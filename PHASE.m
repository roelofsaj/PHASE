function varargout = PHASE(varargin)
% PHASE MATLAB code for PHASE.fig
%      PHASE, by itself, creates a new PHASE or raises the existing
%      singleton*.
%
%      H = PHASE returns the handle to a new PHASE or the handle to
%      the existing singleton*.
%
%      PHASE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHASE.M with the given input arguments.
%
%      PHASE('Property','Value',...) creates a new PHASE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PHASE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PHASE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PHASE

% Last Modified by GUIDE v2.5 18-Jul-2019 16:12:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PHASE_OpeningFcn, ...
    'gui_OutputFcn',  @PHASE_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PHASE is made visible.
function PHASE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PHASE (see VARARGIN)

% add the SleepyFlies and SupportFiles folders to the path
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(fullfile(folder, 'SleepyFlies')));
addpath(genpath(fullfile(folder, 'SupportFiles')));

% Populate the board list
boards = 1:300;
boards = arrayfun(@(x) sprintf("%03d", x), boards');
set(handles.lstBoards, 'String', boards);
channels = 1:32;
channels = arrayfun(@(x) sprintf("%02d", x), channels');
set(handles.lstChannels, 'String', channels);

%Initialize the SleepyFlies class variable and data folder to empty 
handles.sf = [];
handles.dataFolder = [];

% Initialize the active panel
handles.activePanel = 'Analysis';

% Choose default command line output for PHASE
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% If we're on a Mac, make sure the poi libraries are on the java class path
if ~ispc
    % Add Java POI Libs to matlab javapath if necessary
    if exist('org.apache.poi.ss.usermodel.WorkbookFactory', 'class') ~= 8 ...
            || exist('org.apache.poi.hssf.usermodel.HSSFWorkbook', 'class') ~= 8 ...
            || exist('org.apache.poi.xssf.usermodel.XSSFWorkbook', 'class') ~= 8
        appdir = fileparts(mfilename('fullpath'));
        javaaddpath(fullfile(appdir, 'poi_library/poi-3.8-20120326.jar'));
        javaaddpath(fullfile(appdir, 'poi_library/poi-ooxml-3.8-20120326.jar'));
        javaaddpath(fullfile(appdir, 'poi_library/poi-ooxml-schemas-3.8-20120326.jar'));
        javaaddpath(fullfile(appdir, 'poi_library/xmlbeans-2.3.0.jar'));
        javaaddpath(fullfile(appdir, 'poi_library/dom4j-1.6.1.jar'));
        javaaddpath(fullfile(appdir, 'poi_library/stax-api-1.0.1.jar'));
    end
end

if ~license('test', 'Financial_Toolbox')
    %The calendar UI won't work, so don't show the button
    set(handles.pbExpStart, 'visible', 'off');
end


%% DEBUG Setup
DEBUG = false;
if DEBUG
    set(handles.txtFolderOut, 'string', '/Users/aheinlei/work/mcdb-shafer-sleepyflies/TestOutputsNew');
    pbFolderIn_Callback(hObject, eventdata, handles);
end

if ispc
    fieldList = fieldnames(handles);
    for fIdx = 1:numel(fieldList)
        if isa(handles.(fieldList{fIdx}), 'matlab.ui.control.UIControl')
            try
                if handles.(fieldList{fIdx}).FontSize==10
                    handles.(fieldList{fIdx}).FontSize=8;
                end
            catch
                continue
            end
        end
    end
end


% UIWAIT makes PHASE wait for user response (see UIRESUME)
% uiwait(handles.fig);


% --- Outputs from this function are returned to the command line.
function varargout = PHASE_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% -------------------------------------
%% SleepyFlies Class Object Controls
% -------------------------------------
function txtFolderIn_Callback(hObject, eventdata, handles)
% hObject    handle to txtFolderIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newFolder = get(hObject,'string');
openDataFolder(newFolder, handles);

% --- Executes on button press in pbFolderIn.
function pbFolderIn_Callback(hObject, eventdata, handles)
% Open a file dialog
newFolder = uigetdir();
if newFolder ~= 0 % If the user hit cancel, don't do anything
    set(handles.txtFolderIn, 'String', newFolder);
    openDataFolder(newFolder, handles);
end

function openDataFolder(folderIn, handles)
%import SleepyFlies.*
if ~strcmp(handles.dataFolder, folderIn)
    % If the folder changed, clear the existing SleepyFlies class object,
    % since this is new data.
    handles.sf = [];
    handles.dataFolder = folderIn;
    guidata(handles.pbFolderIn, handles);
    if isfolder(folderIn)
        openDataFolder(folderIn, handles);
    else
        msgbox('Please enter a valid folder path.', 'Invalid path');
        return
    end
    try
        files = dir(folderIn);
        % Try to figure out the file name pattern
        sampleName = [];
        i = 3;  % The first two listed files are likely . and ..
        while isempty(sampleName) && i <= size(files,1)
            if ~files(i).isdir && ~strcmp(files(i).name(1), '.')
                sampleName = files(i).name;
            end
            i = i+1;
        end
        pattern = '(\w+)M\d{3}C\d{2}.*';
        fileString = regexp(sampleName, pattern, 'tokens');
        if ~isempty(fileString)
            set(handles.txtRunName, 'String', fileString{1}{1});
            [boards, channels] = getBoardsAndChannels(fileString{1}{1}, files);
            set(handles.lstBoards, 'string', boards);
            set(handles.lstChannels, 'string', channels);
            % While we're at it, see if we can get a date to start on
            [dateStr, timeStr] = DataRaw.getExperimentDate(fullfile(folderIn, sampleName));
            set(handles.txtExpStartDate, 'String', dateStr);
            set(handles.txtExpStartTime, 'String', timeStr);
        end
    catch ME
        % Ignore it.
    end
end

function [boards, channels] = getBoardsAndChannels(runName, fileList)
fileList = {fileList(:).name};
pattern = '\w+M(\d{3})C(\d{2}).*';
boardsChans = regexp(fileList, pattern, 'tokens');
boardsChans = boardsChans(cellfun(@(x) ~isempty(x), boardsChans));
boardsChans = vertcat(boardsChans{:});
boardsChans = vertcat(boardsChans{:});
boards = unique(boardsChans(:,1));
channels = unique(boardsChans(:,2));

% --- Executes during object creation, after setting all properties.
function txtFolderIn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFolderIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtRunName_Callback(hObject, eventdata, handles)
% If this changes, clear the existing class object
handles.sf = [];
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtRunName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtRunName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in lstBoards.
function lstBoards_Callback(hObject, eventdata, handles)
% hObject    handle to lstBoards (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function lstBoards_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstBoards (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in lstChannels.
function lstChannels_Callback(hObject, eventdata, handles)
% hObject    handle to lstChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function lstChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in lstSelections.
function lstSelections_Callback(hObject, eventdata, handles)
% hObject    handle to lstSelections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function lstSelections_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstSelections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pbAddChannels.
function pbAddChannels_Callback(hObject, eventdata, handles)
% Copy the selected board & channels over to the selected listbox
% Also store them in the handles structure
currentSelected = cellstr(get(handles.lstSelections,'String'));
if ~isempty(currentSelected) && strcmpi(currentSelected{1}, 'Selected Channels')
    currentSelected = {};
end
boardList = cellstr(get(handles.lstBoards,'String'));
selBoards = get(handles.lstBoards,'Value');
selBoardNames = boardList(selBoards);
chanList = cellstr(get(handles.lstChannels,'String'));
selChans = get(handles.lstChannels,'Value');
selChanNames = chanList(selChans);
boardCount = numel(selBoards);
chanCount = numel(selChans);
b = repmat(selBoardNames, 1, chanCount);
c = shiftdim(repmat(selChanNames, 1, boardCount),1);
selectedList = strcat('M', b, '_C', c);
selectedList = sort(reshape(selectedList, [], 1));
set(handles.lstSelections, 'String', unique([currentSelected; selectedList]));

handles.sf = []; % Clear the class object, since something changed
guidata(hObject, handles);

% --- Executes on button press in pbClear.
function pbClear_Callback(hObject, eventdata, handles)
% hObject    handle to pbClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lstSelections,'value',[]);
set(handles.lstSelections, 'String', {'Selected Channels'});

% --- Executes on key press with focus on lstSelections and none of its controls.
function lstSelections_KeyPressFcn(hObject, eventdata, handles)
% If the user selects items and hits backspace or delete, remove them from
% the list.
if strcmpi(eventdata.Key, 'delete') || strcmpi(eventdata.Key, 'backspace')
    % Remove the selected items from the list
    selItems = get(hObject, 'Value');
    if ~isempty(selItems)
        itemList = cellstr(get(hObject, 'String'));
        itemList(selItems) = [];
        set(hObject, 'Value', []);
        set(hObject, 'String', itemList);
        handles.sf = []; % Clear the class object, since something changed
        guidata(hObject, handles);
    end
end


function txtExpStartDate_Callback(hObject, eventdata, handles)
% hObject    handle to txtExpStartDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function txtExpStartDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtExpStartDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pbExpStart.
function pbExpStart_Callback(hObject, eventdata, handles)
%https://www.mathworks.com/help/finance/uicalendar-graphical-user-interface.html#brald_4
% Open a calendar to choose the date
% uicalendar requires Financial Toolbox. If it's not installed, don't try
% this.
if license('test', 'Financial_Toolbox')
    defaultDate = get(handles.txtExpStartDate,'String');
    if ~isempty(defaultDate)
        defaultDate = datetime(defaultDate);
    else
        defaultDate = now;
    end
    uicalendar('SelectionType', 1, 'DestinationUI', handles.txtExpStartDate,...
        'OutputDateFormat', 'dd-mmm-yyyy', 'InitDate', defaultDate);
    % Clear the class variable
    handles.sf = [];
    guidata(hObject, handles);
end

function txtExpStartTime_Callback(hObject, eventdata, handles)
% hObject    handle to txtExpStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Clear the class variable
handles.sf = [];
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtExpStartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtExpStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtDayLength_Callback(hObject, eventdata, handles)
% hObject    handle to txtDayLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Clear the class variable
handles.sf = [];
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtDayLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDayLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtLightsOn_Callback(hObject, eventdata, handles)
% hObject    handle to txtLightsOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.sf = [];
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtLightsOn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLightsOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtLightHours_Callback(hObject, eventdata, handles)
% hObject    handle to txtLightHours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.sf = [];
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtLightHours_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLightHours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% -------------------------------------
%% Educer Settings Controls
% -------------------------------------

% --- Executes on button press in btnAvgFlies.
function btnAvgFlies_Callback(hObject, eventdata, handles)
% hObject    handle to btnAvgFlies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnAvgFlies

% --- Executes on button press in btnAvgNone.
function btnAvgNone_Callback(hObject, eventdata, handles)
% hObject    handle to btnAvgNone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnAvgNone

% --- Executes on button press in btnAvgBoth.
function btnAvgBoth_Callback(hObject, eventdata, handles)
% hObject    handle to btnAvgBoth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnAvgBoth


% --- Executes on button press in btnAvgDays.
function btnAvgDays_Callback(hObject, eventdata, handles)
% hObject    handle to btnAvgDays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnAvgDays

% --- Executes on button press in btnPlotClassic.
function btnPlotClassic_Callback(hObject, eventdata, handles)
% hObject    handle to btnPlotClassic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnPlotClassic

% --- Executes on button press in btnPlotNew.
function btnPlotNew_Callback(hObject, eventdata, handles)
% hObject    handle to btnPlotNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnPlotNew

% --- Executes on button press in btnPlotBoth.
function btnPlotBoth_Callback(hObject, eventdata, handles)
% hObject    handle to btnPlotBoth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnPlotBoth


function txtBinSize_Callback(hObject, eventdata, handles)
cleanIntegerInput(hObject);

function txtBinSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtBinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function txtDays_Callback(hObject, eventdata, handles)
% Replace commas, spaces, semicolons with a single space
cleanNumericListInput(hObject);


%% Input cleaning functions
function cleanIntegerInput(hObject)
n = get(hObject, 'String');
n = regexprep(n, '\D', '');
set(hObject, 'string', n);

function cleanDecimalInput(hObject,oldvalue)
n = get(hObject, 'String');
n = regexprep(n, '^\d.', '');
set(hObject, 'string', n);


function cleanNumericListInput(hObject)
numList = get(hObject, 'String');
numList = regexprep(numList, '[ ,;]+',',');
numList = regexprep(numList, '[^\d,.]','');
set(hObject, 'String', numList);

function cleanOddNumberInput(hObject, label)
n = get(hObject, 'String');
n = regexprep(n, '\D', '');
n = str2double(n);
if mod(n,2) == 0
    % msgbox([label ' must be an odd number.']);
    n = n+1;
end
set(hObject, 'String', num2str(n));

function txtDays_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function txtPlotTitle_Callback(hObject, eventdata, handles)
% hObject    handle to txtPlotTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes during object creation, after setting all properties.
function txtPlotTitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPlotTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function txtFolderOut_Callback(hObject, eventdata, handles)
% hObject    handle to txtFolderOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function txtFolderOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFolderOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pbFolderOut_Callback(hObject, eventdata, handles)
% hObject    handle to pbFolderOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Open a file dialog
folderOut = uigetdir();
if folderOut ~= 0 % If the user hit cancel, don't do anything
    set(handles.txtFolderOut, 'String', folderOut);
end


% -------------------------------------
%% EDUCER
% -------------------------------------
% --- Executes on button press in pbSleepEduce.
function pbSleepEduce_Callback(hObject, eventdata, handles)
% hObject    handle to pbSleepEduce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
doEduction(handles, 1,0);

% --- Executes on button press in pbActiveEduce.
function pbActiveEduce_Callback(hObject, eventdata, handles)
% hObject    handle to pbActiveEduce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
doEduction(handles, 0,0);

% --- Executes on button press in pbActiveNormalized.
function pbActiveNormalized_Callback(hObject, eventdata, handles)
% hObject    handle to pbActiveNormalized (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
doEduction(handles, 0,1);

function doEduction(handles, isSleep, isNormalized)
% If we didn't already make the experiment object, get the inputs we're
% going to need to make the experiment class object
%import SleepyFlies.*

folderIn = get(handles.txtFolderIn, 'String');
runName = get(handles.txtRunName, 'String');
dayLength = str2double(get(handles.txtDayLength,'String'));
lightsOn = str2double(get(handles.txtLightsOn, 'String'));
lightHours = str2double(get(handles.txtLightHours, 'String'));
expStartStr = strcat(get(handles.txtExpStartDate, 'String'), {' '}, get(handles.txtExpStartTime, 'String'));
expStart = datetime(expStartStr, 'InputFormat', 'dd-MM-yyyy HH:mm');
bcStrings = get(handles.lstSelections, 'String'); %Anything that's been added to this list is what we need to use
if ~iscell(bcStrings) || isempty(bcStrings) || strcmpi(bcStrings{1}, 'Selected Channels')
    msgbox('Please select at least one board and channel for analysis.', 'No Channels Selected');
    return;
end
if get(handles.btnYaxisManual, 'value')
    % Manual y axis specification
    settings.yrange = [str2double(get(handles.txtYaxisMin, 'string')) ...
        str2double(get(handles.txtYaxisMax, 'string'))];
else
    settings.yrange = [];
end
% Now get the settings for eduction
switch get(get(handles.bgAveraging, 'SelectedObject'), 'String')
    case 'No Averaging'
        settings.averaging = Averaging.None;
    otherwise
        settings.averaging = Averaging.(get(get(handles.bgAveraging, 'SelectedObject'), 'String'));
end
switch get(get(handles.bgPlots, 'SelectedObject'), 'String')
    case 'Bars'
        settings.plotType = PlotType.Bars;
    case 'Lines'
        settings.plotType = PlotType.Lines;
    case 'Both'
        settings.plotType = PlotType.Both;
end
settings.isSleep = isSleep;
settings.normalizeActivity = isNormalized;
settings.binSize = str2double(get(handles.txtBinSize,'String'));
settings.days = sscanf(get(handles.txtDays, 'String'),'%u,')';
settings.title = get(handles.txtPlotTitle, 'String');
settings.folderOut = get(handles.txtFolderOut, 'String');
settings.useErrorBars = get(handles.chkErrorBars, 'Value');
settings.savePlots = get(handles.chkSavePlots, 'Value');
settings.multiPlots = get(handles.chkMultiPlots, 'Value');
if (get(handles.chkActivitySleep, 'value'))
    settings.doAS = true;
else
    settings.doAS = false;
end

% If the time period to observe for latency is specified, do the latency plots;
% If it's 0, no plots.
if get(handles.chkLatency, 'Value')
    settings.latencyMinutes = str2double(get(handles.txtLatencyWindow,'string'));
    settings.latencyOrder = str2double(get(handles.txtLatencyFilterOrder, 'string'));
    settings.latencyFrameLen = str2double(get(handles.txtLatencyFilterLength, 'string'));
    settings.latencyZT = sscanf(get(handles.txtLatencyZT, 'String'),'%u,')';
    settings.latencyDays = sscanf(get(handles.txtLatencyDays, 'String'),'%u,')';
    settings.doLatency = true;
else
    settings.doLatency = false;
end

% If the time period to observe for phase is specified, do the latency plots;
% If it's 0, no plots.
if get(handles.chkPhase, 'Value')
    settings.phaseOrder = str2double(get(handles.txtPhaseFilterOrder, 'string'));
    settings.phaseFrameLen = str2double(get(handles.txtPhaseFilterLength, 'string'));
    settings.phaseMinDist = sscanf(get(handles.txtPhaseMinDist, 'String'),'%u,')';
    settings.phaseDays = sscanf(get(handles.txtPhaseDays, 'String'),'%u,')';
    settings.phaseZT = sscanf(get(handles.txtPhaseZT, 'String'),'%u,')';
    settings.doPhase = true;
else
    settings.doPhase = false;
end

if settings.savePlots && isempty(settings.folderOut)
    waitfor(msgbox('Please select a folder to save results', 'No Output Folder Selected'));
    settings.folderOut = uigetdir();
    if settings.folderOut ~= 0 % If the user hit cancel, don't do anything
        set(handles.txtFolderOut, 'String', settings.folderOut);
    else
        waitfor(msgbox('Educer will continue, but plots will not be saved.'));
        settings.savePlots = 0;
        settings.folderOut = []; % This needs to be empty or the educer will try to save statistics
    end
end


% Convert the board/channel strings to numbers
boardsChans = cell2mat(cellfun(@(x) sscanf(x, 'M%u_C%u', [1 2]), bcStrings, 'uniformoutput', false));
boards = boardsChans(:, 1)';
chans = boardsChans(:, 2)';
try
    experiment = DataExperiment(folderIn, runName, chans, boards, ...
        lightsOn, lightHours, dayLength, expStart);
catch ME
    if strcmpi(ME.identifier, 'SleepyFlies:importData:fileNotFound')
        msgbox(ME.message, 'Invalid Channel');
        return;
    elseif strcmpi(ME.identifier, 'SleepyFlies:invalidExpStart')
        msgbox(ME.message, 'Invalid Experiment Start');
        return;
    else
        msgbox([ME.identifier ':  ' ME.message], 'Unexpected Error');
        ME(1).stack(1)
        return;
    end
end
guidata(handles.fig, handles);



% And do the eduction
set(handles.fig, 'pointer', 'watch');
drawnow
try
    if settings.doAS
        analysis = DataForAnalysisAS(experiment, 'days',settings.days, ...
            'averaging', settings.averaging, 'binSize', settings.binSize, ...
            'isSleep', isSleep, 'title', settings.title, 'normalizeActivity', isNormalized);
        if analysis.DeadFlies
            msgbox(analysis.DeadFlies, 'Warning: Dead Flies', 'modal');
        end
        % TODO: Clean up settings to only have actual plot settings here eventually
        analysis.plotData(settings);
        % 2019-01-21 Change of plans: now the all-the-days pages will
        % be written as averaged data, but the individual days will
        % still be unaveraged. This goes for all analysis types.
        analysis.writeDataToFile(settings.folderOut);
        % Also write each individual day of data.
        % (Previously this was only done with averaging type None.)
        % Do this before the individual days, so that when the settings
        % page gets written it includes all of the days.
        % if settings.averaging == Averaging.None
        for d=1:numel(settings.days)
            day = settings.days(d);
            day_analysis = DataForAnalysisAS(experiment, 'days', day, ...
                'averaging', settings.averaging, 'binSize', settings.binSize,...
                'isSleep', isSleep, 'title', settings.title, 'normalizeActivity', isNormalized);
            day_analysis.writeDataToFile(settings.folderOut);
        end
        % end
        %analysis.writeDataToFile(settings.folderOut);
        % Jenna only wants the no averaging output to Excel now (Sept. 2018), so do that
        % here instead.
        % analysis = DataForAnalysisAS(experiment, 'days', settings.days, ...
        %     'averaging', Averaging.None, 'binSize', settings.binSize, ...
        %     'isSleep', isSleep, 'title', settings.title, 'normalizeActivity', isNormalized);
        % analysis.writeDataToFile(settings.folderOut);
    end
    
    if settings.doLatency
        latency = DataForAnalysisLatency(experiment, ...
            'days', settings.latencyDays,...
            'averaging', Averaging.Days, ...
            'filterOrder', settings.latencyOrder, ...
            'frameLength', settings.latencyFrameLen,...
            'windowMinutes', settings.latencyMinutes,...
            'windowZTs', settings.latencyZT,...
            'isSleep', isSleep,...
            'title', settings.title,...
            'normalizeActivity', isNormalized);
        latency.writeDataToFile(settings.folderOut);
        latency.plotData(settings);
    end
    if settings.doPhase
        % Note that here and in latency, the input averaging & bin size
        % aren't actually used--they're overridden in the constructor.
        phase = DataForAnalysisPhase(experiment, ...
            'days', settings.phaseDays,...
            'averaging', Averaging.Days, ...
            'filterOrder', settings.phaseOrder, ...
            'frameLength', settings.phaseFrameLen,...
            'minPeakDist', settings.phaseMinDist,...
            'phaseZT', settings.phaseZT,...
            'isSleep', isSleep,...
            'title', settings.title,...
            'normalizeActivity', isNormalized);
        phase.writeDataToFile(settings.folderOut);
        phase.plotData(settings);
    end
catch ME
    if ~isempty(ME.cause)
        msg = ME.cause{1}.message;
        icon = 'warn';
    else
        msg = [ME.identifier ':  ' ME.message];
        icon = 'error';
    end
    msgbox(msg, 'Error', icon);
    for i = 1:size(ME(1).stack,1)
        disp(ME(1).stack(i))
    end
    set(handles.fig, 'pointer', 'arrow');
    return
end

set(handles.fig, 'pointer', 'arrow');
drawnow

% --- Executes on button press in chkErrorBars.
function chkErrorBars_Callback(hObject, eventdata, handles)
% hObject    handle to chkErrorBars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkErrorBars


% --- Executes on button press in chkSavePlots.
function chkSavePlots_Callback(hObject, eventdata, handles)
% hObject    handle to chkSavePlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkSavePlots


% --- Executes on button press in chkMultiPlots.
function chkMultiPlots_Callback(hObject, eventdata, handles)
% hObject    handle to chkMultiPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkMultiPlots

%% Enable/Disable Sleep/Activity Analysis
function chkActivitySleep_Callback(hObject, eventdata, handles)
if get(hObject, 'value') == 1
    setting = 'on';
else
    setting = 'off';
end
enableAS(handles, setting);

function enableAS(handles, setting)
set(handles.btnAvgFlies, 'enable', setting);
set(handles.btnAvgDays, 'enable', setting);
set(handles.btnAvgBoth, 'enable', setting);
set(handles.btnAvgNone, 'enable', setting);
set(handles.btnPlotClassic, 'enable', setting);
set(handles.btnPlotNew, 'enable', setting);
set(handles.btnPlotBoth, 'enable', setting);
set(handles.txtBinSize, 'enable', setting);
set(handles.txtDays, 'enable', setting);

%% Enable/Disable Latency Analysis
% --- Executes on button press in chkLatency.
function chkLatency_Callback(hObject, eventdata, handles)
if get(hObject, 'value') == 1
    setting = 'on';
else
    setting = 'off';
end
enableLatency(handles, setting);

function enableLatency(handles, setting)
set(handles.txtLatencyFilterOrder, 'enable', setting);
set(handles.txtLatencyFilterLength, 'enable', setting);
set(handles.txtLatencyWindow, 'enable', setting);
set(handles.txtLatencyZT, 'enable', setting);
set(handles.txtLatencyDays, 'enable', setting);


function txtLatencyMinutes_Callback(hObject, eventdata, handles)
cleanIntegerInput(hObject);

% --- Executes during object creation, after setting all properties.
function txtLatencyMinutes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLatencyMinutes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtLatencyZT_Callback(hObject, eventdata, handles)
cleanNumericListInput(hObject);

% --- Executes during object creation, after setting all properties.
function txtLatencyZTdesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLatencyZTdesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% Enable/Disable Phase Analysis
% --- Executes on button press in chkPhase.
function chkPhase_Callback(hObject, eventdata, handles)
if get(hObject,'value') == 1
    setting = 'on';
else
    setting = 'off';
end
enablePhase(handles, setting);

function enablePhase(handles, setting)
% setting should be either 'on' or 'off'
set(handles.txtPhaseFilterOrder,'enable',setting);
set(handles.txtPhaseFilterLength, 'enable', setting);
set(handles.txtPhaseMinDist, 'enable', setting);
set(handles.txtPhaseDays, 'enable', setting)
set(handles.txtPhaseZT, 'enable', setting);


function txtPhaseFilterOrder_Callback(hObject, eventdata, handles)
cleanIntegerInput(hObject);


% --- Executes during object creation, after setting all properties.
function txtPhaseFilterOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPhaseFilterOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtPhaseFilterLength_Callback(hObject, eventdata, handles)
cleanOddNumberInput(hObject);

% --- Executes during object creation, after setting all properties.
function txtPhaseFilterLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPhaseFilterLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtPhaseMinDist_Callback(hObject, eventdata, handles)
cleanIntegerInput(hObject);

% --- Executes during object creation, after setting all properties.
function txtPhaseMinDistdesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPhaseMinDistdesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtPhaseDays_Callback(hObject, eventdata, handles)
cleanNumericListInput(hObject);

% --- Executes during object creation, after setting all properties.
function txtPhaseDays_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPhaseDays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Settings panels
% --- Executes on button press in pbLatency.
function pbLatency_Callback(hObject, eventdata, handles)
if get(hObject, 'value') == 1
    % Don't allow toggling OFF a tab
    set(hObject, 'value', 0);
else
    togglePanel(handles, 'Latency');
end

% --- Executes on button press in pbPhase.
function pbPhase_Callback(hObject, eventdata, handles)
if get(hObject, 'value') == 1
    set(hObject, 'value', 0);
else
    togglePanel(handles, 'Phase');
end

% --- Executes on button press in pbAnalysis.
function pbAnalysis_Callback(hObject, eventdata, handles)
if get(hObject,'value') == 1
    set(hObject, 'value', 0);
else
    togglePanel(handles, 'Analysis');
end

function togglePanel(handles, activePanel)
% Hide the current active panel, turn on the selected panel, and update the
% active panel variable
set(handles.(['pnl' handles.activePanel]), 'visible', 'off');
set(handles.(['pb' handles.activePanel]), 'value', 1);
set(handles.(['pnl' activePanel]), 'visible','on');
set(handles.(['pb' activePanel]), 'value', 0);
handles.activePanel = activePanel;
guidata(handles.(['pnl' handles.activePanel]), handles);


function txtLatencyFilterOrder_Callback(hObject, eventdata, handles)
cleanIntegerInput(hObject);


% --- Executes during object creation, after setting all properties.
function txtLatencyFilterOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLatencyFilterOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtLatencyFilterLength_Callback(hObject, eventdata, handles)
cleanOddNumberInput(hObject);


% --- Executes during object creation, after setting all properties.
function txtLatencyFilterLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLatencyFilterLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtLatencyWindow_Callback(hObject, eventdata, handles)
cleanIntegerInput(hObject);

% --- Executes during object creation, after setting all properties.
function txtLatencyWindowdesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLatencyWindowdesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function fig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function txtLatencyZT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLatencyZT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function txtLatencyWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLatencyWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtLatencyDays_Callback(hObject, eventdata, handles)
cleanNumericListInput(hObject);


% --- Executes during object creation, after setting all properties.
function txtLatencyDays_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLatencyDays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function txtPhaseZT_Callback(hObject, eventdata, handles)
cleanNumericListInput(hObject);

% --- Executes during object creation, after setting all properties.
function txtPhaseZT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPhaseZT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtYaxisMin_Callback(hObject, eventdata, handles)
% hObject    handle to txtYaxisMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtYaxisMin as text
%        str2double(get(hObject,'String')) returns contents of txtYaxisMin as a double


% --- Executes during object creation, after setting all properties.
function txtYaxisMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtYaxisMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtYaxisMax_Callback(hObject, eventdata, handles)
% hObject    handle to txtYaxisMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtYaxisMax as text
%        str2double(get(hObject,'String')) returns contents of txtYaxisMax as a double


% --- Executes during object creation, after setting all properties.
function txtYaxisMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtYaxisMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnYaxisManual.
function btnYaxisManual_Callback(hObject, eventdata, handles)
% hObject    handle to btnYaxisManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value')
    setYaxisStates(handles, 'on');
else
    setYaxisStates(handles, 'off');
end

function setYaxisStates(handles, enabled)
set(handles.txtYaxisMin,'enable',enabled);
set(handles.txtYaxisMax,'enable',enabled);


% --- Executes on button press in btnYaxisAuto.
function btnYaxisAuto_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    setYaxisStates(handles, 'off');
else
    setYaxisStates(handles, 'on');
end
