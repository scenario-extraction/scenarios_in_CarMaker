% function to build the long. matrix describing the long motion of Ego
% according to the theoretical model. This function is
% specific to Ego with manual driving mode.
% * defined maneuver refer hier to acceleration, decelartion or static cruising 

%---Abbreviations:
%GS: gear shifting
function M = build_long_matrix(Ego_Car_ax, Ego_Car_vx, Time, Ego_sRoad, clutch_array, gear_acc)

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
%7. current gear number
%8. maximum acceleration in current motion segment
%9. occurence of GS

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
    %Matrix M is is extended in the code by adding the current gear number data and maximum acceleration in each longitudinal motion segment
        M(:,m)=[Time(k);Ego_Car_vx(k);Ego_Car_vx(j);Time(j)-Time(k);Ego_sRoad(j)-Ego_sRoad(k);1; clutch_array(2,k+1);max(Ego_Car_ax(k:j))];% add the new motion segment to M
        
    elseif round(Ego_Car_ax(j),1)<Ego_Car_ax_thr
        
        while  j<length(Time) && round(Ego_Car_ax(j),1)<Ego_Car_ax_thr
            
            j=j+1;
            
        end
        
        m=m+1;
        M(:,m)=[Time(k);Ego_Car_vx(k);Ego_Car_vx(j);Time(j)-Time(k);Ego_sRoad(j)-Ego_sRoad(k);-1;clutch_array(2,k+1);min(Ego_Car_ax(k:j))];% add the new motion segment to M
        
    else
        while j<length(Time) && round(Ego_Car_ax(j),1)==Ego_Car_ax_thr
            
            j=j+1;
            
        end
        m=m+1;
        M(:,m)=[Time(k);Ego_Car_vx(k);Ego_Car_vx(j);Time(j)-Time(k);Ego_sRoad(j)-Ego_sRoad(k);0;clutch_array(2,k+1);0];% add the new motion segment to M
        
    end
end

% add other clutch quantities
M=[M;zeros(2,size(M,2))];
M(9,:) = [diff(M(7,:)),0]; % add occurence of GS 

%% correct the labeling and get the final version of the matrix M

% define time threshold, which must be greater than clutch duration
time_thr = 1.0; 

% introduce labeling for GS and unknown maneuver: -9 for GS -99 for unknown
% maneuver. The idea behind introducing GS labeling is to assure a correct lableling of the maneuver prior to GS
% and thus eventually distinguish correctly between static cruising and acceleration (or deceleration)

for i=1:size(M,2)
    
    if M(4,i)<time_thr % smaller than clutch duration
        if M(9,i)~=0 % GS has occured
            M(6,i) = -9; % GS
        else
            M(6,i) = -99; % unknown
            
        end
    end
end


% define an array containing indexes for segments corresponding to the maneuvers prior to GS
ind_gs =[];
for i=1:size(M,2)
    if abs(M(6,i))<9
        if i~=size(M,2)
            
            if (M(6,i+1))==-9 % next maneuver is gear shifting
                ind_gs = [ind_gs,i];
            end
        end
    end
end

% eventually correct the labeling of the segments with indexes not
% contained in the array ind_gs. Unknown maneuvers are not taken into
% consideration
for i=1:size(M,2)
    if ~ismember(i,ind_gs) && abs(M(6,i))==1
        max_current_gear_acc = gear_acc(2,M(7,i)==gear_acc(1,:));% get the maximum reachable acceleration corresonding to the current gear 
        if abs(round(M(8,i)/max_current_gear_acc))<1 % evaluate whether the current long. maneuver is considered as static cruising 
            M(6,i)=0; % label with static cruising label
        end
    end
end    


% ---- remove segments corresponding to gear shifting or unknown maneuvers
% by concatenating to known maneuvers
m=0;
ind=0;
indarr=[]; % array containing the indexes of GD or unknown maneuver

while ind<size(M,2)
    
    ind=ind+1;
    
    if check_time(M(:,ind), 1)
        k=ind+1;
        % while GS or unknown maneuver add the duration and performed
        % displacement
        while k< size(M,2) && abs(M(6,k))>1
            
            m=m+1;
            indarr(m)=k;
            M(4,ind)=M(4,k)+M(4,ind);
            M(5,ind)=M(5,k)+M(5,ind);
            k=k+1;
            
        end
        % concatenate to the next available defined maneuver (acc or dec or static cruising)
        M(3,ind)=M(3,k);
        M(4,ind)=M(4,k)+M(4,ind);
        M(5,ind)=M(5,k)+M(5,ind);
        M(6,ind)=M(6,k); % get the label of the defined maneuver
        m=m+1;
        indarr(m)=k;
        
        if ~isempty(indarr)
            
            M(:,indarr)=[]; % remove GS and unknown maneuver segments (columns in the matrix)
        end
        %             j=1;
        m=0; % preallocate for the next iteration
        indarr=[];% preallocate for the next iteration
        
    end
    
end

%--- concatenate segments with same labeling

% preallocate
label=M(6,:);
m=0;
ind=0;
indarr=[];
%-------------------
while  ind<length(label) && ~check_adj(label) 
    
    ind=ind+1;
    k=ind;
    if label(k)==1
        j=k+1;
        
        while j<=size(M,2) && label(j)==1
            
            m=m+1;
            indarr(m)=j;
            M(3,k)=M(3,j);
            M(4,k)=M(4,k)+M(4,j);
            M(5,k)=M(5,k)+M(5,j);
            j=j+1;
        end
        if ~isempty(indarr)
            
            M(:,indarr)=[];
        end
        j=1;
        m=0;
        indarr=[];
        
    elseif label(k)==-1
        j=k+1;
        
        while j<=size(M,2) && label(j)==-1
            
            m=m+1;
            indarr(m)=j;
            M(3,k)=M(3,j);
            M(4,k)=M(4,k)+M(4,j);
            M(5,k)=M(5,k)+M(5,j);
            j=j+1;
        end
        if ~isempty(indarr)
            
            M(:,indarr)=[];
        end
        
        j=1;
        
        m=0;
        indarr=[];
        
        
    elseif label(k)==0
        j=k+1;
        
        while j<=size(M,2) && label(j)==0
            
            m=m+1;
            indarr(m)=j;
            M(3,k)=M(3,j);
            M(4,k)=M(4,k)+M(4,j);
            M(5,k)=M(5,k)+M(5,j);
            j=j+1;
        end
        if ~isempty(indarr)
            
            M(:,indarr)=[];
            label(:,indarr)=[];
        end
        
        j=1;
        m=0;
        indarr=[];
    elseif label(k)==-99
        j=k+1;
        
        while j<=size(M,2) && label(j)==-99
            
            m=m+1;
            indarr(m)=j;
            M(3,k)=M(3,j);
            M(4,k)=M(4,k)+M(4,j);
            M(5,k)=M(5,k)+M(5,j);
            j=j+1;
        end
        if ~isempty(indarr)
            
            M(:,indarr)=[];
        end
        
        j=1;
        
        m=0;
        indarr=[];
    end
    label=M(6,:);
    
end

%------- delete data, which wont be needed anymore. For example clutch data
M(7:10,:)=[];
end


%--- subfunctions
% this function checks if a certain threshold is exceeded
function b=check_time(vec,time_thr)

b=false;

if  vec(4)<(time_thr)
    b=true;
    
end
end

% this function checks whether two consecutive array elements are duplicate
% and will be needed in the final labeling
function b=check_adj(vec) %
temp=unique(vec,'stable');
b=isequal(temp,vec);
end



