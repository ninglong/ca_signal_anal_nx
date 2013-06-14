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

% Last Modified by GUIDE v2.5 30-Sep-2010 11:08:29

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
usrpth = userpath; usrpth = usrpth(1:end-1);
if exist([usrpth filesep 'nx_CaSingal.info'],'file')
    load([usrpth filesep 'nx_CaSingal.info'], '-mat');
    set(handles.DataPathEdit, 'String',info.DataPath);
    set(handles.AnimalNameEdit, 'String', info.AnimalName);
    set(handles.ExpDate,'String',info.ExpDate);
    set(handles.SessionName, 'String',info.SessionName);
    if isfield(info, 'SoloDataPath')
        set(handles.SoloDataPath, 'String', info.SoloDataPath);
        set(handles.SoloDataFileName, 'String', info.SoloDataFileName);
        set(handles.SoloSessionName, 'String', info.SoloSessionName);
        set(handles.SoloStartTrialNo, 'String', info.SoloStartTrialNo);
        set(handles.SoloEndTrialNo, 'String', info.SoloEndTrialNo);
    end
else
    set(handles.DataPathEdit, 'String', '/Users/xun/Documents/ExpData/2p-Imaging/');
    set(handles.SoloDataPath, 'String', '/Users/xun/Documents/ExpData/Whisker_Behavior_Data/SoloData/Data_2PRig/');
end
% Initialize handles
    % Open and Display section
set(handles.dispModeGreen, 'Value', 1);
set(handles.dispModeRed, 'Value', 0);
set(handles.dispModeImageInfoButton, 'Value', 0);
set(handles.dispModeMoveAvg, 'Value', 1);
set(handles.dispModeWithROI, 'Value', 1);
% set(handles.LUTminEdit, 'Value', 0);
% set(handles.LUTmaxEdit, 'Value', 500);
% set(handles.LUTminSlider, 'Value', 0);
% set(handles.LUTmaxSlider, 'Value', 0.5);
set(handles.CurrentImageFilenameText, 'String', 'Current Image Filename');
    % ROI section
set(handles.nROIsText, 'String', '0');
set(handles.CurrentROINoEdit, 'String', '1');
set(handles.ROITypeMenu,'Value', 1);
    % Analysis mode
set(handles.AnalysisModeDeltaFF, 'Value', 1);
set(handles.AnalysisModeBGsub, 'Value', 0);
set(handles.batchStartTrial, 'String', '1');
set(handles.batchEndTrial, 'String', '1');
set(handles.ROI_modify_toggle, 'Value', 0);
set(handles.CurrentFrameNoEdit,'String',1);
set(handles.setTargetMaxDelta,'Value',0);
set(handles.setTargetCurrentFrame,'Value',0);
set(handles.setTargetMean,'Value',0);

handles.userdata.ImageArray = [];
handles.userdata.nFrames = 0;
% handles.userdata.CaTrials = [];
handles.userdata.h_info_fig = 0;
handles.userdata.FrameNum = 1;
handles.userdata.h_img = 0;
ROIinfo = {};
handles.userdata.ROIplot = {};
handles.userdata.avgCorrCoef_trials = [];
handles.userdata.CorrMapTrials = [];
handles.userdata.CorrMapROINo = [];
handles.userdata.AspectRatio_mode = 'Square';
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

function CaTrial = init_CaTrial(filename, TrialNo, header)
% Initialize the struct data for the current trial
CaTrial.DataPath = pwd;
CaTrial.FileName = filename;
CaTrial.FileName_prefix = filename(1:end-7);

CaTrial.TrialNo = TrialNo;
CaTrial.DaqInfo = header;
CaTrial.nFrames = header.acq.numberOfFrames;
CaTrial.FrameTime = header.acq.msPerLine*header.acq.linesPerFrame;
if CaTrial.FrameTime < 1 % some earlier version of ScanImage use sec as unit for msPerLine
    CaTrial.FrameTime = CaTrial.FrameTime*1000;
end
CaTrial.nROIs = 0;
CaTrial.BGmask = []; % Logical matrix for background ROI
CaTrial.AnimalName = '';
CaTrial.ExpDate = '';
CaTrial.SessionName = '';
CaTrial.dff = [];
CaTrial.f_raw = [];
% CaTrial.meanImage = [];
CaTrial.RegTargetFrNo = [];
CaTrial.ROIinfo = [];
CaTrial.SoloDataPath = '';
CaTrial.SoloFileName = '';
CaTrial.SoloSessionName = '';
CaTrial.SoloTrialNo = [];
CaTrial.SoloStartTrialNo = [];
CaTrial.SoloEndTrialNo = [];
CaTrial.behavTrial = [];
% CaTrial.ROIType = '';

% --- Executes on button press in open_image_file_button.
function open_image_file_button_Callback(hObject, eventdata, handles, filename)

global CaTrials ROIinfo

datapath = get(handles.DataPathEdit,'String');
if exist(datapath, 'dir')
    cd(datapath);
else
    warning([datapath ' not exist!'])
    if exist('/Users/xun/Documents/ExpData/2p-Imaging/','dir')
        cd('/Users/xun/Documents/ExpData/2p-Imaging/');
    end
end;
if ~exist('filename', 'var')
    [filename, pathName] = uigetfile('*.tif', 'Load Image File');
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    cd(pathName);
    FileName_prefix = filename(1:end-7);
    handles.userdata.data_files = dir([FileName_prefix '*.tif']);
    handles.userdata.data_file_names = {};
    for i = 1:length(handles.userdata.data_files)
        handles.userdata.data_file_names{i} = handles.userdata.data_files(i).name;
    end;
end
datapath = pwd;
set(handles.DataPathEdit,'String',datapath);

FileName_prefix = filename(1:end-7);

TrialNo = find(strcmp(filename, handles.userdata.data_file_names));
set(handles.CurrentTrialNo,'String', int2str(TrialNo));
disp(['Loading image file ' filename ' ...']);
set(handles.msgBox, 'String', ['Loading image file ' filename ' ...']);
tic;
[im, header] = imread_multi(filename, 'g');
t_elapsed = toc;
set(handles.msgBox, 'String', ['Loaded file ' filename ' in ' num2str(t_elapsed) ' sec']);
info = imfinfo(filename);
if isfield(info(1), 'ImageDescription')
    handles.userdata.ImageDescription = info(1).ImageDescription; % used by Turboreg
else
    handles.userdata.ImageDescription = '';
end
handles.userdata.ImageArray = im;

if ~isempty(CaTrials)
    if length(CaTrials)<TrialNo || isempty(CaTrials(TrialNo).FileName)
        CaTrials(TrialNo) = init_CaTrial(filename, TrialNo, header);
    end
    if ~strcmp(CaTrials(TrialNo).FileName_prefix, FileName_prefix)
        CaTrials_INIT = 1;
    else
        CaTrials_INIT = 0;
    end
else
    CaTrials_INIT = 1;
end

% Now we are in data file path. Since analysis results are saved in a separate
% folder, we need to find that folder in order to laod or save analysis
% results. If that folder does not exist, a new folder will be created.

handles.userdata.results_path = strrep(datapath,[filesep 'data'],[filesep 'results']);
if ~exist(handles.userdata.results_path,'dir')
    mkdir(handles.userdata.results_path);
    disp('results dir not exists! A new folder created!');
    disp(handles.userdata.results_path);
end

handles.userdata.results_fn = [handles.userdata.results_path filesep 'CaTrials_' FileName_prefix '.mat'];
handles.userdata.results_roiinfo = [handles.userdata.results_path filesep 'ROIinfo_', FileName_prefix '.mat'];   
if CaTrials_INIT == 1
   CaTrials = []; ROIinfo = [];
    if exist(handles.userdata.results_fn,'file')
        load(handles.userdata.results_fn, '-mat');
%         CaTrials = CaTrials;
    else
        A = init_CaTrial(filename, TrialNo, header);
        A(TrialNo) = A;
        if TrialNo ~= 1
            names = fieldnames(A);
            for i = 1:length(names)
                A(1).(names{i})=[];
            end
        end
        CaTrials = A;
    end
end

if exist(handles.userdata.results_roiinfo,'file')
    load(handles.userdata.results_roiinfo, '-mat');
