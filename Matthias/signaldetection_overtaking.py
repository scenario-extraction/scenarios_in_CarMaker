#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 21 14:46:57 2019

@author: matthiasboeker
Class of different supportive functions """

import pandas as pd
import numpy as np

class support_functions():

    #Generates a random walk for comparision purposes
    def gen_random_walk(step_n=10000):
        dims = 1
        step_set = [-0.1, 0, 0.1]
        origin = np.zeros((1,dims))
        # Simulate steps in 1D
        step_shape = (step_n,dims)
        steps = np.random.choice(a=step_set, size=step_shape)
        path = np.concatenate([origin, steps]).cumsum(0)
        start = path[:1]
        stop = path[-1:]
        return path
    
    
    #Calculates the trace of a matrix
    def trace(matrix):
        tsum = 0 
        #Check if matrix is diagonal 
        if matrix.shape[0]==matrix.shape[1]:
            for i in range(0,matrix.shape[0]):
                tsum = tsum + matrix[i,i]
            return tsum
        else:
            print('Matrix is not diagonal! Matrix must be of shape [N,N]')
        
    #Normalises a timeseries
    def z_norm(series):
        max_s = max(series)
        min_s = min(series)
        for i in range(0, len(series)):
            series[i] = (series[i]-min_s)/(max_s-min_s)
        return series
    
    #Standardises a timeseries 
    def z_stand(series):
        mean_s = np.mean(series)
        std_s = np.std(series)
        for i in range(0, len(series)):
            series[i] = ((series[i]-mean_s)/std_s)
        return series
            
    #Calculates the Autocorrelation function (?)
    def autocorr(x):
        result = np.correlate(x, x, mode='full')
        return result[result.size // 2:]
    
    #Calculates the sample derivative of a timeseries
    def derivative(series):
        for k in range(1,len(series)-1):
            derv[k] = 1/2*(series.iloc[k]-series.iloc[k-1])+ 1/4*(series.iloc[k+1]-series.iloc[k-1])
        return derv
    # Function to detect overtaking signal in a DisToLeft or DisToRight Signal 
    def signaldetection(series, threshold):
        res_min_list = []
        res_max_list = []
        derv = np.zeros(len(series))
        for k in range(1,len(series)-1):
            derv[k] = 1/2*(series.iloc[k]-series.iloc[k-1])+ 1/4*(series.iloc[k+1]-series.iloc[k-1])
        max_mask = np.where(derv > 1)[0]
        min_mask = np.where(derv < -1)[0]
        glmean = np.mean(derv)
        
        for i in range(0,len(min_mask)):
            index = min_mask[i]
            j=1
            sig = 1000
            while (sig > threshold) and (j+index < len(derv)-1):
                
                sig = float((derv[index+j]-glmean)**2)
                j = j+1
            res_min_list.append([index-j,index+j])
        
        for i in range(0,len(max_mask)):
            index = max_mask[i]
            j=1
            sig = 1000
            while (sig > threshold) and (j+index < len(derv)-1):
                
                sig = float((derv[index+j]-glmean)**2)
                j = j+1
            res_max_list.append([index-j,index+j])
            te
        return res_max_list, res_min_list



