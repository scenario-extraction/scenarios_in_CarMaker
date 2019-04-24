function Tensor=create_tensor(prepdata_filename,label_data)

Tensor=[];
%% load prep-and labeling data

load(prepdata_filename,'Ego','TObj','Time','n','num_TObj');
load(label_data,'label');

if max(abs(Ego.Lane.vy))>=0.07
    
    Ego.Lane.Act_LaneId=Ego.Lane.Left_width ;
end

% remove redundant data
Time=unique(Time); % remove redundant Time values
Time_offset=Time(1);
Time=round(Time-Time(1),2); % round the Time values to 2 decimals

Ego.Car.ax = Ego.Car.ax(1:length(Time));
Ego.Car.vx = Ego.Car.vx(1:length(Time));
% Ego.Car.vx(end)= Ego.Car.vx(end-1);
Ego.Lane.vy = Ego.Lane.vy(1:length(Time));
Ego.sRoad = Ego.sRoad(1:length(Time));
Ego.Lane.DevDist = Ego.Lane.DevDist(1:length(Time));
Ego.Lane.Act_LaneId = Ego.Lane.Act_LaneId(1:length(Time));


%% create the matrix describing the total long. maneuver of ego

long_ego = []; % matrix containing the vectors describing the total long. maneuver of ego

Ego.Car.ax_thr = 0.55; % threshold of the acc in x direction
label_ego_long =[];

% long_ego: columnwise:
%1. beginning Time / 2. initial_vel in mps / 3. final_vel in mps/
%4. duration in s/ 5. Displacement in m / 6. Label
j=0;
m=0;

while j<length(Time)
    
    j=j+1;
    if j==1
        
        k=j;
    else
        
        k=j-1;
        
    end
    
    if Ego.Car.ax(j)>=Ego.Car.ax_thr
        
        while  j<length(Time) && Ego.Car.ax(j)>=Ego.Car.ax_thr
            
            j=j+1;
            label_ego_long (j) =1;
            
        end
        
        m=m+1;
        long_ego(:,m)=[Time(k);Ego.Car.vx(k);Ego.Car.vx(j);Time(j)-Time(k);Ego.sRoad(j)-Ego.sRoad(k);1];
    elseif Ego.Car.ax(j)<=-Ego.Car.ax_thr
        while  j<length(Time) && Ego.Car.ax(j)<=-Ego.Car.ax_thr
            
            j=j+1;
            label_ego_long (j) =-1;
            
        end
        
        m=m+1;
        long_ego(:,m)=[Time(k);Ego.Car.vx(k);Ego.Car.vx(j);Time(j)-Time(k);Ego.sRoad(j)-Ego.sRoad(k);-1];
        
    else
        while j<length(Time) && abs(Ego.Car.ax(j))<Ego.Car.ax_thr
            
            j=j+1;
            label_ego_long (j) =0;
            
            
        end
        m=m+1;
        long_ego(:,m)=[Time(k);Ego.Car.vx(k);Ego.Car.vx(j);Time(j)-Time(k);Ego.sRoad(j)-Ego.sRoad(k);0];
        
    end
end

% set thresholds for Time
Time_thr=1.0; % must be greater than clutch duration

long_ego =create_long(long_ego,Time_thr);

% predict velocity from the matrix long_ego
Ego.Car.vx_pred=velocity_pred(long_ego);

% correct the long. labeling for Ego
for ind=1:size(long_ego,2)
    ind_start = find(Time==long_ego(1,ind));
    if ind==size(long_ego,2)
        ind_end = length(Time);
    else
        ind_end = find(Time==long_ego(1,ind+1))-1;
    end
    label_ego_long(ind_start:ind_end)= long_ego(end,ind);
end


%% create the matrix describing the lateral maneuver of the ego method with labeling function
j=0;
m=0;

while j<length(Time)
    
    j=j+1;
    if j==1
        k=j;
    else
        k=j-1;
    end
    
    if label.ego.lat(j)==0 % Lane Keeping
        
        while  j<length(Time) && label.ego.lat(j)==0
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_ego(:,m)=[Time(k);Time(j)-Time(k);Ego.Lane.DevDist(j);0];
        
        
    elseif label.ego.lat(j)==1 % LCR
        
        while  j<length(Time) && label.ego.lat(j)==1
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_ego(:,m)=[Time(k);Time(j)-Time(k);Ego.Lane.DevDist(j);1];
        
    elseif label.ego.lat(j)==-1 % LCL
        
        while  j<length(Time) && label.ego.lat(j)==-1
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_ego(:,m)=[Time(k);Time(j)-Time(k);Ego.Lane.DevDist(j);-1];
    else %
        
    end
end

Ego.Lane.DevDist_pred = lat_offset_pred(lat_ego);

