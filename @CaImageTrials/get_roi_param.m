function roiParam = get_roi_param(obj,ROInums,smooth_flag)

% smooth_flag, whether to smooth the signal before get the statistics

slope_span=5; % length of the piece to get local slope, empiracally decided
if ~exist('ROInums','var')||isempty(ROInums)
    ROInums = 1:obj(1).nROIs;
end
nFr = obj(1).nFrames;
nTr = length(obj);

for i = 1:length(ROInums) 
    CaTraces = get_CaTraces(obj, ROInums(i),'asis');
    y = reshape(CaTraces',1,[]);
    if smooth_flag == 1
        y = smooth(y,5,'lowess');
    end
    
    roiParam(i).sd = std(y(y<2*std(y)));
    roiParam(i).sd_neg = std(y(y<0));
    % roiParam(i).sd_pos = std(y(y>0));
    roiParam(i).mean = mean(y);
    
    SNR = roiParam(i).mean/roiParam(i).sd_neg;
    if SNR <= 0.5
        level=3;
    elseif SNR >0.5 && SNR < 1
        level = 2;
    else % SNR > 1
        level = 1;
    end
    y_den = Ca_waveden(y,'db2',level);
    traces_den = reshape(y_den, nFr, nTr)';
    
    roiParam(i).traces_den = traces_den;
    roiParam(i).roi_num = ROInums(i);
    % std of baseline, std of signal<2*std(signal)
%     sigma_dn = std(y_den(y_den<2*std(y_den))); % SD for noise of denoised signal
%     thr_factor= 4.5; %sqrt(2*log(length(ydn)));
%    thr = sigma_dn*thr_factor;
%    dth=sigma;
    roiParam(i).sd_den = std(y_den(y_den<2*std(y_den)));
    roiParam(i).sd_neg_den = std(y_den(y_den<0));
    roiParam(i).mean_den = mean(y_den);
    
    for j=1:length(y);
        if j+slope_span > length(y)
            break
        end
        slope(j) = (y(j+slope_span)-y(j))/slope_span;
    end
    roiParam(i).slope_sd = std(slope);
    roiParam(i).slope_span=  slope_span;
end