%     ROIinfo = ROIinfo;
    if (length(ROIinfo)<TrialNo || isempty(ROIinfo{TrialNo}))
        ROIinfo{TrialNo} = struct([]);
    else
        CaTrials(TrialNo).nROIs = length(ROIinfo{TrialNo}.ROIpos);
    end
% else
%     ROIinfo{TrialNo} = struct([]);
end
if exist([handles.userdata.results_path filesep FileName_prefix(1:end-7) '[dftShift].mat'],'file')
    load([handles.userdata.results_path filesep FileName_prefix(1:end-7) '[dftShift].mat']);
    handles.userdata.dftreg_shift = shift;
else
    handles.userdata.dftreg_shift = [];
end

% Collect info to be displayed in a separate figure

% if get(handles.dispModeImageInfoButton,'Value') == 1
    handles.userdata.info_disp = {sprintf('numFramesPerTrial: %d', header.acq.numberOfFrames), ...
    ['Zoom: ' num2str(header.acq.zoomFactor)],...
    ['numOfChannels: ' num2str(header.acq.numberOfChannelsAcquire)],...
    sprintf('ImageDimXY: %d,  %d', header.acq.pixelsPerLine, header.acq.linesPerFrame),...
    sprintf('Frame Rate: %d', header.acq.frameRate), ...
    ['msPerLine: ' num2str(header.acq.msPerLine)],...
    ['fillFraction: ' num2str(header.acq.fillFraction)],...
    ['motor_absX: ' num2str(header.motor.absXPosition)],...
    ['motor_absY: ' num2str(header.motor.absYPosition)],...
    ['motor_absZ: ' num2str(header.motor.absZPosition)],...
    ['num_zSlice: ' num2str(header.acq.numberOfZSlices)],...
    ['zStep: ' num2str(header.acq.zStepSize)] ...
    ['triggerTime: ' header.internal.triggerTimeString]...
    };
%     dispModeImageInfoButton_Callback(hObject, eventdata, handles)
% end;

set(handles.TotTrialNum, 'String', int2str(length(handles.userdata.data_file_names)));
set(handles.CurrentImageFilenameText, 'String',  filename);
if CaTrials_INIT == 1
    set(handles.DataPathEdit, 'String', pwd);
    set(handles.AnimalNameEdit, 'String', CaTrials(TrialNo).AnimalName);
    set(handles.ExpDate,'String',CaTrials(TrialNo).ExpDate);
    set(handles.SessionName, 'String',CaTrials(TrialNo).SessionName);
    if isfield(CaTrials(TrialNo), 'SoloDataFileName')
        set(handles.SoloDataPath, 'String', CaTrials(TrialNo).SoloDataPath);
        set(handles.SoloDataFileName, 'String', CaTrials(TrialNo).SoloDataFileName);
        set(handles.SoloSessionName, 'String', CaTrials(TrialNo).SoloSessionName);
        set(handles.SoloStartTrialNo, 'String', num2str(CaTrials(TrialNo).SoloStartTrialNo));
        set(handles.SoloEndTrialNo, 'String', num2str(CaTrials(TrialNo).SoloEndTrialNo));
    end
end


% Initialize gui handles based on loaded file
nFrames = size(im, 3);
set(handles.FrameSlider, 'SliderStep', [1/nFrames 1/nFrames]);
set(handles.FrameSlider, 'Value', 1/nFrames);
set(handles.nROIsText, 'String', int2str(CaTrials(TrialNo).nROIs));
handles.userdata.nFrames = nFrames;
set(handles.batchPrefixEdit, 'String', FileName_prefix);
%    handles = get_exp_info(hObject, eventdata, handles);
% CaTrials(TrialNo).meanImage = mean(im,3);

% update target info for TurboReg
% setTargetCurrentFrame_Callback(handles.setTargetCurrentFrame, eventdata, handles);
% setTargetMaxDelta_Callback(handles.setTargetMaxDelta, eventdata,handles);
% setTargetMean_Callback(handles.setTargetMaxDelta, eventdata, handles);

handles.userdata.avgCorrCoef_trials = [];

% The trialNo to load ROIinfo from
TrialNo_load = str2double(get(handles.getROITrialNoEdit,'String'));
if TrialNo_load > 0 && length(ROIinfo)>= TrialNo_load
    ROIinfo{TrialNo} = ROIinfo{TrialNo_load};
    nROIs = length(ROIinfo{TrialNo}.ROIpos);
    CaTrials(TrialNo).nROIs = nROIs;
    set(handles.nROIsText, 'String', num2str(nROIs));
end

guidata(hObject, handles);
handles = update_image_axes(hObject, eventdata, handles,im);
handles = update_projection_images(hObject,eventdata,handles);


%%%%%%%%%%%%%%%%%%%% Start of Independent functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = get_exp_info(hObject, eventdata, handles)
global CaTrials ROIinfo

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
filename = handles.userdata.data_file_names{TrialNo};

if ~isempty(CaTrials(TrialNo).ExpDate)
    ExpDate = CaTrials(TrialNo).ExpDate;
    set(handles.ExpDate, 'String', ExpDate);
else
    CaTrials(TrialNo).ExpDate = get(handles.ExpDate, 'String');
end;


if ~isempty(CaTrials(TrialNo).AnimalName)
    AnimalName = CaTrials(TrialNo).AnimalName;
    set(handles.AnimalNameEdit, 'String', AnimalName);
else
    CaTrials(TrialNo).AnimalName = get(handles.AnimalNameEdit, 'String');
end


if ~isempty(CaTrials(TrialNo).SessionName)
    SessionName = CaTrials(TrialNo).SessionName;
    set(handles.SessionName, 'String', SessionName);
else
    CaTrials(TrialNo).SessionName = get(handles.SessionName, 'String');
end



function handles = update_image_axes(hObject, eventdata, handles,varargin)
% update image display, called by most of call back functions
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String')); 
LUTmin = str2double(get(handles.LUTminEdit,'String'));
LUTmax = str2double(get(handles.LUTmaxEdit,'String'));
sc = [LUTmin LUTmax];
cmap = 'gray';
fr = str2double(get(handles.CurrentFrameNoEdit,'String'));
if fr > handles.userdata.nFrames && handles.userdata.nFrames > 0
    fr = handles.userdata.nFrames;
end
if ~isempty(varargin)
    handles.userdata.ImageArray = varargin{1};
end
handles.userdata.Scale = sc;
handles.userdata.FrameNum = fr;

if get(handles.dispCorrMapTrials,'Value')==1
    im = handles.userdata.CorrMapTrials;
%     cmap = 'jet';
    sc = [0 max(im(:))];
else
    im = handles.userdata.ImageArray;
end;
im_size = size(im);
switch handles.userdata.AspectRatio_mode
    case 'Square'
        s1 = im_size(2)/max(im_size(1:2));
        s2 = im_size(1)/max(im_size(1:2));
        asp_ratio = [s1 s2 1]; 
    case 'Image'
        asp_ratio = [1 1 1];
end
axes(handles.Image_disp_axes);
% hold on;
% if (isfield(handles.userdata, 'h_img')&& ishandle(handles.userdata.h_img))
%     delete(handles.userdata.h_img);
% end;
% handles.userdata.h_img = imagesc(im(:,:,fr), sc);
handles.userdata.h_img = imshow(im(:,:,fr), sc);
set(handles.Image_disp_axes, 'DataAspectRatio', asp_ratio);  %'XTickLabel','','YTickLabel','');
time_str = sprintf('%.3f  sec',CaTrials(1).FrameTime*fr/1000);
set(handles.frame_time_disp, 'String', time_str);
% colormap(gray);
if get(handles.dispModeWithROI,'Value') == 1 && length(ROIinfo) >= TrialNo && ~isempty(ROIinfo{TrialNo})
    handles = update_ROI_plot(hObject, eventdata, handles);
end

% set(handles.figure1, 'WindowScrollWheelFcn',{@figScroll, hObject, eventdata, handles});
guidata(handles.figure1, handles);


function handles = update_ROI_plot(hObject, eventdata, handles)
global CaTrials ROIinfo

CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
TrialNo = str2double(get(handles.CurrentTrialNo,'String')); 

