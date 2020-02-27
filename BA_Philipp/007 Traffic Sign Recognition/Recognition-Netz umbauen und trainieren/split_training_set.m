%% This is a tool to tell user how many images from each class to move to validation set
% ! Remark: 
% All classes have series of 30 images EXCEPT CLASS 33 "TURN RIGHT"
% One image (its name would be 00033_00019_00029) is missing in class 33
% 

% Define base dir
base = 'D:\uhevv\007 Verkehrsschilderkennung aktuell 2020-02-21 1400 (Ohne Trainingsbilder)\Recognition-Netz umbauen und trainieren';

% Define validation portion
val_portion = 0.2;

% Import Train.csv by double clicking and only import "Path" column

% Convert to string array
paths = table2array(Train);

%% Get IDs of image series
% Shorten paths
paths_short = extractBetween(paths, 7, 21);
class = extractBetween(paths_short, "/", "_");
series = extractBetween(paths_short, "_", "_");

% Write in array
% class_series = strcat(class, "_", series);
class_series = [class, series];

% Get unique values
c_s_unique = unique(class_series, 'rows');

% Turn into numbers
c_s_unique = str2double(c_s_unique);

% Create array of size numberOfClasses x 1
count = zeros(size(unique(c_s_unique(:, 1)), 1), 1);
% Fill array with number of series contained in each class
for i = (0:max(c_s_unique(:,1)))
  bool = (c_s_unique(:, 1) == i);
  count(i + 1) = sum(bool);
end

% See how many series in each class have to go into validation set
% Rounding up!
num_ser_val = ceil(count * val_portion);

% Only for checking purposes: Get remaining count (train set count)
num_ser_train = count - num_ser_val;

% Check if all are > 0
allGreaterZero = min(num_ser_val > 0) && min(num_ser_train > 0);
if allGreaterZero
   disp('all good'); 
else
    disp('at least one is zero');
end

% compute how many images to go to validation set for each class
% ! Be careful in class 33 !
num_val = num_ser_val * 30;

% Make a nice representation
classes = unique(c_s_unique(:, 1));
num_val = [classes, num_val];
% Display
disp('class, images to move to validation set');
disp(num_val);


%% And a tool to create the folders
loc = 'C:\Users\philipp\Desktop\gtsrb-german-traffic-sign\Train Validation Split';
mkdir(loc, 'train');
mkdir(loc, 'validation');
for i = (0:max(c_s_unique(:,1)))
    dirStr = num2str(i);
    mkdir(strcat(loc, '\', 'train'), dirStr);
    mkdir(strcat(loc, '\', 'validation'), dirStr);
end







%% Old code

if 0
% Count rows
count = size(c_s_unique, 1);

% Get validation size (round up)
val_size = ceil(count * val_portion);
% And training size
train_size = count - val_size;

% Random index split
split = randperm(count, val_size)';
idx_val = false(count,1);
idx_val(split, 1) = true;
idx_train = ~idx_val;

% Get val and train IDs
valIDs = c_s_unique(idx_val, :);
trainIDs = c_s_unique(idx_train, :);

mkdir('Destination', 'train set');
mkdir('Destination', 'validation set');
for i = (0:42)
    dirStr = num2str(i);
    dest_val = fullfile( 'Destination/validation set', dirStr);
    mkdir(dest_val);
    dest_train = fullfile( 'Destination/train set', dirStr);
    mkdir(dest_train);
    
    
    source = fullfile('Train Images - Kopie', dirStr);
    cd(source);
    
    %%
    %% Hier weitermachen
    %%
    
    % Get validation IDs
    im_val = dir('**');  
    
    cd(base);
end


des_train
copyfile( fname, dest ) ;
end


