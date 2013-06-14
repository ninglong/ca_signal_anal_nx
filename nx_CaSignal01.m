function varargout = nx_CaSignal(varargin)
% NX_CASIGNAL M-file for nx_CaSignal.fig
%      NX_CASIGNAL, by itself, creates a new NX_CASIGNAL or raises the existing
%      singleton*.
%
%      H = NX_CASIGNAL returns the handle to a new NX_CASIGNAL or the handle to
%      the existing singleton*.
%
%      NX_CASIGNAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NX_CASIGNAL.M with the given input arguments.
%
%      NX_CASIGNAL('Property','Value',...) creates a new NX_CASIGNAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nx_CaSignal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nx_CaSignal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nx_CaSignal

% Last Modified by GUIDE v2.5 19-May-2009 14:01:37

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nx_CaSignal_OpeningFcn, ...
                   'gui_OutputFcn',  @nx_CaSignal_OutputFcn, ...
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


% --- Executes just before nx_CaSignal is made visible.
function nx_CaSignal_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for nx_CaSignal
handles.output = hObject;

% Initialize handles
    % Open and Display section
set(handles.DataPathEdit, 'String', 'E:\DATA\ImagingData\Awake\Behavior_Imaging\');
set(handles.dispModeGreen, 'Value', 1);
set(handles.dispModeRed, 'Value', 0);
set(handles.dispModeImageInfoButton, 'Value', 1);
set(handles.dispModeMaxDelta, 'Value', 1);
set(handles.dispModeMoveAvg, 'Value', 1);
set(handles.dispModeWithROI, 'Value', 1);
% set(handles.LUTminEdit, 'Value', 0);
% set(handles.LUTmaxEdit, 'Value', 500);
% set(handles.LUTminSlider, 'Value', 0);
% set(handles.LUTmaxSlider, 'Value', 0.5);
set(handles.CurrentImageFilenameText, 'String', 'Current Image Filename');
    % ROI section
set(handles.nROIsText, 'String', '0');
set(handles.CurrentROINoEdit, 'String', '0');
set(handles.ROITypeMenu,'Value', 1);
    % Analysis mode
set(handles.AnalysisModeDeltaFF, 'Value', 1);
set(handles.AnalysisModeBGsub, 'Value', 0);
set(handles.batchStartTrial, 'String', '1');
set(handles.batchEndTrial, 'String', '1');
set(handles.ModifyROItoggle, 'Value', 0);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nx_CaSignal wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nx_CaSignal_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function CaTrial_init = init_CaTrial(filename, TrialNo, header)
% Initialize the struct data for the current trial
CaTrial.DataPath = pwd;
CaTrial.FileName = filename;
CaTrial.FileName_prefix = filename(1:end-7);

CaTrial_init.TrialNo = TrialNo;
CaTrial_init.DaqInfo = header;
CaTrial_init.nFrames = header.acq.numberOfFrames;
CaTrial_init.FrameTime = header.acq.msPerLine*header.acq.linesPerFrame/1000;
CaTrial_init.nROIs = 0;
CaTrial_init.BGmask = []; % Logical matrix for background ROI

% --- Executes on button press in open_image_file_button.
function open_image_file_button_Callback(hObject, eventdata, handles)

% global CaTrialObj % instantiated when loading image file
datapath = get(handles.DataPathEdit,'String');
if exist(datapath, 'dir')
    cd(datapath);
else
    warning([datapath ' not exist!'])
end;
[filename, pathName] = uigetfile('*.tif', 'Load Image File');
cd(pathName);
set(handles.DataPathEdit, 'String', pwd);

FileName_prefix = filename(1:end-7);
set(handles.CurrentImageFilenameText, 'String',  filename);

TrialNo = str2double(filename(end-6:end-4));
set(handles.CurrentTrialNoText,'String', int2str(TrialNo));

[im, header] = imread_multi(filename, 'g');

handles.userdata.current_image = im;

if get(handles.DispImageCheck, 'Value') == 1
    handles.userdata.h_image_disp_gui = image_disp_gui(im);
    handles.userdata.image_disp_gui = guidata(handles.userdata.h_image_disp_gui);
% else
%     handles.userdata.current_image = im;
end;

if exist(['CaTrials_' FileName_prefix '.mat'],'file')
    load(['CaTrials_' FileName_prefix], '-mat');
    handles.userdata.CaTrials = CaTrials;
% else
%     handles.userdata.CaTrials = struct([]);
end
% handles.userdata.CaTrials{TrialNo} = CaImageTrial(im, header);
if (~isfield(handles.userdata, 'CaTrials')||length(handles.userdata.CaTrials)<TrialNo || isempty(handles.userdata.CaTrials(TrialNo)))
    handles.userdata.CaTrials(TrialNo) = init_CaTrial(filename, TrialNo, header);
end
% Collect info to be displayed in a separate figure
handles.userdata.info_disp = {['NumOfFrames: ' num2str(header.acq.numberOfFrames)],...
    ['Zoom: ' num2str(header.acq.zoomFactor)],...
    ['numOfChannels: ' num2str(header.acq.numberOfChannelsAcquire)],...
    ['scanAmp, X, Y: ' num2str(header.acq.scanAmplitudeX) ', ' num2str(header.acq.scanAmplitudeY)],... 
    ['scanRotation: ' num2str(header.acq.scanRotation)],...
    ['msPerLine: ' num2str(header.acq.msPerLine)],...
    ['fillFraction: ' num2str(header.acq.fillFraction)],...
    ['motor_absX: ' num2str(header.motor.absXPosition)],...
    ['motor_absY: ' num2str(header.motor.absYPosition)],...
    ['motor_absZ: ' num2str(header.motor.absZPosition)],...
    ['triggerTime: ' num2str(header.internal.triggerTimeInSeconds)]};
if get(handles.dispModeImageInfoButton,'Value') == 1
    dispModeImageInfoButton_Callback(hObject, eventdata, handles)
end;

set(handles.batchPrefixEdit, 'String', FileName_prefix);
[p1, ExpDate] = fileparts(pwd);
[p2, AnimalName] = fileparts(p1);
SessionName = filename(1:strfind(filename,'_')-1);
if isempty(get(handles.AnimalNameEdit, 'String'))    
    set(handles.AnimalNameEdit, 'String', AnimalName);
    handles.userdata.CaTrials(TrialNo).AnimalName = AnimalName;
end;
if isempty(get(handles.ExpDate, 'String'))
    set(handles.ExpDate, 'String', ExpDate);
    handles.userdata.CaTrials(TrialNo).ExpDate = ExpDate;
end
if isempty(get(handles.SessionName, 'String'))
    set(handles.SessionName, 'String', SessionName);
    handles.userdata.CaTrials(TrialNo).SessionName = SessionName;
end

guidata(hObject, handles);

% --- Executes on button press in dispModeMaxDelta.
function dispModeMaxDelta_Callback(hObject, eventdata, handles)
% hObject    handle to dispModeMaxDelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispModeMaxDelta


% --- Executes on button press in dispModeMoveAvg.
function dispModeMoveAvg_Callback(hObject, eventdata, handles)
% hObject    handle to dispModeMoveAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispModeMoveAvg


% --- Executes on button press in dispModeWithROI.
function dispModeWithROI_Callback(hObject, eventdata, handles)
% hObject    handle to dispModeWithROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispModeWithROI



function DataPathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DataPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DataPathEdit as text
%        str2double(get(hObject,'String')) returns contents of DataPathEdit as a double
handles.datapath = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DataPathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DataPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_ROI.
function add_ROI_Callback(hObject, eventdata, handles)

%global CaTrialObj
TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
handles.userdata.CaTrials(TrialNo).nROIs = handles.userdata.CaTrials(TrialNo).nROIs + 1;
set(handles.nROIsText, 'String', num2str(handles.userdata.CaTrials(TrialNo).nROIs));
CurrentROINo = get(handles.CurrentROINoEdit,'String');
if strcmp(CurrentROINo, '0')
    set(handles.CurrentROINoEdit,'String', '1');
end;
guidata(hObject, handles);
% --- Executes on button press in del_ROI.
function del_ROI_Callback(hObject, eventdata, handles)

TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
handles.userdata.CaTrials(TrialNo).nROIs = handles.userdata.CaTrials(TrialNo).nROIs - 1;
set(handles.nROIsText, 'String', num2str(handles.userdata.CaTrials(TrialNo).nROIs));
TotROI = get(handles.nROIsText, 'String');
if strcmp(TotROI, '0');
    set(handles.CurrentROINoEdit,'String', '0');
end


% --- Executes on button press in prev_ROI.
function prev_ROI_Callback(hObject, eventdata, handles)

CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
CurrentROINo = CurrentROINo - 1;
if CurrentROINo == 0
    CurrentROINo = 1;
end;
set(handles.CurrentROINoEdit,'String',int2str(CurrentROINo));


% --- Executes on button press in next_ROI.
function next_ROI_Callback(hObject, eventdata, handles)

CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
CurrentROINo = CurrentROINo + 1;
if CurrentROINo > str2double(get(handles.nROIsText,'String')) 
    CurrentROINo = str2double(get(handles.nROIsText,'String')) ;
end;
set(handles.CurrentROINoEdit,'String',int2str(CurrentROINo));


% --- Executes on button press in del_all_ROI.
function del_all_ROI_Callback(hObject, eventdata, handles)





function CurrentROINoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentROINoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentROINoEdit as text
%        str2double(get(hObject,'String')) returns contents of CurrentROINoEdit as a double


% --- Executes during object creation, after setting all properties.
function CurrentROINoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentROINoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_roipoly.
function set_roipoly_Callback(hObject, eventdata, handles)

TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
waitforbuttonpress;
% [BW,xi,yi] = roipoly;
h_poly = impoly('Closed',false); % create ploygon object
pos = getPosition(h_poly);
BW = createMask(h_poly);
currentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
handles.userdata.CaTrials(TrialNo).ROIpos{currentROINo} = pos;
handles.userdata.CaTrials(TrialNo).ROIMask{currentROINo} = BW;
axes(handles.userdata.image_disp_gui.Image_disp_axes);
handles.userdata.image_disp_gui.userdata.ROIpos{end+1} = pos;
delete(h_poly); % delete polygon object
if isfield(handles.userdata, 'roi_line') && ishandle(handles.userdata.roi_line(currentROINo))
    delete(handles.userdata.roi_line(currentROINo));
end
handles.userdata.roi_line(currentROINo) = line(pos(:,1),pos(:,2), 'Color', 'r', 'LineWidth', 2);
guidata(handles.userdata.h_image_disp_gui, handles.userdata.image_disp_gui);
ROITypeMenu_Callback(hObject, eventdata, handles);

guidata(hObject, handles);


% --- Executes on button press in ModifyROItoggle.
function ModifyROItoggle_Callback(hObject, eventdata, handles)

TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
currentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
pos = handles.userdata.CaTrials(TrialNo).ROIpos{currentROINo};
h_axes = handles.userdata.image_disp_gui.Image_disp_axes;
if get(hObject, 'Value')==1
    handles.userdata.current_poly_obj = impoly(h_axes, pos);
    guidata(hObject, handles);
elseif get(hObject, 'Value')== 0 
    if isa(handles.userdata.current_poly_obj, 'imroi')
        pos = getPosition(handles.userdata.current_poly_obj);
        BW = createMask(handles.userdata.current_poly_obj);
        handles.userdata.CaTrials(TrialNo).ROIpos{currentROINo} = pos;
        handles.userdata.CaTrials(TrialNo).ROIMask{currentROINo} = BW;
        handles.userdata.image_disp_gui.userdata.ROIpos{end+1} = pos;
        
        axes(h_axes);
        delete(handles.userdata.current_poly_obj); % delete polygon object
        delete(handles.userdata.roi_line(currentROINo));
        handles.userdata.roi_line(currentROINo) = line(pos(:,1),pos(:,2), 'Color', 'r', 'LineWidth', 2);
        guidata(hObject, handles);
    end;
end;


% --- Executes on selection change in ROITypeMenu.
function ROITypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ROITypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ROITypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROITypeMenu
TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
currentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
Menu = get(handles.ROITypeMenu,'String');
handles.userdata.CaTrials(TrialNo).ROIType{currentROINo} = Menu{get(handles.ROITypeMenu,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ROITypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROITypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function dispModeGreen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispModeGreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in SaveResultsButton.
function SaveResultsButton_Callback(hObject, eventdata, handles)

% TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
FileName_prefix = handles.CaTrials(TrialNo).FileName_prefix;
CaTrials = handles.userdata.CaTrials;
save(['CaTrials_' FileName_prefix '.mat'], 'CaTrials');

%--- Executes on button press in CalculatePlotButton.
function CalculatePlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to CalculatePlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
im = handles.userdata.current_image;
ROIMask = handles.userdata.CaTrials(TrialNo).ROIMask;

    if ~isempty(handles.userdata.CaTrials(TrialNo).BGmask)
        BGmask = repmat(handles.userdata.CaTrials(TrialNo).BGmask,[1 1 size(im,3)]) ;
        BG = nanmean(nanmean(nanmean(BGmask.*double(im))));
%     else
%         error('Background ROI not set! First set BG ROI, then click this button again.');
    end;

F = zeros(size(im,3), length(ROIMask));
deltaFF = zeros(size(F));
CaTrace = zeros(size(F));

for i = 1:length(ROIMask)
    mask = repmat(ROIMask{i}, [1 1 size(im,3)]); % reproduce masks for every frame
    roi_img = mask .* double(im);
    roi_img(roi_img==0) = NaN;
    % F(:,i) = nanmean(nanmean(roi_img));
    F(:,i) = nanmean(nanmean(roi_img));
    if get(handles.AnalysisModeBGsub,'Value') == 1
        F = F - BG;
    end;
    if get(handles.AnalysisModeDeltaFF,'Value') == 1
        [N,X] = hist(F(:,i));
        F_mode = X(find(N==max(N)));
        baseline = mean(F_mode);
        deltaFF(:,i) = (F(:,i)- baseline)./baseline*100;
        CaTrace(:,i) = deltaFF(:,i);
    else
        CaTrace(:,i) = F(:,i);
    end
end;
handles.userdata.CaTrials(TrialNo).CaTrace = CaTrace;
handles.userdata.CaTrials(TrialNo).CaTrace_raw = F;
ts = (1:handles.userdata.CaTrials(TrialNo).nFrames).*handles.userdata.CaTrials(TrialNo).FrameTime;
ts = ts';
handles.userdata.h_CaTrace_fig = plot_CaTraces(CaTrace, ts);

guidata(hObject, handles);
    
% --- Executes on button press in doBatchButton.
function doBatchButton_Callback(hObject, eventdata, handles)

batchPrefix = get(handles.batchPrefixEdit, 'String');
Start_trial = str2double(get(handles.batchStartTrial, 'String'));
End_trial = str2double(get(handles.batchEndTrial,'String'));
handles.userdata.CaTrials = struct([]);
for TrialNo = Start_trial:End_trial
    fname = [batchPrefix g_zerofill(TrialNo, 3) '.tif'];
    if ~exist(fname,'file')
        [fname, pathname] = uigetfile('*.tif', 'Select Image Data file');
        cd(pathname);
    end;
    [im, header] = imread_multi(fname, 'g');
    if (length(handles.userdata.CaTrials)<TrialNo || isempty(handles.userdata.CaTrials(TrialNo)))
        handles.userdata.CaTrials(TrialNo) = init_CaTrial(fname,TrialNo,header);
    end
    if isempty(handles.userdata.CaTrials(TrialNo).ROIMask)
        handles.userdata.CaTrials(TrialNo).ROIpos = handles.userdata.CaTrials(TrialNo-1).ROIpos;
        handles.userdata.CaTrials(TrialNo).ROIMask = handles.userdata.CaTrials(TrialNo-1).ROIMask;
    end
    CalculatePlotButton_Callback(hObject, eventdata, handles)
end
SaveResultsButton_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


function batchStartTrial_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function batchStartTrial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function batchEndTrial_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function batchEndTrial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveROIsButton.
function SaveROIsButton_Callback(hObject, eventdata, handles)


% --- Executes on button press in LoadROIsButton.
function LoadROIsButton_Callback(hObject, eventdata, handles)

% --- Executes on button press in AutoROISaveCheck.
function AutoROISaveCheck_Callback(hObject, eventdata, handles)


% % --- Executes on slider movement.
% function slider6_Callback(hObject, eventdata, handles)
% % hObject    handle to slider6 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'Value') returns position of slider
% %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% 
% 
% % --- Executes during object creation, after setting all properties.
% function slider6_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to slider6 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: slider controls usually have a light gray background.
% if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor',[.9 .9 .9]);
% end
% 

% --- Executes on button press in dispModeGreen.
function dispModeGreen_Callback(hObject, eventdata, handles)

TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
if handles.userdata.CaTrials(TrialNo).DaqInfo.acq.numberOfChannelsAcquire == 1
    set(hObject,'Value',1);
end;


% --- Executes on button press in dispModeImageInfoButton.
function dispModeImageInfoButton_Callback(hObject, eventdata, handles)

if get(hObject, 'Value') == 1
    info_fig = figure; set(gca, 'Visible', 'off');
    f_pos = get(info_fig, 'Position'); f_pos(3) = f_pos(3)/2;
    set(info_fig, 'Position', f_pos);
    info_disp = handles.userdata.info_disp;
    for i = 1: length(info_disp),
        x = 0.01;
        y=1-i/length(info_disp);
        text(x,y,info_disp{i},'Interpreter','none');
    end
    handles.userdata.h_info_fig = info_fig;
    guidata(hObject, handles);
else
    close(handles.userdata.h_info_fig);
end
    


% --- Executes during object creation, after setting all properties.
function nROIsText_CreateFcn(hObject, eventdata, handles)

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)

if ishandle(handles.userdata.h_image_disp_gui)
    delete(handles.userdata.h_image_disp_gui);
end


function getROITrialNoEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function getROITrialNoEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PrevTrialButton.
function PrevTrialButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrevTrialButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in NextTrialButton.
function NextTrialButton_Callback(hObject, eventdata, handles)


% --- Executes on button press in DispImageCheck.
function DispImageCheck_Callback(hObject, eventdata, handles)
% hObject    handle to DispImageCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DispImageCheck
if get(hObject, 'Value') == 1
    if isfield(handles.userdata, 'image_disp_gui')
        im = handles.userdata.current_image;
        handles.userdata.h_image_disp_gui = image_disp_gui(im);
        handles.userdata.image_disp_gui = guidata(handles.userdata.h_image_disp_gui);
    %    handles.userdata.image_disp_gui = guidata(h);
    end;
else
    if ishandle(handles.userdata.h_image_disp_gui)
        delete(handles.userdata.h_image_disp_gui);
    end
end
guidata(hObject, handles);


% --- Executes on button press in AnalysisModeBGsub.
function AnalysisModeBGsub_Callback(hObject, eventdata, handles)
% hObject    handle to AnalysisModeBGsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AnalysisModeBGsub
TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
if get(hObject, 'Value') == 1
    if isempty(handles.userdata.CaTrials(TrialNo).BGmask)
        disp('Click image window to set BackGround Polygon!');
        waitforbuttonpress;
        try
            [BW,xi,yi] = roipoly;
            handles.userdata.CaTrials(TrialNo).BGmask = BW;
            % axes(handles.userdata.image_disp_gui.Image_disp_axes);
            handles.userdata.h_BG = line(xi, yi, 'Color','b', 'LineWidth',2);
        catch
        end
    end
else
%     if ~isempty(handles.userdata.CaTrials(TrialNo).BGmask)
%         handles.userdata.CaTrials(TrialNo).BGmask = [];
%         if isfield(handles.userdata, 'h_BG') && ishandle(handles.userdata.h_BG)
%             delete(handles.userdata.h_BG);
%         end
%     end
end;
guidata(hObject, handles);



function batchPrefixEdit_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function batchPrefixEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AnimalNameEdit_Callback(hObject, eventdata, handles)

TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
handles.userdata.CaTrials(TrialNo).AnimalName = get(hObject, 'String');


% --- Executes during object creation, after setting all properties.
function AnimalNameEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExpDate_Callback(hObject, eventdata, handles)

TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
handles.userdata.CaTrials(TrialNo).ExpDate = get(hObject, 'String');


% --- Executes during object creation, after setting all properties.
function ExpDate_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SessionName_Callback(hObject, eventdata, handles)

TrialNo = str2double(get(handles.CurrentTrialNoText,'String'));
handles.userdata.CaTrials(TrialNo).SessionName = get(hObject, 'String');

% --- Executes during object creation, after setting all properties.
function SessionName_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function FrameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function FrameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function CurrentFrameNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentFrameNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentFrameNoEdit as text
%        str2double(get(hObject,'String')) returns contents of CurrentFrameNoEdit as a double


% --- Executes during object creation, after setting all properties.
function CurrentFrameNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentFrameNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LUTminEdit_Callback(hObject, eventdata, handles)

update_image_axes(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function LUTminEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LUTminEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LUTmaxEdit_Callback(hObject, eventdata, handles)

update_image_axes(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function LUTmaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LUTmaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function LUTminSlider_Callback(hObject, eventdata, handles)
% hObject    handle to LUTminSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function LUTminSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LUTminSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function LUTmaxSlider_Callback(hObject, eventdata, handles)
% hObject    handle to LUTmaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function LUTmaxSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LUTmaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in dispMeanMode.
function dispMeanMode_Callback(hObject, eventdata, handles)

if get(hObject, 'Value') == 1
    figure('Name','Mean Image','Position',[50 500 480 480]);
    im = handles.userdata.ImageArray;
    sc = handles.userdata.Scale;
    mean_im = mean(im,3);
    imagesc(mean_im, sc);
    colormap(gray); 
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
end


% --- Executes on button press in dispMaxDelta.
function dispMaxDelta_Callback(hObject, eventdata, handles)

if get(hObject, 'Value') == 1
    figure('Name','max Delta Image','Position',[50 500 480 480]);
    im = handles.userdata.ImageArray;
    sc = handles.userdata.Scale;
    mean_im = uint16(mean(im,3));
    max_im = max(im,[],3);
    imagesc((max_im - mean_im), sc);
    colormap(gray); 
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
end


