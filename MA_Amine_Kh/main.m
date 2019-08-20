%%
% main script to run : edited to process erg files from Testrun series with variations!
% make the necessary changes, e.g path, directory ...
% the simulations' output erg files are now saved in the default directory
% the main outputs of the main script are: a struct variable containing the
% tensors matices of ego and TObjs for all Testruns
%% preprocess
clc
close all
clear all

%% add necessaray directories to search path
dir_TR = 'F:\Highway_scenarios_overwrite\Data\TestRun'; % dir containing Testrun Infofiles

maindir = 'F:\Highway_scenarios_overwrite\SimOutput'; % dir containing the erg files

date_str= datestr(now,'yyyymmdd');
dir2ergfile =strcat('F:\Highway_scenarios_overwrite\SimOutput\itiv-3041\',date_str);% dir containing the erg files

dire2cmenv = 'F:\Highway_scenarios_overwrite\src_cm4sl'; % dir containing the scripts files and cmenv()
addpath(dir2ergfile,maindir, dire2cmenv,dir_TR);

%% set Matlab env to use Matlab utilities for CM. Path directory must contain cmenv()
cmenv();


%% run the simulations and process the erg files

% preallocate TestRun struct
TestRun=[];

% list erg files from first simulation
cd (dir2ergfile);
TestRun.first_sim = dir('*.erg');
disp(strcat('number of erg files: ',32,num2str(length(TestRun.first_sim))));

% define flag variable for resimulation:
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
        [Tensor_CM, Tensor_model,numOfTObj] = create_tensor(prepdata_filename,label_data);
        
        %% save output Tensors in the corresponding Testrun struct
        TestRun.first_sim(k).Tensor_CM = Tensor_CM;
        TestRun.first_sim(k).Tensor_model = Tensor_model;
        %% overwrite the infofile for resimulation: create a copy of the testRun Infofile manually. The copy will be overwritten in ths step
        file_to_overwrite = 'Highway_with_data_export_ov';
        %         file_to_overwrite = 'Ground_Truth_label_Highwat_01_ov';
        overwrite_infofile(Tensor_CM,file_to_overwrite);
        
        %% delete
        delete(prepdata_filename,label_data);
        
        %% run resimulation via DDE protocol
        run_sim_via_DDE(file_to_overwrite);
        
        %% define the pattern of the erg file from overwritten infofiles and get erg files from the resimulation
        Files_ov = dir(fullfile(dir2ergfile, '*_ov_*'));
        for i=1:numel(Files_ov)
            [~,~,ext] = fileparts(Files_ov(i).name);
            if strcmp(ext,'.erg')
                ind_file= ind_file+1;
                TestRun.resim(ind_file).data=Files_ov(i);
            end
        end
        
        % reallocate for the next testrun
        Files_ov =[];
        
        %% create tensors for resimulation
        flag_resim =1;
        temp_path = fullfile(TestRun.resim(ind_file).data.folder,TestRun.resim(ind_file).data.name);
        prepdata_filename_resim = datapreparation(temp_path);
        
        label_data_resim = labeling(prepdata_filename_resim);
        
        [Tensor_resim_CM, Tensor_resim_model] = create_tensor_resim(prepdata_filename_resim,label_data_resim,k,numOfTObj);
        
        % delete
        delete(prepdata_filename_resim,label_data_resim);
        delete('Ego_plot.fig');
        delete('Ego_plot_final.fig');
        
        % save output tensors from resimulation
        TestRun.resim(ind_file).data.Tensor_CM = Tensor_resim_CM;
        TestRun.resim(ind_file).data.Tensor_model = Tensor_resim_model;
        
        
        % delete the info & erg files for current resimulation and prepare for next resimulation
        delete(fullfile(dir2ergfile, '*_ov_*'))
        
    else
        disp('No erg files were found');
        
    end
end

%% Tensors'compare by directy calculating relative deviation between first sim- Tensor and Resim- Tensor
% clc
% TestRun.tensor_dev = struct;
% for index_TR=1:numel(TestRun.first_sim)
%
%     % Ego
%     TestRun.tensor_dev_metho1(index_TR).Ego = calc_dev_tensor(TestRun.first_sim(index_TR).Tensor_CM.Ego  ,TestRun.resim(index_TR).data.Tensor_CM.Ego);
%
%     % TObjs
%     num_obj_sim = numel(TestRun.first_sim(index_TR).Tensor_CM.TObj);
%     num_obj_resim = numel(TestRun.resim(index_TR).data.Tensor_CM.TObj);
%     num_obj_dev = min(num_obj_sim,num_obj_resim);
%
%     for i=1:num_obj_dev
%         TestRun.tensor_dev_metho1(index_TR).TObj(i).data = calc_dev_tensor(TestRun.first_sim(index_TR).Tensor_CM.TObj(i).data,TestRun.resim(index_TR).data.Tensor_CM.TObj(i).data);
%     end
% end
%% event-based statistical evaluation between the tensors: calculate the errors and store them in a struct variable for each corresponding testrun
for index_TR=1:numel(TestRun.first_sim)
    % Ego
    TestRun.tensor_dev(index_TR).Ego = 100*event_dev_func(TestRun.first_sim(index_TR).Tensor_CM.Ego  ,TestRun.resim(index_TR).data.Tensor_CM.Ego);
    
    % TObjs
    num_obj_sim = numel(TestRun.first_sim(index_TR).Tensor_CM.TObj);
    num_obj_resim = numel(TestRun.resim(index_TR).data.Tensor_CM.TObj);
    num_obj_dev = min(num_obj_sim,num_obj_resim);
    
    for i=1:num_obj_dev % if necessary replace with num_obj_dev
        TestRun.tensor_dev(index_TR).TObj(i).data =100*(event_dev_func(TestRun.first_sim(index_TR).Tensor_CM.TObj(i).data,TestRun.resim(index_TR).data.Tensor_CM.TObj(i).data));
    end
    
    
end

%% save the Struct containing the tensors from all the run Simulations
% close all
%  save('TestRun_update_41_45','TestRun');
