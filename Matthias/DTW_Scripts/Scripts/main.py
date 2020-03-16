#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 13 16:38:57 2020

@author: matthiasboeker
main.py

In case some packages cannot be found uncomment the first lines and execute them.
Execute each line separately to allow for possible debugging
Adjust your the homepath to your personal computer, to the point where the repository lays
Hence, do not change the order of files and scripts in the repository

"""
#importlib.import_module('support_functions')
#importlib.import_module('ApEN')
#importlib.import_module('Multi_sliding_Window')
import importlib
import pandas as pd
import numpy as np
import os 
import seaborn as sns
import scipy.cluster.hierarchy as sch
import csv
from scipy.spatial.distance import euclidean
import fastdtw
import support_functions
import ApEN
import Multi_sliding_Window


#1. Load in Data
#Define your home path leading to the DTW_Scripts Repository
home_path = '/Users/matthiasboeker/Desktop/'

#Execute Read_In_Multi_Data.py
runfile(home_path+'DTW_Scripts/Scripts/Read_In_Multi_Data.py', wdir=home_path+'DTW_Scripts/Scripts')


#2.Calculate the Score and pre_select the signals 
runfile(home_path+'DTW_Scripts/Scripts/A-Score.py', wdir=home_path+'DTW_Scripts/Scripts')

#3.Calculate the clusters 
runfile(home_path+'DTW_Scripts/Scripts/Correlation_matrices.py', wdir=home_path+'DTW_Scripts/Scripts')

#4. Allocate clusters and scored signals 
runfile(home_path+'DTW_Scripts/Scripts/Preprocessing_Allocation.py', wdir=home_path+'DTW_Scripts/Scripts')

#5. Extract the reference signals for DTW
runfile(home_path+'DTW_Scripts/Scripts/reference_extraction.py', wdir=home_path+'DTW_Scripts/Scripts')

#6. Run the multivariate DTW for the four scenarios: 
runfile(home_path+'DTW_Scripts/Scripts/Test_Run.py', wdir=home_path+'DTW_Scripts/Scripts')

#7. Labelling 
runfile(home_path+'DTW_Scripts/Scripts/Labeling.py', wdir=home_path+'DTW_Scripts/Scripts')

#8. Evaluation
#Please look into the evaluation script, since it is very individual! 
runfile(home_path+'DTW_Scripts/Scripts/Advanced_evaluation.py', wdir=home_path+'DTW_Scripts/Scripts')
