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
% This short script is for training an ACF detector with the training data 
% created with "ts_detection_build_training_set"


%% Load data created in 'ts_detection_build_training_set'
load('ts_detection_train');


%% Train detector
detector = trainACFObjectDetector(ts_detection_train);


%% Save detector on hard drive
ts_detection_acfDetector = detector;
save('ts_detection_acfDetector', 'ts_detection_acfDetector');