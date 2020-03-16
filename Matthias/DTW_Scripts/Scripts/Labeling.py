#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 09:17:42 2020

@author: matthiasboeker
Labelling the data 

Applies the detect_obj_lanechange function to the data

"""
from support_functions import support_function
support = support_function()
#Detecting the overtaking maneuvers
signals = ['Traffic.T00.tRoad', 'Traffic.T00.Lane.Act.LaneId']
label_list = []
for k in range(0,80): 
    data = data_list[k]
    label_list.append(support.detect_obj_langechange(data,threshold = 0.005, step_size=10, max_length=700))

del k
del signals 