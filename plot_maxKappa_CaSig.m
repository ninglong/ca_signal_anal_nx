function [h1, h2, rho, slope] = plot_maxKappa_CaSig(imArray, wsArray, roiNo, varargin)
% Scatter plot max Kappa change vs dF/F amplitude, with linear fit
% 
% varargin{1}, specify the way of max Kappa change is computed, i.e., during
%               active touch or during air puff.
% varargin{2}, Num of which whisker to use.
%
% OUTPUT: h1, h2, the handles to the plot; rho, correlation coeff; slope,
% slope of the linear fit.
% NX, 2011 Dec

if isempty(varargin) || isempty(varargin{1}) || strcmpi(varargin{1}, 'touch') 
    stimtype = 'touch';
elseif strcmpi(varargin{1}, 'puff')
    stimtype = 'puff';
end
   
if length(varargin) > 1
    wNo = varargin{2};
else
    wNo = 1;
end
%% get dF/F amplitude from the whole trial
for i = 1:imArray.nROIs
      dff_amp(:,i) = imArray.get_dff_amplitude(i);
end
    
%% get total touch kappa change for each trial
switch stimtype
    case 'touch'
    if isempty(wsArray.maxTouchKappaTrial)
        wsArray = wsArray.get_totTouchKappa_trial;
    end
    tot_ka = wsArray.totalTouchKappaTrial;
    max_ka = wsArray.maxTouchKappaTrial;
    
    wVar = max_ka{wNo}';
    CaSig = dff_amp(:,roiNo);
    
%     I = imArray.trialInds.touch_only{1};
%     wVar = wVar(I); CaSig = CaSig(I);
    
    % Constrain the range of data to be used. Very large kappa change might
    % be due to additional factors or artifacts.
    % Here constrain the kappa change range at <=5
    inds = find(wVar <= 5);
    wVar = wVar(inds);
    CaSig = CaSig(inds);
    
    case 'puff'
    %% For airpuff trials
    for k = 1: wsArray.nTrials
        ts = wsArray.ws_trials{k}.time{wNo};
        % Here use the first air puff between 0.72 - 0.77 sec. Note! This
        % needs to be changed depending on the stimulus delay!
        stimWindow = [0.92  0.97]; %[0.72  0.77]; %
        inds_first_puff = find(ts< stimWindow(2) & ts> stimWindow(1));
        if isempty(inds_first_puff)
            stimWindow = stimWindow + 0.5;
            inds_first_puff = find(ts< stimWindow(2) & ts> stimWindow(1));
        end
            
        ka = wsArray.ws_trials{k}.deltaKappa{wNo};
        ka_peak_first(k) = abs(min(ka(inds_first_puff)));
        ka_sum_first(k) = sum(abs(ka(inds_first_puff)));
    end
    wVar = ka_peak_first';
    CaSig = dff_amp(:, roiNo);
end
    
    %% Plot total kappa change vs. Ca signal amplitude
    h1 = plot(wVar, CaSig, 'go','linewidth',2, 'markersize', 15);
    title(sprintf('ROI - %d', roiNo), 'fontsize', 20)
    
    % Compute CorrCoef and Slope
    rho = corr(wVar, CaSig, 'Type', 'Pearson');
    p = polyfit(wVar, CaSig, 1);
    slope = p(1);
    fprintf('roi-%d\t%.3f\t%.3f\n', roiNo, rho, slope);
    
    hold on;
    h2 = plot(0:5, (0:5)*p(1)+p(2), 'k-', 'linewidth', 2);
    
   %% set the figure properties
   set(gcf, 'color', 'w');
   set(gca, 'fontsize', 20, 'box', 'off');
    