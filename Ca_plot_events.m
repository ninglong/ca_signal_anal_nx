
peaks=[]; event=struct([]);
for i = 1:length(obj)
    for j=1:obj(1).nROIs
        event = obj(i).CaTransients{j};
        if ~isempty(event)
            p=[]; a=[]; w=[]; t=[];
            for k = 1:length(event)
                % criteria(1) = event(k).peak_time < obj(i).behavTrial.answerLickTime;
                % criteria = event(k).onset > obj(i).behavTrial.pinAscentOnsetTime;
                if event(k).onset > obj(i).behavTrial.pinAscentOnsetTime;
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
    % disp(obj(i).behavTrial.trialNum);
end


figure('Position',[30   240   480   580]);
imagesc(peaks); colorbar; set(gca, 'FontSize',12); 
xlabel('ROI #', 'FontSize', 15); ylabel('Trial #', 'FontSize', 15);
title('Peak of Events', 'FontSize', 18);