% this function creates two tensors und returns a total number:
%1- a tensor for CM simulation, which describes the driving scenario in
% terms of elementar longitudinal and lateral maneuvers; for lateral: lane Keeping, right Lane
% Change, left Lane change. For longitudinal: acceleration,
%deceleration and static cruising. The tensor contains matrices respectively for Ego
%vehicle and for the other detectable movable Traffic Objects (in this case
%vehicles). The main tasks of this function are mentioned in the Header of
%the different sections of this script
% 2- a tensor according to the theoretical
% model
%3- the total number of the relevant detectable TObjs (Traffic Objects):
%this number ist given based on the detection, e.g If the detection of a TObj
%takes place over 2 separate Time intervalls, the considered TObj will be
%considered as 2 independant TObjs respectively a TObj for each detection's phase.


%%
function [tensor_CM, tensor_model,ind_TObj_new]=create_tensor(prepdata_filename,label_data)

% preallocate the two output tensors
tensor_CM=struct;
tensor_model =struct;

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

%% create the matrix describing the long. motion of ego during the scenario
% this matrix is used later as input for the long. velocity prediction model

% preallocate arr. containing the long. labeling
label_ego_long =[];

% call build_long_matrix func for Ego
long_ego = build_long_matrix(Ego.Car.ax, Ego.Car.vx, Time, Ego.sRoad);

% predict velocity from the matrix long_ego
Ego.Car.vx_pred=velocity_pred_new(long_ego);

% correct the long. labeling for Ego
for ind=1:size(long_ego,2)
    ind_start = find(Time==long_ego(1,ind));
    if ind==size(long_ego,2)
        ind_end = length(Time);
    else
        ind_end = find(Time==long_ego(1,ind+1))-1;
    end
    label_ego_long(ind_start:ind_end)= long_ego(end,ind); % 6. row in the matrix long_ego contains the long. labeling
end

%% create the matrix describing the lateral motion of the ego with the data from lateral labeling done witin the function labeling.m
%this matrix is used later as input for the lat. position prediction model

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
        
        
    elseif label.ego.lat(j)==1 % if RLC
        
        while  j<length(Time) && label.ego.lat(j)==1
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_ego(:,m)=[Time(k);Time(j)-Time(k);Ego.Lane.DevDist(j);1];
        
    elseif label.ego.lat(j)==-1 % if LLC
        
        while  j<length(Time) && label.ego.lat(j)==-1
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_ego(:,m)=[Time(k);Time(j)-Time(k);Ego.Lane.DevDist(j);-1];
    else %
        
    end
end

% predict the lateral position profile from the matrix lat_ego
Ego.Lane.DevDist_pred = lat_pos_pred(lat_ego);

%% plot lane change for Ego and calculate MAPE
% get
p=0;
data_Ego=[];
data_Ego_pred=[];
for i=1:length(Time)
    if abs(label.ego.lat (i))==1
        
        data_Ego_pred = [data_Ego_pred,Ego.Lane.DevDist_pred(i)];
        data_Ego = [data_Ego,Ego.Lane.DevDist(i)];
    end
end

% Calculate MAPE fpr lane change
Ego.MAPE.LC = calc_MAPE(data_Ego,data_Ego_pred);

% Plot the lane Change profiles in terms of lateral position
for i=1:size(lat_ego,2)
    if abs(lat_ego(end,i))==1
        fig_start=find(Time==lat_ego(1,i));
        fig_end = find(Time==lat_ego(1,i)+lat_ego(2,i));
        figure(10+i);
        plot(Time(fig_start:fig_end),Ego.Lane.DevDist(fig_start:fig_end),'r',Time(fig_start:fig_end),Ego.Lane.DevDist_pred(fig_start:fig_end),'b--');
        p=p+1;
    end
end

%% plot velocity for acc and dec for Ego and calculate MAPE

p=0;
% acc
data_Ego=[];
data_Ego_pred=[];
for i=1:length(Time)
    if (label_ego_long (i))==1
        data_Ego_pred = [data_Ego_pred,Ego.Car.vx_pred(i)];
        data_Ego = [data_Ego,Ego.Car.vx(i)];
    end
end

%Calculate MAPE for acc
Ego.MAPE.acc = calc_MAPE(data_Ego,data_Ego_pred);

% dec
data_Ego=[];
data_Ego_pred=[];
for i=1:length(Time)
    if (label_ego_long (i))==-1
        data_Ego_pred = [data_Ego_pred,Ego.Car.vx_pred(i)];
        data_Ego = [data_Ego,Ego.Car.vx(i)];
    end
