% function to build the long. matrix describing the long motion of Ego
% according to the theoretical model. This function is
% specific to Ego with manual driving mode.
% * defined maneuver refer hier to acceleration, decelartion or static cruising

%---Abbreviations:
%GS: gear shifting
function M = build_long_matrix(Ego_Car_ax, Ego_Car_vx, Time, Ego_sRoad, Time_thr)

M = []; % preallocate

Ego_Car_ax_thr = 0; % threshold of the acceleration

%% The section of the function partitions the acc-velocity curve based on the elementar longitudinal maneuvers: acceleration, deceleration and constant velocity cruising
% M: is the output matrix of this function described linewise as described in the model:
%1. beginning Time
%2. initial velocity in mps
%3. final velocity in mps
%4. duration in s
%5. displacement in m
%6. label

% the matlab predifined function round is used in this case to get consistent
% partitioning of the acceleration-velocity curve. In order to work with plausibel data, very small values of
% acceleration will be considered as zeros. 

j=0;
m=0;

while j<length(Time)
    
    j=j+1;
    if j==1
        
        k=j;
    else
        
        k=j-1;
        
    end
       
    if round(Ego_Car_ax(j),1)>Ego_Car_ax_thr
        
        while  j<length(Time) && round(Ego_Car_ax(j),1)>Ego_Car_ax_thr
            
            j=j+1;
            
        end
        
        m=m+1;
        M(:,m)=[Time(k);Ego_Car_vx(k);Ego_Car_vx(j);Time(j)-Time(k);Ego_sRoad(j)-Ego_sRoad(k);1];% add the new motion segment to M
        
    elseif round(Ego_Car_ax(j),1)<Ego_Car_ax_thr
        
        while  j<length(Time) && round(Ego_Car_ax(j),1)<Ego_Car_ax_thr
            
            j=j+1;
            
        end
        
        m=m+1;
        M(:,m)=[Time(k);Ego_Car_vx(k);Ego_Car_vx(j);Time(j)-Time(k);Ego_sRoad(j)-Ego_sRoad(k);-1];% add the new motion segment to M
        
    else
        while j<length(Time) && round(Ego_Car_ax(j),1)==Ego_Car_ax_thr
            
            j=j+1;
            
        end
        m=m+1;
        M(:,m)=[Time(k);Ego_Car_vx(k);Ego_Car_vx(j);Time(j)-Time(k);Ego_sRoad(j)-Ego_sRoad(k);0];% add the new motion segment to M
        
    end
end

%% create final version of the matrix

M=create_long(M,Time_thr);

end
