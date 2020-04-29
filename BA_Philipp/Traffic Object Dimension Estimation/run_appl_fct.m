%% Grid search for good values for limit_front and limit_rear
%{
This script's purpose is to find good values for the distances in which
bounding boxes are to be ignored by Ego.
The reason for this is that when a car is very close to Ego, most times Ego
is overtaking it or is being overtaken which means that Ego sees the car
from a diagonal perspective.
This leads to bounding box widths being too large.

Bounding boxes have to be loaded by double clicking first.
They are located in .../Data Application/bboxes

After executing array 'result' contains the following:
1st column: limit for front [m]
2nd column: limit for rear [m]
3rd column: MSE front // rear width
4th column: MSE front // rear height
5th column: number of images left after discarding (front // rear)
(
6th column: chosen tolerance for outlier treatment
7th column: MAE width as end result (after allocation to detection object,
outlier treatment, taking average)
8th column: MAE height as end result (after allocation to detection object,
outlier treatment, taking average)
)
%}

%% User input

% Decide wether to view front camera or rear camera results
front = 1;

% Define search interval for front camera
i_lo = 0; % [m]
i_hi = 30; % [m]

% Define search interval for rear camera
j_lo = 0; % [m]
j_hi = 0; % [m]

% Define search stride
stride = 1; % [m // std. dev.]

% Additionally a value for the tolerance used in outlier treatment can be 
% passed. In outlier treatment, any point outside
% median +- tolerance * std. dev
% of respective detection object are discarded.
% Set toleranceMode to 1 if interested in these results, else to 0.
toleranceMode = 0;
% Define tolerance search interval
k_lo = 4; % [std. dev.]
k_hi = 4; % [std. dev.]


%% Check if bboxes are loaded
if ~exist('bboxes_front', 'var') || ~exist('bboxes_rear', 'var')
        disp('You need to load bboxes_front and bboxes_rear into workspace to run this script.');
        disp('bboxes_front and bboxes_rear are located in directory ".../Data Application/bboxes".');
        return
end


%% Computation

% Save console output in file 'ConsoleOutput'
diary ConsoleOutput;

i_range = (i_lo:stride:i_hi);
j_range = (j_lo:stride:j_hi);
k_range = (k_lo:stride:k_hi);
i_num = size(i_range, 2);
j_num = size(j_range, 2);
k_num = size(k_range, 2);


% Preallocate result array
result = zeros(i_num * j_num * k_num, 5);

% If we look at tolerance / outlier treatment as well, make result array
% larger
if toleranceMode
    result = zeros(i_num * j_num * k_num, 8);
end

% Run main_appl_model_3_4_as_fct for defined values and save metrics in
% 'result'.
index = 0;
for i = i_range
    for j = j_range
        for k = k_range
            disp(strcat("limit front: ", num2str(i), ", limit rear: ", num2str(j)));
            if toleranceMode
                disp(strcat("std. dev. multiplier for outlier treatment: ", num2str(k)));  
            end
            index = index + 1;
            result(index, 1) = i;
            result(index, 2) = j;
            [metrics] = appl_model_3_4_as_function(k, i, j, bboxes_front, bboxes_rear);
            if front
                result(index, 3) = metrics.wholeData.sos.front_width / metrics.wholeData.n_front;
                result(index, 4) = metrics.wholeData.sos.front_height / metrics.wholeData.n_front;
                result(index, 5) = metrics.wholeData.n_front;
            else
                result(index, 3) = metrics.wholeData.sos.rear_width / metrics.wholeData.n_rear;
                result(index, 4) = metrics.wholeData.sos.rear_height / metrics.wholeData.n_rear;
                result(index, 5) = metrics.wholeData.n_rear;
            end
            if 1
                result(index, 6) = k;
                result(index, 7) = metrics.endProduct.mae.width;
                result(index, 8) = metrics.endProduct.mae.height;
            end
        end
    end
end

diary off;


%% Plot MSE
figure;
hold on;
if front
    plot(result(:,1), result(:,3), '-o', 'MarkerSize', 5);
    plot(result(:,1), result(:,4), '-o', 'MarkerSize', 5);
    plot(result(:,1), result(:,7), '-o', 'MarkerSize', 5);
    plot(result(:,1), result(:,8), '-o', 'MarkerSize', 5);
    legend('MSE front width', 'MSE front height', 'end result MAE width', 'end result MAE height');
else
    plot(result(:,2), result(:,3), '-o', 'MarkerSize', 5);
    plot(result(:,2), result(:,4), '-o', 'MarkerSize', 5);
    plot(result(:,2), result(:,7), '-o', 'MarkerSize', 5);
    plot(result(:,2), result(:,8), '-o', 'MarkerSize', 5);
    legend('MSE rear width', 'MSE rear height', 'end result MAE width', 'end result MAE height');
end
hold off;

%{ 
Result: 
From looking at the plots it can be said that for this dataset setting a
limit has no considerable beneficial impact.
%}


%% Plot end result MAE
if toleranceMode
    figure;
    hold on;
    plot(result(:,6), result(:,7), '-o', 'MarkerSize', 5);
    plot(result(:,6), result(:,8), '-o', 'MarkerSize', 5);
    legend('MAE end result width', 'MAE end result height');
    hold off;
end

%{
Result:
Looking at plots for tolerance values in [0, 20] (stride 0.5) it seems like
outlier treatment has no considerable positive impact either for this data 
set.
%}