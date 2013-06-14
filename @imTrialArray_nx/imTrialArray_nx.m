% Class for an array of imaging trials
% NX Feb 2009
%
classdef imTrialArray_nx < handle
    
    properties
        SessionName = '';
        AnimalName = '';
        ExpDate = '';
        imTrials = {};  % take the object array of imaging trials
        % FileName = '';
        FileName_prefix = '';
        %         nTrials = [];
        nROIs = []; % total number of ROIs
        ROI_type = {};
        
        nFramesPerTrial = [];
        FrameTime =[]; % time for each frame, in ms
        nChannels = 1;
        %         Ca_events = {}; %
        SoloTrials = {};
        EphusTrials = [];
        WhiskerTrials = {};
        %         SoloTrials = [];
        PPT_filename = '';
        excluded_fileNo = [];
        trialInds = struct([]);
    end
    
    properties (Dependent, SetAccess = private)
        roi_events_param
        trialNums
        imageDim
        roiPos
        roiMask
        nTrials
        SoloTrialNums
        barTime_trial
    end
    
    methods (Access = public)
        %%
        function obj = imTrialArray_nx(imTrialsObj, varargin)
            obj.SessionName = imTrialsObj(1).SessionName;
            obj.AnimalName = imTrialsObj(1).AnimalName;
            obj.ExpDate = imTrialsObj(1).ExpDate;
            obj.FileName_prefix = imTrialsObj(1).FileName_prefix;
            %             obj.nTrials = length(imTrialsObj);
            obj.nROIs = imTrialsObj(1).nROIs;
            obj.ROI_type = imTrialsObj(1).ROIType;
            obj.nFramesPerTrial = imTrialsObj(1).nFrames;
            obj.FrameTime = imTrialsObj(1).FrameTime;
            obj.nChannels = imTrialsObj(1).nChannel;
            for i = 1:length(imTrialsObj)
                obj.imTrials{i} = imTrialsObj(i);
                
                if ~isempty(imTrialsObj(i).behavTrial)
                    obj.SoloTrials{i} = imTrialsObj(i).behavTrial;
                end
                %                 for j = 1:obj.nROIs
                %                     obj.Ca_events{i,j} = imTrialsObj(i).CaTransients{j};
                %                 end
            end
            %             obj.roi_events_param = obj.get_roi_events_param;
            
        end
        % ************************************************************************************
        %%
        function r = get_trial_inds(obj, wsArray)
            if nargin < 2 || isempty(wsArray)
                trInds = obj.trialInds_sorted_by_behav;
                r.sort_by_solo = {trInds.hit, trInds.miss, trInds.cr, trInds.fa};
                r.sort_by_touch = NaN;
                r.touch_only = NaN;
                r.no_sorting = {1:obj.nTrials};
            else
                behavArray = obj.make_behavTrialArray;
                r.sort_by_solo = get_session_trialInds(obj,behavArray,wsArray,1);
                r.sort_by_touch = get_session_trialInds(obj,behavArray,wsArray,2);
                r.touch_only = get_session_trialInds(obj, behavArray, wsArray, 4);
                r.no_sorting = get_session_trialInds(obj,behavArray,wsArray,3);
            end
            obj.trialInds = r;
        end
        
        function trial_inds = trialInds_sorted_by_behav(obj)
            ind_hit = []; ind_miss=[]; ind_cr=[]; ind_fa=[];
            for i = 1:obj.nTrials
                if obj.SoloTrials{i}.trialType==1
                    if obj.SoloTrials{i}.trialCorrect==1
                        ind_hit =[ind_hit i];
                    else
                        ind_miss=[ind_miss i];
                    end
                else
                    if obj.SoloTrials{i}.trialCorrect==1
                        ind_cr=[ind_cr i];
                    else
                        ind_fa = [ind_fa i];
                    end
                end
            end
            trial_inds.go = [ind_hit ind_miss];
            trial_inds.nogo = [ind_cr ind_fa];
            trial_inds.hit = ind_hit;
            % trial_inds.hit_goPos = ind_hit_goPos;
            trial_inds.miss = ind_miss;
            trial_inds.cr = ind_cr;
            trial_inds.fa = ind_fa;
            
            % Sort go trials by object positions.
            for i = 1:length(trial_inds.go)
                goPos(i) = obj.SoloTrials{trial_inds.go(i)}.goPosition;
            end
            [goPos_sorted, inds_temp] = sort(goPos);
            trial_inds.go_pos_sort = trial_inds.go(inds_temp);
        end
        %%
        function recompute_Ca_events_params(obj)
            imTrs = obj.imTrials;
            parfor i = 1:obj.nTrials
                imTrs{i} = imTrs{i}.get_Transients;
            end
            obj.imTrials = imTrs;
        end
        
        %%
        function ROI_events_overview(obj,varargin)
            % varargin{1}, plot_mean_flag.
            % varargin{2}, roi_nums
            % varargin{3}, color_scale
            if nargin > 1 && ~isempty(varargin{1})
                plot_mean_flag = varargin{1};
            else
                plot_mean_flag = 0;
            end
            if nargin > 2 && ~isempty(varargin{2})
                roi_nums = varargin{2};
            else
                roi_nums = 1:obj.nROIs;
            end
            if nargin > 3
                colorScale = varargin{3};
            else
                colorScale = [];
            end
            if isempty(obj.roi_events_param)
                roi_events = obj.get_roi_events_param;
            else
                roi_events = obj.roi_events_param;
            end
            T_BarIn = cellfun(@(x) x.pinDescentOnsetTime + 0.4, obj.SoloTrials);
            T_BarOut = cellfun(@(x) x.pinAscentOnsetTime + 0.4, obj.SoloTrials);
            
            evPeak_stim = nan(obj.nTrials, obj.nROIs);
            evPeak_reward = nan(obj.nTrials, obj.nROIs);
            
            for i = 1 : length(roi_nums)
                n = roi_nums(i);
                trialIDs = arrayfun(@(x) x.trialID, roi_events{n});
                TThresh = arrayfun(@(x) x.time_thresh, roi_events{n});
                peaks = arrayfun(@(x) x.peak, roi_events{n});
                inds1 = (TThresh > mean(T_BarIn) & TThresh < mean(T_BarOut));
                inds2 = (TThresh > mean(T_BarOut));
                evPeak_stim(trialIDs(inds1),i) = peaks(inds1);
                evPeak_reward(trialIDs(inds2), i) = peaks(inds2);
            end
            
            fig1 = roi_overview_color_plot(evPeak_stim,'Events Peak in Stim Epoch', colorScale); % 'Stim Epoch'
            fig2 = roi_overview_color_plot(evPeak_reward, 'Events Peak in Reward Epoch', colorScale); % 'Reward Epoch'
            fig3 = figure('color','w');
            errorbar(nanmean(evPeak_stim), nanstd(evPeak_stim,0,1),'-o','markersize',12,'linewidth',2);
            xlabel('ROI #','Fontsize',15);
            set(gca,'box','off','fontsize',15)
            if plot_mean_flag == 1
                avg1 = nanmean(evPeak_stim); se1 = nanstd(evPeak_stim,0,1)./sqrt(obj.nTrials);
                avg2 = nanmean(evPeak_reward); se2 = nanstd(evPeak_reward,0,1)./sqrt(obj.nTrials);
                ystr = 'Peak dF/F (%)'; %'Event Probability'; %
                xstr = 'ROI #';
                legstr = {'Stim', 'Reward'};
            end
            
            function fig = roi_overview_color_plot(param, varargin)
                % varargin{1}, title_str, 
                % varargin{2}, colorScale
                % varargin{3}, roi_nums
                title_str = varargin{1}; 
                
                fig = figure('Position',[30   240   480   580]);
                imagesc(param); colorbar; set(gca, 'FontSize',12);
                colormap('Hot');
                xlabel('ROI #', 'FontSize', 15);
                ylabel('Trial #', 'FontSize', 15);
                title(title_str, 'FontSize', 18);
                set(gca,'YDir','normal');
                if nargin<3 || isempty(varargin{2})
                    cl = get(gca, 'CLim');
                    colorScale = cl*.7;
                else
                    colorScale = varargin{2};
                end
                set(gca,'CLim',colorScale);
            end
            
        end
        
        %% Scatter plot, Compare Epochs for all ROIs
        function [h,p] = ROI_epoch_compare(obj,ppt_filename,trial_type)
            if nargin < 2
                ppt_filename = obj.PPT_filename;
                trial_type = 'all';
            end
            if nargin < 3
                trial_type = 'all';
            end
            inds = obj.trialInds_sorted_by_behav;
            switch trial_type
                case 'all'
                    trialInds = 1:obj.nTrials;
                case 'go'
                    trialInds = inds.go;
                case 'nogo'
                    trialInds = inds.nogo;
                case 'hit'
                    trialInds = inds.hit;
                case 'cr'
                    trialInds = inds.cr;
            end
            trialTS=(1:obj.nFramesPerTrial).*obj.FrameTime/1000;
            
            for r = 1:obj.nROIs
                %     numEvents{r} = rp_stim.numEvent(:,r);
                %     numEvents{r} = rp_rwd.numEvent(:,r);
                fig(r) = figure; hold on;
                count=0;
                peakF_stim = [];
                peakF_rwd = [];
                mdFF_stim = [];
                mdFF_rwd = [];
                for i = trialInds
                    stimOnset = obj.SoloTrials{i}.pinDescentOnsetTime;
                    stimOffset = obj.SoloTrials{i}.pinAscentOnsetTime + obj.SoloTrials{i}.waterValveDelay;
                    epochStimInd = find(trialTS>stimOnset & trialTS<stimOffset);
                    epochRewardInd = find(trialTS>stimOffset);
                    count = count+1;
                    val_epochStim = obj.imTrials(i).dff(r,epochStimInd);
                    val_epochReward = obj.imTrials(i).dff(r,epochRewardInd);
                    mdFF_stim(count) = mean(val_epochStim);
                    mdFF_rwd(count) = mean(val_epochReward);
                    peakF_stim(count) = max(val_epochStim);
                    peakF_rwd(count) = max(val_epochReward);
                end
                [h(r),p(r)] = ttest(peakF_rwd, peakF_stim);
                plot(peakF_rwd, peakF_stim, 'o');
                lim(1) = min([get(gca, 'YLim') get(gca, 'XLim')]);
                lim(2) = max([get(gca, 'YLim') get(gca, 'XLim')]);
                xlim([lim(1) lim(2)]); ylim([lim(1) lim(2)]);
                line([lim(1) lim(2)], [lim(1) lim(2)],'Color','r');
                set(gca,'FontSize', 15, 'box', 'on');
                ylabel('Peak dF/F in Stim', 'FontSize', 18);
                xlabel('Peak dF/F in Reward', 'FontSize', 18);
                title(['ROI #' num2str(r) ' [' obj.ROI_type{r} '] ' trial_type], 'FontSize', 20, 'Color', [0.5 0.2 0]);
                text(lim(1)+10, lim(2)-20, ['P=' num2str(p(r))], 'FontSize', 13, 'Color', [0 p(r)<0.05 0]);
            end
            
            saveppt2(ppt_filename,'figure',fig(1:end),'scale','halign','left','columns',ceil(sqrt(length(fig))));
        end
        
        %% batch plot color raster for each ROIs with significant modulation
        %         function h_figs = batch_color_raster(obj,ROIs,colorScale, doppt_flag,ppt_filename)
        function h_figs = batch_color_raster(obj,ROIs,colorScale,trialSorting, plot_behavEvents, label_trial_color)
            % h_figs = batch_color_raster(obj,ROIs,colorScale,trialSorting, plot_behavEvents, label_trial_color)
            % ROIs, a vector or [].
            % colorScale, 1x2 vector or [];
            % trialSorting: 0, no sorting
            %               1, sort by solo behavior
            %               2, sort by considering both solo behavior and whisker contact
            % plot_mean: 0, do not plot mean traces; 1, plot mean traces (PSTH)
            if isempty(ROIs)
                ROIs = 1: obj.nROIs;
            end
            bar_pos_trial = cellfun(@(x) x.goPosition*x.trialType + x.nogoPosition*(1-x.trialType), obj.SoloTrials);
            if isempty(obj.trialInds)
                if isempty(obj.SoloTrials)
                    warning('No Solo trials, plot without sorting');
                    ti = 1: obj.nTrials;
                    sort_str = 'no sorting';
                else
                    %                     warning('Trials cannot be sorted by whisker touch, using default sorting by solo behavior!')
                    %                     Inds = obj.trialInds_sorted_by_behav;
                    %                     ti{1} = Inds.go_pos_sort(ismember(Inds.go_pos_sort,Inds.hit));
                    %                     ti{2} = Inds.go_pos_sort(ismember(Inds.go_pos_sort,Inds.miss));
                    %                     ti{3} = Inds.cr;
                    %                     ti{4} = Inds.fa;
                    %                     sort_str = 'Solo';
                    ti = 1:obj.nTrials;
                    sort_str = 'Solo';
                end
            else
                switch trialSorting
                    case 0
                        ti = obj.trialInds.no_sorting;
                        sort_str = 'no sorting';
                    case 1
                        ti = obj.trialInds.sort_by_solo;
                        sort_str = 'Solo';
                    case 2
                                                ti = obj.trialInds.sort_by_touch;
