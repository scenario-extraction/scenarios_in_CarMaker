% this function provides a prediction of absolute lateral position profile 
%based on sinus model for lane change actions. Like the function predicting
%long. velocity, this function takes the matrix describing the lateral
%kinematics of the object which contains the lateral displacement or the
%intended lane change diatance.
% to do: estimate the initial offset from the lat_Matrix!
function lat_pred_total= lat_pos_pred(lat_M)

lat_pred_total=[];

for i=1:size(lat_M,2)
    if i==1
        t_arr=0:0.02:lat_M(2,i);
    else 
        t_arr=0.02:0.02:lat_M(2,i);
    end
    t_arr=round(t_arr,2);
    t_lc=lat_M(2,i);
        
    %% get the lateral displacement from the input matrix
    if i==1
        H=abs(lat_M(3,i));
    else
        H=abs((lat_M(3,i)-lat_M(3,i-1)));
    end
    if  i==1
        dy0 = 0; % initial lat. offset
    else
        dy0= lat_M(3,i-1);
    end
    %% prediction model
    % the prediction of the lateral kinematics is as follow:
    %1- linear approximation for lane keeping and unknown maneuver
    %2- sine function model for lane change based on the model from Enke et al. 1979
    
    if lat_M(end,i)==0 % if lane keeping
        if i==1
            lat_pred=arrayfun(@(x) x*0+lat_M(3,i),t_arr);
        else
            value_lat_temp = (lat_M(3,i)+lat_M(3,i-1))*0.5; % create mean btween two values of lat. pos
            lat_pred=arrayfun(@(x) x*0+value_lat_temp,t_arr);
        end

    elseif lat_M(end,i)==-9  || (lat_M(2,i)<3) % 
        if i==1
            a=lat_M(3,i)/lat_M(2,i);
            b=0;
        else
            a=(lat_M(3,i)-lat_M(3,i-1))/(lat_M(2,i));
            b=lat_M(3,i)-a*t_lc;
        end
        lat_pred=arrayfun(@(x) a*x+b,t_arr);

        % fit with sinus func
    elseif lat_M(end,i)==-1 % fit LCL
           
        lat_pred=arrayfun(@(t) (H*t/t_lc)-(H/(2*pi))*sin(2*pi*t/t_lc)+dy0, t_arr);

    elseif lat_M(end,i)==1 % fit LCR 

        H=-H;
        lat_pred=arrayfun(@(t) (H*t/t_lc)-(H/(2*pi))*sin(2*pi*t/t_lc)+dy0, t_arr);

    else %
        
    end
     
    lat_pred_total=[lat_pred_total,lat_pred];
end
end
