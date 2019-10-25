function dayMask = makeDayNightMask(obj, dayCount)
% Return an array with 1s during light hours and 0s during dark hours for a
% single fly for the specified number of days.
dayMask = zeros(dayCount * obj.DayLength * 60 / obj.DataInterval, 1);
firstLightIdx = obj.LightsOn * 60 / obj.DataInterval + 1;
lastLightIdx = (obj.LightsOn + obj.LightHours) * 60 / obj.DataInterval;

% if first light was before the experiment started, wrap it around
if firstLightIdx < 1
    dayCount = dayCount + 1;
end
for d = 1:dayCount
    dayMask(max(firstLightIdx+(d-1)*obj.IntervalsPerDay,1):min(lastLightIdx+(d-1)*obj.IntervalsPerDay, numel(dayMask))) = 1;
end

