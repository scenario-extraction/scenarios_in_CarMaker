% this function creates two tensors:
%1- a tensor for CM simulation, which describes the driving scenario in
% terms of elementar longitudinal and lateral maneuvers for lateral: lane Keeping, Lane
% Change right, Lane change left. For longitudinal: acceleration,
%deceleration and static cruising. The tensor contains matrices respectively for Ego
%vehicle and for the other detectable movable Traffic Objects (in this case
%vehicles). The main tasks of this function are mentioned in the Header of
%the different sections of this script
% 2- a tensor according to the theoretical
% model

%--- Abbreviations:
%LK: lane keeping
%LCR: lane change right
%LCL: lane change left
%acc: acceleration
%dec: deceleration
%arr: array
%TOBj: traffic object
%GT: Ground Truth

%%
function [tensor_CM, tensor_model]=create_tensor(prepdata_filename,label_data)

global flag_resim;

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

Time_thr = 1; % must be greater than Gear shifting duration!

% call build_long_matrix func for Ego
long_ego = build_long_matrix(Ego.Car.ax, Ego.Car.vx, Time, Ego.sRoad, Time_thr);

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

% predict the lateral position profile
Ego.Lane.DevDist_pred = lat_pos_pred(lat_ego);

%% plot and save figure
figure;
subplot(2,1,1)
plot(Ego.Car.vx_pred.*3.6,'b--'); hold on;
plot(Ego.Car.vx.*3.6,'r');
xlabel('timestamps');
ylabel('velocity [km/h]');

subplot(2,1,2)
plot(Ego.Lane.DevDist_pred,'b--');
hold on
plot(Ego.Lane.DevDist,'r');
xlabel('timestamps');
ylabel('lat. pos [m]');

savefig('Ego_plot.fig');
%% predict Car.v quantity for CM
% CM does not treat the maneuver definition in terms of long. and lat.dynamics
%separately and does not offer needed model-related quantites in the GUI.
% For example the GUI offers the quantity Car.v as the only quantity for long. dynamics.
%the first problem is overriden by the defition of the model, which take in account the overlapping parts in time axis between the lateral and long. maneuvereuvers.
% In order to override the second problem we predict Car.v from predicted longitudinal velocity and predicted lateral displacement

% derive the lat. velocity as described in CM Reference's Guide
Ego.Lane.vy_pred=diff(Ego.Lane.DevDist_pred)./diff(Time);
Ego.Lane.vy_pred=[Ego.Lane.vy_pred,Ego.Lane.vy_pred(end)];

% calculate predicted Car.v=sqrt(v_x^2+v_y^2)
Ego.Car.v_pred=sqrt((Ego.Lane.vy_pred).^2+(Ego.Car.vx_pred).^2);
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
% temp variable
duration_temp=sum(vec_overwrite_ego(1,1:end));

vec_overwrite_ego(1,end)= Time(end)-duration_temp;
vec_overwrite_ego(2,end)=Ego.Car.v_pred(end);
vec_overwrite_ego(3,end)= Ego.Lane.DevDist_pred(end);
vec_overwrite_ego(4,end) = long_ego(end,end);
vec_overwrite_ego(5,end) = lat_ego(end,end);

% convert velocities to kmh
vec_overwrite_ego(2,:)=vec_overwrite_ego(2,:)*3.6;

% fill the Ego Part of the Tensor
vec_overwrite_ego(2,:) = round(vec_overwrite_ego (2,:),2); % round for better results in the Resim
vec_overwrite_ego(3,:) = round(vec_overwrite_ego (3,:),3);
%
tensor_CM.Ego = vec_overwrite_ego;

%% create the model matrices for the traffic objects
%% Combining the lat. and the long. to create to resulting matrix according to the model for detectable TObj

% array containung timesteps referring to maneuver or spatial state change
% for all TObjs and ego, preallocate with time of ego maneuvers change
time_change_allTObj_ego =round(Time_change_ego,2);

