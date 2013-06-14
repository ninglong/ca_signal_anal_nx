%% Overview Plot for all ROIs Peak and Probability of response in different
%%% epochs

eventsParam_stim = CaObj.Ca_plot_ROI_events('stim','peak');
fig1 = gcf;
eventsParam_rwd = CaObj.Ca_plot_ROI_events('reward', 'peak');
fig2 = gcf;
eventsParam_pre = CaObj.Ca_plot_ROI_events('pre_stim', 'none');

avg1 = eventsParam_stim.peak_mean; se1 = eventsParam_stim.peak_se;
avg2 = eventsParam_rwd.peak_mean;  se2 = eventsParam_rwd.peak_se;
avg3 = eventsParam_pre.peak_mean;  se3 = eventsParam_pre.peak_se;
ystr = 'Peak dF/F (%)'; %'Event Probability'; %
xstr = 'ROI #';
legstr = {'Stim', 'Reward', 'Pre-Stim'};

% plot trial averaged parameters for different ROIs
fig3 = figure('Position',[900 300 500 260]); hold on;
h(1) = errorbar(avg1, se1, 'o-');
h(2) = errorbar(avg2, se2, 'r-o');
h(3) = errorbar(avg3, se3, 'g-o');
set(gca, 'FontSize', 15);
xlim([0 length(avg1)])
ylabel(ystr, 'FontSize', 18);
xlabel(xstr, 'FontSize', 18);
legend(legstr, 'FontSize', 15);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CaObj.Ca_plot_ROI_events('stim','count');
fig4 = gcf;
CaObj.Ca_plot_ROI_events('reward', 'count');
fig5 = gcf;

avg1 = eventsParam_stim.numEvent_mean; se1 = eventsParam_stim.numEvent_se;
avg2 = eventsParam_rwd.numEvent_mean;  se2 = eventsParam_rwd.numEvent_se;
avg3 = eventsParam_pre.numEvent_mean;  se3 = eventsParam_pre.numEvent_se;
ystr = 'Event Probability'; %'Peak dF/F (%)'; %
xstr = 'ROI #';
legstr = {'Stim', 'Reward', 'Pre-Stim'};

% plot trial averaged parameters for different ROIs
fig6 = figure('Position',[900 300 500 260]); hold on;
h(1) = errorbar(avg1, se1, 'o-');
h(2) = errorbar(avg2, se2, 'r-o');
h(3) = errorbar(avg3, se3, 'g-o');
set(gca, 'FontSize', 15);
xlim([0 length(avg1)])
ylabel(ystr, 'FontSize', 18);
xlabel(xstr, 'FontSize', 18);
legend(legstr, 'FontSize', 15);

saveppt2(pptfile, 'figure',[fig1,fig2,fig3,fig4,fig5,fig6], 'columns',3);

%% Scatter plot, Compare Epochs for all ROIs

nROIs = CaObj(1).nROIs;
trialInds = 1:length(CaObj);

