% *************************************************************************
% Author:   Philipp Metzger
%           Karlsruher Institut f�r Technologie
% Date:     12.05.2020
% *************************************************************************
%
% *************************************************************************
% Description
% *************************************************************************
%
% This script is for applying model 2 trained with "main_training"
%
% Please note: CarMaker seems to not realise when traffic objects are
% deleted in simulation environment. When deleted a traffic object in
% CarMaker, make sure to untick resprective output quantities in Output
% Quantities Selection. Otherwise they will be exportet as tables of zeros
% and cause problems.
%
% The setup that is used is defined as follows:
%
% Photos exported from IPGMovie with 1920 * 1080 pixels
% Camera Settings:
%   rot x/y/z: 0, 0, 0 (front) // 180 (rear)
% 	Distance: 0.001
% 	View point: See below in external parameters
% 	Field of view (degree): 50
% 	Lens: direct (fast, no distortion)
%
% Remark: To make yellow bounding boxes in CarMaker invisible, open 
% IPGMovie and navigate to: View -> Show -> Sensors


%% Set Main Directory
% Gives the directory of this script
[mainDir, ~, ~] = fileparts(mfilename('fullpath'));
% mainDir = 'C:\Users\philipp\Documents\GitHub\BA_1\src\006 Traffic Object Dimension Estimation';


%%%%%%%%%%%%%%%%
%% Input by user
%%%%%%%%%%%%%%%%


%% Testing mode? Are ground truth dimensions available? 
% Yes -> 1, No -> 0
testing = 1;


%% Do you want to detect bounding boxes from images provided or are they already loaded into the workspace?
% Detect: 1, Already loaded: 0
detect_bboxes = 1;
% Detecting bounding boxes takes a lot of time. Already detected Bounding 
% Boxes for Ground_Truth_Highway_two_lane_traffic are located in 
% ...\Data Application\bboxes


%% Do you want to save (and potentially overwrite) tensors on hard drive after running this script?
% Save: 1, Don't save: 0
saveTensor = 1;


%% Select distance in which traffic objects are ignored 
% (see section "Discard all bounding boxes of objects very close to the camera")
% Good limits can found by running this script as a function through "run_appl_fct.m"
limit_front = 0; % [m]
limit_rear = 0; % [m]


%% Display discarded bounding boxes: 1, Don't display: 0
dispDiscard = 0;


%% Set a tolerance for outlier treatment 
% Any values outside median +- tol * st. dev. 
% of respective detection object will be discarded
tol = 4;


%% Set model constants 
% (hardcopy of model constants: c_height = 2.419195333417422e+03, c_width = 2.208615854935864e+03)
% If unchanged, constants will be loaded from path defined in next line
load(strcat(mainDir, '\Results Training\var_optimal_no_bias_model_2'));
c_height = var.c_height;
c_width = var.c_width;


%% Time of first image and length of time steps between images
t_start = 0.0;
t_step = 1.0;
% t_step = 0.5;
% t_step = 0.2;


%% Set CarMaker output frequency
% CarMaker: Application -> OutputQuantities -> Data Rates -> Frequncy
freq = 50;


%% Front camera position [m]
front_cam_pos_x = 2.7;
front_cam_pos_y = 0;
front_cam_pos_z = 1.35;


%% Rear camera position [m]
rear_cam_pos_x = 0.8;
rear_cam_pos_y = 0;
rear_cam_pos_z = 1.35;


%% Sensor position [m]
% Defined in CM: Parameters -> Car -> Sensors -> Object -> Position x/y/z[m]
sensor_x = 2;
sensor_y = 0;
sensor_z = 0.5;


%% Detection range
range = 200; % [m]


%% For completeness: dimensions of Ego vehicle
ego_length = 4.28; 
ego_width = 1.82;
ego_height = 1.28;


%%%%%%%%%%%%%%%%%%%%%%%
%% End of input by user
%%%%%%%%%%%%%%%%%%%%%%%


%% Check if either both bboxes are in workspace or detect_bboxes == 1
if detect_bboxes == 0 && (~exist('bboxes_front', 'var') || ~exist('bboxes_rear', 'var'))
    disp('You need to either load bboxes_front and bboxes_rear into workspace or set detect_bboxes = 1 before running this script.');
    disp('bboxes_front and bboxes_rear are located in directory ".../Data Application/bboxes".');
    return
end


%% Check if tol > 0
if tol <= 0
    disp('"tol" needs to be positive');
    return
end


%% Set working directory
cd(mainDir);


%% Get Number of images per camera; For every point in time there is a front and  a rear image
n_photos = size(dir([strcat(mainDir, '\Data Application\images\front') '/*.jpg']), 1);


%% Get "radar" data
%{
The sensor data of Ego can be retrieved from .erg-file through cmread function
for example by running Amine's code until the point where cmread is called inside
datapreparation.m
%}
path = strcat(mainDir, '\Data Application\erg, radar\data');

data_radar = load(path, 'data');


%% Retrieve raw radar data; Note: Origin of coordinate system is sensor position defined above
radar.raw = struct;
for k = 0:9
    if isfield(data_radar.data, ['Sensor_Object_OB01_Obj_T0' num2str(k) '_NearPnt_ds_z'])
        n = k+1;
        radar.raw.x(:, n) = eval(strcat('data_radar.data.Sensor_Object_OB01_Obj_T0', num2str(k), '_NearPnt_ds_x.data'));
        radar.raw.y(:, n) = eval(strcat('data_radar.data.Sensor_Object_OB01_Obj_T0', num2str(k), '_NearPnt_ds_y.data'));
        radar.raw.z(:, n) = eval(strcat('data_radar.data.Sensor_Object_OB01_Obj_T0', num2str(k), '_NearPnt_ds_z.data'));
    end
end
for k = 10:256
    if isfield(data_radar.data, ['Sensor_Object_OB01_Obj_T' num2str(k) '_NearPnt_ds_z'])
        n = k+1;
        radar.raw.x(:, n) = eval(strcat('data_radar.data.Sensor_Object_OB01_Obj_T', num2str(k), '_NearPnt_ds_x.data'));
        radar.raw.y(:, n) = eval(strcat('data_radar.data.Sensor_Object_OB01_Obj_T', num2str(k), '_NearPnt_ds_y.data'));
        radar.raw.z(:, n) = eval(strcat('data_radar.data.Sensor_Object_OB01_Obj_T', num2str(k), '_NearPnt_ds_z.data'));
    end
