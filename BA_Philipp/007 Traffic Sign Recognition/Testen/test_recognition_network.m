% import table -> appears in workspace as "table"
load('table.mat');

% load recognition network -> appears as "convnet" in workspace
load('RecognitionNet.mat');

% make predictions for test set
idx_predicted = zeros(size(table, 1),1);
for i = (1: size(table, 1))
    % load image
    image = imread(table2array(table(i, 2)));
    image_resized = imresize(image,[48 48]);
    output = convnet.predict(image_resized);
    [~,idx_predicted(i, 1)] = max(output);
    disp(i)
end


% Map prediction output to actual class
idx_orig_classes = map_pred_to_orig_classes(idx_predicted);


% Get ground truth
gt = table2array(table(:,1));

% Get confusion matrix
% cm = confusionmat(gt, idx_orig_classes);
cm = confusionmat(gt, idx_orig_classes);


%% Hier stimmt etwas noch nicht mit den Zuordnungen
%% Ich glaube er sortiert die 32 hinter der 3 und vor der 4 ein

sum_total = sum(sum(cm))
sum_diag = sum(diag(cm))
accuracy = sum_diag / sum_total

%{
count_0 = sum(gt == 0);
count_1 = sum(gt == 1);
count_2 = sum(gt == 2);
count_3 = sum(gt == 3);
count_4 = sum(gt == 4);
count_5 = sum(gt == 5);
count_7 = sum(gt == 7);
count_8 = sum(gt == 8);
count_32 = sum(gt == 32);
%}