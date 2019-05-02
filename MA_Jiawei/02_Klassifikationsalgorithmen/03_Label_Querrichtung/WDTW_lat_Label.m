%%  Label_object_lat with WDTW(Weighted dynamic time wrapping) and slidingwindow (lcr = lane change right, lcl = lane change left, lk = lane keeping)
%  S is the orignal signal
%  R_lcr is the reference siggnal for lane change right 
%  R_lcl is the reference siggnal for lane change left
%  Slidiwindow parameter: Shift(0.1s, 0.25s, 0.5s ) and Windlen(2.5s,3.5s, 5s, 7.5s).

clc;
tic;

%% Data from CarMaker Sensor signal
data = load('E:\CM_Projects\CM7_Highway\src\prepdataForObjektAnalyse.mat'); 

%% Reference signal 
R_DisToLeft_lcr = data.Rsignal.ego.lcr(: , 6);          % Rsiganl Column 6 Distoleft
R_DisToLeft_lcl = data.Rsignal.ego.lcl(: , 6);
R_Time_lcr = data.Rsignal.object.lcr(: , 1);            % Rsiganl Column 1 Time
R_ds_y_lcr = data.Rsignal.object.lcr(: , 4);            % Rsiganl Column 4 ds_y


R_Time_lcl = data.Rsignal.object.lcl(: , 1);            % Rsiganl Column 1 Time
R_ds_y_lcl = data.Rsignal.object.lcl(: , 4);            % Rsiganl Column 4 ds_y

%% Choose Signal for WDTW Process(Orignal siganl and reference signal)
Signal_DisToLeft = data.Ego_DisToLeft;           
Signal_ego = Signal_DisToLeft;
R_ego_lcr = R_DisToLeft_lcr;
R_ego_lcl = R_DisToLeft_lcl;
Signal_ds_y = data.ds_y;          
start_time = data.Time;
stop_time = data.Time;
frequence = 1/(data.Time(2) - data.Time(1));
Signal_object = Signal_ds_y;
R_object_lcr = R_ds_y_lcr;
R_object_lcl = R_ds_y_lcl;

save ('dataprepation.mat','Signal_ego','R_ego_lcr','R_ego_lcl','Signal_object','R_object_lcr','R_object_lcl','start_time','stop_time');

Lsignal = length(Signal_object);                  % M: the length of sequence Q Sampling data
N_ego_lcr = length(R_ego_lcr);                    % N: the length of sequence C Reference signal
N_ego_lcl = length(R_ego_lcl); 
N_object_lcr = length(R_object_lcr);              % N: the length of sequence C Reference signal
N_object_lcl = length(R_object_lcl); 


%% Sliding window initialization

windLen = 500 ;                     % Window length
m = 2 ;                             % Sliding window signal start id (dataprepation.mat)
n = m + round(windLen) ;            % Sliding window signal end id An
k = 1;                              % Inter for Inkremental
start = m ;                         % Slidong window start
shift = 25 ;                        % Sliding window overlap  
stop = Lsignal - windLen ;          % Slidong window stop
nrOfLoop = 1 ;                      % Number of loops


signal_object_value_max = 0 ;
  
th_value_lcr_ego = 30;               % Threshold value for lane change right classification
th_value_lcl_ego = 30;               % Threshold value for lane change left classification
th_value_lcr_object = 30;            % Threshold value for lane change right classification
th_value_lcl_object = 30;            % Threshold value for lane change left classification
th_value_label_object = 3.5;         % Threshold value for objects lane change 
th_value_label_ego_same = 2;         % Threshold value for objects just same lane change with ego at the same ime
th_value_label_ego_diff = 7;         % Threshold value for objects take different lane change with ego at the same time

% Initialition and pre-allocated computing space
d_object = 0 ;
label_object = 0;
t = 1;
number_loop = zeros();
lstart_time = zeros();
lstop_time = zeros();
dtw_d_object = zeros();
dtw_d_ego = zeros();
labeling_object = zeros();
labeling_ego = zeros();
all_d_object_lcl = zeros();
all_d_ego_lcl = zeros();
all_d_object_lcr = zeros();
all_d_ego_lcr = zeros();
all_signal_ego_value_max = zeros();
all_signal_ego_value_max_time = zeros();
all_delta_ego_object_value =  zeros();
all_signal_object_value_max = zeros();
all_signal_object_value_max_time = zeros();
all_delta_signal_ego_value =  zeros();
all_delta_signal_object_value =  zeros();


