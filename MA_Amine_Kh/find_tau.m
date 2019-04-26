% find the time constant of an exponential fit

function tau=find_tau(flag,a,b,dist_soll, t_arr)

h=0;
tau_arr=[];
dist_error=[];

if flag==1
    for i=-100:0.5:100
        h=h+1;
        dist_error(h)=abs(trapz(t_arr,a*(1-exp(-t_arr/i))+b)-dist_soll);
        tau_arr(h)=i;
        
    end
    tau=tau_arr(dist_error==min(dist_error));
    
elseif flag==-1
    for i=-100:0.5:100
        h=h+1;
        dist_error(h)=abs(trapz(t_arr,a*exp(-t_arr/i)+b)-dist_soll);
        tau_arr(h)=i;
        
    end
    tau=tau_arr(dist_error==min(dist_error)); % get the time constant whereby the respective absolute error between of the  displacement and the 
                                           %is the smallest 
end
 
 end
 

 
