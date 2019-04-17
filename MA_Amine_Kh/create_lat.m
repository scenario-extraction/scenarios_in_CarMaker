% function create matrix describingthe lat. maneu according to model and
% predict the abs. lat offset profile

function [Mnew,lat_pred]=create_lat(M,LaneID)

Mnew=[M;-99*ones(1,size(M,2))]; % add row to label the lat man ( Keep lane, lcl, lcr)

lc_detect=false;

for i=1:size(Mnew,2)
    
    n=Mnew(6,i);
    m=Mnew(7,i);
    
    if LaneID(n)> LaneID(m)  % LCL
        
%         lc_detect=true;
        Mnew(end,i)=-1; % LCL
        
    elseif LaneID(n)< LaneID(m) % LCR
        
%         lc_detect=true;
        Mnew(end,i)=1; % LCR
    elseif abs(Mnew(5,i))<0.5 % set vy threshold to distinguish btween unknown man and lane keeping
%         lc_detect=true;
        Mnew(end,i)=0; % KL   
%     else
        % -99 unknown or interrupted LC
        
    end
    
end

% concatenate curve segments with same labling

label=Mnew(end,:);
k=0;
indarr=[];
m=0;
while  ~check_adj(label) && k<length(label)
    
    k=k+1;
    
    if label(k)==1
        j=k+1;
        
        while j<=size(Mnew,2) && label(j)==1
            
            m=m+1;
            indarr(m)=j;
            Mnew(4,k)=Mnew(4,j);
            Mnew(2,k)=Mnew(2,k)+Mnew(2,j);
%             Mnew(5,k)=Mnew(5,j);
            Mnew(7,k)=Mnew(7,j);
            
            j=j+1;
        end
        Mnew(5,k)=max(Mnew(5,k:j-1));
        if ~isempty(indarr)
            
            M(:,indarr)=[];
            label(:,indarr)=[];
        end
        %             j=1;
        m=0;
        indarr=[];
        
    elseif label(k)==-1
        j=k+1;
        
        while j<=size(Mnew,2) && label(j)==-1
            
            m=m+1;
            indarr(m)=j;
            Mnew(4,k)=Mnew(4,j);
            Mnew(2,k)=Mnew(2,k)+Mnew(2,j);
%             Mnew(5,k)=Mnew(5,j);
            Mnew(7,k)=Mnew(7,j);
            j=j+1;
        end
        Mnew(5,k)=max(Mnew(5,k:j-1));

        if ~isempty(indarr)
            
            Mnew(:,indarr)=[];
            label(:,indarr)=[];
        end
        
        
        m=0;
        indarr=[];
        
        
    elseif label(k)==0
        j=k+1;
        
        while j<=size(Mnew,2) && label(j)==0
            
            m=m+1;
            indarr(m)=j;
            Mnew(4,k)=Mnew(4,j);
            Mnew(2,k)=Mnew(2,k)+Mnew(2,j);
            Mnew(5,k)=Mnew(5,j);
            Mnew(7,k)=Mnew(7,j);
            j=j+1;
        end
        Mnew(5,k)=max(Mnew(5,k:j-1));

        if ~isempty(indarr)
            
            Mnew(:,indarr)=[];
            label(:,indarr)=[];
        end
        
        %             j=1;
        m=0;
        indarr=[];
    else
        j=k+1;
        
        while j<=size(Mnew,2) && label(j)==-99
            
            m=m+1;
            indarr(m)=j;
            Mnew(4,k)=Mnew(4,j);
            Mnew(2,k)=Mnew(2,k)+Mnew(2,j);
            Mnew(5,k)=Mnew(5,j);
            Mnew(7,k)=Mnew(7,j);
            j=j+1;
        end
        Mnew(5,k)=max(Mnew(5,k:j-1));

        if ~isempty(indarr)
            
            Mnew(:,indarr)=[];
            label(:,indarr)=[];
        end
        m=0;
        indarr=[];
    end
    label=Mnew(end,:);
    
    
end
%-----------------
% process maneuvers labeled with -99
ind=0;
indarr=[];
ind_end=0;
while ind~=size(Mnew,2)
    ind=ind+1;
    if ind==size(Mnew,2)
        if Mnew(end,end)==-99
         if Mnew(end,end-1)~=-99
            Mnew(2,end-1)=sum(Mnew(2,end-1:end));
            Mnew(4,end-1)=Mnew(4,end);
            Mnew(5,end-1)=max(Mnew(5,end-1:end));
            Mnew(7,end-1)=Mnew(7,end);
         end
        end
    else
    if Mnew(end,ind)==-99
                
        ind_end=find(Mnew(end,ind:end)~=-99 & Mnew(2,ind:end)>0.5,1,'first')+ind-1;
        
        Mnew(2,ind)=sum(Mnew(2,ind:ind_end));
        Mnew(4,ind)=Mnew(4,ind_end);
        Mnew(5,ind)=max(Mnew(5,ind:ind_end));
        Mnew(7,ind)=Mnew(7,ind_end);
        Mnew(end,ind)=Mnew(end,ind_end);
        Mnew(end,ind:ind_end)=Mnew(end,ind_end);
        indarr=[indarr,ind+1:ind_end];
    end
    end
