%% Data from CarMaker Konfiguration prepation fpr Analyse
clc;
clear;
go2srt = 'E:\CM_Projects\CM7_Highway\src';
cd(go2srt);
run cmenv.m;
clear('go2srt')
% % cd 'C:\CM_Projects\CM7_Highway\src\NeuralNetTObj';
% data=cmread('E:\CM_Projects_All\CM7_Highway\SimOutput\LAPTOP-HNJRQ4FK\20190319\Ground_Truth_label_Highwat_01.dat_191927.erg');
data=cmread('E:\CM_Projects\CM7_Highway\SimOutput\Ground_Truth_label_Highway_01_new_OT_1.erg');
clear('go2srt');
Time = data.Time.data;
Ego_DisToLeft = data.LatCtrl_DistToLeft.data;
Ego_ay =  data.Car_ay.data;
Ego_v =  data.Car_v.data;
% Turning_radius = Ego_v ^2 / abs(Ego_ay);
CarYaw = data.Car_Yaw.data /pi * 180;
RefPont_alpha = data.Sensor_Object_OB01_relvTgt_RefPnt_alpha.data;
% NearPont_alpha = data.Sensor_Object_OB01_relvTgt_NearPnt_alpha.data;
PathDivAng = data.Sensor_Road_RD00_Path_DevAng.data / pi * 180; % Deviation angle at preview point along path / route (rad)
PathCurve = data.Sensor_Road_RD00_Path_CurveXY.data;            % Route / path curvature at x-y plane at preview point (1/m)
ObjID = data.Sensor_Object_OB01_relvTgt_ObjId.data;
ds_x = data.Sensor_Object_OB01_relvTgt_RefPnt_ds_x.data;
ds_y = data.Sensor_Object_OB01_relvTgt_RefPnt_ds_y.data;
% TimeStamp = 
delta_dsy = ds_y - Ego_DisToLeft ;

for n=1:length(Time)
    Turning_radius(1,n) = Ego_v(1,n) ^2 / abs(Ego_ay(1,n));
    PathRadius(1,n) = 1 / PathCurve(1, n);
    
     if n == length(Time)
        Refenrenz0(1,n) =  Refenrenz0(1,n-1);
     elseif ObjID(1,n+1) == ObjID(1,n)
        Refenrenz0(1,n) = 0;
     else 
         Refenrenz0(1,n) = 20;
     end
  
end

clear('ans','data','n','ObjID')
save('prepdataForObjektAnalyse.mat');
