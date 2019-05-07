% this function creates the matrix describing the lateral kinematics
% according to the model for TObj. the function is label-based and has the
% lateral labeling from the function labeling.m as input. 
% the output matrix is linewise describing as follow:
% 1- Beginning time of the action
% 2- duration of the action
% 3- absolute lateral position
% 4- label

function lat_TObj=create_lat_with_label_TO(TObj, label,index_TO, time_obj, ind_first, ind_last)

lat_TObj = [];

%% prepare and preprocess lat. label data
TObj_lat_label = label.TObj(index_TO).lat(ind_first:ind_last);
TObj_lat_pos = TObj(index_TO).Lane.tRoad (ind_first:ind_last);

j=0;
m=0;

while j<length(time_obj)
    
    j=j+1;
    if j==1
        k=j;
    else
        k=j-1;
    end
    
    if TObj_lat_label(j)==0 % Lane Keeping
        
        while  j<length(time_obj) && TObj_lat_label(j)==0
            
            j=j+1;
            
        end
%         k=k+1;
        m=m+1;
        lat_TObj(:,m)=[time_obj(k);time_obj(j)-time_obj(k);TObj_lat_pos(j);0];
        
        
    elseif TObj_lat_label(j)==1 % lane change right
        
        while  j<length(time_obj) && TObj_lat_label(j)==1
            
            j=j+1;
            
        end
%         k=k+1;
        m=m+1;
        lat_TObj(:,m)=[time_obj(k);time_obj(j)-time_obj(k);TObj_lat_pos(j);1];
        
    elseif TObj_lat_label(j)==-1 % lane change left
        
        while  j<length(time_obj) && TObj_lat_label(j)==-1
            
            j=j+1;
            
        end
%         k=k+1;
        m=m+1;
        lat_TObj(:,m)=[time_obj(k);time_obj(j)-time_obj(k);TObj_lat_pos(j);-1];
    else %
        
    end
end

end




