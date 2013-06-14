%% Sort Ca Trial objects - Aug, 09
CaObj_hit=[]; CaObj_miss=[]; CaObj_cr=[]; CaObj_fa=[];
for i = 1:length(CaObj)
    if CaObj(i).behavTrial.trialType==1
        if CaObj(i).behavTrial.trialCorrect==1
            CaObj_hit=[CaObj_hit CaObj(i)];
        else
            CaObj_miss=[CaObj_miss CaObj(i)];
        end
    else
        if CaObj(i).behavTrial.trialCorrect==1
            CaObj_cr=[CaObj_cr CaObj(i)];
        else
            CaObj_fa=[CaObj_fa CaObj(i)];
        end
    end
end
%% Sort Ca hit trials by go positions
goPos_hit = [];
for i = 1:length(CaObj_hit)
    goPos_hit(i) = CaObj_hit(i).behavTrial.goPosition;
end;
[goPos_hit_sort, inds_sort_by_pos] = sort(goPos_hit);
CaObj_hit_sort_by_go = CaObj_hit(inds_sort_by_pos);

%% Label the pole position of go trial
if ~isempty(CaObj(1).behavTrial)
    for i = 1:length(CaObj)
        PolePos(i) = CaObj(i).behavTrial.goPosition;
    end
    PossibleGoPositions = unique(PolePos);
    clrs = {'w','g','y','m'};
    for i = 1:length(PossibleGoPositions)
        polePos_colors(PolePos == PossibleGoPositions(i)) = clrs(i);
    end
end

%%
ROInum = 6;
nTrials = length(CaObj);
titleStr = ['ROInum ' num2str(ROInum) '--' CaObj(1).AnimalName '-' CaObj(1).ExpDate '-' CaObj(1).SessionName];
color_sc = [-10 220];
ts = (1:CaObj(1).nFrames).*CaObj(1).FrameTime;
if ~exist('fig1','var') || ~ishandle(fig1)
    scrsz = get(0, 'ScreenSize');
    fig1 = figure('Position', [20, 50, scrsz(3)/4+100, scrsz(4)-200], 'Color', 'w');
else
    figure(fig1); clf;
end;
axes0 = axes('Position', [0 0 1 1], 'Visible', 'off');

h_axes1 = axes('Position', [0.1, 0.05, 0.8, length(CaObj_hit)/nTrials*0.85]);
%h_hit = cplot_Ca_behav_trials(CaObj_hit,ROInum,color_sc,h_axes1);
CaTraces_hit = CaObj_hit_sort_by_go.get_CaTraces(ROInum,'asis');
eventTimes = CaObj_hit_sort_by_go.get_behavTimes;
h_hit = cplot_Ca_behav_trials(CaTraces_hit,ts,eventTimes.lick, eventTimes.poleOnset, ...
    eventTimes.answerLick, h_axes1,color_sc,polePos_colors);
set(h_axes1,'Box','off');

h_axes2 = axes('Position', [0.1, length(CaObj_hit)/nTrials*0.85+0.06, 0.8,...
    length(CaObj_miss)/nTrials*0.85]);
CaTraces_miss = CaObj_miss.get_CaTraces(ROInum,'asis');
eventTimes = CaObj_miss.get_behavTimes;
h_miss = cplot_Ca_behav_trials(CaTraces_miss,ts,eventTimes.lick, eventTimes.poleOnset, ...
    eventTimes.answerLick, h_axes2,color_sc,polePos_colors);
set(h_axes2,'XTickLabel','','Box','off');

h_axes3 = axes('Position', [0.1, length([CaObj_hit CaObj_miss])/nTrials*0.85+0.07, 0.8,...
    length(CaObj_cr)/nTrials*0.85]);
CaTraces_cr = CaObj_cr.get_CaTraces(ROInum,'asis');
eventTimes = CaObj_cr.get_behavTimes;
h_cr = cplot_Ca_behav_trials(CaTraces_cr,ts,eventTimes.lick, eventTimes.poleOnset, ...
    eventTimes.answerLick, h_axes3,color_sc,polePos_colors);
set(h_axes3,'XTickLabel','','Box','off');

h_axes4 = axes('Position', [0.1, length([CaObj_hit CaObj_miss CaObj_cr])/nTrials*0.85+0.08,...
    0.8, length(CaObj_fa)/nTrials*0.85]);
CaTraces_fa = CaObj_fa.get_CaTraces(ROInum,'asis');
eventTimes = CaObj_fa.get_behavTimes;
h_fa = cplot_Ca_behav_trials(CaTraces_fa,ts,eventTimes.lick, eventTimes.poleOnset, ...
    eventTimes.answerLick, h_axes4,color_sc,polePos_colors);
set(h_axes4,'XTickLabel','','Box','off');
title(['ROInum ' num2str(ROInum) '--' CaObj(1).AnimalName '-' CaObj(1).ExpDate '-' CaObj(1).SessionName], 'FontSize', 15);
