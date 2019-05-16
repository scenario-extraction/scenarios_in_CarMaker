% creates the tensors based on the data from resimulation
% the output tensors contain data only from GT
% provide the final plot by adding plot of the resimulation's GT data
% see documentation for the function create_tensor.m


%%
function [tensor_CM, tensor_model]=create_tensor_resim(prepdata_filename,label_data, ind_TR)

global flag_resim;

% preallocate the two output tensors
tensor_CM=[];
tensor_model =[];

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

% test plot


%% create the matrix describing the long. motion of ego during the scenario

% preallocate arr. containing the long. labeling
label_ego_long =[];

Time_thr = 1.0; % must be greater than Gear shifting duration!

% call build_long_matrix func for Ego
long_ego = build_long_matrix(Ego.Car.ax, Ego.Car.vx, Time, Ego.sRoad, Time_thr);

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

lat_ego =[];
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


% load figure from first simulation and plot Ego resimulation GT data

openfig('Ego_plot.fig','new'); 
hold on;
subplot(2,1,1)
plot(Ego.Car.vx.*3.6,'Color',[0 0 0]);
legend('prediction','first simulation GT','resimulation GT');
title(strcat('Ego long. speed for Testrun ',num2str(ind_TR)));

subplot(2,1,2)
plot(Ego.Lane.DevDist,'Color',[0 0 0]);
legend('prediction','first simulation GT','resimulation GT');
title(strcat('Ego lat. pos for Testrun ',num2str(ind_TR)));
hold off;

savefig( 'Ego_plot.fig');

%% Combining the lat. and the long. to create to resulting matrix according to the model for Ego

% timestamps of maneuvereuver change for ego
Time_change_ego = unique([long_ego(1,:), lat_ego(1,:)]);

% create temporary array to store above timestamps and needed data for
% velocity and lat. position according to the model: this temporary array
% represents the tensor matrix as described in the model

vec_temp_ego(1,:) = Time_change_ego;

for i=1:length(Time_change_ego)
    
    vec_temp_ego(2,i)= Ego.Car.vx(Time==Time_change_ego(i)); 
    
    vec_temp_ego(3,i)= Ego.Lane.DevDist(Time==Time_change_ego(i)); 
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
vec_overwrite_ego(2,end)=Ego.Car.vx(end);
vec_overwrite_ego(3,end)= Ego.Lane.DevDist(end);
vec_overwrite_ego(4,end) = long_ego(end,end);
vec_overwrite_ego(5,end) = lat_ego(end,end);

% convert velocities to kmh
vec_overwrite_ego(2,:)=vec_overwrite_ego(2,:)*3.6;

% fill the Ego Part of the Tensor
% vec_overwrite_ego(2,:) = round(vec_overwrite_ego (2,:),3); % round for better results in the Resim
% vec_overwrite_ego(3,:) = round(vec_overwrite_ego (3,:),1);
tensor_CM.Ego = vec_overwrite_ego;

%% create the model matrices for the traffic objects
%% Combining the lat. and the long. to create to resulting matrix according to the model for detectable TObj

% array containung timesteps referring to maneuver or spatial state change
% for all TObjs and ego, preallocate with time of ego maneuvers change
time_change_allTObj_ego =Time_change_ego;

