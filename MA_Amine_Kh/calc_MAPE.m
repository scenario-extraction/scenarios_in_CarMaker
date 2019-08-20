% function to calculate MAPE error
function MAPE= calc_MAPE(a,b)

a_temp =a;
b_temp=b;

if length(a_temp) == length(b_temp)
    N= length(a_temp);
    for i=1:N
        
        % process array a and b data for the issue of dividing by zero by
        % weigthing the error through the respective value of the
        % prediction
        if a_temp(i) ==0
            if b_temp(i)==0
                a_temp(i)=1;
                b_temp(i)=1;
            else
                a_temp(i)=b_temp(i)/(1+b_temp(i));
            end
        end
    end
    
    % MAPE in %
    MAPE = (100/N)*(sum(abs((a_temp-b_temp)./a_temp)));
    
else
    MAPE= -9999;
end

end