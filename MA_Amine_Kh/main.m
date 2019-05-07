% main script to run
clc
close all
clear all
%% path to .erg file
path2ergfile='F:\Highway_scenarios_overwrite\SimOutput\Ground_truth_data.erg';

%% set Matlab env to use Matlab utilities for CM. Path directory must contain cmenv()
cmenv(); 

%% create struct containing needed data from CM
prepdata_filename = datapreparation(path2ergfile);

%% Labeling
label_data = labeling(prepdata_filename);

%% Create the tensor describing the scenario based on the data from CM and the prediction models
 Tensor = create_tensor(prepdata_filename,label_data); 

 %% overwrite the infofile for resimulation
file_to_overwrite = 'Highway_with_data_export_ov';

overwrite_infofile(Tensor,file_to_overwrite);

%% delete
delete(prepdata_filename,label_data);

%% save Tensor from GT und Prediction data

%% plot maneuver GT data 

%% reconstruct scenario based on the built tensor


%% tensor from the reconstructed scenario 


%% compare tensors


