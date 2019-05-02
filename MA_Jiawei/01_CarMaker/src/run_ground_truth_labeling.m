%% Add environment
clc;
clear;
run cmenv.m;
addpath(genpath('Matlab_functions'));

%% Execute data preparataion with defined erg file and create mat data
run datapreparation.m
%datapreparation('E:\CM_Projects_All\CM7_Highway\SimOutput\LAPTOP-HNJRQ4FK\20190319\Ground_Truth_label_Highwat_01.dat_192037.erg');
% datapreparation('C:\CM_Projects\CM7_Highway\SimOutput\Ground_Truth_label_Highway_01.erg');

%% Run pretrained Classification Alogrithm and label the data
labeling('prepdata.mat');
run export_labels.m;
% export_labels('E:\CM_Projects_All\CM7_Highway\SimInput\ground_truth_label.csv');
%export_labels('E:\CM_Projects\CM7_Highway\SimInput\Ground_Truth_label_Highway_01.csv');
disp('Ground Truth labels export done');