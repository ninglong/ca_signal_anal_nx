function Events = get_Transients(obj,trialStartEnd, ROInums, thrFactor)
% get Ca transients events for all trials, and store the events variables
% to each CaImageTrials object

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
    thrFactor = 8;
end

framesPerTrial = obj(1).nFrames;
unitTime = obj(1).FrameTime;
if unitTime > 1 % meaning unit is ms, convert to sec
    unitTime = unitTime/1000;
end
if exist([obj(1).FileName_prefix 'CaEvents.mat'], 'file')
    load([obj(1).FileName_prefix 'CaEvents'], '-mat');
    disp([obj(1).FileName_prefix 'CaEvents.mat already exists. Loading ths file...']);
    disp(['Adding the loaded CaEvents Data to the current CaObj ...']);
    for i=startTrial:endTrial
        for j=1:obj(i).nROIs
            obj(i).CaTransients{j} = Events{i,j};
        end
    end
    return
else
    Events = {};
end
roiParam = get_roi_param(obj,[],0);
if ~isempty(obj(1).CaTransients)
    s= input('CaTransients already exist. Do event detection again, and overwrite current events? (y/n)');
    if strcmpi(s,'n')
        s = input('Continue unfinished detection(c)? or return (r)? ');
        if strcmpi(s,'c')
            startTrial = input('Continue from trial: ');
        else
            return
        end
    end
end
ts = (1:framesPerTrial).*unitTime;
for i = startTrial : endTrial
    for j = ROInums
%         Threshold = 8*roiParam(j).sd_neg;
%         DecayThresh = roiParam(j).sd_neg;
%         thrFactor = 8;
        thr = thrFactor*roiParam(j).sd_neg_den;
        dthr = roiParam(j).sd_neg_den;
        slopeThresh = 2*roiParam(j).slope_sd;
        slope_span = roiParam(j).slope_span;
        trace_orig = obj(i).CaTrace(j,:);
        trace = smooth(trace_orig,5,'lowess');
        % Use de-noised trace for event detection: denoised by wavelet then
        % smoothed.
        trace_den = smooth(roiParam(j).traces_den(i,:),3); % trace; % 
        % event detection on de-nosied traces
        eventTiming = CaEventDetector(trace, trace_den,4,thr,dthr,slope_span,slopeThresh); %,slopeThresh,slope_span);
        event = struct([]);
        
        str1 = sprintf('TrialID: %d', i);
        str2 = sprintf('ROIid: %d  ', j);
        disp(str1);
        disp(str2);
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
                temp.trialID = i;
                temp.ROIid = j;
                temp.ts = t;
                temp.value = trace_orig(onset:offset);
                event = [event temp];
            end
        else
            event = [];
        end
        obj(i).CaTransients{j} = event;
        Events{i,j} = event;
    end
end % i
save('-v7.3',['CaEvents_' obj(1).FileName_prefix], 'Events');
end % function

