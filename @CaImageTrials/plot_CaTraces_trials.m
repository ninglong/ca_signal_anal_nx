function h_fig = plot_CaTraces_trials(obj, ROInum, trial_ind, flag_plot_events)
% Plot Ca response traces of multiple trials
% Input: Ca_trace_array, nTrials-by-nFrames.
%        ts, time stamp of imaging frames.1-by-nFrames
%        trial_ind, specify the trial numbers of the Ca signal to be ploted.
%        

if ~exist('trial_ind')
    trial_ind = 1:length(obj);
end
if ~exist('flag_plot_events')
    flag_plot_events = 0;
end

if obj(1).FrameTime > 1
    FrameTime = obj(1).FrameTime/1000;
else
    FrameTime = obj(1).FrameTime;
end
CaTrace_ts = (1:obj(1).nFrames).*FrameTime;
   
scrsz = get(0, 'ScreenSize');
h_fig = figure('Position', [20, 50, scrsz(3)/4, scrsz(4)-200], 'Color', 'w');
spacing = 1/(length(trial_ind)+3); % n*x + 3.5x = 1, space between plottings;
% y_lim = [min(Ca_trace_array(:))/2, max(Ca_trace_array(:))]; 
y_lim = [-20 200]; %[min(min(y))/2 max(max(y))];
x_lim = [CaTrace_ts(1)-0.2 CaTrace_ts(end)+0.2];
for i = 1:length(trial_ind)
    % h(i) = axes('position',[0.028, i*0.06, 0.97, 0.22]);
    h(i) = axes('position',[0.1, i*spacing, 0.9, 3.5*spacing]);
    CaTrace = obj(trial_ind(i)).CaTrace(ROInum, :);
    plot(CaTrace_ts, CaTrace, 'color', 'b'); 
    hold on;
    if flag_plot_events==1 && ~isempty(obj(trial_ind(i)).CaTransients)
        events = obj(trial_ind(i)).CaTransients{ROInum};
        for k = 1:length(events)
%             event_traces{k} = events(k).value;
%             event_ts{k} = events(k).ts;
%             plot(event_ts{k}, event_traces{k}, 'Color', 'g')
            plot_Ca_event(events(k),h(i));
        end
    end
    set(h(i),'visible','off', 'color','none','YLim',y_lim,'XLim',x_lim);
end;
set(h(1),'visible','on', 'box','off','XColor','k','YColor','k','FontSize',15);
