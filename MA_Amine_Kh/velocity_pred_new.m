% this function provides a prediction of the whole velocity profile and has
% as an input the matrix created by the functions build_long_matrix.m for ego
% and create_long.m for TObj. The prediction is done in the for loop for
% every single motion segment (every column in the Matrix) and then the
% final predicted is obtained by appending the current predicted values in
% each iteration

function vel_pred_total=velocity_pred_new(M)

vel_pred_total=[];
%% round time values to 2 decimals
M(1,:) = round(M(1,:),2);
M(4,:) = round(M(4,:),2);

%%
for k=1:size(M,2)
    % get the data from the input matrix
    v_i=M(2,k); % initial velocity
    v_f=M(3,k); % final target velocity
    t_a=M(4,k); % duration
    x_a=M(5,k); % long. displacement
    
    if k==1
        t_arr=(0:0.02:t_a); % sampling rate of 50 Hz
    else
        t_arr=(0.02:0.02:t_a);
    end
    % round time interval
    t_arr = round(t_arr,2);
    v_average=x_a/t_a; % average velocity
    
    % calculate the parameter ru from akcelik and al. model
    ru=(v_average-v_i)/(v_f-v_i);
    %disp(strcat('ru_k=',num2str(ru)));
    %% prediction based on the value of ru parameter
    if M(end,k)==-9
        if k==size(M,2)
            b=v_i;
            %a=(v_f-v_i)/t_a;
            vel_pred=arrayfun(@(x) 0*x+b,t_arr);
            
        else
            b=v_f;
            vel_pred=arrayfun(@(x) 0*x+b,t_arr);
            
        end
    elseif  abs(ru)==inf  || M(end,k)==0 || ((ru>=0.4 && ru<=0.55) && (abs(M(end,k))==1))
        
        % fit with a line a(x-b)+c
        b=v_i;
        a=(v_f-v_i)/t_a;
        vel_pred=arrayfun(@(x) a*x+b,t_arr);
        
    elseif   ((ru>0.55 && ru<=0.7)|| (ru<0.4 && ru>=0.3)) && M(end,k)==1
        
%         %fit with a quadratic polynom
        syms a b c
        eqns = [c == v_i, a*(t_a^2)+b*(t_a)+c==v_f, (a/3)*(t_a^3)+(b/2)*(t_a^2)+c*t_a== x_a];
        vars = [a b c];
        [sola, solb, solc] = vpasolve(eqns, vars); % solve numerically
        a=double(sola);
        b=double(solb);
        c=double(solc);
        vel_pred=arrayfun(@(x) a*x^2+b*x+c,t_arr);

        
        
        
    else
        %prediction based on akcelik et al. model of the dec. profil
        [vel_pred, ~,~]= akcelik_model(v_i,v_f,t_a,t_arr,ru);
        
    end
    a=0;
    b=0;
    c=0;
    
    vel_pred_total=[vel_pred_total,vel_pred];  %concatenate the new predicted velocities values to the old vel_pred_total matrix
    
end

end

