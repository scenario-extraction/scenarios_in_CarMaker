function [outputArg1] = datapreparation(~)

% ---This is for preparing the recorded data for following analysis steps



%% load CM data
clc;
clear;

go2srt = 'E:\CM_Projects\CM7_Highway\src';
cd(go2srt);
clear('go2srt');

% data=cmread('E:\CM_Projects_All\CM7_Highway\SimOutput\LAPTOP-HNJRQ4FK\20190319\Ground_Truth_label_Highwat_01.dat_192453.erg');
 data=cmread('E:\CM_Projects\CM7_Highway\SimOutput\Ground_Truth_label_Highway_32.erg');
% data=cmread('E:\CM_Projects\CM7_Highway\SimOutput\Ground_Truth_label_Highway_01_new_OT_1.erg');
% data=cmread('E:\CM_Projects\CM7_Highway\SimOutput\Ground_Truth_label_Highwat_01_TrafficRight_EgoLeft.dat_100.erg');
% data=cmread(path2ergfile);

%% Reference signal 
[Rsignal.ego.lcr , txt1] = xlsread('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Reference_signal.xlsx','Rsignal_lcr');
[Rsignal.ego.lcl , txt2] = xlsread('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Reference_signal.xlsx','Rsignal_lcl');

[Rsignal.object.lcr , txt3] = xlsread('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Reference_signal.xlsx','Object_rsignal_lcr');
[Rsignal.object.lcl , txt4] = xlsread('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Reference_signal.xlsx','Object_rsignal_lcl');


%% Channel Selection
Time = data.Time.data;
%% Ground Truth Ego Maneuvers

Ego.Car.ax = data.Car_ax.data;
Ego.Car.Yaw = data.Car_Yaw.data;
Ego.Car.ay= data.Car_ay.data;
Ego.Car.SteerAngle = data.VC_Steer_Ang.data;
Ego.Car.DisToLeft= data.LatCtrl_DistToLeft.data;

Ego.Lane.Act_LaneId = data.Car_Road_Lane_Act_LaneId.data;
Ego.Lane.Act_width = data.Car_Road_Lane_Act_Width.data;
Ego.Lane.Left_width = data.Car_Road_Lane_OnLeft_Width.data;
Ego.Lane.Right_width = data.Car_Road_Lane_OnRight_Width.data;
Ego.Lane.DevDist = data.Car_Road_Path_DevDist.data;


Ego_DisToLeft = data.LatCtrl_DistToLeft.data;
Ego_ay =  data.Car_ay.data;
Ego_v =  data.Car_v.data;
% Turning_radius = Ego_v ^2 / abs(Ego_ay);

CarYaw = data.Car_Yaw.data /pi * 180;
RefPont_alpha = data.Sensor_Object_OB01_relvTgt_RefPnt_alpha.data;
% NearPont_alpha = data.Sensor_Object_OB01_relvTgt_NearPnt_alpha.data;
PathDivAng = data.Sensor_Road_RD00_Path_DevAng.data / pi * 180;  % Deviation angle at preview point along path / route (rad)
PathCurve = data.Sensor_Road_RD00_Path_CurveXY.data;             % Route / path curvature at x-y plane at preview point (1/m)
ObjID = data.Sensor_Object_OB01_relvTgt_ObjId.data;
ds_x = data.Sensor_Object_OB01_relvTgt_RefPnt_ds_x.data;
ds_y = data.Sensor_Object_OB01_relvTgt_RefPnt_ds_y.data;
delta_dsy = ds_y - Ego_DisToLeft ;

% ds_x = data.Sensor_Object_OB01_relvTgt_NearPnt_ds_x.data;
% ds_y = data.Sensor_Object_OB01_relvTgt_NearPnt_ds_y.data;



