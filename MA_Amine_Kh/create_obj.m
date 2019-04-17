% create the matrices describing both long. maneu and lat. maneuver for TObj
function [long_TObj,lat_TObj, TObj_vx_pred, TObj_lat_pred, time_Obj]=create_obj(prepdata_filename,~, n)

%% load and process CM data for TObj

load(prepdata_filename,'TObj','Time');

time= Time;

% long Quantities
TObj_accx=TObj(n).Car.ax;
TObj_vx=TObj(n).Car.vx;
TObj_vx(1)=TObj_vx(2);
TObj_distx=TObj(n).sRoad;

% lat Quantities
TObj_vy=TObj(n).Lane.vy;
TObj_lat= TObj(n).Lane.tRoad; % -TObj(n).Lane.tRoad(1); % remove lat. Offset from the lat displacement
TObj_LaneID=TObj(n).Lane.Act_LaneId;

% remove redundant data based on detection level 
ind_last = find(TObj(n).DetectLevel~=0,1,'last');
time = time(1:ind_last);

time=unique(time); % remove redundant time values
time_offset=time(1);
time=round(time-time(1),2); % round the time values to 2 decimals
arr_length=length(time);

TObj_accx = TObj_accx(1:arr_length);
TObj_vx = TObj_vx(1:arr_length);

figure;
plot(TObj_vx);
% TObj_vx(end) = TObj_vx(end-1);
TObj_distx = TObj_distx(1:arr_length);
TObj_lat = TObj_lat(1:arr_length);
TObj_LaneID = TObj_LaneID(1:arr_length);

%% build the long man matrix describing the long. maneuver of TObj

long_TObj=[]; % matrix containing the vectors describing the long. maneuver

TObj_accx_thr=0.55; % threshold of the acc in x direction

% long_TObj: columnwise:
%1. beginning time / 2. initial_vel in mps / 3. final_vel in mps/ 
%4. duration in s/ 5. Displacement / 6. Label

j=0;
m=0;
while j<length(time)
    
    j=j+1;
    if j==1
        k=j;
    else
        k=j-1;
    end
    
    if TObj_accx(j)>=TObj_accx_thr
        
        while  j<length(time) && TObj_accx(j)>=TObj_accx_thr
            
            j=j+1;
            
        end
        
        m=m+1;
        long_TObj(:,m)=[time(k);TObj_vx(k);TObj_vx(j);time(j)-time(k);TObj_distx(j)-TObj_distx(k);1];
        
    elseif TObj_accx(j)<=-TObj_accx_thr
        
        while  j<length(time) && TObj_accx(j)<=-TObj_accx_thr
            
            j=j+1;
            
        end
        
        m=m+1;
        long_TObj(:,m)=[time(k);TObj_vx(k);TObj_vx(j);time(j)-time(k);TObj_distx(j)-TObj_distx(k);-1];
        
    elseif abs(TObj_accx(j))<TObj_accx_thr
        
        while j<length(time) && abs(TObj_accx(j))<TObj_accx_thr
            
            j=j+1;
            
        end
        m=m+1;
        long_TObj(:,m)=[time(k);TObj_vx(k);TObj_vx(j);time(j)-time(k);TObj_distx(j)-TObj_distx(k);0];
        
    else
        
    end
end

% set thresholds for time
time_thr=1.0;

long_TObj=create_long(long_TObj, time_thr); % create the matrix long_TObj
TObj_vx_pred = velocity_pred(long_TObj);

%% build the matrix describing the lateral maneuvers of the TObj according to the model

j=0;
m=0;
TObj_vy_thr=0.05; % lat velocity threshold

lat_TObj=[]; % preallocate the matrix containing the vectors describing the lateral maneuvers of the TObj


% lat_TObj: columnwise: 1. time, 2.Duration, 3. Lateral Offset
while j<length(time)
    
    j=j+1;
    if j==1
        k=j;
    else
        k=j-1;
    end
    if (TObj_vy(j))>=TObj_vy_thr
        while j<length(time)  && (TObj_vy(j))>=TObj_vy_thr
            j=j+1;
        end
        m=m+1;
        
        lat_TObj(:,m)=[time(k);time(j)-time(k);TObj_lat(k);TObj_lat(j);(max(TObj_vy(k:j)));k;j]; % add index k,j
        
        
    elseif TObj_vy(j)<=-TObj_vy_thr
        while j<length(time)  && TObj_vy(j)<=-TObj_vy_thr
            
            j=j+1;
        end
        m=m+1;
        
        lat_TObj(:,m)=[time(k);time(j)-time(k);TObj_lat(k);TObj_lat(j);(min(TObj_vy(k:j)));k;j];
    else
        while j<length(time)  && abs(TObj_vy(j))<TObj_vy_thr
            
            j=j+1;
        end
        m=m+1;
        
        lat_TObj(:,m)=[time(k);time(j)-time(k);TObj_lat(k);TObj_lat(j);max(abs(TObj_vy(k:j)));k;j];
        
    end
end

[lat_TObj,TObj_lat_pred]=create_lat(lat_TObj,TObj_LaneID);

% assign time variable specific to TObj
time_Obj=time;