%                         ti = {[obj.trialInds.sort_by_touch{[1 2]}] [obj.trialInds.sort_by_touch{[3  4]}]};
                        sort_str = 'Touch+Solo';
                    case 3 
                        % Only separate touch and no touch trials, without
                        % sorting with bar positions
                        sort_str = 'Touch_only';
                        ti = {sort([obj.trialInds.sort_by_touch{[1 2]}]) sort([obj.trialInds.sort_by_touch{[3  4]}])};
                    case 4
                        % Separate touch and no touch trials, sorting with bar positions
                        sort_str = 'Touch+barPos';
                        temp_trInds_touch = [obj.trialInds.sort_by_touch{[1 2]}];
                        temp_trInds_nonTouch = [obj.trialInds.sort_by_touch{[3  4]}];
                        barPos_touch_trials = bar_pos_trial();
                        [~, Iaux] = sort(bar_pos_trial(temp_trInds_touch));
                        trTouch_barPos = temp_trInds_touch(Iaux);
                        
                        [~, Iaux] = sort(bar_pos_trial(temp_trInds_nonTouch));
                        trNoTouch_barPos = temp_trInds_nonTouch(Iaux);
                        ti = {trTouch_barPos,  trNoTouch_barPos};
                end
            end
            
            t_fr = obj.FrameTime; if t_fr > 1, t_fr = t_fr/1000; end;
            ts = (1:obj.nFramesPerTrial).*t_fr;
            trial_colors = [];
            if isempty(obj.SoloTrials) 
                bc = [];
