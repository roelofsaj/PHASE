classdef DataForAnalysisPhase < DataForAnalysisSmoothed
    properties (SetAccess=protected)
        MinPeakDist
        PhaseZT
        Peaks
    end
    
    methods
        function obj = DataForAnalysisPhase(varargin)
            %There must be a better way to dole these inputs out to the
            %different class levels
            obj = obj@DataForAnalysisSmoothed(varargin{:});
            p = inputParser;
            p.KeepUnmatched=true;
            p.addParameter('minPeakDist', 30, @isnumeric);
            p.addParameter('phaseZT', [], @isnumeric); 
            p.parse(varargin{2:end});
            obj.MinPeakDist = p.Results.minPeakDist;
            obj.PhaseZT = p.Results.phaseZT;
            
            obj.PlotFunction = {@obj.plotPhase};
            if ~obj.IsSleep && obj.NormalizeActivity
                % For activity data, plots should be done with normalized
                % data. This is only for averaged analysis; normalized
                % analysis does its own separate normalization.
                obj.PlotData = obj.NormalizedPlotData;
            end
        end
        
        
        function writeDataToFile(obj, folderOut)
            calcPhase(obj);
            %writePhaseData originally wrote every peak to a new line, but
            %Jenna requested that each fly's data be interleaved on a
            %single line. Instead of completely getting rid of the option
            %to do it the old way, the 'byRows' input allows selecting
            %which of these was to write the output (byRows=true writes all
            %data for a fly on a single row).
            obj.writePhaseData('folderOut', folderOut,'byRows',true);
        end
        
        % function plotData(obj, plotSettings)
        % Default superclass function should work here, I think       
        
    end
    
end