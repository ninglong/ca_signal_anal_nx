function varargout = image_disp_gui(varargin)
% IMAGE_DISP_GUIDE M-file for image_disp_guide.fig
%      IMAGE_DISP_GUIDE, by itself, creates a new IMAGE_DISP_GUIDE or raises the existing
%      singleton*.
%
%      H = IMAGE_DISP_GUIDE returns the handle to a new IMAGE_DISP_GUIDE or the handle to
%      the existing singleton*.
%
%      IMAGE_DISP_GUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE_DISP_GUIDE.M with the given input arguments.
%
%      IMAGE_DISP_GUIDE('Property','Value',...) creates a new IMAGE_DISP_GUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before image_disp_guide_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to image_disp_guide_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help image_disp_guide

% Last Modified by GUIDE v2.5 27-Apr-2009 17:31:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @image_disp_guide_OpeningFcn, ...
                   'gui_OutputFcn',  @image_disp_guide_OutputFcn, ...
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


% --- Executes just before image_disp_guide is made visible.
function image_disp_guide_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image_disp_guide (see VARARGIN)

% Choose default command line output for image_disp_guide
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes image_disp_guide wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if ~isempty(varargin)
    im = varargin{1};
    axes(handles.Image_disp_axes);
    imagesc(im(:,:,1));
end

%    x = [0:.1:40];
%    y = 4.*cos(x)./(x+2);
%    a = handles.Image_disp_axes; 
%    axes(a);
%    h = plot(x,y);
%    set(hObject, 'WindowScrollWheelFcn',{@figScroll,h, a});
%    
%    function figScroll(src,evnt,h,a)
%       if evnt.VerticalScrollCount > 0 
%          xd = get(h,'XData');
%          inc = xd(end)/20;
%          x = [0:.1:xd(end)+inc];
%          re_eval(x,a,h)
%       elseif evnt.VerticalScrollCount < 0 
%          xd = get(h,'XData');
%          inc = xd(end)/20;
%          x = [0:.1:xd(end)-inc+.1]; % Don't let xd = 0
%          re_eval(x,a,h)
%       end
%    %end %figScroll
% 
%    function re_eval(x, a, h)
%       y = 4.*cos(x)./(x+2);
%       set(h,'YData',y,'XData',x)
%       set(a,'XLim',[0 x(end)])
%       drawnow
%    %end % re_eval


% --- Outputs from this function are returned to the command line.
function varargout = image_disp_guide_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
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


