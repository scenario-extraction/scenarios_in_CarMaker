%% This script is for visually testing a trained ACF detector
% When executed it will detect traffic signs in a series of images and
% view them at the same rate as it detects


%% Change to folder of this script
[thisDir, ~, ~] = fileparts(mfilename('fullpath'));
cd(thisDir);


%% Get parent directory of thisDir
parentDir = extractBefore(thisDir, '005');


%% Load trained ACF detector
load('ts_detection_acfDetector');


%% Go to directory where test images are saved
cd(strcat(parentDir, '001 Data\CM images for detection and classification\5 fps'));


%%
for i = (0:600)
    imageNum = i;
    filename = strcat('image_', num2str(imageNum), '.jpg');
    image = imread(filename);
    bboxes = detect(ts_detection_acfDetector, image);
    % Insert found bounding boxes
    image = insertShape(image, 'rectangle', bboxes, 'LineWidth', 5);
    imshow(image);
% Set breakpoint in the following line to go through the images one by one
end
