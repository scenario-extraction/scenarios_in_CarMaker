function result = read_DAT_file(path)
% Read DAT file and extract dimenstions off all traffic objects

% Open file
fid = fopen(path); % open the file

% fid = fopen("data\LKW\ConstructionSite"); % open the file

% Index
i = 1;

% Initialise
result = strings;

while ~feof(fid) % feof(fid) is true when the file ends
    textLineEntry = fgetl(fid); % read one line
    if contains(textLineEntry, 'Basics.Dimension')
       result(i, 1:5) = strsplit(textLineEntry, ' ');
       i = i + 1;
    end
end

% Delete collumn containing =
result(:, 2) = [];

% Close file
fclose(fid); % close the file

end