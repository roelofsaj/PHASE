function cellsOut = table2labeledcells(tableIn)
%TABLE2LABELEDCELLS Convert table to cell array, retaining row & column labels
%
if isa(tableIn, 'table')
    cellsOut = table2cell(tableIn);
    % Add the column names
    if ~isempty(tableIn.Properties.VariableNames)
        cellsOut = [tableIn.Properties.VariableNames; cellsOut];
    end
    % And the row names
    if ~isempty(tableIn.Properties.RowNames)
        if ~isempty(tableIn.Properties.VariableNames)
            cellsOut = [[{' '}; tableIn.Properties.RowNames] cellsOut];
        else
            cellsOut = [tableIn.Properties.RowNames cellsOut];
        end
    end
else
    error('Invalid input type.')
end

