%%  Label_ego_long with delta vx (1 = acceleration, 0 = static cruising, -1= decceleration)
%  S is the orignal signal
%  data is the output from Ego Sensors

clc;
tic;
%% load CM data

 data=cmread('C:\CM_Projects\CM7_Highway\SimOutput\Ground_Truth_label_Highway_01.erg');
% data=cmread(path2ergfile);


%% Channel Selection
Time = data.Time.data;
%% Ground Truth Ego Maneuvers

Ego.Car.ax = data.Car_ax.data;
Ego.Car.vx = data.Car_vx.data;
% Ego.Car.Yaw = data.Car_Yaw.data;
Ego.Car.ay= data.Car_ay.data;
Ego.Car.vy = data.Car_vy.data;
% Ego.Car.SteerAngle = data.VC_Steer_Ang.data;
% Ego.Car.DisToLeft= data.LatCtrl_DistToLeft.data;

% Ego.Lane.Act_LaneId = data.Car_Road_Lane_Act_LaneId.data;
% Ego.Lane.Act_width = data.Car_Road_Lane_Act_Width.data;
% Ego.Lane.Left_width = data.Car_Road_Lane_OnLeft_Width.data;
% Ego.Lane.Right_width = data.Car_Road_Lane_OnRight_Width.data;
% Ego.Lane.DevDist = data.Car_Road_Path_DevDist.data;

%% Labels Ego Longitudinal

label.ego.long(1:length(Time))=0;

for n=2:length(Time)
     if Ego.Car.vx(n) - Ego.Car.vx(n - 1) > 0.01        % "acceleration"
         label.ego.long(n) = 1;
     elseif Ego.Car.vx(n) - Ego.Car.vx(n - 1) < - 0.01   % "decceleration"
         label.ego.long(n) = -1;
     else 
         label.ego.long(n) = 0;                          % "static cruising"
     end
end

%% Results output

results = [Time', Ego.Car.vx' , label.ego.long'];
     
results_cell = num2cell(results);  

title = {'Time', 'Ego car vx', 'label ego long' };

output = [title ; results_cell];  

Output_label = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\DTW_results_highway_01_0.25.xlsx',output ,'Label_ego_long');

toc;