%%  Sliding Window with DTW Algorithmus

for L = start : shift : stop
    
   D = load('dataprepation.mat');
  
   loop_start_time = D.start_time(m);
   loop_stop_time = D.start_time(n);
   
   S_ego = D.Signal_ego(m:n);                          % Signal in Sliding window
   S_object = D.Signal_object(m:n);                          % Signal in Sliding window
   save ('S.mat','S_ego','S_object');
   SD = load ('S.mat');
   w = 1000;
   M_ego = length(S_ego);
   M_object = length(S_object);
   
%% Maximaum signal value und minumum signal value in this sliding window loop
   signal_ego_value = abs(Signal_ego(m : n) - 1.875);                        % make a standard skala
   [signal_ego_value_max,I] = max(signal_ego_value);
   signal_ego_value_max_time = D.start_time(m + I);
   all_signal_ego_value_max(k ,1) = signal_ego_value_max;
   all_signal_ego_value_max_time(k ,1) = signal_ego_value_max_time;

   [signal_ego_value_min,~] = min(signal_ego_value);

   delta_signal_ego_value = abs(signal_ego_value_max - signal_ego_value_min);
   all_delta_signal_ego_value(k ,1) = delta_signal_ego_value;


   signal_object_value = abs(Signal_object(m : n));                       
   [signal_object_value_max,I] = max(signal_object_value);
   signal_object_value_max_time = D.start_time(m + I);
   all_signal_object_value_max(k ,1) = signal_object_value_max;
   all_signal_object_value_max_time(k ,1) = signal_object_value_max_time;

   [signal_object_value_min,~] = min(signal_object_value);

   delta_signal_object_value = abs(signal_object_value_max - signal_object_value_min);
   all_delta_signal_object_value(k ,1) = delta_signal_object_value;
   
%% WDTW 
%Initialiation
Wmax = 1;
g = 0.05;           % Konstante Gewichtung - weight_function = 1/2 Wmax,  or g = 0.05 Lineare Gewichtung.

%- Ego lane change left
% Input signal
X = S_ego';
Y = R_ego_lcl;
N = size(X,1);
M = size(Y,1);
sakoe_chiba_band = 0.5 * N;
%Local Cost Matrix (Dissimilarities)
%-------------------------------------------------------------------------------------------
C = zeros(N,M);
for i = 1 : N
	for j = 1 : M
        a = abs(i - j);        
        Ml = N/2;
        weight_function = Wmax/(1 + 1/exp(g*(a - Ml)));       
		C(i,j) =  weight_function * ( ( X(i) - Y(j) ) ^ 2 ); 
	end
end

%Cost Matrix with Sakoe-Chiba Band
%-------------------------------------------------------------------------------------------
dtw = zeros(N,M);
dtw(1,1) = C(1,1);

for i = 2 : N
	dtw(i,1) = dtw(i-1,1) + C(i,1);
end
for j = 2 : M
	dtw(1,j) = dtw(1,j-1) + C(1,j);
end
for i = 2 : N
	for j = 2 : M
		if abs(i-j) <= sakoe_chiba_band    % sakoe_chiba_band The width of this global constraint is generally set to be 10% ofthe time series length
			dtw(i,j) = C(i,j) + min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1)));
		else
			dtw(i,j) = Inf;
		end
		
	end
end

%Compute Warping Path
%-------------------------------------------------------------------------------------------
i = N;
j = M;
path = zeros(N,M);
path(N,M) = 1;
size_warping_path = 1;

while (i > 1) || (j > 1)
	if (i == 1)
		j = j-1;
	elseif (j == 1)
		i = i-1;
	else
		if (dtw(i-1,j-1) == min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1))))
			i = i-1;
			j = j-1;
		elseif (dtw(i,j-1) == min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1))))
			j = j-1;
		else
			i = i-1;
		end
	end
	path(i,j) = 1;
	size_warping_path = size_warping_path + 1;
