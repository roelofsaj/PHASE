classdef DataRaw < matlab.mixin.Copyable
    properties (SetAccess = protected)
        % This describes what data we have here.
        DataFolder
        RunName % expected base file name of data files
        Channels
        Boards
        DataInterval % data collection interval (dci) in minutes
        DataStartDate % experiment start date as in file
        DataStartTime % experiment start time as in file
        DataStart % datetime object representing data start
        FileData
    end
    
    methods
        function obj = DataRaw(varargin) %(folderIn, runNameIn, channelsIn, boardsIn)
            % Add some error checking here, like for valid folder name and
            % whether files are found
            if nargin > 0
                obj.DataFolder = varargin{1}; %folderIn;
                obj.RunName = varargin{2}; %runNameIn;
                obj.Channels = varargin{3}; %channelsIn;
                obj.Boards = varargin{4}; %boardsIn;
                % Read the raw data from files. This also gets the data
                % collection interval (referred to throught this code as dci,
                % to avoid confusion with the term "bins" as used in analysis).
                obj.importFlyData();
            end
        end
        
        function dataOut = getData(obj) 
            dataOut = obj.FileData;
        end
                
        importFlyData(obj)
                
    end %methods
    
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
end %classdef