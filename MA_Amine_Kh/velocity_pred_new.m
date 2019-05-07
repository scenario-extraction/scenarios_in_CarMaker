% this function provides a prediction of the whole velocity profile and has
% as an input the matrix created by the functions build_long_matrix.m for ego
% and create_long.m for TObj. The prediction is done in the for loop for
% every single motion segment (every column in the Matrix) and then the
% final predicted is obtained by appending the current predicted values in
% each iteration

function vel_pred_total=velocity_pred_new(long_ego)

vel_pred_total=[];

for k=1:size(long_ego,2)
    % get the data from the input matrix
    v_i=long_ego(2,k); % initial velocity
    v_f=long_ego(3,k); % final target velocity 
    t_a=long_ego(4,k); % duration
    x_a=long_ego(5,k); % long. displacement
    
    if k==1
        t_arr=(0:0.02:t_a); % sampling rate of 50 Hz
    else
        t_arr=(0.02:0.02:t_a);
    end
    
    v_average=x_a/t_a; % average velocity
    
    % calculate the parameter ru from akcelik and al. model
    ru=(v_average-v_i)/(v_f-v_i); 
    
    %% prediction based on the value of ru parameter
    if abs(ru)==inf  || long_ego(end,k)==0
        vel_pred=arrayfun(@(x) 0*x+v_i,t_arr);
        
    elseif (ru>=0.45 && ru<=0.55)
        
        % fit with a line a(x-b)+c
        b=v_i;
        a=(v_f-v_i)/t_a;
        vel_pred=arrayfun(@(x) a*x+b,t_arr);
        
        
    elseif (ru>0.55 && ru<=0.6) || (ru<0.45 && ru>=0.35)
         %fit with a quadratic polynom
        syms a b c
        eqns = [c == v_i, a*(t_a^2)+b*(t_a)+c==v_f, (a/3)*(t_a^3)+(b/2)*(t_a^2)+c*t_a== x_a];
        vars = [a b c];
        [sola, solb, solc] = vpasolve(eqns, vars); % solve numerically
        a=double(sola);
        b=double(solb);
        c=double(solc);
        vel_pred=arrayfun(@(x) a*x^2+b*x+c,t_arr); 
      
    else
        % prediction based on akcelik et al. model
        [vel_pred, ~,~]= akcelik_model(v_i,v_f,t_a,t_arr,ru); 
    
        
    end
    vel_pred_total=[vel_pred_total,vel_pred];  %concatenate the new predicted velocities values to the old vel_pred_total matrix
    
end

end