end

%Calculate MAPE for dec
Ego.MAPE.dec = calc_MAPE(data_Ego,data_Ego_pred);

for i=1:size(long_ego,2)
    if abs(long_ego(end,i))==1
        fig_start=find(Time==long_ego(1,i));
        fig_end = find(Time==(long_ego(1,i)+long_ego(4,i)));
        figure(20*i);
        plot(Time(fig_start:fig_end),Ego.Car.vx(fig_start:fig_end)*3.6,'r',Time(fig_start:fig_end),Ego.Car.vx_pred(fig_start:fig_end)*3.6,'b--');
        p=p+1;
    end
end
%% plot and save figures of velocity and lateral position for Ego

figure;
subplot(2,1,1)
plot(Time,Ego.Car.vx_pred.*3.6,'b--'); hold on;
plot(Time,Ego.Car.vx.*3.6,'r');
xlabel('time');
ylabel('velocity [km/h]');

subplot(2,1,2)
plot(Time,Ego.Lane.DevDist_pred,'b--');
hold on
plot(Time,Ego.Lane.DevDist,'r');
xlabel('time');
ylabel('lat. pos [m]');

savefig('Ego_plot.fig');

%% Assign v_pred:
Ego.Car.v_pred = Ego.Car.vx_pred;
%% Combining the lat. and the long. to create to resulting matrix according to the model for Ego

% timestamps of maneuvereuver change for ego
Time_change_ego = unique([long_ego(1,:), lat_ego(1,:)]);

% create temporary array to store above timestamps and needed data for
% velocity and lat. position according to the model: this temporary array
% represents the tensor matrix as described in the model

vec_temp_ego(1,:) = Time_change_ego;

for i=1:length(Time_change_ego)
    
    vec_temp_ego(2,i)= Ego.Car.v_pred(Time==Time_change_ego(i)); % long. velo data from predictIon
    vec_temp_ego(6,i)= Ego.Lane.DevDist_pred(Time==Time_change_ego(i)); % abs. lateral start position from prediction
    vec_temp_ego(5,i)= Ego.sRoad(Time==Time_change_ego(i));
    vec_temp_ego(8,i) = label_ego_long(Time==Time_change_ego(i)); % data from long. labeling correction
    vec_temp_ego(9,i) = label.ego.lat(Time==Time_change_ego(i)); % data from data struct from labeling.m function
end

% temp. var last element of
sRoad_ego_temp =   vec_temp_ego(5,end);

%add duration 6. row
dur_temp_ego = diff(vec_temp_ego(1,:));
vec_temp_ego(4,1:end-1) = dur_temp_ego;

% add duration of the last maneuver or the last state change
vec_temp_ego(4,end) = Time(end)- vec_temp_ego(1,end);

% add target velocity and target lat. pos
for i=1:size(vec_temp_ego,2)-1
    vec_temp_ego(3,i) = vec_temp_ego(2,i+1) ;
    vec_temp_ego(7,i) = vec_temp_ego(6,i+1) ;
    
end
% add target values for the last column
vec_temp_ego(3,end) = Ego.Car.v_pred(end); %
vec_temp_ego(7,end) = Ego.Lane.DevDist_pred(end); %

% add performed long. displacmeent
disp_temp_ego = diff(vec_temp_ego(5,:));
vec_temp_ego(5,1:end-1) = disp_temp_ego;

% add last performed long. displacement
vec_temp_ego(5,end) = Ego.sRoad(end)- sRoad_ego_temp;

%convert velocities to kmh
vec_temp_ego(2:3,:) = vec_temp_ego(2:3,:)*3.6;

% round lat. pos
vec_temp_ego(6:7,:)= round(vec_temp_ego(6:7,:),5);

% define the CM tensor for ego & assign
tensor_CM.Ego = vec_temp_ego;

%% create the model matrices for the traffic objects
%% Combining the lat. and the long. to create to resulting matrix according to the model for detectable TObj

% array containung timesteps referring to maneuver or spatial state change
% for all TObjs and ego, preallocate with time of ego maneuvers change
time_change_allTObj_ego =round(Time_change_ego,2);

% preallocate
Time_change_obj=[];
p=0;
TObj_detec=[];