for index = 1:length(num_TObj)
    if check_detectable(TObj(index).DetectLevel) % check whether TObj is detectable or not
        
        [long_TObj,lat_TObj,~,~, TObj_long_label] = create_obj_matrix(prepdata_filename,label,index, flag_resim);
        %
        
        % extend the long_label for TObj with unknown when TObj not detectable
        for i=1:length(TObj_long_label)
            if length(label.TObj(index).lat)==length(TObj_long_label) % get information from lat labeling done within labeling.m function
                if label.TObj(index).lat(i) ==-9 % get labeling from struct and add unknown labeling to TObj_long_label
                    TObj_long_label(i) = -9;
                end
            end
        end
        
        % timestamps of maneuver change for ego
        Time_maneuver_change_obj = unique([long_TObj(1,:), lat_TObj(1,:)]);
        
        Time_state_long_change = Time(find(diff(label.state.TObj(index).long))+1);
        Time_state_lat_change = Time(find(diff(label.state.TObj(index).lat))+1);
        
        % detect the times when a lat. or long. maneuver change or a change in the spatial state relative to Ego  begins to take place
        Time_state_change = unique([Time_state_long_change,Time_state_lat_change]);
        Time_change_obj = unique([Time_maneuver_change_obj, Time_state_change]);
        
        
        vec_temp_TObj = zeros(10,length(Time_change_obj)); % preallocate temp. array matrix
        
        vec_temp_TObj(1,:) = Time_change_obj;
        
        % round time arrays to avoid errors (sampling time 0.02 s)
        Time = round(Time,2);
        Time_change_obj = round(Time_change_obj,2);
        
        for i=1:length(Time_change_obj)
            vec_temp_TObj(2,i) = TObj(index).Car.vx(Time==Time_change_obj(i)); %
            vec_temp_TObj(3,i) = TObj(index).Lane.tRoad(Time==Time_change_obj(i)); %
            vec_temp_TObj(5,i) = TObj_long_label(Time==Time_change_obj(i)); % data from long. labeling
            vec_temp_TObj(6,i) = label.TObj(index).lat(Time==Time_change_obj(i)); % data from lat. labeling
            vec_temp_TObj(7,i) = label.state.TObj(index).long(Time==Time_change_obj(i)); % data from long state label
            vec_temp_TObj(8,i) = label.state.TObj(index).lat(Time==Time_change_obj(i)); % data from lat state label
            
            % to make a more plausible and realistic reconstruction of the
            % maneuvers of TO, GT data are taken within the non-detection
            % time intervals of the corresponding TObj
            if ismember(-99,vec_temp_TObj(:,i))
                vec_temp_TObj(2,i) = TObj(index).Car.vx(Time==Time_change_obj(i));
                vec_temp_TObj(3,i) = TObj(index).Lane.tRoad(Time==Time_change_obj(i));
            end
            
        end
        %create the final matrix of the current TObj, which will be used to overwrite the
        %maneuver in the infofile in CM. The matrix is described linewise as follows:
        % 1- Duration of the maneuvereuver
        % 2- target velocity
        % 3- target lateral position
        % 4- average acceleration
        % 5- long. label
        % 6- lat. label
        % 7- long. state label relative to ego
        % 8- lat. state label relative to ego
        % 9- long. position relative to ego
        %10- lat. position relative to ego
        
        
        % store the new Tobj in the matrix tensor_model_TObj
        time_change_allTObj_ego =unique([time_change_allTObj_ego,Time_change_obj]);
        
        tensor_model.TObj(index).data = vec_temp_TObj;
        
        % always round to override errors caused by approximation
        time_change_allTObj_ego = round(time_change_allTObj_ego,2);
        
        
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
        
        %% add the final maneuver to vec_overwrite_TObj with correspond lat. and long. infos
        vec_overwrite_TObj=[vec_overwrite_TObj,zeros(10,1)];
        duration_temp=sum(vec_overwrite_TObj(1,1:end));
        
        vec_overwrite_TObj(1,end)= Time(end) - duration_temp;% add duration of last maneuver
        t_end = vec_overwrite_TObj(1,end);
        vec_overwrite_TObj(2,end) = TObj(index).Car.vx(end);
        vec_overwrite_TObj(3,end) = TObj(index).Lane.tRoad(end);
        vec_overwrite_TObj(4,end) = (TObj(index).Car.vx(end)-temp_v)/t_end; % add the value of avg acc in the last maneuver
        vec_overwrite_TObj(5,end) = long_TObj(end,end);
        vec_overwrite_TObj(6,end) = lat_TObj(end,end);
        vec_overwrite_TObj(7,end) = label.state.TObj(index).long(Time==Time(end));
        vec_overwrite_TObj(8,end) = label.state.TObj(index).lat(Time==Time(end));
        
        % add relative distance to ego in terms of s.Road and t.road of TObj
        for i=2:size(vec_overwrite_TObj,2)
            
            time_step_temp =round( sum (vec_overwrite_TObj(1,1:i-1)),2); % temp variable to store the time
            vec_overwrite_TObj(9,i) = TObj(index).sRoad(Time==time_step_temp)- Ego.sRoad(Time==time_step_temp) ;
            vec_overwrite_TObj(10,i) =  TObj(index).Lane.tRoad(Time==time_step_temp)-Ego.Lane.DevDist(Time==time_step_temp);
        end
        
        % convert velocities to kmh
        vec_overwrite_TObj(2,:)=vec_overwrite_TObj(2,:)*3.6;
        
        % round time duration and fill the Tensor struct with the matrix of TObj
        vec_overwrite_TObj(1,:) = round(vec_overwrite_TObj(1,:),2);
        tensor_CM.TObj(index).data = vec_overwrite_TObj;
        
    else
        tensor_CM.TObj(index).data=[];
        tensor_model.TObj(index).data=[];
    end
    vec_overwrite_TObj=[]; % preallocate again for the next iteration
end

% tensor struct contains num_Tobj and the time array of the whole
% simulation
tensor_CM.num_TObj = num_TObj;
tensor_CM.Time = Time;


% make all TObjs matrices have the same dimensions according to the the
% definition of the theoretical tensor
for h=1:length(tensor_model.TObj)
    if ~isempty(tensor_model.TObj(h).data)
        
        % convert speed to kmh
        tensor_model.TObj(h).data(2,:) = tensor_model.TObj(h).data(2,:)*3.6;
        
        for i=1:length(time_change_allTObj_ego)
            if ~ismember(time_change_allTObj_ego(i),tensor_model.TObj(h).data(1,:))
                
                tensor_model.TObj(h).data = [tensor_model.TObj(h).data, [time_change_allTObj_ego(i);-9999*ones(9,1)]];
            end
            
        end
        % permute columns of the matrix according to sorted time steps
        tensor_model.TObj(h).data = permute_sorted_col(tensor_model.TObj(h).data);
    end
end


% make ego matrix have the same dimensions as TObj matrices
tensor_model.Ego = [vec_temp_ego; -9999*ones(5,size(vec_temp_ego,2))];

% convert speed to kmh
tensor_model.Ego(2,:) = tensor_model.Ego(2,:) *3.6;

for i=1:length(time_change_allTObj_ego)
    if ~ismember(time_change_allTObj_ego(i),tensor_model.Ego(1,:))
        
        tensor_model.Ego =  [tensor_model.Ego,[time_change_allTObj_ego(i);-9999*ones(9,1)]];
    end
end

% permute columns of the matrix according to sorted time steps
tensor_model.Ego = permute_sorted_col(tensor_model.Ego);

% func end
end


%  subfunction
% permute matrix columns according to indexing vector
function newB = permute_sorted_col(B)

[~, a_order] = sort(B(1,:));
newB = B(:,a_order);
end
