classdef DataForAnalysisSmoothed < DataForAnalysis
    properties (SetAccess=protected)
        FilterOrder
        FilterFrameLength
        SmoothedData % derived from AveragedData or NormalizedAveragedData 
                     % (which means it's day-centered)
    end
    
    methods
        function obj = DataForAnalysisSmoothed(varargin)
            %There must be a better way to dole these inputs out to the
            %different class levels
            obj = obj@DataForAnalysis(varargin{:});
            p = inputParser;
            p.addParameter('filterOrder', 3, @isnumeric);
            p.addParameter('frameLength', 9, @isnumeric);
            p.KeepUnmatched = true;
            p.parse(varargin{2:end});
            obj.FilterOrder = p.Results.filterOrder;
            obj.FilterFrameLength = p.Results.frameLength;
            obj.AveragingMode = Averaging.Days;
            obj.BinSize = obj.DataInterval;
            
            if license('test','Signal_Toolbox')
                if ~obj.IsSleep && obj.NormalizeActivity
                    data = obj.NormalizedAveragedData;
                else
                    data = obj.AveragedData;
                end
                if istable(data)
                    data = table2array(data);
                end
                obj.SmoothedData = sgolayfilt(data,obj.FilterOrder,obj.FilterFrameLength,[],2);
            else
                msgbox('Skipping filtered calculations because the MATLAB Signal Processing Toolbox is not installed.',...
                    'Signal Processing Toolbox Not Found');
            end
        end
                
        
    end
end