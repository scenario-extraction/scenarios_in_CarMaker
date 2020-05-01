%% This script is for testing a neural network

%% Please load network that shall be tested into workspace manually by double clicking on it


%% Change to folder of this script
[thisDir, ~, ~] = fileparts(mfilename('fullpath'));
cd(thisDir);


%% Load test.mat
load('test.mat');


%% Evaluate class distribution in test set
ts_indices = unique(test.classID);
count = [transpose(ts_indices); histcounts(test.classID)];
% Plot a histogram
figure;
bar(count(1,:), count(2,:));



%% Make predictions for test set
idx_predicted = zeros(size(test.classID, 1), 1);
for i = (1:size(test.classID, 1))
    % load image
    image = imread(test.path(i));
    image_resized = imresize(image,[48 48]);
    output = convnet.predict(image_resized);
    [~,idx_predicted(i, 1)] = max(output);
    % fprintf(strcat(num2str(i), 32));
    disp(i);
end
disp(' ');


%% decrease all predicted classes by 1
idx_predicted = idx_predicted - 1;


%% Get confusion matrix
cm = confusionmat(test.classID, idx_predicted);


%% Compute and display test set accuracy
acc = (sum(diag(cm)) / sum(sum(cm)));
disp(strcat('Test set accuracy =', 32, num2str(acc)));
