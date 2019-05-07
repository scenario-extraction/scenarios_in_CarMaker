% predict velocity based on Akcelik  Model 
function [vel,m,B] =  akcelik_model(v_i,v_f,t_a,t_arr, ru)

a_avg= (v_f-v_i)/t_a; % calculate average acceleration

m = (15-27*ru+sqrt(81*ru*ru-138*ru+73))/(12*ru-4); % calculate calibration parameter m

B = (2*(m+1)*(m+2)*a_avg)/(m^2);% model parameter

acc = arrayfun(@(x) B*(x/t_a)*(1-(x/t_a)^m)^2,t_arr);% acc profile prediction

% velocity prediction: integration of the predicted acceleration
vel = cumtrapz(t_arr,acc)+v_i; 

end
