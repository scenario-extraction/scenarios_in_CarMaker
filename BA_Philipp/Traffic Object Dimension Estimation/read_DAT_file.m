function result = read_DAT_file(path)


% *************************************************************************
% Author:   Philipp Metzger
%           Karlsruher Institut für Technologie
% Date:     12.05.2020
% *************************************************************************
%
% *************************************************************************
% Description
% *************************************************************************
% This function is for reading a CarMaker(.dat) file and extracting
% widths and heights of all traffic objects in respective scenario


    % Open file
    fid = fopen(path); % open the file

    % Index
    i = 1;

    % Initialise
    result = strings;

    if fid == -1
         disp('Error: Unable to open road file. Please check name of CarMaker (.dat) file which is located in "...\006 Traffic Object Dimension Estimation\Data Application\dat"');
         disp('This implementation requires the file name to end with .dat');
         return
    end

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