if get(handles.dispModeWithROI,'Value') == 1
    for i = 1:length(ROIinfo{TrialNo}.ROIpos)
        pos = ROIinfo{TrialNo}.ROIpos{i};
        if i == CurrentROINo
            lw = 2;
        else
            lw = 1;
        end
        if ~isempty(pos)
            if length(handles.userdata.ROIplot)>=i & ~isempty(handles.userdata.ROIplot{i})...
                    & ishandle(handles.userdata.ROIplot{i})
                delete(handles.userdata.ROIplot{i});
            end
            handles.userdata.ROIplot{i} = line(pos(:,1),pos(:,2), 'Color', 'r', 'LineWidth', lw);
            text(median(pos(:,1)), median(pos(:,2)), num2str(i),'Color','g','FontSize',15);
            set(handles.userdata.ROIplot{i}, 'LineWidth', lw);
        end
    end
end
if ~isempty(ROIinfo{TrialNo}.BGpos)
    BGpos = ROIinfo{TrialNo}.BGpos;
    handles.userdata.BGplot = line(BGpos(:,1),BGpos(:,2), 'Color', 'b', 'LineWidth', 2);
end
set(handles.figure1, 'WindowScrollWheelFcn',{@figScroll, hObject, eventdata, handles});



function handles = update_projection_images(hObject,eventdata,handles)
global CaTrials ROIinfo

if get(handles.dispMeanMode, 'Value')==1
    if ~isfield(handles.userdata, 'h_mean_fig') || ~ishandle(handles.userdata.h_mean_fig)
        handles.userdata.h_mean_fig = figure('Name','Mean Image','Position',[960   500   480   480]);
    else
        figure(handles.userdata.h_mean_fig)
    end
    if get(handles.dispCorrMapTrials,'Value')==1
        mean_im = handles.userdata.CorrMapMean;
        sc = [0 max(mean_im(:))];
        colormap('jet');
    else
        im = handles.userdata.ImageArray;
        sc = handles.userdata.Scale;
        mean_im = mean(im,3);
        colormap(gray); 
    end
    imagesc(mean_im, sc);
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    update_projection_image_ROIs(hObject,eventdata,handles);
end
if get(handles.dispMaxDelta,'Value')==1
    if ~isfield(handles.userdata, 'h_maxDelta_fig') || ~ishandle(handles.userdata.h_maxDelta_fig)
        handles.userdata.h_maxDelta_fig = figure('Name','max Delta Image','Position',[960   40   480   480]);
    else
        figure(handles.userdata.h_maxDelta_fig);
    end
    im = handles.userdata.ImageArray;
    sc = handles.userdata.Scale;
    mean_im = uint16(mean(im,3));
    im = im_mov_avg(im,5);
    max_im = max(im,[],3);
    handles.userdata.MaxDelta = max_im - mean_im;
    imagesc(handles.userdata.MaxDelta, sc);
    colormap(gray); 
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    update_projection_image_ROIs(hObject,eventdata,handles);
end
if get(handles.dispMaxMode,'Value')==1
    if ~isfield(handles.userdata, 'h_max_fig') || ~ishandle(handles.userdata.h_max_fig)
        handles.userdata.h_max_fig = figure('Name','Max Projection Image','Position',[960   180   480   480]);
    else
        figure(handles.userdata.h_max_fig)
    end
    im = handles.userdata.ImageArray;
    sc = handles.userdata.Scale;
    im = im_mov_avg(im,5);
    max_im = max(im,[],3);
    imagesc(max_im, sc);
    colormap(gray); 
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    update_projection_image_ROIs(hObject,eventdata,handles);
end

% update ROI plotting in projecting image figure, called only by updata_projection image
function update_projection_image_ROIs(hObject,eventdata,handles)
global CaTrials ROIinfo
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if get(handles.dispModeWithROI,'Value') == 1 && length(ROIinfo) >= TrialNo && ~isempty(ROIinfo{TrialNo})

    for i = 1:length(ROIinfo{TrialNo}.ROIpos) % num ROIs
        pos = ROIinfo{TrialNo}.ROIpos{i};
        if i == CurrentROINo
            lw = 2;
        else
            lw = 1;
        end
        if ~isempty(pos)
            line(pos(:,1),pos(:,2), 'Color', 'r', 'LineWidth', lw);
            text(median(pos(:,1)), median(pos(:,2)), num2str(i),'Color','g','FontSize',15);
        end
    end
end

function figScroll(src,evnt, hObject, eventdata, handles)
global CaTrials ROIinfo
% callback function for mouse scroll
% 
im = handles.userdata.ImageArray;
fr = str2double(get(handles.CurrentFrameNoEdit, 'String'));
sc = handles.userdata.Scale;
nFrames = handles.userdata.nFrames;
% axes(handles.Image_disp_axes);
if evnt.VerticalScrollCount > 0
    if fr < nFrames
        fr = fr + 1;
    end
    
elseif evnt.VerticalScrollCount < 0
    if fr > 1
        fr = fr - 1;
    end  
end

set(handles.FrameSlider,'Value', fr/nFrames);

handles.userdata.FrameNum = fr;
set(handles.CurrentFrameNoEdit, 'String', num2str(fr));

handles.userdata.h_img = imagesc(im(:,:,fr), sc);
colormap(gray);

handles = update_image_axes(hObject, eventdata, handles);

% Update handles structure
% guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% End of Independent functions %%%%%%%%%%%%%%%%%%%%%%%%%


function dispModeWithROI_Callback(hObject, eventdata, handles)
value = get(handles.dispModeWithROI,'Value');
handles = update_image_axes(hObject, eventdata, handles);
update_projection_images(hObject,eventdata,handles);

function DataPathEdit_Callback(hObject, eventdata, handles)
handles.datapath = get(hObject, 'String');
guidata(hObject, handles);

function DataPathEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_add_Callback(hObject, eventdata, handles)

global CaTrials ROIinfo

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CaTrials(TrialNo).nROIs = CaTrials(TrialNo).nROIs + 1;
set(handles.nROIsText, 'String', num2str(CaTrials(TrialNo).nROIs));

CurrentROINo = get(handles.CurrentROINoEdit,'String');
if strcmp(CurrentROINo, '0')
    set(handles.CurrentROINoEdit,'String', '1');
%     str_menu = get(handles.ROITypeMenu,'String');
%     ROIinfo{TrialNo}.ROIType{CurrentROINo} = str_menu{get(handles.ROITypeMenu,'Value')};
end;
guidata(hObject, handles);


function ROI_del_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
if CurrentROINo > 0
    if ishandle(handles.userdata.ROIplot{CurrentROINo})
        delete(handles.userdata.ROIplot{CurrentROINo})
    end
    handles.userdata.ROIplot(CurrentROINo)=[];
    ROIinfo{TrialNo}.ROIpos(CurrentROINo) = [];
    ROIinfo{TrialNo}.ROIMask(CurrentROINo) = [];
    ROIinfo{TrialNo}.ROIType(CurrentROINo) = [];
    CaTrials(TrialNo).nROIs = CaTrials(TrialNo).nROIs - 1;
    CaTrials(TrialNo).ROIinfo = ROIinfo{TrialNo};
    set(handles.nROIsText, 'String', num2str(CaTrials(TrialNo).nROIs));
    set(handles.CurrentROINoEdit,'String', int2str(CurrentROINo - 1));
    % TotROI = get(handles.nROIsText, 'String');
    % if strcmp(TotROI, '0');
    %     set(handles.CurrentROINoEdit,'String', '0');
    % end
    handles = update_ROI_plot(hObject, eventdata, handles);
end
guidata(hObject, handles);


function ROI_pre_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
CurrentROINo = CurrentROINo - 1;
if CurrentROINo <= 0
    CurrentROINo = 1;
end;
set(handles.CurrentROINoEdit,'String',int2str(CurrentROINo));

str_menu = get(handles.ROITypeMenu,'String');
ROIType_str = ROIinfo{TrialNo}.ROIType{CurrentROINo};
if ~isempty(ROIType_str)
    ROIType_num = find(strcmp(ROIType_str, str_menu));
    set(handles.ROITypeMenu,'Value', ROIType_num);
else
    ROIType_str = str_menu{get(handles.ROITypeMenu,'Value')};
    ROIinfo{TrialNo}.ROIType{CurrentROINo} = ROIType_str;
end

handles = update_ROI_plot(hObject, eventdata, handles);
handles = update_projection_images(hObject,eventdata,handles);
guidata(hObject, handles);



function ROI_next_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
CurrentROINo = CurrentROINo + 1;
if CurrentROINo > str2double(get(handles.nROIsText,'String')) 
    CurrentROINo = str2double(get(handles.nROIsText,'String')) ;
