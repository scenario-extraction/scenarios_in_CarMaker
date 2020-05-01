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
% This script is for creating a training set in order to train an ACF 
% detector to detect traffic signs in digital images


%% Please define folder containing numbered subforders with training images
path = "E:\BA\GTSDB\FullIJCNN2013";


%% Change to folder of this script
[thisDir, ~, ~] = fileparts(mfilename('fullpath'));
cd(thisDir);


%% Get ground truth data
gtData = TSD_readGTData("gt.txt");


%% Write Ground Truth data into an array
gtArray = zeros(size(gtData,2), 5);
for i = (1:size(gtData,2))
    row = gtData(i);
    gtArray(i, 1) = row.fileNo;
    gtArray(i, 2) = row.leftCol;
    gtArray(i, 3) = row.topRow;
    gtArray(i, 4) = row.rightCol;
    gtArray(i, 5) = row.bottomRow;
     gtArray(i, 6) = row.classID;
end


%% Transform to different bounding box format
gtArray(:, 4) = gtArray(:, 4) - gtArray(:, 2);
gtArray(:, 5) = gtArray(:, 5) - gtArray(:, 3);


%% Build a table with training data
cd(path);
% Get unique image numbers
im_num_unique = unique(gtArray(:, 1));
% Preallocate string array for paths
paths = strings(size(im_num_unique, 1), 1);
% Initialise index
index = 0;
% Initialise table
T = table('Size', [size(im_num_unique, 1), 2], ...
    'VariableTypes',{'string', 'cell'}, ...
    'VariableNames', {'imageFilename', 'bboxes'});
for i = transpose(im_num_unique)
    index = index + 1;
    image_num = i;
    filepath = strcat(path, '\', num2str(image_num,'%.5d'), '.ppm');
    idx = gtArray(:,1) == image_num;
    bboxes = gtArray(idx, :);
    % Show image with bounding boxes
    if 0
        string = strcat(num2str(image_num,'%.5d'), '.ppm');
        image = imread(string);
        hold on;
        image = insertShape(image, 'rectangle', bboxes(:,(2:5)), 'LineWidth', 5);
        imshow(image);
        hold off;
    % Place a marker at the following line to view images and bounding
    % boxes
    end
    % Fill table with current path
    T(index, 1) = {filepath};
    % Fill table with current bboxes
    T.bboxes{index} = bboxes(:, (2:5));
end


%% Save training set
cd(thisDir);
ts_detection_train = T;
save('ts_detection_train', 'ts_detection_train');


%% Just some code to view certain images:
if 0
    % Which image do you want to see?
    image_num = 317;
    path = "E:\BA\GTSDB\FullIJCNN2013";
    cd(path);
    string = strcat(num2str(image_num,'%.5d'), '.ppm');
    image = imread(string);
    hold on;
    imshow(image);
    hold off; 
end
