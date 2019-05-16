% This function provides the necessary infos about the kinematics of the
% TObj by mainly creating respectively the matrices describing both long. kinematics and lat. kinematics for
% TObj known as long_TObj and lat_TObj. Furthermore the prediction of both long. velocity and
% lateral position profiles are provided as output.
%%
function [long_TObj,lat_TObj, TObj_vx_pred, TObj_lat_pred, label_TObj_long]=create_obj_matrix(prepdata_filename,label_data, n, flag_resim)

%% load and process CM data for TObj

load(prepdata_filename,'TObj','Time');

% load long quantities
TObj_accx=TObj(n).Car.ax;
TObj_vx=TObj(n).Car.vx;
TObj_sRoad=TObj(n).sRoad;

% preallocate
TObj_vx_pred = [];
TObj_lat_pred =[];
 

%% build the matrix describing the long. kinematics of TObj

long_TObj=[]; 

TObj_accx_thr=0.0; % threshold of the acc in x direction
label_TObj_long = []; % preallocate 

% long_TObj: linewise:
%1. beginning Time / 2. initial_vel in mps / 3. final_vel in mps/ 
%4. duration in s/ 5. Displacement / 6. Label

j=0;
m=0;
while j<length(Time)
    
    j=j+1;
    if j==1
        k=j;
    else
        k=j-1;
    end
    
    if round(TObj_accx(j),1)>=TObj_accx_thr
        
        while  j<length(Time) && round(TObj_accx(j),1)>=TObj_accx_thr
            
            j=j+1;
            
        end
        
        m=m+1;
        long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j);Time(j)-Time(k);TObj_sRoad(j)-TObj_sRoad(k);1];
        
    elseif round(TObj_accx(j),1)<=-TObj_accx_thr
        
        while  j<length(Time) && round(TObj_accx(j),1)<=-TObj_accx_thr
            
            j=j+1;
            
        end
        
        m=m+1;
        long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j);Time(j)-Time(k);TObj_sRoad(j)-TObj_sRoad(k);-1];
        
    else
        
        while j<length(Time) && round(TObj_accx(j),1)==TObj_accx_thr
            
            j=j+1;
            
        end
        m=m+1;
        long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j);Time(j)-Time(k);TObj_sRoad(j)-TObj_sRoad(k);0];
    end
end


% set time threshold for TObj
Time_thr=1.0;

long_TObj=create_long(long_TObj, Time_thr); % create the matrix long_TObj
 
if    flag_resim ==0
    TObj_vx_pred = velocity_pred_new(long_TObj); % predict velocity profile
    
end
%% correct the long. labeling for TObj

for ind=1:size(long_TObj,2)
    ind_start = find(Time==long_TObj(1,ind));
    if ind==size(long_TObj,2)
        ind_end = length(Time);
    else
        ind_end = find(Time==long_TObj(1,ind+1))-1;
    end
   label_TObj_long(ind_start:ind_end) = long_TObj(end,ind);
end

%%  build the matrix describing the lateral maneuvers of the TObj from the labeling data

lat_TObj=create_lat_with_label_TO(TObj,label_data,n, Time);

%% predict the lateral pos profile
if    flag_resim ==0
    TObj_lat_pred = lat_pos_pred(lat_TObj); 
    
end

end

