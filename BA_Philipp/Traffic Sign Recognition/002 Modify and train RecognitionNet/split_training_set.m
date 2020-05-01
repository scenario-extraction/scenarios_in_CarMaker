%% This is a tool to tell user how many images from each class to move to validation set
% The moving itself has not been automated (has to be done manually)
% ! Remark: 
% All classes have series of 30 images EXCEPT CLASS 33 "TURN RIGHT"
% One image (its name would be 00033_00019_00029) is missing in class 33
% 


%% Please import "Path" column of "Train.csv" manually by double clicking on it and only selected this one column


%% Define this directory as base directory and change it
[base, ~, ~] = fileparts(mfilename('fullpath'));
cd(base);


%% Define validation portion
val_portion = 0.2;


%% Convert to string array
paths = table2array(Train);


%% Delete first line
paths = paths(2:end);


%% Get IDs of image series

%% Shorten paths
paths_short = extractBetween(paths, 7, 21);
class = extractBetween(paths_short, "/", "_");
series = extractBetween(paths_short, "_", "_");


%% Write in array
% class_series = strcat(class, "_", series);
class_series = [class, series];


%% Get unique values
c_s_unique = unique(class_series, 'rows');


%% Turn into numbers
c_s_unique = str2double(c_s_unique);


%% Create array of size numberOfClasses x 1
count = zeros(size(unique(c_s_unique(:, 1)), 1), 1);
% Fill array with number of series contained in each class
for i = (0:max(c_s_unique(:,1)))
  bool = (c_s_unique(:, 1) == i);
  count(i + 1) = sum(bool);
end


%% See how many series in each class have to go into validation set
% Rounding up!
num_ser_val = ceil(count * val_portion);


%% Only for checking purposes: Get remaining count (train set count)
num_ser_train = count - num_ser_val;


%% Check if all are > 0
allGreaterZero = min(num_ser_val > 0) && min(num_ser_train > 0);
if allGreaterZero
   disp('Status: All good'); 
else
    disp('Status: At least one is zero');
end


%% Compute how many images to go to validation set for each class
% ! Be careful in class 33 !
num_val = num_ser_val * 30;


%% Make a nice representation
classes = unique(c_s_unique(:, 1));
num_val = [classes, num_val];


%% Display
disp('class, number of images to move to validation set');
disp(num_val);


%% And a tool to create the folders:
% (Folders "train" and "validation" each containing one numbered folder per
% class)
% Define location where you would like to create folders
loc = 'C:\Users\philipp\Desktop\gtsrb-german-traffic-sign\Train Validation Split';
mkdir(loc, 'train');
mkdir(loc, 'validation');
for i = (0:max(c_s_unique(:,1)))
    dirStr = num2str(i);
    mkdir(strcat(loc, '\', 'train'), dirStr);
    mkdir(strcat(loc, '\', 'validation'), dirStr);
end
