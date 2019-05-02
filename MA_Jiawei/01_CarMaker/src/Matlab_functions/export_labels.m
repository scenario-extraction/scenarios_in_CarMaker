function [outputArg1] = export_labels(path2csvfile)

%% Export labels over time
%write header to file
load('true_label.mat');

% fid = fopen(path2csvfile,'w'); 
% fid = fopen('E:\CM_Projects\CM7_Highway\SimInput\Ground_Truth_label_Highwat_01_TrafficRight_EgoLeft_100.csv','w');
fid = fopen('E:\CM_Projects\CM7_Highway\SimInput\Ground_Truth_label_Highway_32.csv','w');
% fid = fopen('E:\CM_Projects\CM7_Highway\SimInput\Ground_Truth_label_Highway_01_new_OT_1.csv','w');
% fid = fopen('E:\CM_Projects_All\CM7_Highway\SimInput\ground_truth_label.csv','w'); 
fprintf(fid,'%s\n','#Time label_ego_long label_ego_lat label_TObj_long label_TObj_lat label_ObjId'  );
fclose(fid);
%write data to end of file
export_array = [Time', label.ego.long' label.ego.lat' label.TObj.long' label.TObj.lat' label.ObjId'];
% dlmwrite('E:\CM_Projects_All\CM7_Highway\SimInput\ground_truth_label.csv',export_array,'-append');
dlmwrite('E:\CM_Projects\CM7_Highway\SimInput\Ground_Truth_label_Highway_32.csv',export_array,'-append');
% dlmwrite('E:\CM_Projects\CM7_Highway\SimInput\Ground_Truth_label_Highway_01_new_OT_1.csv',export_array,'-append');
%dlmwrite('E:\CM_Projects\CM7_Highway\SimInput\Ground_Truth_label_Highwat_01_TrafficRight_EgoLeft_100.csv',export_array,'-append');

 end