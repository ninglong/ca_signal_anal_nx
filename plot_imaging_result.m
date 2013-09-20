function [deltaFF, xValues, peak_deltaFF, area_integ, t_10to90] = plot_imaging_result(filenameWithPath,varargin)

% Inputs:
% varargin{1} = ROI No
% varargin{2} = TrialNo, the last number of the data filename
% Outputs:
% peak_deltaFF
% area_integ, integral area under the response plotting
% t_10to90, rising time from 10% to 90% of peak

% NX - 2008
STIM_ON = 1000; % stimulus on time, ms
END_RESPONSE = 3000; % arbitry defining the end of response to be considered
[filepath, main_filename] = fileparts(filenameWithPath);
cd(filepath);
load([main_filename '_Result.mat']);
ROIs = []; TrialNo = []; 
if nargin > 1
    ROIs = varargin{1};
    if nargin > 2
        TrialNo = varargin{2};
    else
        TrialNo = (1:length(Result));
    end
else
    ROIs = (1:length(Result{1}.CellInfo));
    TrialNo = (1:length(Result));
end
total_Trails = length(TrialNo); % Restult should be a cell array
% total_ROIs = length(Result{1,1}.CellInfo);
fig_pos = [10   400   700   400];
peak_deltaFF = zeros(length(ROIs), total_Trails);
area_integ = zeros(size(peak_deltaFF));
t_10to90 = zeros(size(peak_deltaFF));
figure('Position',[155   265   648   396]) ;
for ROI_NO = ROIs
    for i = TrialNo
        if TrialNo>1
            xValues = Result{i}.xValues;
            deltaFF = Result{i}.CellImage(ROI_NO,:);
        else
            xValues = Result.xValues/1000; % unit as sec
            deltaFF = Result.CellImage(ROI_NO,:);
        end;
        % get the peak deltaF/F, and put it to an array
        peak_deltaFF(ROI_NO,i) = max(deltaFF);
        h_plot = plot(xValues, deltaFF); hold on;
        h_title = title([main_filename '-ROI-' num2str(ROI_NO)], 'FontSize', 20,'Interpreter','none');
        % find the points of 10% and 90% of peak at the rising phase, and
        % do the exp fitting to get the rising time constant
        idx_10 = find((deltaFF > peak_deltaFF(ROI_NO, i)*0.1)&(xValues>STIM_ON/1000), 1, 'first');
        idx_90 = find((deltaFF > peak_deltaFF(ROI_NO, i)*0.9), 1, 'first');
        t_10to90(ROI_NO, i) = xValues(idx_90) - xValues(idx_10);
        xdata_rising = xValues(idx_10:idx_90)';
        ydata_rising = deltaFF(idx_10:idx_90)';
%         [estimates, model] = fitcurve_exprise(xdata_rising, ydata_rising);
%         [sse, FittedCurve] = model(estimates);
%         plot(xdata_rising, FittedCurve, 'r-');
%         % get the rising time constant and put it to an array
%         RisingTimeConstant(i) = estimates(2);
        % get the intergral area under the plotting
        idx_stimon = find(xValues>STIM_ON/1000, 1, 'first');
        idx_end_resp = find(xValues<END_RESPONSE, 1, 'last');
        area_integ(ROI_NO, i) = trapz(xValues(idx_stimon:idx_end_resp),deltaFF(idx_stimon:idx_end_resp));
    end
    hold off;
    set(get(gca,'XLabel'),'String','Time (sec)', 'FontSize', 15);
    set(gca, 'FontSize', 15);
    
% else
%     H_fig = figure;
%     H_plot = plot(Result{1,1}.xValues, deltaF(vargin{1},:));
%     axis([0 max(Result{1,1}.xValues) min(-0.1,min(deltaF(vargin{1},10:end))) max(deltaF(vargin{1},:))]);
end


