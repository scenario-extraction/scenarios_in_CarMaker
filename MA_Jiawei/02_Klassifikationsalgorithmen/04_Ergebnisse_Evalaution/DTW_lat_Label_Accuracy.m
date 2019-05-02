%% Compare dtw_label_data with ground truth label data
clc;
tic;
%% Load DTW Label and Ground Truth Label
% data = load ('E:\CM_Projects\CM7_Highway\src\dtw_results_lat.mat');
data = load ('C:\Users\scuwa\Desktop\MA_Jiawei\dtw_results_lat.mat');
gt = load('E:\CM_Projects\CM7_Highway\src\true_label.mat');
lstart_time = data.lstart_time ;
lstop_time = data.lstop_time;
run_time = data.Runtime;
frequence = 1/(gt.Time(2) - gt.Time(1));
shift_time = data.shift / frequence ;
windlen_time = data.windLen /frequence ;
dtw_labeling_ego = data.labeling_ego ;
dtw_labeling_object = data.labeling_object ;
gt_labeling_ego_long = gt.label.ego.long ;
gt_labeling_ego_lat = gt.label.ego.lat ;
gt_labeling_object_long = gt.label.TObj.long ;
gt_labeling_object_lat = gt.label.TObj.lat ;
gt_start_time = gt.Time;
gt_stop_time = gt.Time;
NumberOfLoop = data.nrOfLoop;
% Initiation
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
Nr_fehler_ego = 0;
Nr_fehler_object = 0;
accuracy_sum_ego = 0;
accuracy_sum_object = 0;
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
    
    if dtw_labeling_ego(n) == dtw_labeling_ego(n - 1) &&  dtw_labeling_ego(n) ~= 0     
        m = m + 1;             
     else
              if m >= 5
                 A = data.dtw_d_ego(n-m: n -1);
                 [B,p] = min(A);      
                 I =[p-2;p-1;p;p+1;p+2];            
                 for j = 1 : length(A)
                     if ismember(j, I) == 1
                         dtw_labeling_ego(n-m-1+j) = dtw_labeling_ego(n-m-1+j);
                     else
                         dtw_labeling_ego(n-m-1+j) = 0;
                     end                    
                 end                
              end 
        m = 1;
    end
     
% Object results sorting

    if dtw_labeling_object(n) == dtw_labeling_object(n -1) &&  dtw_labeling_object(n) ~= 0
        
        m1 = m1 + 1; 

     else
              if m1 >= 5
                A = data.dtw_d_object(n-m1 : n -1);
                [B,p] = min(A); 
                 I =[p-2;p-1;p;p+1;p+2];                
                 for j = 1 : length(A)
                     if ismember(j, I) == 1
                         dtw_labeling_object(n-m1-1+j) = dtw_labeling_object(n-m1-1+j);
                     else
                         dtw_labeling_object(n-m1-1+j) = 0;
                     end                    
                 end                
              end 
        m1 = 1; 
     end

end

%% DTW labeling Ego and Object
for n = 1 : NumberOfLoop - 2
 % Ego labeling resuts
    if dtw_labeling_ego(n) == dtw_labeling_ego(n +1)  
        start_time_ego(k) = start_time_ego(k);
        stop_time_ego(k) = lstop_time(n+1) ;
        labeling_ego(k) = dtw_labeling_ego(n);            
    else
        k = k + 1;
        start_time_ego(k) = lstart_time(n+1);
        stop_time_ego(k) = lstop_time(n+1) ;
        labeling_ego(k) = dtw_labeling_ego(n+1);        
    end
    
  % Object labeling results
  
    if dtw_labeling_object(n) == dtw_labeling_object(n +1)  
        start_time_object(k1) = start_time_object(k1);
        stop_time_object(k1) = lstop_time(n+1) ;
        labeling_object(k1) = dtw_labeling_object(n);           
    else
        k1 = k1 + 1;
        start_time_object(k1) = lstart_time(n+1);
        stop_time_object(k1) = lstop_time(n+1) ;       
        labeling_object(k1) = dtw_labeling_object(n+1);    
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
      Sum=0;
      for j=1:m
          if A(1,j) == B(1,j)
             Sum=Sum+1;
          end
      end          
     accuracy_ego(n) = Sum/m*100;
     accuracy_sum_ego = accuracy_sum_ego + accuracy_ego(n);
     
     if accuracy_ego(n) < 50
         Nr_fehler_ego = Nr_fehler_ego + 1;
         accuracy_sum_ego = accuracy_sum_ego - accuracy_ego(n);
     end
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
     accuracy_sum_object = accuracy_sum_object + accuracy_object(n);
     
     if accuracy_object(n) < 50
         Nr_fehler_object = Nr_fehler_object + 1;
         accuracy_sum_object = accuracy_sum_object - accuracy_object(n);
     end
