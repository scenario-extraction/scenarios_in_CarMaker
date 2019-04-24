clc
% close all
clear all
%% prepare data 
path2ergfile='F:\Highway_scenarios_overwrite\SimOutput\Ground_truth_data.erg';

cmenv(); % set Matlab env to use Matlab utilities for CM
prepdata_filename = datapreparation(path2ergfile);
%% Labeling
label_data = labeling(prepdata_filename);

%% Create the Tensor describing the scenario 
 Tensor = create_tensor(prepdata_filename,label_data); 

 %% overwrite the infofile for Resimulation
%  file_to_overwrite= 'ChangingLanes_ov'; % change the name of the file to overwrite
file_to_overwrite = 'Highway_with_data_export_ov';

overwrite_infofile(Tensor,file_to_overwrite);

 %% delete
% delete(prepdata_filename,label_data);

%% save Tensor from GT und Prediction data

%% reconstruct scenario based on the built tensor


%% tensor from the reconstructed scenario 


%% compare tensors


