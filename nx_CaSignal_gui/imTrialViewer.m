function varargout = imTrialViewer(varargin)
% IMTRIALVIEWER M-file for imTrialViewer.fig

% varargin{1}, an object of imTrials_NX class
% varargin{2}, trialInds to be plotted.

% Last Modified by GUIDE v2.5 27-Apr-2011 21:41:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @imTrialViewer_OpeningFcn, ...
    'gui_OutputFcn',  @imTrialViewer_OutputFcn, ...
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


% --- Executes just before imTrialViewer is made visible.
function imTrialViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imTrialViewer (see VARARGIN)
global imTrArr plot_param

if isempty(varargin)
    [fn, pathname] = uigetfile('*.mat','Load Data file');
    c = struct2cell(load([pathname filesep fn]));
    imTrialsObj = c{1};
    imTrArr = imTrialArray_nx(imTrialsObj);
    trialInds = 1:imTrArr.nTrials;
else
    imTrArr = varargin{1};
end
if length(varargin) < 2 || isempty(varargin{2})
    trialInds = 1:imTrArr.nTrials;
else
    trialInds = varargin{2};
end
plot_param = init_plot_param(imTrArr,trialInds);
set(handles.numTrialsMenu, 'Value', 2);
% Choose default command line output for imTrialViewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imTrialViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imTrialViewer_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;


% --- Executes on button press in load_data_button.
function load_data_button_Callback(hObject, eventdata, handles)
global imTrArr plot_param
[fn, pathname] = uigetfile('*.mat','Load Data file');
if isequal(fn,0)
    return;
end
c = struct2cell(load([pathname filesep fn]));
imTrialsObj = c{1};
imTrArr = imTrialArray_nx(imTrialsObj);
plot_param = init_plot_param(imTrArr);


function plot_param = init_plot_param(imTrArr,trialInds)
[f, ts] = imTrArr.get_f_array(1);
plot_param.f = f;
plot_param.ts = ts(1,:);
plot_param.allTrials = trialInds;
plot_param.nTrials = length(trialInds);
plot_param.indTr = trialInds;  % initialize trial index to be plotted
plot_param.roiNo = 1; %
plot_param.nROIs = imTrArr.nROIs;
plot_param.plotEvents = 0;
plot_param.h_fig = NaN;
plot_param.titleStr = 'Fig 1';
plot_param.ylim = [-20 250];
plot_param.trialNumLabel = 'off';
% robust standard deviation using median abs deviation
plot_param.sigma = mad(reshape(plot_param.f,1,[]),1) * 1.4826;
if ~isempty(imTrArr.SoloTrials)
    plot_param.polePos = imTrArr.get_polePos;
end

% --- Executes on button press in plotTracesButton.
function plotTracesButton_Callback(hObject, eventdata, handles)
global imTrArr plot_param

scrsz = get(0, 'ScreenSize');
y_lim = plot_param.ylim; %[min(min(y))/2 max(max(y))];
x_lim = [plot_param.ts(1)-0.2 plot_param.ts(end)+0.2];

if scrsz(3)>1920,
    scrsz = [1 1 1440 878]; % use macbook default
end
keep_fig = get(handles.keepFig_flag,'Value');
collapse_plot = get(handles.CollapseTraces, 'Value');

if ~ishandle(plot_param.h_fig) || keep_fig == 1
    plot_param.h_fig = figure;
    if collapse_plot == 1
        fig_pos = [430 460 640 320];
    else
        fig_pos = [60, 350, scrsz(3)/4, scrsz(4)-200];
    end
else
    figure(plot_param.h_fig);
    fig_pos = get(gcf,'Position');
    clf;
end
plot_param.titleStr = sprintf('ROI# %d, trial %d ~ %d', ...
        plot_param.roiNo, plot_param.indTr(1), plot_param.indTr(end));
set(plot_param.h_fig, 'NumberTitle','off','Name',plot_param.titleStr);
if collapse_plot == 1
    ha(1) = axes('YLim',y_lim,'XLim',x_lim);
    hold on;
    xlabel('Time','FontSize',15);
    ylabel('dF/F', 'FontSize',15);
    title(plot_param.titleStr, 'FontSize', 15);
end
set(gcf,'Position', fig_pos, 'Color', 'w');

spacing = 1/(length(plot_param.indTr) + 2); % n*x + 3.5x = 1, space between plottings;

