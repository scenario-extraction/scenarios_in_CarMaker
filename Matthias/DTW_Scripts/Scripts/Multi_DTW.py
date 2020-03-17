#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec  4 21:22:08 2019

@author: matthiasboeker
Mutlivariate cumulative Dynamic Time Warping 
Function applies the DTW Algorithm to each Dimension independently and sums-up the 
costs.
Input: Two timeseries with k dimensions, respectively 
Output: Cost
Both timeseries must have the same amount of dimensions
Consider, that the dimensions have to be ordered. The function applies DTW column by column

Multi DTW runs with both, 
-the generic DTW, Scripts can be found in the directory DTW_Algo
(RECOMMENDED) the fastdtw package, which is much faster in processing time 
"""
import numpy as np
from scipy.spatial.distance import euclidean
from fastdtw import fastdtw

def Multi_DTW(tseries1, tseries2):
    
    #Check if both timeseries have the same amount of dimensions
    if tseries1.shape[1] != tseries2.shape[1]:
        print("Multivariate timeseries need to have the same dimensions")
    else:
        
        
        #Create DTW object from class DTW
        dtw = DTW() 
        #Create normalisation function object from class 
        normalise = support_functions()
        cost_vector = numpy.zeros(tseries2.shape[1])
    
        #Simple loop which applies DTW column by column 
        #Sums up the costs
        for i in range(0,tseries2.shape[1]):
            if len(set(tseries1)) == 1:
                norm_ts1 = tseries1.iloc[:,i]
            else:
                norm_ts1 = normalise.z_norm(tseries1.iloc[:,i])
            if len(set(tseries2)) == 1:
                norm_ts2 = tseries2.iloc[:,i]
            else:
                norm_ts2 = normalise.z_norm(tseries2.iloc[:,i])
           
            #cost_vector[i],_ = dtw.simple_DTW(tseries1.iloc[:,i],tseries2.iloc[:,i])
            cost_vector[i],_ =  fastdtw(tseries1.iloc[:,i],tseries2.iloc[:,i])
            
            
        cost_sum = numpy.sum(cost_vector)
        
        return cost_sum, cost_vector 
        
        
    