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
% This script is used to train the models, meaning to find good model
% parameters f // f_width, f_height
%
% Model 2 (2 parameters) and models 3 // 4 (they are equivalent; 1
% parameter) have been used for my thesis.
%
% The rest have more of an experimental purpose.
%
% The six models:
%
% 1.
% width_real = width_image * dist_x_from_camera * c_width
% height_real = height_image * dist_x_from_camera * c_height
%
% 2.
% width_image = width_real / dist_x_from_camera * c_width
% height_image = height_real / dist_x_from_camera * c_height
%
% 3.
% width_image = width_real / dist_x_from_camera * c
% height_image = height_real / dist_x_from_camera * c
%
% 4.
% width//height_image = width//height_real / dist_x_from_camera * c
%
% 5.
% width//height_image = a + width//height_real / dist_x_from_camera * c
% y := width//height_image
% x := width//height_real / dist_x_from_camera
% Parameter estimation:
% c_hat = cov(x, y) / var(x) 
%
% 6.
% width//height_image = width//height_real / dist_x_from_camera * c
% y := width//height_image
% x := width//height_real / dist_x_from_camera
% Parameter estimation:
% c_hat = sum(x, y) / sum(x^2) 
%
%
% To use this script as intended, one model has to be activated (if 1 ... end) 
% and the others deactivated (if 0 ... end).
%
% Input: table trainTest.mat created with create_training_test_dataset
% Input location: Folder "Data Training"
%
% Output: Optimal model parameter(s) for this set of training data
% Output location: Folder "Results Training"
% From this location "main_application_model_2" and
% "main_application_model_3_4" will load them automatically


%% Set Main Directory
% Gives the directory of this script
[mainDir, ~, ~] = fileparts(mfilename('fullpath'));


%% Set working directory
cd(mainDir);


%% Load training set
load(strcat(mainDir, '\Data Training\train.mat'));


%% Delete description column and turn into double array
train = train(:, (1:5));
train = table2array(train);


%% Optimisation

if 0
%% Model 1
%{
width_real = width_image * dist_x_from_camera * c_width
height_real = height_image * dist_x_from_camera * c_height
%}
disp('Model 1');
P = optimproblem;
c_width = optimvar('c_width');
c_height = optimvar('c_height');
% obj = sum of squared deviations from ground truth (We solve the least squares probem)
obj = sum((train(:, 1) .* train(:, 3) * c_width - train(:, 4)).^2) + sum((train(:, 2) .* train(:, 3) * c_height - train(:, 5)).^2);
P.Objective = obj;
string = strcat('P: min sum((width image .* dist_x * c_width - width ground truth)^2) + sum((height image * dist_x * c_height - height ground truth)^2) \n Solve for c_width, c_height\n');
fprintf(string);
% showproblem(P)
var = solve(P);
% Get Min. value
P_min = sum((train(:, 1) .* train(:, 3) * var.c_width - train(:, 4)).^2) + sum((train(:, 2) .* train(:, 3) * var.c_height - train(:, 5)).^2);
% Print
string = strcat('\n Min. value =', 32, num2str(P_min), '\n Optimal c =', 32, '(', num2str(var.c_width), ',', 32, num2str(var.c_height), ') \n');
fprintf(string);


%% Plot model
% Width
max_width = max(train(:,1) .* train(:,3));
interval = (0:1:ceil(max_width));
width_hat = var.c_width .* interval;
figure('Name', 'Model 1 width');
xlabel('width image * dist x') 
ylabel('width real') 
hold on;
scatter(width_hat, interval, '.');
scatter(train(:,4), train(:,1) .* train(:,3));

% Height
max_height = max(train(:,2) .* train(:,3));
interval = (0:1:ceil(max_height));
height_hat = var.c_height .* interval;
figure('Name', 'Model 1 height');
xlabel('height image * dist x') 
ylabel('height real')
hold on;
scatter(height_hat, interval, '.');
scatter(train(:,5), train(:,2) .* train(:,3));


%% Save c_width and c_height
save(strcat(mainDir, '\Results Training\var_optimal_no_bias_model_1'), 'var');
end

%%%%%%%%%%
%%%%%%%%%%

if 1
%% Model 2
%{
width_image = width_real / dist_x_from_camera * c_width
height_image = height_real / dist_x_from_camera * c_height
%}
disp('Model 2');
P = optimproblem;
c_width = optimvar('c_width');
c_height = optimvar('c_height');
% obj = sum of squared deviations from ground truth (We solve the least squares probem)
obj = sum(((train(:, 4) ./ train(:, 3) * c_width - train(:, 1)).^2) + ((train(:, 5) ./ train(:, 3) * c_height - train(:, 2)).^2));
P.Objective = obj;
string = strcat('P: min sum(((width ground truth ./ dist_x * c_width - width image)^2) + ((height ground truth ./ dist_x * c_height - height image)^2)) \n Solve for c_width, c_height\n');
fprintf(string);
% showproblem(P)
var = solve(P);
% Get Min. value
P_min = sum(((train(:, 4) ./ train(:, 3) * var.c_width - train(:, 1)).^2) + ((train(:, 5) ./ train(:, 3) * var.c_height - train(:, 2)).^2));
% Print
string = strcat('\n Min. value =', 32, num2str(P_min), '\n Optimal c =', 32, '(', num2str(var.c_width), ',', 32, num2str(var.c_height), ') \n');
fprintf(string);


