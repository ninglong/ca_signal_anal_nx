% Class for calcium imaging trial containing Ca signal traces from multiple
% ROIs
% NX Feb 2009
%
classdef imTrials_nx < handle
    
    properties
        AnimalName = '';
        ExpDate = '';
        SessionName = '';
        
        FileName = '';
        FileName_prefix = '';
        TrialNo = [];
        nFrames = [];
        FrameTime = [];  % in ms
%         nROIs = [];
        ROIMask = {};
        ROIPos = {};
        ROIType = {};
        %         meanImage = [];
        DaqInfo = struct([]); % header info of the image file
        nChannel = 1;
        nTrials = [];
        
        %         EphusData = [];
        %         WhiskerTrial = [];
        dff_orig = [] % nFrames-by-nROIs of delta_F/F directly from gui program
        dff = []; % delta_F/F reprocessed using subtraction or normalization
        f_raw = []; % raw fluo intensity
        CaTransients = {};
        behavTrial = [];
        whiskerTrialNum = [];
    end
    
        properties (Dependent = true, SetAccess = private)
            nROIs %  = imTrials(trialNo).nROIs;
        end
    %
    methods (Access = public)
        function obj = imTrials_nx(imTrials,trialInds)
            if nargin~=0
                if nargin<2
                    n = length(imTrials);
                    trialInds = 1:n;
                else
                    n = numel(trialInds);
                end
                obj(1,n) = imTrials_nx;
                for i = 1:n
                    trialNo = trialInds(i); %i; % ;
                    obj(i).whiskerTrialNum = imTrials(trialNo).TrialNo; % 2P img file No. May not agree with effective trial No.
                    obj(i).FileName = imTrials(trialNo).FileName;
                    obj(i).FileName_prefix = imTrials(trialNo).FileName_prefix;
                    obj(i).TrialNo = i; % effective 2P-Imaging trial No. imTrials(trialNo).TrialNo;
                    obj(i).nFrames = imTrials(trialNo).nFrames;
                    obj(i).FrameTime = imTrials(trialNo).FrameTime;  % in ms
%                     obj(i).nROIs = imTrials(trialNo).nROIs;
                    obj(i).ROIMask = imTrials(trialNo).ROIinfo.ROImask; %ROIMask;
                    obj(i).ROIPos = imTrials(trialNo).ROIinfo.ROIpos;
                    if isfield(imTrials(trialNo).ROIinfo, 'ROItype')
                        obj(i).ROIType = imTrials(trialNo).ROIinfo.ROItype(1:imTrials(trialNo).nROIs);
                    end
                    obj(i).DaqInfo = imTrials(trialNo).DaqInfo; % header info of the image file
                    obj(i).nChannel = 1;
                    obj(i).nTrials = n;
                    %                     obj(i).EphusData = [];
                    
                    if isfield(imTrials(trialNo), 'behaveTrial')
                        obj(i).behavTrial = imTrials(trialNo).behavTrial;
                    end
                    if isfield(imTrials(trialNo),'WhiskerTrial')
                        obj(i).WhiskerTrial = imTrials(trialNo).behavTrial;
                    end
                    obj(i).SessionName = imTrials(trialNo).SessionName;
                    obj(i).AnimalName = imTrials(trialNo).AnimalName;
                    obj(i).ExpDate = imTrials(trialNo).ExpDate;
                    
                    obj(i).dff = imTrials(trialNo).dff;
                    obj(i).dff_orig = imTrials(trialNo).dff; % uncorrected deltaF/F
                    
                    obj(i).f_raw = imTrials(trialNo).f_raw; % raw intensity
                    %                     obj(i).meanImage = imTrials(trialNo).meanImage;
                    if isfield(imTrials,'behavTrial')
                        obj(i).behavTrial = imTrials(trialNo).behavTrial;
                    end
                end
                obj = update_dff(obj,(1:obj(1).nROIs), 'mode2');
                disp('Re-comput dff using global mode, "mode2"!')
