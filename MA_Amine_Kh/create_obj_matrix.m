% This function provides the necessary infos about the kinematics of the
% TObj by mainly creating respectively the matrices describing both long. kinematics and lat. kinematics for
% TObj known as long_TObj and lat_TObj. Furthermore the prediction of both long. velocity and
% lateral position profiles are provided as output.

function [long_TObj,lat_TObj, TObj_vx_pred, TObj_lat_pred, label_TObj_long]=create_obj_matrix(prepdata_filename,label_data, n)

global flag_resim;
%% load and process CM data for TObj

load(prepdata_filename,'TObj','Time');

% load long quantities
TObj_accx=TObj(n).Car.ax;
TObj_vx=TObj(n).Car.vx;
TObj_sRoad=TObj(n).sRoad;
% TObj_lat = TObj(n).Lane.t2Ref;

% preallocate
TObj_vx_pred = [];
TObj_lat_pred =[];

% assign
label_TObj_long = label_data.TObj(n).long;


%% build the matrix describing the long. kinematics of TObj

long_TObj=[];
TObj_accx_thr=0.25; % threshold of the acc in x direction
% set time threshold for TObj
Time_thr=1;

j=0;
m=0;
% long_TObj: linewise:
%1. beginning Time / 2. initial_vel in mps / 3. final_vel in mps/
%4. duration in s/ 5. Displacement / 6. Label


while j<length(Time)
    j=j+1;
    if j==1
        k=j;
    else
        k=j-1;
    end
    if label_TObj_long(j)~=-9
        
        if (TObj_accx(j))>TObj_accx_thr
            while  j<length(Time) && (TObj_accx(j))>TObj_accx_thr && label_TObj_long(j)~=-9
                j=j+1;
            end
            m=m+1;
            
            %add condition for the target velocity before undetection
            if flag_resim ==0
                if label_TObj_long(j) ==-9
                    long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j-1);Time(j)-Time(k);TObj_sRoad(j-1)-TObj_sRoad(k);1];
                    
                else
                    
                    long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j);Time(j)-Time(k);TObj_sRoad(j)-TObj_sRoad(k);1];
                end
            else
                
                long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j);Time(j)-Time(k);TObj_sRoad(j)-TObj_sRoad(k);1];
            end
        elseif (TObj_accx(j))<-TObj_accx_thr
            while  j<length(Time) && TObj_accx(j)<-TObj_accx_thr && label_TObj_long(j)~=-9
                j=j+1;
            end
            m=m+1;
            %  add condition for the target velocity before undetection
            if flag_resim ==0
                if label_TObj_long(j) ==-9
                    long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j-1);Time(j)-Time(k);TObj_sRoad(j-1)-TObj_sRoad(k);-1];
                    
                else
                    
                    long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j);Time(j)-Time(k);TObj_sRoad(j)-TObj_sRoad(k);-1];
                end
            else
                %                 temp_index = find(TObj_vx(1:j),1,'last');
                long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j);Time(j)-Time(k);TObj_sRoad(j)-TObj_sRoad(k);-1];
            end
            
        elseif abs(TObj_accx(j))<=TObj_accx_thr
            while j<length(Time) && abs(TObj_accx(j))<=TObj_accx_thr && label_TObj_long(j)~=-9
                j=j+1;
            end
            m=m+1;
            
            %add condition for the target velocity before undetection
            if flag_resim ==0
                if label_TObj_long(j) ==-9
                    long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j-1);Time(j)-Time(k);TObj_sRoad(j-1)-TObj_sRoad(k);0];
                    
                else
                    
                    long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j);Time(j)-Time(k);TObj_sRoad(j)-TObj_sRoad(k);0];
                end
            else
                %                 temp_index = find(TObj_vx(1:j),1,'last');
                long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j);Time(j)-Time(k);TObj_sRoad(j)-TObj_sRoad(k);0];
            end
        end
    else
        while j<length(Time) && label_TObj_long(j)==-9
            j=j+1;
        end
        m=m+1;
        long_TObj(:,m)=[Time(k);TObj_vx(k);TObj_vx(j);Time(j)-Time(k);TObj_sRoad(j)-TObj_sRoad(k);-9];
    end