% define index of number of TObject including new defined Ojects for every
% detectable part
num_obj=0;
num_detecTObj =0;
if ~isempty(TObj)
    for index = 1:length(num_TObj)
        % check whether TObj is detectable or not
        if check_detectable(TObj(index).DetectLevel)
            num_detecTObj = num_detecTObj+1;
            [long_TObj,lat_TObj,TObj_long_pred,TObj_lat_pred, TObj_long_label] = create_obj_matrix(prepdata_filename,label,index);
            %
            % plot test
            %             figure;
            %             plot(TObj_long_pred,'b--');hold on;
            %             plot(TObj(index).Car.vx,'r');
            %             %             savefig('object5.fig')    ;
            
            % timestamps of maneuver change for ego
            Time_maneuver_change_obj = unique([long_TObj(1,:), lat_TObj(1,:)]);
            Time_state_long_change = Time(find(diff(label.state.TObj(index).long))+1);
            Time_state_lat_change = Time(find(diff(label.state.TObj(index).lat))+1);
            
            % detect the times when a lat. or long. maneuver change or a change in the spatial state relative to Ego  begins to take place
            Time_state_change = unique([Time_state_long_change,Time_state_lat_change]);
            Time_change_obj = unique(round([Time_maneuver_change_obj, Time_state_change],2));
            
            % preallocate temp. array matrix
            vec_temp_TObj = zeros(11,length(Time_change_obj));
            
            % timestamps corresponding to state or maneuver change
            vec_temp_TObj(1,:) = Time_change_obj;
            
            % round time arrays to avoid errors (sampling time 0.02 s)
            Time = round(Time,2);
            Time_change_obj = round(Time_change_obj,2);
            
            for i=1:length(Time_change_obj)
                vec_temp_TObj(2,i) = TObj_long_pred(Time==Time_change_obj(i)); % velocity data from prediction
                vec_temp_TObj(4,i) = TObj_lat_pred(Time==Time_change_obj(i)); % absolute lat. pos data from prediction
                vec_temp_TObj(6,i) = TObj_long_label(Time==Time_change_obj(i)); % data from long. labeling
                vec_temp_TObj(7,i) = label.TObj(index).lat(Time==Time_change_obj(i)); % data from lat. labeling
                vec_temp_TObj(8,i) = label.state.TObj(index).long(Time==Time_change_obj(i)); % data from long state label
                vec_temp_TObj(9,i) = label.state.TObj(index).lat(Time==Time_change_obj(i)); % data from lat state label
                vec_temp_TObj(10,i) = TObj(index).sRoad(Time==Time_change_obj(i));%- Ego.sRoad(Time==Time_change_obj(i)) ;
                vec_temp_TObj(11,i) = TObj(index).Lane.t2Ref(Time==Time_change_obj(i));%-Ego.Lane.DevDist(Time==Time_change_obj(i));
                %                 vec_temp_TObj(12,i) = TObj(index).sRoad(Time==Time_change_obj(i));%-Ego.Lane.DevDist(Time==Time_change_obj(i));
            end
            % add target velocity and target lat. pos respectively in 3.th and 5.th  row in vec_temp_TObj
            for i=1:size(vec_temp_TObj,2)-1
                vec_temp_TObj(3,i) = vec_temp_TObj(2,i+1) ;
                vec_temp_TObj(5,i) = vec_temp_TObj(4,i+1) ;
                
            end
            % add target values for the last column
            vec_temp_TObj(3,end) = TObj_long_pred(end-1); % or ...(end)
            vec_temp_TObj(5,end) = TObj_lat_pred(end-1); % or ...(end)
            
            %% concatenate columns with non relevant labeling
            j_ind=1;
            ind_to_delete=[] ;
            %
            while j_ind<= size(vec_temp_TObj,2)
                
                if j_ind<= size(vec_temp_TObj,2)&&(vec_temp_TObj(8,j_ind)==-99)
                    while j_ind<size(vec_temp_TObj,2) && vec_temp_TObj(8,j_ind)==-99 && vec_temp_TObj(8,j_ind+1)==-99
                        
                        ind_to_delete = [ind_to_delete,j_ind];
                        j_ind=j_ind+1;
                    end
                    
                    % assign
                    if ~isempty(ind_to_delete)
                        vec_temp_TObj(:,ind_to_delete)=[];
                        j_ind=0;
                        ind_to_delete =[];
                    end
                end
                j_ind=j_ind+1;
            end
            disp('concatenating unknown labeling done');
                       
            %%------
            %create the final matrix of the current TObj, which will be used to overwrite the
            %maneuver in the infofile in CM. The matrix is described linewise as follows:
            % 1- Duration of the maneuvereuver
            % 2- target velocity
            % 3- target lateral position
            % 4- long. label
            % 5- lat. label
            % 6- long. state label relative to ego
            % 7- lat. state label relative to ego
            % 8- long. position relative to ego
            % 9- lat. position relative to ego
            
          
            % first timestamp must be 0s
            vec_temp_TObj(1,1)=0;
            
            % add displacement for every maneuver column
            
            vec_temp_TObj = [vec_temp_TObj ; zeros(2,size(vec_temp_TObj,2))];
            if ismember(-99, vec_temp_TObj(:,1))
                vec_temp_TObj(10,1) = 0;
            end
            disp_temp = diff(vec_temp_TObj(10,:));
            
            vec_temp_TObj(12,1:end-1) = disp_temp;
            
            % add last performed displacement if detectable
            if  ~ismember(-99, vec_temp_TObj(:,end))
                
                vec_temp_TObj(12,end) = TObj(index).sRoad(end)- vec_temp_TObj(10,end);
            end
            
            
            % add maneuver duration
            dur_temp = diff(vec_temp_TObj(1,:));
            vec_temp_TObj(13,1:end-1) = dur_temp;
            % add duration of the last maneuver or the last state change
            
            vec_temp_TObj(13,end) = Time(end)- vec_temp_TObj(1,end);
            % convert speed to kmh 
            vec_temp_TObj(2,:) = vec_temp_TObj(2,:)*3.6;
            vec_temp_TObj(3,:) = vec_temp_TObj(3,:)*3.6;
            
            %% Split in detectable parts
            % index arrays for non detectable parts
            ind_undetec8 = find(vec_temp_TObj(8,:)==-99);
            ind_undetec9 = find(vec_temp_TObj(9,:)==-99);
            ind_undetec = unique([ind_undetec8,ind_undetec9]);
            
            % post process the array of indexes
            %             ind_undetec_temp = ind_undetec;
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
                    num_obj =num_obj+1;
                    
                end
            end
            % store vec_temp_TObj
            TObj(index).vec_temp = vec_temp_TObj;
            
            % add array of timestamps corresponding to maneuver and state change
            % for TObj
            time_change_allTObj_ego = round(unique([time_change_allTObj_ego,Time_change_obj]),2);
           
        end
    end
