function varargout = Leo_Ca_Analyzer(varargin)
% LEO_CA_ANALYZER M-file for Leo_Ca_Analyzer.fig
%      LEO_CA_ANALYZER, by itself, creates a new LEO_CA_ANALYZER or raises the existing
%      singleton*.
%
%      H = LEO_CA_ANALYZER returns the handle to a new LEO_CA_ANALYZER or the handle to
%      the existing singleton*.
%
%      LEO_CA_ANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LEO_CA_ANALYZER.M with the given input arguments.
%
%      LEO_CA_ANALYZER('Property','Value',...) creates a new LEO_CA_ANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Leo_Ca_Analyzer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Leo_Ca_Analyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% *************************************************************************
% 
%Bug Fix workaround for 2007b
% 
% This bug was fixed as of R2008a.
% 
% If you have a current subscription to MathWorks Software Maintenance Service (SMS), you can download product updates. If not, learn more about MathWorks SMS.
% Workaround
% If you are using a previous version, please read the following:
% 
% To work around this issue, replace the following files in your existing MATLAB installation with the updated versions attached.
% 
%    1. Determine the MATLAB root directory on your machine by typing
% 
%       matlabroot
% 
%       at the MATLAB prompt. This will be referred to as $MATLAB below.
%    2. Quit MATLAB.
%    3. Move to the following directory:
% 
%       cd $MATLAB/toolbox/images/imuitools/private
%    4. Make a back up copy of the following files. 
% 
%       mv polygonSymbol.m polygonSymbol.m.old
%       mv manageInteractivePlacement.m manageInteractivePlacement.m.old
% 
%    5. Download the attached M-files and store them in the current directory.
%    6. Restart MATLAB
%**************************************************************************
%
% Edit the above text to modify the response to help Leo_Ca_Analyzer

% Last Modified by GUIDE v2.5 05-May-2009 14:02:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Leo_Ca_Analyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @Leo_Ca_Analyzer_OutputFcn, ...
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


% --- Executes just before Leo_Ca_Analyzer is made visible.

function Leo_Ca_Analyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Leo_Ca_Analyzer (see VARARGIN)

% Choose default command line output for Leo_Ca_Analyzer
handles.output = hObject;
%handles.timePerLine = 0.002; % in s
handles.roiNumber=1;
handles.colorlist=rand(200,3)*0.9+0.1;
handles.displayChannel='G';
handles.imageHandle=[];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Leo_Ca_Analyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Leo_Ca_Analyzer_OutputFcn(hObject, eventdata, handles) 
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
try
    delete(handles.imageHandle)
catch
end

switch handles.displayChannel
    case 'G'
        activeChannel=handles.channels.G;
    case 'R'
        activeChannel=handles.channels.R;
end
frame=round(get(hObject,'Value'));
        im=imagesc(activeChannel(:,:,frame),[str2num(get(handles.MinValueText,'String')) str2num(get(handles.MaxValueText,'String'))]);
        handles.imageHandle=im;
        uistack(handles.imageHandle,'bottom')
        
        set(handles.FrameCounter,'String',[num2str(frame) '/' num2str(handles.numberOfFrames) ' | ' num2str(handles.numberOfRows * handles.timePerLine*frame) 's']);
guidata(handles.figure1,handles) ;
% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    delete(handles.imageHandle)

catch
end
%[handles.channels.G, handles.channels.R, handles.currentDirectory, handles.currentFile, handles.state] = loadScanImageMovie('avgFilter');%<-------------filter? 
[f p]=uigetfile('*.tif');
cd(p)
handles.currentFile=f;
handles.currentDirectory=p;
if get(handles.loadHeaderCheck,'Value')==0;
    Data=genericOpenTif(f);
    Data=uint16(Data);
    handles.channels.G=Data ;
    %     handles.channels.G=Data(:,:,1:2:end) ;
    %     handles.channels.R=Data(:,:,2:2:end);
else
    
    % [H Data]=scim_openTif(f);
    [Data H] = imread_multi(f,'green');
    handles.state=H;
    handles.channels.G = Data;
end
if get(handles.loadAvgFilterCheck,'Value')==1
    filter=fspecial('average',[2 2]);
    disp('filtering....')
    fImage=imfilter(handles.channels.G, filter, 'conv');
    handles.channels.G=fImage;
end
if ndims(Data)>3
    handles.channels.R=squeeze(Data(:,:,2,:));
    if get(handles.loadAvgFilterCheck,'Value')==1
        filter=fspecial('average',[2 2]);
        disp('filtering....')
        fImage=imfilter(handles.channels.R, filter, 'conv');
        handles.channels.R=fImage;
    end
end

