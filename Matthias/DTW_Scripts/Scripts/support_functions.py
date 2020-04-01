#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 21 14:46:57 2019

@author: matthiasboeker
Class of different supportive functions:
    
    1. read_in_data
    Input: - directory path
           - empty list to store data in 
    Output: Data_List with one DataFrame per Simulation run containing all recorded signals of the simulation in CarMaker
    
    2. detect_obj_lanechange
    Input: - Dataframe with all the signals, including the signals about the object traffic vehicle 
           - max_length: window length used in the DTW
           - step size
    Output: Range of start and end position of the objects lane change 
    
            
"""


class support_function():
    
    
    
    #Read in Data from the Directory     
    def read_in_data(self,path, data_list):
        import os
        import pandas as pd
        import numpy as np
        os.chdir(path)
        data_files = []
        for file in os.listdir():
            if file.endswith('.dat'):
                data_files.append(file)
                
        #data_list = data_list
        for i in range(0,len(data_files)):        
            header = pd.read_csv('Header_SimRes.csv', sep=';', header=None)
            data = np.loadtxt(data_files[i])
            data = pd.DataFrame(data, columns = header.iloc[0])
            data_list.append(data)
        
    
    #Detect object lanechanges for labelling pureposes 
    def detect_obj_langechange(self, data,threshold = 0.005, step_size=10, max_length=700):
        import os
        import pandas as pd
        import numpy as np
        #Reduce the dataset 
        
        #Detect the middle of the lane change 
        lchange_in = np.where(data['Traffic.T00.Lane.Act.LaneId'][:-1].values != data['Traffic.T00.Lane.Act.LaneId'][1:].values)[0]
        
        #find the borders of the lane change
        i = lchange_in[0]
        j = lchange_in[0]
        start = lchange_in[0]
    
        #minus direction
        while (np.abs(data['Traffic.T00.tRoad'][i]-data['Traffic.T00.tRoad'][i-step_size]) > threshold) or (np.abs(i-start)>max_length):
            if i < 2:
                end_pos_top = i 
            else: 
                i -= 1
        end_pos_top = i
        
        #plus direction
        while (np.abs(data['Traffic.T00.tRoad'][j]-data['Traffic.T00.tRoad'][j+step_size]) > threshold) or (np.abs(j-start)>max_length):
            if j < 2:
                end_pos_bottom = j 
            else: 
                j += 1
        end_pos_bottom = j
        
        return end_pos_top, end_pos_bottom

    
    #Calculates the trace of a matrix
    def trace(self, matrix):
        tsum = 0 
        #Check if matrix is diagonal 
        if matrix.shape[0]==matrix.shape[1]:
            for i in range(0,matrix.shape[0]):
                tsum = tsum + matrix[i,i]
            return tsum
        else:
            print('Matrix is not diagonal! Matrix must be of shape [N,N]')
        

    #Normalises a timeseries
    def z_norm(self, series):
        import pandas as pd
        import numpy as np
        max_s = max(series)
        min_s = min(series)
        
        if isinstance(series, pd.Series):
            for i in range(0, len(series)):
                series.iloc[i] = (series.iloc[i]-min_s)/(max_s-min_s)
        else: 
            for i in range(0, len(series)):
                series[i] = (series[i]-min_s)/(max_s-min_s)
            
        return series
    
    #Standardises a timeseries 
    def z_stand(self,series):
        mean_s = np.mean(series)
        std_s = np.std(series)
        for i in range(0, len(series)):
            series[i] = ((series[i]-mean_s)/std_s)
        return series
            
    
    #Calculates the sample derivative of a timeseries
    def derivative(self, series):
        for k in range(1,len(series)-1):
            derv[k] = 1/2*(series.iloc[k]-series.iloc[k-1])+ 1/4*(series.iloc[k+1]-series.iloc[k-1])
        return derv


