function roiStats = get_roi_stats(obj,ROInums,smooth_flag)

% smooth_flag, whether to smooth the signal before get the statistics

slope_span=3; % length of the piece to get local slope, empiracally decided
if ~exist('ROInums','var')||isempty(ROInums)
    ROInums = 1:obj(1).nROIs;
end

for i = 1:length(ROInums) 
    CaTraces = get_CaTraces(obj, ROInums(i),'asis');
    trace_cat = reshape(CaTraces',1,[]);
    if smooth_flag == 1
        trace_cat = smooth(trace_cat,5);
    end
    roiStats(i).roi_num = ROInums(i);
    % std of baseline, std of signal<2*std(signal)
    roiStats(i).sd = std(trace_cat(trace_cat<2*std(trace_cat)));
    roiStats(i).sd_neg = std(trace_cat(trace_cat<0));
    roiStats(i).sd_pos = std(trace_cat(trace_cat>0));
    roiStats(i).Avg = mean(trace_cat);
    for j=1:length(trace_cat);
        if j+slope_span > length(trace_cat)
            break
        end
        slope(j) = (trace_cat(j+slope_span)-trace_cat(j))/slope_span;
    end
    roiStats(i).slope_sd = std(slope);
    roiStats(i).slope_span=  slope_span;
end
