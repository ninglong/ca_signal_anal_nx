%% Get max delta projection over multi trials
%% get data file names
fpath = 'E:\DATA\ImagingData\Awake\Behavior_Imaging\NXJF31552\090420';
fname_prefix = 'Den3_64_4x';
files = dir([fpath filesep fname_prefix '*']);
%%
for i = 1:length(files)
    %%
    img_filename = files(i).name;
    smooth_flag = 1;
    finfo = imfinfo(img_filename);
    img = imread_multi(img_filename, 'g');
    maxDelta = zeros(size(img,1), size(img,2), 'uint16');
    
    mean_img = uint16(mean(img, 3));
    if smooth_flag == 1
        img = im_mov_avg(img, 5);
    end;
    
    maxDelta(:,:,i) = max(img,[],3) - mean_img;
    figure(gcf);
    imagesc(maxDelta(:,:,i), [0 300]); colormap(gray);
    imwrite(maxDelta(:,:,i), [fname_prefix '_maxDelta_over_trials.tif'] ,'compression','none',...
        'Description',finfo(1).ImageDescription,'WriteMode','append');
end;
maxSum_trials = uint16(sum(maxDelta,3));
figure(gcf);
imagesc(maxSum_trials, [0 300]);

%% Plot Ca traces of multiple trials
datapath = 'E:\DATA\ImagingData\Awake\Behavior_Imaging\NXJF31552\090420';
fname_prefix = 'Den1_64_6x';
cd(datapath);
Ca_results_file = dir([fname_prefix '_Result*']);
results = {};

ca = {}; ts = {}; roiNum = 1;
for k = 1: length(Ca_results_file)
    result_fname = Ca_results_file(k).name;
    load(result_fname,'-mat');
    %for k = 1:n_roi
    for trialID = 1:length(Result) % loop over trials
        ca = [ca Result{trialID}.CellImage.*100];
        ts = [ts Result{trialID}.xValues/1000];
    end
    clear Restult; % to save memory
    %end
end;

%%
Ca_plot_trace_array(ca, ts, go_ind, 1);

