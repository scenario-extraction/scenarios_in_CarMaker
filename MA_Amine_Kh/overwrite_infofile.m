% this function overwrites the CM TestRun infofile with the infos contained
% in the tensor created within the function create_tensor.m

function overwrite_infofile(S,Filename)

cd ('F:\Highway_scenarios_overwrite\Data\TestRun');

% create instance of the file
handle=ifile_new();

ifile_read(handle,Filename);

% overwrite the man of ego
if isfield(S,'Ego')
    
    % initial lat offset &  velocity + maneuver number
    ifile_setstr(handle,strcat('DrivMan.Init.Velocity'),num2str(S.Ego(2,1)));
    ifile_setstr(handle,strcat('DrivMan.Init.LaneOffset'), num2str(S.Ego(6,1)));
    ifile_setstr(handle,strcat('DrivMan.nDMan'),num2str(size(S.Ego,2)));
    
    nD_man=eval(ifile_getstr(handle,'DrivMan.nDMan'));
    
    % ignore traffic ( for ego)
    ifile_setstr(handle,strcat('Driver.ConsiderTraffic'),num2str(0));
    
    % if necessary delete keyvalue of distlimit or Timelimmit
    for n=1:nD_man
        
        if ~strcmp(ifile_getstr(handle,strcat('DrivMan.',num2str(n-1),'.DistLimit')),'')
            
            ifile_setstr(handle,strcat('DrivMan.',num2str(n-1),'.DistLimit'),'');
        end
        
    end
    
    % overwrite lat and long maneuver
    for i =1:size(S.Ego,2)
        ifile_setstr(handle,strcat('DrivMan.',num2str(i-1),'.TimeLimit'),strcat(num2str(S.Ego(4,i))));
        %     ifile_setstr(handle,strcat('DrivMan.',num2str(i-2),'.DistLimit'),strcat(num2str(S.Ego(4,i))));
        
        ifile_setstr(handle,strcat('DrivMan.',num2str(i-1),'.LongDyn'), strcat('Driver 1 0',32,num2str(S.Ego(3,i))));
        ifile_setstr(handle,strcat('DrivMan.',num2str(i-1),'.LatDyn'), strcat('Driver',32, num2str(S.Ego(7,i))));
        
    end
    % set the limit of long. acc and dec for CM Resimulation
        ifile_setstr(handle,strcat('Driver.Long.axMin'),strcat(num2str(10)));
        ifile_setstr(handle,strcat('Driver.Long.axMax'),strcat(num2str(10)));
end

% set number of traffic Objects in the infofile
ifile_setstr(handle,strcat('Traffic.N'), num2str(S.numOfTobj));

% overwrite the maneuver of TObj
if isfield(S,'TObj')
    
    for index=0:numel(S.TObj)-1
        
        if ~isempty(S.TObj(index+1).data)
            index_str=num2str(index);
            
            % assign
            vec_overwrite_TObj=S.TObj(index+1).data;
            
            ifile_setstr(handle,strcat('Traffic.',index_str,'.Man.N '),num2str(size(vec_overwrite_TObj,2)));
            
            v_temp = vec_overwrite_TObj(2,1);
            
            ifile_setstr(handle,strcat('Traffic.',index_str,'.Init.v'),num2str(v_temp)); % target velocity of previous maneuver segment
            
            ifile_setstr(handle,strcat('Traffic.',index_str,'.Init.Road'),strcat(num2str(vec_overwrite_TObj(8,1)),32,num2str(vec_overwrite_TObj(6,1))));
            
            start_time_temp = vec_overwrite_TObj(1,1);
            
            if start_time_temp~=0
                ifile_setstr(handle,strcat('Traffic.',index_str,'.Man.StartCondition'),strcat('Time>=',num2str(start_time_temp))); % set start time condition
            end
            
            for i = 1:size(vec_overwrite_TObj,2)
                
                ifile_setstr(handle,strcat('Traffic.',index_str,'.Man.',num2str(i-1),'.Limit'),strcat('t',32,num2str(vec_overwrite_TObj(4,i))));
                ifile_setstr(handle,strcat('Traffic.',index_str,'.Man.',num2str(i-1),'.LongDyn'), strcat('v',32, num2str(vec_overwrite_TObj(3,i))));
                %ifile_setstr(handle,strcat('Traffic.',index_str,'.Man.',num2str(i-2),'.LongDyn'), strcat('a',32, num2str(vec_overwrite_TObj(4,i))));
                ifile_setstr(handle,strcat('Traffic.',index_str,'.Man.',num2str(i-1),'.LatDyn'), strcat('y_abs',32, num2str(vec_overwrite_TObj(7,i))));
                
            end
        end
    end
end

%% apply the changes to the infofile and delete the handle instance
ifile_write(handle,Filename);
ifile_delete(handle);

end
