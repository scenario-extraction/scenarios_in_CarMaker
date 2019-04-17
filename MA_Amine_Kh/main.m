clc
close all
clear all
%% prepare data 
path2ergfile='F:\Highway_scenarios_overwrite\SimOutput\Ground_truth_data.erg';
   
cmenv();% set Matlab env to use Matlab utilities for CM

prepdata_filename = datapreparation(path2ergfile);
%% Labeling
label_data = labeling(prepdata_filename);

%% Create the Tensor describing the scenario 
 Tensor = create_tensor(prepdata_filename,label_data); 

 %% overwrite the infofile for Resimulation
 overwrite_infofile(Tensor);
 %% delete
 delete(prepdata_filename,label_data);

%% reconstruct scenario based on the built tensor


%% tensor from the reconstructed scenario 


%% compare tensors


