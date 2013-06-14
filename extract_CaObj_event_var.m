function extract_CaObj_event_var(CaObjArray)

peaks=[]; event=struct([]);
for i = 1:length(CaObjArray)
    for j=1:CaObjArray(1).nROIs
        event = CaObjArray(i).CaTransients{j};
        if ~isempty(event)
            p=[]; a=[]; w=[]; t=[];
            for k = 1:length(event)
                % criteria(1) = event(k).peak_time < CaObjArray(i).behavTrial.answerLickTime;
                criteria = event(k).onset < CaObjArray(i).behavTrial.pinAscentOnsetTime;
                if criteria== true
                    p(k) = event(k).peak;
                    a(k) = event(k).area;
                    w(k) = event(k).fwhm;
                    t(k) = event(k).tauDecay;
                    peaks(i,j) = max(p);
                    areas(i,j) = max(a);
                    areasNorm(i,j) = max(a./w);
                    tauDecay(i,j) = t(p==max(p)); % tau of the events with largest peak
                end
            end
        end
    end
    % disp(CaObjArray(i).behavTrial.trialNum);
end



figure('Position',[30   240   480   580]);
imagesc(peaks); colorbar; set(gca, 'FontSize',12); 
xlabel('ROI #', 'FontSize', 15); ylabel('Trial #', 'FontSize', 15);
title('Peak of Events', 'FontSize', 18);
% %%
% fig2 = figure('Position',[50   240   480   580]);
% imagesc(areas); colorbar; set(gca, 'FontSize',12); caxis([0 250]);
% xlabel('ROI #', 'FontSize', 15); ylabel('Trial #', 'FontSize', 15);
% title('Area of Events', 'FontSize', 18);
% %%
% fig3 = figure('Position',[70   240   480   580]);
% imagesc(areasNorm); colorbar; set(gca, 'FontSize',12); 
% xlabel('ROI #', 'FontSize', 15); ylabel('Trial #', 'FontSize', 15);
% title('Normalized Area of Events', 'FontSize', 18);
