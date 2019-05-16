% main script to run : edited to process erg files from Testrun series with variations!
% make the necessary changes, e.g path, directory ...
% the simulations' output erg files are now saved in the default directory

%% preprocess
clc
close all
% clear all

%% add necessaray dir to search path
dir_TR = 'F:\Highway_scenarios_overwrite\Data\TestRun';
maindir = 'F:\Highway_scenarios_overwrite\SimOutput';

date_str= datestr(now,'yyyymmdd');

dir2ergfile =strcat('F:\Highway_scenarios_overwrite\SimOutput\itiv-3039\',date_str); %

dire2cmenv = 'F:\Highway_scenarios_overwrite\src_cm4sl';
addpath(dir2ergfile,maindir, dire2cmenv,dir_TR);

%% set Matlab env to use Matlab utilities for CM. Path directory must contain cmenv()
cmenv();
% preallocate
TestRun=[];

%% run the simulations and process the erg files
% list erg files from first simulation
cd (dir2ergfile);
TestRun.first_sim = dir('*.erg');
disp(length(TestRun.first_sim));

% define indicator for resimulation
global flag_resim;

ind_file =0; % loop index

for k=1:length(TestRun.first_sim)
    if ~isempty(TestRun.first_sim)
        
        flag_resim =0;
        
        %% set the path for the current Testrun
        path2ergfile = fullfile(dir2ergfile, TestRun.first_sim(k).name);
        
        %% create struct containing needed data from CM
        prepdata_filename = datapreparation(path2ergfile);
        
        %% Labeling
        label_data = labeling(prepdata_filename);
        
        %% Create the tensor describing the scenario based on the data from CM and the prediction models
        
        [Tensor_CM, Tensor_model] = create_tensor(prepdata_filename,label_data);
        
        %% save output Tensors in the corresponding Testrun struct
        TestRun.first_sim(k).Tensor_CM = Tensor_CM;
        TestRun.first_sim(k).Tensor_model = Tensor_model;
        %% overwrite the infofile for resimulation
%         file_to_overwrite = 'ChangingLanes_ov';
%         file_to_overwrite = 'Highway_with_data_export_ov';
        file_to_overwrite= 'Ground_Truth_label_Highwat_01_ov';
        overwrite_infofile(Tensor_CM,file_to_overwrite);
        %% save
        %% delete
        delete(prepdata_filename,label_data);
        
        %% run resimulation via channel communication
        run_sim_via_ch_com(file_to_overwrite);
        
        %% define the pattern of the erg file from overwritten infofiles get erg files from the resimulation
        Files_ov = dir(fullfile(dir2ergfile, '*_ov_*'));
        temp_anz = numel(Files_ov);
        for i=1:numel(Files_ov)
            
            [~,~,ext] = fileparts(Files_ov(i).name);
            if strcmp(ext,'.erg')
                ind_file= ind_file+1;
                TestRun.resim(ind_file).data=Files_ov(i);
            end
            
        end
        %reallocate
        Files_ov =[];
        
        %% create tensors for resimulation
        flag_resim =1;
        temp_path = fullfile(TestRun.resim(ind_file).data.folder,TestRun.resim(ind_file).data.name);
        prepdata_filename_resim = datapreparation(temp_path);
        
        label_data_resim = labeling(prepdata_filename_resim);
        
        [Tensor_resim_CM, Tensor_resim_model] = create_tensor_resim(prepdata_filename_resim,label_data_resim,k);
        
        % store output tensors from resimulation
        TestRun.resim(ind_file).data.Tensor_CM = Tensor_resim_CM;
        TestRun.resim(ind_file).data.Tensor_model = Tensor_resim_model;
        
        % delete
        delete(prepdata_filename_resim,label_data_resim);
        delete('Ego_plot.fig');
        delete('Ego_plot_final.fig');

        %delete the info & erg files for current resimulation and prepare for next resimulation
        delete(fullfile(dir2ergfile, '*_ov_*'))
        pause(1);
        
    else
        disp('No erg files were found');
    end
end


