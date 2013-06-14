function [eventTimes] = get_behavTiming(obj)

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

    