% function to check wether an Obj is detectable or not
% vec ist the the array vector of the detection levels
function b = check_detectable(vec)

b=true;
binc = [0,1,2]; % detection Levels
counts = hist(vec,binc);

% time threshold is 250 stamps = 5 seconds (sample time of 0.02 s)
%TObj detection's duration below 5s will be igonred. Threshold can be
%adapted
if counts(1)>=length(vec)-250
    b=false;
end
end
