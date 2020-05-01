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
% This script is for creating a ground truth table for evaluating the performance of "main_ts_detection_and_recognition"
%
% The respective CarMaker road file (.rd5) must be present in "...007 Traffic Sign Recognition\001 Data\ground truth"
% 
% The name of the road file has to be correctly specified in line 51 for executing properly
%
% The structure of the output matrix is as follows:
% - 1st row: Position of traffic sign in meters
% - 2nd row: Time in seconds when Ego passed by traffic sign
% - 3rd row: Variable type (0 for all traffic signs) (This is meant to
% enable integration of other static variables later on - For example: 1 for
% number of lanes, 2 for road width, ...)
% - 4th row: Class number of traffic sign (meaning: type of traffic sign)


%%%%%%%%%%%%%%%%
%% Input by user
%%%%%%%%%%%%%%%%


%% CarMaker: Application -> OutputQuantities -> Data Rates -> Frequncy
freq = 50;


%%%%%%%%%%%%%%%%%%%%%%%
%% End of input by user
%%%%%%%%%%%%%%%%%%%%%%%


%% Get path to this directory and change to it
[thisDir, ~, ~] = fileparts(mfilename('fullpath'));
cd(thisDir);


%% Get path of parent directory
parentDir = extractBefore(thisDir, '006');


%% Get traffic sign positions and IDs automatically from road file
% Open file
fid = fopen(strcat(parentDir, '\001 Data\ground truth\road_larger_scenario_road_signs.rd5'));

if fid == -1
     disp('Error: Unable to open road file. Please check name of road file located in "...007 Traffic Sign Recognition\001 Data\ground truth" and change line 51 accordingly');
     return
end

% Initialise
i_ts = 0;
lineContent = strings;
positions = [];
names = [];
while ~feof(fid) % feof(fid) is true when the file ends
    textLineEntry = fgetl(fid); % read one line
    %if contains(textLineEntry, 'Basics.Dimension')
    string_pos = strcat('RL.1.Mount.', num2str(i_ts), 32, '=');
    % search for "string_pos"
    if contains(textLineEntry, string_pos)
       lineContent = strsplit(textLineEntry, ' ');
       pos = str2double(lineContent(1, 3));
       positions = [positions, pos];
       % Go two lines down (where name is)
       textLineEntry = fgetl(fid);
       textLineEntry = fgetl(fid);
       lineContent = strsplit(textLineEntry, ' ');
       % if str2double(lineContent(1, 16)) == 0
       if lineContent(1, 13) ~= "SpeedLimit" && lineContent(1, 13) ~= "SpeedLimitEnd"
           name = strcat(lineContent(1, 13));
       else
           name = strcat(lineContent(1, 13), " ", lineContent(1, 16));
       end
       names = [names, name];
       i_ts = i_ts + 1;
    end
end
% Create a matrix of the size of "names"
names_ids = zeros(size(names));
% Create a mapping connecting traffic sign names and corresponding indices
keySet = {'SpeedLimit 20'; ...
    'SpeedLimit 30'; 'SpeedLimit 50';...
    'SpeedLimit 60'; 'SpeedLimit 70';...
    'SpeedLimit 80'; 'SpeedLimitEnd 80';...
    'SpeedLimit 100'; 'SpeedLimit 120';...
    'NoOvertaking'; 'NoOvertakingTrucks';...
    'RightOfWay'; 'PriorityRoad';...
    'GiveWay'; 'Stop';...
    'NoTraffic'; '16 = no trucks';...
    'NoEntry'; 'Caution';...
    'CurveL'; 'CurveR';...
    'SCurveL'; '22 = uneven road';...
    'SlipperyRoad'; 'NarrowRoadR';...
    'RoadWorks'; 'TrafficLight';...
    'Pedestrians'; 'Children';...
    'CyclistsCrossingR'; '30 = snow';...
    '31 = animals'; 'EndOfLimitations';...
    'TurnAheadR'; 'TurnAheadL';...
    '35 = go straight'; 'StraightOrRight';...
    'StraightOrLeft'; 'PassR';...
    'PassL'; 'Roundabout';...
    'NoOvertakingEnd'; 'NoOvertakingTrucksEnd'};
valueSet = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42];
mapping = containers.Map(keySet,valueSet);

% Fill "names_ids" with the right values using our mapping
for i = (1:size(names,2)) 
    names_ids(1, i) = mapping(names(1, i));
end


%% Old Code: Mannual creation of position and ID arrays
if 0
    %% Create matrix and fill with s values and traffic sign IDs
    gt = zeros(4, 43 - 5);
    gt(1, :) = [300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600,1700,1800,2000,2100,2200,2300,2400,2600,2700,2800,2900,3000,3100,3200,3500,3600,3700,3900,4000,4100,4200,4300,4400,4500];
    gt(4, :) = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,23,24,25,26,27,28,29,32,33,34,36,37,38,39,40,41,42];
end


%% Add positions and IDs together
gt = zeros(4, size(positions, 2));
gt(1, :) = positions;
gt(4, :) = names_ids;


%% Load CM data
load(strcat(parentDir, '\001 Data\erg, radar\data'));
sRoad = data.Car_Road_sRoad.data;
times = (0:(1 / freq):((size(sRoad, 2) - 1) / freq));


%% Compute times of passing by traffic signs by interpolation and fill second row with them  
k = 1;
for i = (1:size(gt, 2))
    s = gt(1, i);
    % Search this s in in sRoad
    while s > sRoad(1, k)
        k = k + 1;
    end
    if s == sRoad(1, k)
        less = 0; 
    else %% meaning: time > times(1, k)
        % Get percentage of step to deduct from enty k
        less = (s - sRoad(1, k)) / (sRoad(1, k) - sRoad(1, (k-1)));
    end
    gt(2, i) = times(1, k) - less * (times(1, k) - times(1, (k-1)));
end

% Save ground truth table in main directory
save(strcat(parentDir, '001 Data\ground truth\tsdr_ground_truth'), 'gt');