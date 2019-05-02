%%  Label Ego and Object in longitudinal with delta vx (1 = acceleration, 0 = static cruising, -1= decceleration)
%  S is the orignal signal
%  data is the output from Ego Sensors

clc;
tic;
%% load CM data

 data=cmread('C:\CM_Projects\CM7_Highway\SimOutput\Ground_Truth_label_Highway_01.erg');
% data=cmread(path2ergfile);

%% Channel Selection
Time = data.Time.data;

%% Sinal from Sensors
Ego.Car.ax = data.Car_ax.data;
Ego.Car.vx = data.Car_vx.data;
Ego.Car.ay= data.Car_ay.data;
Ego.Car.vy = data.Car_vy.data;
Object.Car.dv_x = data.Sensor_Object_OB01_relvTgt_RefPnt_dv_x.data;  % Speed difference of the traffic object in x-direction in sensor frame
Object.Car.dv_y = data.Sensor_Object_OB01_relvTgt_RefPnt_dv_y.data;  % Speed difference of the traffic object in x,y,z-direction in sensor frame
Object.Car.vx = Ego.Car.vx  + Object.Car.dv_x ;
Object.Car.vy = Ego.Car.vy  + Object.Car.dv_y ;

%% Label Longitudinal (Ego and object)

 label.ego.long(1:length(Time))=0;

for n=2:length(Time)
     if Ego.Car.vx(n) - Ego.Car.vx(n - 1) > 0.01        % "acceleration"
         label.ego.long(n) = 1;
     elseif Ego.Car.vx(n) - Ego.Car.vx(n - 1) < - 0.01   % "decceleration"
         label.ego.long(n) = -1;
     else 
         label.ego.long(n) = 0;                          % "static cruising"
     end
     
     if Object.Car.vx(n) - Object.Car.vx(n - 1) > 0.01        % "acceleration"
         label.Object.long(n) = 1;
     elseif Object.Car.vx(n) - Object.Car.vx(n - 1) < - 0.01   % "decceleration"
         label.Object.long(n) = -1;
     else 
         label.Object.long(n) = 0;                          % "static cruising"
     end
     
end

%% Results output

results = [Time', Ego.Car.vx' , label.ego.long' , Object.Car.vx' ,label.Object.long'];
     
results_cell = num2cell(results);  

title = {'Time', 'Ego car vx', 'label ego long', 'Object car vx', 'label object long' };

output = [title ; results_cell];  

Output_label = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\DTW_results_highway_01_test.xlsx',output ,'Label_long');

clear ('data','title');

toc;
