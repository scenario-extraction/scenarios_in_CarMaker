%%
%this funtion has the long. matrices as a one of its Inputs and. It concatenates the columns
% of the these matrices based on a chosen time thresohld. In this case the
% duration of a Gear shifting is chosen as threshold

function M=create_long(M,time_thr)

m=0;
ind=0;
indarr=[];

while ind<size(M,2)
    
    ind=ind +1 ;
    
    % treat the case that the first maneuver duration is less than the set
    % threshold
    if ind ==1 && check_time(M(4,1), time_thr)
        ind_temp = ind;
        while ind_temp<= size(M,2) && check_time(M(4,ind_temp), time_thr)
            if ind_temp >1
                m=m+1;
                indarr(m)=ind_temp;
            end
            M(3,1)=M(3,ind_temp);
            if ind_temp ~=1
                M(4,1)=M(4,1)+M(4,ind_temp);
                M(5,1)=M(5,1)+M(5,ind_temp);
            end
            ind_temp =ind_temp+1;
        end
        if ind_temp >1
            m=m+1;
            indarr(m)=ind_temp;
        end
        
        % remove exceeded index from indarr
        M(3,1)=M(3,ind_temp);
        if ind_temp ~=1
            M(4,1)=M(4,1)+M(4,ind_temp);
            M(5,1)=M(5,1)+M(5,ind_temp);
        end
        M(end,1) = M(end,ind_temp);
        if ~isempty(indarr)
            
            M(:,indarr)=[]; % remove unknown maneuver segments (columns in the matrix)
        end
    end
    
    m=0;
    indarr=[];
    %
    k=ind+1;
    if k >=size(M,2)
        break;
    end
    if check_time(M(4,k), time_thr)
        
        % while GS or unknown maneuver add the duration and performed
        % displacement
        while k<= size(M,2) && check_time(M(4,k), time_thr)
            
            m=m+1;
            indarr(m)=k;
            M(3,ind)=M(3,k);
            M(4,ind)=M(4,k)+M(4,ind);
            M(5,ind)=M(5,k)+M(5,ind);
            k=k+1;
            
        end
       
        if ~isempty(indarr)
            
            M(:,indarr)=[]; % remove unknown maneuver segments (columns in the matrix)
        end
        %             j=1;
        m=0; % preallocate for the next iteration
        indarr=[];% preallocate for the next iteration
        %         ind = k;
    end
    
end

k=0;
label=M(end,:);
m=0;
ind=0;
indarr=[];
%-------------------
while  ind<length(label) && ~check_adj(label) % &&
    
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
    elseif label(k)==-9
        j=k+1;
        
        while j<=size(M,2) && label(j)==-9
            
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
    label=M(end,:);
    
end

end


%--- subfunctions
% this function checks if a certain threshold is exceeded in a given array
function b=check_time(vec,time_thr)

b=false;

if (find(vec<time_thr))
    
    b=true;
    
end
end

