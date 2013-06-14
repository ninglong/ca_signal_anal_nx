function varargout = image_disp_gui(varargin)
% Display image matrix. Can go through image frames by mouse wheel scroll
% or slider bar.
% varargin{1}: Should be a n by m by p matrix.
% if varargin is empty, promotes to load image file.

% NX, April 2009

% Last Modified by GUIDE v2.5 05-Jul-2010 21:33:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @image_disp_gui_OpeningFcn, ...
    'gui_OutputFcn',  @image_disp_gui_OutputFcn, ...
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


% --- Executes just before image_disp_gui is made visible.
function image_disp_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image_disp_gui (see VARARGIN)

% Choose default command line output for image_disp_gui
handles.output = hObject;
% UIWAIT makes image_disp_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Update handles structure
guidata(hObject, handles);

if ~isempty(varargin)
    im = varargin{1};
    handles = update_image_axes(hObject, eventdata, handles,im);
else
    [ImageFileName datapath] = uigetfile('*.tif', 'Select Image File');
%     cd(datapath);
    im = imread_multi([datapath filesep ImageFileName], 'g');
    set(handles.figure1, 'Name', ImageFileName);
    handles = update_image_axes(hObject, eventdata, handles,im);
end

nFrames = size(im, 3);
set(handles.FrameSlider, 'SliderStep', [1/nFrames 1/nFrames]);
set(handles.colormapMenu,'Value',2);



function Initialize_handles(hObject, eventdata, handles)

set(handles.FrameSlider,'Value',0);
set(handles.meanMode, 'Value', 0);
set(handles.maxDeltaMode, 'Value', 0);
set(handles.maxMode, 'Value', 0);
guidata(hObject, handles);


function handles = update_image_axes(hObject, eventdata, handles,varargin)
% update image display, called by most of call back functions
if isempty(varargin)
    im = handles.userdata.ImageArray;
else
    im = varargin{1};
end;
LUTmin = str2double(get(handles.LUTminEdit,'String'));
LUTmax = str2double(get(handles.LUTmaxEdit,'String'));
sc = [LUTmin LUTmax];
fr = str2double(get(handles.FrameNumEdit,'String'));
ColorMap_strs=get(handles.colormapMenu,'String');
ColorMap_id=get(handles.colormapMenu,'Value');
handles.userdata.ColorMap = ColorMap_strs{ColorMap_id};

handles.userdata.ImageArray = im;
handles.userdata.Scale = sc;
handles.userdata.FrameNum = fr;

% axes(handles.Image_disp_axes);
% hold on;
% if (isfield(handles.userdata, 'h_img')&& ishandle(handles.userdata.h_img))
%     delete(handles.userdata.h_img);
% end;
handles.userdata.h_img = imagesc(im(:,:,fr), sc);
colormap(ColorMap);

% Plot ROIs onece, and store them to handles
if ~isfield(handles.userdata, 'ROIpos')
    handles.userdata.ROIpos = {}; % ROI polygon votex vectors
    handles.userdata.h_poly = []; % handles to ROI polygon drawings
elseif ~isempty(handles.userdata.ROIpos)
    %if isempty(handles.userdata.h_poly) || length(handles.userdata.ROIpos)>length(handles.userdata.h_poly)
    for i = 1:length(handles.userdata.ROIpos)
        xi = handles.userdata.ROIpos{i}(:,1);
        yi = handles.userdata.ROIpos{i}(:,2);
        handles.userdata.h_poly(i) = line(xi, yi, 'Color', 'r', 'LineWidth', 2);
        % hold on;
    end
    %end;
    %uistack(handles.userdata.h_poly,'up');
end;
% hold off;
guidata(hObject, handles);
if size(im,3)>3
     set(handles.figure1, 'WindowScrollWheelFcn',{@figScroll, hObject, eventdata, handles});
end;


function figScroll(src,evnt, hObject, eventdata, handles)
% callback function for mouse scroll
% 
im = handles.userdata.ImageArray;
fr = str2double(get(handles.FrameNumEdit, 'String'));
sc = handles.userdata.Scale;
% axes(handles.Image_disp_axes);
if evnt.VerticalScrollCount > 0
    if fr < size(im,3)
        fr = fr + 1;
    end
    
elseif evnt.VerticalScrollCount < 0
    if fr > 1
        fr = fr - 1;
    end  
end
set(handles.FrameSlider,'Value', fr/size(im,3));

handles.userdata.FrameNum = fr;
set(handles.FrameNumEdit, 'String', num2str(fr));

handles.userdata.h_img = imagesc(im(:,:,fr), sc);
colormap(handles.userdata.ColorMap);

% Plot ROIs onece, and store them to handles
if ~isfield(handles.userdata, 'ROIpos')
    handles.userdata.ROIpos = {}; % ROI polygon votex vectors
    handles.userdata.h_poly = []; % handles to ROI polygon drawings
