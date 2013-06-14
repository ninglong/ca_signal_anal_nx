function varargout = draw_roi_gui_01(varargin)
% DRAW_ROI_GUI_01 MATLAB code for draw_roi_gui_01.fig
%      DRAW_ROI_GUI_01, by itself, creates a new DRAW_ROI_GUI_01 or raises the existing
%      singleton*.
%
%      H = DRAW_ROI_GUI_01 returns the handle to a new DRAW_ROI_GUI_01 or the handle to
%      the existing singleton*.
%
%      DRAW_ROI_GUI_01('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRAW_ROI_GUI_01.M with the given input arguments.
%
%      DRAW_ROI_GUI_01('Property','Value',...) creates a new DRAW_ROI_GUI_01 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before draw_roi_gui_01_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to draw_roi_gui_01_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help draw_roi_gui_01

% Last Modified by GUIDE v2.5 19-Feb-2012 11:43:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @draw_roi_gui_01_OpeningFcn, ...
                   'gui_OutputFcn',  @draw_roi_gui_01_OutputFcn, ...
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


% --- Executes just before draw_roi_gui_01 is made visible.
function draw_roi_gui_01_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to draw_roi_gui_01 (see VARARGIN)

% Choose default command line output for draw_roi_gui_01
global CaImage ROIinfo

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes draw_roi_gui_01 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
CaImage.data = [];
CaImage.header = [];
ROIinfo.ROImask = [];
ROIinfo.ROIpos = [];
ROIinfo.ROItype = [];
ROIinfo.BGpos = [];
ROIinfo.BGmask = [];
ROIinfo.Method = [];

% --- Outputs from this function are returned to the command line.
function varargout = draw_roi_gui_01_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function load_single_stack_button_Callback(hObject, eventdata, handles)

global CaImage ROIinfo

[filename, pathName] = uigetfile('*.tif', 'Load Image File');
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    cd(pathName);
    CaImage.fileName_prefix = filename(1:end-7);
    [im, header] = imread_multi(filename);
    CaImage.data = im;
    CaImage.header = header;
    CaImage.hfig = figure('position',[ 189   813   512   533]);
    CaImage.haxis = axes('Position', [0 0 1 0.96]);
    CaImage.trialNo = str2num(filename(end-6:end-4));
    set(handles.trialNo_edit, 'String', num2str(CaImage.trialNo));
%     axis off; hold on;
    
%     set(gca,'visible','off'); hold on;
    cmin = str2num(get(handles.clim_min, 'String'));
    cmax = str2num(get(handles.clim_max, 'String'));
    CaImage.clim = [cmin cmax];
    CaImage.frNo = str2num(get(handles.frame_num, 'String'));
    disp_image(handles)
    
    
function [] = disp_image(handles)

global CaImage ROIinfo
figure(CaImage.hfig); cla;
frNo = CaImage.frNo;
clim = CaImage.clim;
% text()
imagesc(CaImage.data(:,:,frNo),clim); colormap(gray);
dispStr = sprintf('TrialNo. %d,  FrameNo. %d', CaImage.trialNo, frNo);
text(0.01, 1.02, dispStr, 'Units','Normalized', 'fontsize', 15, 'fontweight','bold','Color','b')
        

    

% --- Executes on button press in load_dir_button.
function load_dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CaImage ROIinfo


function trialNo_edit_Callback(hObject, eventdata, handles)



function clim_min_Callback(hObject, eventdata, handles)
global CaImage
cmin = str2num(get(handles.clim_min, 'String'));
cmax = str2num(get(handles.clim_max, 'String'));
CaImage.clim = [cmin cmax];
disp_image(handles)


function clim_max_Callback(hObject, eventdata, handles)
global CaImage
cmin = str2num(get(handles.clim_min, 'String'));
cmax = str2num(get(handles.clim_max, 'String'));
CaImage.clim = [cmin cmax];
disp_image(handles)


function tot_roi_num_Callback(hObject, eventdata, handles)




function draw_roi_button_Callback(hObject, eventdata, handles)
global CaImage ROIinfo
trialNo = CaImage.trialNo;
roiNo = str2num(get(handles.currentROINo, 'String'));

% define the way of drawing, freehand or ploygon
if get(handles.draw_roi_opt_free_hand, 'Value') == 1
    draw = @imfreehand;
elseif get(handles.draw_roi_opt_polygon, 'Value') == 1;
    draw = @impoly;
end

axes(CaImage.haxis);
h_roi = feval(draw);
finish_drawing = 0;
while finish_drawing == 0
    choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes', 'Re-draw', 'Cancel','Yes');
    switch choice
        case'Yes',
            pos = h_roi.getPosition;
            CaImage.hROIplot(roiNo) = line(pos(:,1), pos(:,2),'color','g');
            BW = createMask(h_roi);
            delete(h_roi);
            finish_drawing = 1;
        case'Re-draw'
            delete(h_roi);
            h_roi = feval(draw); finish_drawing = 0;
        case'Cancel',
            delete(h_roi); finish_drawing = 1;
            return
    end
end
ROIinfo(trialNo).ROIpos{roiNo} = pos;
ROIinfo(trialNo).ROImask{roiNo} = BW;
ROIinfo(trialNo).ROItype{roiNo} = 'tuft branch'; % ROIType;

save(['ROIinfo_' CaImage.fileName_prefix], 'ROIinfo');
update_roi_plot(handles)
set(handles.infoText, 'String', ['ROIinfo saved as ROIinfo_' CaImage.fileName_prefix]);
set(handles.currentROINo, 'String', num2str(roiNo + 1));
% set(handles.tot_roi_num, 'String', num2str(length(ROIinfo(trialNo).ROIpos)));


function update_roi_plot(handles)
global CaImage
axes(CaImage.haxis);
% delete existing ROI plots
if any(ishandle(CaImage.hROIplot))
    try
        delete(CaImage.hROIplot(ishandle(CaImage.hROIplot)));
    end
end
CaSignal.ROIplot = plot_ROIs(handles);
    

function h_roi_plots = plot_ROIs(handles)
%
global CaImage % ROIinfo ICA_ROIs
CurrentROINo = str2double(get(handles.currentROINo,'String'));
TrialNo = str2double(get(handles.trialNo_edit,'String'));
h_roi_plots = [];
roi_pos = {};

if length(CaImage.ROIinfo) >= TrialNo
    roi_pos = CaImage.ROIinfo(TrialNo).ROIpos;
end
for i = 1:length(roi_pos) % num ROIs
    if i == CurrentROINo
        lw = 2;
    else
        lw = 1;
    end
    if ~isempty(roi_pos{i})
        h_roi_plots(i) = line(roi_pos{i}(:,1),roi_pos{i}(:,2), 'Color', [0.8 0 0], 'LineWidth', lw);
        text(median(roi_pos{i}(:,1)), median(roi_pos{i}(:,2)), num2str(i),'Color','y','FontSize',15);
        set(h_roi_plots(i), 'LineWidth', lw);
    end
end    

% --- Executes on button press in draw_roi_opt_free_hand.
function draw_roi_opt_free_hand_Callback(hObject, eventdata, handles)
% hObject    handle to draw_roi_opt_free_hand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of draw_roi_opt_free_hand


% --- Executes on button press in draw_roi_opt_polygon.
function draw_roi_opt_polygon_Callback(hObject, eventdata, handles)
% hObject    handle to draw_roi_opt_polygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of draw_roi_opt_polygon



function currentROINo_Callback(hObject, eventdata, handles)
% hObject    handle to currentROINo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentROINo as text
%        str2double(get(hObject,'String')) returns contents of currentROINo as a double


% --- Executes on button press in prev_frame.
function prev_frame_Callback(hObject, eventdata, handles)
global CaImage
currentFrNo = CaImage.frNo; 
if currentFrNo > 1
    CaImage.frNo = currentFrNo - 1;
end
set(handles.frame_num, 'String', num2str(CaImage.frNo));
disp_image(handles)


% --- Executes on button press in next_frame.
function next_frame_Callback(hObject, eventdata, handles)
global CaImage
currentFrNo = CaImage.frNo; 
if currentFrNo < size(CaImage.data,3)
    CaImage.frNo = currentFrNo + 1;
end
set(handles.frame_num, 'String', num2str(CaImage.frNo));
disp_image(handles)

function play_frames_Callback(hObject, eventdata, handles)
global CaImage
play_flag = get(hObject, 'Value');
if play_flag == 1
    set(hObject,'String','Stop ||','ForegroundColor','r');
end

for j = 1:size(CaImage.data,3)
    play_flag = get(hObject, 'Value');
    if play_flag == 1
        CaImage.frNo = j;
        disp_image(handles)
        pause(0.07)
    else
        set(hObject,'String', 'Play >')
        break;
        
    end
end
set(hObject,'String', 'Play >','ForegroundColor','b')
set(handles.frame_num, 'String', num2str(CaImage.frNo));


function frame_num_Callback(hObject, eventdata, handles)
global CaImage

CaImage.frNo = str2num(get(handles.frame_num, 'String'));
disp_image(handles)

% --- Executes during object creation, after setting all properties.
function frame_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function clim_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clim_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function currentROINo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentROINo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function clim_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clim_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function tot_roi_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tot_roi_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes during object creation, after setting all properties.
function trialNo_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialNo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
