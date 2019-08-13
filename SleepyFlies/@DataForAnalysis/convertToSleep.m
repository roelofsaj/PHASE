function dataOut = convertToSleep(obj, dataIn, varargin)
% Convert activity count data to sleep data
% Any 5+ minute series of no activity (activity count = 0) is sleep time

% If there's an input after the data, it's the minimum number of inactive
% minutes for the fly to be considered sleeping.
% Otherwise use 5.
if nargin>2 && isnumeric(varargin{1})
    minutesForSleep = varargin{1};
else
    minutesForSleep = 5;
end

% Convert the number of minutes for sleep to the number of data collection
% intervals for sleep
intsForSleep = minutesForSleep/obj.DataInterval;

% Create an output array the same size as the input array, initialized to
% 0s (not sleep)
dataOut = zeros(size(dataIn));

if intsForSleep <= 1
    % If the required minutes for sleep is less than or equal to one data
    % interval, than we just consider every interval without activity a
    % sleep interval.
    % (findseq used below doesn't find single occurrences, so it won't work
    % in this case.)
    dataOut(dataIn==0) = 1;
else
    % Find the sequences of 0 activity counts that are long enough to be sleep
    [~, sleepStart, sleepEnd] = findseq(dataIn, 'findValue', 0, 'minLength', ceil(intsForSleep));
    
    % For the data collection intervals that were part of sleep cycles, change
    % the ouput value to 1 (sleep)
    for sIdx = 1:size(sleepStart,1)
        dataOut(sleepStart(sIdx):sleepEnd(sIdx)) = 1;
    end
end
