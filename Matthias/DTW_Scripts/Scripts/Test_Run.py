#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 28 12:27:35 2020

@author: matthiasboeker
For each scenario (each covers 20 runs, 80 in total) the signals with the minimal 
Score per cluster will be selected. 
A multivariate DTW will be applied to the selected signals, which are assumed to contain 
the most information about the lane change of the object. 

The Results are stored in the lists: 
    right_right_Results
    right_left_Results
    left_right_Results
    left_left_Results
Each list containts one scenario with 20 runs

"""

import numpy as np
import pandas as pd
from Multi_sliding_Window import Sliding_Windows 



#Test Run Left 
right_right_Results = list()
#Test Run Right
for j in range(0,20):
    data = data_list[j]
    data = data.drop(signal_list, axis =1)
    signals = Allocation[j].groupby('Cluster')['A-Score'].idxmin().values
    signal_df_right_right = data[signals]
    SRR = Sliding_Windows(ref_signals_right_right[signals], signal_df_right_right,step_size=10)
    out_p = SRR.multi_sliding_window()
    out_df = pd.DataFrame(out_p, columns = signals)
    right_right_Results.append(out_df)
    print('File:',j)

right_left_Results = list()


#Test Run Right
for j in range(20,40):
    data = data_list[j]
    data = data.drop(signal_list, axis =1)
    signals = Allocation[j].groupby('Cluster')['A-Score'].idxmin().values
    signal_df_right_left = data[signals]
    SRL = Sliding_Windows(ref_signals_right_left[signals], signal_df_right_left,step_size=10)
    out_p = SRL.multi_sliding_window()
    out_df = pd.DataFrame(out_p, columns = signals)
    right_left_Results.append(out_df)
    print('File:',j)


left_right_Results = list()
for i in range(40,60):  
    data = data_list[i]
    data = data.drop(signal_list, axis =1)
    signals = Allocation[i].groupby('Cluster')['A-Score'].idxmin().values
    signal_df_left_right = data[signals]
    SLR = Sliding_Windows(ref_signals_left_right[signals], signal_df_left_right,step_size=10)
    out_p = SLR.multi_sliding_window()
    out_df = pd.DataFrame(out_p, columns = signals)
    left_right_Results.append(out_df)
    print('File:',i)

left_left_Results = list()
for i in range(60,80):  
    data = data_list[i]
    data = data.drop(signal_list, axis =1)
    signals = Allocation[i].groupby('Cluster')['A-Score'].idxmin().values
    signal_df_left_left = data[signals]
    SLL = Sliding_Windows(ref_signal_df_left_left[signals], signal_df_left_left,step_size=10)
    out_p = SLL.multi_sliding_window()
    out_df = pd.DataFrame(out_p, columns = signals)
    left_left_Results.append(out_df)
    print('File:',i)


