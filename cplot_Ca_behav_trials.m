function h_plots = cplot_Ca_behav_trials(traceArray, ts, varargin) 

% traceArray, nTrial-by-nFrames
% varargin:  {LickTimes, poleOnsetTimes, answerLickTimes, h_axes, color_scale, polePos_colors}.
%
% -- NX 9/2009

if length(varargin) >= 1
    LickTimes = varargin{1};
end
if length(varargin) >= 2
    poleOnsetTimes = varargin{2};
end
if length(varargin) >= 3
    answerLickTimes = varargin{3};
end
if length(varargin) >= 4
    h_axes = varargin{4};
else
    fig = figure;
end
if length(varargin) >= 5 && ~isempty(varargin{5})
    color_scale = varargin{5};
else
    color_scale = [-10 120];
end
if length(varargin) >= 6
    polePos_colors = varargin{6};
end
if length(varargin) >= 7
    cmap = varargin{7};
else
    cmap = 'jet';
end
h_licks = {};
h_poleOnset = [];
h_waterTimes = [];
h_polePosLabel = {};
nTrials = size(traceArray,1);

% if plot_whisker == 0
if ~exist('ts', 'var')
    ts = 1:size(traceArray,2);
end
%h_cplot = pcolor(ts, (1:nTrials+1), [CaTraces;zeros(1,size(CaTraces,2))]);
%set(h_cplot, 'EdgeColor', 'none');
%caxis(color_scale);
h_cplot = imagesc(traceArray, color_scale);
set(h_cplot, 'XData', [ts(1) ts(end)]);
set(gca,'XLim',get(h_cplot, 'XData'), 'YDir', 'normal');
colormap(cmap);
% elseif plot_whisker ==1
%     ts = [0 CaTrials(1).wVideoTS(1:end-1)];
%     wSpeedTraces = get_CaTrial_WhiskerTrace(CaTrials);
%     n = length(ts);
%     ts = imresize(ts, [1, round(n/5)], 'bilinear');
%     wSpeedTraces = imresize(wSpeedTraces, [size(wSpeedTraces,1) round(n/5)],'bilinear');
% %     h_cplot = pcolor(ts, (1:nTrials+1), [wSpeedTraces;zeros(1,size(wSpeedTraces,2))]);
% %     set(h_cplot, 'EdgeColor', 'none');
% %     caxis(color_scale);
%     h_cplot = imagesc(wSpeedTraces, color_scale);
%     set(h_cplot, 'XData', [ts(1) ts(end)]);
%     set(gca, 'XLim',get(h_cplot, 'XData'), 'YDir', 'normal');
%     colormap(gray);
% end

h_plots = {h_cplot};
hold on;
%% label behavioral times
y = [(1:nTrials); (2:nTrials+1)]; % y value for the labeling ticks
for i= 1:nTrials
    if exist('LickTimes','var') && ~isempty(LickTimes)
        x_lick = repmat(LickTimes{i}',2,1);
        y_lick = repmat([i; i+1], 1, size(x_lick,2));
        
        h_licks{i} = line(x_lick, y_lick, 'Color', 'm','LineWidth',1.12);
    end
    if exist('poleOnsetTimes', 'var')&& ~isempty(poleOnsetTimes)
        h_poleOnset = line(repmat(poleOnsetTimes(i),2,1),y(:,i),'Color','w','LineWidth',1.5);
    end
    if exist('answerLickTimes','var')&& ~isempty(answerLickTimes) && ~isnan(answerLickTimes(i)) 
        h_waterTimes = line(repmat(answerLickTimes(i),2,1),y(:,i),'Color','w','LineWidth',2.5);
    end
    % Label the go positions
    plot(ts(end-1), i, '*', 'Color', polePos_colors{i});
end

%     h_plots = [h_plots {h_licks, h_poleOnset, h_waterTimes}];




