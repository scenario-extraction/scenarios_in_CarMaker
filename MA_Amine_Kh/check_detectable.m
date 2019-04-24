function b = check_detectable(vec)  % function to check wether an Obj is detectable or not 

b=true;
binc = [0,1,2]; % detection Levels
counts = hist(vec,binc);
if counts(1)>=length(vec)-250
    b=false;
end
end
