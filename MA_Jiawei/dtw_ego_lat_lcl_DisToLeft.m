%%  Label_ego_lat with dtw and slidingwindow (lcr = lane change right, lcl = lane change left, lk = lane keeping)
%  S is the orignal signal
%  R_lcr is the reference siggnal for lane change right 
%  R_lcl is the reference siggnal for lane change left
%  Slidiwindow parameter: Shift(0.25* windlen. ) and Windlen(540).

clc;
tic;

%% Data from CarMaker Sensor signal

data = load('C:\CM_Projects\CM7_Highway\prepdata.mat'); 

%% Reference signal 
[Rsignal.lcr , txt1] = xlsread('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Reference_signal.xlsx','Rsignal_lcr');
[Rsignal.lcl , txt2] = xlsread('C:\Users\scuwa\Desktop\MA_Jiawei\Data\Reference_signal.xlsx','Rsignal_lcl');

% R_Time_lcr = Rsignal.lcr(: , 1);               % Rsiganl Column 1 Time
% R_Car_ax_lcr = Rsignal.lcr(: , 2);             % Rsiganl Column 2 ax
% R_Car_Yaw_lcr = Rsignal.lcr(: , 3);            % Rsiganl Column 3 yaw
% R_Car_ay_lcr = Rsignal.lcr(: , 4);             % Rsiganl Column 4 ay
% R_Car_SteerAngle_lcr = Rsignal.lcr(: , 5);     % Rsiganl Column 5 SteerAngle
R_DisToLeft_lcr = Rsignal.lcr(: , 6);          % Rsiganl Column 6 Distoleft

% R_Time_lcl = Rsignal.lcl(: , 1);
% R_Car_ax_lcl = Rsignal.lcl(: , 2);
% R_Car_Yaw_lcl = Rsignal.lcl(: , 3);
% R_Car_ay_lcl = Rsignal.lcl(: , 4);
% R_Car_SteerAngle_lcl = Rsignal.lcl(: , 5);
R_DisToLeft_lcl = Rsignal.lcl(: , 6);

%% Choose Signal for DTW Process(Orignal siganl and reference signal)

Signal_DisToLeft = data.Ego.Car.DisToLeft;           
% Signal_Yaw = data.Ego.Car.Yaw;
% Signal_SteerAngle = data.Ego.Car.SteerAngle;

start_time = data.Time;
stop_time = data.Time;

Signal = Signal_DisToLeft;

R_lcr = R_DisToLeft_lcr;
R_lcl = R_DisToLeft_lcl;

save ('dataprepation.mat','Signal','R_lcr','R_lcl','start_time','stop_time');

Lsignal = length(Signal);           % M: the length of sequence Q Sampling data
N_lcr = length(R_lcr);              % N: the length of sequence C Reference signal
N_lcl = length(R_lcl); 


%% Sliding window initialization

windLen = 0.25 * N_lcl ;            % Window length
m = 2 ;                             % Sliding window signal start id (dataprepation.mat)
n = m + round(windLen) ;            % Sliding window signal end id An
k = 1;                              % Inter for Inkremental

start = m ;                         % Slidong window start
shift = round (0.25 * windLen) ;    % Sliding window overlap  
stop = Lsignal - windLen ;            % Slidong window stop
nrOfLoop = 1 ;                      % Number of loops

signal_value_max = 0 ;

% th_value_lcr = 2.5;                 % Threshold value for lane change right classification
th_value_lcl = 18;                 % Threshold value for lane change left classification

d = 0 ;
label = 0;
t = 1;

number_loop = zeros();
lstart_time = zeros();
lstop_time = zeros();
dtw_d = zeros();
labeling = zeros();
all_d_lcl = zeros();
all_d_lcr = zeros();
all_signal_value_max = zeros();
all_signal_value_max_time = zeros();

%%  Sliding Window with DTW Algorithmus

for L = start : shift : stop
    
   D = load('dataprepation.mat');
   
   
   str1 = ['A',num2str(m),':','A',num2str(n)]; 
  
   loop_start_time = D.start_time(m);
   loop_stop_time = D.start_time(n);
   
   S = D.Signal(m:n);  % Signal in Sliding window
   save ('S.mat','S');
   SD = load ('S.mat');
   w = 1000;
   M = length(S);
   N_lcr = length(R_lcr);
   N_lcl = length(R_lcl);
   
%% Maximaum signal value in this sliding window loop

      signal_value = Signal_DisToLeft(m : n) - 1.875;                    % make a standard skala
      signal_value = abs(signal_value); 
      [signal_value_max,I] = max(signal_value);
      signal_value_max_time = D.start_time(m + I);
      all_signal_value_max(k ,1) = signal_value_max;
      all_signal_value_max_time(k ,1) = signal_value_max_time;
      
      
     
%% DTW algorithm (lane change left)   
   % DTW initiation
   
     DTW = zeros(M+1,N_lcl+1);
     w = max([w,abs(M-N_lcl)]);

     for i = 2:M+1
         for j =2:N_lcl+1
             DTW(i,j) = inf;
         end
     end
     DTW(1,1) = 0;
     
     % d(i,j):The distance between S(i)and R(j)
     for i = 2:M+1
         for j = max([2,i-w+1]) : min([N_lcl+1,i+w+1])
             d_lcl = norm(SD.S(i-1)-D.R_lcl(j-1));
             DTW(i,j) = d_lcl+ min([DTW(i-1,j),DTW(i,j-1),DTW(i-1,j-1)]);
         end
     end

     d_lcl = DTW(M+1,N_lcl+1);
     all_d_lcl(k,1) = d_lcl;
     

%%  Labeling (lane change right, lane chang left, lane keeping)     
    
    if d_lcl <= th_value_lcl 
        
        if signal_value_max > 0.9          % 1 meter is relevant with lane width
          label = -1 ;                   % -1 means lane change left happens
          d = d_lcl ;
          
          dtw_results.lcl.label(t) = label;
          dtw_results.lcl.start_time(t) = loop_start_time;
          dtw_results.lcl.stop_time(t) = loop_stop_time;
          t = t + 1;
          
        elseif signal_value_max > 0.45
            
            label = -2;                  % -2 means attempt lane change left
       
        end
    else
         label = -3;                     % -3  means no lane change left happens
         d = 0;
    end
    
 %% Output(number of Loop,Sliding window start/stop time, DTW distance, labeling)  
  
   number_loop(k,1) = nrOfLoop;
   lstart_time(k,1) = loop_start_time;
   lstop_time(k,1) = loop_stop_time;
   dtw_d(k,1) = d;
   labeling(k,1) = label;
  
   m = m + shift ;
   n = n + shift ;
   nrOfLoop = nrOfLoop + 1 ;
   k = k + 1; 
   
end
  
%% Results output

results = [number_loop, lstart_time, lstop_time, all_signal_value_max, all_signal_value_max_time, all_d_lcl, dtw_d, labeling];
     
results_cell = num2cell(results);  

title = {'Number of loop', 'Loop start time', 'Loop stop time', 'Maximal signal value in loop', 'Maximal signal value time' , 'Real DTW Dis.with Rsignal_lcl', 'DTW Distance', 'Labeling' };

output = [title ; results_cell];  

save ('dtw_results.mat','dtw_results');

Output_label = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\DTW_results_highway_06_0.25.xlsx',output ,'Label_ego_lcl_DistToLeft');

toc;

