function ColorRaster_sessionDataArray(dataArray, ts, trialInds, trial_colors, barTime, lickTimes, RewardTime, h_axes0, clim, axes_scale)
% ColorRaster_sessionDataArray(dataArray, ts, trialInds, trial_colors, barTime, lickTimes, RewardTime, h_axes0, clim, axes_scale)
% Color Raster plot of session Data Array. Can be Ca Fluo array or Behavior data array.
% Input: 
% dataArray, nTrials-by-nTimeStamps
% ts, Time Stamps. 1 x nTimeStamps
% trialInds, can be 1 x nTrials double, or cell array with each component
%            for trial index of one block of trials, e.g., Hits trials.
% trial_colors, nTrials-by-3, color labeling for bar position for each trial. Put [] to skip.
% lickTimes, 1 x nTrials cell array with each component for the lick times of one trial. Put [] to skip this argument.
% answerLickTimes, 1 x nTrials double for the time of answer lick. 0 for non-answer trials
% barOnset, 1 x nTrials double for time the pole start to move.
% h_axes0, parent axes for the plotting. If [], create a new figure.
% axes_scale: [width_scale  height_scale], to scale the whole plot to what's needed

% Note: lickTimes can be replaced by whisker contact times.
%
% NX - Nov,2010

nTrials = size(dataArray,1);
if ~iscell(trialInds)
    trialInds = {trialInds};
end
if isempty(h_axes0) || ~ishandle(h_axes0)
    scrsz = [1 1 1440 900]; % get(0, 'ScreenSize');
    h_fig = figure('Position', [20, 50, scrsz(3)/4+100, scrsz(4)-200], 'Color', 'w');
    h_axes0 = axes('Position', [0 0 1 1], 'Visible', 'off');
else
    axes(h_axes0);
    set(h_axes0, 'Visible','off');
end
% to scale the size of the plots
if ~exist('axes_scale', 'var') || isempty(axes_scale)
    axes_scale = [1 1 0];
end

axes_bottom = (0.05 + (1-axes_scale(2)))/axes_scale(2);
h_axes = nan(1,length(trialInds));

for i = 1:length(trialInds) % number of blocks
    optArgs = cell(1,4);
    if ~isempty(trial_colors)
        if iscell(trial_colors{1})
            % if trial_colors contain more than on trial color indicator
            for k = 1:length(trial_colors) 
                optArgs{1}{k} = trial_colors{k}(trialInds{i});
            end
        else % trial_colros containing only one color indicator, e.g., barPos colors. 
            optArgs{1} = trial_colors(trialInds{i});
        end
    end
    if ~isempty(barTime)
        optArgs{2} = barTime(trialInds{i},:);
    end
    if ~isempty(lickTimes)
        optArgs{3} = lickTimes(trialInds{i});
    end
    if ~isempty(RewardTime)
        optArgs{4} = RewardTime(trialInds{i});
    end
    
    if length(trialInds{i}) > 0
        ax_height = length(trialInds{i})/nTrials*0.85;
        h_axes(i) = axes('Position', [0.06+axes_scale(3), axes_bottom*axes_scale(2), 0.8*axes_scale(1), ax_height*axes_scale(2)]);
        
        color_plot_trials2(dataArray(trialInds{i},:), ts, optArgs{:}, h_axes(i));
    else 
        ax_height = 0;
    end
    
    axes_bottom = axes_bottom + ax_height + 0.01;
end

h_axes = h_axes(ishandle(h_axes));

set(h_axes,'Box','off', 'FontSize',13,'YTickLabel','')

if i>1
    set(h_axes(2:end),'XTickLabel','');
end 
% Set all axes to the same color scale.
if ~exist('clim','var') || isempty(clim)
    clim(1) = prctile(dataArray(:),0.5); % round((min(allTraces))/10)*10;
    clim(2) = prctile(dataArray(:),99.5); % max(allTraces); %
    if isnan(clim(1)), clim(1) = min(dataArray(:)); end;
    if isnan(clim(2)), clim(2) = max(dataArray(:)); end;
end
for i=1:length(h_axes)
    set(h_axes(i), 'CLim', clim);
end

% if ~isempty(imArray.ROI_type)
%     ROItype = imArray.ROI_type{ROInum};
% else
%     ROItype = '';
% end
% titleStr = sprintf('%s,%s,%s\nROI#%d(%s)',imArray.AnimalName,imArray.ExpDate,imArray.SessionName,ROInum,ROItype);
% title(titleStr, 'FontSize', 15,'Interpreter','none');

% clrsc_str = ['Color Scale: [' num2str(clim(1)) ', ' num2str(clim(2)) ']'];
% axes(h_axes0); text(0.3,0.01,clrsc_str ,'FontSize',14,'Color', 'b');
% disp(clrsc_str);
