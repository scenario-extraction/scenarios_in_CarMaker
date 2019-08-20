% calculate the relative % deviation considering the mapping of driving
% events (maneuver and spatial relations) in the resimulation Tensor

function  error=event_dev_func(M_sim,M_resim)

error=[];
if ~isempty(M_sim) && ~isempty(M_resim)
    N_rows=size(M_sim,1);
    % process the two tensors
    index1=[];
    index2=[];
    
    % assign input matrices
    A= M_sim(end-1:end,:);
    B= M_resim(end-1:end,:);
    
   
    % proc A
    for i =2:size(A,2)
        
        if A(1,i)==A(1,i-1)
            index1=[index1,i];
        end
        if A(2,i)==A(2,i-1)
            index2=[index2,i];
        end
   end
    
    index=intersect(index1,index2);
    A(:,index)=[];
    
    index1=[];
    index2=[];
    
    % proc B
    
    for i =2:size(B,2)
        
        if B(1,i)==B(1,i-1)
            index1=[index1,i];
        end
        if B(2,i)==B(2,i-1)
            index2=[index2,i];
        end
    end
    
    index=intersect(index1,index2);
    B(:,index)=[];
    
    % deviation
    
    arr=[];
    for i=1:size(A,2)
        
        vector= A(:,i);
        find1=find(B(1,:)==vector(1));
        find2=find(B(2,:)==vector(2));
        findtotal=intersect(find1,find2);
        if isempty(findtotal)
            error_temp=[-9*ones(N_rows,1);vector];
            error=[error,error_temp];
        else
            for j=1:length(findtotal)
                
                if ~ismember(findtotal(j),arr)
                    arr=[arr,findtotal(j)];
                    % caculate error
                    error_temp= abs((M_sim(:,i)-M_resim(:,findtotal(j)))./M_sim(:,i));
                    error_temp= [error_temp;A(:,i)];
                    error=[error,error_temp];
                    break;
                end
                
            end
        end
        
    end
end


end




