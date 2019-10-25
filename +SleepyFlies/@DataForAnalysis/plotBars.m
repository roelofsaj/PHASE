function [fh, ax, filename] = plotBars(obj, plotSettings)
% This is the classic histogram-looking plot
%
% Usage:
%   [fh, ax, filename] = obj.plotBars(plotSettings);
%
% Inputs:
%   plotSettings: struct with the following fields
%                 pIdx: page index of datae to plot 
%                 useErrorBars (optional, default true): plot error bars?
%                 boardAndChannel: string describing the board & channel
%                                  number, for use in plot title
%
% Outputs:
%   fh: figure handle of the created plot
%   filename: suggested filename to save file

darkgray = [.4 .4 .4];
midgray = [.66 .66 .66];
lightgray = [.824 .824 .824];
% rectmax is an arbitrary maximum y value for the shaded night rectangles.
rectmax = 1000000;

binCtrs = obj.BinCenters;
binSize = obj.BinSize;
lightStart = obj.AnalysisLightStart;
lightStop = obj.AnalysisLightStop;
dayCount = obj.AnalysisOutputDays;
dayLength = obj.DayLength;
mask = obj.AnalysisPlotLightMask;
plotTitle = obj.Title;
lightHours = obj.LightHours;
if isfield(plotSettings, 'barPlotInputs')
    barPlotInputs = plotSettings.barPlotInputs;
else
    barPlotInputs={};
end

% Get the plot data for the current plot index
plotData = obj.PlotData(:,:,plotSettings.pIdx);

% Define the error bar calculation function
errFunc = @(x) obj.DataInterval * std(x,1) / size(plotData,1);
plotErr = errFunc(plotData);

% If there's a useErrorBars field in plotSettings, use that to determine
% whether or not to plot error bars. Default to true if not found.
if isfield(plotSettings, 'useErrorBars')
    useErrorBars = plotSettings.useErrorBars;
else
    useErrorBars = true;
end

% If there are multiple rows of data, this plots the average.
plotData = mean(plotData,1);

% If we're plotting multiple axes on the same sheet, use the input figure &
% axes--makeAxis handles the overhead of laying out the plots.
[fh, ax] = obj.makeAxis(plotSettings);

% Add the light/dark shading and lines
% Add the dashed lines at light/dark boundaries
xtk = [];
xtlbl = {};
for d = 0:dayLength:dayLength*dayCount
    if lightStart>= 0
        rectangle(ax, 'Position', [0+d 0 lightStart rectmax], 'facecolor',lightgray, 'edgecolor',lightgray);
        rectangle(ax, 'Position', [lightStart+lightHours+d  0 dayLength-lightStop rectmax], 'facecolor',lightgray,'edgecolor',lightgray);
        l1 = line([lightStart+d lightStart+d], [0 rectmax], 'linestyle', ':', 'linewidth', 1.5, 'color', 'k');
        l2 = line([lightStop+d lightStop+d], [0 rectmax], 'linestyle', ':', 'linewidth', 1.5, 'color', 'k');
        xtk(end+1:end+2) = [d+lightStart d+lightStop];
        if obj.AveragingMode == Averaging.Flies || obj.AveragingMode == Averaging.None
            %lower(settings.averaging(1))=='f' || lower(settings.averaging(1)) == 'n'
            %xtlbl{end+1} = ['\sffamily\begin{tabular}{c} Day' num2str((d/dayLength)+1) ' \\ ZT0\end{tabular}'];
            %xtlbl{end+1} = ['\sffamily\begin{tabular}{c} Day' num2str((d/dayLength)+1) ' \\ ZT' num2str(lightHours) '\end{tabular}'];
            if d/dayLength >= numel(obj.Days)
                xtlbl{end+1} = '';
            else
                xtlbl{end+1} = ['\sffamily\selectfont' num2str(obj.Days((d/dayLength) + 1))];
            end
            xlabel('Day');
            xtlbl{end+1} = '';
        else
            xtlbl{end+1} = '\sffamily\selectfont ZT0';
            xtlbl{end+1} = ['\sffamily\selectfont ZT' num2str(lightHours)];
        end
    else
        rectangle(ax, 'Position', [lightStart+lightHours+d  0 lightHours rectmax], 'facecolor',lightgray,'edgecolor',lightgray);
        l1 = line([lightStart+d+dayLength lightStart+d+dayLength], [0 rectmax], 'linestyle', ':', 'linewidth', 1.5, 'color', 'k');
        l2 = line([lightStop+d lightStop+d], [0 rectmax], 'linestyle', ':', 'linewidth', 1.5, 'color', 'k');
        xtk(end+1:end+2) = [d+lightStop d+mod(lightStart, dayLength)];
        if obj.AveragingMode == Averaging.Flies || obj.AveragingMode == Averaging.None
            %lower(settings.averaging(1))=='f' || lower(settings.averaging(1)) == 'n'
            xtlbl{end+1} = ['\sffamily\begin{tabular}{c} Day' num2str((d/dayLength)+1) ' \\ ZT' num2str(lightStop) '\end{tabular}'];
            xtlbl{end+1} = ['\sffamily\begin{tabular}{c} Day' num2str((d/dayLength)+1) ' \\ ZT' num2str(mod(lightStart,dayLength)) '\end{tabular}'];
        else
            xtlbl{end+1} = ['\sffamily ZT' num2str(lightStop)];
            xtlbl{end+1} = ['\sffamily ZT' num2str(mod(lightStart,dayLength))];
            
        end
    end