%                 bt = [];
                eventTimes = [];
                at = [];
                rwd_t = [];
                lick_times_trial = [];
            elseif isempty(plot_behavEvents) || plot_behavEvents == 0
                at = [];
                rwd_t = [];
                bc = [];% get_barPos_colors(bar_pos_trial); % 
%                 bt = [obj.SoloTrials{1}.pinDescentOnsetTime  obj.SoloTrials{1}.pinAscentOnsetTime] + 0.4;
                bt = obj.barTime_trial;
                lick_times_trial = [];
            else
                bc = get_barPos_colors(bar_pos_trial);
%                 bt = [obj.SoloTrials{1}.pinDescentOnsetTime  obj.SoloTrials{1}.pinAscentOnsetTime] + 0.4;
                bt = obj.barTime_trial;
                eventTimes = obj.get_behavTimes;
                at = eventTimes.answerLick;
                rwd_t = eventTimes.RewardTime;
                lick_times_trial = [];
                if plot_behavEvents == 2
                    lick_data = obj.get_lick_data_trial;
                    c = struct2cell(lick_data);
                    lick_times_trial = squeeze(cat(1, c(2,1,:)));
                    rwd_t = [];
                end
            end
            
            
            if label_trial_color == 0
                trial_colors = {};
            else
                trial_touch_color = get_trial_color(obj.nTrials,...
                    obj.trialInds.touch_only, {[1 0.3 0.3], [0.6 0.6 0.6]});
                if ~isempty(bc)
                    trial_colors = {bc, trial_touch_color};
                else
                    trial_colors = {trial_touch_color};
                end
            end
            
            for i = 1:length(ROIs)
                dff = obj.get_f_array(ROIs(i),'dff');
                h_figs(i) = figure('Position',[3    40   380   650],'Color','w',...
                    'Name',sprintf('dF/F Array, ROI-%d,%s', ROIs(i),sort_str), 'NumberTitle','off','ToolBar','none');
                h_axes0 = gca; set(h_axes0, 'Position',[0 0 1 1]);
                text(0.2,0.96,sprintf('dF/F Array, ROI-%d,%s\n%s,%s', ROIs(i),sort_str,obj.ExpDate,obj.SessionName), 'FontSize',15,'Interpreter','none');
                
                ColorRaster_sessionDataArray(dff, ts, ti, trial_colors, bt, lick_times_trial, rwd_t, h_axes0, colorScale);
                
                %                 figs = obj.sort_and_plot_trials_roi(ROIs(i),trial_inds,'goPos',colorScale);
%                 fig_tr(i) = figs(1); % plot of trials
%                 fig_mean(i) = figs(3); % plot of means of go and nogo trials
%                 delete(figs(2));
            end
            function trial_color = get_trial_color(ntrials, inds_grouped, color_values)
                % number of element in inds_grouped and color_values must
                % be the same
                trial_color = cell(ntrials,1);
                for i = 1:length(inds_grouped)
                    trial_color(inds_grouped{i}) = {color_values{i}};
                end
            end
            
            function barPos_colors = get_barPos_colors(bar_pos_trial)
                cm = summer; %close;
                clr_map = cm;% (30:5:55,:);
                barPos_u = unique(bar_pos_trial);
                clr_lim = [min(barPos_u)  max(barPos_u)];
                clrs = color_mapping_nx(barPos_u, clr_lim, clr_map);
                
                barPos_colors = arrayfun(@(x) clrs(barPos_u==x,:), bar_pos_trial, 'UniformOutput',false);
            end
          
%             h_figs = [fig_tr fig_mean];
        end
        
        function [f_mean, f_se] = plot_trial_means(obj, roiNum, sort_opt, varargin)
            % obj.plot_trial_means( roiNum, opt)
            % opt: 'touch', 'behavior'
            if ~isempty(varargin)
                cmap = colormap(varargin{1});
            else
                cmap = colormap;
            end
            cmap = cmap(8:end-8,:);
            
            figure; hold on;
            [f, ts] = obj.get_f_array(roiNum,'dff');
            trialInds = obj.trialInds;
            switch sort_opt
                case 'touch'
                    inds{1} = [trialInds.sort_by_touch{[1 2]}];
                    inds{2} = [trialInds.sort_by_touch{[3 4]}];
                case 'solo'
            end
            
%             clrs = color_mapping_nx(1:length(inds), [], cmap);
            line_clrs = [1 0 0; .1 .1 .1];
            shade_clrs = [1 0.5 0.5 ; 0.7 0.7 0.7];
            for i = 1:length(inds)
                f_mean{i} = mean(f(inds{i},:),1);
                f_se{i} = std(f(inds{i},:),0,1)/sqrt(length(inds{i}));
                errorshade(ts, f_mean{i}, f_se{i}, line_clrs(i,:), 2, shade_clrs(i,:));
