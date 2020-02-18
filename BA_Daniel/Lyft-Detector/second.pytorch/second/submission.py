#!/usr/bin/env python
# coding: utf-8

# In[1]:



# In[2]:


import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import axes3d, Axes3D
from tqdm import tqdm
import pickle
from pathlib import Path
from nuscenes.nuscenes import NuScenes
from scipy.spatial.transform import Rotation as R
from math import cos, sin, pi
from lyft_dataset_sdk.lyftdataset import *
from lyft_dataset_sdk.utils.data_classes import LidarPointCloud, Box, Quaternion
from lyft_dataset_sdk.utils.geometry_utils import view_points, transform_matrix
from second.pytorch.train import build_network, example_convert_to_torch
from second.data.preprocess import merge_second_batch

# In[3]:


import torch
from second.pytorch.builder import (box_coder_builder, input_reader_builder,
                                    lr_scheduler_builder, optimizer_builder,
                                    second_builder)
from google.protobuf import text_format
from second.utils import simplevis
from second.pytorch.train import build_network
from second.protos import pipeline_pb2
from second.utils import config_tool


# In[4]:


# phase = 'test'
# data = 'v1.0-trainval' if phase=='train' else 'v1.0-test'
# lyft = LyftDataset(data_path=f'../../data/lyft/{phase}/', json_path=f'../../data/lyft/{phase}/{data}/', verbose=0)
# nusc = NuScenes(dataroot=f'../../data/lyft/{phase}/', version=data, verbose=0)


# ## Read Config file

# In[5]:

torch.set_num_threads(2)
config_path = "configs/nuscenes/all.pp.lowa_large_range.config"
config = pipeline_pb2.TrainEvalPipelineConfig()
with open(config_path, "r") as f:
    proto_str = f.read()
    text_format.Merge(proto_str, config)
input_cfg = config.eval_input_reader
model_cfg = config.model.second
# config_tool.change_detection_range_v2(model_cfg, [-50, -50, 50, 50])
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")




# ## Build Network, Target Assigner and Voxel Generator

# In[6]:


#info_path = input_cfg.dataset.kitti_info_path
#root_path = input_cfg.dataset.kitti_root_path

info_path = '/home/itiv/Desktop/lyft-dataset/infos_val.pkl'
root_path = '/home/itiv/Desktop/lyft-dataset'
with open(info_path, 'rb') as f:
    infos = pickle.load(f)


#df = pd.read_csv('/home/itiv/Desktop/repo/scenarios_in_CarMaker/BA_Daniel/Lyft-Detector/second.pytorch/second/sample_submission.csv')
#df = pd.read_csv('../../data/lyft/train.csv')



token2info = {}
for info in infos['infos']:
    token2info[info['token']] = info



def thresholded_pred(pred, threshold):
    box3d = pred["box3d_lidar"].detach().cpu().numpy()
    scores = pred["scores"].detach().cpu().numpy()
    labels = pred["label_preds"].detach().cpu().numpy()
    idx = np.where(scores > threshold)[0]
    # filter low score ones
    box3d = box3d[idx, :]
    # label is one-dim
    labels = np.take(labels, idx)
    scores = np.take(scores, idx)
    pred['box3d_lidar'] = box3d
    pred['scores'] = scores
    pred['label_preds'] = labels
    return pred



ckpt_path = "/home/itiv/Desktop/repo/scenarios_in_CarMaker/BA_Daniel/Lyft-Detector/second.pytorch/second/model/model_large_range/voxelnet-10882.tckpt"
net = build_network(config.model.second).to(device).float().eval()
net.load_state_dict(torch.load(ckpt_path))
eval_input_cfg = config.eval_input_reader
eval_input_cfg.dataset.kitti_root_path = root_path
eval_input_cfg.dataset.kitti_info_path = info_path
dataset = input_reader_builder.build(
    eval_input_cfg,
    config.model.second,
    training=False,
    voxel_generator=net.voxel_generator,
    target_assigner=net.target_assigner)#.dataset

batch_size = 2
num_workers = 2

dataloader = torch.utils.data.DataLoader(
    dataset,
    batch_size=batch_size,
    shuffle=False,
    num_workers=num_workers,
    pin_memory=False,
    collate_fn=merge_second_batch)

target_assigner = net.target_assigner
voxel_generator = net.voxel_generator
classes = target_assigner.classes


# ### utility functions

# In[10]:


def to_glb(box, info):
    # lidar -> ego -> global
    # info should belong to exact same element in `gt` dict
    box.rotate(Quaternion(info['lidar2ego_rotation']))
    box.translate(np.array(info['lidar2ego_translation']))
    box.rotate(Quaternion(info['ego2global_rotation']))
    box.translate(np.array(info['ego2global_translation']))
    return box


# In[11]:


def get_pred_str(pred, sample_token):
    boxes_lidar = pred["box3d_lidar"]
    boxes_class = pred["label_preds"]
    scores = pred['scores']
    preds_classes = [classes[x] for x in boxes_class]
    box_centers = boxes_lidar[:, :3]
    box_yaws = boxes_lidar[:, -1]
    box_wlh = boxes_lidar[:, 3:6]
    info = token2info[sample_token] # a `sample` token
    boxes = []
    pred_str = ''
    for idx in range(len(boxes_lidar)):
        translation = box_centers[idx]
        yaw = - box_yaws[idx] - pi/2
        size = box_wlh[idx]
        name = preds_classes[idx]
        detection_score = scores[idx]
        quat = Quaternion(scalar=np.cos(yaw / 2), vector=[0, 0, np.sin(yaw / 2)])
        box = Box(
            center=box_centers[idx],
            size=size,
            orientation=quat,
            score=detection_score,
            name=name,
            token=sample_token
        )
        box = to_glb(box, info)
        pred =  str(box.score) + ' ' + str(box.center[0])  + ' ' \
                + str(box.center[1]) + ' '  + str(box.center[2]) + ' '  \
                + str(box.wlh[0]) + ' ' + str(box.wlh[1]) + ' '  +  \
                str(box.wlh[2]) + ' ' + str(box.orientation.yaw_pitch_roll[0]) \
                + ' ' + str(name) + ' '
        pred_str += pred
    return pred_str.strip()

def get_pred_dict(pred, sample_token):

    # only for nuscenes
    attribute_NameMapping = {
        'bicycle' : 'cycle.with_rider',
        'bus' : 'vehicle.moving',
        'car' : 'vehicle.moving',
	'other_vehicle' : 'vehicle.moving',
        'construction_vehicle' : 'vehicle.moving',
        'motorcycle' : 'cycle.with_rider',
        'pedestrian' : 'pedestrian.moving',
        'trailer' : 'vehicle.moving',
        'truck' : 'vehicle.moving' 
    }

    detection_NameMapping = {
        'bicycle' : 'bicycle',
        'bus' : 'bus',
        'car' : 'car',
	'other_vehicle' : 'car',
        'construction_vehicle' : 'construction_vehicle',
        'motorcycle' : 'motorcycle',
        'pedestrian' : 'pedestrian',
        'trailer' : 'trailer',
        'truck' : 'truck', 
	'barrier': 'barrier',
        'traffic_cone': 'traffic_cone'
    }

    boxes_lidar = pred["box3d_lidar"]
    boxes_class = pred["label_preds"]
    scores = pred['scores']
    preds_classes = [classes[x] for x in boxes_class]
    box_centers = boxes_lidar[:, :3]
    box_yaws = boxes_lidar[:, -1]
    box_wlh = boxes_lidar[:, 3:6]
    info = token2info[sample_token] # a `sample` token
    boxes = []
    pred_str = ''
    dict_frame_detections = {str(sample_token):[]}

    for idx in range(len(boxes_lidar)):
        translation = box_centers[idx]
        yaw = - box_yaws[idx] - pi/2
        size = box_wlh[idx]
        name = preds_classes[idx]
        detection_score = scores[idx]
        quat = Quaternion(scalar=np.cos(yaw / 2), vector=[0, 0, np.sin(yaw / 2)])
        box = Box(
            center=box_centers[idx],
            size=size,
            orientation=quat,
            score=detection_score,
            name=name,
            token=sample_token
        )
        box = to_glb(box, info)
        x = box.center[0]
        y = box.center[1]
        z = box.center[2]
        w = np.float64(box.wlh[0])
        l = np.float64(box.wlh[1])
        h = np.float64(box.wlh[2])
        score = np.float64(box.score)
        q = Quaternion(axis=[0, 0, 1], angle=box.orientation.yaw_pitch_roll[0])
        qw = q.w 
        qx = q.x
        qy = q.y
        qz = q.z

        #print('--')
        #print(f'{type(x)} {type(y)} {type(z)}')
        #print(f'{type(score)}')
        #print(f'{type(w)} {type(l)} {type(h)}')
        #print(f'{type(qw)} {type(qx)} {type(qy)} {type(qz)}')
        #print(type(sample_token))

        dict_frame_detection = {'sample_token':sample_token,'translation':[x,y,z],'size':[w,l,h],'rotation':[qw,qx,qy,qz],'velocity':[0,0],'detection_name':detection_NameMapping[name],'detection_score':score,'attribute_name':attribute_NameMapping[name]}
        dict_frame_detections[str(sample_token)].append(dict_frame_detection)


    return dict_frame_detections



#token2predstr = {}
detections = []
#tokens = []
tk0 = tqdm(dataloader, total=len(dataloader))
for idx, examples in enumerate(tk0):
    try:

        example_torch = example_convert_to_torch(examples, device=device)
        detections += net(example_torch)
        #tokens += examples['metadata']
    except Exception as e:
        print(e)
        import pdb; pdb.set_trace()

threshold = 0.2
#predStrings = []
first_sample_token = detections[0]['metadata']['token']
dict_detections = {"results":{}}

for idx, pred in enumerate(tqdm(detections)):
    pred = thresholded_pred(pred, threshold)
    #token = tokens[idx]['token']
    token = pred['metadata']['token']
    dict_detections['results'].update(get_pred_dict(pred, token))
    #pred_str = get_pred_str(pred, token)
    #predStrings.append(pred_str)
    #index = df[df['Id'] == token].index[0]
    #df.loc[index, 'PredictionString'] = pred_str


#df.to_csv(f'final.csv', index=False)
#print(dict_detections)



path_to_result = f'/home/itiv/Desktop/lyft-dataset/detections-large.json'
with open(path_to_result, 'w') as fp:
    json.dump(dict_detections, fp)