[r c z]=size(handles.channels.G);
handles.numberOfFrames=z;
handles.numberOfRows=r;
handles.numberOfColumns=c;
set(handles.figure1,'Name',handles.currentFile);
set(handles.slider1,'Min',1,'Max',z,'Value',1,'SliderStep',[ 1/z 10/z]);
set(handles.FrameCounter,'String',[num2str(1) '/' num2str(z)]);
set(handles.zoomFactorBox,'String', ['Zoom: ' num2str(handles.state.acq.zoomFactor)]);
set(handles.DateBox,'String', ['Date: ' handles.state.internal.startupTimeString]);
set(handles.PowerBox,'String', ['Power: ' num2str(handles.state.init.eom.maxPower(2:3))]);
handles.timePerLine=handles.state.acq.msPerLine/1000; %in sec
guidata(handles.figure1,handles) ;
% --- Executes on button press in BGButton.
function BGButton_Callback(hObject, eventdata, handles)
% hObject    handle to BGButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[bw, xbw, ybw]=roipolyold;

[bw, xbw, ybw]=roipoly;
try 
    delete(handles.backgroundHandle)
catch
end

hold on
bghandle=plot(xbw, ybw,'w-');
set(bghandle,'Tag','BG');

handles.backgroundpolyCoord=[ xbw ybw];
handles.backgroundHandle=bghandle;
guidata(handles.figure1,handles) ;

% --- Executes on button press in ROIButton.
function ROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to ROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roiActive=get(handles.listboxROIs,'Value');
colorList=get(handles.axes1,'ColorOrder');
[roi roixActive roiyActive]=roipoly;
try 
    delete(handles.roiPlotHandle(roiActive),handles.roiTextHandle(roiActive) )
catch
end
%roiActive=repmat(roiActive, [ 1 1 handles.numberOfFrames]);
%roiActive=uint16(roi);
hold on
handles.roiPlotHandle(roiActive)=plot(roixActive, roiyActive,'Color', handles.colorlist(roiActive,:));
%set(handles.roiPlotHandle(roiActive),'Tag','ROI','ButtonDownFcn','Leo_moverotateobj(''BtnDown'')');
htext=text(mean(roixActive), mean(roiyActive), num2str(roiActive),'Color',handles.colorlist(roiActive,:));
handles.roiTextHandle(roiActive)=htext;
handles.roipolyCoord{roiActive}=[ roixActive roiyActive];
guidata(handles.figure1,handles) ;

% --- Executes on button press in AnalyzeButton.
    function AnalyzeButton_Callback(hObject, eventdata, handles)
        % hObject    handle to AnalyzeButton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        %roiActive=get(handles.listboxROIs,'Value')
        
        switch handles.displayChannel
            case 'G'
                activeChannel=handles.channels.G;
            case 'R'
                activeChannel=handles.channels.R;
        end
        
