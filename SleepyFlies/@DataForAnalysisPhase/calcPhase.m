function calcPhase(obj)
% calcLatencies: Calculate latency or anticipation.

% Find peaks in data: minute bin converted to ZT, and area under curve
flyCount = size(obj.SmoothedData,1);
peaks(flyCount).rowLabel = [];
peaks(flyCount).locs = [];
peaks(flyCount).auc = [];
peaks(flyCount).time = []; % Time relative to the plotted x-axis (first bin is 0, regardless of day-centering ZT shift)
peaks(flyCount).timeZT = []; % Time for each peak, ZT-shifted. For labeling, not plotting.
peaks(flyCount).widths = [];
peaks(flyCount).peaks = [];
peaks(flyCount).extentsBins = []; % Extent of peaks, in bin units
peaks(flyCount).extentsTime = []; % Extent of peaks, in time units relative to x-axis (not ZT)

% For each fly, find peaks & related information
for flyIdx = 1:flyCount 
    [pks, locs, width, ~] = findpeaks(obj.SmoothedData(flyIdx,:), ...
                                    'MinPeakDistance', obj.MinPeakDist,...
                                    'MinPeakHeight', 0);
    % Originally this was sorting peaks by descending height
    %                                'SortStr', 'descend',...
    % For each peak, calculate peak extents based on peak width, as well as
    % area under the curve at the peak between the extents.
    auc = zeros(numel(pks),1);
    extents = zeros(numel(pks), 2);
    for p = 1:numel(pks)
        % Find the indices of the peak extents, with width w centered on the peak
        halfWidth = round(width(p)/2);
        extents(p,:) = [locs(p)-halfWidth locs(p)+halfWidth];
        % Make sure indices are > 1 and < data length
        extents(p,:) = max(extents(p,:), 1);
        extents(p,:) = min(extents(p,:), size(obj.SmoothedData(flyIdx,:),2));
        % Calculate area under the curve at of this peak
        pkData = obj.SmoothedData(flyIdx, extents(p,:));
        auc(p) = trapz(pkData);
    end
    peaks(flyIdx).auc = auc;
    peaks(flyIdx).peaks = pks';
    peaks(flyIdx).locs = locs';
    peaks(flyIdx).widths = width';
    
    % convert locs (an index of dataintervals) to time relative to x-axis
    peaks(flyIdx).time = locs' / (60/obj.BinSize);
    % To find the time in ZT, shift so light start is 0 and wrap to day length
    peaks(flyIdx).timeZT = mod(peaks(flyIdx).time-obj.AnalysisLightStart, obj.DayLength);
    % also convert extents to ZT, since after the AUC calculation it's only
    % useful for plotting
    peaks(flyIdx).extentsBins = extents;
    peaks(flyIdx).extentsTime = extents / (60/obj.BinSize);
    % obj.BinSize should be obj.DataInterval here, but just in case it's not, this would more accurately reflect the data. 
    peaks(flyIdx).rowLabel = obj.RowLabels{flyIdx};
    if ~isempty(obj.PhaseZT)
       % If ZTs were entered for phase, find the closest peak to each ZT.
       % First find how far each peak is from each ZT: 
       % each column in peakDist represent the distance from each peak
       % (row) to an entered ZT (column).
       peakDist = repmat(peaks(flyIdx).timeZT, 1, size(obj.PhaseZT,2)) - repmat(obj.PhaseZT, size(peaks(flyIdx).timeZT,1),1);
       % It doesn't matter if the peak is before or after the selected ZT
       peakDist = abs(peakDist);
       % Also account for peaks that are close to a low ZT, but from the
       % side of the hight ZT (eg. a peak at ZT 23.5 is close to ZT 0)
       wrapDist = obj.DayLength-peakDist;
       peakDist = min(wrapDist,peakDist);
       % Find the closest peak to each ZT and its index in the peak list
       [peakDist, idx] = min(peakDist);
       % Keep only these closest-to-ZTs peaks 
       peaks(flyIdx).locs = peaks(flyIdx).locs(idx);
       peaks(flyIdx).auc = peaks(flyIdx).auc(idx);
       peaks(flyIdx).time = peaks(flyIdx).time(idx);
       peaks(flyIdx).timeZT = peaks(flyIdx).timeZT(idx);
       peaks(flyIdx).widths = peaks(flyIdx).widths(idx);
       peaks(flyIdx).peaks = peaks(flyIdx).peaks(idx);
       peaks(flyIdx).extentsBins = peaks(flyIdx).extentsBins(idx,:);
       peaks(flyIdx).extentsTime = peaks(flyIdx).extentsTime(idx,:);
    end
end

obj.Peaks = peaks;
end