%                 errorshade(ts, f_mean{i}, f_se{i}, clrs(i,:));
            end
            
        end
            
        %% Color plot of dF/F traces of trials sorted by behavior. Mark behavioral time.
        function h_figs = sort_and_plot_trials_roi(obj, ROInum, trial_inds, sorting,colorScale)
            %             tr_hit = [obj.imTrials{trial_inds.hit}];
            %             tr_miss = [obj.imTrials{trial_inds.miss}];
            %             tr_cr = [obj.imTrials{trial_inds.cr}];
            %             tr_fa = [obj.imTrials{trial_inds.fa}];
            %             tr_go = [obj.imTrials{trial_inds.go}];
            %             tr_nogo = [obj.imTrials{trial_inds.nogo}];
            ind_hit = trial_inds.hit;
            ind_miss = trial_inds.miss;
            ind_cr = trial_inds.cr;
            ind_fa = trial_inds.fa;
            ind_go = trial_inds.go;
            ind_nogo = trial_inds.nogo;
            array_hit = [];
            array_miss = [];
            array_cr = [];
            array_fa = [];
            %% Label the pole position of go trial
            if ~isempty(obj.SoloTrials)
                polePosTrials = cellfun(@(x) x.goPosition*x.trialType + x.nogoPosition*(1-x.trialType), obj.SoloTrials);
                polePos_unq = unique(polePosTrials);
                % set colors for bar position label
                cmap_bar = jet; cmap_bar = cmap_bar(15:55,:);
                %                 cmap_bar = [ones(50,1) linspace(1,0,50)' linspace(1,0,50)'];
                nPos = length(polePos_unq);
                colors = cmap_bar((1:nPos) * floor(size(cmap_bar,1)/nPos),:);
                for i = 1:length(polePosTrials)
                    polePos_clr{i} = colors(find(polePosTrials(i) == polePos_unq),:);
                end
                
            end
            
            % Sort Ca hit trials by go positions (default)
            if ~exist('sorting','var') || strcmpi(sorting,'goPos')
                [~, isort1] = sort(polePosTrials(ind_hit));
                ind_hit_sort = ind_hit(isort1);
                [~, isort2] = sort(polePosTrials(ind_miss));
                ind_miss_sort = ind_miss(isort2);
            end
            
            % Sort by answer lick
            if exist('sorting','var') && strcmpi(sorting,'AnswerLick')
                AnswerLickTimes_hit = [];
                AnswerLickTimes_fa = [];
                for i = 1:length(tr_hit)
                    AnswerLickTimes_hit(i) = tr_hit(i).behavTrial.answerLickTime;
                end
                [answerT_sort_hit, inds_sort_hit] = sort(AnswerLickTimes_hit);
                tr_hit = tr_hit(inds_sort_hit);
                
                for i = 1:length(tr_fa)
                    AnswerLickTimes_fa(i) = tr_fa(i).behavTrial.answerLickTime;
                end
                [answerT_sort_fa, inds_sort_fa] = sort(AnswerLickTimes_fa);
                tr_fa = tr_fa(inds_sort_fa);
            end
            
            if ~isempty(obj.ROI_type)
                ROItype = obj.ROI_type{ROInum};
            else
                ROItype = '';
            end
            titleStr = ['ROI# ' num2str(ROInum) '(' ROItype ')' '-' obj.AnimalName '-' obj.ExpDate '-' obj.SessionName];
            %             color_sc = [-10 200];
            ts = (1:obj.nFramesPerTrial).*obj.FrameTime;
            if obj.FrameTime > 1
                ts = ts/1000;
            end
            
            % Start plotting
            if ~exist('fig1','var') || ~ishandle(fig1)
                scrsz = [1 1 1440 900]; % get(0, 'ScreenSize');
                fig1 = figure('Position', [20, 50, scrsz(3)/4+100, scrsz(4)-200], 'Color', 'w');
            else
                figure(fig1); clf;
            end;
            h_axes0 = axes('Position', [0 0 1 1], 'Visible', 'off');
            if ~isempty(ind_hit)
                [array_hit,ts] = obj.get_f_array(ROInum, ind_hit_sort);
                eventTimes = obj.get_behavTimes(ind_hit_sort);
                h_axes(1) = axes('Position', [0.1, 0.05, 0.8, length(ind_hit_sort)/obj.nTrials*0.85]);
                
                cplot_trials_with_behav_times(array_hit,ts,eventTimes.lick,eventTimes.poleOnset,...
                    eventTimes.answerLick, polePos_clr(ind_hit_sort),h_axes(1));
                
                % Sorting based on Answer lick time, NOT usable.
                if exist('sorting','var') && strcmpi(sorting,'AnswerLick')
                    [traces_hit_align, ts1] = align_traces(CaTraces_hit, ts, answerT_sort_hit);
                    hit_mean = mean(traces_hit_align,1);
                end
                set(h_axes(1),'Box','off', 'FontSize',13,'YTickLabel','');
                
            end
            if ~isempty(ind_miss)
                [array_miss,ts] = obj.get_f_array(ROInum, ind_miss_sort);
                eventTimes = obj.get_behavTimes(ind_miss_sort);
                h_axes(2) = axes('Position', [0.1, length(ind_hit)/obj.nTrials*0.85+0.06, 0.8,...
                    length(ind_miss)/obj.nTrials*0.85]);
                
                cplot_trials_with_behav_times(array_miss,ts,eventTimes.lick,eventTimes.poleOnset,...
                    eventTimes.answerLick, polePos_clr(ind_miss_sort),h_axes(2));
                set(h_axes(2),'XTickLabel','','Box','off', 'FontSize',13,'YTickLabel','');
            end
            if ~isempty(ind_cr)
                [array_cr,ts] = obj.get_f_array(ROInum, ind_cr);
                eventTimes = obj.get_behavTimes(ind_cr);
                h_axes(3) = axes('Position', [0.1, length([ind_hit ind_miss])/obj.nTrials*0.85+0.07, 0.8,...
                    length(ind_cr)/obj.nTrials*0.85]);
                
                cplot_trials_with_behav_times(array_cr,ts,eventTimes.lick,eventTimes.poleOnset,...
                    eventTimes.answerLick, polePos_clr(ind_cr),h_axes(3));
                set(h_axes(3),'XTickLabel','','Box','off', 'FontSize',13,'YTickLabel','');
            end
            
            if ~isempty(ind_fa)
                [array_fa,ts] = obj.get_f_array(ROInum, ind_fa);
                eventTimes = obj.get_behavTimes(ind_fa);
                h_axes(4) = axes('Position', [0.1, length([ind_hit ind_miss ind_cr])/obj.nTrials*0.85+0.08,...
                    0.8, length(ind_fa)/obj.nTrials*0.85]);
                
                cplot_trials_with_behav_times(array_fa,ts,eventTimes.lick,eventTimes.poleOnset,...
                    eventTimes.answerLick, polePos_clr(ind_fa),h_axes(4));
                set(h_axes(4),'XTickLabel','','Box','off', 'FontSize',13,'YTickLabel','');
                
                if exist('sorting','var') && strcmpi(sorting,'AnswerLick')
                    [traces_fa_align, ts2] = align_traces(CaTraces_fa, ts, answerT_sort_fa);
                    fa_mean = mean(traces_fa_align,1);
                end
            end
            title(titleStr, 'FontSize', 18);
            if ~exist('colorScale','var') || isempty(colorScale)
                allTraces = obj.get_f_array(ROInum);
                clim(1) = round((prctile(allTraces(:),0.5))/10)*10; % round((min(allTraces))/10)*10;
                clim(2) = round((prctile(allTraces(:),99.5))/10)*10; % max(allTraces); %
            else
                clim = colorScale;
            end
            clrsc_str = ['Color Scale: [' num2str(clim(1)) ', ' num2str(clim(2)) ']'];
            axes(h_axes0); text(0.3,0.01,clrsc_str ,'FontSize',14,'Color', 'b');
            disp(clrsc_str);
            for i=1:length(h_axes)
                if h_axes(i) ~=0
                    set(h_axes(i), 'CLim', clim);
                end
            end
            
            h_figs(1) = fig1;
            
            % plot trial mean
            
            fpos = get(fig1,'Position');
            fig2 = figure('Position', [fpos(1)+100 fpos(2) fpos(3) fpos(3)/2]);
            hold on;
            if exist('sorting','var') && strcmpi(sorting,'AnswerLick')
                plot(ts1, hit_mean,'r', 'LineWidth', 1.5);
                plot(ts2, fa_mean,'k', 'LineWidth', 1.5);
                legend('Hit', 'F-A');
                set(gca,'FontSize',13,'Position',[0.14 0.24 0.805 0.68]);
                x1 = min(ts1(1),ts2(1)); x2 = max(ts1(end),ts2(end));
                xlim([x1 x2]);
                % yl = get(gca,'YLim'); ylim([-5 yl(2)]);
                set(gca,'XTick',(floor(x1):round(x2)));
                set(get(gca,'XLabel'), 'String', 'Time (sec)', 'FontSize', 18);
                set(get(gca,'YLabel'), 'String', 'mean dF/F (%)', 'FontSize',18);
            else
                go_mean = mean([array_hit;array_miss],1);
                go_se = std([array_hit;array_miss],0,1)./sqrt(length(ind_go));
                nogo_mean = mean([array_cr;array_fa],1);
                nogo_se = std([array_cr;array_fa],0,1)./sqrt(length(ind_nogo));
                
                fig3 = figure('Position', [fpos(1)+200 fpos(2) fpos(3) fpos(3)/2]);
                hold on;
                hit_mean = mean(array_hit,1);
                hit_se = std(array_hit,0,1)./sqrt(length(ind_hit));
                cr_mean = mean(array_cr,1);
                cr_se = std(array_cr,0,1)./sqrt(length(ind_cr));
                errorshade(ts, cr_mean,cr_se,[1 0 0],3, [1 .4 .3]);
                errorshade(ts, hit_mean,hit_se, [0 0 1], 3, [0.3 0.4 0.9]);
                %                 legend('Go-trials', 'NoGo-trials');
                set(gca,'FontSize',13,'Position',[0.14 0.24 0.805 0.68]);
                xlim([ts(1) ts(end)]);
                % yl = get(gca,'YLim'); ylim([-5 yl(2)]);
                set(gca,'XTick',(floor(ts(1)):round(ts(end))));
                set(get(gca,'XLabel'), 'String', 'Time (sec)', 'FontSize', 18);
                set(get(gca,'YLabel'), 'String', 'mean dF/F (%)', 'FontSize',18);
                
                array_detected = [array_hit; array_fa];
                m_detected = mean(array_detected,1);
                se_detected = std(array_detected,0,1)/sqrt(size(array_detected,1));
                array_undetect = [array_miss; array_cr];
                m_undetect = mean(array_undetect,1);
                se_undetect = std(array_undetect,0,1)/sqrt(size(array_undetect,1));
                
                
                fig4 = figure('Position', [fpos(1)+300 fpos(2) fpos(3) fpos(3)/2]);
                hold on;
                %                 plot(ts, m_detected, 'r', 'LineWidth', 2);
                %                 plot(ts, m_undetect, 'k', 'LineWidth', 2);
                errorshade(ts, m_undetect,se_undetect,[0 0 0],3, [.5 .5 .5]);
                errorshade(ts, m_detected,se_detected, [1 0 0], 3, [1 0.4 0.3]);
                legend('detected', 'undetect');
                set(gca,'FontSize',13,'Position',[0.14 0.24 0.805 0.68]);
                xlim([ts(1) ts(end)]);
                % yl = get(gca,'YLim'); ylim([-5 yl(2)]);
                set(gca,'XTick',(floor(ts(1)):round(ts(end))));
                set(get(gca,'XLabel'), 'String', 'Time (sec)', 'FontSize', 18);
                set(get(gca,'YLabel'), 'String', 'mean dF/F (%)', 'FontSize',18);
                
            end
            h_figs(2) = fig2;
            h_figs(3) = fig3;
            h_figs(4) = fig4;
            
            
            function [traces_aligned, ts_align] = align_traces(traces, ts, eventTimes)
                
                frameTime = ts(2)-ts(1);
                eventFrame = ceil(eventTimes./frameTime);
                window(1) = min(eventFrame); % ts(find(ts<min(eventTimes),1,'last'));
                window(2) = length(ts) - max(eventFrame);
                traces_aligned = [];
                for i = 1:size(traces,1)
                    inds{i} = eventFrame(i)-window(1)+1 : eventFrame(i)+window(2);
                    traces_aligned(i,:) = traces(i,inds{i});
                    ts_align = ts(inds{i})-eventTimes(i);
                end
            end
            
            
        end
        %%
        function make_2pImg_whisker_movie(obj,trialNo, wsk_mov_dir,window,save_fmt, saveFileName,FPS)
            %
            %  - NX 2009-10
            %
            imgFile2p = obj.imTrials(trialNo).FileName;
            % t_off = 5;
            frameTime = obj.FrameTime;
            if frameTime > 1
                frameTime = frameTime/1000;
            end
            
            if ~exist('saveFileName','var')
                saveFileName = obj.FileName_prefix;
            end
            
            wsk_mov_files = dir(fullfile(wsk_mov_dir,'*.seq'));
            wsk_mov_fileName = fullfile(wsk_mov_dir, wsk_mov_files(obj(trialNo).TrialNo).name);
            
            h_fig = figure('Position', [138   431   327   535]);
            ha(1) = axes('Position', [0.01 0.39 0.98 0.6]); % 320x320
            ha(2) = axes('Position', [0.01 0.01 0.98 0.38]); % 320*200
            
            im2p = imread_multi(imgFile2p,'g');
            ts2p = (1:size(im2p,3)).*frameTime;
            fr2p = find(ts2p > window(1) & ts2p <= window(2));
            count = 0;
            for i = fr2p
                axes(ha(1)); colormap(gray);
                imagesc(im2p(:,:,i),[0 400]); set(gca,'visible', 'off');
                text(3,5,['Fr# ' num2str(i)],'Color','g');
                text(400,125,[num2str(i*frameTime) ' sec'],'Color','g');
                
                t1 = (i-1)*frameTime;
                t2 = i*frameTime;
                frWsk = [round(t1/0.002) ceil(t2/0.002)];
                if frWsk(1) == 0
                    frWsk(1) = 1;
                end
                [wskImg tsWsk] = get_seq_frames(wsk_mov_fileName, frWsk, 5);
                for j = 1:size(wskImg,3)
                    axes(ha(2)); set(gca,'visible','off');
                    imshow(wskImg(:,:,j),[]);
                    text(400,30,[num2str(tsWsk(j)/1000) ' sec'],'Color','w')
                    count = count + 1;
                    F(count) = getframe(h_fig);
                    if strcmpi(save_fmt,'tif')
                        im = frame2im(F(count));
                        imwrite(im,[saveFileName '.tif'],'tif','compression','none',...
                            'writemode','append');
                    end
                end
            end
            
            if ~exist('FPS','var')
                FPS = 15;
            end
            if strcmpi(save_fmt, 'avi')
                movie2avi(F,[saveFileName '.avi'],'compression','none','fps',FPS);
            end
        end
        
        function w = get_whisker_trials(obj, WhiskerSignalTrials, whisker_ID, varargin)
            % Extract whisker data from WhiskerSignalTrials
            % INPUT: WhiskerSignalTrials, cell array containing
            %        WhiskerSignalTrial objects. If input as a filename, or
            %        [], promote user to load the data file.
            %        varargin{1}, 1 x n integer. Numbers of whisker trials
            %                   to be ecluded, usually when some imaging trials were missing.
            %        whisker_ID, trajectory ID starting from 0.
            % OUTPUT: struct with fields containing relevant whisker signal
            %        variables, i.e., timestamps, curvature (kappa), position (theta), touch times.
            %             w = struct('ts',0,'kappa',[],'theta',[],'touch_windows',{});
            if ischar(WhiskerSignalTrials) || isempty(WhiskerSignalTrials)
                if exist(WhiskerSignalTrials,'file')
                    fn = WhiskerSignalTrials;
                else
                    fn = uigetfile([pwd filesep '*.mat'],'Select Whisker Signal Array data file');
                end
                x = load(fn);
                nm = fieldnames(x);
                WhiskerSignalTrials = x.(nm{1});
            end
            if ~isempty(varargin)
                trials_to_exclude = varargin{1};
            else
                trials_to_exclude = [];
            end
            
            wids = WhiskerSignalTrials{1}.trajectoryIDs;
            for k = 1:length(whisker_ID)
                w_ind = find(whisker_ID(k)==wids);
                trCount = 0;
                for i = 1:length(WhiskerSignalTrials)
                    if ismember(i,trials_to_exclude)
                        continue;
                    end
                    wObj = WhiskerSignalTrials{i};
                    trCount = trCount + 1;
                    stim_time = [obj.SoloTrials{trCount}.pinDescentOnsetTime+.4 obj.SoloTrials{trCount}.pinAscentOnsetTime+.4];
                    w.trialNo(trCount) = wObj.trialNum;
                    %                 if isempty(wObj.mKappaNearBar)|| isempty(wObj.mKappaNearBar{w_ind})
                    %                     [mTheta, mKappa, rROI] = wObj.mean_theta_kappa_near_bar(whisker_ID(k));
                    %                 else
                    %                     mKappa = wObj.mKappaNearBar{w_ind};
                    %                     mTheta = wObj.mThetaNearBar{w_ind};
                    %                 end
                    w.ts{trCount} = wObj.time{w_ind};
                    w.kappa{trCount} = medfilt1(wObj.kappa{w_ind},3);
                    w.theta{trCount} = wObj.theta{w_ind};
                    w.deltaKappa{trCount} = medfilt1(wObj.deltaKappa{w_ind},3);
                    %                 w.mCurvNearBar{trCount} = medfilt1(mKappa,3);
                    %                 w.mThetaNearBar{trCount} = mTheta;
                    w.CurvatureDot{trCount} = [0 diff(w.deltaKappa{trCount})] ./ [0 diff(w.ts{trCount})];
                    if isempty(wObj.contacts)
                        w.contacts = wObj.get_contacts(whisker_ID(k),stim_time);
                        w.contact_events{trCount} = wObj.contact_params{w_ind};
                    else
                        w.contact_events{trCount} = wObj.contact_params{w_ind};
                    end
                    
                end
                obj.WhiskerTrials{w_ind} = w;
            end
        end
        
        %%
        function out = get_signal_param(obj, varargin)
            %
            % Extract signal parameters for specified ROIs, from specified
            % trials of the session.
            %
            % varargin{},     1, ROInums
            %                 2, ROIType, 'spine', 'branch', 'trunk',  'all'.    Default, 'all'
            %                 3, trialType, 'hit', 'miss', 'cr', 'fa'.         Defualt, 'hit'
            %                 4, trialPhase, 'stim', 'reward', 'trial'.     Default, 'stim'
            %
            out = struct('ROInums', [], 'trialInds', [], 'ROItype', {'all'}, 'trialPhase','stim', 'trialType','hit',...
                'peak_dff',[], 'eventPeak',[], 'eventArea', [], 'tauDecay', [], 'fwhm', [], 'eventProb', []);
            
            if ~isempty(varargin)
                out.ROInums = varargin{1};
            end
            if length(varargin)>1 && isempty(varargin{1})
                out.ROIType = varargin{2};
            elseif isequal(length(obj.ROI_type), obj.nROIs)
                out.ROItype = obj.ROI_type(varargin{1});
            else
                out.ROItype = 'all';
            end
            if length(varargin)>2
                out.trialType = varargin{3};
            end
            if length(varargin)>3
                out.trialPhase = varargin{4};
            end
            
            ind_struct = obj.trialInds_sorted_by_behav;
            if strcmpi(out.trialType,'all')
                tr_ind = 1:obj.nTrials;
            else
                tr_ind = ind_struct.(out.trialType);
            end
            out.trialInds = tr_ind;
            
            ROI_events_param = obj.get_ROI_events_param;
            k = find(strcmpi(out.trialPhase, {'pre_stim', 'stim', 'reward', 'trial'}));
            event_struct = ROI_events_param(k);
            
            dt = obj.FrameTime/1000;
            ts = (1:obj.nFramesPerTrial).*dt;
            for i = 1:length(tr_ind)
                for j = 1:length(out.ROInums)
                    dff = obj.imTrials(tr_ind(i)).dff(out.ROInums(j),:);
                    t1 = obj.imTrials(tr_ind(i)).behavTrial.pinDescentOnsetTime;
                    t2 = obj.imTrials(tr_ind(i)).behavTrial.pinAscentOnsetTime + 0.4;
                    %                     ind_stim = find(ts>t1& ts<t2);
                    %                     ind_rwd = find(ts>t2);
                    out.peak_dff(i,j) = max(dff(ts>t1& ts<t2));
                    switch out.trialPhase
                        case 'trial'
                            out.peak_dff(i,j) = max(dff);
                        case 'stim'
                            out.peak_dff(i,j) = max(dff(ts>t1& ts<t2));
                        case 'reward'
                            out.peak_dff(i,j) = max(dff(ts>t2));
                    end
                end
            end
            out.eventPeak = event_struct.peaks(tr_ind, out.ROInums);
            out.eventArea = event_struct.areas(tr_ind, out.ROInums);
            out.tauDecay = event_struct.tauDecay(tr_ind, out.ROInums);
            out.fwhm = event_struct.fwhm(tr_ind, out.ROInums);
            out.eventProb = mean(event_struct.numEvent(tr_ind, out.ROInums));
        end
        
        function correct_lick_artifact(obj)
            
            
        end
        
        function [f_array,ts] = get_f_array(obj, roi_no, trialNums, opt)
            % Retrieve fluo time series array of particular ROIs, in the
            % form of either deltaF/F or raw fluorescence.
            if nargin < 2 || isempty(roi_no)
                roi_no = 1: obj.nROIs;
                trialNums = obj.trialNums;
            end
            if nargin < 3 || isempty(trialNums)
                trialNums = obj.trialNums;
            end
            if nargin < 4 || isempty(opt)
                opt = 'dff';
            end
            if ischar(trialNums)
                trialNums = obj.trialNums;
            end
            nROIs = length(roi_no);
            f_array = zeros(length(trialNums), obj.nFramesPerTrial, nROIs);
            switch opt
                case 'raw'
                    for  i = 1:nROIs
                        for j = 1:length(trialNums)
                            f_array(j, :, i)= obj.imTrials{trialNums(j)}.f_raw(roi_no(i),:);
                        end
                    end
                case 'dff'
                    for  i = 1:nROIs
                        for j = 1:length(trialNums)
                            f_array(j, :, i)= obj.imTrials{trialNums(j)}.dff(roi_no(i),:);
                        end
                    end
                case 'dff2' % Re-calculate delta F/F, based on global mode
                    for  i = 1:nROIs
                        for j = 1:length(trialNums)
                            f_raw(j,:) = obj.imTrials{trialNums(j)}.f_raw(roi_no(i),:);
                        end
                        [N,X] = hist(f_raw(:),50);
                        f_mode = min(X(N==max(N)));
                        f_base = prctile(f_raw(f_raw < f_mode),50);
                        f_array(:,:,i) = (f_raw - f_base)./f_base*100;
                    end
            end
            ts = (1:obj.nFramesPerTrial).* obj.FrameTime/1000;
        end
        
        function out = get_dff_amplitude(obj, roi_no, trialNums, time_window)
            % out is n x 1 array, with n being length(trialNums)
            % take the mean from 5 frames around the max df/f as the
            % response amplitude.
            if nargin < 3
                trialNums = obj.trialNums;
                time_window = NaN;
            end
            if nargin < 4
                time_window = NaN;
            end
            if isempty(trialNums)
                trialNums = obj.trialNums;
            end
            [f_all,ts] = obj.get_f_array;
            f_array = f_all(trialNums,:,roi_no);