bw=poly2mask(handles.backgroundpolyCoord(:,1),handles.backgroundpolyCoord(:,2),handles.numberOfRows,handles.numberOfColumns);
bw=repmat(bw, [ 1 1 handles.numberOfFrames]);
bw=uint16(bw);
handles.backgroundpoly=bw;
        
        background=handles.backgroundpoly.*activeChannel;
        background=double(background);
        %background(background==0)=NaN;

        B=nanmean(nanmean(nanmean(background(:))));
        F=zeros(handles.roiNumber,handles.numberOfFrames);
        for i=1:handles.roiNumber;

            roiMask=poly2mask(handles.roipolyCoord{i}(:,1),handles.roipolyCoord{i}(:,2),handles.numberOfRows,handles.numberOfColumns);
            roiMask=repmat(roiMask, [ 1 1 handles.numberOfFrames]);
            roiMask=uint16(roiMask);
            areaOfInterest=roiMask.*activeChannel;
            areaOfInterest=double(areaOfInterest);
            areaOfInterest(areaOfInterest==0)=NaN;
            F(i,:)=squeeze(nanmean(nanmean(areaOfInterest)));
        end
        
        timePerLine = handles.timePerLine; % in s
        deltaT = handles.numberOfRows * timePerLine; % in ms, time per frame

        switch handles.analysisMode
            case 'F'
                F=F-B;
                yFactor=100;
                offsetVector=yFactor*(0:handles.roiNumber-1)';
                offsetArray=repmat(offsetVector, [1 handles.numberOfFrames ]);
                Fplot=F+offsetArray;
                            
                YLabel='F-Background';

               
            case 'deltaF/F'
                Fo=(prctile((F-B)',35))'; % using lower 35 percentile as Fo!
                FoArray=repmat(Fo,[1 handles.numberOfFrames]);
                F=(F-B-FoArray)./FoArray;

                yFactor=1;    %<-----Offset between traces for the plot
                offsetVector=yFactor*(0:handles.roiNumber-1)';
                offsetArray=repmat(offsetVector, [1 handles.numberOfFrames ]);
                Fplot=F+offsetArray;
                YLabel='deltaF/F';
            case 'deltaF/F/R'
                backgroundG=handles.backgroundpoly.*handles.channels.G;
                backgroundR=handles.backgroundpoly.*handles.channels.R;
                backgroundG=double(backgroundG);
                backgroundR=double(backgroundR);
                %background(background==0)=NaN;

                BG=nanmean(nanmean(nanmean(backgroundG(:))));
                BR=nanmean(nanmean(nanmean(backgroundR(:))));
                F=zeros(handles.roiNumber,handles.numberOfFrames);
                FR=zeros(handles.roiNumber,handles.numberOfFrames);
                for i=1:handles.roiNumber;

                    roiMask=poly2mask(handles.roipolyCoord{i}(:,1),handles.roipolyCoord{i}(:,2),handles.numberOfRows,handles.numberOfColumns);
                    roiMask=repmat(roiMask, [ 1 1 handles.numberOfFrames]);
                    roiMask=uint16(roiMask);
                    areaOfInterestG=roiMask.*handles.channels.G;
                    areaOfInterestR=roiMask.*handles.channels.R;
                    areaOfInterestG=double(areaOfInterestG);
                    areaOfInterestR=double(areaOfInterestR);
                    areaOfInterestG(areaOfInterestG==0)=NaN;
                    areaOfInterestR(areaOfInterestR==0)=NaN;
                    F(i,:)=squeeze(nanmean(nanmean(areaOfInterestG)));
                    FR(i,:)=squeeze(nanmean(nanmean(areaOfInterestR)));
                end
                
                maxRed=repmat(max(FR,[],2),[1 handles.numberOfFrames])-BG;
                Red=(FR-BR);
                
                Fo=(prctile(((F-BG)./Red)',35))'; % using lower 35 percentile as Fo!
                FoArray=repmat(Fo,[1 handles.numberOfFrames]);
                F=((F-B-FoArray)./FoArray)./Red;

                yFactor=1;    %<-----Offset between traces for the plot
                offsetVector=yFactor*(0:handles.roiNumber-1)';
                offsetArray=repmat(offsetVector, [1 handles.numberOfFrames ]);
                Fplot=F+offsetArray;
                YLabel='deltaF/F/R';
        end
        
        if hObject==handles.AnalyzeButton
        h=figure('Position',[268         118         507        1024]);
        set(h,'DefaultAxesColorOrder',handles.colorlist);

        hax=subplot(15,3,[1 : 36]);
        %uicontrol(h,'Style','pushbutton','String','Load Treadmill vel','Position', [20   266   151    20], 'Callback', 'plotTreadmillVel');
        %uicontrol(h,'Style','pushbutton','String','Load Stim pulse','Position', [20   300   151    20], 'Callback', 'plotStimPulse');
        %uicontrol(h,'Style','pushbutton','String','Load Whiker Slice','Position', [20   334   151    20], 'Callback', 'plotWhiskerSlice');
        set(gcf,'Name', handles.currentFile)
        set(h,'Name', handles.currentFile);
        plot(deltaT:deltaT:handles.numberOfFrames*deltaT, Fplot);

        set(get(hax,'XLabel'),'String', 'Time (s)');
        set(get(hax,'YLabel'),'String', YLabel);
        set(hax,'XLim',[0 handles.numberOfFrames*deltaT], 'YLim', [-1 handles.roiNumber]);
        assignin('base', ['F_' handles.currentFile(1:end-4)], F);
        else
        handles.lastF=zeros(handles.roiNumber,handles.numberOfFrames);
        handles.lastF=F;
        %handles.lastF(1,1)
        guidata(handles.figure1,handles) ;
       
        end
        
  
% 

% --- Executes on slider movement.
function ColormapMax_Callback(hObject, eventdata, handles)
% hObject    handle to ColormapMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

maxImageValue=round(get(hObject,'Value'));
set(gca,'CLim', [str2num(get(handles.MinValueText,'String')) maxImageValue ])
set(handles.MaxValueText,'String',num2str(maxImageValue));
% --- Executes during object creation, after setting all properties.
function ColormapMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColormapMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function MinValueText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinValueText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on slider movement.
function ColormapMin_Callback(hObject, eventdata, handles)
% hObject    handle to ColormapMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
minImageValue=round(get(hObject,'Value'));
set(gca,'CLim', [minImageValue str2num(get(handles.MaxValueText,'String'))])
set(handles.MinValueText,'String',num2str(minImageValue));
% --- Executes during object creation, after setting all properties.
function ColormapMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColormapMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on button press in MaxProjection.
function MaxProjection_Callback(hObject, eventdata, handles)


% hObject    handle to MaxProjection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1,'Name',handles.currentFile);
set(handles.ColormapMax,'Min',0, 'Max',max(max(max(handles.channels.G,[],3))), 'Value', max(max(max(handles.channels.G,[],3))),...
            'SliderStep', [ 1/double(max(handles.channels.G(:))) 10/double(max(handles.channels.G(:)))])%
        set(handles.ColormapMin,'Min',0, 'Max',max(max(max(handles.channels.G,[],3))), 'Value', min(min(min(handles.channels.G,[],3))),...
            'SliderStep', [ 1/double(max(handles.channels.G(:))) 10/double(max(handles.channels.G(:)))])%
        set(handles.MaxValueText, 'String', max(max(max(handles.channels.G,[],3))));
        set(handles.MinValueText, 'String', min(min(min(handles.channels.G,[],3))));
    try
    delete(handles.imageHandle)
    
    catch
    end

switch handles.displayChannel
    case 'G'
        movAvgim=im_mov_avg(handles.channels.G,5);%
    case 'R'
        movAvgim=im_mov_avg(handles.channels.R,5);%
end
axes(handles.axes1);
im=imagesc(max(movAvgim,[],3));colormap(gray);
handles.imageHandle=im;
uistack(handles.imageHandle,'bottom')
guidata(handles.figure1,handles) ;



% --- Executes on button press in CopyImageButton.
function CopyImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to CopyImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
axes
set(gca,'YDir','reverse')
copyHandle=copyobj([handles.imageHandle handles.roiPlotHandle handles.roiTextHandle],gca);
set(gca,'YDir','reverse')
colormap(gray)
uistack(copyHandle(1),'bottom');


% --- Executes on button press in FradioButton.
function FradioButton_Callback(hObject, eventdata, handles)
% hObject    handle to FradioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FradioButton
set(hObject,'Value',1);
set(handles.deltaFoverFoRadioButton,'Value',0)
set(handles.ratiometricRadioButton,'Value',0)
handles.analysisMode='F';
guidata(handles.figure1,handles) ;
% --- Executes on button press in deltaFoverFoRadioButton.
function deltaFoverFoRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to deltaFoverFoRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of deltaFoverFoRadioButton
set(hObject,'Value',1);
set(handles.FradioButton,'Value',0);
set(handles.ratiometricRadioButton,'Value',0)
handles.analysisMode='deltaF/F';
guidata(handles.figure1,handles) ;

%--------------------------------------------------------------------------


    




% --- Executes on selection change in listboxROIs.
function listboxROIs_Callback(hObject, eventdata, handles)
% hObject    handle to listboxROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxROIs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxROIs


% --- Executes during object creation, after setting all properties.
function listboxROIs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddNewROI.
function AddNewROI_Callback(hObject, eventdata, handles)
% hObject    handle to AddNewROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.roiNumber=handles.roiNumber+1;
set(handles.listboxROIs,'String',num2str([1:handles.roiNumber]'),...
	'Value',handles.roiNumber)
guidata(handles.figure1,handles)

% --- Executes on button press in DeleteROI.
function DeleteROI_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

roiActive=get(handles.listboxROIs,'Value');
handles.roiNumber=handles.roiNumber-1;
set(handles.listboxROIs,'String',num2str([1:handles.roiNumber]'),...
	'Value',roiActive);
 delete(handles.roiPlotHandle(:),handles.roiTextHandle(:) );
 dummy.roipolyCoord=handles.roipolyCoord;

 handles.roipolyCoord=[];
 handles.roiPlotHandle=[];
 handles.roiTextHandle=[];
 i=[1:roiActive-1 roiActive+1:handles.roiNumber+1];
     
     handles.roipolyCoord=dummy.roipolyCoord(i);

     clear('dummy');
    for i=1:handles.roiNumber;
    handles.roiPlotHandle(i)=plot(handles.roipolyCoord{i}(:,1),handles.roipolyCoord{i}(:,2),'Color',handles.colorlist(i,:))
    handles.roiTextHandle(i)=text(mean(handles.roipolyCoord{i}(:,1)), mean(handles.roipolyCoord{i}(:,2)), num2str(i),'Color',handles.colorlist(i,:));
    end
 
guidata(handles.figure1,handles)


% --- Executes on button press in translateROIs.
function translateROIs_Callback(hObject, eventdata, handles)
% hObject    handle to translateROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 roiActive=get(handles.listboxROIs,'Value');
 hAx = handles.axes1;  
% CurrentPoint = get(hAx,'CurrentPoint');  
 hObj = handles.roiPlotHandle(roiActive); 
 curr_pt = get(hAx,'CurrentPoint');
% x = get(hObj,'XData');  
% y = get(hObj,'YData');  
%         
% 
% LastPoint = CurrentPoint;  
% CurrentPoint = get(hAx,'CurrentPoint');  
%  
% 
% ROIsHandles=findobj('Tag','ROI');
%     
%         %Calculate Difference  
%         dx = CurrentPoint(1,1) - LastPoint(1,1);  
%         dy = CurrentPoint(1,2) - LastPoint(1,2);  
% %         x = x + dx;  
% %         y = y + dy;  
%         %Update position on Plot  
%      for i=1:length(ROIsHandles) 
%          xy{i}(:,1)=get(ROIsHandles(i),'XData')';
%          xy{i}(:,2)=get(ROIsHandles(i),'YData')';
%         set(ROIsHandles(i),'XData',xy{i}(:,1)+dx,'YData',xy{i}(:,2)+dy);
% %         set(handles.roiTextHandle(i),'Position', [mean(xy{i}(:,1)+dx) mean(xy{i}(:,2)+dy)]);
%      end
% %   handles.roipolyCoord=xy;
%       
% ud.CurrentPoint = CurrentPoint;


% set(hObj,'ButtonDownFcn','Leo_moverotateobj(''BtnDown'')')




% --- Executes on button press in lrftButton.
function lrftButton_Callback(hObject, eventdata, handles)
% hObject    handle to lrftButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for i=1:length(handles.roiPlotHandle) 
         xy{i}(:,1)=get(handles.roiPlotHandle(i),'XData')-1';
         xy{i}(:,2)=get(handles.roiPlotHandle(i),'YData')';
        set(handles.roiPlotHandle(i),'XData',xy{i}(:,1),'YData',xy{i}(:,2));
        set(handles.roiTextHandle(i),'Position', [mean(xy{i}(:,1)) mean(xy{i}(:,2))]);
       
        handles.roipolyCoord=xy;
        
end
 guidata(handles.figure1,handles)
% --- Executes on button press in upButton.
function upButton_Callback(hObject, eventdata, handles)
% hObject    handle to upButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%ROIsHandles=findobj('Tag','ROI');
 for i=1:length(handles.roiPlotHandle) 
         xy{i}(:,1)=get(handles.roiPlotHandle(i),'XData')';
         xy{i}(:,2)=get(handles.roiPlotHandle(i),'YData')'-1;
        set(handles.roiPlotHandle(i),'XData',xy{i}(:,1),'YData',xy{i}(:,2));
        set(handles.roiTextHandle(i),'Position', [mean(xy{i}(:,1)) mean(xy{i}(:,2))]);
       
        handles.roipolyCoord=xy;
        
 end
guidata(handles.figure1,handles)
% --- Executes on button press in rightButton.
function rightButton_Callback(hObject, eventdata, handles)
% hObject    handle to rightButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 for i=1:length(handles.roiPlotHandle) 
         xy{i}(:,1)=get(handles.roiPlotHandle(i),'XData')+1';
         xy{i}(:,2)=get(handles.roiPlotHandle(i),'YData')';
        set(handles.roiPlotHandle(i),'XData',xy{i}(:,1),'YData',xy{i}(:,2));
        set(handles.roiTextHandle(i),'Position', [mean(xy{i}(:,1)) mean(xy{i}(:,2))]);
       
        handles.roipolyCoord=xy;
        
 end
 guidata(handles.figure1,handles)
% --- Executes on button press in downButton.
function downButton_Callback(hObject, eventdata, handles)
% hObject    handle to downButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for i=1:length(handles.roiPlotHandle) 
         xy{i}(:,1)=get(handles.roiPlotHandle(i),'XData')';
         xy{i}(:,2)=get(handles.roiPlotHandle(i),'YData')'+1;
        set(handles.roiPlotHandle(i),'XData',xy{i}(:,1),'YData',xy{i}(:,2));
        set(handles.roiTextHandle(i),'Position', [mean(xy{i}(:,1)) mean(xy{i}(:,2))]);
       
        handles.roipolyCoord=xy;
        
 end
guidata(handles.figure1,handles)


% --- Executes on button press in ratiometricRadioButton.
function ratiometricRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to ratiometricRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ratiometricRadioButton

set(hObject,'Value',1);
set(handles.FradioButton,'Value',0);
set(handles.deltaFoverFoRadioButton,'Value',0)
handles.analysisMode='deltaF/F/R';
guidata(handles.figure1,handles) ;


% --- Executes on button press in displayGreenRadioButton.
function displayGreenRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to displayGreenRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayGreenRadioButton
set(hObject,'Value',1);
set(handles.displayRedRadioButton,'Value',0);
handles.displayChannel='G';
guidata(handles.figure1,handles) ;

% --- Executes on button press in displayRedRadioButton.
function displayRedRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to displayRedRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayRedRadioButton

set(hObject,'Value',1);
set(handles.displayGreenRadioButton,'Value',0);
handles.displayChannel='R';
guidata(handles.figure1,handles) ;



function startingTrialBox_Callback(hObject, eventdata, handles)
% hObject    handle to startingTrialBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startingTrialBox as text
%        str2double(get(hObject,'String')) returns contents of startingTrialBox as a double


% --- Executes during object creation, after setting all properties.
function startingTrialBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startingTrialBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endingTrialBox_Callback(hObject, eventdata, handles)
% hObject    handle to endingTrialBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endingTrialBox as text
%        str2double(get(hObject,'String')) returns contents of endingTrialBox as a double


% --- Executes during object creation, after setting all properties.
function endingTrialBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endingTrialBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in analyzeAcrossTrialsButton.
function analyzeAcrossTrialsButton_Callback(hObject, eventdata, handles)
% hObject    handle to analyzeAcrossTrialsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

startString=get(handles.startingTrialBox,'String');
endingString=get(handles.endingTrialBox,'String');
startTrialNum=str2num(startString);
endingTrialNum=str2num(endingString);
%handles.lastF=zeros(handles.numberOfFrames);
handles.FAcrossTrials=zeros(handles.roiNumber, handles.numberOfFrames, endingTrialNum-startTrialNum+1);
clear('handles.trials');
for i=startTrialNum:endingTrialNum;
    filename=[handles.currentFile(1:end-7) sprintf('%03d',i) '.tif'];
handles.currentFile=filename;
f=filename;
 if get(handles.loadHeaderCheck,'Value')==0;
    Data=genericOpenTif(f);
    Data=uint16(Data);
    handles.channels.G=Data; ;
%     handles.channels.G=Data(:,:,1:2:end) ;
%     handles.channels.R=Data(:,:,2:2:end);
 else
 
[H Data]=scim_openTif(f);
handles.state=H;
handles.channels.G=squeeze(Data(:,:,1,:));
 end
if get(handles.loadAvgFilterCheck,'Value')==1
filter=fspecial('average',[2 2]);
    disp('filtering....')
    fImage=imfilter(handles.channels.G, filter, 'conv');
    handles.channels.G=fImage;
end
if ndims(Data)>3
    handles.channels.R=squeeze(Data(:,:,2,:));
    if get(handles.loadAvgFilterCheck,'Value')==1
filter=fspecial('average',[2 2]);
    disp('filtering....')
    fImage=imfilter(handles.channels.R, filter, 'conv');
    handles.channels.R=fImage;
end
end
    

  
    guidata(handles.figure1,handles) 
    AnalyzeButton_Callback(hObject, eventdata, handles)
    handles=guidata(handles.figure1);
    handles.FAcrossTrials(:,:,i-startTrialNum+1)=handles.lastF; % rows= ROI , column= frame, z=trial
    handles.trials(i-startTrialNum+1,:)=filename;
    
end
handles.currentFile=filename;

guidata(handles.figure1,handles) ;
assignin('base', 'FAcrossTrials', handles.FAcrossTrials);
assignin('base', 'trials', handles.trials);

    




function ROItoPlotValue_Callback(hObject, eventdata, handles)
% hObject    handle to ROItoPlotValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROItoPlotValue as text
%        str2double(get(hObject,'String')) returns contents of ROItoPlotValue as a double


% --- Executes during object creation, after setting all properties.
function ROItoPlotValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROItoPlotValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotROIDataButton.
function plotROIDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotROIDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROItoPlot=str2num(get(handles.ROItoPlotValue,'String'));
figure(111);
timePerLine = handles.timePerLine; % in s
deltaT = handles.numberOfRows * timePerLine; % in ms, time per frame
 yFactor=1;    %<-----Offset between traces for the plot
 [a b c]=size(handles.FAcrossTrials);
 ROIData=(squeeze(handles.FAcrossTrials(ROItoPlot,:,:)))';
 offsetVector=yFactor*(0:c-1)';
 offsetArray=repmat(offsetVector, [1 handles.numberOfFrames ]);
 ROIplot=ROIData+offsetArray;
 
plot(deltaT:deltaT:handles.numberOfFrames*deltaT,ROIplot')

hax=gca;
set(get(hax,'XLabel'),'String', 'Time (s)');
set(get(hax,'YLabel'),'String', [handles.analysisMode '--Trial #']);
set(hax,'XLim',[0 handles.numberOfFrames*deltaT]);
set(hax,'YLim',[-0.5 c+2]);
title(['ROI ' num2str(ROItoPlot)]);


% --- Executes on button press in saveROIbutton.
function saveROIbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveROIbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
savedROIs.backgroundpolyCoord=handles.backgroundpolyCoord;
savedROIs.roipolyCoord=handles.roipolyCoord;


save(['savedROIs_' handles.currentDirectory(end-17:end-1)],'savedROIs');
disp(['saving.. savedROIs' handles.currentDirectory(end-17:end)])




% --- Executes on button press in loadROIsButton.
function loadROIsButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadROIsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f p]=uigetfile('Pick saved ROIs');
loadedROIs=load([p f]);
try;
delete(handles.roiPlotHandle(:),handles.roiTextHandle(:), handles.backgroundHandle )
catch
 handles.roiPlotHandle=[];
 handles.roiTextHandle=[];
end
handles.roiPlotHandle=[];
handles.roiTextHandle=[];
handles.roipolyCoord=[];
handles.backgroundpolyCoord=[];
[r c]=size(loadedROIs.savedROIs.roipolyCoord);

handles.roiNumber=c;
set(handles.listboxROIs,'String',num2str([1:handles.roiNumber]'),...
	'Value',1);

 handles.roipolyCoord=loadedROIs.savedROIs.roipolyCoord;
 handles.backgroundpolyCoord=loadedROIs.savedROIs.backgroundpolyCoord;
 %calculate background;


 %plot:
 hold on
 handles.backgroundHandle=plot(handles.backgroundpolyCoord(:,1), handles.backgroundpolyCoord(:,2),'w-');
 
 
    for i=1:handles.roiNumber;
    handles.roiPlotHandle(i)=plot(handles.roipolyCoord{i}(:,1),handles.roipolyCoord{i}(:,2),'Color',handles.colorlist(i,:))
    handles.roiTextHandle(i)=text(mean(handles.roipolyCoord{i}(:,1)), mean(handles.roipolyCoord{i}(:,2)), num2str(i),'Color',handles.colorlist(i,:));
    end

guidata(handles.figure1,handles) ;


% --- Executes on button press in loadFowardButton.
function loadFowardButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadFowardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadFowardButton
filename=handles.currentFile;
number=str2num(filename(end-6:end-4));
filename=[handles.currentFile(1:end-7) sprintf('%03d',number+1) '.tif'];
f=filename;
handles.currentFile=filename;
try
    delete(handles.imageHandle)

catch
end


 if get(handles.loadHeaderCheck,'Value')==0;
    Data=genericOpenTif(f);
    Data=uint16(Data);
    handles.channels.G=Data; ;
%     handles.channels.G=Data(:,:,1:2:end) ;
%     handles.channels.R=Data(:,:,2:2:end);
 else
 
[H Data]=scim_openTif(f);
handles.state=H;
handles.channels.G=squeeze(Data(:,:,1,:));
 end
if get(handles.loadAvgFilterCheck,'Value')==1
filter=fspecial('average',[2 2]);
    disp('filtering....')
    fImage=imfilter(handles.channels.G, filter, 'conv');
    handles.channels.G=fImage;
end
if ndims(Data)>3
    handles.channels.R=squeeze(Data(:,:,2,:));
    if get(handles.loadAvgFilterCheck,'Value')==1
filter=fspecial('average',[2 2]);
    disp('filtering....')
    fImage=imfilter(handles.channels.R, filter, 'conv');
    handles.channels.R=fImage;
end
end

        [r c z]=size(handles.channels.G);
        handles.numberOfFrames=z;
        handles.numberOfRows=r;
        handles.numberOfColumns=c;
        set(handles.figure1,'Name',handles.currentFile);
        set(handles.slider1,'Min',1,'Max',z,'Value',1,'SliderStep',[ 1/z 10/z]);
        set(handles.FrameCounter,'String',[num2str(1) '/' num2str(z)]);
        set(handles.zoomFactorBox,'String', ['Zoom: ' num2str(handles.state.acq.zoomFactor)]);
        set(handles.DateBox,'String', ['Date: ' handles.state.internal.startupTimeString]);
        set(handles.PowerBox,'String', ['Power: ' num2str(handles.state.init.eom.maxPower(2:3))]);
        handles.timePerLine=handles.state.acq.msPerLine/1000; %in sec
        guidata(handles.figure1,handles) ;


MaxProjection_Callback(hObject, eventdata, handles);



% --- Executes on button press in loadBackwardsButton.
function loadBackwardsButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadBackwardsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadBackwardsButton
filename=handles.currentFile;
number=str2num(filename(end-6:end-4));
filename=[handles.currentFile(1:end-7) sprintf('%03d',number-1) '.tif'];
f=filename;
handles.currentFile=filename;
try
    delete(handles.imageHandle)

catch
end


 if get(handles.loadHeaderCheck,'Value')==0;
    Data=genericOpenTif(f);
    Data=uint16(Data);
    handles.channels.G=Data; ;
%     handles.channels.G=Data(:,:,1:2:end) ;
%     handles.channels.R=Data(:,:,2:2:end);
 else
 
[H Data]=scim_openTif(f);
handles.state=H;
handles.channels.G=squeeze(Data(:,:,1,:));
 end
if get(handles.loadAvgFilterCheck,'Value')==1
filter=fspecial('average',[2 2]);
    disp('filtering....')
    fImage=imfilter(handles.channels.G, filter, 'conv');
    handles.channels.G=fImage;
end
if ndims(Data)>3
    handles.channels.R=squeeze(Data(:,:,2,:));
    if get(handles.loadAvgFilterCheck,'Value')==1
filter=fspecial('average',[2 2]);
    disp('filtering....')
    fImage=imfilter(handles.channels.R, filter, 'conv');
    handles.channels.R=fImage;
end
end

        [r c z]=size(handles.channels.G);
        handles.numberOfFrames=z;
        handles.numberOfRows=r;
        handles.numberOfColumns=c;
        set(handles.figure1,'Name',handles.currentFile);
        set(handles.slider1,'Min',1,'Max',z,'Value',1,'SliderStep',[ 1/z 10/z]);
        set(handles.FrameCounter,'String',[num2str(1) '/' num2str(z)]);
        set(handles.zoomFactorBox,'String', ['Zoom: ' num2str(handles.state.acq.zoomFactor)]);
        set(handles.DateBox,'String', ['Date: ' handles.state.internal.startupTimeString]);
        set(handles.PowerBox,'String', ['Power: ' num2str(handles.state.init.eom.maxPower(2:3))]);
        handles.timePerLine=handles.state.acq.msPerLine/1000; %in sec
        guidata(handles.figure1,handles) ;


MaxProjection_Callback(hObject, eventdata, handles);




% --- Executes on button press in ROItoPlotBackButton.
function ROItoPlotBackButton_Callback(hObject, eventdata, handles)
% hObject    handle to ROItoPlotBackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROItoPlotBackButton
ROItoPlot=str2num(get(handles.ROItoPlotValue,'String'));
ROItoPlot=ROItoPlot-1;
set(handles.ROItoPlotValue,'String',num2str(ROItoPlot));
guidata(handles.figure1,handles) ;
plotROIDataButton_Callback(hObject, eventdata, handles)
%plotTrialButton_Callback(hObject, eventdata, handles)

% --- Executes on button press in ROItoPlotForwardButton.
function ROItoPlotForwardButton_Callback(hObject, eventdata, handles)
% hObject    handle to ROItoPlotForwardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROItoPlotForwardButton

ROItoPlot=str2num(get(handles.ROItoPlotValue,'String'));
ROItoPlot=ROItoPlot+1;
set(handles.ROItoPlotValue,'String',num2str(ROItoPlot));
guidata(handles.figure1,handles) ;
plotROIDataButton_Callback(hObject, eventdata, handles)
%plotTrialButton_Callback(hObject, eventdata, handles)



% --- Executes on button press in loadAvgFilterCheck.
function loadAvgFilterCheck_Callback(hObject, eventdata, handles)
% hObject    handle to loadAvgFilterCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadAvgFilterCheck


% --- Executes on button press in loadHeaderCheck.
function loadHeaderCheck_Callback(hObject, eventdata, handles)
% hObject    handle to loadHeaderCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadHeaderCheck




% --- Executes on button press in plotTrialButton.
function plotTrialButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotTrialButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trialToPlot=str2num(get(handles.ROItoPlotValue,'String'));
figure(112);
timePerLine = handles.timePerLine; % in s
deltaT = handles.numberOfRows * timePerLine; % in ms, time per frame
 yFactor=1;    %<-----Offset between traces for the plot
 [a b c]=size(handles.FAcrossTrials);
 trialData=handles.FAcrossTrials(:,:,trialToPlot);
 offsetVector=yFactor*(0:handles.roiNumber-1)';
 offsetArray=repmat(offsetVector, [1 handles.numberOfFrames ]);
 trialPlot=trialData+offsetArray;
 
plot(deltaT:deltaT:handles.numberOfFrames*deltaT,trialPlot')

hax=gca;
title(['Trial# ' num2str(trialToPlot)]);
set(get(hax,'XLabel'),'String', 'Time (s)');
set(get(hax,'YLabel'),'String', [handles.analysisMode '-- ROI #']);
set(hax,'XLim',[0 handles.numberOfFrames*deltaT]);
set(hax,'YLim',[-0.5 handles.roiNumber+2]);

