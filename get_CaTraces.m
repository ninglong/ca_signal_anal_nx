function [CaTraces, ts] = get_CaTraces(CaTrials, ROInums,flag)
% 
% CaTrials is structure data, results from nx_CaSginal GUI. 
% CaTraces, nTrials x nFrames x nROIs
% ts, 1 by nFrames
% 
% NX - 6/2009
% flag = 0, CaTraces is raw F
% flag = 1, CaTraces is deltaF/F with F0 being the 30 percentile over all trials
% flag = 2, CaTraces is deltaF/F with F0 being the mode over all trials          
% 

if nargin < 2
    ROInums = 1: CaTrials(1).nROIs;
    flag = 0; % output deltaF/F
end
if nargin < 3
    flag = 0;
end

nROIs = length(ROInums);

CaTraces = zeros(length(CaTrials), CaTrials(1).nFrames, nROIs);
for  i = 1:nROIs
    for j = 1:length(CaTrials)
        traces(j,:) = CaTrials(j).CaTrace_raw(:,ROInums(i));
    end
   
    switch flag
        case 0
            CaTraces(:,:, i) = traces;
        case 1 % percentile 30 over all trials
            F0 = prctile(traces(:), 30);
            CaTraces(:,:, i) = (traces-F0)./F0*100;
        case 2 % use mode as Fo
            [N,X] = hist(traces(:),50);
            F0 = mean(X(N==max(N)));
            CaTraces(:,:, i) = (traces-F0)./F0*100;
    end
end
ts = (0: CaTrials(1).nFrames-1).*CaTrials(j).FrameTime/1000;
if CaTrials(1).FrameTime < 1 % in sec
    ts = ts.*1000;
end