if ~isempty(TObj)
    for index = 1:length(num_TObj)
        % check whether TObj is detectable or not
        if check_detectable(TObj(index).DetectLevel)
            % array with the indexes of detec. TObjs
            TObj_detec =[TObj_detec,index];
            [long_TObj,lat_TObj,TObj_long_pred,TObj_lat_pred, TObj_long_label] = create_obj_matrix(prepdata_filename,label,index);
            
            %% goodness of prediction model for velocity for TObj
            % acc
            data_TObj=[];
            data_TObj_pred=[];
            for i=1:length(Time)
                if (TObj_long_label (i))==1
                    data_TObj = [data_TObj,TObj(index).Car.vx(i)];
                    data_TObj_pred = [data_TObj_pred,TObj_long_pred(i)];
                end
            end
            if ~isempty(data_TObj) && ~isempty(data_TObj_pred)
                TObj(index).MAPE.acc = calc_MAPE(data_TObj,data_TObj_pred);
            end
            
            % dec
            data_TObj=[];
            data_TObj_pred=[];
            for i=1:length(Time)
                if TObj_long_label (i)==-1
                    data_TObj = [data_TObj,TObj(index).Car.vx(i)];
                    data_TObj_pred = [data_TObj_pred,TObj_long_pred(i)];
                end
            end
            if ~isempty(data_TObj) && ~isempty(data_TObj_pred)
                TObj(index).MAPE.dec = calc_MAPE(data_TObj,data_TObj_pred);
            end
            %% goodness of prediction model for lateral pos for TObj
            data_TObj=[];
            data_TObj_pred=[];
            for i=1:length(Time)
                if abs(label.TObj(index).lat(i))==1
                    
                    data_TObj = [data_TObj,TObj(index).Lane.t2Ref(i)];
                    data_TObj_pred = [data_TObj_pred,TObj_lat_pred(i)];
                end
            end
            if ~isempty(data_TObj) && ~isempty(data_TObj_pred)
                TObj(index).MAPE.LC= calc_MAPE(data_TObj,data_TObj_pred);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%
            % Plots for TOBj
            for i=1:size(long_TObj,2)
                if abs(long_TObj(end,i))==1
                    fig_start=find(Time==long_TObj(1,i));
                    
                    fig_end_time=round(long_TObj(1,i)+long_TObj(4,i),2);
                    fig_end = find(Time==fig_end_time);
                    figure;
                    plot(Time(fig_start:fig_end),TObj(index).Car.vx(fig_start:fig_end),'r',Time(fig_start:fig_end),TObj_long_pred(fig_start:fig_end),'b--');
                    p=p+1;
                    
                    
                end
            end
            
            %reallocate plot index
            p=0;
            %% goodness of prediction model for lateral pos for TObj
            lat_TObj(1,:)=round(lat_TObj(1,:),2);
            for i=1:size(lat_TObj,2)
                
                if abs(lat_TObj(end,i))==1
                    fig_start=find(Time==lat_TObj(1,i));
                    
                    fig_end_time=round(lat_TObj(1,i)+lat_TObj(2,i),2);
                    fig_end = find(Time==fig_end_time);
                    
                    figure(index*1000+i);
                    
                    plot(Time(fig_start:fig_end),TObj(index).Lane.t2Ref(fig_start:fig_end),'r',Time(fig_start:fig_end),TObj_lat_pred(fig_start:fig_end),'b--');
                    p=p+1;
                    
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            %%
            
            % timestamps of maneuver change for ego
            Time_maneuver_change_obj = unique([long_TObj(1,:), lat_TObj(1,:)]);
            Time_state_long_change = Time(find(diff(label.state.TObj(index).long))+1);
            Time_state_lat_change = Time(find(diff(label.state.TObj(index).lat))+1);
            
            % detect the times when a lat. or long. maneuver change or a change in the spatial state relative to Ego  begins to take place
            Time_state_change = unique([Time_state_long_change,Time_state_lat_change]);
            Time_change_obj = unique(round([Time_maneuver_change_obj, Time_state_change],2));
            
            % preallocate temp. array matrix
            vec_temp_TObj = zeros(13,length(Time_change_obj));
            displ_vector = [];
            
            % timestamps corresponding to state or maneuver change
            vec_temp_TObj(1,:) = Time_change_obj;
            
            % round time arrays to avoid errors (sampling time 0.02 s)
            Time = round(Time,2);
            Time_change_obj = round(Time_change_obj,2);
            
            for i=1:length(Time_change_obj)
                vec_temp_TObj(2,i) = TObj_long_pred(Time==Time_change_obj(i)); % velocity data from prediction
                vec_temp_TObj(6,i) = TObj_lat_pred(Time==Time_change_obj(i)); % absolute lat. pos data from prediction
                vec_temp_TObj(8,i) = round(TObj(index).Sensor.dx(Time==Time_change_obj(i)),4)+Ego.sRoad(Time==Time_change_obj(i)); % S position based on measured relative long. distance
                vec_temp_TObj(9,i) = round(TObj(index).Sensor.dy(Time==Time_change_obj(i)),4);% measured relative lat. spacing
                vec_temp_TObj(10,i) = TObj_long_label(find(Time==Time_change_obj(i))); % data from long. labeling
                vec_temp_TObj(11,i) = label.TObj(index).lat(find(Time==Time_change_obj(i))); % data from lat. labeling
                vec_temp_TObj(12,i) = label.state.TObj(index).long(Time==Time_change_obj(i)); % data from lat state label
                vec_temp_TObj(13,i) = label.state.TObj(index).lat(Time==Time_change_obj(i)); % data from lat state label
                displ_vector = [displ_vector,TObj(index).sRoad(Time==Time_change_obj(i))];
            end
            % add target velocity and target lat. pos respectively in 3.th and 5.th  row in vec_temp_TObj
            for i=1:size(vec_temp_TObj,2)-1
                vec_temp_TObj(3,i) = vec_temp_TObj(2,i+1) ;
                vec_temp_TObj(7,i) = vec_temp_TObj(6,i+1) ;
                
            end
            % add target values for the last column
            vec_temp_TObj(3,end) = TObj_long_pred(end); % or ...(end)
            vec_temp_TObj(7,end) = TObj_lat_pred(end); % or ...(end)
            
            %% concatenate columns with non relevant labeling -99
            j_ind=1;
            ind_to_delete=[];
            
            while j_ind<= size(vec_temp_TObj,2)
                
                if j_ind<= size(vec_temp_TObj,2)&&(vec_temp_TObj(12,j_ind)==-99)
                    while j_ind<size(vec_temp_TObj,2) && vec_temp_TObj(12,j_ind)==-99 && vec_temp_TObj(12,j_ind+1)==-99
                        
                        ind_to_delete = [ind_to_delete,j_ind];
                        j_ind=j_ind+1;
                    end
                    % assign
                    if ~isempty(ind_to_delete)
                        vec_temp_TObj(:,ind_to_delete)=[];
                        displ_vector(:,ind_to_delete)=[];
                        j_ind=0;
                        ind_to_delete =[];
                    end
                end
                j_ind=j_ind+1;
            end
            
            %create the final matrix of the current TObj, which will be used to overwrite the
            %maneuver in the infofile in CM. The matrix is described linewise as follows:
            % 1- timestamp of the beginning of the maneuver or state
            % 2- start velocity
            % 3- target velocity
            % 4- duration of the maneuver or state
            % 5- performed distance
            % 6- start lateral position
            % 7- target lateral position
            % 8- measured relative long. distance
            % 9- measured relative lat. distance
            % 10- label long. maneuver
            % 11- label lat. maneuver
            % 12- label long. state
            % 13- label lat. state
            
            
            %-----------------
            % add displacement for every maneuver column
            
            %vec_temp_TObj = [vec_temp_TObj ; zeros(2,size(vec_temp_TObj,2))];
            if ismember(-99, vec_temp_TObj(:,1))
                vec_temp_TObj(5,1) = 0;
            end
            disp_temp = diff(displ_vector);
            
            vec_temp_TObj(5,1:end-1) = disp_temp;
            
            % add last performed displacement if detectable
            if  ~ismember(-99, vec_temp_TObj(:,end))
                
                vec_temp_TObj(5,end) = TObj(index).sRoad(end)- displ_vector(end);
            end
            
            % add maneuver duration
            dur_temp = diff(vec_temp_TObj(1,:));
            vec_temp_TObj(4,1:end-1) = dur_temp;
            
            % add duration of the last maneuver or the last state change
            vec_temp_TObj(4,end) = Time(end)- vec_temp_TObj(1,end);
            
            % convert speed to kmh
            vec_temp_TObj(2:3,:) = vec_temp_TObj(2:3,:)*3.6;
            
            
            %----------------------------------
            
            %% Split in detectable parts
            % index arrays for non detectable parts
            ind_undetec10=find(vec_temp_TObj(10,:)==-9);
            ind_undete11=find(vec_temp_TObj(11,:)==-9);
            ind_undetec12 = find(vec_temp_TObj(12,:)==-99);
            ind_undetec13 = find(vec_temp_TObj(13,:)==-99);
            ind_undetec = unique([ind_undetec12,ind_undetec13]);
            
            % post process the array of indexes
            if ~ismember(1,ind_undetec)
                ind_undetec = [0,ind_undetec];
            end
            if ~ismember(size(vec_temp_TObj,2),ind_undetec)
                ind_undetec = [ind_undetec,size(vec_temp_TObj,2)+1];
            end
            
            % split long. TObj into detectable intervals
            if ~isempty(ind_undetec)
                for k=1:length(ind_undetec)-1
                    TObj(index).TObj_DetectPart(k).data = vec_temp_TObj(:,ind_undetec(k)+1:ind_undetec(k+1)-1);
                end
            end
            
            % store matrix describing the dynamik of the TObj in the struct
            TObj(index).vec_temp = vec_temp_TObj;
            
            % add array of timestamps corresponding to maneuver and state change
            % for TObj
            time_change_allTObj_ego = round(unique([time_change_allTObj_ego,Time_change_obj]),2);
            
        end
    end
    