end
%%
%--------
% %index arrays of relevance
% ind_detectable = find(long_TObj(end,:)~=-9);
% ind_undetectable = find(long_TObj(end,:)==-9);
%
% % post process the array of indexes
% ind_undetectable_temp = ind_undetectable;
% if ~ismember(1,ind_undetectable)
%     ind_undetectable = [0,ind_undetectable];
% end
% if ~ismember(size(long_TObj,2),ind_undetectable)
%     ind_undetectable = [ind_undetectable,size(long_TObj,2)+1];
% end
%
% % matrix to store the detectable parts
% Matrix_temp = long_TObj(:,ind_undetectable_temp);
%
% % split long. TObj into detectable intervals
% if ~isempty(ind_undetectable)
%     for i=1:length(ind_undetectable)-1
%         long_TObj_DetectPart(i).data = long_TObj(:,ind_undetectable(i)+1:ind_undetectable(i+1)-1);
% %         if size(long_TObj_DetectPart(i).data,2) >1
% %             long_TObj_DetectPart(i).data = create_long(long_TObj(:,ind_undetectable(i)+1:ind_undetectable(i+1)-1),Time_thr);
% %         end
%         Matrix_temp = [Matrix_temp, long_TObj_DetectPart(i).data];
%     end
% end
%------
%%
% resort the matrix columns according to the time
% long_TObj=permute_sorted_col(Matrix_temp);
long_TObj = create_long(long_TObj,1);


if  flag_resim ==0
    TObj_vx_pred = velocity_pred_new(long_TObj); % predict velocity profile only for first simulation
end

%% correct the long. labeling for TObj
label_TObj_long = -9*ones(1,length(Time));
for ind=1:size(long_TObj,2)
    if long_TObj(end,ind)~=-9
        ind_start = find(Time==long_TObj(1,ind));
        if ind==size(long_TObj,2)
            ind_end = length(Time);
        else
            ind_end = find(Time==long_TObj(1,ind+1))-1;
        end
        label_TObj_long(ind_start:ind_end) = long_TObj(end,ind);
    end
end

%%  build the matrix describing the lateral maneuvers of the TObj from the labeling data
TObj_lat_label = label_data.TObj(n).lat;
TObj_lat_pos = TObj(n).Lane.t2Ref ; % use the quantity t2ref

j=0;
m=0;
k=0;
while j<length(Time)
    
    j=j+1;
    if j==1
        k=j;
    else
        k=j-1;
    end
    
    if TObj_lat_label(j)==0 % Lane Keeping
        
        while  j<length(Time) && TObj_lat_label(j)==0
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_TObj(:,m)=[Time(k);Time(j)-Time(k);TObj_lat_pos(j);0];
        
        
    elseif TObj_lat_label(j)==1 % lane change right
        
        while  j<length(Time) && TObj_lat_label(j)==1
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_TObj(:,m)=[Time(k);Time(j)-Time(k);TObj_lat_pos(j);1];
        
    elseif TObj_lat_label(j)==-1 % lane change left
        
        while  j<length(Time) && TObj_lat_label(j)==-1
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_TObj(:,m)=[Time(k);Time(j)-Time(k);TObj_lat_pos(j);-1];
        
    elseif TObj_lat_label(j)==-9 % undetected
        while  j<length(Time) && TObj_lat_label(j)==-9
            
            j=j+1;
            
        end
        %         k=k+1;
        m=m+1;
        lat_TObj(:,m)=[Time(k);Time(j)-Time(k);TObj_lat_pos(j);-9];
        
    end
end


%% predict the lateral pos profile
if  flag_resim ==0
    TObj_lat_pred = lat_pos_pred(lat_TObj);
    
end

end
