% this function provides a prediction of absolute lateral position profile
%based on sinus model for lane change actions. Like the function predicting
%long. velocity, this function takes the matrix describing the lateral
%kinematics of the object which contains the lateral displacement or the
%intended lane change diatance.
%% ToDo: estimate the initial offset from the lat_Matrix!
function lat_pred_total= lat_pos_pred(lat_M)

lat_pred_total=[];

for i=1:size(lat_M,2)
    lat_M(2,i) = round(lat_M(2,i),2);
    if i==1
        t_arr=0:0.02:lat_M(2,i);
    else
        t_arr=0.02:0.02:lat_M(2,i);
    end
    t_arr=round(t_arr,2);
    t_lc=lat_M(2,i);
    
    %% get the lateral displacement from the input matrix
    if i==1
        H=(lat_M(3,i));
    else
        H=((lat_M(3,i)-lat_M(3,i-1)));
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
    
    if lat_M(end,i)==0   % if lane keeping
        if i==1 || find(lat_M(end,:)==0,1,'first')==2
            lat_pred=arrayfun(@(x) x*0+lat_M(3,i),t_arr);
        else
            a = H/t_lc;
            b = dy0;
            lat_pred=arrayfun(@(x) x*a+b,t_arr);
        end
        
    elseif lat_M(end,i)==-9
        lat_pred=arrayfun(@(x) x*0+lat_M(3,i),t_arr);
        
        % fit with sinus func
    elseif abs(lat_M(end,i))==1 % fit Lane change
        
        lat_pred=arrayfun(@(t) (H*t/t_lc)-(H/(2*pi))*sin(2*pi*t/t_lc)+dy0, t_arr); % Enke 1979
    end
    
    lat_pred_total=[lat_pred_total,lat_pred];
end
end