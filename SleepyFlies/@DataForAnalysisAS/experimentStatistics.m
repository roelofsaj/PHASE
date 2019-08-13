function stats = experimentStatistics(obj, varargin)
% experimentStatistics: Calculate statistics on activity/sleep during experiment.
%
% Usage: (where obj is an object of class DataExperiment)
%   stats = obj.experimentStatistics(statType, normalized)
%
% Inputs:
%   normalized - true or false, default false
%
% Outputs:
%   stats - table containing experiment statistics
%
% For EACH FLY, we need total minutes of sleep or activity, total bouts of sleep or activity, and
% average duration of bouts of sleep or activity, as well as these same 3
% fields for both day hours and night hours

% Total minutes is the number of data intervals with a value > 0 times the
% length of an interval in minutes
% For activity counts, it's the total number of beam crossings, not the
% total minutes
% Since this comes up in a number of places, use a multiplier that's the
% data interval for sleep (to get minutes) and 1 for activity.
if obj.IsSleep
    interval = obj.DataInterval;
else
    interval = 1;
end
if nargin==0
    normalized = false;
else
    normalized = varargin{1};
end
if normalized && ~ obj.NormalizeActivity
    useData = obj.AnalysisData ./ obj.BinSize;
    % Anything that had 0 activity (and therefore mean 0) will come out
    % nan... replace these with 0s.
    useData(isnan(useData)) = 0;
elseif normalized && obj.NormalizeActivity
    % Ignore the bin size when normalizing here, since obj.AnalysisData isn't in bins.
    tmpBinSize = obj.BinSize;
    obj.BinSize = 1;
    useData = obj.normalizeData(obj.AnalysisData);
    obj.BinSize = tmpBinSize;
else
    useData = obj.AnalysisData;
end

totalMinutes = sum(useData) * interval;
avgMinutes = mean(useData * interval);

%Initialize variables that will be used to create the output table
[~, chans, boards] = size(useData);
totalBouts = zeros(size(totalMinutes));
avgDuration = zeros(size(totalMinutes));
totalDayMinutes = zeros(size(totalMinutes));
%avgDayMinutes = zeros(size(totalMinutes));
totalDayBouts = zeros(size(totalMinutes));
avgDayDuration = zeros(size(totalMinutes));
totalNightMinutes = zeros(size(totalMinutes));
%avgNightMinutes = zeros(size(totalMinutes));
totalNightBouts = zeros(size(totalMinutes));
avgNightDuration = zeros(size(totalMinutes));

