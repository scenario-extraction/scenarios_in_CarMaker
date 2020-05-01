% This script is based on a script from this Matlab example:
% https://de.mathworks.com/help/gpucoder/examples/code-generation-for-traffic-sign-detection-and-recognition-networks.html
% Viewed 13.03.2020 14:38
% Copyright 2017 The MathWorks, Inc.


%% Do you want to train from checkpoint or from scratch?
trainFromCheckpoint = 0;


%% Define this directory as base directory and change to it
[baseDir, ~, ~] = fileparts(mfilename('fullpath'));
cd(baseDir);


%% Get training images
% Careful: CNN uses subfolder names in lexikographic /
% alphabetic order as class names!
% This means for example: 3 < 32 < 4
% -> Name subfolders like this: 00, 01, 02, ...
images_train = imageDatastore('Train Images\train', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
images_validation = imageDatastore('Train Images\validation', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');


%% Create an image augmenter object
%{
Which transformations to apply:
- Reflection: Wouldn't make sense for traffic signs
- Rotation: Same as Reflection
- Scaling: Not sure, but I think it doesn't make sense because we scale all images to same size anyways
- Translation: A bit can't hurt
    - Ended up training like this: 4 x 6 Epochs with translation = [-4 4] and 2 x 6 Epochs with no translation 
%}
shear = [0 0];
translation = [0 0];
augmenter = imageDataAugmenter( ...
    'RandXShear', shear, ...
    'RandYShear', shear, ...
    'RandXTranslation', translation, ...
    'RandYTranslation', translation);


%% Resize all images and augment training images
augImages_train = augmentedImageDatastore([48 48], images_train, 'DataAugmentation', augmenter);
augImages_validation = augmentedImageDatastore([48 48], images_validation);


if 0
    %% Preview transformation
    minibatch = preview(augImages_train);
    imshow(imtile(minibatch.input));
end


if ~trainFromCheckpoint
    %% Load parameters of pretrained network
    params = load(strcat(baseDir, "\Modified but untrained RecognitionNet (convnet)\43 Outputs\params_2020_02_21__15_55_17.mat"));

    
    %% Define number of classes
    numClasses = 43; % Number of classes (traffic signs) in the training data

    
    %% Define network architecture
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
end


%% Set training options
% Path where checkpoints shall be saved at
cpp = strcat(baseDir, "\checkpoints");
options = trainingOptions('sgdm', 'MaxEpochs', 6, 'InitialLearnRate', 0.001, 'MiniBatchSize', 256, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', cpp, 'Plots', 'training-progress', ...
    'ValidationData', augImages_validation, ...
    'ValidationFrequency', 25);


%% Train network
if trainFromCheckpoint
    %% Train from checkpoint
    checkpoint = load(strcat(baseDir, "\Trained RecognitionNets (convnets)\2020-03-09\4 x 6 Epochs, Translation -4 4, 2 x 6 Epochs, no Translation\net_checkpoint__720__2020_03_09__17_41_20.mat"));
    net = checkpoint.net;
    convnet = trainNetwork(augImages_train, net.Layers, options);
else
    convnet = trainNetwork(augImages_train, layers, options);
end


%% Just a line of code if network is already in workspace and you just want to keep training it
if 0
    convnet = trainNetwork(augImages_train, convnet.Layers, options);
end


%% Save network on hard drive
if 0
    save('RecognitionNet.mat','convnet');
end