%                 obj = obj.get_Transients;
            end
        end
        
        function obj = update_dff(obj, roi_no, opt)
            if nargin < 2
                roi_no = 1: obj(1).nROIs;
                opt = 'mode'; % output deltaF/F
            end
            if nargin < 3
                opt = 'mode';
            end
            
            nROIs = length(roi_no);
            nTrials = length(obj);
            dff_array = zeros(length(obj), obj(1).nFrames, nROIs);
            for  i = 1:nROIs
                switch opt
                    case 'mode' % recalculate dF/F using mode as Fo
                        %             for j = 1:length(caobj)
                        %                 traces(j, :)= caobj(j).CaTrace_raw(ROInums(i),:);
                        %             end
                        %             [N,X] = hist(traces(:),50);
                        %             F0 = mean(X(N==max(N)));
                        %             CaTraces(:,:, i) = (traces-F0)./F0*100;
                        traces = get_f_array(obj, i, 1:nTrials,'raw');
                        v = var(traces,0,2);
                        % normalize to a mean trace to correct artifacts
                        trace_mean = mean(traces(v<prctile(v,30),:),1);
                        for j = 1:length(obj)
                            y = traces(j,:)./trace_mean;
                            [N,X] = hist(y,30);
                            F0 = mean(X(N==max(N)));
                            dff_array(j,:, i) = (y - F0)./F0*100;
                            obj(j).dff(i,:) = dff_array(j,:, i);
                        end
                    case 'mode2' % Re-calculate delta F/F, based on global mode, used for high and slow activity
                        for  i = 1:nROIs
                            for j = 1:length(obj)
                                f_raw(j,:) = obj(j).f_raw(i,:);
                            end
                            [N,X] = hist(f_raw(:),50);
                            f_mode = min(X(N==max(N)));
                            F0 = prctile(f_raw(f_raw < f_mode),50);
                            dff_array(:,:,i) = (f_raw - F0)./F0*100;
                            for j = 1:length(obj)
                                obj(j).dff(i,:) = dff_array(j,:, i);
                            end
                        end
                        
                        %         case 'perct' % recalculate dF/F using percentile 30 over all trials as Fo
                    case 'perct' % recalculate dF/F using percentile 30 within the current trial as Fo
                        traces = get_f_array(obj, i,1:nTrials, 'raw');
                        v = var(traces,0,2);
                        trace_mean = mean(traces(v<prctile(v,30),:),1);
                        for j = 1:length(caobj)
                            y = traces(j,:)./trace_mean;
                            F0 = prctile(y, 30);
                            dff_array(j,:, i) = (y - F0)./F0*100;
                            obj(j).dff(i,:) = dff_array(j,:, i);
                        end
                       
                end
            end
            
        end
        
        function [f_array,ts] = get_f_array(obj, roi_no, trialNums, opt)
            % Retrieve fluo time series array of particular ROIs, in the
            % form of either deltaF/F or raw fluorescence.
            if nargin < 2
                roi_no = 1: obj(1).nROIs;
                trialNums = 1:length(obj);
                opt = 'dff'; % output deltaF/F
            end
            if nargin < 3
                trialNums = 1:length(obj);
                opt = 'dff';
            end
            if nargin < 4
                opt = 'dff';
            end
            if ischar(trialNums)
                trialNums = 1:length(obj);
            end
            nROIs = length(roi_no);
            f_array = zeros(length(trialNums), obj(1).nFrames, nROIs);
            switch opt
                case 'raw'
                    for  i = 1:nROIs
                        for j = 1:length(trialNums)
                            f_array(j, :, i)= obj(trialNums(j)).f_raw(roi_no(i),:);
                        end
                    end
                case 'dff'
                    for  i = 1:nROIs
                        for j = 1:length(trialNums)
                            f_array(j, :, i)= obj(trialNums(j)).dff(roi_no(i),:);
                        end
                    end
            end
            ts = (1:obj(1).nFrames).* obj(1).FrameTime/1000;
        end
        
        function roiParam = get_roi_param(obj,ROInums,smooth_flag)
            % Get the basic parameters of time series for each ROI, such as
            % mean, standard deviatin etc.
            
            % smooth_flag, whether to smooth the signal before get the statistics
            
            slope_span = 5; % length of the piece to get local slope, empiracally decided
            
            if ~exist('ROInums','var')||isempty(ROInums)
                ROInums = 1:obj(1).nROIs;
            end
            nFr = obj(1).nFrames;
            nTr = length(obj);
            
            for i = 1:length(ROInums)
                CaTraces = get_f_array(obj, ROInums(i),1:nTr,'dff');
                y = reshape(CaTraces',1,[]);
                if smooth_flag == 1
%                     y = smooth(y,5,'lowess');
                     y = smooth(y, 5, 'sgolay');
                end
                
%                 roiParam(i).sd = std(y(y<2*std(y)));
                % Use median absolute deviation to obtain SD, as an
                % estimation of noise. This way could reduce the
                % contribution from neuronal signal
                roiParam(i).sd = mad(y,1) * 1.4826;
%                 roiParam(i).sd_neg = std(y(y<0));
                % roiParam(i).sd_pos = std(y(y>0));
                roiParam(i).mean = mean(y);
                
%                 SNR = roiParam(i).mean/roiParam(i).sd_neg;
%                 if SNR <= 0.5
%                     level=3;
%                 elseif SNR >0.5 && SNR < 1
%                     level = 2;
%                 else % SNR > 1
%                     level = 1;
%                 end
%                 y_dn = Ca_wave_dn(y,'db2',level); % Wavelet denoise
%                 traces_dn = reshape(y_dn, nFr, nTr)';
%                 
%                 roiParam(i).traces_dn = traces_dn;
%                 roiParam(i).roi_num = ROInums(i);
%                 roiParam(i).sd_dn = std(y_dn(y_dn<2*std(y_dn)));
%                 roiParam(i).sd_neg_dn = std(y_dn(y_dn<0));
%                 roiParam(i).mean_dn = mean(y_dn);
%                 
                for j=1:length(y);
                    if j+slope_span > length(y)
                        break
                    end
                    slope(j) = (y(j+slope_span)-y(j))/slope_span;
                end
                roiParam(i).slope_sd = mad(slope,1)*1.4826;
                roiParam(i).slope_span =  slope_span;
            end
        end
        
        % *************************************************************************
        function obj = get_Transients(obj,trialStartEnd, ROInums)
            % Detect Ca transients events for all trials, and store the
            % events info to each imTrialsObj object
            
            % - NX, 8/2009
            
            if ~exist('trialStartEnd','var') || isempty(trialStartEnd)
                startTrial = 1;
                endTrial = length(obj);
            else
                startTrial = trialStartEnd(1);
                endTrial = trialStartEnd(2);
            end
            if ~exist('ROInums','var')||isempty(ROInums)
                ROInums = 1:obj(1).nROIs;
            end
            if ~ exist('thrFactor', 'var')
                thrFactor = 4;
            end
            
            framesPerTrial = obj(1).nFrames;
            unitTime = obj(1).FrameTime;
            if unitTime > 1 % meaning unit is ms, convert to sec
                unitTime = unitTime/1000;
            end
%             if exist([obj(1).FileName_prefix 'CaEvents.mat'], 'file')
%                 load([obj(1).FileName_prefix 'CaEvents'], '-mat');
%                 disp([obj(1).FileName_prefix 'CaEvents.mat already exists. Loading ths file...']);
%                 disp(['Adding the loaded CaEvents Data to the current CaObj ...']);
%                 for i = startTrial:endTrial
%                     for j = 1:obj(i).nROIs
%                         obj(i).CaTransients{j} = Events{i,j};
%                     end
%                 end
%                 return
%             else
%                 Events = {};
%             end

%             if ~isempty(obj(1).CaTransients)
%                 s= input('CaTransients already exist. Do event detection again, and overwrite current events? (y/n)');
%                 if strcmpi(s,'n')
%                     s = input('Continue unfinished detection(c)? or return (r)? ');
%                     if strcmpi(s,'c')
%                         startTrial = input('Continue from trial: ');
%                     else
%                         return
%                     end
%                 end
%             end

            roiParam = get_roi_param(obj,[],0);
            ts = (1:framesPerTrial).*unitTime;
%             for i = startTrial : endTrial
            parfor i = startTrial : endTrial
                %%
                for j = ROInums
                    %         Threshold = 8*roiParam(j).sd_neg;
                    %         DecayThresh = roiParam(j).sd_neg;
                    %         thrFactor = 8;
%                     thr = thrFactor*roiParam(j).sd_neg_dn;
%                     thr = 4*roiParam(j).sd;
                    thr = thrFactor*roiParam(j).sd;
                    dthr = roiParam(j).sd;
                    slopeThresh = 2*roiParam(j).slope_sd;
                    slope_span = roiParam(j).slope_span;
                    trace_orig = obj(i).dff(j,:);
                    trace = smooth(trace_orig,5,'sgolay');
                    % Use de-noised trace for event detection: denoised by wavelet then
                    % smoothed.
%                     trace_dn = smooth(roiParam(j).traces_dn(i,:),3); % trace; %
                    % event detection on de-nosied traces
                    eventTiming = CaEventDetector(trace,thr,dthr,slope_span,slopeThresh); %,slopeThresh,slope_span);
                    event = struct([]);
                    
                    if ~isempty(eventTiming)
                        %             figure(gcf);
                        %             plot(ts,trace);title([str1 str2]);
                        for k = 1:size(eventTiming,1) % number of events in each trial
                            onset = eventTiming(k,1);
                            offset = eventTiming(k,2);
                            time_thresh = eventTiming(k,3)*unitTime;
                            t = (onset:offset).*unitTime;
                            y = trace(onset:offset);
                            if length(y)< 4
                                continue;
                            end
                            temp = Ca_getEventParam(y,t);
                            temp.time_thresh = time_thresh;
                            temp.trialID = obj(i).TrialNo;
                            temp.ROIid = j;
                            temp.ts = t;
                            temp.value = trace_orig(onset:offset);
                            event = [event temp];
                        end
                    else
                        event = [];
                    end
                    obj(i).CaTransients{j} = event;
                    fprintf('%d Ca Events detected for TrialID: %d\n', length(event), obj(i).TrialNo);
                end
            end
        end % function
        
        function [eventTimes] = get_behavTimes(obj)
            
            if isempty(obj(1).behavTrial)
                error('No behavioral info in CaImageTrials object...');
                return;
            end
            for i = 1:length(obj)
                %     eventTimes.lick{i} = [obj(i).behavTrial.LickTimesPreAnswer obj(i).behavTrial.LickTimesPostAnswer];
                eventTimes.lick{i} = obj(i).behavTrial.beamBreakTimes;
                eventTimes.poleOnset(i) = obj(i).behavTrial.pinDescentOnsetTime;
                eventTimes.poleOffset(i) = obj(i).behavTrial.pinAscentOnsetTime;
                if isempty(obj(i).behavTrial.answerLickTime)
                    eventTimes.answerLick(i) = NaN;
                else
                    eventTimes.answerLick(i) = obj(i).behavTrial.answerLickTime;
                end
                
            end
        end
        
        function ROI_events = ROI_events_param(obj)
            % Get the event parameters from all ROIs of all trials. And compute trial
            % ROI_events, 1x4 struct array, with each element for one of
            %                   the 4 trial phase,   'pre_stim', 'stim',  'reward', 'trial'
            %                   'pre_stim', before the pole entering
            %                   'stim', during the time the pole is presented. 
            %                   'trial', get the events for the whole trial.
            %
            %
            % 
            % - NX 2009
            event = struct([]);
            criteria_id = 1;
            epoch_type = {'pre_stim', 'stim', 'reward', 'trial'};
            for ii = 1:4
                ROI_events(ii).epoch = epoch_type{ii};
                pks = [];
                areas = [];
                width = nan(obj(1).nTrials, obj(1).nROIs);
                areasNorm = [];
                tauDecay = nan(obj(1).nTrials, obj(1).nROIs);
                numEvent = [];
                
                for i = 1:length(obj)
                    % boundary point bp
                    bp(1)=obj(i).behavTrial.pinDescentOnsetTime;
                    bp(2) = obj(i).behavTrial.pinAscentOnsetTime + obj(i).behavTrial.waterValveDelay;
                    unitTime = obj(i).FrameTime; if unitTime>1, unitTime=unitTime/1000; end;
                    switch ROI_events(ii).epoch
                        case 'pre_stim'
                            criteria_id = 1;
                            str='Pre Stim Epoch';
                            t_start=0; t_end=bp(1);
                        case 'stim'
                            str='Stim Epoch';
                            criteria_id = 2;
                            t_start=bp(1); t_end=bp(2);
                        case 'reward'
                            str='Reward Epoch';
                            criteria_id = 3;
                            t_start=bp(2); t_end=obj(i).nFrames*unitTime;
                        case 'trial'
                            str='Full Trial';
                            criteria_id = 4;
                            t_start=0; t_end=obj(i).nFrames*unitTime;
                    end
                    for j=1:obj(1).nROIs
                        event = obj(i).CaTransients{j};
                        if ~isempty(event)
                            %criteria(1:3)=[false false false];
                            for k = 1:length(event)
                                p = []; a=[]; w=[];
                                criteria(1) = event(k).time_thresh < bp(1);
                                criteria(2) = event(k).time_thresh>bp(1)&&event(k).time_thresh<bp(2); % for stim epoch
                                criteria(3) = event(k).time_thresh > bp(2); % for reward epoch
                                criteria(4) = true;
                                if criteria(criteria_id) == true
                                    p(k) = event(k).peak;
                                    a(k) = event(k).area;
                                    w(k) = event(k).fwhm;
                                    t(k) = event(k).tauDecay;
                                    [pks(i,j), ind] = max(p);
                                    areas(i,j) = a(ind);
                                    width(i,j) = w(ind);
                                    areasNorm(i,j) = max(a(ind)./w(ind));
                                    tauDecay(i,j) = t(ind); % tau of the events with largest peak
                                end
                                numEvent(i,j)= numel(p); % /(t_end-t_start);
                            end
                        end
                    end
                end
                
                ROI_events(ii).peaks=pks;
                ROI_events(ii).peak_mean = mean(pks,1);
                ROI_events(ii).peak_se = std(pks,0,1)./sqrt(length(obj));
                
                ROI_events(ii).areas=areas;
                ROI_events(ii).area_mean=mean(areas,1);
                ROI_events(ii).area_se=std(areas,0,1)/sqrt(length(obj));
                
                ROI_events(ii).fwhm=width;
                ROI_events(ii).fwhm_mean = nanmean(width,1);
                ROI_events(ii).fwhm_se= nanstd(width,0,1)/sqrt(length(obj));
                
                ROI_events(ii).areasNorm=areasNorm;
                ROI_events(ii).areasNorm_mean=mean(areasNorm,1);
                ROI_events(ii).areasNorm_se=std(areasNorm,0,1)/sqrt(length(obj));
                
                ROI_events(ii).tauDecay = tauDecay;
                ROI_events(ii).tauDecay_mean = nanmean(tauDecay,1);
                ROI_events(ii).tauDecay_se = nanstd(tauDecay,0,1)/sqrt(length(obj));
                
                ROI_events(ii).numEvent=numEvent;
                ROI_events(ii).numEvent_mean=mean(numEvent,1);
                ROI_events(ii).numEvent_se=std(numEvent,0,1)/sqrt(length(obj));
            end
            % color plotting
        end
        
        function fig = roi_overview_color_plot(obj, param, title_str, clr_sc)
            if nargin < 4
                clr_sc = [-10 200];
            end
            cscale = [-10 200];
            fig = figure('Position',[30   240   480   580]);
            imagesc(param); colorbar; caxis(clr_sc); set(gca, 'FontSize',12);
            colormap('Hot');
            xlabel('ROI #', 'FontSize', 15);
            ylabel('Trial #', 'FontSize', 15);
            title(title_str, 'FontSize', 18);
            set(gca,'YDir','normal');
        end
        
        function [Traces, trace_mean, trace_se, ts] = get_traces_and_plot(obj, ROInum, h_axes, polePos_id)
            for i = 1:numel(obj)
                trialNums(i) = obj(i).TrialNo;
            end
            if ~exist('polePos_id','var')
                polePos_id = [];
