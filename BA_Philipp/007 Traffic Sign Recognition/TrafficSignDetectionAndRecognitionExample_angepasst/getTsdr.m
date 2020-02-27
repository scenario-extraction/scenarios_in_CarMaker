function [out1,out2] = getTsdr

 % Copyright 2017-2019 The MathWorks, Inc.

 % Return trained series network object for detecting Traffic Signals
 % Download trained Detection Network model from URL
 if exist('yolo_tsr.mat','file') == 0
	url = 'https://www.mathworks.com/supportfiles/gpucoder/cnn_models/traffic_sign_detection/yolo_tsr.mat';
	websave('yolo_tsr.mat',url);
 end
 net = load('yolo_tsr.mat');
 f = fields(net);
 f = f{1};
 out1 = net.(f); 
 
 % Return trained series network object for recognizing Traffic Signals
 % Download trained Recognition Network model from UR
 if exist('RecognitionNet.mat','file') == 0
	url = 'https://www.mathworks.com/supportfiles/gpucoder/cnn_models/traffic_sign_detection/RecognitionNet.mat';
	websave('RecognitionNet.mat',url);
 end
 net = load('RecognitionNet.mat');
 f = fields(net);
 f = f{1};
 out2 = net.(f);
 
end