end

d_ego_lcl = dtw(N,M); 
all_d_ego_lcl(k,1) = d_ego_lcl;

%- Ego lane change right
% Input signal
X = S_ego';
Y = R_ego_lcr;
N = size(X,1);
M = size(Y,1);
sakoe_chiba_band = 0.5 * N;
%Local Cost Matrix (Dissimilarities)
%-------------------------------------------------------------------------------------------
C = zeros(N,M);
for i = 1 : N
	for j = 1 : M
        a = abs(i - j);        
        Ml = N/2;
        weight_function = Wmax/(1 + 1/exp(g*(a - Ml)));       
		C(i,j) =  weight_function * ( ( X(i) - Y(j) ) ^ 2 ); 
	end
end

%Cost Matrix with Sakoe-Chiba Band
%-------------------------------------------------------------------------------------------
dtw = zeros(N,M);
dtw(1,1) = C(1,1);

for i = 2 : N
	dtw(i,1) = dtw(i-1,1) + C(i,1);
end
for j = 2 : M
	dtw(1,j) = dtw(1,j-1) + C(1,j);
end
for i = 2 : N
	for j = 2 : M
		if abs(i-j) <= sakoe_chiba_band    % sakoe_chiba_band The width of this global constraint is generally set to be 10% ofthe time series length
			dtw(i,j) = C(i,j) + min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1)));
		else
			dtw(i,j) = Inf;
		end
		
	end
end

%Compute Warping Path
%-------------------------------------------------------------------------------------------
i = N;
j = M;
path = zeros(N,M);
path(N,M) = 1;
size_warping_path = 1;

while (i > 1) || (j > 1)
	if (i == 1)
		j = j-1;
	elseif (j == 1)
		i = i-1;
	else
		if (dtw(i-1,j-1) == min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1))))
			i = i-1;
			j = j-1;
		elseif (dtw(i,j-1) == min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1))))
			j = j-1;
		else
			i = i-1;
		end
	end
	path(i,j) = 1;
	size_warping_path = size_warping_path + 1;
end

d_ego_lcr = dtw(N,M); 
all_d_ego_lcr(k,1) = d_ego_lcr;   
 %%  Labeling Ego  (1 = lane change right, -1 = lane chang left, 0 = lane keeping)  

  if d_ego_lcl <= th_value_lcl_ego         
        if signal_ego_value_max > 0.9           % 1 meter is relevant with lane width
          label_ego = -1 ;                      % -1 means lane change left happens
          d_ego = d_ego_lcl ;
        else
             label_ego = 0;                     % 0  means no lane change left happens
             d_ego = 0;     
        end 

  elseif d_ego_lcr <= th_value_lcr_ego         
        if signal_ego_value_max > 1             % 1 meter is relevant with lane width
          label_ego = 1 ;                       % 1 means lane change right happens
          d_ego = d_ego_lcr ;                  
        else
               label_ego = 0;                     
               d_ego = 0; 
        end

  else
       label_ego = 0;                     
       d_ego = 0;
  end
%% WDTW Object lat
%- object lane change left
% Input signal
X = S_object';
Y = R_object_lcl;
N = size(X,1);
M = size(Y,1);
sakoe_chiba_band = 0.5 * N;
%Local Cost Matrix (Dissimilarities)
%-------------------------------------------------------------------------------------------
C = zeros(N,M);
for i = 1 : N
	for j = 1 : M
        a = abs(i - j);        
        Ml = N/2;
        weight_function = Wmax/(1 + 1/exp(g*(a - Ml)));       
		C(i,j) =  weight_function * ( ( X(i) - Y(j) ) ^ 2 ); 
	end
end

%Cost Matrix with Sakoe-Chiba Band
%-------------------------------------------------------------------------------------------
dtw = zeros(N,M);
dtw(1,1) = C(1,1);

for i = 2 : N
	dtw(i,1) = dtw(i-1,1) + C(i,1);