%% Plot model
% Width
max_domain = max(train(:,4) ./ train(:,3));
interval = (0:0.001:max_domain);
width_image_hat = var.c_width .* interval;
figure('Name', 'Model 2 width');
xlabel('width real / dist x') 
ylabel('width image') 
hold on;
scatter(interval, width_image_hat, '.');
scatter(train(:,4) ./ train(:,3), train(:,1));

% Height
max_domain = max(train(:, 5) ./ train(:, 3));
interval = (0:0.001:max_domain);
height_image_hat = var.c_height .* interval;
figure('Name', 'Model 2 height');
xlabel('height real / dist x') 
ylabel('height image')
hold on;
scatter(interval, height_image_hat, '.');
scatter(train(:, 5) ./ train(:, 3), train(:, 2));


%% Save c_width and c_height
save(strcat(mainDir, '\Results Training\var_optimal_no_bias_model_2'), 'var');
end

%%%%%%%%%%
%%%%%%%%%%

if 0
%% Model 3 (like model 2, but only one c for both width and height)
%{
width_image = width_real / dist_x_from_camera * c
height_image = height_real / dist_x_from_camera * c
%}
disp('Model 3');
P = optimproblem;
c = optimvar('c');
% obj = sum of squared deviations from ground truth (We solve the least squares probem)
obj = sum(((train(:, 4) ./ train(:, 3) * c - train(:, 1)).^2) + ((train(:, 5) ./ train(:, 3) * c - train(:, 2)).^2));
P.Objective = obj;
string = strcat('P: min sum(((width ground truth ./ dist_x * c - width image)^2) + ((height ground truth ./ dist_x * c - height image)^2)) \n Solve for c\n');
fprintf(string);
% showproblem(P)
var = solve(P);
% Get Min. value
P_min = sum(((train(:, 4) ./ train(:, 3) * var.c - train(:, 1)).^2) + ((train(:, 5) ./ train(:, 3) * var.c - train(:, 2)).^2));
% Print
string = strcat('\n Min. value =', 32, num2str(P_min), '\n Optimal c =', 32, num2str(var.c), '\n');
fprintf(string);

%% Get residuals
% Width
width = [train(:, 1), train(:, 4) ./ train(:, 3)];
width_sorted = sortrows(width, 2);
res_width = (width_sorted(:, 2)) * var.c - width_sorted(:, 1);
%height
height = [train(:, 2), train(:, 5) ./ train(:, 3)];
height_sorted = sortrows(height, 2);
res_height = (height_sorted(:, 2)) * var.c - height_sorted(:, 1);

%% Plot residials
figure('Name', 'residuals Model 3 width');
plot(res_width);
figure('Name', 'residuals Model 3 height');
plot(res_height);

%% Plot model
% Width
max_domain = max(train(:,4) ./ train(:,3));
interval = (0:0.001:max_domain);
width_image_hat = var.c .* interval;
figure('Name', 'Model 3 width');
xlabel('width real / dist x') 
ylabel('width image') 
hold on;
scatter(interval, width_image_hat, '.');
scatter(train(:,4) ./ train(:,3), train(:,1));

% Height
max_domain = max(train(:, 5) ./ train(:, 3));
interval = (0:0.001:max_domain);
height_image_hat = var.c .* interval;
figure('Name', 'Model 3 height');
xlabel('height real / dist x') 
ylabel('height image') 
hold on;
scatter(interval, height_image_hat, '.');
scatter(train(:, 5) ./ train(:, 3), train(:, 2));


%% Save c_width and c_height
save(strcat(mainDir, '\Results Training\var_optimal_no_bias_model_3'), 'var');
end

%%%%%%%%%%
%%%%%%%%%%

if 0
%% Model 4 (like model 3, but as one regression model)
%{
width//height_image = width//height_real / dist_x_from_camera * c
%}
disp('Model 4');

% Make train matrix
train_reshaped = [train(:,1), train(:,4) ./ train(:, 3); train(:, 2), train(:, 5) ./ train(:,3)];