end;
set(handles.CurrentROINoEdit,'String',int2str(CurrentROINo));

str_menu = get(handles.ROITypeMenu,'String');
if length(ROIinfo{TrialNo}.ROIType)>= CurrentROINo
    % ~isempty(ROIinfo{TrialNo}.ROIType{CurrentROINo})
    
    ROIType_str = ROIinfo{TrialNo}.ROIType{CurrentROINo};
    if ~isempty(ROIType_str)
        ROIType_num = find(strcmp(ROIType_str, str_menu));
        set(handles.ROITypeMenu,'Value', ROIType_num);
    else
        ROIType_str = str_menu{get(handles.ROITypeMenu,'Value')};
        ROIinfo{TrialNo}.ROIType{CurrentROINo} = ROIType_str;
    end
else
    ROIinfo{TrialNo}.ROIType{CurrentROINo} = str_menu{get(handles.ROITypeMenu,'Value')};
end
handles = update_ROI_plot(hObject, eventdata, handles);
handles = update_projection_images(hObject,eventdata,handles);
guidata(hObject, handles);


function ROI_del_all_Callback(hObject, eventdata, handles)


function CurrentROINoEdit_Callback(hObject, eventdata, handles)
handles = update_ROI_plot(hObject, eventdata, handles);
guidata(hObject, handles);


function CurrentROINoEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ROI_set_poly_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if length(ROIinfo) < TrialNo || isempty(ROIinfo{TrialNo}) ...
        || ~isfield(ROIinfo{TrialNo}, 'ROIpos')
    % Initialize ROIinfo for the CurrentROINo
    ROIinfo{TrialNo}(1).ROIpos = {};
    ROIinfo{TrialNo}(1).ROIMask = {};
    ROIinfo{TrialNo}(1).BGpos = [];
    ROIinfo{TrialNo}(1).BGmask = [];
    ROIinfo{TrialNo}(1).ROIType = {};
   % handles.userdata.ROIplot = {};    
end
% if ~isfield(ROIinfo{TrialNo}, 'ROIType'),
%     ROIinfo{TrialNo}(1).ROIType = {};
% end
waitforbuttonpress;
% [BW,xi,yi] = roipoly;
h_poly = impoly('Closed',false); % create ploygon object
pos = getPosition(h_poly);
BW = createMask(h_poly);
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
ROIinfo{TrialNo}.ROIpos{CurrentROINo} = pos;
ROIinfo{TrialNo}.ROIMask{CurrentROINo} = BW;

str_menu = get(handles.ROITypeMenu,'String');
ROIinfo{TrialNo}.ROIType{CurrentROINo} = str_menu{get(handles.ROITypeMenu,'Value')};

axes(handles.Image_disp_axes);
delete(h_poly); % delete polygon object

if length(handles.userdata.ROIplot) >= CurrentROINo & ishandle(handles.userdata.ROIplot{CurrentROINo})
    delete(handles.userdata.ROIplot{CurrentROINo});
else
    handles.userdata.ROIplot{CurrentROINo} = [];
end
%handles.userdata.roi_line(CurrentROINo) = line(pos(:,1),pos(:,2), 'Color', 'r', 'LineWidth', 2);
handles = update_ROI_plot(hObject, eventdata, handles);
handles = update_projection_images(hObject,eventdata,handles);
ROITypeMenu_Callback(hObject, eventdata, handles);

guidata(hObject, handles);



function ROI_modify_toggle_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
pos = ROIinfo{TrialNo}.ROIpos{CurrentROINo};
h_axes = handles.Image_disp_axes;
% handles = update_ROI_plot(hObject, eventdata, handles);
% handles = update_projection_images(hObject,eventdata,handles);

if get(hObject, 'Value')==1
    handles.userdata.current_poly_obj = impoly(h_axes, pos);
elseif get(hObject, 'Value')== 0 
    if isa(handles.userdata.current_poly_obj, 'imroi')
        pos = getPosition(handles.userdata.current_poly_obj);
        BW = createMask(handles.userdata.current_poly_obj);
        ROIinfo{TrialNo}.ROIpos{CurrentROINo} = pos;
        ROIinfo{TrialNo}.ROIMask{CurrentROINo} = BW;
        axes(h_axes);
        delete(handles.userdata.current_poly_obj); % delete polygon object
        if ishandle(handles.userdata.ROIplot{CurrentROINo})
            delete(handles.userdata.ROIplot{CurrentROINo});
        end
        handles.userdata.ROIplot{CurrentROINo} = [];
        % handles.userdata.roi_line(CurrentROINo) = line(pos(:,1),pos(:,2), 'Color', 'r', 'LineWidth', 2);
         handles = update_ROI_plot(hObject, eventdata, handles);
         handles = update_projection_images(hObject,eventdata,handles);
    end;
end;
guidata(hObject, handles);


function getROITrialNoEdit_Callback(hObject, eventdata, handles)
getROIinfoButton_Callback(hObject, eventdata, handles)

% --- Executes on button press in getROIinfoButton.
function getROIinfoButton_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
% The trialNo to load ROIinfo from
TrialNo_load = str2double(get(handles.getROITrialNoEdit,'String'));
FileName_prefix = CaTrials(TrialNo).FileName_prefix;

if length(ROIinfo)>= TrialNo_load
    ROIinfo{TrialNo} = ROIinfo{TrialNo_load};
elseif exist(['ROIinfo_' FileName_prefix '.mat'],'file')
    load([FileName_prefix 'ROIinfo.mat'], '-mat');
    if length(CaTrials)>= TrialNo_load
        ROIinfo{TrialNo} = ROIinfo{TrialNo_load};
    end
end
nROIs = length(ROIinfo{TrialNo}.ROIpos);
CaTrials(TrialNo).nROIs = nROIs;
set(handles.nROIsText, 'String', num2str(nROIs));
handles = update_ROI_plot(hObject, eventdata, handles);
handles = update_projection_images(hObject,eventdata,handles);
guidata(hObject, handles);

function getROITrialNoEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ROITypeMenu_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
Menu = get(handles.ROITypeMenu,'String');
% CaTrials(TrialNo).ROIType{CurrentROINo} = Menu{get(handles.ROITypeMenu,'Value')};
ROIinfo{TrialNo}.ROIType{CurrentROINo} = Menu{get(handles.ROITypeMenu,'Value')};
guidata(hObject, handles);

function handles = CalculatePlotButton_Callback(hObject, eventdata, handles, im, plot_flag)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
% ROIMask = CaTrials(TrialNo).ROIMask;
if nargin < 4
im = handles.userdata.ImageArray;
end    
if nargin < 5 %~exist('plot_flag','var')
    plot_flag = 1;
end
if ~isempty(ROIinfo{TrialNo}.BGmask)
    BGmask = repmat(ROIinfo{TrialNo}.BGmask,[1 1 size(im,3)]) ;
    BG_img = BGmask.*double(im);
    BG_img(BG_img==0) = NaN;
    BG = reshape(nanmean(nanmean(BG_img)),1,[]); % 1-by-nFrames array
else
    BG = 0;
end;
nROI_effective = length(ROIinfo{TrialNo}.ROIpos);
F = zeros(nROI_effective, size(im,3));
deltaFF = zeros(size(F));
dff = zeros(size(F));

for i = 1: nROI_effective
    ROImask = ROIinfo{TrialNo}.ROIMask{i};
    mask = repmat(ROImask, [1 1 size(im,3)]); % reproduce masks for every frame
    roi_img = mask .* double(im);
    roi_img(roi_img<=0) = NaN;
    % F(:,i) = nanmean(nanmean(roi_img));
    F(i,:) = nanmean(nanmean(roi_img));
    if get(handles.AnalysisModeBGsub,'Value') == 1
        F(i,:) = F(i,:) - BG;
    end;
    if get(handles.AnalysisModeDeltaFF,'Value') == 1
        [N,X] = hist(F(i,:));
        F_mode = X(find(N==max(N)));
        baseline = mean(F_mode);
        deltaFF(i,:) = (F(i,:)- baseline)./baseline*100;
        dff(i,:) = deltaFF(i,:);
    else
%         CaTrace(i,:) = F(i,:);
    end
