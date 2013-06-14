function hcell = cplot_Ca_behav_trials(CaTraces, CaTimeStamps, bTrials, color_scale, h_axes, sortPolePos) 

% bTrials, cell array of Solo.BehavTrial objects
% CaTraces, N x M matrix of Ca signal, with N trials of M frames
% CaTimeStamps, time stamps, nFrams*FrameTime
% color_scale, to set the color scale of pseudo color plotting
% h_axes, handle to the axes in which to plot 
%
% -- NX 5/2009

if nargin < 2
    CaTimeStamps = size(CaTraces,2);
end;
if nargin > 4
    axes(h_axes);
else
    fig = figure;
end;
if nargin < 4
    color_scale = [-10 120];
end;
if nargin < 6
    sortPolePos = 0;
end

h_licks = {};
h_poleOnset = [];
h_waterTimes = [];
pos_clrs = {};
if sortPolePos ==1
    for i = 1:length(bTrials)
        PolePos(i) = bTrials{i}.goPosition;
    end
    [PolePos_sorted, ind] = sort(PolePos);
    CaTraces = CaTraces(ind, :);
    
    % Label the go positions
    clrs = {'w','g','y','m'};
    pos = unique(PolePos_sorted);
    for j = 1:length(pos)
        pos_clrs(PolePos_sorted == pos(j)) = clrs(j);
    end
end
        
h_cplot = pcolor(CaTimeStamps, (1:length(bTrials)+1), [CaTraces;zeros(1,size(CaTraces,2))]);
set(h_cplot, 'EdgeColor', 'none');
caxis(color_scale);
colormap(jet);

hcell = {h_cplot};

if nargin > 2
    hold on;
    nTrials = length(bTrials);
    for i= 1:nTrials
        % mark lick times
        x_lick = repmat(bTrials{i}.beamBreakTimes',2,1);
        y_lick = repmat([i; i+1], 1, size(x_lick,2));
        if ~isempty(x_lick)
            h_licks{i} = line(x_lick, y_lick, 'Color', 'm','LineWidth',1.12);
        end
        
        poleOnsetTimes(i) = bTrials{i}.pinDescentOnsetTime;
        if isempty(bTrials{i}.rewardTime)
            waterTimes(i) = NaN;
        else
            waterTimes(i) = bTrials{i}.rewardTime(1);
        
        end
    end
    y = [(1:nTrials); (2:nTrials+1)];
    h_poleOnset = line(repmat(poleOnsetTimes,2,1),y,'Color','w','LineWidth',1.5);
    h_waterTimes = line(repmat(waterTimes,2,1),y,'Color','w','LineWidth',2.5);
    
    hcell = [hcell {h_licks, h_poleOnset, h_waterTimes}];
end
if ~isempty(pos_clrs)
    for i = 1:length(pos_clrs)
        plot(CaTimeStamps(end-1), i, '*', 'Color', pos_clrs{i});
    end;
end