for n=1:length(Time)
    
    Turning_radius(1,n) = Ego_v(1,n) ^2 / abs(Ego_ay(1,n));
    PathRadius(1,n) = 1 / PathCurve(1, n);
    y_off(1,n) = (PathRadius(1,n)- sqrt(PathRadius(1,n)^2 - ds_x(1,n)^2 ))* sign(Ego_ay(1,n)); % imaginary vehicle offset in sensor frame at target position
    
    if ~isnan(y_off(1,n))
        ds_y(1,n) = ds_y(1,n) - y_off(1,n);     %  To avoid the curve influence the accuracy
    end
        
   
     if n == length(Time)
        Refenrenz0(1,n) =  Refenrenz0(1,n-1);
     elseif ObjID(1,n+1) == ObjID(1,n)
        Refenrenz0(1,n) = 0;
     else 
         Refenrenz0(1,n) = 20;
     end
  
end

clear('ans','n','ObjID','txt1','txt2','txt2','txt4')

save('prepdataForObjektAnalyse.mat');


%% Ground Truth Dynamic Objects Maneuvers

%--------------------------------------------------------------------------
%Identificate Object
%Column 1: if there is a target exist
%Column 2: determine the target ID
%--------------------------------------------------------------------------
TObj.Flag = data.Sensor_Object_OB01_relvTgt_dtct.data';  
TObj.ObjID = data.Sensor_Object_OB01_relvTgt_ObjId.data';

for n=1:length(Time)
     if TObj.Flag(n) == 1 
        TObj.ObjID(n,2) = TObj.ObjID(n,1)- 227;             % Maximal munber of the Car: 227
     else 
          TObj.ObjID(n,2) =TObj.ObjID(n,1);
     end
  
end

%Load Data based on Objct ID


for n=1:length(Time)
    
    if TObj.ObjID(n,2) ~= -1 && TObj.ObjID(n,2) ~= 0
        ObjID = TObj.ObjID(n,2);
      
        eval(['TObj.Car.ax(n) = data.Traffic_T' num2str(ObjID) '_a_1_x.data(n) ' ])
        %name_string1 = ['TObj.Car.ax(n) = data.Traffic_T' num2str(ObjID) '_a_1_x.data(n) ' ];
        %eval(name_string1);
        %TObj.Car.ax(n) = data.Traffic_T ObjID_a_1_x.data;
        eval(['TObj.Lane.Act_LaneId(n) = data.Traffic_T' num2str(ObjID) '_Lane_Act_LaneId.data(n) ' ])
        %name_string2 = ['TObj.Lane.Act_LaneId(n) = data.Traffic_T' num2str(ObjID) '_Lane_Act_LaneId.data(n) ' ];
        %eval(name_string2);
        %T00.Lane.Act_LaneId = data.Traffic_T00_Lane_Act_LaneId.data;
       
        eval(['TObj.Lane.t2Ref(n) = data.Traffic_T' num2str(ObjID) '_t2Ref.data(n) ' ])
        %name_string3 = ['TObj.Lane.t2Ref(n) = data.Traffic_T' num2str(ObjID) '_t2Ref.data(n) ' ];
        %eval(name_string3);
        %TObj.Lane.t2Ref = data.Traffic_T00_t2Ref.data;
        
        eval(['TObj.Lane.t2Ref(n) = data.Traffic_T' num2str(ObjID) '_t2Ref.data(n) ' ])  
        
    elseif TObj.ObjID(n,2) ~= -1 && TObj.ObjID(n,2) == 0
        %% Attention! here should care the Init Objct ID: T00 or T0?
        
         
        TObj.Car.ax(n) = data.Traffic_T0_a_1_x.data(n);
        TObj.Lane.Act_LaneId(n) = data.Traffic_T0_Lane_Act_LaneId.data(n);
        TObj.Lane.t2Ref(n) = data.Traffic_T0_t2Ref.data(n);      
    else
        TObj.Car.ax(n) = 0;
        TObj.Lane.Act_LaneId(n) = 2;
        TObj.Lane.t2Ref(n) = 0;
    end

end


%save selected Data in mat file
clear ('data', 'path2ergfile','n','ObjID','name_string','name_string1');
clear('name_string2');
clear('name_string3');
save('prepdata.mat');

end