end;
CaTrials(TrialNo).dff = dff;
CaTrials(TrialNo).f_raw = F;
ts = (1:CaTrials(TrialNo).nFrames).*CaTrials(TrialNo).FrameTime;
if plot_flag == 1
    handles.userdata.h_CaTrace_fig = plot_CaTraces_ROIs(dff, ts);
end
guidata(hObject, handles);

function doBatchButton_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
batchPrefix = get(handles.batchPrefixEdit, 'String');
Start_trial = str2double(get(handles.batchStartTrial, 'String'));
End_trial = str2double(get(handles.batchEndTrial,'String'));
% CaTrials = [];
h = waitbar(0, 'Start Batch Analysis ...');
for TrialNo = Start_trial:End_trial
    fname = handles.userdata.data_file_names{TrialNo};
    if ~exist(fname,'file')
        [fname, pathname] = uigetfile('*.tif', 'Select Image Data file');
        cd(pathname);
    end;
    msg_str1 = sprintf('Batch analyzing %d of total %d trials with %d ROIs...', ...
        TrialNo, End_trial-Start_trial+1, CaTrials(1).nROIs);  
%     disp(['Batch analyzing ' num2str(TrialNo) ' of total ' num2str(End_trial-Start_trial+1) ' trials...']);
    disp(msg_str1);
    waitbar(TrialNo/(End_trial-Start_trial+1), h, msg_str1);
    set(handles.msgBox, 'String', msg_str1);
    [im, header] = imread_multi(fname, 'g');
    if (length(CaTrials)<TrialNo || isempty(CaTrials(TrialNo).FileName))
        trial_init = init_CaTrial(fname,TrialNo,header);
        CaTrials(TrialNo) = trial_init;
    end
    set(handles.CurrentTrialNo,'String', int2str(TrialNo));
    % if isempty(ROIinfo{TrialNo})
    %###########################################################################
    % Make sure the ROIinfo of the first trial of the batch is up to date
    if TrialNo > Start_trial && ~isempty(ROIinfo{TrialNo-1}.ROIpos)
        ROIinfo{TrialNo} = ROIinfo{TrialNo-1};
    end
    %##########################################################################
    % end
%     handles = update_image_axes(hObject, eventdata, handles,im);
    handles = CalculatePlotButton_Callback(hObject, eventdata, handles, im, 0);
%     handles = update_projection_images(hObject,eventdata,handles);
    handles = get_exp_info(hObject, eventdata, handles);
%     CaTrials(TrialNo).meanImage = mean(im,3);
%     close(handles.userdata.h_CaTrace_fig);
    set(handles.CurrentTrialNo, 'String', int2str(TrialNo));
    set(handles.CurrentImageFilenameText,'String',fname);
%     set(handles.nROIsText,'String',int2str(length(ROIinfo{TrialNo}.ROIpos)));
    guidata(hObject, handles);
end

SaveResultsButton_Callback(hObject, eventdata, handles);
close(h);
disp(['Batch analysis completed for ' CaTrials(1).FileName_prefix]);
set(handles.msgBox, 'String', ['Batch analysis completed for ' CaTrials(1).FileName_prefix]);

function SaveResultsButton_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
FileName_prefix = CaTrials(TrialNo).FileName_prefix;
% CaTrials = CaTrials;
% ROIinfo = ROIinfo;
for i = 1:length(ROIinfo)
    if isfield(ROIinfo{i},'ROIpos')
        CaTrials(i).nROIs = length(ROIinfo{i}.ROIpos);
        % save ROIinfo reduntantly to be safe.
        CaTrials(i).ROIinfo = ROIinfo{i};
    end
end
save(handles.userdata.results_fn, 'CaTrials');
save(handles.userdata.results_roiinfo, 'ROIinfo');
msg_str = sprintf('CaTrials Saved, with %d trials, %d ROIs', length(CaTrials), CaTrials(TrialNo).nROIs);
disp(msg_str);
set(handles.msgBox, 'String', msg_str);
save_gui_info(handles);

function batchStartTrial_Callback(hObject, eventdata, handles)

function batchStartTrial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function batchEndTrial_Callback(hObject, eventdata, handles)

function batchEndTrial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dispModeGreen_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if CaTrials(TrialNo).DaqInfo.acq.numberOfChannelsAcquire == 1
    set(hObject,'Value',1);
end;

function dispModeImageInfoButton_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
if get(hObject, 'Value') == 1
    handles.userdata.h_info_fig = figure; set(gca, 'Visible', 'off');
    f_pos = get(handles.userdata.h_info_fig, 'Position'); f_pos(3) = f_pos(3)/2;
    set(handles.userdata.h_info_fig, 'Position', f_pos);
    info_disp = handles.userdata.info_disp;
    for i = 1: length(info_disp),
        x = 0.01;
        y=1-i/length(info_disp);
        text(x,y,info_disp{i},'Interpreter','none');
    end
    guidata(hObject, handles);
else
    close(handles.userdata.h_info_fig);
end


function nROIsText_CreateFcn(hObject, eventdata, handles)

function figure1_DeleteFcn(hObject, eventdata, handles)
global CaTrials ROIinfo
save_gui_info(handles);
clear CaTrials ROIinfo
% close all;

function CurrentTrialNo_Callback(hObject, eventdata, handles)

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if TrialNo>0
    filename = handles.userdata.data_file_names{TrialNo};
    if exist(filename,'file')
        open_image_file_button_Callback(hObject, eventdata, handles,filename);
    end
end

function PrevTrialButton_Callback(hObject, eventdata, handles)

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if TrialNo>1
    filename = handles.userdata.data_file_names{TrialNo-1};
    if exist(filename,'file')
        open_image_file_button_Callback(hObject, eventdata, handles,filename);
    end
end

function NextTrialButton_Callback(hObject, eventdata, handles)

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if  TrialNo+1 <= length(handles.userdata.data_file_names) % exist(filename,'file')
    filename = handles.userdata.data_file_names{TrialNo+1};
    open_image_file_button_Callback(hObject, eventdata, handles,filename);
end

function AnalysisModeBGsub_Callback(hObject, eventdata, handles)



function batchPrefixEdit_Callback(hObject, eventdata, handles)


function batchPrefixEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function AnimalNameEdit_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CaTrials(TrialNo).AnimalName = get(hObject, 'String');
guidata(hObject, handles);
save_gui_info(handles);

function AnimalNameEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ExpDate_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CaTrials(TrialNo).ExpDate = get(hObject, 'String');
guidata(hObject, handles);
save_gui_info(handles);

function ExpDate_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SessionName_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CaTrials(TrialNo).SessionName = get(hObject, 'String');
guidata(hObject, handles);
save_gui_info(handles);

function SessionName_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FrameSlider_Callback(hObject, eventdata, handles)

slider_value = get(hObject,'Value');
nFrames = handles.userdata.nFrames;
new_frameNum = ceil(nFrames*slider_value);
if new_frameNum == 0, new_frameNum = 1; end;
set(handles.CurrentFrameNoEdit, 'String', num2str(new_frameNum));
handles = update_image_axes(hObject, eventdata, handles);
guidata(hObject, handles);

function FrameSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function CurrentFrameNoEdit_Callback(hObject, eventdata, handles)

update_image_axes(hObject, eventdata, handles);

function CurrentFrameNoEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LUTminEdit_Callback(hObject, eventdata, handles)

handles = update_image_axes(hObject, eventdata, handles);
handles = update_projection_images(hObject, eventdata, handles);
guidata(hObject, handles);

function LUTminEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LUTmaxEdit_Callback(hObject, eventdata, handles)

handles = update_image_axes(hObject, eventdata, handles);
handles = update_projection_images(hObject, eventdata, handles);
guidata(hObject, handles);

function LUTmaxEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LUTminSlider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value_min = get(hObject,'Value');
value_max = get(handles.LUTmaxSlider,'Value');
if value_min >= value_max
    value_min = value_max - 0.01;
    set(hObject, 'Value', value_min);
end;
set(handles.LUTminEdit, 'String', num2str(value_min*1000));
handles = update_image_axes(hObject, eventdata, handles);
handles = update_projection_images(hObject, eventdata, handles);
guidata(hObject, handles);


function LUTminSlider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function LUTmaxSlider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value_max = get(hObject,'Value');
value_min = get(handles.LUTminSlider, 'Value');
if value_max <= value_min
    value_max = value_min + 0.01;
    set(hObject, 'Value', value_max);
