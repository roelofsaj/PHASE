function bin = findBinByDatetime(obj, datetimeIn)
% Return the bin number (row index) for the bin starting at a given date
% and time, based on the data start date and time

% First determine the time offset between the requested time and the data
% start time
timeDiff = minutes(datetimeIn - obj.DataStart);

intervals = floor(timeDiff/obj.DataInterval);
% Just in case the intervals are something other than minutes & the
% requested time doesn't fall right on an interval boundary...
if mod(timeDiff, obj.DataInterval) ~= 0
    warning('Requested day/time does not line up with a data collection time. Using the bin that contains this day/time.');
end

% The bin that starts at the requested time is the one after the
% number of intervals between data start and the requested time, i.e.
% obj.DataStart = 24-Aug-2017 21:10:00
% datetimeIn = 24-Aug-2017 21:10:02
%   -> timediff = 2 minutes, intervals = 2 (with DataInterval=1 minute)
% bin 1 starts at 21:10:00
% bin 2 starts at 21:10:01
% bin 3 starts at 21:10:02, the requested time.
bin = intervals + 1;