function [expData,deadFliesMsg] = getAnalysisData(obj)
% getAnalysisData - Return data for experiment days, converted to sleep if necessary
%
% Usage: (where obj is an object of class DataForAnalysis)
%   analysisData = obj.getAnalysisData();
% 
% Output: 
%   expData: [nxc] array of fly sleep or activity data
%            For activity data, each value is a count of beam crossings.
%            For sleep data, values are 1 or 0, where 1 indicates that the
%            interval was part of a sleep bout.
% 
% Note: When obj.isSleep = false (activity eduction), this function returns
% the same data as SleepyFliesObj.getDayData(SleepyFliesObj.days).

% Get the days of data we'll need
[expData, deadFliesMsg] = obj.getDayData(obj.Days);

if obj.IsSleep
    % If this is sleep eduction, we need to convert the activity data to
    % sleep data
    expData = obj.convertToSleep(expData);
end
