#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 16 09:41:34 2020
@author: matthiasboeker

1. The loaded data is cleaned from signals, which are actually unknown by the ego vehicle
2. These signals which are constant are deleted, since they do not contain information and they can not be used for the correaltion analysis 
3. The Approximate Entropy is calculated
4. Signals with zero entropy (non-random systems) are deleted as they don't contain information it is needed (for more information read the ppt)
5. The variance of each signal is calculated
6. The score of approx. entropy and variance is calculated: Var/log(ApEn)
7. Signals with a score outside the interval (-1,1) are deleted. 
    Signals with a repetitive pattern, thus easy to forecast are assumed to contain the highest
    information about the lane change 
    The score is supposed to filter these signals
"""
#Delete Signals which only appear in the simulation and are not sensor data 
signal_list = ['Time','Sensor.Object.OB01.Obj.T00.RefPnt.alpha','Sensor.Object.OB01.Obj.T00.RefPnt.ds.y',
               'Sensor.Object.OB01.Obj.T00.RefPnt.dv.y','Sensor.Object.OB01.Obj.T00.RefPnt.theta', 'Sensor.Object.OB01.Obj.T00.dtct',
               'Time.Global','Traffic.T00.DetectLevel', 'Traffic.T00.Lane.Act.LaneId','Traffic.T00.LongAcc', 'Traffic.T00.LongVel', 
               'Traffic.T00.tRoad']
from ApEN import ApEn
 
#Clean out constant time series with no variance 
ref_list = list(data_list)
for k in range(0,len(ref_list)):
    data = data_list[k]
    ref_list[k] = data.drop(data.loc[:,data.var(axis=0) == 0], axis=1)

#Calculate the Approximative Entropy for each signal 
ApEn_Result_list = list()
for j in range(0, len(ref_list)):
    data = ref_list[j]
    apen_results = np.zeros(ref_list[j].shape[1])
    print('Run',j)
    for i in range(0,len(apen_results)):
        apen_results[i] = ApEN.ApEn(data.iloc[:,i],m=5, r=0.001)
        print('Signal',i)
    apen_results = pd.DataFrame(apen_results)
    apen_results.index = data.columns
    ApEn_Result_list.append(apen_results)


#Clean out random signals/ zero Entropy 
for k in range(0,len(ApEn_Result_list)):
    data = ref_list[k]
    drops = ApEn_Result_list[k]
    ref_list[k] = data.drop(data.loc[:,drops[0] == 0], axis=1)

results_list = list(ApEn_Result_list)

#Calculation of variance 
for k in range(0,len(ApEn_Result_list)):
    data = ref_list[k]
    results_list[k]['Variance']= data.var(axis=0)
    
#Calc simple Å score
for k in range(0,len(results_list)):
    results_list[k]['A-Score'] = np.zeros(len(results_list[k]))
    for i in range(0,len(results_list[k])):    
        results_list[k]['A-Score'][i] = (results_list[k].iloc[i,1]/np.log(results_list[k].iloc[i,0]))
        
pre_select = list(results_list)

#Select signals with A-Score within (-1,1)
for k in range(0,len(pre_select)):
    data = pre_select[k]
    data = data.drop(data[data.index.isin(signal_list)].index)
    pre_select[k] = data.loc[np.abs(data['A-Score'])<1]
    


del ApEn_Result_list 
del signal_list
del k
del i
del j 
del apen_results


