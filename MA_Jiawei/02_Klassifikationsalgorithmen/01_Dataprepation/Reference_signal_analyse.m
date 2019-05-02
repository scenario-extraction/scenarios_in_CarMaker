%% Reference signal 

[Rsignal.ego.lcr , txt1] = xlsread('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Reference_signal.xlsx','Rsignal_lcr');
[Rsignal.ego.lcl , txt2] = xlsread('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Reference_signal.xlsx','Rsignal_lcl');

[Rsignal.object.lcr , txt3] = xlsread('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Reference_signal.xlsx','Object_rsignal_lcr');
[Rsignal.object.lcl , txt4] = xlsread('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Reference_signal.xlsx','Object_rsignal_lcl');

R_Time_ego_lcr = Rsignal.ego.lcr(: , 1); 
R_DisToLeft_lcr= Rsignal.ego.lcr(: , 6);
R_Time_ego_lcl = Rsignal.ego.lcl(: , 1);
R_DisToLeft_lcl = Rsignal.ego.lcl(: , 6);

R_Time_object_lcr = Rsignal.object.lcr(: , 1);   
R_ds_y_lcr = Rsignal.object.lcr(: , 4); 
R_Time_object_lcl = Rsignal.object.lcl(: , 1);  
R_ds_y_lcl = Rsignal.object.lcl(: , 4);   


figure
subplot(2,2,1);
plot(R_Time_ego_lcl, R_DisToLeft_lcl ,'linewidth',2);
title('Reference signal - Ego lane chang left')
xlabel('Time');
ylabel('Ego-Distance to left lane [m]');
hold on;

subplot(2,2,2);
plot(R_Time_ego_lcr, R_DisToLeft_lcr ,'linewidth',2);
title('Reference signal - Ego lane chang right')
xlabel('Time');
ylabel('Ego-Distance to left lane [m]');
hold on;

subplot(2,2,3);
plot(R_Time_object_lcl, R_ds_y_lcl ,'linewidth',2);
title('Reference signal - Object lane chang left')
xlabel('Time');
ylabel('Object-Distance to left lane [m]');
hold on;

subplot(2,2,4);
plot(R_Time_object_lcr, R_ds_y_lcr ,'linewidth',2);
title('Reference signal - Object lane chang right')
xlabel('Time');
ylabel('Object-Distance to left lane [m]');
hold on;