end

hold(ax, 'on');
ymin = 0;
% Make a bar plot with error bars
if useErrorBars && size(obj.PlotData, 1) > 1
    b = barwitherr(plotErr, binCtrs, plotData, barPlotInputs{:});
    % ymargin is the gap on to leave above the maximum data point on the y
    % axis. With error bars, the maximum data point is actual the maximum
    % of data + error, and ymax will be that value plus 10% of the data
    % range (0 to ymax).
    ymargin = .05 * max(plotData+plotErr);
    ymax = max(plotData+plotErr) + 2*ymargin;
else
% Or make a bar plot without error bars
    b  = bar(binCtrs, plotData, barPlotInputs{:});
    % Without error bars, just use the data maximum as ymax.
    ymargin = .05*max(plotData);
    ymax = max(plotData) + 2*ymargin;
end

% Put the day/night dashed demarcation lines over top of the data bars
for d = 0:dayLength:dayLength*dayCount
    if lightStart>= 0
        line([lightStart+d lightStart+d], [0 rectmax], 'linestyle', ':', 'linewidth', 1.5, 'color', 'k');
        line([lightStop+d lightStop+d], [0 rectmax], 'linestyle', ':', 'linewidth', 1.5, 'color', 'k');
    else
        line([lightStart+d+dayLength lightStart+d+dayLength], [0 rectmax], 'linestyle', ':', 'linewidth', 1.5, 'color', 'k');
        line([lightStop+d lightStop+d], [0 rectmax], 'linestyle', ':', 'linewidth', 1.5, 'color', 'k');
    end
end

% New min/max y axis range as of 2019-01-21
if obj.NormalizeActivity && ~obj.IsSleep
    if obj.BinSize == obj.DataInterval
        % phase/latency analysis
        ymax = 0.01;
        ymin = 0;
    else
        % binned activity analysis
        % per Jenna, 1-14-19, always use .25 for y-axis max with normalized
        % analysis
        ymax = 0.25;
        ymin = 0;
    end
elseif ~obj.IsSleep
    % non-normalized activity plots
    ymax = 8;
    ymin = 0;
elseif obj.IsSleep % Sleep analysis
    % As of 2019-04-08, use bin size + 10% for y axis maximum
    ymin = 0;
    ymax = obj.BinSize * 1.1;
end
if ~obj.NormalizeActivity
    ymax = max(ymax, 1);
end
% Manually specified y-axis range overrides all of the above.
if ~isempty(plotSettings.yrange)
    ymin = plotSettings.yrange(1);
    ymax = plotSettings.yrange(2);
end


b.FaceColor = 'flat';
b.CData(mask>0,:) = repmat(midgray, sum(mask>0),1);
b.CData(~mask,:) = repmat(darkgray, sum(~mask),1);
b.BarWidth = 1;
set(gcf, 'Color', [1 1 1]);
hold all;


