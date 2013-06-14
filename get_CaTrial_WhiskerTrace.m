function [WhiskerSpeed, wVideoTS] = get_CaTrial_WhiskerTrace(CaTrials)
% 
% CaTrials is structure data, the results from nx_CaSginal GUI, integraged with behavioral data. 
% WhiskerSpeed, nTrials x nFrames
% ts, nTrials x nFrames
%
% Note that the nFrmaes in the CaTrial structure data are pre-processed so
%       tahta all trials have the same number of video frames.
%
% NX - 6/2009

WhiskerSpeed = [];
wVideoTS = [];
for i = 1:length(CaTrials)
    trace = CaTrials(i).wAvgMotion;
    ts = CaTrials(i).wVideoTS;
    WhiskerSpeed = [WhiskerSpeed; trace];
    wVideoTS = [wVideoTS; ts];
end