end;
set(handles.LUTmaxEdit, 'String', num2str(value_max*1000));
handles = update_image_axes(hObject, eventdata, handles);
handles = update_projection_images(hObject, eventdata, handles);
guidata(hObject, handles);


function dispMeanMode_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')==1
    handles = update_projection_images(hObject,eventdata,handles);
else
    try
        if ishandle(handles.userdata.h_mean_fig)
            delete(handles.userdata.h_mean_fig);
        end;
    catch ME
    end
end
guidata(hObject, handles);


function dispMaxDelta_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')==1
    handles = update_projection_images(hObject,eventdata,handles);
else
    try
        if ishandle(handles.userdata.h_maxDelta_fig)
            delete(handles.userdata.h_maxDelta_fig);
        end;
    catch ME
    end
end
guidata(hObject, handles);

function dispMaxMode_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')==1
    handles = update_projection_images(hObject,eventdata,handles);
else
    try
        if ishandle(handles.userdata.h_max_fig)
            delete(handles.userdata.h_max_fig);
        end;
    catch ME
    end
end
guidata(hObject, handles);

function ROITypeMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dispModeGreen_CreateFcn(hObject, eventdata, handles)

function LUTmaxSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in SaveFrameButton.
function SaveFrameButton_Callback(hObject, eventdata, handles)

im = handles.userdata.ImageArray;
fr = str2double(get(handles.CurrentFrameNoEdit,'String'));
dataFileName = get(handles.CurrentImageFilenameText, 'String');

[fname, pathName] = uiputfile([dataFileName(1:end-4) '_' int2str(fr) '.tif'], 'Save the current frame as');
if ~isequal(fname, 0)&& ~isequal(pathName, 0)
    imwrite(im(:,:,fr), [pathName fname], 'tif','WriteMode','overwrite','Compression','none');
end


% --- Executes on button press in setTargetForTrial.
function setTargetForTrial_Callback(hObject, eventdata, handles)



% --- Executes on button press in setTargetForSession.
function setTargetForSession_Callback(hObject, eventdata, handles)
% hObject    handle to setTargetForSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of setTargetForSession


% --- Executes on button press in setTargetCurrentFrame.
function setTargetCurrentFrame_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2num(get(handles.CurrentTrialNo, 'String'));
if get(hObject,'Value') == 1
    fr = str2num(get(handles.CurrentFrameNoEdit, 'String'));
    handles.userdata.RegTarget = handles.userdata.ImageArray(:,:,fr);
    CaTrials(TrialNo).RegTargetFrNo = fr;
    set(handles.setTargetMean, 'Value', 0);
    set(handles.setTargetMaxDelta, 'Value', 0);
end
guidata(hObject, handles);


% --- Executes on button press in setTargetMean.
function setTargetMean_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles.userdata.RegTarget = uint16(mean(handles.userdata.ImageArray,3));
    set(handles.setTargetCurrentFrame, 'Value', 0);
    set(handles.setTargetMaxDelta, 'Value', 0);
end
guidata(hObject, handles);

% --- Executes on button press in setTargetMaxDelta.
function setTargetMaxDelta_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    if isfield(handles.userdata, 'MaxDelta')&& ~isempty(handles.userdata.MaxDelta)
        handles.userdata.RegTarget = handles.userdata.MaxDelta;
    else
        im = handles.userdata.ImageArray;
        mean_im = uint16(mean(im,3));
        im = im_mov_avg(im,5);
        max_im = max(im,[],3);
        handles.userdata.RegTarget = max_im - mean_im;
        set(handles.setTargetCurrentFrame, 'Value', 0);
        set(handles.setTargetMean, 'Value', 0);
    end 
end
guidata(hObject, handles);

% --- Executes on button press in RegCurrentTrial.
function RegCurrentTrial_Callback(hObject, eventdata, handles)
% Motion correction by for the current trial
% setTargetCurrentFrame_Callback(hObject, eventdata, handles);
% setTargetMaxDelta_Callback(hObject, eventdata, handles);
% setTargetMean_Callback(hObject, eventdata, handles);
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
RegMethod_id = get(handles.RegMethodMenu,'Value');
RegMethod_string = get(handles.RegMethodMenu,'String');
switch get(handles.RegMethodMenu,'Value')
    case 2 % 'TurboReg'
        ImageReg = Turboreg_nx3(handles.userdata.RegTarget, handles.userdata.ImageArray,'translation',0);
    case {3 4} % 'dft_Reg'
        tg_img = handles.userdata.RegTarget;
        src_img = handles.userdata.ImageArray;
        for i=1:size(src_img,3);
            output(:,i) = dftregistration(fft2(double(tg_img)),fft2(double(src_img(:,:,i))),1);
        end
        shift = output(3:4,:);
%         if size(src_img,1) > CaTrials(TrialNo).DaqInfo.acq.linesPerFrame
%             % if the source image is already padded image from the original
%             % data, then do not padding
%             padding = [0 0 0 0];
%         else
%             % Otherwise, pad the image matrix according to the shift pixels
%             padding = [];
%         end
        padding = [0 0 0 0];
        ImageReg = ImageTranslation_nx(src_img,shift,padding,0);
        figure('Name','Image shiftings');
        dist_shifted = sqrt(shift(1,:).^2 + shift(2,:).^2);
        plot(dist_shifted);
        xlabel('# Frame'); ylabel('Shift Distance');
        disp(['mean shifting for all frames: ' num2str(mean(dist_shifted))]);
end;
disp(['Completed registration of the current trial using ' RegMethod_string{RegMethod_id}]);
handles.userdata.ImageArray = ImageReg;
update_image_axes(hObject, eventdata, handles);
guidata(hObject,handles)

