#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 30 10:52:33 2020

@author: matthiasboeker
Evaluation"""


ground_truth = label_list

#Simple sum

dtw_windowed = list()
dtw_result_list = list([right_right_Results,right_left_Results,left_right_Results,left_left_Results])
#Simple addition
for j in range(0,len(dtw_result_list)):
    bins = dtw_result_list[j]
    for i in range(0,len(bins)):
        file = bins[i]
        sum_vec = np.zeros(len(file))
        for j in range(0,len(file)):
            sum_vec[j] = np.sum(file[j])
        dtw_windowed.append(sum_vec)


#Evaluation

results_sum = np.zeros(len(dtw_windowed))
for i in range(0,len(dtw_windowed)):
    start = np.argmin(dtw_windowed[i])
    interval_dtw = np.array(range(start*10,(start*10)+280))
    interval_gt = np.array(range(ground_truth[i][0],ground_truth[i][1]))
    overlap = np.isin(interval_gt,interval_dtw).astype(int)
    if sum(overlap)> len(overlap)*0.5:
        results_sum[i] = 1



#Evaluation of every single signal used    
results_single  = np.zeros((len(dtw_windowed),7))
single_signal_list = list()
single_signal_list.append(VC_Steer_Ang_l)
single_signal_list.append(Car_WRL_rot_l)
single_signal_list.append(Car_ax_l)
single_signal_list.append(Path_DevAng_l)
single_signal_list.append(T00_RefPnt_ds_y_l)
single_signal_list.append(T00_RefPnt_alpha_l)
single_signal_list.append(T00_RefPnt_dv_y_l)


results_single  = np.zeros((len(dtw_windowed),7))
for j in range(0,7):
    bins = single_signal_list[j]
    for i in range(0,len(dtw_windowed)):   
        start = np.argmin(bins[i])
        interval_dtw = np.array(range(start*10,(start*10)+280))
        interval_gt = np.array(range(ground_truth[i][0],ground_truth[i][1]))

        overlap = np.isin(interval_gt,interval_dtw).astype(int)
        if sum(overlap)> len(overlap)*0.5:
            results_single[i,j] = 1

header = ['VC.Steer.Ang','Car.WRL.rot','Car.ax', 'Path.DevAng','T00.RefPnt.ds.y', 'T00.RefPnt.alpha', 'T00.RefPnt.dv.y']
results_signals = pd.DataFrame(results_single, columns = header) 
results_signals.to_csv('Results_Signals_new.csv', index=False)




#Evaluation of weighted sum best three signals

weighted_sum_dtw = list()
for j in range(0,len(dtw_result_list)):
    bins = dtw_result_list[j]
    for i in range(0,len(bins)):
        file = bins[i]
        sum_vec = np.zeros(len(file))
        for j in range(0,len(file)):
            sum_vec[j] = 0.3*file[j][5]+0.5*file[j][4]+0.2*file[j][2]
        weighted_sum_dtw.append(sum_vec)

#Evaluation

results_weighted_sum = np.zeros(len(dtw_windowed))
for i in range(0,len(dtw_windowed)):
    start = np.argmin(weighted_sum_dtw[i])
    interval_dtw = np.array(range(start*10,(start*10)+280))
    interval_gt = np.array(range(ground_truth[i][0],ground_truth[i][1]))
    overlap = np.isin(interval_gt,interval_dtw).astype(int)
    if sum(overlap)> len(overlap)*0.5:
        results_weighted_sum[i] = 1
    
header = ['Weighted Sum Result']
results_wighted_sum = pd.DataFrame(results_weighted_sum, columns = header) 
results_wighted_sum.to_csv('Results_WS_new.csv', index=False)



