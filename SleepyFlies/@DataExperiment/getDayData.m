function [dayData, deadFliesMsg] = getDayData(obj, dayNums)
% getDayData: Get experiment data for specified experiment day(s)
% 
% Get the specified day of data starting at experiment start (not raw data
% start). If day is a vector, it represents multiple days to return.
% 
% Usage: (where obj is an object of class ExperimentData)
%   dayData = obj.getDayData(dayNumbers);
% 
% Inputs:
%   dayNums int or [1xN int] - Experiment days of data to return, where the
%                              first experiment day is 1.
%  
% Outputs:
%   dayData [MxO int] - Raw data from files for day(s) specified, where 
%                       M is the total number of data collection intervals
%                       for the selected days (with data collection every 1 
%                       minute and 3 days selected, 
%                       M=60bins/hour * 24hours/day * 3days = 4320)
%                       O is the number of flies selected
%   deadFliesMsg - String describing which boards/channels had no activity
%                       on the selected days. If all channels had activity,    
%                       returns an empty string.

% See how long our output needs to be and initialize the array 
dayCount = numel(dayNums);

dayData = nan(dayCount*obj.IntervalsPerDay, size(obj.ExperimentData,2), size(obj.ExperimentData,3));

try
    for dIdx = 1:dayCount
        d = dayNums(dIdx);
%         dayStartIdx = (d-1)*obj.IntervalsPerDay+1
%         dayEndIdx = d*obj.IntervalsPerDay
        dayData((dIdx-1)*obj.IntervalsPerDay+1:dIdx*obj.IntervalsPerDay,:,:) = obj.ExperimentData( (d-1)*obj.IntervalsPerDay+1 : d*obj.IntervalsPerDay,:,:);
        % Check for dead (inactive) flies       
    end
    deadFlies = ~any(dayData);
    if any(deadFlies)
        deadFliesMsg = 'The following fl';
        if sum(deadFlies) > 1
            deadFliesMsg = [deadFliesMsg 'ies'];
        else
            deadFliesMsg = [deadFliesMsg 'y'];
        end
        deadFliesMsg = [deadFliesMsg ' had no activity on the selected day(s): '];
        for dIdx = find(deadFlies)
            deadFliesMsg = [deadFliesMsg num2str(obj.Boards(dIdx), '%02.f') 'C' num2str(obj.Channels(dIdx), '%02.f') ', '];
        end
        deadFliesMsg = deadFliesMsg(1:end-2);
    else
        deadFliesMsg = '';
    end
catch ME
    if strcmp(ME.identifier, 'MATLAB:badsubscript')
        causeException = MException('MATLAB:SleepyFlies:invalidday', 'Invalid day number selected.');
        ME = addCause(ME, causeException);
    end
    rethrow(ME)
end