end
    
%% Output
% Quality accuracy- Accuracy Ego/Object
quality_ego = accuracy_sum_ego/(k2 - Nr_fehler_ego);
quality_object = accuracy_sum_object/(k3 - Nr_fehler_object);

% Qunantity
quantity_ego = (k2 - Nr_fehler_ego)/k2 ;
quantity_object = (k3 - Nr_fehler_object)/k3 ;

%% To Excel(when necessary)
% results_ego_lat = [start_time_ego', stop_time_ego', labeling_ego' ];
% results_object_lat = [ start_time_object', stop_time_object', labeling_object' ];
% results_gt_ego_lat = [gt_start_time_ego', gt_stop_time_ego', gt_labeling_ego', accuracy_ego' ];
% results_gt_object_lat = [ gt_start_time_object', gt_stop_time_object', gt_labeling_object' ,accuracy_object'];
% results_output = [run_time, Nr_fehler_ego,k2,quantity_ego,quality_ego; run_time, Nr_fehler_object,k3,quantity_object,quality_object ];
% results_cell_ego_lat = num2cell(results_ego_lat);  
% results_cell_object_lat = num2cell(results_object_lat);
% results_cell_gt_ego_lat = num2cell(results_gt_ego_lat);  
% results_cell_gt_object_lat = num2cell(results_gt_object_lat);
% results_cell_output = num2cell(results_output);
% title1 = { 'Maneuver start time', 'Maneuver stop time', 'DTW Labeling Ego lat' };
% title2 = { 'Maneuver start time', 'Maneuver stop time', 'DTW Labeling Object lat'};
% title3 = { 'Maneuver start time', 'Maneuver stop time', 'Ground Truth Labeling Ego lat','Quality Accuracy(%)' };
% title4 = { 'Maneuver start time', 'Maneuver stop time', 'Ground Truth Labeling Object lat','Quality Accuracy(%)'};
% title5 = {'Run time','Number of wrong label','All label','Quantity Accuracy','Quality Accuracy'};
% output1 = [title1 ; results_cell_ego_lat ]; 
% output2 = [title2 ;  results_cell_object_lat]; 
% output3 = [title3 ; results_cell_gt_ego_lat ]; 
% output4 = [title4 ;  results_cell_gt_object_lat]; 
% output5 = [title5;  results_cell_output];
% a = [k,k1,k2,k3];
% cell_Index = max(a);
% rowNr = 316;
% cellnames_ego =['A',num2str(rowNr),':C',num2str(k + rowNr )];
% cellnames_gt_ego =['E',num2str(rowNr),':H',num2str(k2 + rowNr)];
% cellnames_object =['K',num2str(rowNr),':M',num2str(k1+ rowNr)];
% cellnames_gt_object =['O',num2str(rowNr),':R',num2str(k3 + rowNr)];
% cellnames_output = ['A',num2str(rowNr+cell_Index+1),':E',num2str(rowNr+cell_Index+3)];
% Output_label1 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_slidingwindow.xlsx',output1 ,'results_DTW',cellnames_ego);
% Output_label2 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_slidingwindow.xlsx',output2 ,'results_DTW',cellnames_object);
% Output_label3 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_slidingwindow.xlsx',output3 ,'results_DTW',cellnames_gt_ego);
% Output_label4 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_slidingwindow.xlsx',output4 ,'results_DTW',cellnames_gt_object);
% Output_label5 = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Accuracy_slidingwindow.xlsx',output5 ,'results_DTW',cellnames_output);
%%
toc;
save output.mat;
 