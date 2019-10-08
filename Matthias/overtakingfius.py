#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Jul  2 09:54:34 2019

@author: matthiasboeker
"""

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

label_lat_ego_r = pd.DataFrame(data=label_lat_ego)
label_lat_ego_r.iloc[label_lat_ego_r == 1] = 0
label_lat_ego_l = pd.DataFrame(data=label_lat_ego)
label_lat_ego_l.iloc[label_lat_ego_l == -1] = 0


#Extract Signal
signal = np.transpose(mat['Signal_object'])

#Plot Signal and Labels 
plt.plot(signal)
plt.ylabel('Raw Signal')
plt.plot(label_lat_ego)
plt.ylabel('Label')
plt.show()

#Extract Reference Signal 
ref_right = mat['R_object_lcr']
ref_left = mat['R_object_lcl']

plt.plot(ref_right)
plt.ylabel('Ref right')
plt.show()

plt.plot(ref_left)
plt.ylabel('Ref left')
plt.show()


#Sliding Window approach
win_size_l = len(ref_left)
win_size_r = len(ref_right)
ss_l = int(win_size_l/10)
ss_r = int(win_size_r/10)
dist_left = list()
dist_right = list()
ctest = list()



#First sliding window approach - overtaking left
label_lat_ego_l_ref = list()
for i in range(0,int(len(label_lat_ego_r))-win_size_l, ss_l):
    t = label_lat_ego_l[i:i+win_size_l]
    if np.count_nonzero(~np.isnan(t[t == 1]))>int(win_size_l*(1/2)):
        label_lat_ego_l_ref.append(1)
    else:
        label_lat_ego_l_ref.append(0)
    
#First sliding window approach - overtaking right 
label_lat_ego_r_ref = list()
for i in range(0,int(len(label_lat_ego_r)/8)-win_size_r, ss_r):
    t = label_lat_ego_r[i:i+win_size_r]
    if np.count_nonzero(~np.isnan(t[t == -1]))>int(win_size_l*(1/2)):
        label_lat_ego_r_ref.append(1)
    else:
        label_lat_ego_r_ref.append(0)

    
#First sliding window approach - overtaking left 
#Mistake: WATCH END OF SIGNAL: WINDOW BECOMES SMALLER


for i in range(0,int(len(signal))-win_size_l, ss_l):
    tsignal = signal[i:i+win_size_l]
    cost, path = dtw_1.simple_DTW(ref_left,tsignal)
    dist_left.append(cost)
#First sliding window approach - overtaking right 
for i in range(0,int(len(signal))-win_size_r, ss_r):
    tsignal = signal[i:i+win_size_r]
    cost, path = dtw_1.simple_DTW(ref_right,tsignal)
    dist_right.append(cost) 


sw_test = SWindow(ref_left, signal, label_lat_ego_l, 10, 1/8)


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
plt.plot(dist_left)
plt.ylabel('Label')
plt.show()



