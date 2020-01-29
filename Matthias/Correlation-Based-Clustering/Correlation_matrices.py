#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec  6 11:25:02 2019

@author: matthiasboeker
Create Correlation Matrices and Dendrograms for test runs"""
import matplotlib
import matplotlib.pyplot as plt
import os
import numpy as np
import pandas as pd
import seaborn as sns
import scipy.cluster.hierarchy as sch
import csv



for i in range(0,len(data_list)):
    data = data_list[i]
    
    #data.to_csv('/Users/matthiasboeker/Documents/Uni/ITIV/TS_Classification_DTW/Multivariate_Data/Data_Left_2.csv'
               # ,sep=";", index = False)
    #Check which columns do not vary
    proc_data = data.loc[:, (data != data.iloc[0]).any()] 
    #proc_data.to_csv('/Users/matthiasboeker/Documents/Uni/ITIV/TS_Classification_DTW/Multivariate_Data/p_Data_Left_1.csv'
               # ,sep=";", index = False)
    
    #Create Correlation Matrix
    corr = proc_data.corr()
    corr = 1- corr.abs()
    
    #corr.to_csv('/Users/matthiasboeker/Documents/Uni/ITIV/TS_Classification_DTW/Multivariate_Data/Corr_Right_2.csv'
                #,sep=";", index = False)
    
    #Prepare Heatmap
    mask = np.zeros_like(corr, dtype=np.bool)
    mask[np.triu_indices_from(mask)] = True
    f, ax = plt.subplots(figsize=(12, 10))
    sns.heatmap(corr, mask=mask, cmap="coolwarm", vmax=1, center=0,xticklabels=corr.columns,
                yticklabels=corr.columns,square=True)
    "Only uncomment if the plot should be safed"
    os.chdir('/Users/matthiasboeker/Documents/Uni/ITIV/TS_Classification_DTW/Multivariate_Data')
    #f.savefig('Corr_Left_2_Absolute.pdf',bbox_inches = "tight")
    
    
    g, dendrogram = plt.subplots(figsize=(12, 10))
    dendrogram = sch.dendrogram(sch.linkage(corr, method='ward'), labels=corr.columns)
    plt.xlabel('Signals')
    plt.ylabel('Euc. Distance of R2')
    os.chdir('/Users/matthiasboeker/Documents/Uni/ITIV/TS_Classification_DTW/Multivariate_Data/Full_Corr_Analysis')
    
    if i < 40:
        
        g.savefig('Dendo_Left_'+str(i)+'.pdf',bbox_inches = "tight")
    else:
        g.savefig('Dendo_Right_'+str(i-40)+'.pdf',bbox_inches = "tight")

