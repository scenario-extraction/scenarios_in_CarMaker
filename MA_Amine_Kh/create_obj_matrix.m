% This function provides the necessary infos about the kinematics of the
% TObj by mainly creating respectively the matrices describing both long. kinematics and lat. kinematics for
% TObj known as long_TObj and lat_TObj. Furthermore the prediction of both long. velocity and
% lateral position profiles are provided as output.
%%
function [long_TObj,lat_TObj, TObj_vx_pred, TObj_lat_pred, label_TObj_long, time_Obj, det_ind]=create_obj_matrix(prepdata_filename,label_data, n)

%% load and process CM data for TObj

load(prepdata_filename,'TObj','Time');
det_ind = 1; % detection at start indicator

% load long quantities
TObj_accx=TObj(n).Car.ax;
TObj_vx=TObj(n).Car.vx;
TObj_sRoad=TObj(n).sRoad;


% test plot 
if n==2
    figure(50);
    plot(TObj_vx);
end
 

% load lat Quantities
TObj_vy=TObj(n).Lane.vy;
TObj_lat= TObj(n).Lane.tRoad; 
TObj_LaneID=TObj(n).Lane.Act_LaneId;

% define the time during which the TObj is detectable and consider its motion only in this time interval  
ind_first = find(TObj(n).DetectLevel~=0,1,'first');
if ind_first> 51 % not detectable in the first sec after sim starts
    det_ind = 0;
else
    ind_first =1; % detection timestamps below one sec are ignored
end

ind_last= find(TObj(n).DetectLevel~=0,1,'last');
time_Obj = Time(ind_first:ind_last);

time_Obj=unique(time_Obj); % remove redundant time_Obj values
time_Obj=round(time_Obj,2); % round the time_Obj values to 2 decimals

% prepare quantites 
TObj_accx = TObj_accx(ind_first:ind_last);
TObj_vx = TObj_vx(ind_first:ind_last);
TObj_sRoad = TObj_sRoad(ind_first:ind_last);
TObj_lat = TObj_lat(ind_first:ind_last);

%% build the matrix describing the long. kinematics of TObj

long_TObj=[]; 

TObj_accx_thr=0.0; % threshold of the acc in x direction
label_TObj_long = []; % preallocate 

% long_TObj: linewise:
%1. beginning time_Obj / 2. initial_vel in mps / 3. final_vel in mps/ 
%4. duration in s/ 5. Displacement / 6. Label

j=0;
m=0;
while j<length(time_Obj)
    
    j=j+1;
    if j==1
        k=j;
    else
        k=j-1;
    end
    
    if round(TObj_accx(j),1)>=TObj_accx_thr
        
        while  j<length(time_Obj) && round(TObj_accx(j),1)>=TObj_accx_thr
            
            j=j+1;
            
        end
        
        m=m+1;
        long_TObj(:,m)=[time_Obj(k);TObj_vx(k);TObj_vx(j);time_Obj(j)-time_Obj(k);TObj_sRoad(j)-TObj_sRoad(k);1];
        
    elseif round(TObj_accx(j),1)<=-TObj_accx_thr
        
        while  j<length(time_Obj) && round(TObj_accx(j),1)<=-TObj_accx_thr
            
            j=j+1;
            
        end
        
        m=m+1;
        long_TObj(:,m)=[time_Obj(k);TObj_vx(k);TObj_vx(j);time_Obj(j)-time_Obj(k);TObj_sRoad(j)-TObj_sRoad(k);-1];
        
    else
        
        while j<length(time_Obj) && round(TObj_accx(j),1)==TObj_accx_thr
            
            j=j+1;
            
        end
        m=m+1;
        long_TObj(:,m)=[time_Obj(k);TObj_vx(k);TObj_vx(j);time_Obj(j)-time_Obj(k);TObj_sRoad(j)-TObj_sRoad(k);0];
    end
end


% set time threshold for TObj
time_Obj_thr=1.0;

long_TObj=create_long(long_TObj, time_Obj_thr); % create the matrix long_TObj
TObj_vx_pred = velocity_pred(long_TObj); % predict velocity profile

%% correct the long. labeling for TObj

for ind=1:size(long_TObj,2)
    ind_start = find(time_Obj==long_TObj(1,ind));
    if ind==size(long_TObj,2)
        ind_end = length(time_Obj);
    else
        ind_end = find(time_Obj==long_TObj(1,ind+1))-1;
    end
   label_TObj_long(ind_start:ind_end) = long_TObj(end,ind);
end

%%  build the matrix describing the lateral maneuvers of the TObj from the labeling data

lat_TObj=create_lat_with_label_TO(TObj,label_data,n, time_Obj, ind_first, ind_last);

%% predict the lateral pos profile
 TObj_lat_pred= lat_pos_pred(lat_TObj);
 
 
%% plot to test 


end