end

%% Delete zeros (they need to be NaN for next step)
zeros_x = find(~radar.raw.x);
zeros_y = find(~radar.raw.y);
zeros_z = find(~radar.raw.z);
radar.raw.x(zeros_x) = NaN;
radar.raw.y(zeros_y) = NaN;
radar.raw.z(zeros_z) = NaN;


%% Convert to (x, y, z)_from_front_camera
radar.from_front_camera.x = radar.raw.x - (front_cam_pos_x - sensor_x);
radar.from_front_camera.y = radar.raw.y - (front_cam_pos_y - sensor_y);
radar.from_front_camera.z = radar.raw.z - (front_cam_pos_z - sensor_z);


%% Convert to (x, y, z)_from_rear_camera
radar.from_rear_camera.x = radar.raw.x - (rear_cam_pos_x - sensor_x);
radar.from_rear_camera.y = radar.raw.y - (rear_cam_pos_y - sensor_y);
radar.from_rear_camera.z = radar.raw.z - (rear_cam_pos_z - sensor_z);


%% Get "in range" true/false for every object for every point in time
range_front = range;
range_back = range;
inrange = zeros(size(radar.from_front_camera.x, 1), size(radar.from_front_camera.x, 2));
for index = (1:size(radar.from_front_camera.x, 2))
    inrange(:, index) = ~isnan(radar.raw.x(:, index)) & radar.raw.x(:,index) <= range_front & radar.raw.x(:,index) >= -range_back;
end


%% Get "in range" intervals for every object
% indices are first and last indices where object is in range
% To a copy of inrange, add a row of zeros in the end
row_of_zeros = zeros(1, size(radar.from_front_camera.x, 2));
inrange_copy = [inrange; row_of_zeros];
% intervals = zeros(2, size(radar.from_front_camera.x, 2));
for index = (1:size(radar.from_front_camera.x, 2))
    k = 1;
    while any(inrange_copy(:, index))
        intervals(k, index) = find(inrange_copy(:, index), 1, 'first');
        k = k + 1;
        intervals(k, index) = intervals(k-1, index) + find(~inrange_copy((intervals(k-1, index):end), index), 1, 'first') - 2;
        inrange_copy((intervals(k-1, index):intervals(k, index)), index) = 0;
        k = k + 1;
    end
end


%% Define a new object for every interval but remember correspondence to original objects
% Save number of intervals per traffic object
num_intervals = zeros(1, size(radar.raw.x, 2));
for index = (1:size(radar.raw.x, 2))
    num_intervals(index) = numel(find(intervals(:, index))) / 2; 
end
% Convert intervals to a single vector
intervals_vec = intervals(find(intervals));
% Create a table with: 2nd and 3rd row: Detection interval, 
% 1st row: Index of original traffic object
DetectObjects = [];
k = 1;
i = 1;
for object = (1:size(radar.raw.x, 2))
    for index = (1:num_intervals(1,object))
        DetectObjects(1, i) = intervals_vec(k) / freq;
        k = k + 1;
        DetectObjects(2, i) = intervals_vec(k) / freq;
        k = k + 1;
        DetectObjects(3, i) = object;
        i = i + 1;
    end
end



%% Sort in the same way as Amine's implementation sorts it
pointer = 1;
prev = 99;
count = size(DetectObjects, 2);
while pointer <= count
    if prev == DetectObjects(3, pointer)
       store = DetectObjects(:, pointer);
       DetectObjects(:, pointer) = [];
       DetectObjects = [DetectObjects, zeros(3,1)];
       DetectObjects(:, count) = store;
    else
        prev = DetectObjects(3, pointer);
        pointer = pointer + 1;
    end
end


%% Define detect objects
for i = (1:count)
    DetectObjects(4, i) = i;
end


%% Get all bounding boxes
% This step takes a lot of time. Already detected Bounding Boxes for 
% Ground_Truth_Highway_two_lane_traffic are located in ...\Data Application\bboxes

%{
Output of this step:
"bboxes_front" // "bboxes_rear"
(coordinate system for raw images: x = right, y = down, origin = upper left
corner of image)
- 1st and 2nd column: Position of upper left corner of bounding box
- 3rd and 4th column: width and height of bounding box
- 5th column: Time [s]
- Later: 
- 6th column: Radar object ID
- 7th column: Detection object ID
- 8th column: Estimated width
- 9th column: Estimated height
%}

if detect_bboxes
    % Initialise vehicle detector
    % Documentation:
    % https://de.mathworks.com/help/driving/ref/vehicledetectoracf.html?s_tid=doc_ta
    detector = vehicleDetectorACF('front-rear-view');

    %% Front camera
    bboxes_front = [];
    disp(strcat('Getting front camera bounding boxes from', 32, num2str(n_photos), ' images:'));
    for index = (1:n_photos)
        % Print progess
        fprintf(strcat(num2str(index), 32));
        % Time
        t = t_start + ((index - 1) * t_step);
        % Load image
        string = strcat(mainDir, '\Data Application\images\front\image_', num2str((index - 1),'%.0f'), '.jpg');
        I = imread(string);
        % Detect car
        [bboxes,~] = detect(detector, I);
        % Don't add bounding boxes that are made for t = 0 (leads to
        % problems later on
        if ~isempty(bboxes) && t ~= 0
            bboxes(:,5) = t; 
            bboxes_front = [bboxes_front; bboxes];
        end
    end

    %% Rear camera
    bboxes_rear = [];
    disp(' ');
    disp(strcat('Getting rear camera bounding boxes from', 32, num2str(n_photos), ' images:'));
    for index = (1:n_photos)
        fprintf(strcat(num2str(index), 32));
        % Time
        t = t_start + ((index - 1) * t_step);
        % Load image
        string = strcat(mainDir, '\Data Application\images\rear\image_', num2str((index - 1),'%.0f'), '.jpg');
        I = imread(string);
        % Detect car
        [bboxes,~] = detect(detector, I);
        % Don't add bounding boxes that are made for t = 0 (leads to
        % problems later on
        if ~isempty(bboxes) && t ~= 0
            bboxes(:,5) = t; 
            bboxes_rear = [bboxes_rear; bboxes];
        end
    end
    
    
    %% Save bounding boxes on hard drive
    save(strcat(mainDir, '\Data Application\bboxes\bboxes_front'), 'bboxes_front');
    save(strcat(mainDir, '\Data Application\bboxes\bboxes_rear'), 'bboxes_rear');
