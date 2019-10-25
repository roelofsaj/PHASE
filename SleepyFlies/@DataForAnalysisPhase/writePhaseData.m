function outfile = writePhaseData(obj, varargin)
% Write the latency data from the educer to an Excel file
% This has quite a bit of overlap with writeEducerData.m

p = inputParser;
p.addParameter('outfile', []);
p.addParameter('folderOut', []);
p.addParameter('byRows', false);
p.parse(varargin{:});
outfile = p.Results.outfile;
folderOut = p.Results.folderOut;
byRows = p.Results.byRows;

peakList = obj.Peaks;

title = obj.Title;
if ~isempty(outfile)
    outfile = varargin{1};
else
    if obj.IsSleep
        filename = 'SleepPhase_';
        desc = 'Sleep';
    else
        filename = 'ActivityPhase_';
        if obj.NormalizeActivity
            filename = ['Normalized'  filename];
        end
        desc = 'Activity';
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
dispSettings.PhasePeakMinDist = obj.MinPeakDist;
if numel(obj.Days) == 1
    dprefix = ['Day ' num2str(obj.Days(1)) ' '];
else
    dprefix = '';
end
sheetName = [dprefix 'Phase'];

warning('off', 'xlwrite:AddSheet');
warning('off', 'MATLAB:xlswrite:AddSheet');
if byRows 
    peaksOut = {};
else
    peaksOut = [];
end
for i = 1:numel(peakList)
    if byRows 
        if size(peakList(i).timeZT, 1)>=1
            % Build the info for this fly: time, peaks, area under curve
            flyPeaks = [obj.PhaseZT' peakList(i).timeZT peakList(i).peaks peakList(i).auc];
        else
            flyPeaks = [zeros(size(peakList(i).timeZT,1)) peakList(i).timeZT peakList(i).peaks peakList(i).auc];
        end
        % Peaks will be in order by occurrence time but will be output in
        % reverse occurence time. Loop through in reverse order. 
        flyPeaks = sortrows(flyPeaks, 'descend'); 
        % Note that we have to add the selected ZT for sorting and then remove
        % it to prevent inclusion in the output spreadsheet. Otherise
        % the above sortrows doesn't work when ZT0 is selected, since peaks
        % associated with ZT0 can occur at ZT23.xx and would be sorted
        % incorrectly.
        flyPeaks = flyPeaks(:,2:end);
        % Convert to a single row
        flyPeaks = reshape(flyPeaks', 1, numel(flyPeaks));
        % Conver to a cell array
        flyPeaks = num2cell(flyPeaks);
        flyPeaks = [{peakList(i).rowLabel} flyPeaks];
        peaksOut(i,1:size(flyPeaks,2)) = flyPeaks;
    else
        % Build the output data array, one fly at a time
        % Each fly has multiple latencies, which means multiple rows. 
        % Use num2cell to put all the colums together correctly, and then label
        % only the first row of this set with the fly information.
        peaksOut = [peaksOut ;...
            cell(size(peakList(i).peaks,1),1) ...
            num2cell(peakList(i).timeZT) ...
            num2cell(peakList(i).peaks)...
            num2cell(peakList(i).auc)];
        peaksOut{end-size(peakList(i).peaks,1)+1,1} = peakList(i).rowLabel;
    end
end
if byRows
    % In this case we get empty spaces from different numbers of peaks per
    % fly, so just leave them blank.
    blanksValue = {' '};
else
    % In this case blanks mean something was undefined, so use that
    % instead.
    blanksValue = {'Undefined'};
end
%Replace empty values with "Undefined"
replace_empty = cellfun(@isempty, peaksOut(:, 2:end));
replace_empty = [false(size(replace_empty,1),1) replace_empty];
peaksOut(replace_empty) = {inf};
%Replace infinite values with "Undefined"
replace_inf = cellfun(@isinf, peaksOut(:,2:end)); %2:end because the first column isn't numeric and throws an error
replace_inf = [false(size(replace_inf,1),1) replace_inf];
peaksOut(replace_inf) = blanksValue;

% Add column headers
if byRows
    cols = [{'Peak Time (ZT)'} ...
        {'Peak Height'} ...
        {'Peak Area'}]; 
    % Now repeat those as many times as we have columns of data (minus one,
    % for the first column containing the fly label)
    colCount = size(peaksOut,2) - 1;
    cols = repmat(cols, 1, colCount/3);
    peaksOut = [{' '} cols; peaksOut];
else
    peaksOut = [{' '} ...
        {'Peak Time (ZT)'} ...
        {'Peak Height'} ...
        {'Peak Area'}; 
        peaksOut];
end
peaksOut(cellfun(@isempty, peaksOut)) = {' '};
xlfunc(outfile, peaksOut, sheetName);

xlfunc(outfile, [fieldnames(dispSettings) struct2cell(dispSettings)], 'Settings');
warning('on', 'xlwrite:AddSheet');
warning('on', 'MATLAB:xlswrite:AddSheet');



