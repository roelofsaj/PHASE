function averagedData = calcAveraged(obj, dataIn)
% calcAveraged: 
% 
% Usage: (where obj is an object of class DataForAnalysis)
%   dayData = obj.calcAveraged(dataIn, );
% 
% Inputs:
%   dataIn - 
%  
% Outputs:
%   averagedData [MxOxP int] - 


% These variables just make the code easier to read
AVG_NONE = obj.AveragingMode == Averaging.None;
AVG_DAYS = obj.AveragingMode == Averaging.Days;
AVG_FLIES = obj.AveragingMode == Averaging.Flies;
AVG_BOTH = obj.AveragingMode == Averaging.Both;

% Average the data before returning
% If the data was being averaged by flies or both, after averaging the
% columns will already be bins.
if AVG_FLIES || AVG_BOTH
    averagedData = squeeze(mean(dataIn,1));
elseif AVG_DAYS || AVG_NONE
    % If averaging was by days, after averaging the columns are bins, but the flies
    % are all different layers, so switch the first & last dimension to make
    % each fly a row.
    averagedData = permute(mean(dataIn,1), [3 2 1]);
end

% Convert to a table, so it's easy to read
averagedData = array2table(averagedData, 'VariableNames', ...
    strcat('t_', strip(cellstr(num2str(obj.ColumnLabels')))', 'min'), ...
    'RowNames', obj.RowLabels);



