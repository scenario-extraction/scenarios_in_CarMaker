function [outputArg1] = datapreparation(path2ergfile)

% ---This is for preparing the recorded data for following analysis steps


%% load CM data
% data=cmread('C:\CM_Projects\CM7_Highway\SimOutput\Ground_truth_data.erg');
data=cmread(path2ergfile);


%% Time Channel Selection
Time = data.Time.data;

%% Ground Truth Ego Maneuvers
Ego.Car.ax = data.Car_ax.data;
Ego.Lane.Act_LaneId = data.Car_Road_Lane_Act_LaneId.data;
Ego.Lane.Act_width = data.Car_Road_Lane_Act_Width.data;
Ego.Lane.Left_width = data.Car_Road_Lane_OnLeft_Width.data;
Ego.Lane.Right_width = data.Car_Road_Lane_OnRight_Width.data;
Ego.Lane.DevDist = data.Car_Road_Path_DevDist.data;
%% Ground Truth Ego States
Ego.sRoad = data.Car_Road_sRoad.data;


%--------------------------------------------------------------------------
%% Ground Truth Dynamic Objects Maneuvers & States
n = 0;
for k = 0:9
    %Check if data available, then copy data in structure array
    if isfield(data, ['Traffic_T0' num2str(k) '_sRoad']) == 1;
        n = n+1;
        TObj(n).name = eval(['data.Traffic_T0' num2str(k) '_sRoad.name']);
        TObj(n).sRoad = eval(['data.Traffic_T0' num2str(k) '_sRoad.data']);
        TObj(n).Car.ax = eval(['data.Traffic_T0' num2str(k) '_a_1_x.data']);
        TObj(n).Lane.Act_LaneId = eval(['data.Traffic_T0' num2str(k) '_Lane_Act_LaneId.data']);
        TObj(n).Lane.t2Ref = eval(['data.Traffic_T0' num2str(k) '_t2Ref.data']);
        TObj(n).DetectLevel = eval(['data.Traffic_T0' num2str(k) '_DetectLevel.data']);
        totalObjects = n;
    end 
end

for k = 10:256
    %Check if data available, then copy data in structure array
    if isfield(data, ['Traffic_T' num2str(k) '_sRoad']) == 1;
        n = n+1;
        TObj(n).name = eval(['data.Traffic_T' num2str(k) '_sRoad.name']);        
        TObj(n).sRoad = eval(['data.Traffic_T' num2str(k) '_sRoad.data']);
        TObj(n).Car.ax = eval(['data.Traffic_T' num2str(k) '_a_1_x.data']);
        TObj(n).Lane.Act_LaneId = eval(['data.Traffic_T' num2str(k) '_Lane_Act_LaneId.data']);
        TObj(n).Lane.t2Ref = eval(['data.Traffic_T' num2str(k) '_t2Ref.data']);
        TObj(n).DetectLevel = eval(['data.Traffic_T' num2str(k) '_DetectLevel.data']);
        totalObjects = n;        
    end 
end


%save selected Data in mat file
clear ('data', 'path2ergfile');
save('prepdata.mat');

end
