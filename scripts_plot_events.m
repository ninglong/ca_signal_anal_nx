%%
for i = 1:size(events,1)
    for j = 1:size(events,2)
        if ~isempty(events{i,j})
            p = [events{i,j}.peak];
            a = [events{i,j}.area];
            w = [events{i,j}.fwhm];
            t = [events{i,j}.tauDecay];
            peaks(i,j) = max(p);
            areas(i,j) = max(a);
            areasNorm(i,j) = max(a./w);
            tauDecay(i,j) = t(p==max(p)); % tau of the events with largest peak
        end
    end
end
%%
fig1 = figure('Position',[30   240   480   580]);
imagesc(peaks); colorbar; set(gca, 'FontSize',12); 
xlabel('ROI #', 'FontSize', 15); ylabel('Trial #', 'FontSize', 15);
title('Peak of Events', 'FontSize', 18);
%%
fig2 = figure('Position',[50   240   480   580]);
imagesc(areas); colorbar; set(gca, 'FontSize',12); caxis([0 250]);
xlabel('ROI #', 'FontSize', 15); ylabel('Trial #', 'FontSize', 15);
title('Area of Events', 'FontSize', 18);
%%
fig3 = figure('Position',[70   240   480   580]);
imagesc(areasNorm); colorbar; set(gca, 'FontSize',12); 
xlabel('ROI #', 'FontSize', 15); ylabel('Trial #', 'FontSize', 15);
title('Normalized Area of Events', 'FontSize', 18);