% --- Executes on button press in RegCurrentSession.
function RegCurrentSession_Callback(hObject, eventdata, handles)
% 
% setTargetCurrentFrame_Callback(hObject, eventdata, handles);
% setTargetMaxDelta_Callback(hObject, eventdata, handles);
% setTargetMean_Callback(hObject, eventdata, handles);
filename_base = get(handles.batchPrefixEdit, 'String');
targetImage = handles.userdata.RegTarget;
sorce_filenames = handles.userdata.data_file_names;
ref_trial_num = str2num(get(handles.CurrentTrialNo, 'String'));
shift = [];
switch get(handles.RegMethodMenu,'Value')
    case 2 % 'TurboReg'
        for i = 1:length(handles.userdata.data_file_names)
            disp(['Registering data file: ' sorce_filenames{i} ' ...']);
            Turboreg_nx3(targetImage, sorce_filenames{i}, 'translation',1);
        end
        save(['dft_reg\' filename_base '[dftShift].mat'], 'shift','ref_trial_num');
    case 3 % 'dft_Reg'
        shift = batch_dft_reg(targetImage, sorce_filenames, 0);
        % save reg info
        save(['dft_reg\' filename_base '[dftShift].mat'], 'shift','ref_trial_num');
    case 4 % 'dft_Reg_padded', padding the orignal image to accomadate the maximum pixel shifts accross trials
        shift = batch_dft_reg(targetImage, sorce_filenames, 1);
end;
handles.userdata.dftreg_shift = shift;
guidata(hObject,handles);

% --- Executes on button press in SaveRegImage.
function SaveRegImage_Callback(hObject, eventdata, handles)
im = handles.userdata.ImageArray;
currentFileName = get(handles.CurrentImageFilenameText, 'String');
im_describ = handles.userdata.ImageDescription;
% if the current file is not the original data, then overwrite it,
% otherwise create another file for the registered image
switch get(handles.RegMethodMenu,'Value')
    case 2 % 'TurboReg'
        if isempty(findstr(pwd, 'turboreg'))
            saveName = [currentFileName(1:end-7) 'reg_' currentFileName(end-6:end)];
            savePath = [pwd filesep 'turboreg_corrected'];
        else
            saveName = currentFileName;
            savePath = pwd;
        end;
    case {3, 4}% 'dft_Reg'
        if isempty(findstr(pwd, 'dft_reg'))
            savePath = [pwd filesep 'dft_reg'];
            saveName = [currentFileName(1:end-7) '_dftReg_' currentFileName(end-6:end-4) '.tif'];
        else
            saveName = currentFileName;
            savePath = pwd;
        end
end
if ~exist(savePath, 'dir')
    mkdir(savePath);
end
for i = 1:size(im,3)
    if i == 1,
        imwrite(im(:,:,i),[savePath filesep saveName],'tif','Compression','none','Description',im_describ,'WriteMode','overwrite');
    else
        imwrite(im(:,:,i),[savePath filesep saveName],'tif','Compression','none','WriteMode','append');
    end
end
disp(['Registered image saved as ' saveName]);
set(handles.msgBox, 'String', ['Registered image saved as ' saveName]);


% --- Executes on button press in BG_poly_set.
function BG_poly_set_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
%    if isempty(CaTrials(TrialNo).BGmask)
waitforbuttonpress;
[BW,xi,yi] = roipoly;
ROIinfo{TrialNo}.BGmask = BW;
ROIinfo{TrialNo}.BGpos = [xi yi];
% axes(handles.userdata.image_disp_gui.Image_disp_axes);
% if isfield(handles.userdata, 'BGplot')&& ishandle(handles.userdata.BGplot)
%     delete(handles.userdata.BGplot);
% end
% handles.userdata.BGplot = line(xi, yi, 'Color','b', 'LineWidth',2);
handles = update_ROI_plot(hObject, eventdata, handles);       
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function AnalysisModeBGsub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AnalysisModeBGsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in RegMethodMenu.
function RegMethodMenu_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function RegMethodMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RegMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MotionEstmOptions.
function MotionEstmOptions_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns MotionEstmOptions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MotionEstmOptions

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
switch get(hObject,'Value')
    case 2 % plot cross correlation coef for the current trial
        img = handles.userdata.ImageArray;
        xcoef = xcoef_img(img);
        figure('Name', ['xCorr. Coefficient for Trial ' num2str(TrialNo)], 'Position', [1200 300 480 300]);
        plot(xcoef); xlabel('Frame #'); ylabel('Corr. Coeff');
        disp(sprintf(['mean xCorr. Coefficient for trial ' num2str(TrialNo) ': %g'],mean(xcoef)));
    case 3 % Compute cross correlation across all trials
        n_trials = length(handles.userdata.data_file_names);
        if isempty(handles.userdata.avgCorrCoef_trials)
            xcoef_trials = zeros(n_trials,1);
            h_wait = waitbar(0, 'Calculating cross correlation coefficients for trial 0 ...');
            for i = 1:n_trials
                waitbar(i/n_trials, h_wait, ['Calculating cross correlation coefficients for trial ' num2str(i)]);
                img = imread_multi(handles.userdata.data_file_names{i},'g');
                xcoef = xcoef_img(img);
                xcoef_trials(i) = mean(xcoef);
            end
            close(h_wait);
            handles.userdata.avgCorrCoef_trials = xcoef_trials;
        else
            xcoef_trials = handles.userdata.avgCorrCoef_trials;
        end
        figure('Name', 'xCorr. Coef across all trials', 'Position', [1200 300 480 300]);
        plot(xcoef_trials); xlabel('Trial #'); ylabel('mean Corr. Coeff');
    case 4
        
    case 5
        if ~isempty(handles.userdata.dftreg_shift)
            for i = 1:str2num(get(handles.TotTrialNum, 'String'))
                avg_shifts(i) = max(mean(abs(handles.userdata.dftreg_shift(:,:,i)),2));
            end
            figure;
            plot(avg_shifts,'LineWidth',2); 
            title('Motion estimation of all trials','FontSize',18);
            xlabel('Trial #', 'FontSize', 15); ylabel('Mean shift of all frames', 'FontSize', 15);
        end
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function MotionEstmOptions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MotionEstmOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function save_gui_info(handles)
info.DataPath = pwd;
info.AnimalName = get(handles.AnimalNameEdit,'String');
info.ExpDate = get(handles.ExpDate,'String');
info.SessionName = get(handles.SessionName, 'String');
info.SoloDataPath = get(handles.SoloDataPath, 'String');
info.SoloDataFileName = get(handles.SoloDataFileName, 'String');
info.SoloSessionName = get(handles.SoloSessionName, 'String');
info.SoloStartTrialNo = get(handles.SoloStartTrialNo, 'String');
info.SoloEndTrialNo = get(handles.SoloEndTrialNo, 'String');

usrpth = userpath; usrpth = usrpth(1:end-1);
save([usrpth filesep 'nx_CaSingal.info'], 'info');



function SoloStartTrialNo_Callback(hObject, eventdata, handles)
% hObject    handle to solostarttrialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of solostarttrialno as text
%        str2double(get(hObject,'String')) returns contents of solostarttrialno as a double


% --- Executes during object creation, after setting all properties.
function SoloStartTrialNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to solostarttrialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SoloEndTrialNo_Callback(hObject, eventdata, handles)
% hObject    handle to soloendtrialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of soloendtrialno as text
%        str2double(get(hObject,'String')) returns contents of soloendtrialno as a double


% --- Executes during object creation, after setting all properties.
function SoloEndTrialNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to soloendtrialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SoloDataPath_Callback(hObject, eventdata, handles)
% hObject    handle to solodatapath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of solodatapath as text
%        str2double(get(hObject,'String')) returns contents of solodatapath as a double


% --- Executes during object creation, after setting all properties.
function SoloDataPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to solodatapath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SoloDataFileName_Callback(hObject, eventdata, handles)
% hObject    handle to solodatafilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of solodatafilename as text
%        str2double(get(hObject,'String')) returns contents of solodatafilename as a double


% --- Executes during object creation, after setting all properties.
function SoloDataFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to solodatafilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addBehavTrials.
function addBehavTrials_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo

Solopath = get(handles.SoloDataPath,'String');
mouseName = get(handles.AnimalNameEdit, 'String');
sessionName = get(handles.SoloSessionName, 'String');
trialStartEnd(1) = str2num(get(handles.SoloStartTrialNo, 'String'));
trialStartEnd(2) = str2num(get(handles.SoloEndTrialNo, 'String'));
trailsToBeExcluded = str2num(get(handles.behavTrialNoToBeExcluded, 'String'));

[Solo_data, SoloFileName] = Solo.load_data_nx(mouseName, sessionName,trialStartEnd,Solopath);
set(handles.SoloDataFileName, 'String', SoloFileName);
behavTrialNums = trialStartEnd(1):trialStartEnd(2);
behavTrialNums(trailsToBeExcluded) = [];

if length(behavTrialNums) ~= str2num(get(handles.TotTrialNum, 'String'))
    error('Number of behavior trials NOT equal to Number of Ca Image Trials!')
end

for i = 1:length(behavTrialNums)
    behavTrials(i) = Solo.BehavTrial_nx(Solo_data,behavTrialNums(i),1);
    CaTrials(i).behavTrial = behavTrials(i);
end
disp([num2str(i) ' Behavior Trials added to CaTrials']);
set(handles.msgBox, 'String', [num2str(i) ' Behavior Trials added to CaTrials']);
guidata(hObject, handles)


function SoloSessionName_Callback(hObject, eventdata, handles)
Solopath = get(handles.SoloDataPath,'String');
mouseName = get(handles.AnimalNameEdit, 'String');
sessionName = get(handles.SoloSessionName, 'String');
trialStartEnd(1) = str2num(get(handles.SoloStartTrialNo, 'String'));
trialStartEnd(2) = str2num(get(handles.SoloEndTrialNo, 'String'));

[Solo_data, SoloFileName] = Solo.load_data_nx(mouseName, sessionName,trialStartEnd,Solopath);
set(handles.SoloDataFileName, 'String', SoloFileName);


% --- Executes during object creation, after setting all properties.
function SoloSessionName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to solosessionname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function dispModeImageInfoButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispModeImageInfoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in ROI_move_left.
function ROI_move_left_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(handles.userdata.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
move_unit = 1* max(aspect_ratio,1);
for i = 1: length(ROIinfo{TrialNo}.ROIpos)
    ROIinfo{TrialNo}.ROIpos{i}(:,1) = ROIinfo{TrialNo}.ROIpos{i}(:,1)-move_unit;
    x = ROIinfo{TrialNo}.ROIpos{i}(:,1);
    y = ROIinfo{TrialNo}.ROIpos{i}(:,2);
    ROIinfo{TrialNo}.ROIMask{i} = poly2mask(x,y,imsize(1),imsize(2));
end;
handles = update_ROI_plot(hObject, eventdata, handles);
update_projection_image_ROIs(hObject,eventdata,handles);
guidata(hObject, handles)


% --- Executes on button press in ROI_move_right.
function ROI_move_right_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(handles.userdata.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
move_unit = 1* max(aspect_ratio,1);
for i = 1: length(ROIinfo{TrialNo}.ROIpos)
    ROIinfo{TrialNo}.ROIpos{i}(:,1) = ROIinfo{TrialNo}.ROIpos{i}(:,1)+move_unit;
    x = ROIinfo{TrialNo}.ROIpos{i}(:,1);
    y = ROIinfo{TrialNo}.ROIpos{i}(:,2);
    ROIinfo{TrialNo}.ROIMask{i} = poly2mask(x,y,imsize(1),imsize(2));
end;
handles = update_ROI_plot(hObject, eventdata, handles);
update_projection_image_ROIs(hObject,eventdata,handles);
guidata(hObject, handles)

% --- Executes on button press in ROI_move_up.
function ROI_move_up_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(handles.userdata.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
move_unit = 1* max(1/aspect_ratio,1);
for i = 1: length(ROIinfo{TrialNo}.ROIpos)
    ROIinfo{TrialNo}.ROIpos{i}(:,2) = ROIinfo{TrialNo}.ROIpos{i}(:,2)-move_unit;
    x = ROIinfo{TrialNo}.ROIpos{i}(:,1);
    y = ROIinfo{TrialNo}.ROIpos{i}(:,2);
    ROIinfo{TrialNo}.ROIMask{i} = poly2mask(x,y,imsize(1),imsize(2));
end;
handles = update_ROI_plot(hObject, eventdata, handles);
update_projection_image_ROIs(hObject,eventdata,handles);
guidata(hObject, handles)


% --- Executes on button press in ROI_move_down.
function ROI_move_down_Callback(hObject, eventdata, handles)

global CaTrials ROIinfo
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(handles.userdata.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
move_unit = 1* max(1/aspect_ratio,1);
for i = 1: length(ROIinfo{TrialNo}.ROIpos)
    ROIinfo{TrialNo}.ROIpos{i}(:,2) = ROIinfo{TrialNo}.ROIpos{i}(:,2)+move_unit;
    x = ROIinfo{TrialNo}.ROIpos{i}(:,1);
    y = ROIinfo{TrialNo}.ROIpos{i}(:,2);
    ROIinfo{TrialNo}.ROIMask{i} = poly2mask(x,y,imsize(1),imsize(2));
end;
handles = update_ROI_plot(hObject, eventdata, handles);
update_projection_image_ROIs(hObject,eventdata,handles);
guidata(hObject, handles)



function behavTrialNoToBeExcluded_Callback(hObject, eventdata, handles)
% hObject    handle to behavTrialNoToBeExcluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of behavTrialNoToBeExcluded as text
%        str2double(get(hObject,'String')) returns contents of behavTrialNoToBeExcluded as a double


% --- Executes during object creation, after setting all properties.
function behavTrialNoToBeExcluded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to behavTrialNoToBeExcluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dispCorrMapTrials.
function dispCorrMapTrials_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
currROI = str2num(get(handles.CurrentROINoEdit,'String'));
if get(handles.dispCorrMapTrials,'Value')==1
    if isempty(handles.userdata.CorrMapTrials) || ~isequal(handles.userdata.CorrMapROINo, currROI)
        [fn, pathname] = uigetfile([handles.userdata.results_path filesep '*.tif'],'Select image file of correlation map');
        handles.userdata.CorrMapTrials = imread_multi([pathname filesep fn]);
        handles.userdata.CorrMapROINo = currROI;
        % get the mean correlation map from trials with variance > 70 percentile
        dFF = get_dFF_roi(CaTrials, currROI);
        v = var(dFF,0,2);
        ind = find(v > prctile(v,70));
        handles.userdata.CorrMapMean = mean(handles.userdata.CorrMapTrials(:,:,ind),3);
    end
%     im = handles.userdata.CorrMapTrials;
    handles.userdata.nFrames = size(handles.userdata.CorrMapTrials,3);
    set(handles.CurrentFrameNoEdit,'String',num2str(1));
    update_image_axes(hObject, eventdata, handles);
else
    handles.userdata.nFrames = size(handles.userdata.ImageArray,3);
    update_image_axes(hObject, eventdata, handles);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function dispCorrMapTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispCorrMapTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function dFF_array = get_dFF_roi(CaTrials, roiNo)
nTrials = numel(CaTrials);
dFF_array = [];
for i = 1:nTrials
    if ~isempty(CaTrials(i).dff)
        if size(CaTrials(i).dff,1) < roiNo
            return;
        else
            dFF_array = [dFF_array; CaTrials(i).dff(roiNo,:)];
        end
    end
end
    
% --- Executes on button press in CorrMap_button.
function CorrMap_button_Callback(hObject, eventdata, handles)
global CaTrials ROIinfo
confirm = questdlg('Start computing spatial temporal correlation for all ROIs? It would take a long time!');
if ~strcmp(confirm, 'Yes')
    return
else
    savepath = handles.userdata.results_path;
    roiNums = 1:CaTrials(1).nROIs; 
    % fVar = var(dffROI,0,2);
    % ind = find(fVar > prctile(fVar,70)); % trNoROI; %  find(peakROI>80);
    nTr = length(CaTrials);
    width = CaTrials(1).DaqInfo.width;
    height = CaTrials(1).DaqInfo.height;
    
    for n = 1:numel(roiNums)
        crr_map = zeros(height,width,nTr);
        h = waitbar(0, sprintf('Analyzing %d of total %d ROIs',n,numel(roiNums)),... ) %['Analyzing ' num2str(n) ' of total ' num2str(numel(roiNums)) ' ROIs ...'],...
            'CreateCancelBtn', 'setappdata(gcbf,''cancelling'',1)');
        setappdata(h,'canceling',0);
        for k = 1:nTr
            if getappdata(h,'canceling')
                break
            end
            %     tr = ind(k);
            %     disp(['Analyzing ' imobj(tr).FileName]);
            fname = handles.userdata.data_file_names{k};
            im = imread_multi(fname,'g');
            f = CaTrials(k).f_raw(roiNums(n),:);
            for i=1:size(im,1)
                for j = 1:size(im,2)
                    p = double(im(i,j,:));
                    c = corrcoef(f,p);
                    crr_map(i,j,k) = c(2,1);
                end
            end
            
            waitbar(k/nTr,h, sprintf('Analyzing %d of total %d ROIs, in Trial %d...', n,numel(roiNums),k)); %  ['Analyzing ROI # ' num2str(roiNums(n)) ', Trial ' num2str(k) ' ...']);
            imwrite(crr_map(:,:,k),sprintf('%s%cCorrMapROI#%d.tif',savepath,filesep,roiNums(n)),'Compression','none','WriteMode','append');
        end
        delete(h);
        save(sprintf('%s%cCorr_Map_ROI_#%d.mat', savepath,filesep, roiNums(n)),'crr_map');
        %     axes(ax1); plot(dffROI(ind(k),:)); axes(ax2); imagesc(crr_im(:,:,k),[-0.1 1]);
    end
end

    


% --- Executes during object creation, after setting all properties.
function Image_disp_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Image_disp_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Image_disp_axes


% --- Executes during object creation, after setting all properties.
function msgBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msgBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in dispAspectRatio.
function dispAspectRatio_Callback(hObject, eventdata, handles)
global CaTrials
Str = get(hObject, 'String');
handles.userdata.AspectRatio_mode = Str{get(hObject,'Value')};
guidata(hObject, handles);
update_image_axes(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function dispAspectRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispAspectRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function frame_time_disp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_time_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in export2avi_button.
function export2avi_button_Callback(hObject, eventdata, handles)

global CaTrials
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
fname = CaTrials(TrialNo).FileName;
[movieFileName, pathname] = uiputfile([fname(1:end-4) '.avi'], 'Export current trial to an avi movie');
movObj = VideoWriter([pathname filesep movieFileName]);
movObj.FrameRate = 15;

open(movObj);

for i = 1:CaTrials(TrialNo).nFrames
    set(handles.CurrentFrameNoEdit,'String',num2str(i));
    handles = update_image_axes(hObject, eventdata, handles);
    F = getframe(handles.Image_disp_axes);
    writeVideo(movObj, F);
end
close(movObj);
% movie2avi(Mov,[pathname filesep movieFileName],'compression','none');
