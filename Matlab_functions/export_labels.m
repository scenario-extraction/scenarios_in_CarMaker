function [outputArg1] = export_labels(path2csvfile)

%% Export labels over time
%write header to file
load('true_label.mat');

fid = fopen(path2csvfile,'w'); 
% fid = fopen('..\SimInput\ground_truth_label.csv','w'); 
% TODO
fprintf(fid,'%s\n','#Time ego_long ego_lat TObj1_long TObj1_lat st_TObj1_long st_TObj1_lat TObj2_long TObj2_lat st_TObj2_long st_TObj2_lat TObj3_long TObj3_lat st_TObj3_long st_TObj3_lat TObj4_long TObj4_lat st_TObj4_long st_TObj4_lat TObj5_long TObj5_lat st_TObj5_long st_TObj5_lat '  );
fclose(fid);
%write data to end of file
%export_array = [Time', label.ego.long' label.ego.lat' label.TObj.long' label.TObj.lat' label.ObjId' label.state.TObj.long' label.state.TObj.lat'];

for i=1:totalObjects
    TObj_data(:,4*i-3) = label.TObj(i).long';
    TObj_data(:,4*i-2) = label.TObj(i).lat';
    TObj_data(:,4*i-1) = label.state.TObj(i).long';
    TObj_data(:,4*i-0) = label.state.TObj(i).lat';
end

export_array = [Time' label.ego.long' label.ego.lat' TObj_data];

dlmwrite('..\SimInput\ground_truth_label.csv',export_array,'-append');

disp('Ground truth labels export done');

end