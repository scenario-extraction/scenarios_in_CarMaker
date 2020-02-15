import os
import pathlib
import pickle
import shutil
import time
from functools import partial
import json 
import fire
import numpy as np
import torch
from google.protobuf import text_format
from tensorboardX import SummaryWriter
import copy
import torchplus
from second.core import box_np_ops
import second.data.kitti_common as kitti
from second.builder import target_assigner_builder, voxel_builder
from second.data.preprocess import merge_second_batch
from second.protos import pipeline_pb2
from second.pytorch.builder import (box_coder_builder, input_reader_builder,
                                      lr_scheduler_builder, optimizer_builder,
                                      second_builder)
from second.utils.eval import get_coco_eval_result, get_official_eval_result
from second.utils.progress_bar import ProgressBar
from second.utils.log_tool import metric_to_str, flat_nested_json_dict


def detect(config_path,
             model_dir=None,
             result_path=None,
             ckpt_path=None,
             ref_detfile=None,
             pickle_result=True,
             measure_time=False,
             batch_size=None):
    result_name = 'eval_results'
    if result_path is None:
        model_dir = pathlib.Path(model_dir)
        result_path = model_dir / result_name
    else:
        result_path = pathlib.Path(result_path)
    if isinstance(config_path, str):
        # directly provide a config object. this usually used 
        # when you want to eval with several different parameters in
        # one script.
        config = pipeline_pb2.TrainEvalPipelineConfig()
        with open(config_path, "r") as f:
            proto_str = f.read()
            text_format.Merge(proto_str, config)
    else:
        config = config_path

    input_cfg = config.eval_input_reader
    model_cfg = config.model.second
    train_cfg = config.train_config
    
    center_limit_range = model_cfg.post_center_limit_range
    ######################
    # BUILD VOXEL GENERATOR
    ######################
    net = build_network(model_cfg, measure_time=measure_time).cuda()
    if train_cfg.enable_mixed_precision:
        net.half()
        print("half inference!")
        net.metrics_to_float()
        net.convert_norm_to_float(net)
    target_assigner = net.target_assigner
    voxel_generator = net.voxel_generator
    class_names = target_assigner.classes

    if ckpt_path is None:
        assert model_dir is not None
        torchplus.train.try_restore_latest_checkpoints(model_dir, [net])
    else:
        torchplus.train.restore(ckpt_path, net)

    batch_size = batch_size or input_cfg.batch_size
    eval_dataset = input_reader_builder.build(
        input_cfg,
        model_cfg,
        training=False,
        voxel_generator=voxel_generator,
        target_assigner=target_assigner)
    eval_dataloader = torch.utils.data.DataLoader(
        eval_dataset,
        batch_size=batch_size,
        shuffle=False,
        num_workers=0,# input_cfg.num_workers,
        pin_memory=False,
        collate_fn=merge_second_batch)

    if train_cfg.enable_mixed_precision:
        float_dtype = torch.float16
    else:
        float_dtype = torch.float32

    net.eval()
    result_path_step = result_path #/ f"step_{net.get_global_step()}"
    result_path_step.mkdir(parents=True, exist_ok=True)
    t = time.time()
    dt_annos = []
    print("Generate output labels...")
    bar = ProgressBar()
    bar.start((len(eval_dataset) + batch_size - 1) // batch_size)
    prep_example_times = []
    prep_times = []
    t2 = time.time()
    for example in iter(eval_dataloader):
        if measure_time:
            prep_times.append(time.time() - t2)
            t1 = time.time()
            torch.cuda.synchronize()
        example = example_convert_to_torch(example, float_dtype)
        if measure_time:
            torch.cuda.synchronize()
            prep_example_times.append(time.time() - t1)
        dt_annos += predict_to_kitti_label(
                net, example, class_names, center_limit_range,
                model_cfg.lidar_input)
        # print(json.dumps(net.middle_feature_extractor.middle_conv.sparity_dict))
        bar.print_bar()
        if measure_time:
            t2 = time.time()

    sec_per_example = len(eval_dataset) / (time.time() - t)
    print(f'generate label finished({sec_per_example:.2f}/s). start eval:')
    if measure_time:
        print(f"avg example to torch time: {np.mean(prep_example_times) * 1000:.3f} ms")
        print(f"avg prep time: {np.mean(prep_times) * 1000:.3f} ms")
    for name, val in net.get_avg_time_dict().items():
        print(f"avg {name} time = {val * 1000:.3f} ms")
    if pickle_result:
        print('Frames analyzed:'+str(len(dt_annos)))
        with open(result_path_step / "result.pkl", 'wb') as f:
            pickle.dump(dt_annos, f)
    else:
        kitti_anno_to_label_file(dt_annos, result_path_step)

    #result_official, result_coco = eval_dataset.dataset.evaluation(dt_annos)
    #if result_official is not None:
    #    print(result_official)
    #    print(result_coco)

def example_convert_to_torch(example, dtype=torch.float32,
                             device=None) -> dict:
    device = device or torch.device("cuda:0")
    example_torch = {}
    float_names = [
        "voxels", "anchors", "reg_targets", "reg_weights", "bev_map"
    ]
    for k, v in example.items():
        if k in float_names:
            # slow when directly provide fp32 data with dtype=torch.half
            example_torch[k] = torch.tensor(v, dtype=torch.float32, device=device).to(dtype)
        elif k in ["coordinates", "labels", "num_points"]:
            example_torch[k] = torch.tensor(
                v, dtype=torch.int32, device=device)
        elif k in ["anchors_mask"]:
            example_torch[k] = torch.tensor(
                v, dtype=torch.uint8, device=device)
        elif k == "calib":
            calib = {}
            for k1, v1 in v.items():
                calib[k1] = torch.tensor(v1, dtype=dtype, device=device).to(dtype)
            example_torch[k] = calib
        else:
            example_torch[k] = v
    return example_torch


def build_network(model_cfg, measure_time=False):
    voxel_generator = voxel_builder.build(model_cfg.voxel_generator)
    bv_range = voxel_generator.point_cloud_range[[0, 1, 3, 4]]
    box_coder = box_coder_builder.build(model_cfg.box_coder)
    target_assigner_cfg = model_cfg.target_assigner
    target_assigner = target_assigner_builder.build(target_assigner_cfg,
                                                    bv_range, box_coder)
    class_names = target_assigner.classes
    net = second_builder.build(model_cfg, voxel_generator, target_assigner, measure_time=measure_time)
    return net

def predict_to_kitti_label(net,
                          example,
                          class_names,
                          center_limit_range=None,
                          lidar_input=False):
    predictions_dicts = net(example)
    limit_range = None
    if center_limit_range is not None:
        limit_range = np.array(center_limit_range)
    annos = []
    for i, preds_dict in enumerate(predictions_dicts):
        box3d_lidar = preds_dict["box3d_lidar"].detach().cpu().numpy()
        box3d_camera = None
        scores = preds_dict["scores"].detach().cpu().numpy()
        label_preds = preds_dict["label_preds"].detach().cpu().numpy()
        if "box3d_camera" in preds_dict:
            box3d_camera = preds_dict["box3d_camera"].detach().cpu().numpy()
        bbox = None
        if "bbox" in preds_dict:
            bbox = preds_dict["bbox"].detach().cpu().numpy()
        anno = kitti.get_start_result_anno()
        num_example = 0
        for j in range(box3d_lidar.shape[0]):
            if limit_range is not None:
                if (np.any(box3d_lidar[j, :3] < limit_range[:3])
                        or np.any(box3d_lidar[j, :3] > limit_range[3:])):
                    continue
            if "bbox" in preds_dict:
                assert "image_shape" in preds_dict["metadata"]["image"]
                image_shape = preds_dict["metadata"]["image"]["image_shape"]
                if bbox[j, 0] > image_shape[1] or bbox[j, 1] > image_shape[0]:
                    continue
                if bbox[j, 2] < 0 or bbox[j, 3] < 0:
                    continue
                bbox[j, 2:] = np.minimum(bbox[j, 2:], image_shape[::-1])
                bbox[j, :2] = np.maximum(bbox[j, :2], [0, 0])
                anno["bbox"].append(bbox[j])
                # convert center format to kitti format
                # box3d_lidar[j, 2] -= box3d_lidar[j, 5] / 2
                anno["alpha"].append(-np.arctan2(-box3d_lidar[j, 1], box3d_lidar[j, 0]) +
                                    box3d_camera[j, 6])
                anno["dimensions"].append(box3d_camera[j, 3:6])
                anno["location"].append(box3d_camera[j, :3])
                anno["rotation_y"].append(box3d_camera[j, 6])

               ### added for mmmot compatibility
               #anno["image_idx"] = preds_dict["metadata"]["image"]["image_idx"]
            else:
                # bbox's height must higher than 25, otherwise filtered during eval
                anno["bbox"].append(np.array([0, 0, 50, 50]))
                # note that if you use raw lidar data to eval,
                # you will get strange performance because
                # in standard KITTI eval, instance with small bbox height
                # will be filtered. but it is impossible to filter
                # boxes when using raw data.
                anno["alpha"].append(0.0)
                anno["dimensions"].append(box3d_lidar[j, 3:6])
                anno["location"].append(box3d_lidar[j, :3])
                anno["rotation_y"].append(box3d_lidar[j, 6])

            anno["name"].append(class_names[int(label_preds[j])])
            anno["truncated"].append(0.0)
            anno["occluded"].append(0)
            anno["score"].append(scores[j])


            num_example += 1
        if num_example != 0:
            anno = {n: np.stack(v) for n, v in anno.items()}
            annos.append(anno)
        else:
            annos.append(kitti.empty_result_anno())
        num_example = annos[-1]["name"].shape[0]
        annos[-1]["metadata"] = preds_dict["metadata"]
    return annos

def kitti_anno_to_label_file(annos, folder):
    folder = pathlib.Path(folder)
    for anno in annos:
        image_idx = anno["metadata"]["image"]["image_idx"]
        label_lines = []
        for j in range(anno["bbox"].shape[0]):
            label_dict = {
                'name': anno["name"][j],
                'alpha': anno["alpha"][j],
                'bbox': anno["bbox"][j],
                'location': anno["location"][j],
                'dimensions': anno["dimensions"][j],
                'rotation_y': anno["rotation_y"][j],
                'score': anno["score"][j],
            }
            label_line = kitti.kitti_result_line(label_dict)
            label_lines.append(label_line)
        label_file = folder / f"{kitti.get_image_index_str(image_idx)}.txt"
        label_str = '\n'.join(label_lines)
        with open(label_file, 'w') as f:
            f.write(label_str)


if __name__ == '__main__':
    fire.Fire()

