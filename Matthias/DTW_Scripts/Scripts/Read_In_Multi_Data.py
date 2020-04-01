#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 27 17:48:23 2020

@author: matthiasboeker
Read in the data from the repository 
Please adjust your homepath in the main.py to read in the data from the repository
 """
import pandas as pd
import numpy as np
import os
from support_functions import support_function


path = home_path+'DTW_Scripts/Data'
support = support_function()
data_list = list()
support.read_in_data(path,data_list)
os.chdir(home_path+'DTW_Scripts/Scripts')

