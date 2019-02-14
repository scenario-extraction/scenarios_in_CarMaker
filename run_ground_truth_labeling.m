%% Add environment
run cmenv.m;
addpath(genpath('Matlab_functions'));

%% Execute data preparataion with defined erg file and create mat data
datapreparation('C:\CM_Projects\CM7_Highway\SimOutput\Ground_truth_data.erg');
%% Run post processing Alogrithm and label the data based on ground truth information
labeling('prepdata.mat');

export_labels('..\SimInput\ground_truth_label.csv');

