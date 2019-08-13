function [fh, ax, filename] = plotPhase(obj, plotSettings)
% Create a plot of peaks in the smoothed data
%
% Usage:
%   [fh, ax, filename] = obj.plotPhase(plotSettings);
%
% Inputs:
%   plotSettings: struct with the following fields
%                 pIdx: page index of datae to plot
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

smoothColor = midblue; % This is the smoothing line
pkColor = darkblue; % This is the color for the peak markers & labels
aucColor = midblue; % This is to shade the area under the curve


% Make a base plot on which to display the latencies
plotSettings.useErrorBars = false;
fh = obj.plotBars(plotSettings);
ax = fh.CurrentAxes;

% Plot a line with the smoothed data
smoothedData = obj.SmoothedData(plotSettings.pIdx,:); % TODO: Make sure this indexing is correct
plot(ax, obj.BinCenters, smoothedData,'linewidth',2,'color', smoothColor);
pks = obj.Peaks(plotSettings.pIdx);

[xSpace, ySpace] = obj.getLabelSpacing(ax);

% Plot each peak
for p = 1:size(pks.peaks,1)
    % Plot the peak area
    xvals = pks.extentsTime(p,1):obj.BinSize/60:pks.extentsTime(p,2);
    % Make sure indices are > 1 and < data length
    yvals = smoothedData(pks.extentsBins(p,1):pks.extentsBins(p,2));
    area(xvals, yvals, 'FaceColor', aucColor, 'FaceAlpha', 0.4);
    % Annotate with the peak values
    plot(pks.time(p), pks.peaks(p), 'v', 'markeredgecolor', pkColor, 'markerfacecolor', pkColor);
    % line(xvals, yvals, 'linewidth', 2, 'color', latColor)
    text(pks.time(p) + xSpace, pks.peaks(p) + ySpace, num2str(round(pks.timeZT(p),1)),...
        'horizontalalignment', 'left', 'color', pkColor, 'fontweight', 'bold');
end

% Label the plot
% ax.Title.String = [ax.Title.String; {plotLabel}];

if obj.IsSleep
    fLabel = 'SleepPhase_';
else
    fLabel = 'ActivityPhase_';
    if obj.NormalizeActivity
        fLabel = ['Normalized'  fLabel];
    end
end
% filename = fullfile(obj.folderOut, replace([fLabel plotSettings.boardChanLabel '_' datestr(now, 'yyyymmdd_HHMMSS') '.fig'], ' ', '_'));
filename = replace([fLabel obj.Title '_' datestr(now, 'yyyymmdd_HHMM') '.fig'], ' ', '_');
end

