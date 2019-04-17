% create the final version of the matrix describing the long. maneuvers
% according to the model
function M=create_long(M,time_thr)

 
m=0;
ind=0;
indarr=[];
%-----------------
while ind<size(M,2)  %&& ~check_time_thr_all(M(4,:),time_thr)
    
    
    ind=ind+1;
    %     if ind==1
    if check_time_thr(M(:,ind), time_thr)
        k=ind+1;
        while k< size(M,2) && check_time_thr(M(:,k), time_thr)
            
            m=m+1;
            indarr(m)=k;
            M(4,ind)=M(4,k)+M(4,ind);
            M(5,ind)=M(5,k)+M(5,ind);
            k=k+1;
            
            
        end
        M(3,ind)=M(3,k);
        M(4,ind)=M(4,k)+M(4,ind);
        M(5,ind)=M(5,k)+M(5,ind);
        M(end,ind)=M(end,k); % label the new curve segment
        m=m+1;
        indarr(m)=k;
        
        if ~isempty(indarr)
            
            M(:,indarr)=[];
        end
        %             j=1;
        m=0;
        indarr=[];
        
    end

end
 
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
        
        
    else
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
        
    end
   label=M(end,:);
 
    
end
end
 
 
 
function b=check_time_thr(vec,time_thr)
 
b=false;

if  vec(4)<(time_thr)
    b=true;
    
end
 
 
end
 
 
 
% function b=check_time_thr_all(vec,time_thr)
%  
% b=false;
% I=find(vec<time_thr, 1);
% %     if (vec(5)< T01  &&    vec(4)<T01)
% if  ~isempty(I) % && abs(vec(3)-vec(2))<vel_thr)
%     b=true;
%     
% end
%  
%  
% end
 
