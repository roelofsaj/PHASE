classdef PageMultiPlots < handle
% Plotting wrapper class to put multiple plots from
% different plotting function calls all on the same page
    properties (SetAccess = private)
        Rows = 3
        Cols = 4
        SavePlots = false
        Filename = ''
        FolderOut = ''
        TotalPlots = 0
        pIdx
        startNewPage = true
    end
    
    properties (Dependent = true)
        PlotsPerPage
    end
    
    methods
        function obj = PageMultiPlots(varargin)
            % PageMultiPlots('rows', 5, 'cols', 5, ...
            %            'save', true, 'file', filename, ...
            %            'totalPlots', plotCount)
            %    OR
            % PageMultiPlots() to use default rows/cols/save settings
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
            p.addParameter('folderOut', '');
            p.parse(varargin{:})
            obj.Rows = p.Results.rows;
            obj.Cols = p.Results.cols;
            obj.SavePlots = p.Results.save;
            obj.TotalPlots = p.Results.totalPlots;
            obj.pIdx = 1;
            obj.startNewPage = true;
            obj.FolderOut = p.Results.folderOut;
        end
        
        function plotsPerPage = get.PlotsPerPage(obj)
            plotsPerPage = obj.Rows * obj.Cols;
        end
        
        function [fhOut, ax, filename] = doPlots(obj, fhIn, plotFunc, plotSettings)
        % fhOut = plotObj.doPlots(fhIn, plotFunc)
        % Inputs:
        %   plotFun - function handle for a plotting function that takes
        %             two inputs, plotData and plotSettings, and returns
        %             three outputs, fhOut (figure handle), ax (axix), and filename to
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
            
            [fhOut, ax, filename] = plotFunc(plotSettings);
            obj.Filename = filename; % Save this to use later
             
            if obj.SavePlots && ...
                (obj.PlotsPerPage == 1 ||... % single plot OR
                mod(obj.pIdx, obj.PlotsPerPage)==0  || ... % this was the last plot on the page OR
                obj.pIdx == obj.TotalPlots) % this was the last plot in the series
                obj.saveAndClose(fhOut);
            end
            obj.pIdx = obj.pIdx + 1;
        end
        
        function savePlotPage(obj, fh)
            % Check if this is the end of a page, and if so save and close
            % it, regardless of obj.SavePlots setting. 
            % This provides a way to change the plots after the main plot
            % function is called while still closing, saving, and starting
            % new figures correctly
            % obj.pIdx will always be referring to the next plot to come,
            % so we need to use the previous pIdx to do the checks here.
            obj.pIdx = obj.pIdx - 1;
            if (obj.PlotsPerPage == 1 ||... % single plot OR
                mod(obj.pIdx, obj.PlotsPerPage)==0  || ... % this was the last plot on the page OR
                obj.pIdx == obj.TotalPlots) ...% this was the last plot in the series
                && isgraphics(fh) % AND it wasn't already closed.
                obj.saveAndClose(fh);
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
                %if obj.PlotsPerPage > 1 && obj.SavePlots
                if obj.SavePlots
                    set(fh,'visible','on');
                    filename = replace(obj.Filename, '.fig', ['_' num2str(pageNum) '.fig']);
                    filename = fullfile(obj.FolderOut, filename);
                    saveas(fh, filename, 'fig');
                    set(fh, 'renderer', 'painters');
                    set(fh, 'papersize', [17 11]);
                    print(fh, strrep(filename,'.fig', '.pdf'),'-dpdf', '-r0', '-fillpage');
                end
                if strcmpi(wasVisible,'off')
                    close(fh);
                end
                obj.startNewPage = true;
        end
        
    end
    
    
end
