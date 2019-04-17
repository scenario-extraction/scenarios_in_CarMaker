% create the prediction model for velocity
function vel_pred_total=velocity_pred(long_ego)

vel_pred=[];
vel_pred_total=[];

for k=1:size(long_ego,2)
    
    v_i=long_ego(2,k);
    v_f=long_ego(3,k);
    t_a=long_ego(4,k);
    x_a=long_ego(5,k);
    
    if k==1
        t_arr=(0:0.02:t_a); % sampling rate of 50 Hz
    else
        t_arr=(0.02:0.02:t_a); 
    end
   
    
    v_average=x_a/t_a; % average vel
    thetha=(v_average-v_i)/(v_f-v_i); % calculate the parameter Theta from akcelik and al. model
       
    if (thetha>=0.48 && thetha<=0.52) ||  t_a<=1
        
        % fit with a line a(x-b)+c
        b=v_i;
        a=(v_f-v_i)/t_a;
        vel_pred=arrayfun(@(x) a*x+b,t_arr);
        
        
    elseif (thetha>0.52 && thetha<=0.7) || (thetha<0.48 && thetha>=0.3) %fit with a quadratic polynom
        
        syms a b c
        eqns = [c == v_i, a*(t_a^2)+b*(t_a)+c==v_f, (a/3)*(t_a^3)+(b/2)*(t_a^2)+c*t_a== x_a];
        vars = [a b c];
        [sola, solb, solc] = vpasolve(eqns, vars); % solve numerically
        a=double(sola);
        b=double(solb);
        c=double(solc);
        vel_pred=arrayfun(@(x) a*x^2+b*x+c,t_arr);
        
        
    elseif (thetha< 0.3   ||  thetha>0.7) && v_f>=v_i % fit with expo func for increasing func
        
        flag=1;
        a=v_f-v_i;
        b=v_i;
        t=find_tau(flag,a,b,x_a, t_arr);
        vel_pred=arrayfun(@(x) a*(1-exp(-x/t))+b,t_arr);
        

    elseif (thetha< 0.3  ||  thetha>0.7) && v_f<v_i % fit for decreasing func
        
        flag=-1;
        b=v_f;
        a=v_i-v_f;
        t=find_tau(flag,a,b,x_a, t_arr);
        vel_pred=arrayfun(@(x) a*exp(-x/t)+b,t_arr);
        
    end
%     if k~=1
%         
%         vel_pred=vel_pred(2:end);
%         
%     end
    vel_pred_total=[vel_pred_total,vel_pred];  %concatenate the new predicted velocities values to the old vel_pred_total matrix
    
end

end

