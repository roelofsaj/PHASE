function outfile = writeExperimentData(obj, stats, averagedData, varargin)
% Write the data from the educer to an Excel file
p = inputParser;
p.addParameter('outfile', []);
p.addParameter('folderOut', []);
p.addParameter('rawData', false);
p.parse(varargin{:});
outfile = p.Results.outfile;
rawData = p.Results.rawData;
folderOut = p.Results.folderOut;
title = obj.Title;

if isempty(outfile)
    if obj.IsSleep
        filename = 'SleepAnalysis_';
    else
        filename = 'ActivityAnalysis_';
        if obj.NormalizeActivity
            filename = ['Normalized' filename];
        else 
            filename = ['Averaged' filename];
        end
    end
    filename = [filename title '_' datestr(now, 'yyyymmdd_HHMM')];

    outfile = fullfile(folderOut, [filename '.xlsx']);
end

if ispc
    xlfunc = @xlswrite;
else
    xlfunc = @xlwrite;
end

dispSettings.days = num2str(obj.Days);
dispSettings.Channels = strcat('M', arrayfun(@(x) sprintf("%03d", x), obj.Boards'), 'C', arrayfun(@(x) sprintf("%02d", x), obj.Channels'));
dispSettings.Channels = strjoin(dispSettings.Channels, ',');
dispSettings.ZeitgeberOn = obj.LightsOn;
dispSettings.ZeitgeberHours = obj.LightHours;
dispSettings.DayLength = obj.DayLength;
dispSettings.ExpStart = datestr(obj.ExpStart, 'yyyy-mmm-dd HH:MMSS');
dispSettings.RunName = obj.RunName;
dispSettings.DataFolder = obj.DataFolder;
if numel(obj.Days) == 1
    dprefix = ['Day ' num2str(obj.Days(1)) ' '];
else
    dprefix = '';
end
if rawData
    statName = 'Statistics (Raw)';
    dataSheet = [dprefix 'BinnedData (Raw)'];
else
    statName = 'Statistics';
    dataSheet = [dprefix 'BinnedData'];
end

warning('off', 'xlwrite:AddSheet');
warning('off', 'MATLAB:xlswrite:AddSheet');
stats = table2labeledcells(stats);

if numel(obj.Days) > 1
    % Don't include the extra label or do averaging if there's only day of data
    statType = 'Summed';
else
    statType = '';
end
statSheet = [dprefix statType statName];
xlfunc(outfile, stats, statSheet);
% Also output a sheet with the statistics averaged by day... 
% This pretty much just means summing & dividing by the number of days.
if numel(obj.Days) > 1
    statType = 'DayAvg';
    statSheet = [dprefix statType statName];
    avgStats = cell2mat(stats(2:end, :));
    avgStats(:, 3:end) = avgStats(:,3:end)/numel(obj.Days);
    avgStats = [stats(1,:); num2cell(avgStats)];
    xlfunc(outfile, avgStats, statSheet);
end
averagedData = table2labeledcells(averagedData)';
% The lab orginally wanted data in rows, so that's how everything was
% written... However, at some point they decided columns would be better,
% so transpose the table here before exporting.

xlfunc(outfile, averagedData, dataSheet);
if ~rawData || obj.IsSleep
    xlfunc(outfile, [fieldnames(dispSettings) struct2cell(dispSettings)], 'Settings');
end
warning('on', 'xlwrite:AddSheet');
warning('on', 'MATLAB:xlswrite:AddSheet');



