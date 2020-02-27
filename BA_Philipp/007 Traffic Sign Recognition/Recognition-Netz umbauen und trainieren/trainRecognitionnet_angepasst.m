%   Based on a script from a Matlab example
%
%   Copyright 2017 The MathWorks, Inc.

% TO DO:
%{
- Prevent overfitting (Suchwort: "Early Stopping")
%https://de.mathworks.com/help/deeplearning/ug/improve-neural-network-generalization-and-avoid-overfitting.html#bss4gz0-32
%}

baseDir = "C:\Users\philipp\Documents\GitHub\BA_1\src\007 Verkehrsschilderkennung aktuell\Recognition-Netz umbauen und trainieren";

% Trainingsdaten anpassen
% Vorsicht: Das CNN nimmt die Subfolder-Namen in lexikographischer /
% alphabetischer Reihenfolge als Klassen!
% Bedeutet z.B., dass 3 < 32 < 4
images_train = imageDatastore('Train Images\train', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
images_validation = imageDatastore('Train Images\validation', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% Create an image augmenter object
%{
Reflection: wouldn't make sense
Rotation: Same
Scaling: No, because we scale all images to same size anyways
%}
shear = [0 0];
translation = [0 0];
augmenter = imageDataAugmenter( ...
    'RandXShear', shear, ...
    'RandYShear', shear, ...
    'RandXTranslation', translation, ...
    'RandYTranslation', translation);

% Resize all images and augment training images
augImages_train = augmentedImageDatastore([48 48], images_train, 'DataAugmentation', augmenter);
augImages_validation = augmentedImageDatastore([48 48], images_validation);

if 0
% Preview transformation
minibatch = preview(augImages_train);
imshow(imtile(minibatch.input));
end

% Parameter des vortrainierten Netzes laden
params = load("C:\Users\philipp\Documents\GitHub\BA_1\src\007 Verkehrsschilderkennung aktuell\Recognition-Netz umbauen und trainieren\nicht fertigtrainiertes Recognition Network (convnet)\43 Outputs\params_2020_02_21__15_55_17.mat");

%{
% Location of the training data set folder that has training images of
% cropped traffic signs in separate folders.
trainigDataPath = '';
tsrDatasetPath = fullfile(trainigDataPath);

tsrData = imageDatastore(tsrDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');

minSetCount = min(tsrData.countEachLabel{:,2});
trainingNumFiles = round(minSetCount * 1);
[trainTsrData,testTsrData] = splitEachLabel(tsrData, ...
    trainingNumFiles,'randomize');
%}

numClasses = 43; % Number of classes (traffic signs) in the training data

%% Network architecture

layers = [
    imageInputLayer([48 48 3],"Name","imageinput","DataAugmentation","randfliplr","Mean",params.imageinput.Mean)
    convolution2dLayer([7 7],100,"Name","conv_1","WeightsInitializer","narrow-normal","Bias",params.conv_1.Bias,"Weights",params.conv_1.Weights)
    reluLayer("Name","relu_1")
    maxPooling2dLayer([2 2],"Name","maxpool_1","Stride",[2 2])
    convolution2dLayer([4 4],150,"Name","conv_2","WeightsInitializer","narrow-normal","Bias",params.conv_2.Bias,"Weights",params.conv_2.Weights)
    reluLayer("Name","relu_2")
    maxPooling2dLayer([2 2],"Name","maxpool_2","Stride",[2 2])
    convolution2dLayer([4 4],250,"Name","conv_3","WeightsInitializer","narrow-normal","Bias",params.conv_3.Bias,"Weights",params.conv_3.Weights)
    maxPooling2dLayer([2 2],"Name","maxpool_3","Stride",[2 2])
    fullyConnectedLayer(300,"Name","fc_1","WeightsInitializer","narrow-normal","Bias",params.fc_1.Bias,"Weights",params.fc_1.Weights)
    dropoutLayer(0.9,"Name","dropout")
    fullyConnectedLayer(43,"Name","fc2_43_outputs","BiasLearnRateFactor", 10,"WeightLearnRateFactor", 10,"WeightsInitializer","narrow-normal")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput_43_outputs")];

%% Training-Optionen

% Pfad zum speichern der Checkpoints definieren
cpp = strcat(baseDir, "\checkpoints");

options = trainingOptions('sgdm', 'MaxEpochs', 4, 'InitialLearnRate', 0.001, 'MiniBatchSize', 256, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', cpp, 'Plots', 'training-progress', ...
    'ValidationData', augImages_validation, ...
    'ValidationFrequency', 25);
% https://de.mathworks.com/help/deeplearning/ref/trainingoptions.html
% save checkpoint networks
% https://de.mathworks.com/help/deeplearning/ug/resume-training-from-a-checkpoint-network.html

if 0
% Train from checkpoint
checkpoint = load("C:\Users\philipp\Documents\GitHub\BA_1\src\007 Verkehrsschilderkennung aktuell\Recognition-Netz umbauen und trainieren\checkpoints\net_checkpoint__240__2020_02_24__14_22_04.mat");
net = checkpoint.net;
convnet = trainNetwork(augImages_train, convnet.Layers, options);
end

%% Netz trainieren

% reduce learning rate over time!
convnet = trainNetwork(augImages_train, layers, options);


%% Netz speichern

% Save the Trained Network in matfile
% save('RecognitionNet.mat','convnet');