end
for j = 2 : M
	dtw(1,j) = dtw(1,j-1) + C(1,j);
end
for i = 2 : N
	for j = 2 : M
		if abs(i-j) <= sakoe_chiba_band    % sakoe_chiba_band The width of this global constraint is generally set to be 10% ofthe time series length
			dtw(i,j) = C(i,j) + min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1)));
		else
			dtw(i,j) = Inf;
		end
		
	end
end

%Compute Warping Path
%-------------------------------------------------------------------------------------------
i = N;
j = M;
path = zeros(N,M);
path(N,M) = 1;
size_warping_path = 1;

while (i > 1) || (j > 1)
	if (i == 1)
		j = j-1;
	elseif (j == 1)
		i = i-1;
	else
		if (dtw(i-1,j-1) == min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1))))
			i = i-1;
			j = j-1;
		elseif (dtw(i,j-1) == min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1))))
			j = j-1;
		else
			i = i-1;
		end
	end
	path(i,j) = 1;
	size_warping_path = size_warping_path + 1;
end

d_object_lcl = dtw(N,M); 
all_d_object_lcl(k,1) = d_object_lcl;
  
%- object lane change left
% Input signal
X = S_object';
Y = R_object_lcr;
N = size(X,1);
M = size(Y,1);
sakoe_chiba_band = 0.5 * N;
%Local Cost Matrix (Dissimilarities)
%-------------------------------------------------------------------------------------------
C = zeros(N,M);
for i = 1 : N
	for j = 1 : M
        a = abs(i - j);        
        Ml = N/2;
        weight_function = Wmax/(1 + 1/exp(g*(a - Ml)));       
		C(i,j) =  weight_function * ( ( X(i) - Y(j) ) ^ 2 ); 
	end
end

%Cost Matrix with Sakoe-Chiba Band
%-------------------------------------------------------------------------------------------
dtw = zeros(N,M);
dtw(1,1) = C(1,1);

for i = 2 : N
	dtw(i,1) = dtw(i-1,1) + C(i,1);
end
for j = 2 : M
	dtw(1,j) = dtw(1,j-1) + C(1,j);
end
for i = 2 : N
	for j = 2 : M
		if abs(i-j) <= sakoe_chiba_band    % sakoe_chiba_band The width of this global constraint is generally set to be 10% ofthe time series length
			dtw(i,j) = C(i,j) + min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1)));
		else
			dtw(i,j) = Inf;
		end
		
	end
end

%Compute Warping Path
%-------------------------------------------------------------------------------------------
i = N;
j = M;
path = zeros(N,M);
path(N,M) = 1;
size_warping_path = 1;

while (i > 1) || (j > 1)
	if (i == 1)
		j = j-1;
	elseif (j == 1)
		i = i-1;
	else
		if (dtw(i-1,j-1) == min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1))))
			i = i-1;
			j = j-1;
		elseif (dtw(i,j-1) == min(dtw(i-1,j-1) , min(dtw(i-1,j),dtw(i,j-1))))
			j = j-1;
		else
			i = i-1;
		end
	end
	path(i,j) = 1;
	size_warping_path = size_warping_path + 1;
end

d_object_lcr = dtw(N,M); 
all_d_object_lcr(k,1) = d_object_lcr;

