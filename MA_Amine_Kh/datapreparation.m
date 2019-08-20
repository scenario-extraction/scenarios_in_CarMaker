function  prepdata_filename=datapreparation(path2ergfile)
% ---This is for preparing the recorded data for following analysis steps

global flag_resim;

%% load CM data
data=cmread(path2ergfile);

%% Ground Truth Ego States
Ego.sRoad = data.Car_Road_sRoad.data;

%% Time Channel Selection
Time = data.Time.data;

%% Ground Truth Ego Maneuvers
Ego.Car.ax = data.Car_ax.data;
% Ego.Car.vx = diff(Ego.sRoad)./diff(Time);
% Ego.Car.vx = [Ego.Car.vx,Ego.Car.vx(end)]; % get vx from differentiating sRoad
Ego.Car.vx= data.Car_v.data;

Ego.Lane.Act_LaneId = data.Car_Road_Lane_Act_LaneId.data;
% Ego.Lane.Act_LaneId = data.Car_Road_Lane_Act_isRight.data; % just in case of changing lane template
Ego.Lane.Act_width = data.Car_Road_Lane_Act_Width.data;
Ego.Lane.Left_width = data.Car_Road_Lane_OnLeft_Width.data;
Ego.Lane.Right_width = data.Car_Road_Lane_OnRight_Width.data;
Ego.Lane.DevDist = data.Car_Road_Path_DevDist.data;
 
%--------------------------------------------------------------------------
%% Ground Truth Dynamic Objects Maneuvers & States
TObj=[];
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
%         TObj(n).Car.vx = diff(TObj(n).sRoad)./diff(Time);
%         TObj(n).Car.vx =  [TObj(n).Car.vx,  TObj(n).Car.vx(end)]; % add vx for traffic  obj
        
        TObj(n).Car.vx=eval(['data.Traffic_T0' num2str(k) '_LongVel.data']);
        
        TObj(n).Lane.Act_LaneId = eval(['data.Traffic_T0' num2str(k) '_Lane_Act_LaneId.data']);
        TObj(n).Lane.tRoad = eval(['data.Traffic_T0' num2str(k) '_tRoad.data']);
        TObj(n).Lane.t2Ref = eval(['data.Traffic_T0' num2str(k) '_t2Ref.data']);
        % process t2Ref
        TObj(n).Lane.t2Ref = (TObj(n).Lane.t2Ref-TObj(n).Lane.t2Ref(1))+TObj(n).Lane.tRoad(1); % add initial tRoad offset
        
%         TObj(n).Lane.vy = eval(['data.Traffic_T0' num2str(k) '_LatVel.data']);
        TObj(n).DetectLevel = eval(['data.Traffic_T0' num2str(k) '_DetectLevel.data']);
        struct_sensors = strcat('data.Sensor_Object_OB01_Obj_T0', num2str(k), '_NearPnt_ds_x');
        if ~isempty(eval(struct_sensors))
            TObj(n).Sensor.dx = eval(['data.Sensor_Object_OB01_Obj_T0' num2str(k) '_NearPnt_ds_x.data']);
            TObj(n).Sensor.dy = eval(['data.Sensor_Object_OB01_Obj_T0' num2str(k) '_NearPnt_ds_y.data']);
        end
        totalObjects = n;

        %% process velocity data before saving remove step from data
        if TObj(n).Car.vx(1) ==0 &&  TObj(n).Car.vx(2)>1  ||( TObj(n).Car.ax(1) ==0 && TObj(n).Car.ax(2)~=0)
            
            TObj(n).Car.vx(1) =  TObj(n).Car.vx(2)-TObj(n).Car.ax(2)*0.02; % 0.02 s being the sampling time
            
        end
        % index of the last non zeros element in Car.vx for TObj
        index_last_nonzero = find(TObj(n).Car.vx,1,'last');
        if abs(TObj(n).Car.vx(index_last_nonzero)- TObj(n).Car.vx(index_last_nonzero-1))>5
            TObj(n).Car.vx(index_last_nonzero) = TObj(n).Car.vx(index_last_nonzero-1);
        end
        % process zeros speed data at the end
        index_last_zero = find(TObj(n).Car.vx==0,1,'last');
        if ~isempty(index_last_zero)
            TObj(n).Car.vx(index_last_nonzero+1:index_last_zero) = TObj(n).Car.vx(index_last_nonzero);
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
%         TObj(n).Car.vx = diff(TObj(n).sRoad)./diff(Time);
%         TObj(n).Car.vx =  [TObj(n).Car.vx,  TObj(n).Car.vx(end)]; % add vx for traffic  obj´according to the definition in  CM manual
        
        TObj(n).Car.vx = eval(['data.Traffic_T' num2str(k) '_LongVel.data']);

        TObj(n).Lane.Act_LaneId = eval(['data.Traffic_T' num2str(k) '_Lane_Act_LaneId.data']);
        TObj(n).Lane.t2Ref = eval(['data.Traffic_T' num2str(k) '_t2Ref.data']);
        TObj(n).Lane.tRoad = eval(['data.Traffic_T' num2str(k) '_tRoad.data']);
        totalObjects = n;
        
        % process t2Ref
        TObj(n).Lane.t2Ref = TObj(n).Lane.t2Ref-TObj(n).Lane.t2Ref(1)+TObj(n).Lane.tRoad(1); % add initial tRoad offset
        
%         TObj(n).Lane.vy = eval(['data.Traffic_T' num2str(k) '_LatVel.data']); % add vy for Traffic obj
        TObj(n).DetectLevel = eval(['data.Traffic_T' num2str(k) '_DetectLevel.data']);
        
        struct_sensors = strcat('data.Sensor_Object_OB01_Obj_T', num2str(k), '_NearPnt_ds_x');
        
        if ~isempty(eval(struct_sensors))
            TObj(n).Sensor.dx = eval(['data.Sensor_Object_OB01_Obj_T' num2str(k) '_NearPnt_ds_x.data']);
            TObj(n).Sensor.dy = eval(['data.Sensor_Object_OB01_Obj_T' num2str(k) '_NearPnt_ds_y.data']);
        end
        
        %% process velocity data before saving: remove step from data
        if TObj(n).Car.vx(1) ==0 &&  TObj(n).Car.vx(2)>1  ||( TObj(n).Car.ax(1) ==0 && TObj(n).Car.ax(2)~=0)
            
            TObj(n).Car.vx(1) =  TObj(n).Car.vx(2)-TObj(n).Car.ax(2)*0.02; % 0.02 s being the sampling time
        end
        % index of the last non zeros element in Car.vx for TObj
        index_last_nonzero = find(TObj(n).Car.vx,1,'last');
        if abs(TObj(n).Car.vx(index_last_nonzero)- TObj(n).Car.vx(index_last_nonzero-1))>5 % thresolhold to workaround!
            TObj(n).Car.vx(index_last_nonzero) = TObj(n).Car.vx(index_last_nonzero-1);
        end
        % process zeros speed data at the end
        index_last_zero = find(TObj(n).Car.vx==0,1,'last');
        if ~isempty(index_last_zero)
            TObj(n).Car.vx(index_last_nonzero+1:index_last_zero) = TObj(n).Car.vx(index_last_nonzero);
        end
        %%%
    end
end

%% save Data in mat file
clear ('data', 'path2ergfile');
if  flag_resim ==1
    prepdata_filename= 'prepdata_resim.mat';
else
    prepdata_filename= 'prepdata.mat';
end
save(prepdata_filename);

end