end


%% Association bounding boxes <-> traffic objects
%{
Determine where in image objects would theoretically be displayed by front
camera
Concept:
y_theoretical_photo = y_from_front_camera / x_from_front_camera * c_width
z_theoretical_photo = z_from_front_camera / x_from_front_camera * c_height
%}


%% Create a struct for this process
Assoc = struct;


%% Front camera

% If any bounding boxes exist
if ~isempty(bboxes_front)
    
    %% Make copies of radar.from_front_camera.(x, y, z)
    Assoc.front.data.x = radar.from_front_camera.x;
    Assoc.front.data.y = radar.from_front_camera.y;
    Assoc.front.data.z = radar.from_front_camera.z;


    %% Delete (x, y, z)_from_front_camera < 0
    irrelevant_front = find(radar.from_front_camera.x < 0);
    Assoc.front.data.x(irrelevant_front) = NaN;
    Assoc.front.data.y(irrelevant_front) = NaN;
    Assoc.front.data.z(irrelevant_front) = NaN;


    %% Calculate theoretical positions in image [pixels]
    Assoc.front.theoretical_image_pos.y = Assoc.front.data.y ./ Assoc.front.data.x .* c_width;
    Assoc.front.theoretical_image_pos.z = Assoc.front.data.z ./ Assoc.front.data.x .* c_height;


    %% Get image time, center y, center z, width and height
    %{
    Output: 
    "Assoc.front.bboxes_centers"
    1st column: image time
    2nd and 3rd column: (y, z) of bboxes' center
    %}

    % time
    Assoc.front.bboxes_centers(:, 1) = bboxes_front(:, 5);
    % center y
    Assoc.front.bboxes_centers(:, 2) = bboxes_front(:, 1) + (bboxes_front(:, 3) ./ 2);
    % center z
    Assoc.front.bboxes_centers(:, 3) = bboxes_front(:, 2) + (bboxes_front(:, 4) ./ 2);
    % width
    Assoc.front.bboxes_centers(:, 4) = bboxes_front(:, 3);
    % height
    Assoc.front.bboxes_centers(:, 5) = bboxes_front(:, 4);


    %% Get image resolution
    string = strcat(mainDir, '\Data Application\images\rear\image_0.jpg');
    I = imread(string);
    [pixels_z, pixels_y, ~] = size(I);


    %% Transform to CarMaker coordinate system
    Assoc.front.bboxes_centers(:, 2) = -(Assoc.front.bboxes_centers(:, 2) - (pixels_y / 2) - 0.5);
    Assoc.front.bboxes_centers(:, 3) = -(Assoc.front.bboxes_centers(:, 3) - (pixels_z / 2) - 0.5);


    %% Make association between bounding boxes and traffic objects
    for bb = (1:size(Assoc.front.bboxes_centers, 1))

        % Get index in CarMaker data
        index = int64(Assoc.front.bboxes_centers(bb, 1) * freq);

        % Get theoretical image positions
        % y
        candidates_y = Assoc.front.theoretical_image_pos.y(index, :);
        % z
        candidates_z = Assoc.front.theoretical_image_pos.z(index, :);
        
        % if there are at least 2 options
        if size(candidates_y, 2) >= 2
            
            %% If two point are too close to each other, delete the one corresponding to traffic object that is further away
            % Get distance in x of all candidates
            candidates_dist_x = Assoc.front.data.x(index, :);

            % Get pairwise euclidian distances
            euc_pairwise = squareform(pdist(transpose([candidates_y; candidates_z])));
            euc_pairwise = tril(euc_pairwise);

            % Find the pairs that are close to each other
            linLoc = find(euc_pairwise ~= 0 & euc_pairwise < Assoc.front.bboxes_centers(bb, 4));

            % Get their indices
            loc(:, 1) = rem(linLoc(:, 1), size(euc_pairwise, 1));

            % Write highest number where zero
            loc(find(~loc(:, 1))) = size(euc_pairwise, 1);
            loc(:, 2) = ceil(linLoc(:, 1) / size(euc_pairwise, 1));

            % Delete values where distance in x is greater
            for closeCandidates = (1:size(loc, 1))    
                if candidates_dist_x(loc(closeCandidates, 1)) >= candidates_dist_x(loc(closeCandidates, 2))
                    candidates_y(loc(closeCandidates, 1)) = NaN;
                else
                    candidates_y(loc(closeCandidates, 2)) = NaN;        
                end
            end
            clear linLoc loc;

            %% Choose the candidate, whose theoretical image position is closer to the center of the bounding box
            % Get euclidian distances in (y, z) of candidates to bounding box center [pixels]
            euc = sqrt((Assoc.front.bboxes_centers(bb, 2) - candidates_y).^2 + (Assoc.front.bboxes_centers(bb, 3) - candidates_z).^2);

            % Get count of non-NaN values in euc
            nonNanCount = sum(~isnan(euc));

            % Get 1st minimum
            [min_1, index_min_1] = min(euc);

            if nonNanCount == 0
                bboxes_front(bb, 6) = NaN;
            else
                if min_1 > 2 * Assoc.front.bboxes_centers(bb, 4)
                    % If most optimal candidate is quite far away from bounding box'
                    % center (2 * width of bounding box): 
                    % Do not associate this bounding box with any traffic object
                    bboxes_front(bb, 6) = NaN;
                else
                    bboxes_front(bb, 6) = index_min_1;
                end
            end
            
        else
            % If there is only 1 option
            euc = sqrt((Assoc.front.bboxes_centers(bb, 2) - candidates_y).^2 + (Assoc.front.bboxes_centers(bb, 3) - candidates_z).^2);

            if isnan(euc)
                bboxes_front(bb, 6) = NaN;
            else
                if euc > 2 * Assoc.front.bboxes_centers(bb, 4)
                    % If this one candidate is quite far away from bounding box'
                    % center (2 * width of bounding box): 
                    % Do not associate this bounding box with any traffic object
                    bboxes_front(bb, 6) = NaN;
                else
                    bboxes_front(bb, 6) = 1;
                end
            end
        end
    end