%% predict Car.v for CM
% Ego.Car.vx_pred=[Ego.Car.vx_pred,Ego.Car.vx_pred(end)];
% Ego.Lane.vy_pred=diff(Ego.Lane.DevDist_pred)./diff(Time);
% Ego.Lane.vy_pred=[Ego.Lane.vy_pred,Ego.Lane.vy_pred(end)];
% Ego.Car.v_pred=sqrt((Ego.Lane.vy_pred).^2+(Ego.Car.vx_pred).^2);
Ego.Car.v_pred=Ego.Car.vx_pred;

%% Combining the lat. and the long. to create to resulting matrix according to the model for Ego
% vel. and lateral pos of resulting matrix must be taken from prediction data!

% timestamps of man change for ego

Time_change_ego = unique([long_ego(1,:), lat_ego(1,:)]);

vec_temp_ego(1,:) = Time_change_ego; % 1. row for timestamps of maneu changes

for i=1:length(Time_change_ego)
    
    vec_temp_ego(2,i)= Ego.Car.v_pred(Time==Time_change_ego(i)); % long. velo data from predictIon
    
    vec_temp_ego(3,i)= Ego.Lane.DevDist_pred(Time==Time_change_ego(i)); % abs. lateral pos from prediction
    
    vec_temp_ego(4,i) = label_ego_long(Time==Time_change_ego(i)); % data from labeling correction
    
    vec_temp_ego(5,i) = label.ego.lat(Time==Time_change_ego(i)); % data from data struct
    
end

%- initial conditions
vec_overwrite_ego(:,1)= vec_temp_ego(:,1);

j=1;

for i=1:length(Time_change_ego)-1
    j=j+1;
    vec_overwrite_ego(1,j)= vec_temp_ego(1,i+1) - vec_temp_ego(1,i);
    vec_overwrite_ego(2,j)= vec_temp_ego(2,i+1);
    vec_overwrite_ego(3,j)= vec_temp_ego(3,i+1);
    vec_overwrite_ego(4,j)= vec_temp_ego(4,i); % label long. maneu change
    vec_overwrite_ego(5,j)= vec_temp_ego(5,i); % label lat. maneuv change
    
end

% add final velocity to vec_overwrite
vec_overwrite_ego=[vec_overwrite_ego,[0;0;0;0;0]];
duration_temp=sum(vec_overwrite_ego(1,1:end));
vec_overwrite_ego(1,end)= Time(end)-duration_temp;
vec_overwrite_ego(2,end)=Ego.Car.v_pred(end);
vec_overwrite_ego(3,end)= Ego.Lane.DevDist_pred(end);
vec_overwrite_ego(4,end) = long_ego(end,end);
vec_overwrite_ego(5,end) = lat_ego(end,end);
% convert velocities to kmh
vec_overwrite_ego(2,:)=vec_overwrite_ego(2,:)*3.6;

% fill the Ego Part of the Tensor
Tensor.Ego = vec_overwrite_ego;

%% Combining the lat. and the long. to create to resulting matrix according to the model for TObj

vec_overwrite_TObj=[];

