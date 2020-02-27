%{
Notizen:
Funktioniert gut mit CM_images image_{51, 52, 85, 86, 109}
and thresh = 0.2 in 'tsdr_predict'
Erkennt faelschlicherweise zwei Schilder in: image_128
%}

% Zuerst: 
%{
- image in workspace importieren per Doppelclick
- Die zwei Netze in diesen Ordner kopieren falls nicht schon da
- Oder die Original-Netze herunterzuladen: getTsdr();
%}

% Load detection network and recognition network
load('yolo_tsr.mat');
% yolo.Layers
load('RecognitionNet.mat');
% convnet.Layers

img = image_51;
[selectedBbox, idx] = tsdr_predict(img, yolo, convnet);

if 0
% Klassennamen fuer das Original Recognition-Netz
classNames = {'addedLane','slow','dip','speedLimit25','speedLimit35','speedLimit40','speedLimit45',...
    'speedLimit50','speedLimit55','speedLimit65','speedLimitUrdbl','doNotPass','intersection',...
    'keepRight','laneEnds','merge','noLeftTurn','noRightTurn','stop','pedestrianCrossing',...
    'stopAhead','rampSpeedAdvisory20','rampSpeedAdvisory45','truckSpeedLimit55',...
    'rampSpeedAdvisory50','turnLeft','rampSpeedAdvisoryUrdbl','turnRight','rightLaneMustTurn',...
    'yield','yieldAhead','school','schoolSpeedLimit25','zoneAhead45','signalAhead'};
end

% Klassennamen fuer das Original Recognition-Netz
classNames = {'20', '30', '50', '60', 'unbegrenzt', '70', '80', '100', '120'};

% Bild-Ausgabe
I = insertShape(img, 'rectangle', selectedBbox, 'LineWidth', 5);

for i = 1:size(selectedBbox, 1)
    I = insertText(I,[selectedBbox(i,1) + selectedBbox(i,3) selectedBbox(i,2) - 20], ...
        classNames(idx(i)), 'FontSize', 20, 'TextColor', 'red');
end

imshow(I);

if 0
% Namen der erkannten Schilder sammeln
signs = strings(size(selectedBbox,1), 1);
for i = 1:size(idx,1)
    signs(i, 1) = classNames(idx(i));
end

% Display recognised traffic signs
disp(signs);
end