for i = 1: length(plot_param.indTr)
    trNo = plot_param.indTr(i);
    % Set trace color based on trial type
    if ~isempty(imTrArr.SoloTrials)
            if imTrArr.SoloTrials{trNo}.trialType == 1
                if imTrArr.SoloTrials{trNo}.trialCorrect == 1
                    clr = 'b'; % hit trial
                    time_answerLick(i) = imTrArr.SoloTrials{trNo}.answerLickTime;
                else
                    clr = 'k'; % miss trial
                    time_answerLick(i) = NaN;
                end
            else
                if imTrArr.SoloTrials{trNo}.trialCorrect == 1
                    clr = 'r'; % correct rejection
                    time_answerLick(i) = NaN;
                else
                    clr = 'g'; % false alarm
                    time_answerLick(i) = imTrArr.SoloTrials{trNo}.answerLickTime;
                end
            end
            cmap = colormap(jet); cind = ceil((plot_param.polePos(trNo)+1)/(max(plot_param.polePos)+1)*64);
            polePos_color = cmap(cind,:);
            
            if get(handles.ColorLess_plot_button, 'Value') == 1
                clr = 'k';
                polePos_color = [.2 .2 1];
                time_answerLick(i) = NaN;
            end
        % pole entering time, with estimated travel time of 0.4 sec. Color code the pole positions. 
        time_pole_in(i) = imTrArr.SoloTrials{trNo}.pinDescentOnsetTime + 0.2;
        time_pole_out(i) = imTrArr.SoloTrials{trNo}.pinAscentOnsetTime + 0.4;
%         polePos = imTrArr.get_polePos;
    else
        clr = 'b';
        time_pole_in = NaN;
        time_pole_out = NaN;
    end
    
    if collapse_plot == 0
        ha(i) = axes('position',[0.1, i*spacing, 0.85, 3.5*spacing]);
        set(ha(i),'visible','off', 'color','none','YLim',y_lim,'XLim',x_lim);
        hold on;
        if ~strcmp(plot_param.trialNumLabel, 'off')
            text(0.01, 10, num2str(trNo), 'FontWeight', 'bold');
        end
        if ~isnan(time_pole_in)
            line([time_pole_in(i) time_pole_in(i)], [y_lim(1) y_lim(2)/3],'Color',polePos_color,'LineWidth',1.1);
            line([time_pole_out(i) time_pole_out(i)], [y_lim(1) y_lim(2)/3],'Color',polePos_color,'LineWidth',1.1);
            line([time_answerLick(i) time_answerLick(i)], [y_lim(1) y_lim(2)/3],...
                    'Color', [0.2 0.8 0.5],'LineWidth',1.5,'LineStyle','-');
        end
    end
    plot(plot_param.ts, plot_param.f(trNo,:), 'Color', clr, 'LineWidth',1);
    if plot_param.plotEvents == 1 & collapse_plot == 0
        events = imTrArr.imTrials{trNo}.CaTransients{plot_param.roiNo};
        if ~isempty(events)
            for k = 1:length(events)
                plot(events(k).ts, events(k).value,'m--','LineWidth',1.2);
                if ~isnan(events(k).tauRise)
                    % Color label goodness of fit
                    if events(k).gof_rise.rmse < plot_param.sigma * 1.5
                        c = [0 0.5 0.25];
                    else
                        c = 'k';
                    end
                    plot(events(k).t_rise, events(k).yfit_rise, 'Color', c,'LineWidth',1.1);
                end
                if ~isnan(events(k).tauDecay)
                    if events(k).gof_decay.rmse < plot_param.sigma * 1.5
                        c = [0 0.5 0.25];
                    else
                        c = 'k';
                    end
                    plot(events(k).t_decay, events(k).yfit_decay,'Color',c,'LineWidth',1.1);
                end
            end
        end
    end
end
set(ha(1),'visible','on', 'box','off','XColor','k','YColor','k','FontSize',15);
if collapse_plot == 1 & ~isnan(mean(time_pole_in))
    line([mean(time_pole_in) mean(time_pole_in)], [y_lim(1) y_lim(2)/3],'Color',[0.9 0.5 0],'LineWidth',2);
    line([mean(time_pole_out) mean(time_pole_out)], [y_lim(1) y_lim(2)/3],'Color',[0.9 0.5 0],'LineWidth',2);
    line([nanmean(time_answerLick) nanmean(time_answerLick)], [y_lim(1) y_lim(2)/3], 'Color', [0.2 0.8 0.5],'LineWidth',2);
end


% --- Executes on selection change in numTrialsMenu.
function numTrialsMenu_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns numTrialsMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from numTrialsMenu
global plot_param
get_numTrials(hObject, eventdata, handles);
% plot_param.indTr = plot_param.allTrials(1:plot_param.nTrials);
plotTracesButton_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function numTrialsMenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nextBlock.
function nextBlock_Callback(hObject, eventdata, handles)
global plot_param
% update number of trials in plot_param.nTrials
get_numTrials(hObject, eventdata, handles);

a = plot_param.indTr(end) + 1;
b = plot_param.indTr(end) + plot_param.nTrials;
if a > length(plot_param.allTrials)
    return
end
if b > length(plot_param.allTrials)
    b = length(plot_param.allTrials);
