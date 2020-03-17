#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 16 16:01:37 2020

@author: matthiasboeker
Allocate clusters and scored data"""


#Set the Columns Approximative Entropy, Variance and Score in DataFrame to allocate to clusters 
ApEn_crop = list()
for i in range(0,len(pre_select)):
    data = pre_select[i]
    data.columns = ['Apen', 'Variance','A-Score']
    ApEn_crop.append(data)
    
    
    
#Allocate ApEn Score to Signal-Cluster-Allocation
#Allocation needed to select the signal with the minimal Score per Cluster
Allocation = list()
for k in range(0,len(ApEn_crop)):
    #DataFrame with calculated score 
   data_ApEn = ApEn_crop[k]
   #DataFrame with clustered signals 
   data_cl = store_alloc[k]
   data_cl.index = data_cl['Signal'].values
   data_ApEn.index = data_cl.index
   data_ApEn['Cluster'] = data_cl['ClusterNr']
   data_ApEn['A-Score'] = np.abs(data_ApEn['A-Score'])
   Allocation.append(data_ApEn)

del ApEn_crop
del k 
del i 