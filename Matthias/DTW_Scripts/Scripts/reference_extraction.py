#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 16 16:01:36 2020

@author: matthiasboeker
Extract the Reference Signals
he reference signal was visually extracted, the longest lane change 
for each scenario was chosen as reference
"""

#Extracting the signals for the four scenarios 
data = data_list[4]
signal_df_right_right = data

data = data_list[24]
signal_df_right_left = data


data = data_list[44]
signal_df_left_right = data

data = data_list[64]
signal_df_left_left = data


#Extracting the reference of the lanechange for each scenario 
ref_signals_right_right = signal_df_right_right.loc[(signal_df_right_right['Time'] > 3.5) & (signal_df_right_right['Time'] <= 17.5)]
ref_signals_right_left = signal_df_right_left.loc[(signal_df_right_left['Time'] > 3.5) & (signal_df_right_left['Time'] <= 17.5)]

ref_signals_left_right = signal_df_left_right.loc[(signal_df_left_right['Time'] > 3.5) & (signal_df_left_right['Time'] <= 17.5)]
ref_signal_df_left_left  = signal_df_left_left.loc[(signal_df_left_left['Time'] > 3.5) & (signal_df_left_left['Time'] <= 17.5)]