%             [f_array,ts] = obj.get_f_array(roi_no, trialNums,'dff');
            if isnan(time_window)
                array = f_array;
                inds1 = 1:length(ts);
            else
                inds1 = find(ts > time_window(1) & ts < time_window(2));
                array = f_array(:,inds1);
            end
            [~,I] = max(array,[],2);
            inds = arrayfun(@(x) x-2:x+2, I, 'UniformOutput',false);
            for i=1:length(inds),
                inds{i}(inds{i}<1)=1; inds{i}(inds{i}>length(inds1)) = length(inds1);
                out(i) = mean(array(i,inds{i}));
            end
        end
        
        
        %%
        function out = get_mean_dff_stim_epoch(obj, roiNo, trialInds, varargin)
            if nargin<4 || isempty(varargin{1})
                opt = 'mean';
            else
                opt = varargin{1};
            end
            if length(varargin) <2 || isempty(varargin{2})
                bp(1) = obj.SoloTrials{1}.pinDescentOnsetTime + 0.2;
                bp(2) = obj.SoloTrials{1}.pinAscentOnsetTime + 0.5;
            else
                bp = varargin{2};
            end
                
            if isempty(trialInds)
                trialInds = 1:obj.nTrials;
            end
                
            [f_all,ts] = obj.get_f_array;
            f = f_all(trialInds,:,roiNo);
            out = [];
            for i = 1:length(trialInds)
                
                unitTime = obj.FrameTime; if unitTime>1, unitTime=unitTime/1000; end;
                frInd = find(ts>bp(1) & ts<bp(2));
                for j = 1:length(roiNo)
                    switch opt
                        case 'mean'
