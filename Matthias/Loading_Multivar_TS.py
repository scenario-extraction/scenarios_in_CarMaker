# -*- coding: utf-8 -*-
"""
Spyder Editor

Loading Mutivariate TS
"""

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os
import math
import scipy.signal

os.chdir('/Users/matthiasboeker/Documents/Uni/ITIV/TS_Classification_DTW/Multivariate_Data/SimOut')
data_files = []
for file in os.listdir():
    if file.endswith('.dat'):
        data_files.append(file)

data_list = []
for i in range(0,len(data_files)):        
    header = pd.read_csv('Header_SimRes.csv', sep=';', header=None)
    data = np.loadtxt(data_files[i])
    data = pd.DataFrame(data, columns = header.iloc[0])
    data_list.append(data)
    
laneID = data['Car.Road.Lane.Act.LaneId']
lanech = laneID[laneID == 1].index.tolist()
DisToRight = data['LatCtrl.DistToRight']
Ego_vel = data['Car.v']
Ego_Acc_y = data['Car.ay']
Ego_Acc_x = data['Car.ax']
Ego_Yaw = data['Car.Yaw']
Ego_Yaw_R = data['Car.YawRate']
Obj_ds_x = data['Sensor.Object.OB01.relvTgt.RefPnt.ds.x']
Obj_ds_y = data['Sensor.Object.OB01.relvTgt.RefPnt.ds.y']
Obj_dv_x = data['Sensor.Object.OB01.relvTgt.RefPnt.dv.x']
Obj_dv_y = data['Sensor.Object.OB01.relvTgt.RefPnt.dv.y']
im_rad = ((Ego_vel**2)/np.fabs(Ego_Acc_y))
y_off = (im_rad - np.sqrt((im_rad**2)-(Ego_ds_x**2)))*np.sign(Ego_Acc_y)
DisToLeft = data['LatCtrl.DistToLeft']
Object_DisToLeft = DisToLeft-(Ego_ds_y-y_off)

frame = {'DisToLeft': DisToLeft, 'Ego_vel': Ego_vel, 'Ego_Acc_y': Ego_Acc_y, 'Ego_Acc_x': Ego_Acc_x, 'Ego_Yaw': Ego_Yaw, 
         'Ego_Yaw_R': Ego_Yaw_R, 'Obj_ds_x':Obj_ds_x, 'Obj_ds_y':Obj_ds_y, 'Obj_dv_x':Obj_dv_x, 'Obj_dv_y':Obj_dv_y }
test_pca_DF = pd.DataFrame(frame)