end


%% Rear camera

% If any bounding boxes exist
if ~isempty(bboxes_rear)
    
    %% Make copies of radar.from_rear_camera.(x, y, z) and account for new camera direction
    Assoc.rear.data.x = - radar.from_rear_camera.x;
    Assoc.rear.data.y = - radar.from_rear_camera.y;
    Assoc.rear.data.z = radar.from_rear_camera.z;


    %% Delete, where x_from_rear_camera > 0
    irrelevant_rear = find(radar.from_rear_camera.x > 0);
    Assoc.rear.data.x(irrelevant_rear) = NaN;
    Assoc.rear.data.y(irrelevant_rear) = NaN;
    Assoc.rear.data.z(irrelevant_rear) = NaN;


    %% Calculate theoretical positions in image [pixels]
    Assoc.rear.theoretical_image_pos.y = Assoc.rear.data.y ./ Assoc.rear.data.x .* c_width;
    Assoc.rear.theoretical_image_pos.z = Assoc.rear.data.z ./ Assoc.rear.data.x .* c_height;


    %% Get image ID, center y, center z, width and height
    %{
    Output: 
    "Assoc.rear.bboxes_centers"
    1st column: image ID
    2nd and 3rd column: (y, z) of bboxes' center
    %}
    % ID
    Assoc.rear.bboxes_centers(:, 1) = bboxes_rear(:, 5);
    % center y
    Assoc.rear.bboxes_centers(:, 2) = bboxes_rear(:, 1) + (bboxes_rear(:, 3) ./ 2);
    % center z
    Assoc.rear.bboxes_centers(:, 3) = bboxes_rear(:, 2) + (bboxes_rear(:, 4) ./ 2);
    % width
    Assoc.rear.bboxes_centers(:, 4) = bboxes_rear(:, 3);
    % height
    Assoc.rear.bboxes_centers(:, 5) = bboxes_rear(:, 4);


    % Get image resolution
    string = strcat(mainDir, '\Data Application\images\rear\image_0.jpg');
    I = imread(string);
    [pixels_z, pixels_y, ~] = size(I);


    %% Transform to CarMaker coordinate system
    Assoc.rear.bboxes_centers(:, 2) = -(Assoc.rear.bboxes_centers(:, 2) - (pixels_y / 2) - 0.5);
    Assoc.rear.bboxes_centers(:, 3) = -(Assoc.rear.bboxes_centers(:, 3) - (pixels_z / 2) - 0.5);


    %% %% Make association between bounding boxes and traffic objects
    for bb = (1:size(Assoc.rear.bboxes_centers, 1))

        % Get index in CarMaker data
        index = int64(Assoc.rear.bboxes_centers(bb, 1) * freq);

        % Get theoretical image positions
        % y
        candidates_y = Assoc.rear.theoretical_image_pos.y(index, :);
        % z
        candidates_z = Assoc.rear.theoretical_image_pos.z(index, :);
        
        % if there are at least 2 options
        if size(candidates_y, 2) >= 2
            
            % Get distance in x of all candidates
            candidates_dist_x = Assoc.rear.data.x(index, :);

            % Get pairwise euclidian distances
            euc_pairwise = squareform(pdist(transpose([candidates_y; candidates_z])));
            euc_pairwise = tril(euc_pairwise);

            % If two point are too close to each other, delete the one coresponding
            % to traffic object that is further away
            % Find the pairs that are close to each other
            linLoc = find(euc_pairwise ~= 0 & euc_pairwise < Assoc.rear.bboxes_centers(bb, 4));

            % Get their indices
            loc(:, 1) = rem(linLoc(:, 1), size(euc_pairwise, 1));

            % Write highest number where zero
            loc(find(~loc(:, 1))) = size(euc_pairwise, 1);
            loc(:, 2) = ceil(linLoc(:, 1) / size(euc_pairwise, 1));

            % Delete values where distance in x is greater
            for closeCandidates = (1:size(loc, 1))    
                if candidates_dist_x(loc(closeCandidates, 1)) >= candidates_dist_x(loc(closeCandidates, 2))
                    candidates_y(loc(closeCandidates, 1)) = NaN;
                else
                    candidates_y(loc(closeCandidates, 2)) = NaN;        
                end
            end
            clear linLoc loc;

            % Get euclidian distances in (y, z) of candidates to bounding box center [pixels]
            euc = sqrt((Assoc.rear.bboxes_centers(bb, 2) - candidates_y).^2 + (Assoc.rear.bboxes_centers(bb, 3) - candidates_z).^2);

            % Get count of non-NaN values in euc
            nonNanCount = sum(~isnan(euc));

            % Get 1st minimum
            [min_1, index_min_1] = min(euc);

            if nonNanCount == 0
                bboxes_rear(bb, 6) = NaN;
            else
                if min_1 > 2 * Assoc.rear.bboxes_centers(bb, 4)
                    % If most optimal candidate is quite far away from bounding box'
                    % center (2 * width of bounding box): 
                    % Do not associate this bounding box with any traffic object
                    bboxes_rear(bb, 6) = NaN;
                else
                    bboxes_rear(bb, 6) = index_min_1;
                end 
            end
            
        else
            % If there is only 1 option
            euc = sqrt((Assoc.front.bboxes_centers(bb, 2) - candidates_y).^2 + (Assoc.front.bboxes_centers(bb, 3) - candidates_z).^2);

            if isnan(euc)
                bboxes_front(bb, 6) = NaN;
            else
                if euc > 2 * Assoc.front.bboxes_centers(bb, 4)
                    % If this one candidate is quite far away from bounding box'
                    % center (2 * width of bounding box): 
                    % Do not associate this bounding box with any traffic object
                    bboxes_front(bb, 6) = NaN;
                else
                    bboxes_front(bb, 6) = 1;
                end
            end
        end
    end