end

%% create new struct with the new defined Objcts TObj_new

% index for the new added TObjs
ind_TObj_new =num_detecTObj;

% preallocate TObj_new
TObj_new =struct;

% add the new Objects (a new Object is defined pro detectable process)
for i=1:num_detecTObj
    if check_detectable(TObj(i).DetectLevel)
        for j=1:numel(TObj(i).TObj_DetectPart)
            if j==1
                TObj_new(i).matrix_model.data= TObj(i).TObj_DetectPart(j).data;
            else
                ind_TObj_new = ind_TObj_new+1;
                TObj_new(ind_TObj_new).matrix_model.data= TObj(i).TObj_DetectPart(j).data;
            end
        end
    end
end
%% build the Tensor for CM from the Tensor_model using the Struct TObj_new

% round time_change_allTObj_ego
time_change_allTObj_ego = round(unique([time_change_allTObj_ego,Time_change_obj]),2);


% make all TObjs matrices have the same dimensions according to the the
% definition of the theoretical tensor
for h=1:num_obj
    if ~isempty(TObj_new(h).matrix_model.data)
        
        % fill the struct tensor_CM for TObj 
        tensor_CM.TObj(h).data=TObj_new(h).matrix_model.data;
        % preallocate
        tensor_model.Tobj(h).data = TObj_new(h).matrix_model.data;
        % round time array
        tensor_model.Tobj(h).data(1,:)= round(tensor_model.Tobj(h).data(1,:),2) ;
        % convert speed to kmh
%         tensor_model.Tobj(h).data(2,:) = tensor_model.Tobj(h).data(2,:)*3.6;
%         tensor_model.Tobj(h).data(3,:) = tensor_model.Tobj(h).data(3,:)*3.6;
        
        
        for i=1:length(time_change_allTObj_ego)
            if ~ismember(time_change_allTObj_ego(i),round(tensor_model.Tobj(h).data(1,:),2))
                
                tensor_model.Tobj(h).data = [tensor_model.Tobj(h).data, [time_change_allTObj_ego(i);-9999*ones(12,1)]];
            end
            
            % postprocess the TObj model matrix by removing redundant
            % columns
            tensor_model.Tobj(h).data(1,:)= round(tensor_model.Tobj(h).data(1,:),2);
            temp_matrix = unique(transpose(tensor_model.Tobj(h).data),'rows','stable');
            tensor_model.Tobj(h).data = transpose(temp_matrix);
        end
        % permute columns of the matrix according to sorted time steps
        tensor_model.Tobj(h).data = permute_sorted_col(tensor_model.Tobj(h).data);
        
    end
end

% make ego matrix have the same dimensions as TObj matrices (Tensor pages must have the same dimension)
tensor_model.Ego = [vec_temp_ego; -9999*ones(8,size(vec_temp_ego,2))];

% convert speed to kmh
tensor_model.Ego(2,:) = tensor_model.Ego(2,:) *3.6;

% round time to avoid error warning
tensor_model.Ego(1,:) = round(tensor_model.Ego(1,:),2);

% unify the dimension for ego
for i=1:length(time_change_allTObj_ego)
    if ~ismember(time_change_allTObj_ego(i),tensor_model.Ego(1,:))
        tensor_model.Ego = [tensor_model.Ego,[time_change_allTObj_ego(i);-9999*ones(12,1)]];
    end
end

% rearrange the columns of the ego matrix according to sorted time steps
tensor_model.Ego = permute_sorted_col(tensor_model.Ego);

%% save changes to Tobj struct
prepdata_filename= 'prepdata.mat';
save(prepdata_filename);

% func end
end