%             else
%                 polePos_colors = polePos_colors(trialNums,:);
            end
            if ~exist('h_axes', 'var')
                h_axes = gca;
            end
            eventTimes = obj.get_behavTimes;
            t_lick = eventTimes.lick;
            poleOnset = eventTimes.poleOnset;
            answerLick = eventTimes.answerLick;
            
            [Traces, ts] = obj.get_f_array(ROInum,'dff');
            color_sc = [-10 200];
            cmap = 'jet';
            trace_mean = nanmean(Traces, 1);
            trace_se = nanstd(Traces,0, 1)./sqrt(size(Traces,1));
            % if no_plotting == true
            %    return;
            % end
            h_plot = cplot_trials_with_behav_times(Traces,ts,t_lick, ...
                poleOnset, answerLick, h_axes,color_sc,polePos_id, cmap);
        end

        function plot_multi_traces(obj, roiNo, trialNums, flag_mark_events, eventt, h_fig)
            % Plot Ca response traces of multiple trials
            % Input: traceArray, nTrials-by-nFrames.
            %        ts,     time stamp of imaging frames.1-by-nFrames
            %        eventt, m x n cell array. m, nTrials. n, types of events.
%                            Each element is a 1 x k double. 
            %
            [traceArray, ts] = obj.get_f_array(roiNo,trialNums);
            
            if ~exist('flag_mark_events','var')||~exist('eventt','var')
                flag_mark_events = 0;
            end
