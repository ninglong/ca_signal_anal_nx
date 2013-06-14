function [CaTraces, ts] = get_CaTraces(caobj, ROInums,flag)
% 
% CaTrials is structure data, results from nx_CaSginal GUI. 
% CaTraces, nTrials x nFrames x nROIs
% ts, 1 by nFrames
% 
% NX - 8/2009
% flag = 'raw', output CaTraces is raw F
% flag = 'asis', output CaTraces is taken as is.
% flag = 'mode', output CaTraces is recalculated from raw F with F0 being the mode of the same trial          
% flag = 'percn', output CaTraces is recalculated from raw F with F0 being the 30 percentile of the same trial
% 

if nargin < 2
    ROInums = 1: caobj(1).nROIs;
    flag = 0; % output deltaF/F
end
if nargin < 3
    flag = 0;
end

nROIs = length(ROInums);

CaTraces = zeros(length(caobj), caobj(1).nFrames, nROIs);
for  i = 1:nROIs
    switch flag
        case 'raw'
            for j = 1:length(caobj)
                CaTraces(j, :, i)= caobj(j).CaTrace_raw(ROInums(i),:);
            end
        case 'asis' % take dF/F as it is
            for j = 1:length(caobj)
                CaTraces(j, :, i)= caobj(j).CaTrace(ROInums(i),:);
            end
        case 'mode' % recalculate dF/F using mode as Fo
%             for j = 1:length(caobj)
%                 traces(j, :)= caobj(j).CaTrace_raw(ROInums(i),:);
%             end
%             [N,X] = hist(traces(:),50);
%             F0 = mean(X(N==max(N)));
%             CaTraces(:,:, i) = (traces-F0)./F0*100;
            traces = feval(mfilename,caobj, ROInums(i),'raw');
            v = var(traces,0,2);
            trace_mean = mean(traces(v<prctile(v,30),:),1);
            for j = 1:length(caobj)
%                traces(j, :)= caobj(j).CaTrace_raw(ROInums(i),:);
               y = traces(j,:)./trace_mean; 
               [N,X] = hist(y,30);
               F0 = mean(X(N==max(N)));
               CaTraces(j,:, i) = (y - F0)./F0*100; 
            end
            
%         case 'percn' % recalculate dF/F using percentile 30 over all trials as Fo
%             
%             for j = 1:length(caobj)
%                 traces(j, :)= caobj(j).CaTrace_raw(ROInums(i),:);
%             end
%             F0 = prctile(traces(:), 30);
%             CaTraces(:,:, i) = (traces-F0)./F0*100;
        case 'percn' % recalculate dF/F using percentile 30 within the current trial as Fo
            traces = feval(mfilename,caobj, 1,'raw');
            v = var(traces,0,2);
            trace_mean = mean(traces(v<prctile(v,30),:),1);
            for j = 1:length(caobj)
                y = traces(j,:)./trace_mean; 
                F0 = prctile(y, 30);
                CaTraces(j,:, i) = (y-F0)./F0*100;
            end
    end
end
ts = (0: caobj(1).nFrames-1).*caobj(1).FrameTime/1000;
if caobj(1).FrameTime < 1 % in sec
    ts = ts.*1000;
end