trialTS=(1:CaObj(1).nFrames).*CaObj(1).FrameTime/1000;
for r = 1:nROIs
%     numEvents{r} = rp_stim.numEvent(:,r);
%     numEvents{r} = rp_rwd.numEvent(:,r);
    fig(r) = figure; hold on;
    count=0;
    peakF_stim = [];
    peakF_rwd = [];
    mdFF_stim = [];
    mdFF_rwd = [];
    for i = trialInds
        stimOnset = CaObj(i).behavTrial.pinDescentOnsetTime;
        stimOffset = CaObj(i).behavTrial.pinAscentOnsetTime+CaObj(i).behavTrial.waterValveDelay;
        %     rewardOnset=stimOffset;
        %     rewardOffset=trialTS(end);
        epochStimInd = find(trialTS>stimOnset & trialTS<stimOffset);
        epochRewardInd = find(trialTS>stimOffset);
        count = count+1;
        val_epochStim = CaObj(i).CaTrace(r,epochStimInd);
        val_epochReward = CaObj(i).CaTrace(r,epochRewardInd);
        mdFF_stim(count) = mean(val_epochStim);
        mdFF_rwd(count) = mean(val_epochReward);
        peakF_stim(count) = max(val_epochStim);
        peakF_rwd(count) = max(val_epochReward);
    end
    [h,p] = ttest(peakF_rwd, peakF_stim);
    plot(peakF_rwd, peakF_stim, 'o');
    lim(1) = min([get(gca, 'YLim') get(gca, 'XLim')]);
    lim(2) = max([get(gca, 'YLim') get(gca, 'XLim')]);
    xlim([lim(1) lim(2)]); ylim([lim(1) lim(2)]);
    line([lim(1) lim(2)], [lim(1) lim(2)],'Color','r');
    set(gca,'FontSize', 15, 'box', 'on');
    ylabel('Peak dF/F in Stim', 'FontSize', 18);
    xlabel('Peak dF/F in Reward', 'FontSize', 18);
    title(['ROI #' num2str(r) ' [' CaObj(1).ROIType{r} ']'], 'FontSize', 20, 'Color', [0.5 0.2 0]);
    text(lim(1)+10, lim(2)-20, ['P=' num2str(p)], 'FontSize', 13, 'Color', [0 p<0.05 0]); 
end

saveppt2(pptfile,'figure',fig(1:end),'scale','halign','left','columns',ceil(sqrt(length(fig))));

%% Compare tuft and trunk responses
selective_TUFT_rois = [1 2 5 7 8 9 11 12];
selective_TRUNK_rois = [4 6 7 8 9];
all_TUFT_rois = 1:CaObj(1).nROIs;
all_TRUNK_rois = 1:obj_trunk(1).nROIs;
%% Events Probability of Stimulation Epoch
prob_TUFT_stim = roievntTF_stim.numEvent_mean(selective_TUFT_rois);
prob_TRUNK_stim = roievntTRUNK_stim.numEvent_mean(selective_TRUNK_rois);
[h,p] = ttest2(prob_TUFT_stim, prob_TRUNK_stim)

event_prob = [prob_TUFT_stim prob_TRUNK_stim];
tuftlabels = repmat('Tuft ', length(prob_TUFT_stim), 1);
trunklabels = repmat('Trunk', length(prob_TRUNK_stim),1);
figure; hold on;
boxplot(event_prob, [tuftlabels; trunklabels],'labels',{'Tuft','Trunk'});
set(gca, 'FontSize', 15); 
% set(gca, 'XTickLabel', {'Tuft', 'Trunk'}, 'FontSize', 15);
title('Event Probability for Trunk and Tuft', 'FontSize', 18);

%% Peak dF/F distribution of Stimulation Epoch
peaks_Tuft_stim = roievntTF_stim.peaks;
peaks_Trunk_stim = roievntTRUNK_stim.peaks;
figure; hold on;
h1 = cdfplot(peaks_Tuft_stim(peaks_Tuft_stim>0));
h2 = cdfplot(peaks_Trunk_stim(peaks_Trunk_stim>0));
set(h2, 'Color', 'r');
set(gca,'FontSize', 15);
legend('Tuft', 'Trunk');
title('CDF of peak dF/F in Stim Epoch', 'FontSize', 18);
set(get(gca, 'XLabel'), 'String', 'Event Peak dF/F (%)', 'FontSize', 18);
[h,p] = kstest2(peaks_Tuft_stim(peaks_Tuft_stim>0), ...
    peaks_Trunk_stim(peaks_Trunk_stim>0))
%%
figure; hold on;
hist(peaks_Tuft_stim(peaks_Tuft_stim>0),50);
hist(peaks_Trunk_stim(peaks_Trunk_stim>0),50);
h = findobj('Type', 'Patch');
set(h(1), 'FaceColor', 'r', 'EdgeColor', 'k');
set(gca,'FontSize', 15); legend('Tuft', 'Trunk');
title('Event peak dF/F in Stim Epoch', 'FontSize', 18);
xlabel('Event Peak dF/F (%)', 'FontSize', 18);
ylabel('Event Count', 'FontSize', 18);