%             if ~exist('ts','var')||isempty(ts)
%                 ts=1:size(traceArray,2);
%             end
            if ~exist('h_fig','var')
                scrsz = get(0, 'ScreenSize');
                h_fig = figure('Position', [20, 50, scrsz(3)/4, scrsz(4)-200], 'Color', 'w');
            end
            
%             traceArray = obj.get_f_array(roiNo,trialNums);
            figure(h_fig);
            spacing = 1/(size(traceArray,1)+2); % n*x + 3.5x = 1, space between plottings;
            % y_lim = [min(Ca_trace_array(:))/2, max(Ca_trace_array(:))];
            y_lim = [-20 250]; %[min(min(y))/2 max(max(y))];
            x_lim = [ts(1)-0.2 ts(end)+0.2];
            for i = 1:size(traceArray,1)
                if ~isempty(obj(trialNums(i)).behavTrial)
                    if obj(trialNums(i)).behavTrial.trialType == 1
                        if obj(trialNums(i)).behavTrial.trialCorrect == 1
                            clr = 'b'; % hit trial
                        else
                            clr = 'k'; % miss trial
                        end
                    else
                        if obj(trialNums(i)).behavTrial.trialCorrect == 1
                            clr = 'r'; % correct rejection
                        else
                            clr = 'g'; % false alarm
                        end
                    end
                else
                    clr = 'b';
                end
                ha(i) = axes('position',[0.1, i*spacing, 0.85, 3.5*spacing]);
                hold on;
                %                 plot(ts, traceArray(i,:), 'Color', 'b');
                plot(ts, traceArray(i,:), 'Color', clr, 'LineWidth',1);
                cmap = hsv;
                if flag_mark_events==1
                    for j = 1:size(eventt,2)
                        t = eventt{i,j}.*2/1000;
                        if ~isempty(t)
                            y_ev = [];
                            for k = 1:numel(t)
                                ind = find(ts<=t(k),1,'last');
                                y_ev(k) = traceArray(i,ind);
                            end
                            clr = cmap(floor(64/4*(j-1)+1, :));
                            plot(t, y_ev, 'o', 'MarkerEdgeColor', clr, 'MarkerFaceColor',clr,'MarkerSize',3);
                            % plot_Ca_event(events(k),ha(i));
                        end
                    end
                end
                set(ha(i),'visible','off', 'color','none','YLim',y_lim,'XLim',x_lim);
            end;
            set(ha(1),'visible','on', 'box','off','XColor','k','YColor','k','FontSize',15);
        end
        
        function out = get_eventParam_roi(obj,roiNo,paramStr)
            % paramStr: 'fwhm','peak','area',tauRise','tauDecay'
            nTr = length(obj);
            out = cell(nTr,1);
            for i = 1:nTr
                if isempty(obj(i).CaTransients)
                    out{i} = NaN;
                    continue;
                end
                for j = 1:length(obj(i).CaTransients{roiNo})
                    out{i}(j) = obj(i).CaTransients{roiNo}(j).(paramStr);
                end
            end
            
        end
        
        function behavTrials = add_behavTrials(obj,SoloSessionID, SoloTrialStartEnd, SoloDataPath)
            % SoloSessionID: 'a', 'b', etc.
            mouseName = obj(1).AnimalName;
            SoloSessionName = [obj(1).ExpDate SoloSessionID];
            solodata = Solo.load_data_nx(mouseName, SoloSessionName, SoloTrialStartEnd,SoloDataPath);
            SoloTrialNums = (SoloTrialStartEnd(1) : SoloTrialStartEnd(2));
            
            if length(SoloTrialNums) ~= length(obj)
                error('Number of behavior trials NOT equal to Number of Ca Image Trials!')
            end
            for i = 1:length(SoloTrialNums)
                behavTrials(i) = Solo.BehavTrial_nx(solodata,SoloTrialNums(i),1);
                obj(i).behavTrial = behavTrials(i);
            end
            disp([num2str(i) ' Behavior Trials added to imTrialsObj']);
            
        end
    end
    
    methods % Dependent property methods; cannot have attributes
        
        function value = get.nROIs(obj)
            for i = 1: length(obj)
                value(i) = length(obj(i).ROIMask); 
%                 obj(i).nROIs = value(i);
            end
%             obj.roi_events_param = roi_events;
        end
    end
end