%                             f(f<0) = 0;
                            out(i,j) = mean(f(i, frInd, j),2);
                        case 'peak'
                            out(i,j) = max(f(i, frInd, j), [], 2);
                    end
                end
            end
        end
        
        function polePos = get_polePos(obj)
            polePos = zeros(obj.nTrials,1);
            if isempty(obj.SoloTrials)
                error('SoloTrials is empty!');
            end
            goPos = cellfun(@(x) x.goPosition, obj.SoloTrials);
            nogoPos = cellfun(@(x) x.nogoPosition, obj.SoloTrials);
            ttype = cellfun(@(x) x.trialType, obj.SoloTrials);
            polePos(ttype) = goPos(ttype);
            polePos(ttype==0) = nogoPos(ttype==0);
        end
        
        function [eventTimes] = get_behavTimes(obj,tr_ind)
            
            if nargin < 2
                tr_ind = 1:obj.nTrials;
            end
            
            if isempty(obj.SoloTrials)
                error('No behavioral info ...');
            end
            %     eventTimes.lick{i} = [obj(i).behavTrial.LickTimesPreAnswer obj(i).behavTrial.LickTimesPostAnswer];
            eventTimes.lick = cellfun(@(x) {x.beamBreakTimes}, obj.SoloTrials(tr_ind));
            eventTimes.poleOnset = cellfun(@(x) x.pinDescentOnsetTime, obj.SoloTrials(tr_ind));
            eventTimes.poleOffset = cellfun(@(x) x.pinAscentOnsetTime, obj.SoloTrials(tr_ind));
            eventTimes.answerLick = cellfun(@(x) {x.answerLickTime}, obj.SoloTrials(tr_ind));
            eventTimes.RewardTime = nan(1,length(tr_ind));
            solo_trials = obj.SoloTrials(tr_ind);
            for i = 1:length(solo_trials)
                if solo_trials{i}.trialType == 1 && solo_trials{i}.trialCorrect == 1
                    eventTimes.RewardTime(i) = solo_trials{i}.answerLickTime;
                end
            end
        end
        
        function bta = make_behavTrialArray(obj,indsTrial)
            if nargin < 2
                indsTrial = 1:obj.nTrials;
            end
            bta = Solo.BehavTrialArray_NX; % create an empty object.
            bta.mouseName = obj.AnimalName;
            bta.sessionName = sprintf('%s_%s',obj.ExpDate, obj.SessionName);
            bta.trials = obj.SoloTrials(indsTrial);
