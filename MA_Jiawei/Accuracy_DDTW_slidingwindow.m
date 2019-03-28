%% Compare dtw_label_data with ground truth label data
clc;
tic;


data = load ('C:\Users\scuwa\Desktop\MA_Jiawei\DDTW_results_lat.mat');
gt = load('E:\CM_Projects\CM7_Highway\src\true_label.mat');

lstart_time = data.lstart_time ;
lstop_time = data.lstop_time;

frequence = 1/(gt.Time(2) - gt.Time(1));

shift_time = data.shift / frequence ;
windlen_time = data.windLen /frequence ;

ddtw_labeling_ego = data.labeling_ego ;
ddtw_labeling_object = data.labeling_object ;

gt_labeling_ego_long = gt.label.ego.long ;
gt_labeling_ego_lat = gt.label.ego.lat ;

gt_labeling_object_long = gt.label.TObj.long ;
gt_labeling_object_lat = gt.label.TObj.lat ;

gt_start_time = data.start_time;
gt_stop_time = data.stop_time;

NumberOfLoop = data.nrOfLoop;

m = 1;
m1 = 1;
m2 = 1;
m3 = 1;
m4 = 1;
k = 1;
k1 =1;
k2 = 1;
k3 =1;
k4 = 1 ;
q = 1;
q1 = 1;
nrofrightmatch = 0;                         % number of matched lane change right
nrofleftmatch = 0;                          % number of matched lane change left
nrofdtwright = 0;                           % number of dtw lane change right
nrofdtwleft = 0;                            % number of dtw lane change left 

start_time_ego = zeros();
stop_time_ego = zeros();
labeling_ego = zeros();

start_time_object = zeros();
stop_time_object= zeros();
labeling_object = zeros();

gt_start_time_ego = zeros();
gt_stop_time_ego = zeros();
gt_labeling_ego = zeros();

gt_start_time_object = zeros();
gt_stop_time_object= zeros();
gt_labeling_object = zeros();

min_dtw_ego = zeros();
min_dtw_object = zeros();
min_start_time_ego = zeros();
min_start_time_object = zeros();

min_stop_time_ego = zeros();
min_stop_time_object = zeros();

%% choose the results according to the number of Slidingwindow (For exsample : less than 5 X Sliding Window results )

for n = 2 : NumberOfLoop - 2
    
    if ddtw_labeling_ego(n) == ddtw_labeling_ego(n - 1) &&  ddtw_labeling_ego(n) ~= 0
        
        m = m + 1; 
               
     else
              if m >= 5
                 A = data.ddtw_d_ego(n-m: n -1);
                 [B,p] = min(A);      
                 I =[p-2;p-1;p;p+1;p+2];            
                 for j = 1 : length(A)
                     if ismember(j, I) == 1
                         ddtw_labeling_ego(n-m-1+j) = ddtw_labeling_ego(n-m-1+j);
                     else
                         ddtw_labeling_ego(n-m-1+j) = 0;
                     end                    
                 end                
              end 
        m = 1;
    end
     
% Object results sorting

    if ddtw_labeling_object(n) == ddtw_labeling_object(n -1) &&  ddtw_labeling_object(n) ~= 0
        
        m1 = m1 + 1; 

     else
              if m1 >= 5
                A = data.ddtw_d_object(n-m1 : n -1);
                [B,p] = min(A); 
                 I =[p-2;p-1;p;p+1;p+2];                
                 for j = 1 : length(A)
                     if ismember(j, I) == 1
                         ddtw_labeling_object(n-m1-1+j) = ddtw_labeling_object(n-m1-1+j);
                     else
                         ddtw_labeling_object(n-m1-1+j) = 0;
                     end                    
                 end                
              end 
        m1 = 1; 
     end

end

