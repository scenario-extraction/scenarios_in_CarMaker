function  label_data=labeling(inputdata)

load(inputdata);
% load('prepdata.mat');
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
lc_ego_threshold = 0.005;  %parameter
   
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
for i=1:totalObjects
    label.TObj(i).long(1:length(Time))=0;

    for n=1:length(Time)
        if TObj(i).DetectLevel(n) > 0
             if TObj(i).Car.ax(n) > 1 % "acceleration"
                 label.TObj(i).long(n) = 1;
             elseif TObj(i).Car.ax(n) < -1   % "decceleration"
                 label.TObj(i).long(n) = -1;
             else % "static cruising"
                 label.TObj(i).long(n) = 0;
             end
        else 
             label.TObj(i).long(n) = -9; %outside the area of interest
        end
    end
  
    %% Labels Dynamic Objects Lateral   
    label.TObj(i).lat(1:length(Time))=0;  
    %% TODO: Workaround!
    label.TObj(i).lat(1:6)=-9;
    label.TObj(i).lat(length(Time)-6:length(Time))=-9;
    
    lc_traffic_threshold = 0.005;

    for n=6:length(Time)-6
        if TObj(i).DetectLevel(n) > 0
            % "Lane Change Left" 
            if TObj(i).Lane.Act_LaneId(n) >  TObj(i).Lane.Act_LaneId(n+1)
                k = n;
                while TObj(i).Lane.t2Ref(k) - TObj(i).Lane.t2Ref(k-5) > lc_traffic_threshold && k > 6 && k < length(Time)-6;;  
                    label.TObj(i).lat(k-5:k) = -1;
                    k = k - 1;
                end
                k = n;
                while TObj(i).Lane.t2Ref(k+5) - TObj(i).Lane.t2Ref(k) > lc_traffic_threshold && k > 6 && k < length(Time)-6;
                    label.TObj(i).lat(k:k+5) = -1;
                    k = k + 1;
                end
            % "Lane Change Right"
            elseif TObj(i).Lane.Act_LaneId(n) < TObj(i).Lane.Act_LaneId(n+1)
                k = n;
                while TObj(i).Lane.t2Ref(k) - TObj(i).Lane.t2Ref(k-5) < -lc_traffic_threshold && k > 6 && k < length(Time)-6;  
                    label.TObj(i).lat(k-5:k) = 1;
                    k = k - 1;
                end
                k = n;
                while TObj(i).Lane.t2Ref(k+5) - TObj(i).Lane.t2Ref(k) < -lc_traffic_threshold && k > 6 && k < length(Time)-6;
                    label.TObj(i).lat(k:k+5) = 1;
                    k = k + 1;
                end
            % "Static cruising"
            else
                %label.TObj(i).lat(n) = 0;
            end
        else 
             label.TObj(i).lat(n) = -9; %outside the area of interest
        end
    end 
end    


%% Label states
for i=1:totalObjects
    % initialize with status unknown / irrelevant (-99)
    label.state.TObj(i).long(1:length(Time))= -99;
    label.state.TObj(i).lat(1:length(Time))= -99;

    for n=1:length(Time)
        if TObj(i).DetectLevel(n) > 0
            %long direction
            if abs(Ego.sRoad(n) - TObj(i).sRoad(n)) <= 2.5 % "same level"
                label.state.TObj(i).long(n) = 0;
             elseif Ego.sRoad(n) - TObj(i).sRoad(n) > 2.5 && Ego.sRoad(n) - TObj(i).sRoad(n) < 200 % "Obj behind"
                label.state.TObj(i).long(n) = -1;
             elseif TObj(i).sRoad(n) - Ego.sRoad(n) > 2.5 && TObj(i).sRoad(n) - Ego.sRoad(n) < 200 % "Obj in front"
                label.state.TObj(i).long(n) = 1;
             end

            %lat direction
            if  label.state.TObj(i).long(n) > -99
                label.state.TObj(i).lat(n) = TObj(i).Lane.Act_LaneId(n) -  Ego.Lane.Act_LaneId(n);
            end
        end
    end
end





%% Save
label_data= 'true_label.mat';
% save ('true_label.mat', 'label', 'Time', 'totalObjects');
save(label_data,'label');
disp('Ground truth labels generation done');

end