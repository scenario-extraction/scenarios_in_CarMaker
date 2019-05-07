% this function creates the tensor, which describes the driving scenario in
% terms of longitudinal and lateral maneuvers according to the theoretical
% model based on the following elementar maneuvers: for lateral: lane Keeping, Lane
% Change right, Lane change left. For longitudinal: acceleration,
%deceleration and static cruising. The tensor contains matrices respectively for Ego
%vehicle and for the other detectable movable Traffic Objects (in this case
%vehicles). The main tasks of this function are mentioned in the Header of
%the different sections of this script

%--- Abbreviations:
%LK: lane keeping
%LCR: lane change right
%LCL: lane change left
%acc: acceleration
%dec: deceleration
%arr: array
%TOBj: traffic object
% CM: CarMaker

%%
function Tensor=create_tensor(prepdata_filename,label_data)

% preallocate 
Tensor=[];
%% load needed data from created structs within the labeling.m and preparedata.m functions

load(prepdata_filename,'Ego','TObj','Time','n','num_TObj');
load(label_data,'label');

% remove redundant data and process time data

Time=unique(Time); % remove redundant Time values
Time_offset=Time(1); % Time offset to add later after processing the data
Time=round(Time-Time(1),2); % round the Time values to 2 decimals
Ego.Car.ax = Ego.Car.ax(1:length(Time));
Ego.Car.vx = Ego.Car.vx(1:length(Time));
Ego.sRoad = Ego.sRoad(1:length(Time));
Ego.Lane.DevDist = Ego.Lane.DevDist(1:length(Time));
Ego.Lane.Act_LaneId = Ego.Lane.Act_LaneId(1:length(Time));

% Engine Contol Unit and clutch Quantitites for manual driving mode. PS: Ego.GearNo is actually Ego.Gear_trgt
Ego.GearNo = Ego.GearNo(1:length(Time));
Ego.Clutch = Ego.Clutch(1:length(Time));


% get and process information from clutch quantities in order distunguish between attempt to
% reaccelerate and static cruising for maneuverual driving

gear_acc(1,:)=[1,2,3,4,5]; % gear numbers
gear_acc(2,:)= [4.6,2.5,1.8,1.3,0.9]; % maximum reachable acceleration per Gear

% the clutch array contains linewise:
%1- Time
%2- current gear number
%3- occurence of gear shifting 
clutch_array = zeros(3,length(Ego.Clutch)); % preallocate
clutch_array(1,:)= Time;
clutch_array(2,:)= Ego.GearNo;
diff_gear= diff(Ego.GearNo); % check the occurence of gear shifting 
diff_gear =[0,diff_gear]; % assumption: no gear Shifting at the start of the simulation
clutch_array(3,:)=diff_gear;

% test plot
vx_to_plot =Ego.Car.vx(1:220);
plot(vx_to_plot,'r')
hold on

%% create the matrix describing the long. motion of ego during the scenario
% this matrix is used later as input for the long. velocity prediction model



% preallocate arr. containing the long. labeling
label_ego_long =[];


% call build_long_matrix func for Ego
long_ego = build_long_matrix(Ego.Car.ax, Ego.Car.vx, Time, Ego.sRoad, clutch_array, gear_acc);

% predict velocity from the matrix long_ego
Ego.Car.vx_pred=velocity_pred_new(long_ego);

% plot test
figure(99);
plot(Ego.Car.vx_pred,'b--'); hold on;
plot(Ego.Car.vx,'r');

% correct the long. labeling for Ego
for ind=1:size(long_ego,2)
    ind_start = find(Time==long_ego(1,ind));
    if ind==size(long_ego,2)
        ind_end = length(Time);
    else
        ind_end = find(Time==long_ego(1,ind+1))-1;
    end
    label_ego_long(ind_start:ind_end)= long_ego(6,ind); % 6. row in the matrix long_ego contains the long. labeling
end

%% create the matrix describing the lateral motion of the ego with the data from lateral labeling done witin the function labeling.m
%this matrix is used later as input for the lat. position prediction model
% the matrix is linewise:
% 1- Beginning time of the action
% 2- duration of the action
% 3- target absolute lateral position
% 4- label


