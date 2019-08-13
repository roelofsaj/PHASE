classdef MultiPlots < handle
% Plotting wrapper class to put multiple plots from
% different plotting function calls all on the same page
    properties (SetAccess = private)
        Rows = 3
        Cols = 4
        SavePlots = false
        Filename = ''
        TotalPlots = 0
        pIdx
        startNewPage = true
    end
    
    properties (Dependent = true)
        PlotsPerPage
    end
    
    methods
        function obj = MultiPlots(varargin)
            % MultiPlots('rows', 5, 'cols', 5, ...
            %            'save', true, 'file', filename, ...
            %            'totalPlots', plotCount)
            %    OR
            % MultiPlots() to use default rows/cols/save settings
            %  (default rows=3, cols=4, save=false)
            % Optionally specify 'totalPlots' to indicate the total number
            %   of plots to be included in the set; if this is indicated, the
            %   'lastPlot' input of the plotting function doesn't need to be
            %   specified to save the final page of plots.
            p = inputParser();
            p.addParameter('rows', obj.Rows, @(x) isnumeric(x) && x>0);
            p.addParameter('cols', obj.Cols, @(x) isnumeric(x) && x>0);
            p.addParameter('save', obj.SavePlots, @(x) islogical(x) || (isnumeric(x) && (x==0 || x==1)));
            p.addParameter('totalPlots', obj.TotalPlots, @isnumeric);
            p.parse(varargin{:})
            obj.Rows = p.Results.rows;
            obj.Cols = p.Results.cols;
            obj.SavePlots = p.Results.save;
            obj.TotalPlots = p.Results.totalPlots;
            obj.pIdx = 1;
            obj.startNewPage = true;
        end
        
        function plotsPerPage = get.PlotsPerPage(obj)
            plotsPerPage = obj.Rows * obj.Cols;
        end
        
        function [fhOut, varargout] = doPlots(obj, fhIn, plotFunc, plotSettings, plotData)
        % fhOut = plotObj.doPlots(fhIn, plotFunc)
        % Inputs:
        %   plotFun - function handle for a plotting function that takes
        %             two inputs, plotData and plotSettings, and returns
        %             two outputs, fhOut (figure handle) and filename to
        %             save plot file
        %   fhIn - figure handle of the current plot figure (fhOut from
        %          previous call to this function or [])
        %   plotSettings - see other plotSettings inputs in this project
        %   plotData - data to be plotted, see other plotData inputs in
        %              this project
            if obj.pIdx>2 && obj.SavePlots
                % If we're past the first plot & are saving them, don't
                % display the rest of the plots
                plotSettings.plotVisible = 'off';
            else
                % If we're on the first couple plots or aren't saving, make them
                % visible.
                plotSettings.plotVisible = 'on';
            end

            if obj.PlotsPerPage > 1 
                if mod(obj.pIdx-1, prod(obj.PlotsPerPage)) == 0 || ...
                        obj.startNewPage
                    plotSettings.fh = figure('visible',plotSettings.plotVisible,...
                        'units','normalized','outerposition',[0 0 .9 .9], ...
                        'papertype', 'usletter', 'paperunits', 'inches', ...
                        'paperposition', [.5 .5 10 7.5], 'paperorientation', 'landscape');
                    obj.startNewPage = false;
                else
                    plotSettings.fh = fhIn;
                end
                subplotIdx = mod(obj.pIdx,obj.PlotsPerPage);
                if subplotIdx == 0
                    subplotIdx = obj.Rows * obj.Cols;
                end

                plotSettings.ax = subplot(obj.Rows, obj.Cols, subplotIdx,'parent',plotSettings.fh);
            else
                plotSettings.fh = figure('visible',plotSettings.plotVisible,...
                    'units','normalized','outerposition',[0 0 .9 .9], ...
                    'papertype', 'usletter', 'paperunits', 'inches', ...
                    'paperposition', [.5 .5 10 7.5], 'paperorientation', 'landscape');
                plotSettings.ax = axes(plotSettings.fh);
            end

            % [fhOut, filename [,latency, intensity]] = plotFun(plotData(:,:,pIdx), plotSettings);
            [fhOut, filename, out1, out2, out3] = plotFunc(plotData, plotSettings);
            varargout{1} = out1;
            varargout{2} = out2;
            varargout{3} = out3;
            % This could probably be improved. The latency plot function
            % also returns two informational fields, so pass those along.

            obj.Filename = filename; % Save this to use later
             
            if obj.SavePlots && ...
                (obj.PlotsPerPage == 1 ||... % single plot OR
                mod(obj.pIdx, obj.PlotsPerPage)==0  || ... % this was the last plot on the page OR
                obj.pIdx == obj.TotalPlots) % this was the last plot in the series
                obj.saveAndClose(fhOut);
            end
            obj.pIdx = obj.pIdx + 1;
        end
        
        function closePlots(obj, fhIn)
            % That was all the plots, so save and close figure as required
            % First make sure the figure still exists
            if isgraphics(fhIn)
                obj.saveAndClose(fhIn);
            end        
        end        
    end
    
    methods (Access = 'private')
        
        function saveAndClose(obj, fh)
                pageNum = ceil(obj.pIdx/obj.PlotsPerPage);
                wasVisible = get(fh, 'visible');
                if obj.PlotsPerPage > 1 && obj.SavePlots
                    set(fh,'visible','on');
                    filename = replace(obj.Filename, '.fig', ['_' num2str(pageNum) '.fig']);
                    saveas(fh, filename, 'fig');
                end
                if strcmpi(wasVisible,'off')
                    close(fh);
                end
                obj.startNewPage = true;
        end
        
    end
    
    
end