% Find each sleep or active interval: any value in useData that's greater
% than 0 at this point indicates activity (or sleep, whichever we're
% looking at) for its data interval, so replace the activity count value
% with the length of the data interval in minutes for use in summing bout
% durations.
% Get a light/dark mask to split the data by day/night
% This mask will have a column the length of a single fly's data, with 1s
% for light hours and 0s for dark hours
mask = obj.AnalysisLightMask;
for bIdx = 1:boards % This should still work, even though there's no longer a boards dimension... leaving it here just in case.
    for cIdx = 1:chans
        % For finding bouts, we just want to know if the target thing
        % (sleep or activity) happened,
        % so replace the beam crossing counts with 1s here for activity
        % (for sleep this doesn't c anything).
        % flyData = min(useData(:,cIdx,bIdx),1);
        flyData = useData(:,cIdx,bIdx) > 0;
        boutStart = [flyData(1)>0; diff(flyData)] == 1; % This will have a 1 at every location where a bout starts
        boutEnd = [diff(flyData); -flyData(end)] == -1; % This will have a 1 at every location where a bout ends
        % boutDuration is a vector that has the bout duration in minutes at
        % the location of the first interval of each bout
        boutDuration = zeros(numel(flyData),1);
        if obj.IsSleep
            % For sleep datat we want the bout duration in minutes
            boutDuration(boutStart) = interval * (find(boutEnd)+1 - find(boutStart));
        else
            % Now that we've found bouts, we can revert to actual beam
            % counts
            flyData = useData(:, cIdx, bIdx);
            % And for active data, we want the total beam crossings in the
            % bout, not the total minutes... I think.
            % This is not that easy, since we're adding up different-length
            % intervals within the column vector, but I think the following
            % will do it: First sum up all the beam crossings.
            activeCounts = cumsum(flyData);
            % Now shift that up by one, so that entry at each boutStart
            % point has the total number of activity counts BEFORE that
            % point.
            preBoutActiveCounts = activeCounts([2:size(useData,1), 1], :);
            preBoutActiveCounts(1) = 0; % We want 0 activity counts before the first bin, not the total number of counts that was shifted into this position.
            % Now the activity counts in each bit should be the
            % cumulative sum at the end of each bout minus the cumulative
            % sum before the bout started
            boutDuration(boutStart) = activeCounts(boutEnd) - preBoutActiveCounts(boutStart);
            
        end
        %[~, boutStart, boutEnd, boutDuration] = findseq((flyData>0) * obj.DataInterval, 'findValue', obj.DataInterval);
        %[boutStartRow, boutCol] = ind2sub(size(useData(:,:,bIdx)), boutStart);
        totalBouts(1,cIdx,bIdx) = sum(boutStart);
        if any(boutDuration>0)
            avgDuration(1, cIdx, bIdx) = mean(boutDuration(boutDuration>0));
        end
        % Also need to determine day-time stats & night-time stats
        totalDayMinutes(1, cIdx, bIdx) = sum(flyData .* mask) * interval;
        totalNightMinutes(1,cIdx, bIdx) = sum(flyData .* ~mask) * interval;
        totalDayBouts(1,cIdx, bIdx) = sum(boutStart & mask);
        totalNightBouts(1,cIdx, bIdx) = sum(boutStart & ~mask);
        if totalDayBouts(1,cIdx,bIdx) > 0 % No else part needed, since it's already 0.
            avgDayDuration(1,cIdx,bIdx) = sum(boutDuration .* mask) / totalDayBouts(1,cIdx,bIdx);
        end
        if totalNightBouts(1,cIdx,bIdx) > 0
            avgNightDuration(1,cIdx,bIdx) = sum(boutDuration .* ~mask) / totalNightBouts(1,cIdx,bIdx);
        end
    end
    
end

avgDayMinutes = totalDayMinutes / sum(mask);
avgNightMinutes = totalNightMinutes / sum(~mask);

flies = repmat(obj.Channels', boards, 1);
boards = obj.Boards'; % This was a change for getting rid of boards dimension
%boards = reshape(repmat(obj.Boards, chans, 1),[], 1);
if obj.IsSleep
    stats = table(boards, flies, ...
        reshape(totalMinutes, [],1,1), reshape(avgMinutes,[],1,1), reshape(totalBouts,[],1,1), reshape(avgDuration,[],1,1),...
        reshape(totalDayMinutes, [],1,1), reshape(avgDayMinutes, [],1,1), reshape(totalDayBouts,[],1,1), reshape(avgDayDuration,[],1,1),...
        reshape(totalNightMinutes, [],1,1), reshape(avgNightMinutes, [],1,1), reshape(totalNightBouts,[],1,1), reshape(avgNightDuration,[],1,1),...
        'VariableNames', {'Board', 'Fly', 'TotalMinutes', 'AverageMinutes', 'TotalBouts', 'AverageBoutDuration',...
        'DayTotal', 'AverageDayMinutes', 'DayBouts', 'AverageDayBoutDuration',...
        'NightTotal', 'AverageNightMinutes', 'NightBouts', 'AverageNightBoutDuration',...
        });
else
    % If this is a normalized analysis, the TotalCounts and AverageCounts
    % are meaningless; don't include them.
    % (This takes two checks: obj.NormalizedActivity checks whether we're
    % doing a normalized analysis, and normalized checks whether this
    % particular call to experimentStatistics is for the normalized or the
    % raw tab of the spreadsheets.)
%     if obj.NormalizeActivity && normalized
%         stats = table(boards, flies, ...
%             reshape(totalDayMinutes, [],1,1), reshape(avgDayMinutes, [],1,1),...
%             reshape(totalNightMinutes, [],1,1), reshape(avgNightMinutes, [],1,1),...
%             'VariableNames', {'Board', 'Fly', ...
%             'DayTotalCounts', 'AverageDayCounts', ...
%             'NightTotalCounts', 'AverageNightCounts'});
%     else
        stats = table(boards, flies, ...
            reshape(totalMinutes, [],1,1), reshape(avgMinutes,[],1,1),...
            reshape(totalDayMinutes, [],1,1), reshape(avgDayMinutes, [],1,1),...
            reshape(totalNightMinutes, [],1,1), reshape(avgNightMinutes, [],1,1),...
            'VariableNames', {'Board', 'Fly', 'TotalCounts', 'AverageCounts', ...
            'DayTotalCounts', 'AverageDayCounts', ...
            'NightTotalCounts', 'AverageNightCounts'});
%     end
    
end
