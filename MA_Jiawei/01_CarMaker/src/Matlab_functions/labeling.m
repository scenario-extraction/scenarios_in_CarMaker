function [outputArg1] = labeling(~)

% load(inputdata);
load('prepdata.mat');
%% Labels Ego Longitudinal

label.ego.long(1:length(Time))=0;
for n=1:length(Time)
     if Ego.Car.ax(n) > 1 % "acceleration"
         label.ego.long(n) = 1;
     elseif Ego.Car.ax(n) < -1   % "decceleration"
         label.ego.long(n) = -1;
     else % "static cruising"
         label.ego.long(n) = 0;
     end
end

%% Labels Ego Lateral
label.ego.lat(1:length(Time))=0;  
lc_ego_threshold = 0.005;
   
for n=6:length(Time)-6
    % "Lane Change Left" 
    if Ego.Lane.Act_LaneId(n) >  Ego.Lane.Act_LaneId(n+1) 
        %label.ego.lat(n-50:n+50) = -1;
        k = n;
        while Ego.Lane.DevDist(k) - Ego.Lane.DevDist(k-5) > lc_ego_threshold && k > 6 && k < length(Time)-6  
            label.ego.lat(k-5:k) = -1;
            k = k - 1;
        end
        k = n;
        while Ego.Lane.DevDist(k+5) - Ego.Lane.DevDist(k) > lc_ego_threshold && k > 6 && k < length(Time)-6
            label.ego.lat(k:k+5) = -1;
            k = k + 1;
        end
    % "Lane Change Right"
    elseif Ego.Lane.Act_LaneId(n) < Ego.Lane.Act_LaneId(n+1)
        %label.ego.lat(n-50:n+50) = 1;
        k = n;
        while Ego.Lane.DevDist(k) - Ego.Lane.DevDist(k-5) < -lc_ego_threshold && k > 6 && k < length(Time)-6  
            label.ego.lat(k-5:k) = 1;
            k = k - 1;
        end
        k = n;
        while Ego.Lane.DevDist(k+5) - Ego.Lane.DevDist(k) < -lc_ego_threshold && k > 6 && k < length(Time)-6
            label.ego.lat(k:k+5) = 1;
            k = k + 1;
        end
    % "Static cruising"
    else
        %label.ego.lat(n) = 0;
    end
end 
             
   
%% Labels Dynamic Objects Longitudinal
label.TObj.long(1:length(Time))=0;

for n=1:length(Time)
     if TObj.Car.ax(n) > 1 % "acceleration"
         label.TObj.long(n) = 1;
     elseif TObj.Car.ax(n) < -1   % "decceleration"
         label.TObj.long(n) = -1;
     else % "static cruising"
         label.TObj.long(n) = 0;
     end
end
  
%% Labels Dynamic Objects Lateral   
label.TObj.lat(1:length(Time))=0;  
lc_traffic_threshold = 0.005;

%length(Time)

for n=6:length(Time)-6
    % "Lane Change Left" 
    if TObj.Lane.Act_LaneId(n) > TObj.Lane.Act_LaneId(n+1) && TObj.ObjID(n,1) == TObj.ObjID(n +1,1)
        k = n;
        while TObj.Lane.t2Ref(k) - TObj.Lane.t2Ref(k-5) > lc_traffic_threshold && k > 6 && k < length(Time)-6  
            label.TObj.lat(k-5:k) = -1;
            k = k - 1;
        end
        k = n;
        while TObj.Lane.t2Ref(k+5) - TObj.Lane.t2Ref(k) > lc_traffic_threshold && k > 6 && k < length(Time)-6
            label.TObj.lat(k:k+5) = -1;
            k = k + 1;
        end
    % "Lane Change Right"
    elseif TObj.Lane.Act_LaneId(n) < TObj.Lane.Act_LaneId(n+1) && TObj.ObjID(n,1) == TObj.ObjID(n +1,1)
        k = n;
        while TObj.Lane.t2Ref(k) - TObj.Lane.t2Ref(k-5) < -lc_traffic_threshold && k > 6 && k < length(Time)-6  
            label.TObj.lat(k-5:k) = 1;
            k = k - 1;
        end
        k = n;
        while TObj.Lane.t2Ref(k+5) - TObj.Lane.t2Ref(k) < -lc_traffic_threshold && k > 6 && k < length(Time)-6
            label.TObj.lat(k:k+5) = 1;
            k = k + 1;
        end
    % "Static cruising"
    else
        %label.TObj.lat(n) = 0;
    end
end 
       

label.ObjId = TObj.ObjID(:,2)';

save ('true_label.mat', 'label', 'Time', 'TObj');
disp('Ground Truth labels matfile done');


end