function EventsParamPool = get_CaObjEventsParamsPool(obj,ROInums,trial_epoch)

EventsParamsPool=struct([]);
onset=[]; peak=[]; fwhm=[]; area=[]; tauDecay=[]; tauRise=[]; thresh_cross_time=[];
for i=1:length(obj)
    
    bp(1)=obj(i).behavTrial.pinDescentOnsetTime;
    bp(2) = obj(i).behavTrial.pinAscentOnsetTime + obj(i).behavTrial.waterValveDelay;
    unitTime = obj(i).FrameTime; if unitTime>1, unitTime=unitTime/1000; end;
    switch trial_epoch
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
    
    for j=1:length(ROInums)
        if ~isempty(obj(i).CaTransients{ROInums(j)})
            events=obj(i).CaTransients{ROInums(j)};
            for k=1:length(events)
                criteria(1) = events(k).time_thresh < bp(1);
                criteria(2) = events(k).time_thresh>bp(1)&&events(k).time_thresh<bp(2); % for stim epoch
                criteria(3) = events(k).time_thresh > bp(2); % for reward epoch
                criteria(4) = true;
                if criteria(criteria_id)==true
                    onset=[onset events(k).onset];
                    peak=[peak events(k).peak];
                    fwhm=[fwhm events(k).fwhm];
                    area=[area events(k).area];
                    tauDecay=[tauDecay events(k).tauDecay];
                    tauRise=[tauRise events(k).tauRise];
                    thresh_cross_time=[thresh_cross_time events(k).time_thresh];
                end
            end
        end
    end
end
EventsParamPool.onset=onset;
EventsParamPool.peak=peak;
EventsParamPool.fwhm=fwhm;
EventsParamPool.area=area;
EventsParamPool.tauDecay=tauDecay;
EventsParamPool.tauRise=tauRise;
EventsParamPool.thresh_cross_time=thresh_cross_time;
