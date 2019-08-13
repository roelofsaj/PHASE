function [fh, ax, filename] = plotLatency(obj, plotSettings)
% Create a plot of latencies or anticipations
%
% Usage:
%   [fh, ax, filename] = obj.plotLatency(plotSettings);
%
% Inputs:
%   plotSettings: struct with the following fields
%                 pIdx: page index of data to plot
%                 useErrorBars (optional, default true): plot error bars?
%                 boardAndChannel: string describing the board & channel
%                                  number, for use in plot title
%
% Outputs:
%   fh: figure handle of the created plot
%   filename: suggested filename to save file


% Color definitions
darkred = [0.55 0 0];
lightblue = [0.5273 0.8047 0.9792];
lightgreen = [0.5625 0.92975 0.5625];
palegrey = [0.9583 0.9583 0.9583];
lightgray = [.824 .824 .824];
midblue = [.17 .4 .6];
darkblue = midblue - .17;
%latColor = [.17 .4 .6];  % Dark Blue
%latColor = [0 .5 0];  % Darkish green
%latColor = [0 0 .8]; %bright blue
smoothColor = midblue; % Color for the smoothing line
latColor = darkblue; % Color for the latency markers & annotations


% Make a base plot on which to display the latencies
plotSettings.useErrorBars = false;
%plotSettings.barPlotInputs can be used to specify name/value pair inputs
%for the bar plots. 
%plotSettings.barPlotInputs = {'edgecolor','flat'};
fh = obj.plotBars(plotSettings);
ax = fh.CurrentAxes;

% Find the latency intervals
latencyInts = obj.getLatencyIntervals();
% Get the latencies for the current plot
latencies = obj.Latencies(plotSettings.pIdx);

% Instead of lines, shade the intervals
% ztInts = [lightsOnInts; lightsOffInts];
for iIdx = 1:size(latencyInts, 1)
    thisInt = latencyInts(iIdx,:);
    intStart = obj.BinCenters(thisInt(1));
    intStop = obj.BinCenters(thisInt(2));
    r = rectangle(ax, 'Position', [intStart -100 intStop-intStart 5000], 'facecolor',palegrey, 'edgecolor',palegrey);
    uistack(r, 'bottom');
end
% Include lines for the latency intervals we're looking at
%     intervalEdges = [lightsOnInts(:); lightsOffInts(:)];
%     for iIdx = 1:numel(intervalEdges)
%         loc = plotSettings.binCtrs(intervalEdges(iIdx));
%         line(ax, [loc loc], [-1000 1000], 'linestyle','--', 'color',darkred,'linewidth', 1);
%     end
%     for iIdx = 1:size(lightsOnInts,1)
%         loc = plotSettings.binCtrs(intervalEdges(iIdx));
%         line(ax, [loc loc], [-1000 1000],'linestyle','--', 'color',darkred,'linewidth', 1);
%     end


% Plot a line with the smoothed data
smoothedData = obj.SmoothedData(plotSettings.pIdx,:); % TODO: Make sure this indexing is correct
plot(ax, obj.BinCenters, smoothedData,'linewidth',2,'color', smoothColor);

[xSpace, ySpace] = obj.getLabelSpacing(ax);

% Plot each individual latency
for lIdx = 1:size(latencies.time,1)
    if ~isempty(latencies.loc(lIdx,:)) && any(latencies.loc(lIdx,:)) 
        % Figure out where the min & max occur & mark them
        %xvals = [minIdx+pt1Idx maxIdx+pt1Idx]/(60/binSize);
        xvals = latencies.time(lIdx,:);
        yvals = smoothedData(latencies.loc(lIdx,:));
        % Use markers instead of a line
        plot(xvals, yvals, 'v', 'markeredgecolor', latColor, 'markerfacecolor', latColor);
        % line(xvals, yvals, 'linewidth', 2, 'color', latColor)
        text(xvals(2)+xSpace, yvals(2) + ySpace, [num2str(latencies.latency(lIdx)) ' min'],...
            'horizontalalignment', 'left', 'color', latColor, 'fontweight', 'bold');
    end
end

% Label the plot
% ax.Title.String = [ax.Title.String; {plotLabel}];

if obj.IsSleep
    fLabel = 'SleepLatency_';
else
    fLabel = 'ActivityAnticipation_';
    if obj.NormalizeActivity
        fLabel = ['Normalized' fLabel];
    end
end
% filename = fullfile(obj.folderOut, replace([fLabel plotSettings.boardChanLabel '_' datestr(now, 'yyyymmdd_HHMMSS') '.fig'], ' ', '_'));
filename = replace([fLabel obj.Title '_' datestr(now, 'yyyymmdd_HHMM') '.fig'], ' ', '_');
end