% This was the original plotting method, with a day-night black and white
% bar at the bottom of the data plot. This was replaced with shaded
% grey areas similar to the line plots, coded above.
%l1 = line([lightStart lightStart], [0 ymax]);
%l2 = line([lightStop lightStop], [0 ymax]);
% Add the light/dark bar(s) at the bottom
% xtk = [];
% xtlbl = {};
% for d = 0:dayLength:dayCount*dayLength
%     if lightStart >= 0
%         rectangle(ax, 'Position', [0+d ymin lightStart abs(ymin)], 'facecolor','k');
%         rectangle(ax, 'Position', [lightStart+lightHours+d  ymin dayLength-lightStop abs(ymin)], 'facecolor','k');
%         xtk(end+1:end+2) = [d+lightStart d+lightStop];
%         if obj.AveragingMode == Averaging.Flies || obj.AveragingMode == Averaging.None
%             %lower(settings.averaging(1))=='f' || lower(settings.averaging(1)) == 'n'
%             %xtlbl{end+1} = ['\sffamily\begin{tabular}{c} Day' num2str((d/dayLength)+1) ' \\ ZT0\end{tabular}'];
%             %xtlbl{end+1} = ['\sffamily\begin{tabular}{c} Day' num2str((d/dayLength)+1) ' \\ ZT' num2str(lightHours) '\end{tabular}'];
%             if d/dayLength >= numel(obj.Days)
%                 xtlbl{end+1} = '';
%             else
%                 xtlbl{end+1} = ['\sffamily\selectfont' num2str(obj.Days((d/dayLength) + 1))];
%             end
%             xlabel('Day');
%             xtlbl{end+1} = '';
%             %xtickangle(ax, 45);
%         else
%             xtlbl{end+1} = '\sffamily\selectfont ZT0';
%             xtlbl{end+1} = ['\sffamily\selectfont ZT' num2str(lightHours)];
%         end
%     else
%         rectangle(ax, 'Position', [lightStart+lightHours+d  ymin lightHours abs(ymin)], 'facecolor','k');
%         xtk(end+1:end+2) = [d+lightStop d+mod(lightStart, dayLength)];
%         if obj.AveragingMode == Averaging.Flies || obj.AveragingMode == Averaging.None
%             %lower(settings.averaging(1))=='f' || lower(settings.averaging(1)) == 'n'
%             xtlbl{end+1} = ['\sffamily\begin{tabular}{c} Day' num2str((d/dayLength)+1) ' \\ ZT' num2str(lightStop) '\end{tabular}'];
%             xtlbl{end+1} = ['\sffamily\begin{tabular}{c} Day' num2str((d/dayLength)+1) ' \\ ZT' num2str(mod(lightStart,dayLength)) '\end{tabular}'];
%         else
%             xtlbl{end+1} = ['\sffamily ZT' num2str(lightStop)];
%             xtlbl{end+1} = ['\sffamily ZT' num2str(mod(lightStart,dayLength))];
%             
%         end
%     end
% end

% Set the y-axis range with the limits calculated above
ylim(ax, [ymin ymax]);

xlim([0 max(binCtrs + (binSize/60)/2)]);
if abs(lightStart - lightStop) ~= dayLength
    set(ax, 'xtick', xtk, 'xticklabel', xtlbl, 'ticklabelinterpreter', 'latex');
    %xticks(ax, xtk); % [lightStart lightStop])
    %xticklabels(ax, xtlbl); %{'ZT0' ['ZT' num2str(lightHours)]})
end

if obj.IsSleep
    ylabel('Sleep (minutes)');
else
    if obj.NormalizeActivity
        ylabel('Activity (beam crosses/total)');
    else
        ylabel('Activity (beam crosses/min)');
    end
end

title({obj.Title; plotSettings.boardAndChannel});
if obj.IsSleep
    filePrefix = 'SleepAnalysis_';
else
    filePrefix = 'ActivityAnalysis_';
    if obj.NormalizeActivity
        filePrefix = ['Normalized' filePrefix];
    end
end
filename = replace([filePrefix plotTitle '_' datestr(now, 'yyyymmdd_HHMM') '.fig'], ' ', '_');