end  

Mnew(:,indarr)=[];
      
 %--------------  concatenate maneuvers with same label again
 label=Mnew(end,:);
k=0;
indarr=[];
m=0;
while  ~check_adj(label) && k<length(label)
    
    k=k+1;
    
    if label(k)==1
        j=k+1;
        
        while j<=size(Mnew,2) && label(j)==1
            
            m=m+1;
            indarr(m)=j;
            Mnew(4,k)=Mnew(4,j);
            Mnew(2,k)=Mnew(2,k)+Mnew(2,j);
%             Mnew(5,k)=Mnew(5,j);
            Mnew(7,k)=Mnew(7,j);
            
            j=j+1;
        end
        Mnew(5,k)=max(Mnew(5,k:j-1));
        if ~isempty(indarr)
            
            M(:,indarr)=[];
            label(:,indarr)=[];
        end
        %             j=1;
        m=0;
        indarr=[];
        
    elseif label(k)==-1
        j=k+1;
        
        while j<=size(Mnew,2) && label(j)==-1
            
            m=m+1;
            indarr(m)=j;
            Mnew(4,k)=Mnew(4,j);
            Mnew(2,k)=Mnew(2,k)+Mnew(2,j);
%             Mnew(5,k)=Mnew(5,j);
            Mnew(7,k)=Mnew(7,j);
            j=j+1;
        end
        Mnew(5,k)=max(Mnew(5,k:j-1));

        if ~isempty(indarr)
            
            Mnew(:,indarr)=[];
            label(:,indarr)=[];
        end
        
        
        m=0;
        indarr=[];
        
        
    elseif label(k)==0
        j=k+1;
        
        while j<=size(Mnew,2) && label(j)==0
            
            m=m+1;
            indarr(m)=j;
            Mnew(4,k)=Mnew(4,j);
            Mnew(2,k)=Mnew(2,k)+Mnew(2,j);
            Mnew(5,k)=Mnew(5,j);
            Mnew(7,k)=Mnew(7,j);
            j=j+1;
        end
        Mnew(5,k)=max(Mnew(5,k:j-1));

        if ~isempty(indarr)
            
            Mnew(:,indarr)=[];
            label(:,indarr)=[];
        end
        
        m=0;
        indarr=[];
    else
        j=k+1;
        
        while j<=size(Mnew,2) && label(j)==-99
            
            m=m+1;
            indarr(m)=j;
            Mnew(4,k)=Mnew(4,j);
            Mnew(2,k)=Mnew(2,k)+Mnew(2,j);
            Mnew(5,k)=Mnew(5,j);
            Mnew(7,k)=Mnew(7,j);
            j=j+1;
        end
        Mnew(5,k)=max(Mnew(5,k:j-1));

        if ~isempty(indarr)
            
            Mnew(:,indarr)=[];
            label(:,indarr)=[];
        end
        m=0;
        indarr=[];
    end
    label=Mnew(end,:);
    
    
end
%--------------

% predicition
lat_pred=lat_offset_pred(Mnew);


end % end create_lat


%build the  prediciton model

function lat_pred_total= lat_offset_pred(lat_ego)
lat_pred_total=[];

for i=1:size(lat_ego,2)
    if i==1
        t_arr=0:0.02:lat_ego(2,i);
    else 
        t_arr=0.02:0.02:lat_ego(2,i);
    end
    t_arr=round(t_arr,2);
    t_lc=lat_ego(2,i);

    H=abs((lat_ego(4,i)-lat_ego(3,i)));
    
    if lat_ego(end,i)==0  || lat_ego(end,i)==-99  || (lat_ego(2,i)<3)% fit with a line
        a=(lat_ego(4,i)-lat_ego(3,i))/(lat_ego(2,i));
        b=lat_ego(4,i)-a*t_lc;
        lat_pred=arrayfun(@(x) a*x+b,t_arr);

        % fit with sinus model
    elseif lat_ego(end,i)==-1
    
        %---------------------
        x1= (pi/t_lc);
        x2=-x1*t_lc*0.42;
        %----------------------
        %         x1=pi*0.45*(1/t_lc);
        lat_pred=arrayfun(@(t) H*0.5*sin(x1*(t)+x2)+H*0.5, t_arr);
       
        

    elseif lat_ego(end,i)==1
        x1= -(pi/t_lc);
        x2=(pi*0.42);
        lat_pred=arrayfun(@(t) H*0.5*sin(x1*(t)+x2)+H*0.5, t_arr);
        

    else %
        
    end
%     if i>1
%         lat_pred=lat_pred(2:end);
%     end
%     
    lat_pred_total=[lat_pred_total,lat_pred];
end
end




