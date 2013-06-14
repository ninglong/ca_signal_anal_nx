function obj = sub_mean_trace(obj,ROInum)

if ~exist('ROInum','var')
    nROIs = obj(1).nROIs;
    ROInum = (1:nROIs);
end
nFrames = obj(1).nFrames;

%[CaTraces, ts] = get_CaTraces(obj, (1:nROIs),2); % use mode as Fo
for n= ROInum
    CaTraces = get_CaTraces(obj, n,'asis'); 
    %catTraces = [];
    % for i=1:nROIs
    %     catTraces=cat(1,catTraces,CaTraces(:,:,i));
    % end
    %v = var(catTraces,0,2);
    v = var(CaTraces,0,2);
    % find traces with variance less than 30 percentile over traces of all
    % trials of all ROIs
    trace_to_sub = zeros(1,nFrames);
%     if exist('FrameNum','var')
%         trace_to_sub(FrameNum) = mean(CaTraces(:,FrameNum));
%     else
%         trace_to_sub = mean(CaTraces(v<prctile(v,30),:));
%     end
    trace_to_sub = mean(CaTraces(v<prctile(v,30),:));
    figure(gcf); plot(trace_to_sub); title(['ROI ' num2str(n)]);
    hold on;
    for i=1:length(obj)
        % obj(i).CaTrace = shiftdim(CaTraces(i,:,:),1)' - repmat(trace_to_sub, [nROIs 1]);
        obj(i).CaTrace(n,:) = CaTraces(i,:) - trace_to_sub;
    end
end
end

       