elseif ~isempty(handles.userdata.ROIpos)
    %if isempty(handles.userdata.h_poly) || length(handles.userdata.ROIpos)>length(handles.userdata.h_poly)
    for i = 1:length(handles.userdata.ROIpos)
        xi = handles.userdata.ROIpos{i}(:,1);
        yi = handles.userdata.ROIpos{i}(:,2);
        handles.userdata.h_poly(i) = line(xi, yi, 'Color', 'r', 'LineWidth', 2);
        % hold on;
    end
    %end;
    %uistack(handles.userdata.h_poly,'up');
end;
% hold off;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = image_disp_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function FrameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
slider_value = get(hObject,'Value');
im = handles.userdata.ImageArray;
new_frameNum = ceil(size(im,3)*slider_value);
if new_frameNum == 0, new_frameNum = 1; end;
set(handles.FrameNumEdit, 'String', num2str(new_frameNum));
update_image_axes(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function FrameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function Image_disp_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Image_disp_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Image_disp_axes



function FrameNumEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FrameNumEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameNumEdit as text
%        str2double(get(hObject,'String')) returns contents of FrameNumEdit as a double
update_image_axes(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function FrameNumEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameNumEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadImageFile.
function LoadImageFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImageFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Initialize_handles(hObject, eventdata, handles);
[ImageFileName datapath] = uigetfile('*.tif', 'Select Image File');
cd(datapath);
im = imread_multi(ImageFileName, 'g');
set(handles.figure1, 'Name', ImageFileName);
update_image_axes(hObject, eventdata, handles,im);


function LUTminEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LUTminEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_image_axes(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of LUTminEdit as text
%        str2double(get(hObject,'String')) returns contents of LUTminEdit as a double


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
% hObject    handle to LUTmaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LUTmaxEdit as text
%        str2double(get(hObject,'String')) returns contents of LUTmaxEdit as a double
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
value_min = get(hObject,'Value');
value_max = get(handles.LUTmaxSlider,'Value');
if value_min >= value_max
    value_min = value_max - 0.01;
    set(hObject, 'Value', value_min);
end;
set(handles.LUTminEdit, 'String', num2str(value_min*1000));
update_image_axes(hObject, eventdata, handles);

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
value_max = get(hObject,'Value');
value_min = get(handles.LUTminSlider, 'Value');
if value_max <= value_min
    value_max = value_min + 0.01;
    set(hObject, 'Value', value_max);
end;
set(handles.LUTmaxEdit, 'String', num2str(value_max*1000));
update_image_axes(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function LUTmaxSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LUTmaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in maxDeltaProj.
function maxDeltaProj_Callback(hObject, eventdata, handles)
% hObject    handle to maxDeltaProj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of maxDeltaProj


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over maxDeltaProj.
function maxDeltaProj_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to maxDeltaProj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Max Delta Projection!');


% --- Executes on button press in meanMode.
function meanMode_Callback(hObject, eventdata, handles)
% hObject    handle to meanMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of meanMode
meanMode = get(hObject, 'Value');
if meanMode == 1
    figure('Name','Mean Image','Position',[50 500 512 512]);
    im = handles.userdata.ImageArray;
    sc = handles.userdata.Scale;
    mean_im = mean(im,3);
    imagesc(mean_im, sc);
    colormap(handles.userdata.ColorMap); 
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
end

% --- Executes on button press in maxDeltaMode.
function maxDeltaMode_Callback(hObject, eventdata, handles)

maxDeltaMode = get(hObject, 'Value');
if maxDeltaMode == 1
    figure('Name','max Delta Image','Position',[50 500 480 480]);
    im = handles.userdata.ImageArray;
    sc = handles.userdata.Scale;
    mean_im = uint16(mean(im,3));
    max_im = max(im,[],3);
    imagesc((max_im - mean_im), sc);
    colormap(handles.userdata.ColorMap); 
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
end

% --- Executes on button press in maxMode.
function maxMode_Callback(hObject, eventdata, handles)

maxMode = get(hObject, 'Value');
if maxMode == 1
    figure('Name','Max Projection Image','Position',[50 500 480 480]);
    im = handles.userdata.ImageArray;
    sc = handles.userdata.Scale;
    max_im = max(im,[],3);
    imagesc((max_im), sc);
    colormap(handles.userdata.ColorMap); 
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
end


% --- Executes on button press in SaveFrameButton.
function SaveFrameButton_Callback(hObject, eventdata, handles)
% Save the current frame as a tiff file.
im = handles.userdata.ImageArray;
fr = handles.userdata.FrameNum;
[fname, path] = uiputfile('*.tif', 'Save Current Frame to Tiff');
imwrite(im(:,:,fr), [path filesep fname], 'Compression', 'none', 'writemode', 'overwrite');


% --- Executes on selection change in colormapMenu.
function colormapMenu_Callback(hObject, eventdata, handles)
update_image_axes(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function colormapMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colormapMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