end

if 0
%%Plot bounding box and theoretical positions of traffic objects in image
% Red: Selected traffic object
% Blue: The other traffic objects
%% Front Camera
for bb = 1:size(bboxes_front, 1)
    % Time
    t = bboxes_front(bb, 5);
    % Load image
    string = strcat(mainDir, '\Data Application\images\front\image_', num2str(t,'%.0f'), '.jpg');
    I = imread(string);
    % Add bounding box
    I = insertShape(I, 'rectangle', bboxes_front(bb,(1:4)), 'LineWidth', 5);
    if ~isnan(bboxes_front(bb, 6))
        % Get theoretical image position of selected object in image coordinate
        % system
        y = -(Assoc.front.theoretical_image_pos.y(t * freq, bboxes_front(bb, 6))) + (pixels_y / 2) + 0.5;
        z = -(Assoc.front.theoretical_image_pos.z(t * freq, bboxes_front(bb, 6))) + (pixels_z / 2) + 0.5;
    end
    % Get theoretical image positions of all objects in image coordinate
    % system
    y_all = -(Assoc.front.theoretical_image_pos.y(t * freq, :)) + (pixels_y / 2) + 0.5;
    z_all = -(Assoc.front.theoretical_image_pos.z(t * freq, :)) + (pixels_z / 2) + 0.5;
    % Show image and plot theoretical image positions
    imshow(I);
    hold on;
    plot(y_all, z_all, 'b+', 'MarkerSize', 30, 'LineWidth', 2);
    if ~isnan(bboxes_front(bb, 6))
        plot(y, z, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
    end
    hold off;
% Set a breakpoint at the following line to view plots one by one
end
end

if 0
%% Rear Camera
for bb = 1:size(bboxes_rear, 1)
    % Time
    t = bboxes_rear(bb, 5);
    % Load image
    string = strcat(mainDir, '\Data Application\images\rear\image_', num2str(t,'%.0f'), '.jpg');
    I = imread(string);
    % Add bounding box
    I = insertShape(I, 'rectangle', bboxes_rear(bb,(1:4)), 'LineWidth', 5);
    if ~isnan(bboxes_rear(bb, 6))
        % Get theoretical image position of selected object in image coordinate
        % system
        y = -(Assoc.rear.theoretical_image_pos.y(t * freq, bboxes_rear(bb, 6))) + (pixels_y / 2) + 0.5;
        z = -(Assoc.rear.theoretical_image_pos.z(t * freq, bboxes_rear(bb, 6))) + (pixels_z / 2) + 0.5;
    end
    % Get theoretical image positions of all objects in image coordinate
    % system
    y_all = -(Assoc.rear.theoretical_image_pos.y(t * freq, :)) + (pixels_y / 2) + 0.5;
    z_all = -(Assoc.rear.theoretical_image_pos.z(t * freq, :)) + (pixels_z / 2) + 0.5;
    % Show image and plot theoretical image positions
    imshow(I);
    hold on;
    plot(y_all, z_all, 'b+', 'MarkerSize', 30, 'LineWidth', 2);
    if ~isnan(bboxes_rear(bb, 6))
        plot(y, z, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
    end
    hold off;
% Set a breakpoint at the following line to view plots one by one
end
end


%% Discard all bounding boxes of objects very close to the camera
% Idea here is: When dist_x is very small, in most cases Ego is overtaking 
% the other car (or is being overtaken by it).
% In these situations we get inaccurate bounding box widths because Ego
% sees the car from a diagonal perspective.
% -> We ignore bounding boxes from these situations
% Limits are defined in the beginning of the script.
% Good limits can found by running this script as a function through
% "run_appl_fct.m"
%% Front
if dispDiscard
    disp(' ');
    disp('discarding as result of distance limit front:');
end
for bb = 1:size(bboxes_front, 1)
    time = bboxes_front(bb, 5);
    object = bboxes_front(bb, 6);
    if ~isnan(bboxes_front(bb, 6))
        if radar.from_front_camera.x(int64(time * freq), object) <= limit_front
            if dispDiscard
                disp(strcat('time: ', num2str(time), ', object: ', num2str(object)));
            end
            bboxes_front(bb, 6) = NaN;
        end
    end
end
%% Rear
if dispDiscard
    disp(' ');
    disp('discarding as result of distance limit rear:');
end
for bb = 1:size(bboxes_rear, 1)
    time = bboxes_rear(bb, 5);
    object = bboxes_rear(bb, 6);
    if ~isnan(bboxes_rear(bb, 6))
        if radar.from_rear_camera.x(int64(time * freq), object) >= -(limit_rear)
            if dispDiscard
                disp(strcat('time: ', num2str(time), ', object: ', num2str(object)));
            end
            bboxes_rear(bb, 6) = NaN;
        end
    end
end


%% Select the right detection object per bounding box
%% Front
for bb = 1:size(bboxes_front, 1)
    if ~isnan(bboxes_front(bb, 6))
        radarObj = bboxes_front(bb, 6);
        for detObj = (1:count)
           if radarObj == DetectObjects(3, detObj) && bboxes_front(bb, 5) >= DetectObjects(1, detObj) && bboxes_front(bb, 5) <= DetectObjects(2, detObj) 
               bboxes_front(bb, 7) = DetectObjects(4, detObj);
           end
        end
    else
        bboxes_front(bb, 7) = NaN;
    end
end
%% Rear
for bb = 1:size(bboxes_rear, 1)
    if ~isnan(bboxes_rear(bb, 6))
        radarObj = bboxes_rear(bb, 6);
        for detObj = (1:count)
           if radarObj == DetectObjects(3, detObj) && bboxes_rear(bb, 5) >= DetectObjects(1, detObj) && bboxes_rear(bb, 5) <= DetectObjects(2, detObj) 
               bboxes_rear(bb, 7) = DetectObjects(4, detObj);
           end
        end
    else
        bboxes_rear(bb, 7) = NaN;
    end
end


%% Calculate real height and width of objects [m]
%{
Concept:
height_real = height_image * x_from_camera / c_height
width_real = width_image * x_from_camera / c_width
%}
%% Front Camera
% Width
for bb = 1:size(bboxes_front, 1)
    if ~isnan(bboxes_front(bb, 6))
        % If bounding box has an associated traffic object
        % Width
        bboxes_front(bb, 8) = bboxes_front(bb, 3) * radar.from_front_camera.x(int64(bboxes_front(bb, 5) .* freq), bboxes_front(bb, 6)) / c_width;
        % Height
        bboxes_front(bb, 9) = bboxes_front(bb, 4) * radar.from_front_camera.x(int64(bboxes_front(bb, 5) .* freq), bboxes_front(bb, 6)) / c_height ;
    else
        bboxes_front(bb, 8) = NaN;
        bboxes_front(bb, 9) = NaN;
    end
end
%% Rear Camera
for bb = 1:size(bboxes_rear, 1)
    if ~isnan(bboxes_rear(bb, 6))
        % If bounding box has an associated traffic object
        % Width
        bboxes_rear(bb, 8) = bboxes_rear(bb, 3) * (-radar.from_rear_camera.x(int64(bboxes_rear(bb, 5) .* freq), bboxes_rear(bb, 6))) / c_width;
        % Height
        bboxes_rear(bb, 9) = bboxes_rear(bb, 4) * (-radar.from_rear_camera.x(int64(bboxes_rear(bb, 5) .* freq), bboxes_rear(bb, 6))) / c_height;
    else
        bboxes_rear(bb, 8) = NaN;
        bboxes_rear(bb, 9) = NaN;
    end
end


%% Save calculated sizes and IDs for validation purposes
if ~isempty(bboxes_front)
    valid_front = [bboxes_front(:,6), bboxes_front(:,8), bboxes_front(:,9)];
    valid_front = valid_front(sum(isnan(valid_front),2)==0, :);
end
if ~isempty(bboxes_rear)
    valid_rear = [bboxes_rear(:,6), bboxes_rear(:,8), bboxes_rear(:,9)];
    valid_rear = valid_rear(sum(isnan(valid_rear),2)==0, :);
end


%% Treat outliers
%{
Separate categories for outliers treatment: (width, height) X detection objects
Note: It is assumed, that membership to traffic object categories is
unknown and only membership to detection object categories is known
%}
%% Width
% Preallocate an array for validation purposes
widths_all_without_outliers = [];
% Get all IDs and widths
% Handle errors in case bboxes_front//rear are is empty
if ~isempty(bboxes_front) && ~isempty(bboxes_rear) 
    widths = [bboxes_front(:, (7:8)); bboxes_rear(:, (7:8))];
elseif ~isempty(bboxes_front) && isempty(bboxes_rear) 
    widths = bboxes_front(:, (7:8));
elseif isempty(bboxes_front) && ~isempty(bboxes_rear) 
    widths = bboxes_rear(:, (7:8));
else
    disp('Error: There are no bounding boxes');
    return
end
% Delete NaN values
widths(any(isnan(widths), 2), :) = [];
% Get IDs of all involved traffic objects
ids = unique(widths(:, 1));
% Sort by ID
widths = sortrows(widths);
% Seperate traffic objects
widths_array = zeros(2, size(ids,1));
% 1st row: Traffic object indices
% 2nd row: mean after removing of outliers
for obj = (1:size(ids, 1))
    % Save index
    widths_array(1, obj) = widths(1, 1);
    % Get values for this object
    logical = (widths(:, 1) == ids(obj));
    widths_obj = widths(logical, 2);
    % Delete from vector
    widths = widths(size(widths_obj,1) + 1:end, :);
    % Calculate standard deviation of this object
    stDev = std(widths_obj);
    % Calculate median of this object
    med = median(widths_obj);
    if 0
    % Plot values and print interval +- 3 standard deviation from median 
    figure;
    scatter(widths_obj, ones(size(widths_obj, 1), 1));
    hold on;
    scatter(med - tol * stDev, 1, 500, 'r', 'x');
    scatter(med + tol * stDev, 1, 500, 'r', 'x');
    hold off;
    end
    % Delete outliers
    logical = widths_obj >= med - tol * stDev & widths_obj <= med + tol * stDev;
    widths_obj_without_outliers = widths_obj(logical);
    % Save all values in one array for validation purposes
    widths_all_without_outliers = [widths_all_without_outliers; [widths_obj_without_outliers, ones(size(widths_obj_without_outliers, 1), 1) * ids(obj)]];
    % Calculate each detection object's arithmetic mean
    widths_array(2, obj) = mean(widths_obj_without_outliers);
end

%% Height
% Preallocate an array for validation purposes
heights_all_without_outliers = [];
% Get all IDs and heights
% Handle errors in case bboxes_front//rear are is empty
if ~isempty(bboxes_front) && ~isempty(bboxes_rear) 
    heights = [bboxes_front(:, 7), bboxes_front(:, 9); bboxes_rear(:, 7), bboxes_rear(:, 9)];
elseif ~isempty(bboxes_front) && isempty(bboxes_rear)
    heights = [bboxes_front(:, 7), bboxes_front(:, 9)];
elseif isempty(bboxes_front) && ~isempty(bboxes_rear)
    heights = [bboxes_rear(:, 7), bboxes_rear(:, 9)];
else
    disp('Error: There are no bounding boxes');
    return
end
% Delete NaN values
heights(any(isnan(heights), 2), :) = [];
% Get IDs of all involved traffic objects
ids = unique(heights(:, 1));
% Sort by ID
heights = sortrows(heights);
% Seperate traffic objects
heights_array = zeros(2, size(ids,1));
% 1st row: Traffic object indices
% 2nd row: mean after removing of outliers
for obj = (1:size(ids, 1))
    % Save index
    heights_array(1, obj) = heights(1, 1);
    % Get values for this object
    logical = (heights(:, 1) == ids(obj));
    heights_obj = heights(logical, 2);
    % Delete from vector
    heights = heights(size(heights_obj,1) + 1:end, :);
    % Calculate standard deviation of this object
    stDev = std(heights_obj);
    % Calculate median of this object
    med = median(heights_obj);
    if 0
    % Plot values and print interval +- 3 standard deviation from median 
    figure;
    scatter(heights_obj, ones(size(heights_obj, 1), 1));
    hold on;
    scatter(med - tol * stDev, 1, 500, 'r', 'x');
    scatter(med + tol * stDev, 1, 500, 'r', 'x');
    hold off;
    end
    % Delete outliers
    logical = heights_obj >= med - tol * stDev & heights_obj <= med + tol * stDev;
    heights_obj_without_outliers = heights_obj(logical);
    % Save all values in one array for validation purposes
    heights_all_without_outliers = [heights_all_without_outliers; [heights_obj_without_outliers, ones(size(heights_obj_without_outliers, 1), 1) * ids(obj)]];
    % Calculate each detection object's arithmetic mean
    heights_array(2, obj) = mean(heights_obj_without_outliers);
end


%% Test model performance
if testing == 1
    %% Get dimensions of all traffic objects
    % path_DAT = strcat(mainDir, '\Data Application\dat\Ground_Truth_Highway_two_lane_traffic.dat');
    % path_DAT = strcat(mainDir, '\Data Application\dat\Larger_scenario_road_signs.dat');
    specs_DAT = dir(strcat(mainDir, '\Data Application\dat\', '*.dat')); 
    path_DAT = strcat(specs_DAT.folder, '\', specs_DAT.name);
    dimensions = read_DAT_file(path_DAT);
    
    
    %% Get widths and heights
    dimensions = dimensions(:, (3:4));
    
    
    %% Add ground truth to widths_array and heights_array
    index = 1;
    for object = widths_array(1, :)
        % Get respective radar object
        radarObj = DetectObjects(3, object);
        % Get its ground truth dimensions
        ground_truth_width = dimensions(radarObj, 1);
        ground_truth_height = dimensions(radarObj, 2);
        % Write them in the right place
        widths_array(3, index) = ground_truth_width;
        heights_array(3, index) = ground_truth_height;
        index = index + 1;
    end
    
    
    %% Add ground truth to valid_front//rear
    % Note: valid_front//rear was collected BEFORE outlier treatment.
    if exist('valid_front', 'var')
        valid_front(:, 4) = dimensions(valid_front(:,1), 1);
        valid_front(:, 5) = dimensions(valid_front(:,1), 2);
    end
    if exist('valid_rear', 'var')
        valid_rear(:, 4) = dimensions(valid_rear(:,1), 1);
        valid_rear(:, 5) = dimensions(valid_rear(:,1), 2);
    end
    
    
    %% Get some metrics for performance evaluation
    % Note: This calculation is based on data BEFORE outlier treatment.
    
    % Front
    if exist('valid_front', 'var') && ~isempty(valid_front)
        metrics.wholeData.n_front = size(valid_front, 1);
        % Save sums of absolute differences
        metrics.wholeData.soa.front_width = sum(abs(valid_front(:, 2) - valid_front(:, 4)));
        metrics.wholeData.soa.front_height = sum(abs(valid_front(:, 3) - valid_front(:, 5)));
        % Calculate and save MAE
        metrics.wholeData.mae.front_width = metrics.wholeData.soa.front_width / metrics.wholeData.n_front;
        metrics.wholeData.mae.front_height = metrics.wholeData.soa.front_height / metrics.wholeData.n_front;
        % Save sums of squared differences
        metrics.wholeData.sos.front_width = sum((valid_front(:, 2) - valid_front(:, 4)).^2);
        metrics.wholeData.sos.front_height = sum((valid_front(:, 3) - valid_front(:, 5)).^2);
        % Calculate and save MSE
        metrics.wholeData.mse.front_width = metrics.wholeData.sos.front_width / metrics.wholeData.n_front;
        metrics.wholeData.mse.front_height = metrics.wholeData.sos.front_height / metrics.wholeData.n_front;
        % Calculate and save RMSE
        metrics.wholeData.rmse.front_width = sqrt(metrics.wholeData.mse.front_width);
        metrics.wholeData.rmse.front_height = sqrt(metrics.wholeData.mse.front_height);
        % Calculate and save sums of differences (not absolute)
        metrics.wholeData.sod.front_width = sum(valid_front(:, 2) - valid_front(:, 4));
        metrics.wholeData.sod.front_height = sum(valid_front(:, 3) - valid_front(:, 5));
    end
    
    % Rear
    if exist('valid_rear', 'var') && ~isempty(valid_rear)
        metrics.wholeData.n_rear = size(valid_rear, 1);
        % Save sums of absolute differences
        metrics.wholeData.soa.rear_width = sum(abs(valid_rear(:, 2) - valid_rear(:, 4)));
        metrics.wholeData.soa.rear_height = sum(abs(valid_rear(:, 3) - valid_rear(:, 5)));
        % Calculate and save MAE
        metrics.wholeData.mae.rear_width = metrics.wholeData.soa.rear_width / metrics.wholeData.n_rear;
        metrics.wholeData.mae.rear_height = metrics.wholeData.soa.rear_height / metrics.wholeData.n_rear;
        % Save sums of squared differences
        metrics.wholeData.sos.rear_width = sum((valid_rear(:, 2) - valid_rear(:, 4)).^2);
        metrics.wholeData.sos.rear_height = sum((valid_rear(:, 3) - valid_rear(:, 5)).^2);
        % Calculate and save MSE
        metrics.wholeData.mse.rear_width = metrics.wholeData.sos.rear_width / metrics.wholeData.n_rear;
        metrics.wholeData.mse.rear_height = metrics.wholeData.sos.rear_height / metrics.wholeData.n_rear;
        % Calculate and save RMSE
        metrics.wholeData.rmse.rear_width = sqrt(metrics.wholeData.mse.rear_width);
        metrics.wholeData.rmse.rear_height = sqrt(metrics.wholeData.mse.rear_height);
        % Save sums of differences (not absolute)
        metrics.wholeData.sod.rear_width = sum(valid_rear(:, 2) - valid_rear(:, 4));
        metrics.wholeData.sod.rear_height = sum(valid_rear(:, 3) - valid_rear(:, 5));
    end
    
    
    % Overall MAE for Width
    if isfield(metrics.wholeData.mae, 'front_width') && isfield(metrics.wholeData, 'n_front') && isfield(metrics.wholeData.mae, 'rear_width') && isfield(metrics.wholeData, 'n_rear')
        metrics.wholeData.mae.width = (metrics.wholeData.mae.front_width * metrics.wholeData.n_front ...
            + metrics.wholeData.mae.rear_width * metrics.wholeData.n_rear) ...
            / (metrics.wholeData.n_front + metrics.wholeData.n_rear);
        metrics.wholeData.n = metrics.wholeData.n_front + metrics.wholeData.n_rear;
    elseif ~isfield(metrics.wholeData.mae, 'front_width') && ~isfield(metrics.wholeData, 'n_front') && isfield(metrics.wholeData.mae, 'rear_width') && isfield(metrics.wholeData, 'n_rear')
        metrics.wholeData.mae.width = metrics.wholeData.mae.rear_width;
    elseif isfield(metrics.wholeData.mae, 'front_width') && isfield(metrics.wholeData, 'n_front') && ~isfield(metrics.wholeData.mae, 'rear_width') && ~isfield(metrics.wholeData, 'n_rear')
        metrics.wholeData.mae.width = metrics.wholeData.mae.front_width;
    end
    
    % Overall MAE for Height
    if isfield(metrics.wholeData.mae, 'front_height') && isfield(metrics.wholeData, 'n_front') && isfield(metrics.wholeData.mae, 'rear_height') && isfield(metrics.wholeData, 'n_rear')
        metrics.wholeData.mae.height = (metrics.wholeData.mae.front_height * metrics.wholeData.n_front ...
            + metrics.wholeData.mae.rear_height * metrics.wholeData.n_rear) ...
            / (metrics.wholeData.n_front + metrics.wholeData.n_rear);
        metrics.wholeData.n = metrics.wholeData.n_front + metrics.wholeData.n_rear;
    elseif ~isfield(metrics.wholeData.mae, 'front_height') && ~isfield(metrics.wholeData, 'n_front') && isfield(metrics.wholeData.mae, 'rear_height') && isfield(metrics.wholeData, 'n_rear')
        metrics.wholeData.mae.height = metrics.wholeData.mae.rear_height;
    elseif isfield(metrics.wholeData.mae, 'front_height') && isfield(metrics.wholeData, 'n_front') && ~isfield(metrics.wholeData.mae, 'rear_height') && ~isfield(metrics.wholeData, 'n_rear')
        metrics.wholeData.mae.height = metrics.wholeData.mae.front_height;
    end
    
    
    %% Calculate mean absolute error (MAE) and root mean square error (RMSE) for the end product (widths_array and heigths_array)
    % Note: This calculation is based on data AFTER outlier treatment.
    if ~isempty(widths_array)
        metrics.endProduct.mae.width = mean(abs(widths_array(2, :) - widths_array(3, :)));
        metrics.endProduct.rmse.width = sqrt(mean((widths_array(2, :) - widths_array(3, :)).^2));
    end
    if ~isempty(heights_array)
        metrics.endProduct.mae.height = mean(abs(heights_array(2, :) - heights_array(3, :)));
        metrics.endProduct.rmse.height = sqrt(mean((heights_array(2, :) - heights_array(3, :)).^2));
    end
    
    
    % Print to command window where to find these numbers
    disp(' ');
    disp('Quality assessment has been carried out. The resulting numbers are stored in variable "metrics".');
end


%% Add dimensions to Tensor
%% Load tensor
load(strcat(mainDir, '\Data Application\tensors\tensors.mat'));
tensors = struct;
tensors.CM = TestRun.first_sim.Tensor_CM;
tensors.model = TestRun.first_sim.Tensor_model;
clear('TestRun');


%% Add dimensions in last rows of tensor
%% Traffic objects
% Begin with first id that has width and height
index = 1;
% Loop over detected objects
for detecObj = (1:count)
    id = ids(index);
    if ismember(detecObj, ids)
        % If width and height were determined write them in tensor
        % CM
        tensors.CM.TObj(detecObj).data(14, :) = widths_array(2, index);
        tensors.CM.TObj(detecObj).data(15, :) = heights_array(2, index);
        % model  
        tensors.model.Tobj(detecObj).data(14, :) = widths_array(2, index);
        tensors.model.Tobj(detecObj).data(15, :) = heights_array(2, index);
        index = index + 1;
    else
        % If no width and height were determined write 9999
        % CM
        tensors.CM.TObj(detecObj).data(14, :) = -9999;
        tensors.CM.TObj(detecObj).data(15, :) = -9999;
        % model
        tensors.model.Tobj(detecObj).data(14, :) = -9999;
        tensors.model.Tobj(detecObj).data(15, :) = -9999;
    end
end


%% Ego vehicle
% CM
tensors.CM.Ego(10, :) = ego_width;
tensors.CM.Ego(11, :) = ego_height;
% model
tensors.model.Ego(14, :) = ego_width;
tensors.model.Ego(15, :) = ego_height;


%% For model tensor: Delete value where column conatains -9999
%% Traffic objects
for i = (1:size(tensors.model.Tobj, 2))
    for j = (1:size(tensors.model.Tobj(i).data, 2))
        if tensors.model.Tobj(i).data(13, j) == -9999
            tensors.model.Tobj(i).data((14:15), j) = -9999;
        end
    end
end


%% Ego vehicle
for j = (1:size(tensors.model.Ego, 2))
    if tensors.model.Ego(2, j) == -9999
        tensors.model.Ego((14:15), j) = -9999;
    end
end

if saveTensor
    %% Save tensors on hard drive
    save(strcat(mainDir, '\Results Application\tensors'), 'tensors');
end


%% Print to console where to find resulting tensor
disp('Dimension estimation complete. Resulting tensors are stored in variable "tensors".');