j=0;
m=0;

while j<length(Time)
    
    j=j+1;
    if j==1 
        k=j;
    else
        k=j-1;
    end
    
    if label.ego.lat(j)==0 % if  Lane Keeping
        
        while  j<length(Time) && label.ego.lat(j)==0
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_ego(:,m)=[Time(k);Time(j)-Time(k);Ego.Lane.DevDist(j);0];
        
        
    elseif label.ego.lat(j)==1 % if LCR
        
        while  j<length(Time) && label.ego.lat(j)==1
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_ego(:,m)=[Time(k);Time(j)-Time(k);Ego.Lane.DevDist(j);1];
        
    elseif label.ego.lat(j)==-1 % if LCL
        
        while  j<length(Time) && label.ego.lat(j)==-1
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_ego(:,m)=[Time(k);Time(j)-Time(k);Ego.Lane.DevDist(j);-1];
    else %
        
    end
end

% predict the whole lateral position profile 
Ego.Lane.DevDist_pred = lat_pos_pred(lat_ego);

% plot test
figure(100)
plot(Ego.Lane.DevDist_pred,'b--')
hold on
plot(Ego.Lane.DevDist,'r')

%% predict Car.v quantity for CM
% CM does not treat the maneuvereuver definition in terms of long. and lat.dynamics 
%separately and does not offer needed model-related quantites in the GUI. 
% For example the GUI offers the quantity Car.v as the only quantity for long. dynamics.
%the first problem is overriden by the defition of the model, which take in account the overlapping parts in time axis between the lateral and long. maneuvereuvers. 
% In order to override the second problem we predict Car.v from predicted longitudinal velocity and predicted lateral displacement

Ego.Lane.vy_pred=diff(Ego.Lane.DevDist_pred)./diff(Time); % derive the lat. velocity as described in CM Reference's Guide
Ego.Lane.vy_pred=[Ego.Lane.vy_pred,Ego.Lane.vy_pred(end)];
Ego.Car.v_pred=sqrt((Ego.Lane.vy_pred).^2+(Ego.Car.vx_pred).^2); % calculate predicted Car.v=sqrt(v_x^2+v_y^2)

%% Combining the lat. and the long. to create to resulting matrix according to the model for Ego

% timestamps of maneuvereuver change for ego
Time_change_ego = unique([long_ego(1,:), lat_ego(1,:)]);

% create temporary array to store above timestamps and needed data for
% velocity and lat. position according to the model

vec_temp_ego(1,:) = Time_change_ego; 

for i=1:length(Time_change_ego)
    
    vec_temp_ego(2,i)= Ego.Car.v_pred(Time==Time_change_ego(i)); % long. velo data from predictIon
    
    vec_temp_ego(3,i)= Ego.Lane.DevDist_pred(Time==Time_change_ego(i)); % abs. lateral position from prediction
    
    vec_temp_ego(4,i) = label_ego_long(Time==Time_change_ego(i)); % data from long. labeling correction
    
    vec_temp_ego(5,i) = label.ego.lat(Time==Time_change_ego(i)); % data from data struct from labeling.m function
    
end

%create the final matrix of the Ego, which will be used to overwrite the
%maneuver in the infofile. The matrix is described linewise as follows:
% 1- Duration of the maneuver
% 2- target velocity
% 3- target lateral position
% 4- long. label
% 5- lat. label

vec_overwrite_ego = [];

% first column is for the initial conditions: initial velocity and initial
% lat. position
vec_overwrite_ego(:,1) = vec_temp_ego(:,1);


j=1;
for i=1:length(Time_change_ego)-1
    j=j+1;
    vec_overwrite_ego(1,j)= vec_temp_ego(1,i+1) - vec_temp_ego(1,i); % calculate duration from two consecutive timestamps
    vec_overwrite_ego(2,j)= vec_temp_ego(2,i+1);
    vec_overwrite_ego(3,j)= vec_temp_ego(3,i+1);
    vec_overwrite_ego(4,j)= vec_temp_ego(4,i); % label long. maneuver change
    vec_overwrite_ego(5,j)= vec_temp_ego(5,i); % label lat. maneuver change