%             bta.trials(obj.excluded_fileNo) = [];
        end
        
        function trace_array_viewer(obj,varargin)
            if isempty(varargin)
                trNums = [];
            else
                trNums = varargin{1};
            end
            imTrialViewer(obj,trNums);
        end
        
        function imMD_trial = get_maxDelta_image(obj, trialNums)
            %
            % trialNums, if none or 'all', taking all trials
            
            if nargin < 2 || ischar(trialNums)
                trialNums = 1:obj.nTrials;
            end
            if ~exist(obj.imTrials{1}.FileName, 'file')
                [fileName, pathName, fileIndex] = uigetfile('*.tif', 'Get Imaging Data Files');
                if isdir(fullfile(pathName, fileName))
                    cd (fullfile(pathName, fileName));
                else
                    cd (pathName);
                end
            end
            files = dir('*.tif');
            
            imMD_trial = zeros([obj.imageDim(1) obj.imageDim(2) length(trialNums)]);
            for i = 1:length(trialNums)
                fn = files(trialNums(i)).name;
                im_orig = imread_multi(fn,'g');
                %                 imMD =
                imMD_trial(:,:,i) = get_imMaxDelta(im_orig); %imMD(:,:);
            end
            hf = figure;
            hold on;
            imagesc(max(imMD_trial, [], 3)); colormap('gray');
            
            obj.plot_rois(hf);
            axis image square;
            set(gca,'Ydir','reverse')
            
            function imMaxDelta = get_imMaxDelta(im)
                mean_im = mean(im,3);
                im_sm = im_mov_avg(im,5);
                max_im = double(max(im_sm,[],3));
                imMaxDelta = max_im - mean_im;
            end
        end
        
        function h_roi = plot_rois(obj, ha, roiNums)
            if ~exist('roiNums','var') || isempty(roiNums)
                roiNums = 1: obj.nROIs;
            end
            if isempty(ha) || ~ishandle(ha)
                ha = axes;
            end
            axes(ha);
            for i = 1:length(roiNums)
                pos = obj.roiPos{roiNums(i)};
                h_roi(i) = line(pos(:,1),pos(:,2), 'Color', 'g', 'LineWidth', 0.5,'linestyle','--');
                text(median(pos(:,1)), median(pos(:,2)), num2str(roiNums(i)),'Color','g','FontSize',20);
            end
        end
        
        function SoloTrials = add_SoloTrials(obj,SoloSessionID, SoloTrialStartEnd, trExclude, SoloDataPath)
            % SoloSessionID: 'a', 'b', etc.
            % trExclude, trials to be excluded. should use image trial index, NOT solo trial number
            % imArray.add_SoloTrials('a',[2 241],[], '/Users/xun/Documents/Data/Exp_Data/Whisker_Behavior_Data/SoloData/Data_2PRig');
            mouseName = obj.AnimalName;
            SoloSessionName = [obj.ExpDate SoloSessionID];
            solodata = Solo.load_data_nx(mouseName, SoloSessionName, SoloTrialStartEnd,SoloDataPath);
            SoloTrialNums = (SoloTrialStartEnd(1) : SoloTrialStartEnd(2));
            SoloTrialNums(trExclude) = [];
            
            if length(SoloTrialNums) ~= obj.nTrials
                warning('Number of behavior trials NOT equal to Number of Ca Image Trials!')
            end
            for i = 1:length(SoloTrialNums)
                SoloTrials(i) = Solo.BehavTrial_nx(solodata,SoloTrialNums(i),1);
                obj.SoloTrials{i} = SoloTrials(i);
            end
            fprintf('%d Behavior Trials added to imTrialArray !\n', length(SoloTrialNums));
            
        end
        %% Get Lick data for each trial
        function lick_data_trial = get_lick_data_trial(obj)
            % Get Licking data for each trial
            lick_data_trial = struct('lick_times_all', [], ...
                'lick_times_after_pole', [],...
                'lick_rate', [], 'num_of_lick',[], ...
                'lick_time_first', [], 'lick_time_last', []);
            
            if ~isempty(obj.SoloTrials)
                for i = 1:obj.nTrials,
                    I = find(obj.SoloTrials{i}.beamBreakTimes > obj.SoloTrials{i}.pinDescentOnsetTime + 0.3);
                    
                    lick_data_trial(i).lick_times_all = obj.SoloTrials{i}.beamBreakTimes;
                    lick_data_trial(i).lick_times_after_pole = obj.SoloTrials{i}.beamBreakTimes(I);
                    
                    if length(I) > 1
                        lick_data_trial(i).lick_time_first = lick_data_trial(i).lick_times_after_pole(1);
                        lick_data_trial(i).lick_time_last = lick_data_trial(i).lick_times_after_pole(end);
                        lick_data_trial(i).lick_rate = length(I) / (lick_data_trial(i).lick_time_last - lick_data_trial(i).lick_time_first);
                        
                    else
                        lick_data_trial(i).lick_rate = NaN;
                        lick_data_trial(i).lick_time_first = NaN;
                        lick_data_trial(i).lick_time_last = NaN;
                    end
                    
                    lick_data_trial(i).num_of_lick = length(I);
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [dff_aligned ts_new] = align_traces_to_eventTimes(obj, event_times, roiNo)
            % Align imaging traces to behavioral event times, e.g., first whisker touch time.
            %
            % event_times, nTrials length vector. Each element is a time point in a given trial.
            % 
            
            [dff imts] = obj.get_f_array(roiNo);
            
            imFrameTime = obj.FrameTime;
            
            % for roino = 1:im(1).nROIs
            % t_touch = ws(1).get_first_touch_time_trial;
            % t_touch_mean = nanmean(t_touch);
            
            event_times;
            mean_event_times = nanmean(event_times);
            
            
            I = find(~isnan(event_times));
            
            % get the shift time
            tshift = event_times - mean_event_times;
            
            fr_shift = round(tshift./imFrameTime*1000);
            % dff = dffarray{1}(:,:,roino);
            
            dff_aligned = nan(length(I), size(dff,2));
            for i = 1:length(I)
                new_inds = (1 : size(dff,2)) + fr_shift(I(i));
                new_inds(new_inds > size(dff,2) | new_inds < 1) = [];
                %     plot(dff(I(i),new_inds), 'color', [.9 .6 .6]);
                if fr_shift(I(i)) > 0
                    dff_aligned(i, 1: end-fr_shift(I(i))) = dff(I(i),new_inds);
                elseif fr_shift(I(i)) < 0
                    dff_aligned(i, 1-fr_shift(I(i)) : end) = dff(I(i), new_inds);
                end
                %     keyboard
                
            end
            
            ts_new = imts - mean_event_times;