%% pseudo color plotting
ca_go = cell2mat(ca(go_ind-2)');
H = pcolor(ca_go); 
title('Go Trials');
set(H,'EdgeColor','none');

ca_nogo = cell2mat(ca(nogo_ind- s.trim(1))');
figure; H = pcolor(ca_nogo);
title('NoGo Trials');
set(H,'EdgeColor','none');
%% Turboreg motion correction batch
mouse_name = 'NXJF00032027';
session = '090504';
datapath = 'E:\DATA\ImagingData\Awake\Behavior_Imaging\';
prefix = {'dendr3_8Hz_16x_behav_'};
target_filename = {'AVG_dendr3_8Hz_16x_behav_reg_006.tif'};

cd([datapath mouse_name filesep session]);
for i = 1:length(target_filename)
    data_file = dir([prefix{i} '*.tif']);
    tic;
    for j = 1:length(data_file)
        source_filename = data_file(j).name;
        disp(['correcting ' source_filename]);
        Turboreg_nx2(target_filename{i}, source_filename, 'rigidBody',0);
        
    end;
    disp(['Finished correction with target file: ' target_filename{i}]);
    toc
end


%% Get CaTrials of different trial types

nTrials = length(CaTrials);

for i = 1:nTrials
    pinOnsetTime(i) = CaTrials(i).behavTrial.pinDescentOnsetTime;
end

Ca_behavInds = get_Ca_behavInds(CaTrials);

CaTrials_hit = CaTrials(bta.hitTrialInds(Ca_behavInds));

t_pin_hit = pinOnsetTime(bta.hitTrialInds(Ca_behavInds));

[t_pin_hit_sort, ix] = sort(t_pin_hit);
CaTrials_hit_sort_by_pintime = CaTrials_hit(ix);

CaTrials_miss = CaTrials(bta.missTrialInds(Ca_behavInds));
CaTrials_FA = CaTrials(bta.falseAlarmTrialInds(Ca_behavInds));
CaTrials_CR = CaTrials(bta.correctRejectionTrialInds(Ca_behavInds));

Offset = bta.trim(1); % bta, BehavTrialArray object

% Sort hit trilas by go positions
goPos_hit = [];
for i = 1:length(CaTrials_hit)
    goPos_hit(i) = CaTrials_hit(i).behavTrial.goPosition;
end;
[goPos_hit_sort, ind_sort_by_pos] = sort(goPos_hit);
CaTrials_hit_sort_by_pos = CaTrials_hit(ind_sort_by_pos);

%% Plot pcolor of Ca signals in different trial types and Mark behavior times

ROInum = 2;
plot_whisker = 0;

if plot_whisker==0
    titleStr = ['ROInum ' num2str(ROInum) '--' CaTrials(1).AnimalName '-' CaTrials(1).ExpDate '-' CaTrials(1).SessionName];
    color_sc = [-10 220];
else
    titleStr = ['AvgWhiskerSpeed' '--' CaTrials(1).AnimalName '-' CaTrials(1).ExpDate '-' CaTrials(1).SessionName];
    color_sc = [0 4.5];
end

if ~exist('fig1','var') || ~ishandle(fig1)
    scrsz = get(0, 'ScreenSize');
    fig1 = figure('Position', [20, 50, scrsz(3)/4+100, scrsz(4)-200], 'Color', 'w');
else
    figure(fig1); clf;
end;
axes0 = axes('Position', [0 0 1 1], 'Visible', 'off');

h_axes1 = axes('Position', [0.1, 0.05, 0.8, length(CaTrials_hit)/nTrials*0.85]);
%h_hit = cplot_Ca_behav_trials(CaTrials_hit,ROInum,color_sc,h_axes1);
h_hit = cplot_Ca_behav_trials(CaTrials_hit_sort_by_pos,ROInum,color_sc,h_axes1,plot_whisker);
set(h_axes1,'Box','off');

h_axes2 = axes('Position', [0.1, length(CaTrials_hit)/nTrials*0.85+0.06, 0.8,...
    length(CaTrials_miss)/nTrials*0.85]);
h_miss = cplot_Ca_behav_trials(CaTrials_miss,ROInum,color_sc,h_axes2,plot_whisker);
set(h_axes2,'XTickLabel','','Box','off');

h_axes3 = axes('Position', [0.1, length([CaTrials_hit CaTrials_miss])/nTrials*0.85+0.07, 0.8,...
    length(CaTrials_CR)/nTrials*0.85]);
h_cr = cplot_Ca_behav_trials(CaTrials_CR,ROInum,color_sc,h_axes3,plot_whisker);
set(h_axes3,'XTickLabel','','Box','off');

h_axes4 = axes('Position', [0.1, length([CaTrials_hit CaTrials_miss CaTrials_CR])/nTrials*0.85+0.08,...
    0.8, length(CaTrials_FA)/nTrials*0.85]);
h_fa = cplot_Ca_behav_trials(CaTrials_FA,ROInum,color_sc,h_axes4,plot_whisker);
set(h_axes4,'XTickLabel','','Box','off');
if plot_whisker==0
    title(['ROInum ' num2str(ROInum) '--' CaTrials(1).AnimalName '-' CaTrials(1).ExpDate '-' CaTrials(1).SessionName], 'FontSize', 15);
else
    title(['AvgWhiskerSpeed' '--' CaTrials(1).AnimalName '-' CaTrials(1).ExpDate '-' CaTrials(1).SessionName], 'FontSize', 15);
end
%%
CaTraces_hit = get_CaTraces(CaTrials_hit, ROInum);
CaTraces_hit_pinTime = get_CaTraces(CaTrials_hit_sort_by_pintime, ROInum);
CaTraces_miss = get_CaTraces(CaTrials_miss, ROInum);
CaTraces_CR = get_CaTraces(CaTrials_CR, ROInum);
CaTraces_FA = get_CaTraces(CaTrials_FA, ROInum);

%%

figure(fig2);
%trace_sorted = CaSignal_hit_sort_by_goPos;
trace_sorted = CaSignal_hit_sort_by_pintime;
h_pc2 = pcolor(ts{1}, (1:length(trace_sorted)), [trace_sorted; zeros(1,size(trace_sorted,2))]);
set(h_pc2, 'EdgeColor','none'); caxis(color_axis); colormap(jet);
title(['ROI ' num2str(ROInum)]);

%% 
Ca_plot_trace_array(CaSignalArray, ts, bta.hitTrialNums-Offset+1,3);

%%
% for i = 1:length(CaTrials)
trace = CaTrials(48).CaTrace_raw(:,3);
F0 = prctile(trace, 30);
dFF = (trace - F0)/F0 * 100;
plot(dFF);
sd = std(dFF);
sd_minus = std(dFF(dFF<=0));
sd_plus = std(dFF(dFF>0));

line([0 60], [10.3560 10.3560], 'Color','r', 'LineStyle', '--');

% peak_dFF(i) = max(dFF);
% [n, xout] = hist(peak_dFF,20);
% end

%%
% average window: pinOnsetTime ~ pinOnsetTime+5
window_length = 5; % sec
frameNumLimit = round(window_length/CaTrials(1).FrameTime);
CaSignal_wind = [];
for i = 1:nTrials
    Inds = (ts{i}>=pinOnsetTime(i) & ts{i}<=pinOnsetTime(i)+5);
    temp = CaSignal(i,Inds);
    if length(temp)> frameNumLimit
        temp(frameNumLimit+1:end) = [];
    end
    CaSignal_wind = [CaSignal_wind; temp];
end
CaSignal_wind_hit = CaSignal_wind(bta.hitTrialInds,:);
Ca_hit_mean = mean(CaSignal_wind_hit,1);
Ca_hit_se = std(CaSignal_wind_hit, 0, 1)/sqrt(nTrials);
goPos_hit = goPos(bta.hitTrialInds);
hit_go1_ind = (goPos_hit == bta.goPositionSettings(1));
hit_go2_ind = (goPos_hit == bta.goPositionSettings(2));
hit_go3_ind = (goPos_hit == bta.goPositionSettings(3));
hit_go4_ind = (goPos_hit == bta.goPositionSettings(4));

Ca_hit_mean_go{1} = mean(CaSignal_wind_hit(hit_go1_ind,:), 1);
Ca_hit_mean_go{2} = mean(CaSignal_wind_hit(hit_go2_ind,:), 1);
Ca_hit_mean_go{3} = mean(CaSignal_wind_hit(hit_go3_ind,:), 1);
Ca_hit_mean_go{4} = mean(CaSignal_wind_hit(hit_go4_ind,:), 1);

ts2 = (1:size(CaSignal_wind,2)).*CaTrials(1).FrameTime;
figure; hold on; 
plot(ts2, Ca_hit_mean_go{1}, 'b', 'LineWidth', 2);
plot(ts2, Ca_hit_mean_go{2}, 'g', 'LineWidth', 2);
plot(ts2, Ca_hit_mean_go{3}, 'r', 'LineWidth', 2);
plot(ts2, Ca_hit_mean_go{4}, 'm', 'LineWidth', 2);
legend(['GoPos ' num2str(bta.goPositionSettings(1))], ['GoPos ' num2str(bta.goPositionSettings(2))],...
    ['GoPos ' num2str(bta.goPositionSettings(3))], ['GoPos ' num2str(bta.goPositionSettings(4))]);  
set(gca, 'FontSize', 14);
set(get(gca,'XLabel'),'String', 'Time from Pole Onset', 'FontSize', 17);
set(get(gca,'YLabel'),'String', 'dF/F0', 'FontSize', 17);
title('Mean Ca Trace, Aligned to Pole Onset', 'FontSize', 17);

%% Performance for different Go positions
goPosInGo = goPos(logical(bta.hitTrialInds + bta.missTrialInds));
goPosInd{1} = (goPosInGo == bta.goPositionSettings(1));
goPosInd{2} = (goPosInGo == bta.goPositionSettings(2));
goPosInd{3} = (goPosInGo == bta.goPositionSettings(3));
goPosInd{4} = (goPosInGo == bta.goPositionSettings(4));
scoreGoPos(1) = sum(hit_go1_ind)/sum(goPosInd{1})*100;
scoreGoPos(2) = sum(hit_go2_ind)/sum(goPosInd{2})*100;
scoreGoPos(3) = sum(hit_go3_ind)/sum(goPosInd{3})*100;
scoreGoPos(4) = sum(hit_go4_ind)/sum(goPosInd{4})*100;
figure;
bar(scoreGoPos);
set(gca, 'XTickLabel', {'Go1','Go2','Go3','Go4'}, 'FontSize', 15);
set(get(gca, 'YLabel'), 'String', 'Perc Correct in Go Trial', 'FontSize', 17);

%% get ROIinfo from CaTrials
ROIinfo = {};
for i = 1:length(CaTrials)
    for j=1:CaTrials(i).nROIs
        ROIinfo{i}.ROIpos{j} = CaTrials(i).ROIinfo(j).ROIpos;
        ROIinfo{i}.ROIMask{j} = CaTrials(i).ROIinfo(j).ROIMask;
    end
end
%%
save(['ROIinfo_' CaTrials(1).FileName_prefix],'ROIinfo');

%% Construct Ca Imaging Trial objects
CaObj = CaImageTrials(CaTrials);
% subtract a mean trace
CaObj = CaObj.sub_mean_trace;
% Load solo behavior data
solo_data = solo_load_data(mouseName, sessionName,trialStartEnd);
% add behavior trial data to CaObj
behavTrials = CaObj.Ca_add_behavTrialObj(solo_data);
% Ca transients event detection
Events = CaObj.get_Transients;

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
%% Put sorted Ca trials together
CaObj_sorted = [CaObj_hit CaObj_miss CaObj_cr CaObj_fa];


%% batch Plot traces with events, and copy to PowerPoint - Aug, 09
nROI = CaObj(1).nROIs;
types = {'Hit', 'Miss', 'Crr_Rej', 'False_Alarm', 'Sorted', 'Original'};
pptfile = 'E:\DATA\ImagingData\Awake\Behavior_Imaging\NXJF36705\090716\PPT_files\JF36705_trunk1_d100_beh_dftReg_test2.pptx';
for ROInum = 1:nROI
    for trialtype = 6 ;%[1 2 3 4];
        chunk = 10; % number of traces per figure
        close all; clear fig;
        % doppt('new');
        switch types{trialtype}
            case 'Hit'
                obj = CaObj_hit;
            case 'Miss'
                obj = CaObj_miss;
            case 'Crr_Rej'
                obj = CaObj_cr;
            case 'False_Alarm'
                obj = CaObj_fa;
            case 'Sorted'
                obj = CaObj_sorted;
            otherwise
                obj = CaObj;
        end
        
        for i=1:ceil(length(obj)/chunk)
            indStart = (i-1)*chunk+1;
            if i*chunk > length(obj)
                indEnd = length(obj);
            else
                indEnd = i*chunk;
            end
            Tstr = sprintf('ROI # %d, Trial # %d - %d', ROInum, indStart, indEnd);
            fig(i)= obj.plot_CaTraces_trials(ROInum, (indStart:indEnd), 1);
            text(1, 120, Tstr, 'FontSize',15);
        end
        ttl = sprintf('Ca Traces of ROI %d in %s trials, w/ detected events', ROInum, types{trialtype});
        if length(fig)>4
            for i=1:ceil(length(fig)/4)
                indStart = (i-1)*4+1;
                if i*4>length(fig)
                    indEnd=length(fig);
                else
                    indEnd=i*4;
                end
                saveppt2(pptfile,'figure',fig(indStart:indEnd),'scale','halign','left','columns',4,'title',ttl);
            end
        else
            saveppt2(pptfile,'figure',fig(1:end),'scale','halign','left','columns',length(fig),'title',ttl);
        end
    end
end
%%
% get Ca Transients events from CaObj array
event = struct([]); 
criteriaID = 1;
for i = 1:length(obj)
    % boundary point bp
    bp = obj(i).behavTrial.pinAscentOnsetTime + obj(i).behavTrial.waterValveDelay;
    for j=1:obj(1).nROIs
        event = obj(i).CaTransients{j};
        if ~isempty(event)
            criteria=[];
            for k = 1:length(event)
                p = []; a=[]; w=[]; 
                criteria(1) = event(k).time_thresh < bp;
                criteria(2) = event(k).time_thresh > bp;
                % criteria(2) = true;
                if criteria(criteriaID) == true
                    disp(p)
                    p(k) = event(k).peak;
                    a(k) = event(k).area;
                    w(k) = event(k).fwhm;
                    t(k) = event(k).tauDecay;
                    peaks(i,j) = max(p);
                    areas(i,j) = max(a);
                    areasNorm(i,j) = max(a./w);
                    tauDecay(i,j) = t(p==max(p)); % tau of the events with largest peak
                end
                numEvent(i,j)= numel(p);
            end
        end
    end
end
switch criteriaID
    case 1
        str='Stim Epoch';
    case 2
        str='Reward Epoch';
    case 3
        str='Full Trial';
end
% color plotting
fig1 = figure('Position',[30   240   480   580]);
imagesc(peaks); colorbar; set(gca, 'FontSize',12); 
xlabel('ROI #', 'FontSize', 15); ylabel('Trial #', 'FontSize', 15);
title(['Peak of Events in ' str], 'FontSize', 18);
set(gca,'YDir','normal');

%% summary plot of ROI events
mean_numEvents = mean(numEvent,1); se_numEvents=std(numEvent,0,1)./sqrt(length(obj));
mean_ROI_peaks=mean(peaks,1); se_ROI_peaks=std(peaks,0,1)./sqrt(length(obj));
mean_ROI_areas=mean(areas,1); se_ROI_areas=std(areas,0,1)./sqrt(length(obj));

%%
fig2 = figure('Position',[50   240   480   580]);
imagesc(areas); colorbar; set(gca, 'FontSize',12); caxis([0 250]);
xlabel('ROI #', 'FontSize', 15); ylabel('Trial #', 'FontSize', 15);
title('Area of Events', 'FontSize', 18);
set(gca,'YDir','normal');
%%
fig3 = figure('Position',[70   240   480   580]);
imagesc(areasNorm); colorbar; set(gca, 'FontSize',12); 
xlabel('ROI #', 'FontSize', 15); ylabel('Trial #', 'FontSize', 15);
title('Normalized Area of Events', 'FontSize', 18);
set(gca,'YDir','normal');

%% Compare epochs for each ROI
ROInum=2;
obj=CaObj;
trialInds=(1:length(obj));
count=0;
trialTS=(1:obj(1).nFrames).*obj(1).FrameTime/1000;
for i=trialInds
    stimOnset=obj(i).behavTrial.pinDescentOnsetTime;
    stimOffset=obj(i).behavTrial.pinAscentOnsetTime+obj(i).behavTrial.waterValveDelay;
%     rewardOnset=stimOffset;
%     rewardOffset=trialTS(end);
    epochStimInd=find(trialTS>stimOnset & trialTS<stimOffset);
    epochRewardInd=find(trialTS>stimOffset);
    count = count+1;
    val_epochStim = obj(i).CaTrace(ROInum,epochStimInd);
    val_epochReward = obj(i).CaTrace(ROInum,epochRewardInd);
    mdFF_stim(count) = mean(val_epochStim);
    mdFF_rwd(count) = mean(val_epochReward);
    peak_stim(count)=max(val_epochStim);
    peak_rwd(count)=max(val_epochReward);
end
figure(gcf); clf;  hold on;
plot(mdFF_stim, mdFF_rwd,'.');
%plot(peak_stim, peak_rwd,'ro');
hold off;

%%