end

%% create a new struct with the new defined Objcts TObj_new based of the detection over different Time Phases

% number of the detectable TObj
ind_TObj_new =length(TObj_detec);

% preallocate TObj_new
TObj_new =[];

% add the new Objects (a new Object is defined pro additional detection process)
for i=1:length(TObj_detec)
    index_temp = TObj_detec(i);
    for j=1:numel(TObj(index_temp).TObj_DetectPart)
        if j==1
            TObj_new(i).matrix_model.data= TObj(index_temp).TObj_DetectPart(j).data;
        else
            % increment the number of the TObj as soon as an additional
            % detection takes place.
            ind_TObj_new = ind_TObj_new+1;
            TObj_new(ind_TObj_new).matrix_model.data= TObj(index_temp).TObj_DetectPart(j).data;
        end
    end
end

%% build the Tensor

% close all

% round time_change_allTObj_ego
time_change_allTObj_ego = round(unique([time_change_allTObj_ego,Time_change_obj]),2);

% make all TObjs matrices have the same dimensions according to the the
% definition of the theoretical tensor
for h=1:ind_TObj_new
    if ~isempty(TObj_new(h).matrix_model)
        
        % fill the struct tensor_CM for TObj
        tensor_CM.TObj(h).data=TObj_new(h).matrix_model.data;
        % preallocate
        tensor_model.Tobj(h).data = TObj_new(h).matrix_model.data;
        % round time array
        tensor_model.Tobj(h).data(1,:)= round(tensor_model.Tobj(h).data(1,:),2) ;
        
        for i=1:length(time_change_allTObj_ego)
            if ~ismember(time_change_allTObj_ego(i),round(tensor_model.Tobj(h).data(1,:),2))
                
                tensor_model.Tobj(h).data = [tensor_model.Tobj(h).data, [time_change_allTObj_ego(i);-9999*ones(12,1)]];
            end
            
            tensor_model.Tobj(h).data(1,:)= round(tensor_model.Tobj(h).data(1,:),2);
            temp_matrix = unique(transpose(tensor_model.Tobj(h).data),'rows','stable');
            tensor_model.Tobj(h).data = transpose(temp_matrix);
        end
        % permute columns of the matrix according to sorted time steps
        tensor_model.Tobj(h).data = permute_sorted_col(tensor_model.Tobj(h).data);
        
    end
end

% add number of detectable TObj in the struct of tensor_CM
tensor_CM.numOfTobj=ind_TObj_new;

% make ego matrix have the same dimensions as TObj matrices (Tensor pages must have the same dimension)
tensor_model.Ego = [vec_temp_ego; -9999*ones(4,size(vec_temp_ego,2))];

% round time to avoid error
tensor_model.Ego(1,:) = round(tensor_model.Ego(1,:),2);

% permute rows of maneuver labeling and due to the order of
% the metaparameter in the tensor
tensor_model.Ego(10:11,:) = tensor_model.Ego(8:9,:);
tensor_model.Ego (8:9,:) = -9999*ones(2,size(tensor_model.Ego,2));

% unify the dimension for ego
for i=1:length(time_change_allTObj_ego)
    if ~ismember(time_change_allTObj_ego(i),tensor_model.Ego(1,:))
        tensor_model.Ego = [tensor_model.Ego,[time_change_allTObj_ego(i);-9999*ones(12,1)]];
    end
end

% rearrange the columns of the ego matrix according to the sorted time steps
tensor_model.Ego = permute_sorted_col(tensor_model.Ego);

%% save changes to Tobj struct
prepdata_filename= 'prepdata.mat';
save(prepdata_filename);

% func end
end