%             mean_aligned = nanmean(dff_aligned);
%             se_aligned = nanstd(dff_aligned,0,1)./sqrt(length(I));
        end
 %%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = update_dff(obj, roi_no, opt, varargin)
            % Recalculate delta F/F, and put them back to imTrialsObj
            % varargin, the value of percentile to be treated as baseline.
            if nargin < 2 || isempty(roi_no)
                roi_no = 1: obj(1).nROIs;
            end
            if nargin < 3
                opt = 'mode';
            end
            
            nROIs = obj.nROIs;
            nTrials = obj.nTrials;
            dff_array = zeros(length(obj), obj.nFramesPerTrial, nROIs);
            for  i = 1:nROIs
                traces = obj.get_f_array(i, 1:nTrials,'raw');
                        
                switch opt
                    case 'mode' % recalculate dF/F using mode as Fo
                        %             for j = 1:length(caobj)
                        %                 traces(j, :)= caobj(j).CaTrace_raw(ROInums(i),:);
                        %             end
                        %             [N,X] = hist(traces(:),50);
                        %             F0 = mean(X(N==max(N)));
                        %             CaTraces(:,:, i) = (traces-F0)./F0*100;
                        v = var(traces,0,2);
                        % normalize to a mean trace to correct artifacts
                        trace_mean = mean(traces(v<prctile(v,30),:),1);
                        for j = 1:length(obj)
                            y = traces(j,:)./trace_mean;
                            [N,X] = hist(y,30);
                            F0 = mean(X(N==max(N)));
                            dff_array(j,:, i) = (y - F0)./F0*100;
                            obj.imTrials{j}.dff(i,:) = dff_array(j,:, i);
                        end
                    case 'mode2' % Re-calculate delta F/F, based on global mode, used for high and slow activity
                        for  i = 1:nROIs
                            f_raw = traces;
                            [N,X] = hist(f_raw(:),50);
                            f_mode = min(X(N==max(N)));
                            F0 = prctile(f_raw(f_raw < f_mode),50);
                            dff_array(:,:,i) = (f_raw - F0)./F0*100;
                            for j = 1:length(obj)
                                obj.imTrials{j}.dff(i,:) = dff_array(j,:, i);
                            end
                        end
                        
                        %         case 'perct' % recalculate dF/F using percentile 30 over all trials as Fo
                    case 'perct' % recalculate dF/F using percentile 30 within the current trial as Fo
                        if ~isempty(varargin)
                            thresh_prct = varargin{1};
                        else
                            thresh_prct = 10;
                        end
                        v = var(traces,0,2);
%                         trace_mean = mean(traces(v<prctile(v,30),:),1);
                        for j = 1:obj.nTrials
%                             y = traces(j,:)./trace_mean;
                            y = traces(j,:);
                            F0 = prctile(traces(:), 5);
                            dff_array(j,:, i) = (y - F0)./F0*100;
                            obj.imTrials{j}.dff(i,:) = dff_array(j,:, i);
                        end
                       
                end
            end
            
        end
        
        
    end
    %===========================================================================================================
    
    methods % Dependent property methods; cannot have attributes
        
        function roi_events = get.roi_events_param(obj)
            % Reorganize events data for ROIs
            % - NX 2011
            roi_events = cell(1,obj.nROIs);
            for i = 1:obj.nROIs
                events = [];
                for tr = 1:obj.nTrials
                    events = [events obj.imTrials{tr}.CaTransients{i}];
                    
                end
                roi_events{i} = events;
            end
            %             obj.roi_events_param = roi_events;
        end
        
        function barTime_trial = get.barTime_trial(obj)
            if ~isempty(obj.SoloTrials)
                barTime_trial = [cellfun(@(x) x.pinDescentOnsetTime, obj.SoloTrials)' cellfun(@(x) x.pinAscentOnsetTime, obj.SoloTrials)']+0.2;
            else
                barTime_trial = [];
            end
        end
        
        function value = get.trialNums(obj)
            value = 1:length(obj.imTrials);
        end
        
        function imageDim = get.imageDim(obj)
            w = obj.imTrials{1}.DaqInfo.width;
            h = obj.imTrials{1}.DaqInfo.height;
            imageDim = [h w];
        end
        
        function roiPos = get.roiPos(obj)
            roiPos = obj.imTrials{1}.ROIPos;
        end
        
        function roiMask = get.roiMask(obj)
            roiMask = obj.imTrials{1}.ROIMask;
        end
        
        function nTrials = get.nTrials(obj)
            nTrials = length(obj.imTrials);
        end
        
        function SoloTrialNums = get.SoloTrialNums(obj)
            SoloTrialNums = cellfun(@(x) x.trialNum, obj.SoloTrials);
        end
        
    end
    
end
