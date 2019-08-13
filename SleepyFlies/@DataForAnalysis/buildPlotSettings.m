function plotSettings = buildPlotSettings(obj, varargin)
%buildPlotSettings: Compile relevant object properties into a structure
% 
% plotSettings = obj.buildPlotSettings();
% plotSettings = obj.buildPlotSettings('errorFunction', errorFunction);
% plotSettings = obj.buildPlotSettings('plotLabel', plotLabel);
%
% Inputs:
%   errorFunction: function handle with function to use in calculating
%                  error for error bars (optional)
%   plotLabel: second line of the plot title (for example,
%              a string containing the board & channel of the data)
%              (optional)
plotSettings.binCtrs = obj.BinCenters;
plotSettings.dayLength = obj.DayLength;
plotSettings.lightStart = obj.AnalysisLightStart;
plotSettings.lightStop = obj.AnalysisLightStop;
plotSettings.lightHours = obj.LightHours;
plotSettings.dayCount = obj.AnalysisOutputDays;
plotSettings.binSize = obj.BinSize;
plotSettings.title = obj.Title;
p = inputParser;
addParameter(p, 'errorFunction', []);
addParameter(p, 'plotLabel', []);
parse(p, varargin{:});
plotSettings.errorFunction = p.Results.errorFunction;
plotLabel = p.Results.plotLabel;
if ~isempty(plotLabel)
    plotSettings.title = {plotSettings.title; plotLabel};
end
if obj.isSleep
    plotSettings.filePrefix = 'SleepAnalysis_';
    plotSettings.yLabel('Sleep (minutes)');
else
    plotSettings.filePrefix = 'ActivityAnalysis_';
    plotSettings.yLabel('Activity (arbitrary units)');
end

end