%% DTW labeling Ego and Object
for n = 1 : NumberOfLoop - 2
 % Ego labeling resuts
    if ddtw_labeling_ego(n) == ddtw_labeling_ego(n +1)  
        start_time_ego(k) = start_time_ego(k);
        stop_time_ego(k) = lstop_time(n+1) ;
        labeling_ego(k) = ddtw_labeling_ego(n);            
    else
        k = k + 1;
        start_time_ego(k) = lstart_time(n+1);
        stop_time_ego(k) = lstop_time(n+1) ;
        labeling_ego(k) = ddtw_labeling_ego(n+1);        
    end
    
  % Object labeling results
  
    if ddtw_labeling_object(n) == ddtw_labeling_object(n +1)  
        start_time_object(k1) = start_time_object(k1);
        stop_time_object(k1) = lstop_time(n+1) ;
        labeling_object(k1) = ddtw_labeling_object(n);           
    else
        k1 = k1 + 1;
        start_time_object(k1) = lstart_time(n+1);
        stop_time_object(k1) = lstop_time(n+1) ;       
        labeling_object(k1) = ddtw_labeling_object(n+1);    
    end        
end

for n = 1:k
    if labeling_ego(n) ==0       
        if n == 1
           start_time_ego(n ) = 0;
           stop_time_ego(n ) = start_time_ego(n + 1 ) ;
        elseif n < k && n > 1
           start_time_ego(n ) = stop_time_ego(n-1);
           stop_time_ego(n ) = start_time_ego(n + 1 ) ;
        else
            start_time_ego(n ) = stop_time_ego(n-1);
        end        
    end
    
    labeling_ego_new(1,fix(start_time_ego(n )*frequence) + 1 : fix(stop_time_ego(n)*frequence)) = labeling_ego(n);
    
end

for n = 1:k1
    if labeling_object(n) ==0
        if n ==1
           start_time_object(n ) = 0;
           stop_time_object(n ) = start_time_object(n + 1 ) ;
        elseif n < k1 && n > 1
           start_time_object(n ) = stop_time_object(n-1);
           stop_time_object(n ) = start_time_object(n + 1 ) ;
        else
            start_time_object(n ) = stop_time_object(n-1);
        end        
    end
    
    labeling_object_new(1,fix(start_time_object(n )*frequence) + 1 : fix(stop_time_object(n)*frequence)) = labeling_object(n);
    
end

%% Ground Truth label Ego and Object
for n = 1 : length(gt_start_time) - 1
 %   Ground Truth label Ego  
    if gt_labeling_ego_lat(n) == gt_labeling_ego_lat(n+1)
        gt_start_time_ego(k2) = gt_start_time_ego(k2);
        gt_stop_time_ego(k2) = gt_stop_time(n+1) ;
        gt_labeling_ego(k2) = gt_labeling_ego_lat(n);
    else
         k2 = k2 + 1;
        gt_start_time_ego(k2) = gt_stop_time(n);
        gt_stop_time_ego(k2) = gt_stop_time(n+1) ;
        gt_labeling_ego(k2) = gt_labeling_ego_lat(n+1);        
    end
    
 %   Ground Truth label Object   
    if  gt_labeling_object_lat(n) == gt_labeling_object_lat(n+1)
        
        gt_start_time_object(k3) = gt_start_time_object(k3);
        gt_stop_time_object(k3) = gt_stop_time(n+1) ;
        gt_labeling_object(k3) = gt_labeling_object_lat(n);

    else
        k3 = k3 + 1;
        gt_start_time_object(k3) = gt_stop_time(n);
        gt_stop_time_object(k3) = gt_stop_time(n+1) ;
        gt_labeling_object(k3) = gt_labeling_object_lat(n+1);

    end
    
end


%% Accuracy calculate
% DTW Accuracy for Ego lat.
gt_labeling_ego_lat = gt_labeling_ego_lat(1,1 : length(labeling_ego_new));
gt_stop_time_ego(k2) = gt_stop_time_ego(k2) - (length(gt_labeling_ego_long) - length(labeling_ego_new))/frequence;
for n = 1 : k2    
      A = gt_labeling_ego_lat(1,fix(gt_start_time_ego(n )*frequence) + 1 : fix(gt_stop_time_ego(n)*frequence));
      B = labeling_ego_new(1,fix(gt_start_time_ego(n )*frequence) + 1 : fix(gt_stop_time_ego(n)*frequence));                
      m=length(A);
      Sum=1;
      for j=1:m
          if A(1,j) == B(1,j)
             Sum=Sum+1;
          end
      end          
     accuracy_ego(n) = Sum/m*100;
