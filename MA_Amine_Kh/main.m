% main script to run : edited to process erg files from Testrun series with variations!
% make the necessary changes, e.g path, directory ...
% the simulations output files are now saved in the default directory

%% preprocess
clc
close all
clear all

%% add necessaray dir to search path
dir_TR = 'F:\Highway_scenarios_overwrite\Data\TestRun';
maindir = 'F:\Highway_scenarios_overwrite\SimOutput';

date_str= datestr(now,'yyyymmdd');

dir2ergfile =strcat('F:\Highway_scenarios_overwrite\SimOutput\itiv-3039\',date_str); % to be adapted to today's date!!

dire2cmenv = 'F:\Highway_scenarios_overwrite\src_cm4sl';
addpath(dir2ergfile,maindir, dire2cmenv,dir_TR);

%% set Matlab env to use Matlab utilities for CM. Path directory must contain cmenv()
cmenv();

%% run the simulations and process the erg files
% list erg files from first simulation
cd (dir2ergfile);
TestRun.GT = dir('*.erg');


flag_sim = 0;
ind_file =0;
if ~isempty(TestRun.GT)

    for k=1:length(TestRun.GT)
        %% set the path for the current Testrun
        path2ergfile = fullfile(dir2ergfile, TestRun.GT(k).name);
        
        %% create struct containing needed data from CM
        prepdata_filename = datapreparation(path2ergfile);
        
        %% Labeling
        label_data = labeling(prepdata_filename);
        
        %% Create the tensor describing the scenario based on the data from CM and the prediction models
        
        [Tensor_CM, Tensor_model] = create_tensor(prepdata_filename,label_data, flag_sim);
        
        %% save output Tensors in the corresponding Testrun struct
        TestRun.GT(k).Tensor_CM = Tensor_CM;
        TestRun.GT(k).Tensor_model = Tensor_model;
        %% overwrite the infofile for resimulation
        % file_to_overwrite = 'Highway_with_data_export_ov';
        file_to_overwrite= 'Ground_Truth_label_Highwat_01_ov';
        overwrite_infofile(Tensor_CM,file_to_overwrite);
        %% save
        
        %% delete
        delete(prepdata_filename,label_data);
        
        %% run resimulation via channel communication
        run_sim_via_ch_com(file_to_overwrite);
       
        %% define the pattern of the erg file from overwritten infofiles get erg files from the resimulation
        Files_ov = dir(fullfile(dir2ergfile, '*_ov_*'));
        for i=1:numel(Files_ov)
            
            [~,~,ext] = fileparts(Files_ov(i).name);
            if strcmp(ext,'.erg')
                ind_file= ind_file+1;
               TestRun.resim(ind_file+1).data = Files_ov(i);
            end
             
        end
        
        %delete current resimulation info & erg files and prepare for next resimulation
        delete(fullfile(dir2ergfile, '*_ov_*'))
        
        %% to edit and workaround !
%         Files_ov = [];
%         TestRun.resim(ind_file+1) = Files_ov;
%          prepdata_filename = datapreparation(dir2ergfile);
%         
%         label_data = labeling(prepdata_filename);
%         
%         Tensor_resim = create_tensor(prepdata_filename,label_data);
        
    end
else
    disp('No erg files was found');
end



