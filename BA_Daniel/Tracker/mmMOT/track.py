import logging
import os
import pprint
import time
import fire

import torch
import torch.backends.cudnn as cudnn
import torch.optim
import yaml
from easydict import EasyDict
from torch.utils.data import DataLoader
from tracking_model import TrackingModule
from utils.build_util import build_augmentation, build_dataset, build_model
from utils.data_util import write_kitti_result
from utils.train_util import AverageMeter, create_logger, load_state

def start(config_path,dataset_root,result_path,load_path,result_sha,recover=False,evaluate=False):
    global config
    print('####### Tracker start ##########')
    with open(config_path) as f:
        config = yaml.load(f, Loader=yaml.FullLoader)

    config = EasyDict(config['common'])
    config.save_path = os.path.dirname(config_path)

    # create model
    model = build_model(config)
    model.cuda()

    # optionally resume from a checkpoint
    last_iter = -1
    best_mota = 0
    if load_path:
        if recover:
            best_mota, last_iter = load_state(
                load_path, model, optimizer=None)
        else:
            load_state(load_path, model)

    cudnn.benchmark = True

    # Data loading code
    train_transform, valid_transform = build_augmentation(config.augmentation)

    # train_val
    test_dataset = build_dataset(
        config,
	dataset_root=dataset_root,
        set_source='test',
        evaluate=False,
        valid_transform=valid_transform)

    logger = create_logger('global_logger', config.save_path + '/eval_log.txt')
   # logger.info('args: {}'.format(pprint.pformat(args)))
    logger.info('config: {}'.format(pprint.pformat(config)))

    tracking_module = TrackingModule(model, None, None, config.det_type)

    track(test_dataset,result_path, tracking_module, result_sha, part='test')



def track(val_loader,
             result_path,
             tracking_module,
             step,
             part='test',
             fusion_list=None,
             fuse_prob=False):

    logger = logging.getLogger('global_logger')

    logger.info('Start tracking:')
    for i, (sequence) in enumerate(val_loader):
        logger.info('Test: [{}/{}]\tSequence ID: KITTI-{}'.format(i, len(val_loader), sequence.name))
        seq_loader = DataLoader(
            sequence,
            batch_size=config.batch_size,
            shuffle=False,
            num_workers=config.workers,
            pin_memory=True)
        if len(seq_loader) == 0:
            tracking_module.eval()
            logger.info('Empty Sequence ID: KITTI-{}, skip'.format(
                sequence.name))
        else:
            validate_seq(seq_loader, tracking_module)


        logger.info('Writing result to '+str(result_path))
        write_kitti_result(
            result_path,
            sequence.name,
            step,
            tracking_module.frames_id,
            tracking_module.frames_det,
            part=part)

    tracking_module.train()
    return

def validate_seq(val_loader,
                 tracking_module,
                 fusion_list=None,
                 fuse_prob=False):
    batch_time = AverageMeter(0)

    # switch to evaluate mode
    tracking_module.eval()

    logger = logging.getLogger('global_logger')
    end = time.time()
    # Create an accumulator that will be updated during each frame

    with torch.no_grad():
        for i, (input, det_info, dets, det_split) in enumerate(val_loader):
            input = input.cuda()
            if len(det_info) > 0:
                for k, v in det_info.items():
                    det_info[k] = det_info[k].cuda() if not isinstance(
                        det_info[k], list) else det_info[k]

            # compute output
            aligned_ids, aligned_dets, frame_start = tracking_module.predict(
                input[0], det_info, dets, det_split)

            # measure elapsed time
            batch_time.update(time.time() - end)
            end = time.time()
            if i % config.print_freq == 0:
                logger.info(
                    'Test Frame: [{0}/{1}]\tTime'
                    ' {batch_time.val:.3f} ({batch_time.avg:.3f})'.format(
                        i, len(val_loader), batch_time=batch_time))

    return

if __name__ == '__main__':
    fire.Fire()
