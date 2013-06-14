function ROI_events = get_ROI_events_param(obj)
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
            for ii = 1:4 % loop through 4 epochs
                ROI_events(ii).epoch = epoch_type{ii};
                pks = [];
                areas = [];
                width = nan(obj.nTrials, obj.nROIs);
                areasNorm = [];
                tauDecay = nan(obj.nTrials, obj.nROIs);
                numEvent = [];
                
                for i = 1:obj.nTrials
                    % boundary point bp
                    bp(1)=obj.SoloTrials{i} .pinDescentOnsetTime + 0.4;
                    bp(2) = obj.SoloTrials{i} .pinAscentOnsetTime + obj.SoloTrials{i} .waterValveDelay;
                    unitTime = obj.FrameTime; if unitTime>1, unitTime=unitTime/1000; end;
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
                            t_start=bp(2); t_end=obj.nFramesPerTrial*unitTime;
                        case 'trial'
                            str='Full Trial';
                            criteria_id = 4;
                            t_start=0; t_end=obj.nFramesPerTrial*unitTime;
                    end
                    for j=1:obj.nROIs
                        event = obj.Ca_events{i,j};
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
                        else
                            pks(i,j) = NaN;
                            areas(i,j) = NaN;
                            width(i,j) = NaN;
                            tauDecay(i,j) = NaN;
                        end
                    end
                end
                
                ROI_events(ii).peaks=pks;
                ROI_events(ii).peak_mean = nanmean(pks,1);
                ROI_events(ii).peak_se = nanstd(pks,0,1)./sqrt(length(obj));
                
                ROI_events(ii).areas=areas;
                ROI_events(ii).area_mean= nanmean(areas,1);
                ROI_events(ii).area_se=nanstd(areas,0,1)/sqrt(length(obj));
                
                ROI_events(ii).fwhm=width;
                ROI_events(ii).fwhm_mean = nanmean(width,1);
                ROI_events(ii).fwhm_se= nanstd(width,0,1)/sqrt(length(obj));
                
                ROI_events(ii).areasNorm=areasNorm;
                ROI_events(ii).areasNorm_mean= nanmean(areasNorm,1);
                ROI_events(ii).areasNorm_se= nanstd(areasNorm,0,1)/sqrt(length(obj));
                
                ROI_events(ii).tauDecay = tauDecay;
                ROI_events(ii).tauDecay_mean = nanmean(tauDecay,1);
                ROI_events(ii).tauDecay_se = nanstd(tauDecay,0,1)/sqrt(length(obj));
                
                ROI_events(ii).numEvent=numEvent;
                ROI_events(ii).numEvent_mean=mean(numEvent,1);
                ROI_events(ii).numEvent_se=std(numEvent,0,1)/sqrt(length(obj));
            end
            % color plotting
            obj.ROI_events_param = ROI_events;
        end
    end