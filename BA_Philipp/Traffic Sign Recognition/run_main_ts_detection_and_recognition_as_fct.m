% *************************************************************************
% Author:   Philipp Metzger
%           Karlsruher Institut für Technologie
% Date:     12.05.2020
% *************************************************************************
%
% *************************************************************************
% Description
% *************************************************************************
%
% This script is for running "main_ts_detection_and_recognition_as_fct"
%
% The purpose of doing that is to find a good value for "delay"
%
% "time_and_prediction" has to be loaded into workspace to execute
% properly
% 
% Load it by double clicking on "tsdr_time_and_prediction"


%% Check if time_and_prediction is loaded
if ~exist('time_and_prediction', 'var')
   disp('"time_and_prediction" has to be loaded into workspace to execute properly. Load it by double clicking on "tsdr_time_and_prediction"');
   return
end


%% Get mean deviations in time and sRoad for given delay values
delay = (0.4:0.001:0.6);
sumDevs = zeros(size(delay, 2), 2);
i = 0;
s = size(delay, 2);
disp(strcat('Running script', 32, num2str(s), 32, 'times'));
for d = delay
    i = i + 1;
    fprintf(strcat(num2str(i), 32));
    [sumDev_time, sumDev_sRoad] = main_ts_detection_and_recognition_as_fct(time_and_prediction, d);
    sumDevs(i, 1) = delay(1, i);
    sumDevs(i, 2) = sumDev_time;
    sumDevs(i, 3) = sumDev_sRoad;
end


%% Get global minima
[min_Dev_time, min_Dev_time_idx] = min(abs(sumDevs(:, 2)));
[min_Dev_sRoad, min_Dev_sRoad_idx] = min(abs(sumDevs(:, 3)));


%% Plot all time and sRoad deviations (multiply time by 10 to have a better comparability)
plot(sumDevs(:, 1), 10 * abs(sumDevs(:, 2)));
xlabel('delay');
hold on;
plot(sumDevs(:, 1), abs(sumDevs(:, 3)));
legend('sum deviations time * 10', 'sum of deviations sRoad');
hold off;