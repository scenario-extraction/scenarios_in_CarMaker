#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep  8 12:05:09 2019

@author: matthiasboeker
"""
import time
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import scipy.io
import csv

#Import data 
mat = scipy.io.loadmat('dataprepation.mat')

#Import labelled data
labels = pd.read_csv('Ground_Truth_label_Highway_TestRun_10.csv', header=None , skiprows = 1, sep=',')
labels.columns = ['Time', 'label_ego_long', 'label_ego_lat', 'label_TObj_long', 'label_TObj_lat', 'label_ObjId']
label_lat_ego = labels['label_ego_lat']
label_long_ego = labels['label_ego_long']

label_lat_ego_r = pd.DataFrame(data=label_lat_ego)
label_lat_ego_r.iloc[label_lat_ego_r == 1] = 0
label_lat_ego_l = pd.DataFrame(data=label_lat_ego)
label_lat_ego_l.iloc[label_lat_ego_l == -1] = 0

label_long_ego_b = pd.DataFrame(data=label_long_ego)
label_long_ego_b.iloc[label_long_ego_b == 1] = 0
label_long_ego_a = pd.DataFrame(data=label_long_ego)
label_long_ego_a.iloc[label_long_ego_a == -1] = 0



#Extract Signal
signal = np.transpose(mat['Signal_object'])


#Extract Reference Signal 
ref_right = mat['R_ego_lcr']
ref_left = mat['R_ego_lcl']

#Create Object
swindow_lat = SWindow(ref_left, signal, label_lat_ego, 25, 1/8)

label_lat_ego_r = swindow_lat.sliding_window_label(1/2,-1)

start = time.time()
dist_right = swindow_lat.sliding_window()
end= time.time()
print(end-start)

#Labelling the data
#Overtaking left

df_dl = pd.DataFrame(dist_left) 
df_dl.columns = ['signal']
df_dl['label'] = label_lat_ego_l_ref

#Overtaking right
df_dr = pd.DataFrame(dist_right) 
df_dr.columns = ['signal']
df_dr['label'] = label_lat_ego_r_ref  


plt.plot(dist_right)
plt.ylabel('Raw Signal')
plt.show


plt.plot(dist_right)
plt.ylabel('Label')
plt.show()

