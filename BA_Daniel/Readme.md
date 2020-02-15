# Dataset-to-Simulation

TODO:
 - EGO-Movement-Converter


System-Design:
Lyft-Data ---> Lyft-Detector ----->
                                    ---> Tracker
Kitti-Data ---> Kitti-Detector --->


Lyft Dataset File Structure:
- lyft_dataset_root/


Kitti Dataset File Structure:
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

Based on:
- Detector is based on Secondv1.5.1 and spconv at commit 7342772 
- Tracker is based on mmMOT

Requirements:
 - CUDA >= 9.0
 - Ubuntu >= 16.04


Installation:
 - Setup conda environment using environment.yml 
 - Install spconv as deescribed in
 - Copy pretrained model "pp_pv_40e_dualadd_subabs_C.pth" to Tracker/mmMOT/model/
