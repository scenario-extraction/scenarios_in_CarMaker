%% Traffic Sign Detection and Recognition
%
% This example shows how to generate CUDA(R) MEX code for a
% traffic sign detection and recognition application that uses deep learning.
% Traffic sign detection and recognition is an important application for driver
% assistance systems, aiding and providing information to the driver about road signs.
%
% <<../block_diagram_tsdr.png>>
%
% In this traffic sign detection and recognition example you perform 
% three steps - detection, Non-Maximal Suppression (NMS), and recognition.
% First, the example detects the traffic signs on an input image by using
% an object detection network that is a variant of the You Only Look Once (YOLO) network.
% Then, overlapping detections are suppressed by using the NMS algorithm.
% Finally, the recognition network classifies the detected traffic signs.
%
% Copyright 2017 - 2018 The MathWorks, Inc. 

%% Prerequisites
% * CUDA enabled NVIDIA(R) GPU with compute capability 3.2 or higher.
% * NVIDIA CUDA toolkit and driver.
% * NVIDIA cuDNN library.
% * Environment variables for the compilers and libraries. For information 
% on the supported versions of the compilers and libraries, see 
% <docid:gpucoder_gs#mw_aa8b0a39-45ea-4295-b244-52d6e6907bff
% Third-party Products>. For setting up the environment variables, see 
% <docid:gpucoder_gs#mw_453fbbd7-fd08-44a8-9113-a132ed383275
% Environment Variables>.
% * GPU Coder Interface for Deep Learning Libraries support package. To install
% this support package, use the <matlab:matlab.addons.supportpackage.internal.explorer.showSupportPackages('GPU_DEEPLEARNING_LIB','tripwire') Add-On Explorer>.

%% Verify GPU Environment
% Use the <docid:gpucoder_ref#mw_0957d820-192f-400a-8045-0bb746a75278 coder.checkGpuInstall> function
% to verify that the compilers and libraries necessary for running this example
% are set up correctly.
envCfg = coder.gpuEnvConfig('host');
envCfg.DeepLibTarget = 'cudnn';
envCfg.DeepCodegen = 1;
envCfg.Quiet = 1;
coder.checkGpuInstall(envCfg);

%% Detection and Recognition Networks
% The detection network is trained in the Darknet framework and imported 
% into MATLAB(R) for inference. Because the size of the traffic sign is 
% relatively small with respect to that of the image and the number 
% of training samples per class are fewer in the training data, all the 
% traffic signs are considered as a single class for training the 
% detection network. 
% 
% The detection network divides the input image into a 7-by-7 grid. Each
% grid cell detects a traffic sign if the center of the traffic sign falls 
% within the grid cell.
% Each cell predicts two bounding boxes and confidence scores for these 
% bounding boxes. Confidence scores indicate whether the box contains an 
% object or not. Each cell predicts on probability for finding the 
% traffic sign in the grid cell. The final score is product of the 
% preceeding scores. You apply a threshold of 0.2 on this final score to 
% select the detections.
% 
% The recognition network is trained on the same images by using MATLAB. 
%
% The <matlab:edit(fullfile(matlabroot,'examples','deeplearning_shared','main','trainRecognitionnet.m')) trainRecognitionnet.m>
% helper script shows the recognition network training.
%% Get the Pretrained SeriesNetwork
%
% Download the detection and recognition networks.
getTsdr();
%%
%
% The detection network contains 58 layers including convolution, leaky ReLU, and
% fully connected layers.
load('yolo_tsr.mat');
yolo.Layers

%%
%
% The recognition network contains 14 layers including convolution, fully connected, and the
% classification output layers.
load('RecognitionNet.mat');
convnet.Layers