end
plot_param.indTr = a : b;
plot_param.nTrials = length(a:b);
plotTracesButton_Callback(hObject, eventdata, handles);


% --- Executes on button press in prevBlock.
function prevBlock_Callback(hObject, eventdata, handles)
global plot_param
% update number of trials in plot_param.nTrials
get_numTrials(hObject, eventdata, handles);

if plot_param.indTr(1) == 1
    return
end
a = plot_param.indTr(1) - plot_param.nTrials;
b = plot_param.indTr(1) - 1;
if a < 1
    a = 1;
end
plot_param.indTr = a : b;
plot_param.nTrials = length(a:b);
plotTracesButton_Callback(hObject, eventdata, handles);


% --- Executes on button press in showEventsButton.
function showEventsButton_Callback(hObject, eventdata, handles)
global plot_param

if get(hObject, 'Value') == 1
    plot_param.plotEvents = 1;
else
    plot_param.plotEvents = 0;
end
plotTracesButton_Callback(hObject, eventdata, handles);

% --- Executes on button press in roiNo.
function roiNo_Callback(hObject, eventdata, handles)

global imTrArr plot_param
plot_param.roiNo = str2double(get(handles.roiNo, 'String'));
[f, ts] = imTrArr.get_f_array(plot_param.roiNo);
plot_param.f = f;
plot_param.ts = ts(1,:);
plot_param.sigma = mad(reshape(f,1,[]),1) * 1.4826;
plotTracesButton_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function roiNo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function get_numTrials(hObject, eventdata, handles)
global plot_param
nTrialsID = get(handles.numTrialsMenu, 'Value');
switch nTrialsID
    case 1
        plot_param.nTrials = 10;
    case 2
        plot_param.nTrials = 20;
    case 3
        plot_param.nTrials = 30;
    case 4
        plot_param.nTrials = 50;
    case 5
        plot_param.nTrials = 100;
    case 6
        plot_param.nTrials = length(plot_param.allTrials);
    case 7 % user specify which trials to be plotted
        trNumsInput = input('Please specify number of trials to plot [a b] or [...]: ');
        if numel(trNumsInput) > 2 % user input exact trial numbers to be ploted
            plot_param.indTr = trNumsInput;
        else                      % user input only the start and end of the trial number range.
            plot_param.indTr = trNumsInput(1):trNumsInput(2);
        end
        plot_param.nTrials = length(plot_param.indTr);
end
if plot_param.nTrials > length(plot_param.allTrials)
    plot_param.nTrials = length(plot_param.allTrials);
    set(handles.numTrialsMenu, 'Value', 5);
end
if nTrialsID ~= 7
    a = plot_param.indTr(1);
    b = plot_param.indTr(1) + plot_param.nTrials;
    if b >  length(plot_param.allTrials)
        b =  length(plot_param.allTrials);
    end
    plot_param.indTr = a:b;
end


% --- Executes on button press in keepFig_flag.
function keepFig_flag_Callback(hObject, eventdata, handles)


% --- Executes on button press in CollapseTraces.
function CollapseTraces_Callback(hObject, eventdata, handles)
% hObject    handle to CollapseTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CollapseTraces


% --- Executes on button press in expFig.
function expFig_Callback(hObject, eventdata, handles)
global imTrArr plot_param
if ~isdir(['trialPlotting_' imTrArr.FileName_prefix])
    mkdir(['trialPlotting_' imTrArr.FileName_prefix]);
end
export_fig(plot_param.h_fig, ['trialPlotting_' imTrArr.FileName_prefix filesep plot_param.titleStr], '-png');


% --- Executes on button press in Next_ROI.
function Next_ROI_Callback(hObject, eventdata, handles)
global plot_param
next_roiNo = str2double(get(handles.roiNo, 'String')) + 1;
if next_roiNo > plot_param.nROIs
    next_roiNo = 1;
end
set(handles.roiNo,'String', num2str(next_roiNo));
guidata(hObject, handles);
roiNo_Callback(hObject, eventdata, handles);



function Edit_Y_Lim_Callback(hObject, eventdata, handles)
global plot_param
plot_param.ylim = str2num(get(hObject,'String'));
plotTracesButton_Callback(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function Edit_Y_Lim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Y_Lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trialNumLabelOn.
function trialNumLabelOn_Callback(hObject, eventdata, handles)
% hObject    handle to trialNumLabelOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plot_param
if get(hObject, 'Value') == 0
    plot_param.trialNumLabel = 'off';
else
    plot_param.trialNumLabel = 'on';
end
plotTracesButton_Callback(hObject, eventdata, handles);

% Hint: get(hObject,'Value') returns toggle state of trialNumLabelOn


% --- Executes on button press in ColorLess_plot_button.
function ColorLess_plot_button_Callback(hObject, eventdata, handles)
plotTracesButton_Callback(hObject, eventdata, handles)