% create the Tensor matrices for all detectable TObj
for index = 1:length(num_TObj)
    if check_detectable(TObj(index).DetectLevel)
        
        [long_TObj,lat_TObj,TObj(index).Car.vx_pred,TObj(index).Lane.tRoad_pred, TObj(index).long_label, Time_Obj, detect_at_start]=create_obj(prepdata_filename,label,index);
        %% predict LongVel Quantity for TO for CM
        %         TObj(index).Lane.vy_pred=diff(TObj(index).Lane.tRoad_pred)./diff(Time_Obj);
        %         TObj(index).Lane.vy_pred =[TObj(index).Lane.vy_pred,TObj(index).Lane.vy_pred(end)];
        % %         TObj(index).Car.v_pred=sqrt((TObj(index).Lane.vy_pred).^2+(TObj(index).Car.vx_pred).^2);
        %         TObj(index).Car.v_pred = TObj(index).Car.vx_pred;
        %% continue
        max_Time_Obj = Time_Obj(end);
        
        Time_man_change_obj = unique([long_TObj(1,:), lat_TObj(1,:)]);
        
        %         if detect_at_start==0
        Time_state_long_change = Time(find(diff(label.state.TObj(index).long))+1);
        Time_state_lat_change = Time(find(diff(label.state.TObj(index).lat))+1);
        %         else
        %             Time_state_long_change = [0,Time(find(diff(label.state.TObj(index).long))+1)];
        %             Time_state_lat_change = [0, Time(find(diff(label.state.TObj(index).lat))+1)];
        %         end
        % detect the Time when a lat. or long. man or a spatial state change begins to take place
        Time_state_change = unique([Time_state_long_change,Time_state_lat_change]);
        Time_change_obj = unique([Time_man_change_obj, Time_state_change]);
        
        Time_change_obj(Time_change_obj>= max_Time_Obj)=[]; % del. columns with values equal or greater than maxTimeObj
        
        vec_temp_TObj = zeros(8,length(Time_change_obj)); % preallocate
        
        vec_temp_TObj(1,:) = Time_change_obj;
        
        %% round time arrays
        Time_Obj = round(Time_Obj,2);
        Time_change_obj = round(Time_change_obj,2);
        %% continue
        for i=1:length(Time_change_obj)
            ind_temp = find(Time_Obj==Time_change_obj(i));
            vec_temp_TObj(2,i) = TObj(index).Car.vx_pred(Time_Obj==Time_change_obj(i)); % data from prediction
            vec_temp_TObj(3,i) = TObj(index).Lane.tRoad_pred(Time_Obj==Time_change_obj(i)); % data from prediction
            vec_temp_TObj(5,i) = TObj(index).long_label(Time_Obj==Time_change_obj(i)); % data from long. labeling
            vec_temp_TObj(6,i) = label.TObj(index).lat(Time==Time_change_obj(i)); % data from lat. labeling
            vec_temp_TObj(7,i) = label.state.TObj(index).long(Time==Time_change_obj(i)); % data from long state label
            vec_temp_TObj(8,i) = label.state.TObj(index).lat(Time==Time_change_obj(i)); % data from lat state label
        end
        
        % first column is for the inital conditions
        
        vec_overwrite_TObj(:,1)= vec_temp_TObj(:,1);
        j=1;
        
        for i=1:size(vec_temp_TObj,2)-1
            j=j+1;
            vec_overwrite_TObj(1,j) = vec_temp_TObj(1,i+1) - vec_temp_TObj(1,i); % set the duration of the maneu for CM Resim
            vec_overwrite_TObj(2,j) = vec_temp_TObj(2,i+1);
            vec_overwrite_TObj(3,j) = vec_temp_TObj(3,i+1); % lat pos
            vec_overwrite_TObj(4,j) = (vec_temp_TObj(2,i+1)-vec_temp_TObj(2,i))/(vec_temp_TObj(1,i+1)-vec_temp_TObj(1,i));% avg acc
            vec_overwrite_TObj(5,j) = vec_temp_TObj(5,i);
            vec_overwrite_TObj(6,j) = vec_temp_TObj(6,i);
            vec_overwrite_TObj(7,j) = vec_temp_TObj(7,i);
            vec_overwrite_TObj(8,j) = vec_temp_TObj(8,i);
            
        end
        
        temp_value=vec_overwrite_TObj(2,end); % temp variable
        
        % add the final maneuver to vec_overwrite_TObj
        vec_overwrite_TObj=[vec_overwrite_TObj,[0;0;0;0;0;0;0;0]];
        duration_temp=sum(vec_overwrite_TObj(1,1:end));
        
        vec_overwrite_TObj(1,end)= Time_Obj(end) - duration_temp;
        t_end = vec_overwrite_TObj(1,end);
        vec_overwrite_TObj(2,end) = TObj(index).Car.vx_pred(end);
        vec_overwrite_TObj(3,end) = TObj(index).Lane.tRoad_pred(end);
        vec_overwrite_TObj(4,end) = (TObj(index).Car.vx_pred(end)-temp_value)/t_end; % add the value of avg acc in the last maneuver
        vec_overwrite_TObj(5,end) = long_TObj(end,end);
        vec_overwrite_TObj(6,end) = lat_TObj(end,end);
        vec_overwrite_TObj(7,end) = label.state.TObj(index).long(Time==Time_Obj(end));
        vec_overwrite_TObj(8,end) = label.state.TObj(index).lat(Time==Time_Obj(end));
        
        % convert velocities to kmh
        vec_overwrite_TObj(2,:)=vec_overwrite_TObj(2,:)*3.6;
        
        % fill the Tensor struct with the matrices of Obj
        Tensor.TObj(index).data = vec_overwrite_TObj;
        Tensor.TObj(index).detect_at_start= detect_at_start;
        if detect_at_start == 0
            Tensor.TObj(index).sRoad_init = TObj(index).sRoad(Time==Time_Obj(1));% init sRoad at the time(ind_first)
            Tensor.TObj(index).tRoad_init = TObj(1).Lane.tRoad(Time==Time_Obj(1));    % init tRoad at time(ind_last)
        else
            Tensor.TObj(index).sRoad_init = [];
            Tensor.TObj(index).tRoad_init = [];
            
        end
    else
        Tensor.TObj(index).data=[];
    end
    vec_overwrite_TObj=[]; % preallocate again for the next iteration
end

% tensor struct contains num_Tobj and Time array
Tensor.num_TObj = num_TObj;
Tensor.Time = Time;

end