%% The |tsdr_predict| Entry-Point Function
%
% The <matlab:edit(fullfile(matlabroot,'examples','deeplearning_shared','main','tsdr_predict.m')) tsdr_predict.m>
% entry-point function takes an image input and detects the traffic signs 
% in the image by using the detection network. The function suppresses the 
% overlapping detections (NMS) by using |selectStrongestBbox| and 
% recognizes the traffic sign by using the recognition network. The function loads the
% network objects from |yolo_tsr.mat| into a persistent variable
% _detectionnet_ and the |RecognitionNet.mat| into a persistent variable 
% _recognitionnet_. The function reuses the the persistent objects on subsequent calls.
%
type('tsdr_predict.m')

%% Generate CUDA MEX for the |tsdr_predict| Function
%
% Create a GPU configuration object for a MEX target and set the target
% language to C++. Use the
% <docid:gpucoder_ref#mw_e8e85f8e-8dde-45b6-9ec5-f121a79dc48f coder.DeepLearningConfig>
% function to create a |CuDNN| deep learning configuration object and
% assign it to the |DeepLearningConfig| property of the GPU code
% configuration object. To generate CUDA MEX, use the |codegen| command and 
% specify the input to be of size [480,704,3]. This value corresponds to 
% the input image size of the |tsdr_predict| function.
cfg = coder.gpuConfig('mex');
cfg.TargetLang = 'C++';
cfg.DeepLearningConfig = coder.DeepLearningConfig('cudnn');
codegen -config cfg tsdr_predict -args {ones(480,704,3,'uint8')} -report

%%
% 
% To generate code by using TensorRT, pass
% |coder.DeepLearningConfig('tensorrt')| as an option to the coder
% configuration object instead of |'cudnn'|.

%% Run Generated MEX
%
% Load an input image.
im = imread('stop.jpg');
imshow(im);
%%
% Call |tsdr_predict_mex| on the input image.
im = imresize(im, [480,704]);
[bboxes,classes] = tsdr_predict_mex(im);
%%
% Map the class numbers to traffic sign names in the class dictionary.
classNames = {'addedLane','slow','dip','speedLimit25','speedLimit35','speedLimit40','speedLimit45',...
    'speedLimit50','speedLimit55','speedLimit65','speedLimitUrdbl','doNotPass','intersection',...
    'keepRight','laneEnds','merge','noLeftTurn','noRightTurn','stop','pedestrianCrossing',...
    'stopAhead','rampSpeedAdvisory20','rampSpeedAdvisory45','truckSpeedLimit55',...
    'rampSpeedAdvisory50','turnLeft','rampSpeedAdvisoryUrdbl','turnRight','rightLaneMustTurn',...
    'yield','yieldAhead','school','schoolSpeedLimit25','zoneAhead45','signalAhead'};

classRec = classNames(classes);

%%
% Display the detected traffic signs.
outputImage = insertShape(im,'Rectangle',bboxes,'LineWidth',3);

for i = 1:size(bboxes,1)
    outputImage = insertText(outputImage,[bboxes(i,1)+bboxes(i,3) bboxes(i,2)-20],classRec{i},'FontSize',20,'TextColor','red');
end

imshow(outputImage);
%% Traffic Sign Detection and Recognition on a Video
%
% The included helper file
% <matlab:edit(fullfile(matlabroot,'examples','deeplearning_shared','main','tsdr_testVideo.m')) tsdr_testVideo.m>
% grabs frames from the test video, performs traffic sign detection and 
% recognition, and plots the results on each frame of the test video.
%%
%
%    % Input video
%    v = VideoReader('stop.avi');
%    fps = 0;
%
%
%     while hasFrame(v)
%        % Take a frame
%        picture = readFrame(v);
%        picture = imresize(picture,[920,1632]);
%        % Call MEX function for Traffic Sign Detection and Recognition
%        tic;
%        [bboxes,clases] = tsdr_predict_mex(picture);
%        newt = toc;
%
%        % fps
%        fps = .9*fps + .1*(1/newt);
%
%        % display
%
%         displayDetections(picture,bboxes,clases,fps);
%      end
%%
%
% Clear the static network objects that were loaded into memory. 
clear mex;
