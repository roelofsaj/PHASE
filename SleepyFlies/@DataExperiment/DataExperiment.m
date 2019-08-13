classdef DataExperiment < DataRaw & matlab.mixin.Copyable
    
    properties (SetAccess = protected)
        % These are the experiment-related parameters, describing how the
        % experiment was actually run and data collected. These describe
        % real physical conditions during the experiment.
        DayLength % length of a day in hours
        LightsOn % lights on time in hours (experiment start = 0)
        LightHours % lights off time in hours
        ExpStart % datetime object of time 0 on Day 1
    end
    
    properties (Dependent = true)
        IntervalsPerDay
        ExperimentData
    end
    
    methods
        function obj = DataExperiment(varargin) %folderIn, runNameIn, channelsIn, boardsIn, ...
                %lightsOn, lightHours, dayLength, expStart)
            % Add some error checking here, like for valid folder name and
            % whether files are found
            obj@DataRaw(varargin{:});
            if nargin>0
                obj.LightsOn = varargin{5};%lightsOn;
                obj.LightHours = varargin{6};%lightHours;
                obj.DayLength = varargin{7};%dayLength;
                expStart = varargin{8};
                if expStart < obj.DataStart
                    error('SleepyFlies:invalidExpStart', ...
                        'Error: Invalid experiment start time specified. The specified time is before the data collection start time.');
                elseif obj.findBinByDatetime(expStart) > size(obj.FileData, 1)
                    error('SleepyFlies:invalidExpStart', ...
                        'Error: Invalid experiment start time specified. The specified time is after the data file ends.');
                else
                    obj.ExpStart = expStart;
                end
            end
        end
        
        function dataOut = get.ExperimentData(obj)
            dataOut = obj.getData();
        end
              
        function intsPerDay = get.IntervalsPerDay(obj)
            % Find the number of intervals (data points) per day (60 is 60
            % minutes/hour, since days are specified in minutes and day length in hours)
            intsPerDay = 60 * obj.DayLength / obj.DataInterval;
        end
    end
    
    methods 
        function dataOut = getData(obj)
            % This overrides RawData's getData function, called from
            % get.Data(obj)
            % Return points starting at the experiment start time.
            startBin = obj.findBinByDatetime(obj.ExpStart);
            dataOut = obj.FileData(startBin:end, :, :);
        end
                      
    end
    
    methods (Static)
        function [dateStr, timeStr] = getExperimentDate(filename)
            try
                fid = fopen(filename);
                line = fgetl(fid);
                dateStr = regexpi(line, '[\w\d]+ +(\d+ +\w+ +\d+)', 'tokens');
                dateStr = replace(dateStr{1}, ' ', '-');
                % time should be in line 4
                for i = 2:4
                    timeStr = fgetl(fid);
                end
                timeStr = [timeStr(1:2) ':' timeStr(3:4)];
                fclose(fid);
            catch
                dateStr = [];
                timeStr = [];
            end
        end
        
    end
    
    methods (Access = 'private')
             
        function binCount = binsPerDay(obj, binSizeMinutes)
            binCount = (obj.DayLength * 60) / binSizeMinutes;
        end
        
    end %methods
    
end %classdef