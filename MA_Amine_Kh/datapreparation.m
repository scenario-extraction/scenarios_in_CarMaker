function  prepdata_filename=datapreparation(path2ergfile)
% add clutch signals
% ---This is for preparing the recorded data for following analysis steps

%% load CM data
data=cmread(path2ergfile);

%% Ground Truth Ego States
Ego.sRoad = data.Car_Road_sRoad.data;

%% Time Channel Selection
Time = data.Time.data;

%% Ground Truth Ego Maneuvers
Ego.Car.ax = data.Car_ax.data;
Ego.Car.vx = diff(Ego.sRoad)./diff(Time);
Ego.Car.vx = [Ego.Car.vx,Ego.Car.vx(end)]; % build vx from differentiating sRoad
Ego.Lane.Act_LaneId = data.Car_Road_Lane_Act_LaneId.data;
% Ego.Lane.Act_LaneId = data.Car_Road_Lane_Act_isRight.data; % just in case of changing lane template
Ego.Lane.Act_width = data.Car_Road_Lane_Act_Width.data;
Ego.Lane.Left_width = data.Car_Road_Lane_OnLeft_Width.data;
Ego.Lane.Right_width = data.Car_Road_Lane_OnRight_Width.data;
Ego.Lane.DevDist = data.Car_Road_Path_DevDist.data;
Ego.Lane.vy = data.Car_Fr1_vy.data;

% Engine & Gearbox Quantities
Ego.Clutch = data.DM_Clutch.data ;
Ego.GearNo = data.DM_GearNo_Trgt.data ;
Ego.Engine_Load = data.PT_ECU_Load.data; %
%--------------------------------------------------------------------------
%% Ground Truth Dynamic Objects Maneuvers & States
n = 0;
num_TObj=strings; % array cont. designation number of all TObj participating in the scenario

for k = 0:9
    %Check if data available, then copy data in structure array
    if isfield(data, ['Traffic_T0' num2str(k) '_sRoad']) == 1
        n = n+1;
        num_TObj(n)=strcat('0',num2str(k));
        TObj(n).name = eval(['data.Traffic_T0' num2str(k) '_sRoad.name']);
        TObj(n).sRoad = eval(['data.Traffic_T0' num2str(k) '_sRoad.data']);
        TObj(n).Car.ax = eval(['data.Traffic_T0' num2str(k) '_a_1_x.data']);
        TObj(n).Car.vx = diff(TObj(n).sRoad)./diff(Time);
        TObj(n).Car.vx =  [TObj(n).Car.vx,  TObj(n).Car.vx(end)]; % add vx for traffic  obj
        TObj(n).Lane.Act_LaneId = eval(['data.Traffic_T0' num2str(k) '_Lane_Act_LaneId.data']);
        TObj(n).Lane.t2Ref = eval(['data.Traffic_T0' num2str(k) '_t2Ref.data']);
        TObj(n).Lane.tRoad = eval(['data.Traffic_T0' num2str(k) '_tRoad.data']);
        TObj(n).Lane.vy = eval(['data.Traffic_T0' num2str(k) '_LatVel.data']);
        TObj(n).DetectLevel = eval(['data.Traffic_T0' num2str(k) '_DetectLevel.data']);
        totalObjects = n;
        %% process velocity data before saving remove step from data
        if TObj(n).Car.vx(1) ==0 &&  TObj(n).Car.vx(2)>1  ||( TObj(n).Car.ax(1) ==0 && TObj(n).Car.ax(2)~=0)
            
                
                TObj(n).Car.vx(1) =  TObj(n).Car.vx(2)-TObj(n).Car.ax(2)*0.02; % 0.02 s being the sampling time
                
            
        end
    end
end

for k = 10:256
    %Check if data available, then copy data in structure array
    if isfield(data, ['Traffic_T' num2str(k) '_sRoad']) == 1
        n = n+1;
        num_TObj(n)=num2str(k);
        
        TObj(n).name = eval(['data.Traffic_T' num2str(k) '_sRoad.name']);
        TObj(n).sRoad = eval(['data.Traffic_T' num2str(k) '_sRoad.data']);
        TObj(n).Car.ax = eval(['data.Traffic_T' num2str(k) '_a_1_x.data']);
        TObj(n).Car.vx = diff(TObj(n).sRoad)./diff(Time);
        TObj(n).Car.vx =  [TObj(n).Car.vx,  TObj(n).Car.vx(end)]; % add vx for traffic  obj
        
        TObj(n).Lane.Act_LaneId = eval(['data.Traffic_T' num2str(k) '_Lane_Act_LaneId.data']);
        TObj(n).Lane.t2Ref = eval(['data.Traffic_T' num2str(k) '_t2Ref.data']);
        TObj(n).Lane.tRoad = eval(['data.Traffic_T' num2str(k) '_tRoad.data']);
        TObj(n).Lane.vy = eval(['data.Traffic_T' num2str(k) '_LatVel.data']); % add vy for Traffic obj
        TObj(n).DetectLevel = eval(['data.Traffic_T' num2str(k) '_DetectLevel.data']);
        totalObjects = n;
        %% process velocity data before saving remove step from data
        if TObj(n).Car.vx(1) ==0 &&  TObj(n).Car.vx(2)>1
            if TObj(n).Car.ax(1)<1 && TObj(n).Car.ax(2)~=0
                
                TObj(n).Car.vx(1) =  TObj(n).Car.vx(2)-TObj(n).Car.ax(2)*0.02; % 0.02 s being the sampling time
                
            end
        end
        %%
    end
end

%% process velocity data before saving



%save selected Data in mat file
clear ('data', 'path2ergfile');
prepdata_filename='prepdata.mat';
save(prepdata_filename);

end
