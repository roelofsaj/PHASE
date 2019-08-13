function varargout = ImageAnalysis(varargin)
% IMAGEANALYSIS MATLAB code for ImageAnalysis.fig
%      IMAGEANALYSIS, by itself, creates a new IMAGEANALYSIS or raises the existing
%      singleton*.
%
%      H = IMAGEANALYSIS returns the handle to a new IMAGEANALYSIS or the handle to
%      the existing singleton*.
%
%      IMAGEANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEANALYSIS.M with the given input arguments.
%
%      IMAGEANALYSIS('Property','Value',...) creates a new IMAGEANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageAnalysis

% Last Modified by GUIDE v2.5 20-Feb-2018 10:36:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageAnalysis_OutputFcn, ...
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


% --- Executes just before ImageAnalysis is made visible.
function ImageAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageAnalysis (see VARARGIN)

% Choose default command line output for ImageAnalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImageAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figIA);


% --- Outputs from this function are returned to the command line.
function varargout = ImageAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function txtFolder_Callback(hObject, eventdata, handles)
% hObject    handle to txtFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtFolder as text
%        str2double(get(hObject,'String')) returns contents of txtFolder as a double


% --- Executes during object creation, after setting all properties.
function txtFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbFolder.
function pbFolder_Callback(hObject, eventdata, handles)
% hObject    handle to pbFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Open a file dialog
folderIn = uigetdir();
if folderIn ~= 0 % If the user hit cancel, don't do anything
    set(handles.txtFolderIn, 'String', folderIn);
end



function txtPreStart_Callback(hObject, eventdata, handles)
% hObject    handle to txtPreStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPreStart as text
%        str2double(get(hObject,'String')) returns contents of txtPreStart as a double


% --- Executes during object creation, after setting all properties.
function txtPreStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPreStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtPreEnd_Callback(hObject, eventdata, handles)
% hObject    handle to txtPreEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPreEnd as text
%        str2double(get(hObject,'String')) returns contents of txtPreEnd as a double


% --- Executes during object creation, after setting all properties.
function txtPreEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPreEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtStimStart_Callback(hObject, eventdata, handles)
% hObject    handle to txtStimStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtStimStart as text
%        str2double(get(hObject,'String')) returns contents of txtStimStart as a double


% --- Executes during object creation, after setting all properties.
function txtStimStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtStimStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtStimEnd_Callback(hObject, eventdata, handles)
% hObject    handle to txtStimEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtStimEnd as text
%        str2double(get(hObject,'String')) returns contents of txtStimEnd as a double


% --- Executes during object creation, after setting all properties.
function txtStimEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtStimEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtWashStart_Callback(hObject, eventdata, handles)
% hObject    handle to txtWashStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtWashStart as text
%        str2double(get(hObject,'String')) returns contents of txtWashStart as a double


% --- Executes during object creation, after setting all properties.
function txtWashStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtWashStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtWashEnd_Callback(hObject, eventdata, handles)
% hObject    handle to txtWashEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtWashEnd as text
%        str2double(get(hObject,'String')) returns contents of txtWashEnd as a double


% --- Executes during object creation, after setting all properties.
function txtWashEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtWashEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbIncludeAvg.
function cbIncludeAvg_Callback(hObject, eventdata, handles)
% hObject    handle to cbIncludeAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbIncludeAvg


% --- Executes on button press in pbPlot.
function pbPlot_Callback(hObject, eventdata, handles)
% hObject    handle to pbPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
