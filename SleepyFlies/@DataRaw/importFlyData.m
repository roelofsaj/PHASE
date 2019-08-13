function importFlyData(obj)
% IMPORTDATA:
%
% Usage:
%
% Inputs:
%
% Outputs:
%
startRow = 4;
pointCountRow = 1;
intervalRow = 2;
timeRow = 3;
% See http://www.trikinetics.com/Downloads/DAMSystem%20User's%20Guide%203.0.pdf
%   p. 23 for file format.
% Line 0: File name  Date
% Line 1: Number of readings
% Line 2: Reading interval MM(SS)
% Line 3: First reading HHMM(SS)
% Line 4-end: Activity counts, where a negative value indicates an error

% Get the number of points from the first file here
textFile = buildFilename(obj.DataFolder, obj.RunName, obj.Boards(1), obj.Channels(1));
dateStr = obj.getExperimentDate(textFile);

% Unlike most of MATLAB, inputs to csvread are 0-based indexes.
try
    pointCount = csvread(textFile, pointCountRow, 0, [pointCountRow, 0, pointCountRow, 0]);
    interval = csvread(textFile, intervalRow, 0, [intervalRow, 0, intervalRow, 0]);
    startTime = csvread(textFile, timeRow, 0, [timeRow, 0, timeRow, 0]);
catch ME
    if strcmpi(ME.identifier, 'MATLAB:csvread:FileNotFound')
        [~, f] = fileparts(textFile);
        error('SleepyFlies:importData:fileNotFound', ...
            ['Error. File not found: ' f '\nRemove this channel from the list and try again.']);
    else
        rethrow(ME);
    end
end
obj.DataStartDate = dateStr{1};
obj.DataStartTime = startTime;
obj.DataInterval = interval;
obj.DataStart = datetime(sprintf('%s%04u', obj.DataStartDate, obj.DataStartTime),'InputFormat', 'dd-MMM-yyyyHHmm');
obj.FileData = nan(pointCount, numel(obj.Channels));

for idx = 1:numel(obj.Channels)
    textFile = buildFilename(obj.DataFolder, obj.RunName, obj.Boards(idx), obj.Channels(idx));
    try
        newData = csvread(textFile, startRow, 0);
    catch ME
        if strcmpi(ME.identifier, 'MATLAB:csvread:FileNotFound')
            [~, f] = fileparts(textFile);
            error('SleepyFlies:importData:fileNotFound', ...
                ['Error. File not found: ' f '\nRemove this channel from the list and try again.']);
        else
            rethrow(ME);
        end
    end
    try
        obj.FileData(:, idx) = newData;
    catch ME
        if strcmpi(ME.identifier, 'MATLAB:subsassigndimmismatch')
            %Try truncating dimensions to the shorter recorder
            currDim = size(obj.FileData,1);
            newDim = size(newData,1);
            if currDim > newDim
                obj.FileData = obj.FileData(1:newDim,:);
            elseif newDim > currDim
                obj.FileData(:, idx) = newData(1:currDim);
            else
                rethrow(ME)
            end
        else
            rethrow(ME)
        end

    end
end

function filepath = buildFilename(folder, runName, boardNum, channel)
% Format is something like "MyRunCtM086C03.txt"
boardLetter = 'M';
filepath = fullfile(folder, [runName, boardLetter, ...
    sprintf('%03u', boardNum), 'C' sprintf('%02u', channel) '.txt']);
%disp(filepath)