end

% add final maneuver to vec_overwrite_ego with corresponding long. and lat.
% infos
vec_overwrite_ego=[vec_overwrite_ego,[0;0;0;0;0]]; 
duration_temp=sum(vec_overwrite_ego(1,1:end)); % temp variable
vec_overwrite_ego(1,end)= Time(end)-duration_temp;
vec_overwrite_ego(2,end)=Ego.Car.v_pred(end);
vec_overwrite_ego(3,end)= Ego.Lane.DevDist_pred(end);
vec_overwrite_ego(4,end) = long_ego(end,end);
vec_overwrite_ego(5,end) = lat_ego(end,end);

% convert velocities to kmh
vec_overwrite_ego(2,:)=vec_overwrite_ego(2,:)*3.6;

% fill the Ego Part of the Tensor
vec_overwrite_ego(2,:) = round(vec_overwrite_ego (2,:),3); % round for better results in the Resim
vec_overwrite_ego(3,:) = round(vec_overwrite_ego (3,:),1);
Tensor.Ego = vec_overwrite_ego;

%% create the model matrices for the traffic objects
%% Combining the lat. and the long. to create to resulting matrix according to the model for detectable TObj

for index = 1:length(num_TObj)
    if check_detectable(TObj(index).DetectLevel) % check whether TObj is detectable or not
        
        [long_TObj,lat_TObj,TObj_long_pred,TObj_lat_pred, TObj_long_label, Time_Obj, detect_at_start]=create_obj_matrix(prepdata_filename,label,index);
        % 
        TObj(index).Car.vx_pred= TObj_long_pred;
        TObj(index).Lane.tRoad_pred = TObj_lat_pred;
        TObj(index).long_label=TObj_long_label;
        
        % last detection moment of the current TOBj
        max_Time_Obj = Time_Obj(end);
        
        % timestamps of maneuver change for ego
        Time_maneuver_change_obj = unique([long_TObj(1,:), lat_TObj(1,:)]);
        
        Time_state_long_change = Time(find(diff(label.state.TObj(index).long))+1);
        Time_state_lat_change = Time(find(diff(label.state.TObj(index).lat))+1);
        
        % detect the times when a lat. or long. maneuver change or a change in the spatial state relative to Ego  begins to take place
        Time_state_change = unique([Time_state_long_change,Time_state_lat_change]);
        Time_change_obj = unique([Time_maneuver_change_obj, Time_state_change]);
        
        Time_change_obj(Time_change_obj>= max_Time_Obj)=[]; % delete columns with values equal or greater than maxTimeObj
        
        vec_temp_TObj = zeros(8,length(Time_change_obj)); % preallocate temp. array matrix
        
        vec_temp_TObj(1,:) = Time_change_obj;
        
        % round time arrays to avoid errors (sampling time 0.02 s)
        Time_Obj = round(Time_Obj,2);
        Time_change_obj = round(Time_change_obj,2);
        %% continue
        for i=1:length(Time_change_obj)
            vec_temp_TObj(2,i) = TObj(index).Car.vx_pred(Time_Obj==Time_change_obj(i)); % data from prediction
            vec_temp_TObj(3,i) = TObj(index).Lane.tRoad_pred(Time_Obj==Time_change_obj(i)); % data from prediction
            vec_temp_TObj(5,i) = TObj(index).long_label(Time_Obj==Time_change_obj(i)); % data from long. labeling
            vec_temp_TObj(6,i) = label.TObj(index).lat(Time==Time_change_obj(i)); % data from lat. labeling
            vec_temp_TObj(7,i) = label.state.TObj(index).long(Time==Time_change_obj(i)); % data from long state label
            vec_temp_TObj(8,i) = label.state.TObj(index).lat(Time==Time_change_obj(i)); % data from lat state label
        end
        %create the final matrix of the current TObj, which will be used to overwrite the
        %maneuver in the infofile. The matrix is described linewise as follows:
        % 1- Duration of the maneuvereuver
        % 2- target velocity
        % 3- target lateral position
        % 4- average acceleration
        % 5- long. label
        % 6- lat. label
        % 7- long. state label relative to ego
        % 8- lat. state label relative to ego
        
        
        % first column is for the inital conditions
        vec_overwrite_TObj = [];
        vec_overwrite_TObj(:,1)= vec_temp_TObj(:,1);
        
        j=1;
        for i=1:size(vec_temp_TObj,2)-1
            j=j+1;
            vec_overwrite_TObj(1,j) = vec_temp_TObj(1,i+1) - vec_temp_TObj(1,i);% calculate duration between two consecutive maneuver change or state change timestamps
            vec_overwrite_TObj(2,j) = vec_temp_TObj(2,i+1);
            vec_overwrite_TObj(3,j) = vec_temp_TObj(3,i+1); 
            vec_overwrite_TObj(4,j) = (vec_temp_TObj(2,i+1)-vec_temp_TObj(2,i))/(vec_temp_TObj(1,i+1)-vec_temp_TObj(1,i));
            vec_overwrite_TObj(5,j) = vec_temp_TObj(5,i);
            vec_overwrite_TObj(6,j) = vec_temp_TObj(6,i);
            vec_overwrite_TObj(7,j) = vec_temp_TObj(7,i);
            vec_overwrite_TObj(8,j) = vec_temp_TObj(8,i);
            
        end
        
        temp_v=vec_overwrite_TObj(2,end); % temp variable
        
        % add the final maneuver to vec_overwrite_TObj with correspond lat.
        % and long. infos
        vec_overwrite_TObj=[vec_overwrite_TObj,[0;0;0;0;0;0;0;0]];
        duration_temp=sum(vec_overwrite_TObj(1,1:end));
        
        vec_overwrite_TObj(1,end)= Time_Obj(end) - duration_temp;% add duration of last maneuver
        t_end = vec_overwrite_TObj(1,end);
        vec_overwrite_TObj(2,end) = TObj(index).Car.vx_pred(end);
        vec_overwrite_TObj(3,end) = TObj(index).Lane.tRoad_pred(end);
        vec_overwrite_TObj(4,end) = (TObj(index).Car.vx_pred(end)-temp_v)/t_end; % add the value of avg acc in the last maneuver
        vec_overwrite_TObj(5,end) = long_TObj(end,end);
        vec_overwrite_TObj(6,end) = lat_TObj(end,end);
        vec_overwrite_TObj(7,end) = label.state.TObj(index).long(Time==Time_Obj(end));
        vec_overwrite_TObj(8,end) = label.state.TObj(index).lat(Time==Time_Obj(end));
        
        % convert velocities to kmh
        vec_overwrite_TObj(2,:)=vec_overwrite_TObj(2,:)*3.6;
        vec_overwrite_TObj(2:end,:) = round(vec_overwrite_TObj (2:end,:),3);% round 
        
        % fill the Tensor struct with the matrix of the current TObj
        Tensor.TObj(index).data = vec_overwrite_TObj;
        Tensor.TObj(index).detect_at_start= detect_at_start;
        if detect_at_start == 0
            
            % in case the current TObj is not detectable at start, we
            % calculate the s.Road and t.Road values at the time where it is first detected 
            Tensor.TObj(index).sRoad_init = TObj(index).sRoad(Time==Time_Obj(1));
            Tensor.TObj(index).tRoad_init = TObj(1).Lane.tRoad(Time==Time_Obj(1));
        else
            Tensor.TObj(index).sRoad_init = [];
            Tensor.TObj(index).tRoad_init = [];
            
        end
    else
        Tensor.TObj(index).data=[];
    end
    vec_overwrite_TObj=[]; % preallocate again for the next iteration
end

% tensor struct contains num_Tobj and the time array of the whole
% simulation
Tensor.num_TObj = num_TObj;
Tensor.Time = Time;

end

