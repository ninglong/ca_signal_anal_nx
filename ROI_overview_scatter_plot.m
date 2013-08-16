function ROI_overview_scatter_plot(CaObj)

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