end

gt_labeling_object_lat = gt_labeling_object_lat(1,1 : length(labeling_object_new));
gt_stop_time_object(k3) = gt_stop_time_object(k3) - (length(gt_labeling_object_long) - length(labeling_object_new))/frequence;
for n = 1 : k3    
      A = gt_labeling_object_lat(1,fix(gt_start_time_object(n )*frequence) + 1 : fix(gt_stop_time_object(n)*frequence));
      B = labeling_object_new(1,fix(gt_start_time_object(n )*frequence) + 1 : fix(gt_stop_time_object(n)*frequence));                
      m=length(A);
      Sum=1;
      for j=1:m
          if A(1,j) == B(1,j)
             Sum=Sum+1;
          end
      end          
     accuracy_object(n) = Sum/m*100;
end
    
%% Output
%  accuracy_ego_lat_right = nrofrightmatch / nrofdtwright;
%  accuracy_ego_lat_left = nrofleftmatch / nrofdtwleft;

results_ego_lat = [start_time_ego', stop_time_ego', labeling_ego' ];
results_object_lat = [ start_time_object', stop_time_object', labeling_object' ];
results_gt_ego_lat = [gt_start_time_ego', gt_stop_time_ego', gt_labeling_ego', accuracy_ego' ];
results_gt_object_lat = [ gt_start_time_object', gt_stop_time_object', gt_labeling_object' ,accuracy_object'];
                  
results_cell_ego_lat = num2cell(results_ego_lat);  
results_cell_object_lat = num2cell(results_object_lat);
results_cell_gt_ego_lat = num2cell(results_gt_ego_lat);  
results_cell_gt_object_lat = num2cell(results_gt_object_lat);  

title1 = { 'Maneuver start time', 'Maneuver stop time', 'DDTW Labeling Ego lat' };
title2 = { 'Maneuver start time', 'Maneuver stop time', 'DDTW Labeling Object lat'};

title3 = { 'Maneuver start time', 'Maneuver stop time', 'Ground Truth Labeling Ego lat','Accuracy(%)' };
title4 = { 'Maneuver start time', 'Maneuver stop time', 'Ground Truth Labeling Object lat','Accuracy(%)'};

output1 = [title1 ; results_cell_ego_lat ]; 
output2 = [title2 ;  results_cell_object_lat]; 
output3 = [title3 ; results_cell_gt_ego_lat ]; 
output4 = [title4 ;  results_cell_gt_object_lat]; 

rowNr = 3;
cellnames_ego =['A',num2str(rowNr),':C',num2str(k + rowNr )];
cellnames_gt_ego =['E',num2str(rowNr),':H',num2str(k2 + rowNr)];

cellnames_object =['K',num2str(rowNr),':M',num2str(k1+ rowNr)];
cellnames_gt_object =['O',num2str(rowNr),':R',num2str(k3 + rowNr)];

save output.mat;

% cell_Index = max(k,k1,k2,k3);
% rowNr = rowNr + cell_Index;
% 
% Output_label1 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_dtw_slidingwindow.xlsx',output1 ,'results',cellnames_ego);
% Output_label2 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_dtw_slidingwindow.xlsx',output2 ,'results',cellnames_object);
% Output_label3 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_dtw_slidingwindow.xlsx',output3 ,'results',cellnames_gt_ego);
% Output_label4 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_dtw_slidingwindow.xlsx',output4 ,'results',cellnames_gt_object);

Output_label1 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_dtw_slidingwindow.xlsx',output1 ,'results_ddtw',cellnames_ego);
Output_label2 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_dtw_slidingwindow.xlsx',output2 ,'results_ddtw',cellnames_object);
Output_label3 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_dtw_slidingwindow.xlsx',output3 ,'results_ddtw',cellnames_gt_ego);
Output_label4 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_dtw_slidingwindow.xlsx',output4 ,'results_ddtw',cellnames_gt_object);

toc;
 
 