P = optimproblem;
c = optimvar('c');
% obj = sum of squared deviations from ground truth (We solve the least squares probem)
obj = sum((train_reshaped(:, 2) * c - train_reshaped(:, 1)).^2);
P.Objective = obj;
string = strcat('P: min sum((dist_ground truth ./ dist_x * c - dist_image)^2) \n Solve for c\n');
fprintf(string);
% showproblem(P)
var = solve(P);
% Get Min. value
P_min = sum((train_reshaped(:, 2) * var.c - train_reshaped(:, 1)).^2);
% Print
string = strcat('\n Min. value =', 32, num2str(P_min), '\n Optimal c =', 32, num2str(var.c), '\n');
fprintf(string);


%% Plot model
max_domain = max(train_reshaped(:, 2));
interval = (0:0.001:max_domain);
dist_image_hat = var.c .* interval;
figure('Name', 'Model 4');
xlabel('y // z real / dist x') 
ylabel('y // z image') 
hold on;
scatter(interval, dist_image_hat, '.');
scatter(train_reshaped(:, 2), train_reshaped(:, 1));


%% Save c_width and c_height
save(strcat(mainDir, '\Results Training\var_optimal_no_bias_model_4'), 'var');
end

%%%%%%%%%%
%%%%%%%%%%

if 0
%% Model 5 (OLS estimator)
%{
Note: This is simply for exploratory purposes. OLS is not what we want, 
because we want a model without a constant!

Model:
width//height_image = a + width//height_real / dist_x_from_camera * c
y := width//height_image
x := width//height_real / dist_x_from_camera

Parameter estimation:
c_hat = cov(x, y) / var(x) 
= (sum(x * y) - 1/n * sum(x) * sum(y)) / (sum(x^2) - 1/n (sum(x)^2)
a_hat = mean(y) - c_hat * mean(x)
%}
disp('Model 5');

% Make train matrix
train_reshaped = [train(:,1), train(:,4) ./ train(:, 3); train(:, 2), train(:, 5) ./ train(:,3)];

var = struct;
n = size(train_reshaped, 1);
% var.c = (sum(train_reshaped(:, 2) .* train_reshaped(:, 1)) - (1/n) * sum(train_reshaped(:, 2)) * sum(train_reshaped(:, 1))) / ...
%    (sum(train_reshaped(:, 2).^2) - (1/n) * (sum(train_reshaped(:,2))^2));
covar = cov(train_reshaped(:, 1), train_reshaped(:, 2), 1);
var.c = covar(2,1) / covar(2,2);
var.a = mean(train_reshaped(:, 1)) - var.c * mean(train_reshaped(:, 2));
% Get Min. value
P_min = sum((var.a + train_reshaped(:, 2) * var.c - train_reshaped(:, 1)).^2);
% Print
string = strcat('\n Min. value =', 32, num2str(P_min), '\n Optimal c =', 32, num2str(var.c), '\n', 'Optimal a =', 32, num2str(var.a), '\n');
fprintf(string);


%% Plot model
max_domain = max(train_reshaped(:, 2));
interval = (0:0.001:max_domain);
dist_image_hat = var.a + var.c .* interval;
figure('Name', 'Model 5');
xlabel('y // z real / dist x') 
ylabel('y // z image') 
hold on;
scatter(interval, dist_image_hat, '.');
scatter(train_reshaped(:, 2), train_reshaped(:, 1));


%% Save c_width and c_height
save(strcat(mainDir, '\Results Training\var_optimal_with_bias_model_5'), 'var');
end

if 0
%% Model 6 (Regression trough origin with formula)
%{
Yields the same result as model 4.

Model:
width//height_image = width//height_real / dist_x_from_camera * c
y := width//height_image
x := width//height_real / dist_x_from_camera

Parameter estimation:
c_hat = sum(x, y) / sum(x^2) 
Source:
http://web.ist.utl.pt/~ist11038/compute/errtheory/,regression/regrthroughorigin.pdf,
page 77
or
Pettit and Peers (1991)
%}
disp('Model 6');

% Make train matrix
train_reshaped = [train(:,1), train(:,4) ./ train(:, 3); train(:, 2), train(:, 5) ./ train(:,3)];

var = struct;
var.c = sum(train_reshaped(:, 1) .* train_reshaped(:, 2)) / sum(train_reshaped(:, 2).^2);
% Get Min. value
P_min = sum((train_reshaped(:, 2) * var.c - train_reshaped(:, 1)).^2);
% Print
string = strcat('\n Min. value =', 32, num2str(P_min), '\n Optimal c =', 32, num2str(var.c), '\n');
fprintf(string);


%% Plot model
max_domain = max(train_reshaped(:, 2));
interval = (0:0.001:max_domain);
dist_image_hat = var.c .* interval;
figure('Name', 'Model 6');
xlabel('y // z real / dist x') 
ylabel('y // z image') 
hold on;
scatter(interval, dist_image_hat, '.');
scatter(train_reshaped(:, 2), train_reshaped(:, 1));


%% Save c_width and c_height
save(strcat(mainDir, '\Results Training\var_optimal_no_bias_model_6'), 'var');
end

%% Check which packages are in use
disp(' ');
disp('Packages in use');
license('inuse')
