#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 28 14:36:55 2020

@author: matthiasboeker


Class 1 Sliding_Windows:
   Applies the multivariate DTW iterative on each window, while window with lenght of the reference signak 
   slides with a certain step_size over the signal 
   
   Input:
       - Reference Signal
       - Signal 
       -Step_size
       -Testing_p: The signal can be cropped down by the size of (1/n), or debugging reasons or others,

    Output: A Series of costs per applied window, the lenght depends on the signal size, the window size
            and the step size 

Class 2 Fast_Multi_DTW

Mutlivariate  Dynamic Time Warping 
Function applies the DTW Algorithm to each Dimension independently and calulates the costs

Input: Two timeseries with k dimensions, respectively 
Output: Cost

Both timeseries must have the same amount of dimensions
Consider, that the dimensions have to be ordered. The function applies DTW column by column

Multi DTW runs with both, 
-the generic DTW, Scripts can be found in the directory DTW_Algo
(RECOMMENDED) the fastdtw package, which is much faster in processing time 
"""

class Sliding_Windows():
    
        def __init__(self, ref_signal,  signal, step_size=10, testing_p = 1 ):
            import numpy as np
            import pandas as pd
            from Multi_sliding_Window import Fast_Multi_DTW
            self.signal = signal
            self.ref_signal = ref_signal
            self.win_size = len(self.ref_signal)
            self.step_size = step_size
            self.ss_l = int(self.win_size/step_size)
            self.cost_l = list()
            self.testing_p = testing_p
            
            
        def multi_sliding_window(self):
            
            fmdtw = Fast_Multi_DTW(self.signal,self.ref_signal)
            for i in range(0,int(len(self.signal)*self.testing_p)-self.win_size, self.step_size):
                tsignal = self.signal[i:i+self.win_size]
                _,cost = fmdtw.Multi_DTW()
                self.cost_l.append(cost)
            return self.cost_l
        

class Fast_Multi_DTW():
    
    def __init__(self, ref_signal,  signal):
        self.signal = signal
        self.ref_signal = ref_signal
    
    def Multi_DTW(self):
        import numpy as np
        import pandas as pd
        from fastdtw import fastdtw 
        from support_functions import support_function
        #Check if both timeseries have the same amount of dimensions
        if self.signal.shape[1] != self.ref_signal.shape[1]:
            print("Multivariate timeseries need to have the same dimensions")
        else:
                    
            #Create DTW object from class DTW
            #dtw = DTW() 
            #Create normalisation function object from class 
            normalise = support_function()
            cost_vector = np.zeros(self.ref_signal.shape[1])
                
            #Simple loop which applies DTW column by column 
            #Sums up the costs
            for i in range(0,self.ref_signal.shape[1]):
                if len(set(self.signal)) == 1:
                    norm_ts1 = self.signal.iloc[:,i]
                else:
                    norm_ts1 = normalise.z_norm(self.signal.iloc[:,i])
                if len(set(self.ref_signal)) == 1:
                    norm_ts2 = self.ref_signal.iloc[:,i]
                else:
                    norm_ts2 = normalise.z_norm(self.ref_signal.iloc[:,i])
                    
                #cost_vector[i],_ = dtw.simple_DTW(tseries1.iloc[:,i],tseries2.iloc[:,i])
                cost_vector[i],_ =  fastdtw(self.signal.iloc[:,i],self.ref_signal.iloc[:,i])
            
            
            cost_sum = np.sum(cost_vector)
                
            return cost_sum, cost_vector 
        
