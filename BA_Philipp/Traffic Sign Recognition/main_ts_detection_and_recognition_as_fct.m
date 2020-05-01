function [sumDev_time, sumDev_sRoad] = main_ts_detection_and_recognition_as_fct(time_and_prediction, delay)


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
    % This function is equivalent to "main_ts_detection_and_recognition" which
    % is a script for detecting and recognising traffic signs in a series
    % of images.
    %
    % This function can be called from "run_main_ts_detection_and_recognition_as_fct"
    %
    % CNN "RecognitionNet" and ACF detector "ACFDetector" have to 
    % be present in the same folder as this function
    %
    % The purpose of running this function is to find a good value for "delay"

    
    %%%%%%%%%%%%%%%%
    %% Input by user
    %%%%%%%%%%%%%%%%


    %% Do you want to detect and recognise traffic signs in given images? Then set detectAndRecognise = 1
    % Detection and recognition takes a lot of time, so if you just want to play
    % around with the post processing part, set detectAndRecognise = 0
    % With detectAndRecognise = 0 "tsdr_time_and_prediction" which contains 
    % traffic signs from an earlier run will be imported automatically
    detectAndRecognise = 0;


    %% Do you want to test the model?
    % Ground truth data must be available for this
    % This information is created by running the script
    % "ts_detection_and_recognition_build_ground_truth_array" in the folder
    % "006 Create ground truth table for whole application"
    testing = 1;


    %% Is additional ground truth information available that defines which traffic signs are in sight in the given images?
    % If yes: Set classification_gt_available = 1
    % Else: Set classification_gt_available = 0
    %
    % To this point, this information has been created manually and stored in excel sheet
    % "ground_truth.xlsx" which needs to be located in folder "...\007 Traffic Sign Recognition\001 Data\ground truth"
    %
    % To this point this information has been created only for Scenario 1
    % Future work: Automate creation of this information
    classification_gt_available = 0;


    %% Do you want to save (and potentially overwrite) tensors on hard drive after running this script? Save: 1, Don't save: 0
    saveTensor = 0;


    %% Time of first image and length of time steps between images
    t_start = 0.0;
    t_step = 0.2;


    %% CarMaker: Application -> OutputQuantities -> Data Rates -> Frequncy
    freq = 50;


    %% Define a threshold for classification. 
    % Any classificatins with a lower corresponding probability will be
    % discarded
    threshold = 0.05;


    %% Define thickness of additional pixels added around detected bounding boxes
    % We add a frame of thickness (enlargeFactor * height) (for height) and
    % (enlargeFactor * width) (for width) to all bounding boxes.
    % We round up to the nearest integer.
    % These enlarged bounding boxes are the regions of interest that we use for 
    % classification
    enlargeFactor = 0.2;


    %% Define location of Road Sensor used for determining Ego's position
    % In CarMaker these values are set in: Parameters -> Car -> Sensors -> Road
    road_x = 3.4;
    road_y = 0;
    road_z = 0.29;


    %% Define location of camera that collected the images used for recognition
    cam_x = 2.7;
    cam_y = 0;
    cam_z = 1.35;


    %% Define a delay for traffic sign passing time (a good value was found by repeatedly running this script as a function via "run_main_ts_detection_and_recognition_as_fct")
    % Time of passing traffic signs is approximated by using the time that is (delay) after time where traffic sign was last seen
    % The described approximation was performed on the basis of scenario
    % „Ground_Truth_Highway_two_lane_traffic_road_signs.dat“ with road file „Simple_Highway_circle_road_signs.rd5“
    % delay = 0.496;


    %% Define initial values for variables (optional)
    %{
    Example: We want to define that at the start of the route the following is
    effective:
    - Speed limit 30
    - No overtaking (trucks)
    Then the initialisation matrix needs to be defined as follows: 
    initial = [0, 0; 1, 10];
    where 0, 0 both stand for type = "traffic sign" and 1, 10 stand for "speed
    limit 30" and "no overtaking (trucks)" respectively
    %}
    initial = [0, 0; 1, 10];


    %%%%%%%%%%%%%%%%%%%%%%%
    %% End of input by user
    %%%%%%%%%%%%%%%%%%%%%%%


    %% Check if initial is in workspace
    if ~exist('initial', 'var')
       disp('Error: "initial" has not been defined. Please set inital = [] if no initial values are needed');
       return
    end


    %% Change to folder of this script
    [thisDir, ~, ~] = fileparts(mfilename('fullpath'));
    cd(thisDir);


    %% Define traffic sign mapping
    traffic_signs = ["0 = speed limit 20 (prohibitory)"; ...
        "1 = speed limit 30"; "2 = speed limit 50";...
        "3 = speed limit 60"; "4 = speed limit 70";...
        "5 = speed limit 80"; "6 = restriction ends 80";...
        "7 = speed limit 100"; "8 = speed limit 120";...
        "9 = no overtaking"; "10 = no overtaking (trucks)";...
        "11 = priority at next intersection"; "12 = priority road";...
        "13 = give way"; "14 = stop";...
        "15 = no traffic both ways"; "16 = no trucks";...
        "17 = no entry"; "18 = danger";...
        "19 = bend left"; "20 = bend right";...
        "21 = bend"; "22 = uneven road";...
        "23 = slippery road"; "24 = road narrows";...
        "25 = construction"; "26 = traffic signal";...
        "27 = pedestrian crossing"; "28 = school crossing";...
        "29 = cycles crossing"; "30 = snow";...
        "31 = animals"; "32 = restriction ends (other)";...
        "33 = go right"; "34 = go left";...
        "35 = go straight"; "36 = go right or straight";...
        "37 = go left or straight"; "38 = keep right";...
        "39 = keep left"; "40 = roundabout";...
        "41 = restriction ends (overtaking)"; "42 = restriction ends (overtaking (trucks))"];


    %% Get Number of images per camera; For every point in time there is a front and  a rear image
    n_photos = size(dir([strcat(thisDir, '\001 Data\CM images for detection and classification\5 fps') '/*.jpg']), 1);


    %% If user set detectAndRecognise = 0, load "tsdr_time_and_prediction" which contains traffic signs from an earlier run
    if detectAndRecognise == 0
       load('tsdr_time_and_prediction');
    end


    if detectAndRecognise

        %% Load trained ACF detector for traffic sign detection
        load('ACFDetector');


        %% Load trained CNN for traffic sign recognition
        load('RecognitionNet');


        %% Go to image location
        % cd(strcat(thisDir, '\CM images to classify\1 fps'));
        cd(strcat(thisDir, '\001 Data\CM images for detection and classification\5 fps'));


        %% Loop over images
        time_and_prediction = [];
        index_prediction_probability = [];
        index_where_bb = [];
        disp(strcat('Detecting and recognising traffic signs from', 32, num2str(n_photos), ' images:'));
        for i = (0:n_photos - 1)
        % for i = (2400:n_photos - 1) 
            % Print progess
            fprintf(strcat(num2str(i), 32));
            % Time
            t = t_start + (i * t_step);
            % Read image
            filename = strcat('image_', num2str(i), '.jpg');
            image = imread(filename);
            % Get image width and height
            im_width = size(image, 2);
            im_height = size(image, 1);


            %% Traffic sign detection
            bboxes = detect(ts_detection_acfDetector, image);
            bboxes_enlarged = [];
            if 0
                % Insert found bounding boxes into images and visualise
                image_copy = insertShape(image, 'rectangle', bboxes, 'LineWidth', 5);
                imshow(image_copy);
            end
            % Get regions of interest for all bounding boxes detected in this
            % iteration and crop image accordingly
            % We make ROI a bit larger than the detected bounding boxes
            inpImg = zeros(48, 48, 3, size(bboxes, 1), 'uint8');
            large_enough_count = 0;
            if ~isempty(bboxes)
                % Save all indices of images for which at least one bounding 
                % box was created
                index_where_bb = [index_where_bb; i];
                for bb = (1:size(bboxes, 1))
                    % Make a copy of image
                    im = image;
                    width = bboxes(bb, 3);
                    height = bboxes(bb, 4);
                    % Skip this bounding box if either width or height is
                    % smaller than 19 pixels (recognition is quite inaccurate when
                    % object is still far away)
                    if width >= 19 && height >= 19
                        large_enough_count = large_enough_count + 1;
                        % Add some pixels to bounding box, but make sure numbers
                        % don't exceed image limits
                        zmin = max(bboxes(bb, 2) - ceil(enlargeFactor * height), 1);
                        zmax = min(bboxes(bb, 2) + bboxes(bb, 4) + ceil(enlargeFactor * height), im_height);
                        height_enlarged = zmax - zmin;
                        ymin = max(bboxes(bb, 1) - ceil(enlargeFactor * width), 1);
                        ymax = min(bboxes(bb, 1) + bboxes(bb, 3) + ceil(enlargeFactor * width), im_width);
                        width_enlarged = ymax - ymin;
                        % Save a cropped and resized version of image
                        inpImg(:, :, :, large_enough_count) = imresize(im(zmin:zmax, ymin:ymax, :),[48,48]);
                        % Save enlarged bounding box
                        bboxes_enlarged = [bboxes_enlarged; ymin, zmin, width_enlarged, height_enlarged];
                    end
                end
            end


            %% Traffic sign recognition
            % Loop over cropped images from this image
            if ~isempty(inpImg)

                % For visualisation
                class_and_prob = zeros(large_enough_count, 2);

                for img = (1:large_enough_count)
                    % Save cropped images on hard drive
                    if 1
                        location = strcat(thisDir, '\008 Cropped images being classified (for checking purposes only)\');
                        imwrite(inpImg(:, :, :, img), strcat(location, num2str(i), '_', num2str(img), '.jpg'), 'jpg');
                    end



                    % Use CNN to predict probabilities of traffic sign IDs
                    output = convnet.predict(inpImg(:, :, :, img));
                    % Get the most probable one
                    [maxim, idx] = max(output);
                    % Only process classifications that have a high enough probability 
                    if maxim >= threshold
                        % Decrease index by one because convnet's way of counting is 1, 2, 3, ... 
                        % and our way of counting is 0, 1, 2, ...
                        idx = idx - 1;
                        % Write prediction along with time stamp
                        t_and_pred = [t, idx]; 
                        % Add the pair to the others
                        time_and_prediction = [time_and_prediction; t_and_pred];   
                        % Write prediction along with index
                        idx_pred_prob = [i, idx, maxim];
                        % Add the pair to the others
                        index_prediction_probability = [index_prediction_probability; idx_pred_prob];
                        % Add pair to the visualisation instance
                        class_and_prob(img, :) = [maxim, idx];
                        % If view_cropped = 1: Add prediction to image and view it
                        view_cropped = 0;
                        if view_cropped
                            % View cropped image that has just been classified
                            imshow(inpImg(:, :, :, img));
                            hold on;
                            % Add classified ID
                            title(num2str(idx));
                            hold off;
                        end
                    end
                    % Place breakpoint in at the following line to view cropped
                    % images and their prediction one by one
                end
            end

            if 1
                % Visualise image with bounding boxes and classifications
                image_copy = insertShape(image, 'rectangle', bboxes, 'LineWidth', 4, 'Color', 'yellow');
                image_copy = insertShape(image_copy, 'rectangle', bboxes_enlarged, 'LineWidth', 4, 'Color', 'blue');
                for bb = (1:large_enough_count)
                    % Get probability in percent
                    p = round(class_and_prob(bb, 1), 4) * 100;
                    % Define location of prediction and probability in image
                    pos_class = [0, (2 * bb - 2) * 90];
                    pos_p = [0, (2 * bb - 2) * 90 + 90];
                    % Get prediction
                    class = class_and_prob(bb, 2);
                    % Define color representation of probability for
                    % visualisation
                    if p < 0.3333
                        color = 'red';
                    elseif p < 0.6666
                        color = 'yellow';
                    else
                        color = 'green';
                    end
                    % Create text
                    text1 = convertCharsToStrings(strcat('Classified as:', 32, num2str(traffic_signs(class + 1), 1)));
                    if p < threshold
                        text2 = convertCharsToStrings(strcat('Confidence:', 32, num2str(p), '%', 32, '(discarded)'));
                    else
                        text2 = convertCharsToStrings(strcat('Confidence:', 32, num2str(p), '%'));
                    end
                    % Insert everything into image
                    image_copy = insertText(image_copy, [pos_class; pos_p], ...
                        [text1; text2], 'FontSize', 40, ...
                        'BoxColor', color, 'BoxOpacity', 0.4, ...
                        'TextColor', 'white');
                end
                % Show image
                imshow(image_copy);
                % Add image's index as title
                title(num2str(i));
            end
        % Set breakpoint in the following line to look at each visualisation
        end
        disp('');


        %% Change to directory of this script and save time_and_prediction, index_prediction_probability and index_where_bb
        cd(thisDir);
        save('tsdr_time_and_prediction', 'time_and_prediction');
        save('tsdr_index_prediction_probability','index_prediction_probability');
        save('tsdr_index_where_bb', 'index_where_bb');
    end


    %% Identify points in time where Ego passed traffic signs

    %% Create a matrix showing which traffic sign was recognised when
    % Discard rows with same content
    tap = unique(time_and_prediction,'rows');
    % Make a matrix with rows: all times where an image was taken, columns: all
    % possible traffic signs
    times = transpose(t_start:t_step:(n_photos - 1) * t_step);
    seen = zeros(size(times, 1), 43);
    % Fill it
    for i = (1:size(tap, 1))
        time = tap(i, 1);
        index_in_seen = int64((time/t_step) + 1);
        trafficSign = tap(i, 2);
        seen(index_in_seen, trafficSign + 1) = 1;
    end


    %% Get last points in time where traffic sign is still in sight, making quite sure it's not a measurement error
    % Rule:
    % 1st condition: Two images are in succesion; in first one the traffic sign
    % is seen, in the second one it isn't.
    % 2nd condition: Out of the four images before those two images, in at 
    % least 3 images the traffic sign was seen AND out of the four images after
    % those two images, in at least 3 images the traffic sign was not seen 
    occurence = [];
    for i = (1:size(seen, 1))
       for ts = (1:size(seen, 2))
           % Check first condition and check if not too close to beginning and end our time span
           if seen(i, ts) == 1 && seen(i+1, ts) == 0 && i >= 5 && i <= size(seen, 1) - 5
               % Test 2nd condition
               if sum(seen((i-4:i), ts)) >= 4 && sum(seen((i+1:i+5), ts)) <= 1
                       % save the time when last seen and the traffic sign's ID
                       occurence = [occurence; [((i - 1) * t_step), ts - 1]];
               end
           end
       end
    end


    UseThisRule = 1;
    if UseThisRule
        %% Mark columns where prediction is different in next row or where next row is at least 1 second away
        % Add an extra column
        occurence = [occurence, zeros(size(occurence, 1), 1)];
        % Put a 1 where prediction is different in next row or where at least 
        % 1 second has passed between this row and next row. And: Put a 1 in 
        % the last row no matter what
        for i = (1:size(occurence, 1))
            if i <= size(occurence, 1) - 1
                if occurence(i, 2) ~= occurence(i + 1, 2) || (occurence(i + 1, 1) - occurence(i,1)) >= 1
                    occurence(i, 3) = 1; 
                end
            else
                % Last row gets a 1 no matter what
                occurence(i, 3) = 1;
            end
        end


        %% Reduce matrix to only those rows
        lastOccurence = occurence((occurence(:, 3) == 1), (1:2));
    else
        lastOccurence = occurence;
    end


    %% Approximate time of passing traffic sign by using the time that is (delay) after time where traffic sign was last seen
    % Also add two lines: One for s (= distance travelled by Ego) and one for
    % variable type
    % Note that type = 0 = "traffic sign"
    passingBy = [zeros(1, size(lastOccurence, 1)); transpose(lastOccurence(:, 1)); zeros(1, size(lastOccurence, 1)); transpose(lastOccurence(:, 2))];
    passingBy(2, :) = passingBy(2, :) + delay;


    %% Load CM data
    load(strcat(thisDir, '\001 Data\erg, radar\data'));


    %% Get distance travelled by Ego car for whole time span
    sRoad = data.Car_Road_sRoad.data;
    % From this calculate camera positions for whole time span
    sRoad_cam = sRoad - (road_x - cam_x);
    % And get the corresponding points in time
    times = (0:(1 / freq):((size(sRoad_cam, 2) - 1) / freq));


    %% Interpolate sRoad_cam data at the relevant spots and add sRoad_cam value to passingBy
    k = 1;
    for i = (1:size(passingBy, 2))
        time = passingBy(2, i);
        % Search point in time in times
        while time > times(1, k)
            k = k + 1;
        end
        if time == times(1, k)
            less = 0; 
        else %% meaning: time > times(1, k)
            % Get percentage of step to deduct from enty k
            less = (time - times(1, k)) / (times(1, k) - times(1, (k-1)));
        end
        passingBy(1, i) = sRoad_cam(1, k) - less * (sRoad_cam(1, k) - sRoad_cam(1, (k-1)));
    end


    %% Model validation
    if testing
        %% Define a tolerance for traffic sign position
        tol = 15; % [m]


        %% Load ground truth table and add one row 
        load(strcat(thisDir, '\001 Data\ground truth\tsdr_ground_truth'));
        gt = [gt; zeros(1, size(gt,2)); zeros(1, size(gt,2)); zeros(1, size(gt,2))];


        %% Determine if traffic signs were identified close to where they should have been identified and get sRoad and time deviations for successful identifications
        for entry = (1:size(gt, 2))
            % Get ID of this traffic sign
            ID = gt(4, entry);
            % Get entries where ID matches the ID we are currently looking at
            entries_this_ID = passingBy(4,:) == ID;
            entries_this_ID = passingBy(:, entries_this_ID);
            % Determine if respective traffic sign was identified in an
            % interval of ground truth position +- tol meters
            identified = 0;
            devs_sRoad = zeros(1, size(entries_this_ID, 2));
            devs_time = zeros(1, size(entries_this_ID, 2));
            for i = (1:size(entries_this_ID, 2))
                if abs(gt(1, entry) - entries_this_ID(1, i)) <= tol
                   identified = 1; 
                end
                devs_sRoad(i) = gt(1, entry) - entries_this_ID(1, i);
                devs_time(i) = gt(2, entry) - entries_this_ID(2, i);
            end
            % Set identified accordingly
            gt(5, entry) = identified;
            % Calculate deviation in sRoad and time
            if ~isempty(devs_sRoad)
                [~, nearest_sRoad] = min(abs(devs_sRoad));
                gt(6, entry) = devs_sRoad(nearest_sRoad);
                [~, nearest_time] = min(abs(devs_time));
                gt(7, entry) = devs_time(nearest_time);
            end
        end


        %% Calculate accuracy for the whole application
        acc_whole_application = sum(gt(5, :)) / size(gt, 2);


        %% Calculate sum of deviations for sRoad and time for those where recognition was successful
        sumDev_sRoad = sum(gt(6, gt(5, :) == 1));
        sumDev_time = sum(gt(7, gt(5, :) == 1)); 


        %% Calculate MAE for sRoad and time for those where recognition was successful
        MAE_sRoad = sum(abs(gt(6, gt(5, :) == 1))) / size(gt(6, gt(5, :) == 1), 2);
        MAE_time = sum(abs(gt(7, gt(5, :) == 1))) / size(gt(7, gt(5, :) == 1), 2);


        if classification_gt_available
            %% Evaluatin of classification performance only
            %% Load ground truth for all images
            gt_all_images = readmatrix(strcat(thisDir, '\001 Data\ground truth\ground_truth_all_classifications.xlsx'));


            %% Add information to index_prediction_probability
            % Check if index_prediction_probability is in workspace; if not, load a
            % previously saved version of it
            if ~exist('index_prediction_probability', 'var')
                load('tsdr_index_prediction_probability');
            end    
            % Add another column
            index_prediction_probability(:, 4) = zeros(size(index_prediction_probability, 1), 1);
            % Get true traffic sign IDs and add them to index_prediction_probability
            for i = (1:size(index_prediction_probability, 1))
                index = index_prediction_probability(i, 1);
                trueID = gt_all_images(index + 1, 2);
                index_prediction_probability(i, 4) = trueID;
            end


            %% Compute confusion matrix and accuracy
            confusionMatrix = confusionmat(index_prediction_probability(:, 4), index_prediction_probability(:, 2));
            acc_classification_only = sum(diag(confusionMatrix)) / sum(sum(confusionMatrix));


            %% Compute classification accuracies for each traffic sign individually
            % Get unique traffic sign IDs of the ones that were detected
            trafficSigns_detected = unique(index_prediction_probability(:, 4));
            % Loop over traffic signs and save ID and corresponding accuracies
            accs_individual_trafficSigns = [];
            for i = (1:size(trafficSigns_detected, 1))
                thisID = trafficSigns_detected(i);
                classifications_this_ID = index_prediction_probability(index_prediction_probability(:, 4) == thisID, :);
                cm_this_ID = confusionmat(classifications_this_ID(:, 4), classifications_this_ID(:, 2));
                acc_this_ID = sum(diag(cm_this_ID)) / sum(sum(cm_this_ID));
                % id_acc = [i, acc_this_ID];
                accs_individual_trafficSigns = [accs_individual_trafficSigns; thisID, acc_this_ID];
            end
            bar(accs_individual_trafficSigns(1:end-1, 1), accs_individual_trafficSigns(1:end-1, 2));
        end


        %% Work in progress: Compute an approximate success rate for bounding box creation
        % Check if index_where_bb is in workspace; if not, load a previously
        % saved version of it
        if ~exist('index_where_bb', 'var')
            load('tsdr_index_where_bb');
        end
    end


    %% Add initial information provided by user
    result = passingBy;
    initial = [zeros(2, size(initial, 2)); initial];
    result = [initial, result];


    %% Save result on hard drive
    save('tsdr_result', 'result');


    %% Integration into model

    %% Load tensors
    path_tensor = strcat(thisDir, '/001 Data/tensors/tensors.mat');
    load(path_tensor);
    % tensors = struct;
    % tensors.CM = TestRun.first_sim.Tensor_CM;
    % tensors.model = TestRun.first_sim.Tensor_model;
    % clear('TestRun');


    %% Add results to tensor
    tensors.CM.sRoad = result;
    tensors.model.sRoad = result;

    if saveTensor
        %% Save tensors on hard drive
        save(strcat(thisDir, '\007 Results\tensors'), 'tensors');
    end
end

