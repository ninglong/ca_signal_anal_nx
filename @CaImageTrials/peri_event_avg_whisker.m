function wskPE = peri_event_avg_whisker(obj, ROInum, whiskerDir, epoch,ignore_trials)

% obj = CaObj;
% ROInum = 1;
% whiskerDir = 'I:\Exp_Data\NXJF36705\090716\WhiskerTrackingResults';
bin = 3; % the time window in sec for averaging
SI = 0.002;
count = 0;
if ~exist('epoch','var')
    epoch = [];
end
if ~exist('ignore_trials','var')
    ignore_trials = [];
end
for i = 1:length(obj)
    if ismember(i,ignore_trials)
        continue
    end
    T = []; % threshold crossing times
    CaEvents = obj(i).CaTransients{ROInum};
    if ~isempty(CaEvents)
        for j = 1:length(CaEvents)
            if CaEvents(j).peak >= 0 % select events with certain peak amp
                T = CaEvents(j).time_thresh; % peak_time; %
            else
                continue
            end
        end
        if strcmpi(epoch,'stim')
            bound1 = obj(i).behavTrial.pinDescentOnsetTime;
            bound2 = obj(i).behavTrial.pinAscentOnsetTime + obj(i).behavTrial.waterValveDelay;
            T = T(T>=bound1 & T<=bound2);
        elseif strcmpi(epoch, 'reward')
            bound1 = obj(i).behavTrial.pinAscentOnsetTime + obj(i).behavTrial.waterValveDelay;
            T = T(T>=bound1);
        else
            T = T(find(T>= obj(i).behavTrial.pinDescentOnsetTime,1,'first'));
        end
    end
    if ~isempty(T) % only the first events were taken
        count = count+1;
        wsk = obj(i).get_whisker_trial(whiskerDir);
        PEA_window = [max(T(1)-bin/2, 0), min(T(1)+bin/2, wsk(1).ts(end))];
        padding = {[], []};
        if T(1)< bin/2
            padding{1} = nan(ceil((bin/2-T(1))/SI),1);
        end
        if T(1) > wsk(1).ts(end) - bin/2
            padding{2} = nan(floor((T(1)+bin/2 - wsk(1).ts(end))/SI),1);
        end
        PE_inds = find(wsk(1).ts> PEA_window(1) & wsk(j).ts< PEA_window(2));
%         if length([padding{1};PE_inds; padding{2}]) < floor(bin/SI)
%             padding{2} = [padding{2}; nan((floor(bin/SI)-length([padding{1};PE_inds; padding{2}])),1)];
%         end
        for j = 1:length(wsk)
            wskPE(j).PE_curv(:,count) = [padding{1}; wsk(j).curvature(PE_inds); padding{2}];
            wskPE(j).PE_angle(:,count) = [padding{1}; wsk(j).angle(PE_inds); padding{2}];
            wskPE(j).PE_vel(:,count) = [padding{1}; ...
                wsk(j).velocity(PE_inds(1):min(length(wsk(j).velocity), PE_inds(end)));padding{2}];
            wskPE(j).PE_acc(:,count) = [padding{1};...
                wsk(j).accel(PE_inds(1):min(length(wsk(j).accel), PE_inds(end)));padding{2}];
        end
    end
end
for i = 1:length(wskPE)
    curvPEA(i,:) = nanmean(wskPE(i).PE_curv,2)';
    angPEA(i,:) = nanmean(wskPE(i).PE_angle,2)';
    velPEA(i,:) = nanmean(wskPE(i).PE_vel,2)';
    accPEA(i,:) = nanmean(wskPE(i).PE_acc,2)';
end
ts = (-bin/2:SI:bin/2-SI);
fig1 = figure; hold on;
plot(ts,curvPEA(1:3,:));
set(gca,'FontSize',12)
title(['PEA-Curvature, ROI#' num2str(ROInum)],'FontSize',18);
ylabel('mean Curvature', 'FontSize', 18);
xlabel('Peri-Thresh Time (s)','FontSize',18);
legend('C1','C2','C3'); %,'C4','C5');
yl = get(gca,'YLim');
line([0 0], yl, 'Color', 'k','LineStyle','--');
fig2 = figure;
plot(ts,angPEA);
% fig3 = figure;
% plot(ts,velPEA);
% plot(ts,accPEA);