%{
This script creates a table with training data.
Training is needed to determine the linear model parameters
c_height, c_width, bias_height and bias_width.
The goal is to create a dataset corresponding to several images, each containing
only one traffic object with known dimensions and known distances in direction of x.
1st column: image width of traffic object [pixels]
2nd column: image height of traffic object [pixels]
3rd column: Distance in direction of x to traffic object (from camera)
4th column: Ground truth width of traffic object
5th column: Ground truth height of traffic object
6th column: Name of traffic object in CarMaker

Note: Expected format of images' names is:
image_xxx (image_000, image_001, image_002).
This is different in main_application_... where image numbers are 1, 2, 3, ...
%}

%% External parameters
% Main Directory
mainDir = 'C:\Users\philipp\Documents\GitHub\BA_1\src\006 Traffic Object Dimension Estimation';

% Front camera position [m]
front_cam_pos_x = 2.7;
front_cam_pos_y = 0;
front_cam_pos_z = 1.35;

%{
% Rear camera position [m]
rear_cam_pos_x = -0.026;
rear_cam_pos_y = 0;
rear_cam_pos_z = 0.721;
%}

% Time of first image and length of time steps between images
t_start = 0.0;
t_step = 1.0;
t_end = 152.0;

% CarMaker - Data Rates - Frequncy
freq = 50;

% Number of images to add to dataset
n_photos = 153;

% Names of images provided
name = 'image_';

% Traffic object width
width = 1.7;

% Traffic object height
height = 1.15;

% Traffic object description in CarMaker
description = "Audi_S3_2015";


%% Get bounding boxes 
%{
Output of this step:
"bboxes_front"
(coordinate system for raw images: x = right, y = down, origin = upper left
corner of image)
- 1st and 2nd column: Position of upper left corner of bounding box
- 3rd and 4th column: width and height of bounding box
- 5th column: image index
%}
% Initialise vehicle detector
% Documentation:
% https://de.mathworks.com/help/driving/ref/vehicledetectoracf.html?s_tid=doc_ta
detector = vehicleDetectorACF('front-rear-view');

% Get all bounding boxes for front camera
bboxes_front = [];
for index = (1:n_photos)
    % Time
    t = t_start + ((index - 1) * t_step);
    % Load image
    string = strcat(mainDir, '\Data Training Set Generation\', name, num2str(t,'%.3d'), '.jpg');
    I = imread(string);
    % Detect car
    [bboxes, ~] = detect(detector, I);
    % Only add bbox if it exists and if it is only one
    if ~isempty(bboxes) && size(bboxes,1) == 1 
        % Add image index
        bboxes_index = [bboxes, index];
        bboxes_front = [bboxes_front; bboxes_index];
        %% Visualise bounding boxes in image
        % Temporalily disable warnings (plotting throws a warning)
        warning('off', 'all')
        % Visualise bounding box
         I = insertShape(I, 'rectangle', bboxes, 'LineWidth', 5);
         imshow(I)
        % Enable warnings again
        warning('on', 'all')
    end
end


%% Get indices of images where a bounding box was found
bbIndices = bboxes_front(:, 5);


%% Create vector of image widths
widths_image = bboxes_front(:, 3);


%% Create vector of image heights
heights_image = bboxes_front(:, 4);


%% Get data extracted from .erg file
%{
The sensor data of Ego can be retrieved from .erg-file through cmread function
for example by running Amine's code until the point where cmread is called inside
datapreparation.m
%}
string = strcat(mainDir, '\Data Training Set Generation\data.mat');
load(string);


%% Get distance to traffic object in direction of x
dist_x.raw = data.Sensor_Object_OB01_Obj_T00_RefPnt_ds_x.data;


%% Convert to (x, y, z)_from_front_camera
dist_x.from_front_camera = dist_x.raw - front_cam_pos_x;


%% Get corresponding dist_x values for the images provided
indices = (t_start * freq + 1:t_step * freq:t_end * freq + 1);
dist_x.relevant = dist_x.from_front_camera(indices);


%% Only those who have a bounding box
dist_x.relevant = dist_x.relevant(bbIndices);


%% Create vector with provided ground truth widths
widths_ground_truth = zeros(size(bbIndices, 1), 1);
widths_ground_truth(:) = width;


%% Create vector with provided heights
heights_ground_truth = zeros(size(bbIndices, 1), 1);
heights_ground_truth(:) = height;


%% Create vector with name of traffic object
descriptions = strings(size(bbIndices, 1), 1);
descriptions(:) = description;


%% Add all together
train = table(widths_image, heights_image, transpose(dist_x.relevant), widths_ground_truth, heights_ground_truth, descriptions, 'VariableNames', ["width image", "height image", "dist_x", "width ground truth", "height ground truth", "description"]);


%% Save train as .mat
% save('train_Audi_S3_2015.mat', "train");


%% Plot
% Width
% scatter(table2array(train(:,1)).*table2array(train(:,3)), table2array(train(:,4)));
% Height
% scatter(table2array(train(:,2)).*table2array(train(:,3)), table2array(train(:,5)));