%%  Labeling - Object lane change right (1 = lane change right, -1 = lane chang left, 0 = lane keeping)     
    if d_object_lcl <= th_value_lcl_object                    % wdtw results shows lane change left identity (maybe object lane change or ego lane change)
        
            if signal_object_value_max > 0.5                  % value is relevant with lane width

                  if delta_signal_object_value > th_value_label_object && delta_signal_object_value < th_value_label_ego_diff && label_ego ~= - 1 % label (0,-1)
                      label_object = -1 ;                     % -1 means object lane change left happens
                      d_object = d_object_lcl ;  
                  elseif delta_signal_object_value > th_value_label_object && delta_signal_object_value < th_value_label_ego_diff && label_ego == - 1 % label (-1,0)
                         label_object = 0 ;                   % 0 means dtw results changes due to ego lane change left not object lane change left
                         d_object = d_object_lcl ;  
                  elseif delta_signal_object_value >= th_value_label_ego_diff    % label (1, -1)  Ego and Object take differernt lane change
                         label_object = -1 ;                  % -1 means lane change left happens 
                         d_object = d_object_lcl ; 
                  elseif delta_signal_object_value <= th_value_label_ego_same && label_ego == - 1 %label(-1, -1) Ego and Object take same lane change
                         label_object = -1 ;
                         d_object = d_object_lcl ;
                  end
            else
                 label_object = 0;                            % 0  means no lane change left happens
                 d_object = 0;
            end
            
    elseif d_object_lcr <= th_value_lcr_object                 % wdtw results shows lane change right identity (maybe object lane change or ego lane change or together lane change)
        
            if signal_object_value_max > 0.5                   % value is relevant with lane width

                  if delta_signal_object_value > th_value_label_object && delta_signal_object_value < th_value_label_ego_diff && label_ego ~= 1 % label (0,1)
                      label_object = 1 ;                       % 1 means object lane change right happens
                      d_object = d_object_lcr ;  

                  elseif delta_signal_object_value > th_value_label_object && delta_signal_object_value < th_value_label_ego_diff && label_ego ==  1 % label (1,0)
                      label_object = 0 ;                       % 0 means dtw results changes due to ego lane change left not object lane change left
                      d_object = d_object_lcr ;  

                  elseif delta_signal_object_value >= th_value_label_ego_diff  % label (-1, 1)  Ego and Object take differernt lane change
                      label_object = 1 ;                       % -1 means lane change left happens 
                      d_object = d_object_lcr ; 

                  elseif delta_signal_object_value <= th_value_label_ego_same &&  label_ego ==  1 %label(1, 1) Ego and Object take same lane change
                      label_object = 1 ;
                      d_object = d_object_lcr ;
                  end
            else
                 label_object = 0;                             % 0  means lane keep happens
                 d_object = 0;
            end
        
    else
         label_object = 0;                                     % 0  means lane keep happens
         d_object = 0;
    end 
%% Output(number of Loop,Sliding window start/stop time, WDTW distance, labeling)  
   number_loop(k,1) = nrOfLoop;
   lstart_time(k,1) = loop_start_time;
   lstop_time(k,1) = loop_stop_time;
   wdtw_d_object(k,1) = d_object;
   wdtw_d_ego(k,1) = d_ego;
   labeling_object(k,1) = label_object;
   labeling_ego(k,1) = label_ego;
   
   m = m + shift ;
   n = n + shift ;
   nrOfLoop = nrOfLoop + 1 ;
   t = t + 1 ;
   k = k + 1 ; 
   
end
  
%% Results output
% results = [number_loop, lstart_time, lstop_time, all_signal_ego_value_max, all_signal_ego_value_max_time, all_delta_signal_ego_value, all_d_ego_lcl,all_d_ego_lcr, wdtw_d_ego, labeling_ego, all_signal_object_value_max, all_signal_object_value_max_time, all_delta_signal_object_value, all_d_object_lcl,all_d_object_lcr, wdtw_d_object,labeling_object];
% results_cell = num2cell(results);  
% title = {'Number of loop', 'Loop start time', 'Loop stop time', 'Maximal Ego signal value in loop', 'Maximal Ego signal value time' , 'Delta Ego signal value', 'Real WDTW Ego Dis.with Rsignal_lcl','Real WDTW Ego Dis.with Rsignal_lcr', 'WDTW Ego Distance', 'Labeling Ego','Maximal Object signal value in loop', 'Maximal Obeject signal value time' , 'Delta Object signal value', 'Real WDTW Object Dis.with Rsignal_lcl', 'Real WDTW Object Dis.with Rsignal_lcr','WDTW Object Distance', 'Labeling Object' };
% output = [title ; results_cell];  
% Output_label = xlswrite('C:\Users\scuwa\Desktop\MA_Jiawei\Data\WDTW_results_highway_T10.xlsx',output ,'Label_lat_wdtw');

toc;
Runtime = toc;
save ('WDTW_results_lat.mat');
