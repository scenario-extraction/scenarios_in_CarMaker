# Dataset-to-Simulation

## Setup Anaconda environment:
### You need two separate environments for Kitti and Lyft Tracking.
- Kitti-Environment
  -  Install using kitti-environment.yml
  -  Add kitti detector path to environment using: conda develop /your/path/to/Kitti-Detector/second.pytorch
- Lyft-Environment
  -  Install using lyft-environment.yml
  -  Add lyft detector path to environment using: conda develop /your/path/to/Lyft-Detector/second.pytorch

## System-Design:
```Plain
 - Lyft-Data ──> SECOND-Detector ──> Kalman-Filter ──> Nachbearbeitung ──> Konverter ──> Simulation
                                    
 - Kitti-Data ──> Kitti-Detector ──> mmMOT-Tracker ──> Nachbearbeitung ──> Konverter ──> Simulation
```

## Prepare Dataset
### Lyft Dataset File Structure:
```Plain
└── lyft_train_dataset_root/
    ├── images/
    ├── lidar/
    ├── maps/
    ├── v1.0*-train/
    └── v1.0-trainval/  <- softlink to v1.0*-train
└── lyft_test_dataset_root/
    ├── images/
    ├── lidar/
    ├── maps/
    ├── v1.0*-test/
    └── v1.0-test/  <- softlink to v1.0*-test
```

### Kitti Dataset File Structure:
- kitti_dataset_root/
  - image_02/
    -   0000.png
    -   0001.png
    -   ...
    -   xxxx.png
  - velodyne/
    -   0000.bin
    -   0001.bin
    -   ...
    -   xxxx.bin
  - calib/
    -   calib.txt
  - oxts/
    -   oxts.txt

### Based on:
- Kitti-Detector is based on [Secondv1.5.1](https://github.com/traveller59/second.pytorch/tree/v1.5.1) and [Spconv](https://github.com/traveller59/spconv) at commit 7342772 (recent might work as well)
- Kitti-Tracker is based on [mmMOT](https://github.com/ZwwWayne/mmMOT)
- Lyft-Detector is based on [SECOND for Lyft](https://github.com/pyaf/second.pytorch) and recent [Spconv](https://github.com/traveller59/spconv)
-Lyft-Tracker is based on [Probabilistic 3D Multi-Object Tracking for Autonomous Driving](https://github.com/eddyhkchiu/mahalanobis_3d_multi_object_tracking)


### Requirements:
 - CUDA >= 10.0
 - Ubuntu >= 16.04


### Installation:
#### Kitti-Tracker:
 - Install spconv for kitti-env as described in the project directory ./Kitti-Detector/spconv
 - Copy pretrained car_fhd model to ./Kitti-Detector/second.pytorch/pretrained_models_v1.5/car_fhd/
 - Copy pretrained model "pp_pv_40e_dualadd_subabs_C.pth" to Kitt-Tracker/mmMOT/model/ as described on mmMOT Page
#### Lyft-Tracker:
 - Install spconv for lyft-env as described in the project directory ./Lyft-Detector/spconv

### Usage
#### Kitti-Tracking:
 - Copy your scene to the data structure as described above
 - activate the conda kitti-env
 - all commands for Training and Detection generation are summarized in the Kitti-Tracking-System.ipynb Notebook
#### Lyft-Tracking
 - all commands for Training and Detection generation are summarized in the Lyft-Tracking-System.ipynb Notebook
