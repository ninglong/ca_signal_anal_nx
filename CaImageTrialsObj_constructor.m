
%% Construct Ca Imaging Trial objects
% strdir=pwd;
% % Load solo behavior data
% solo_data = solo_load_data(mouseName, sessionName,trialStartEnd);

% cd(strdir);
% CaObj = CaImageTrials(CaTrials,(7:143));
CaObj = CaImageTrials(CaTrials);
% % subtract a mean trace
% CaObj = CaObj.sub_mean_trace;
for n= 1: CaObj(1).nROIs
    CaTraces = get_CaTraces(CaObj, n, 'mode');
    for i=1:length(CaObj)
        % obj(i).CaTrace = shiftdim(CaTraces(i,:,:),1)' - repmat(trace_to_sub, [nROIs 1]);
        CaObj(i).CaTrace(n,:) = CaTraces(i,:);
    end
end

% add behavior trial data to CaObj
% behavTrials = CaObj.Ca_add_behavTrialObj(solo_data);
%%
% Ca transients event detection
Events = CaObj.get_Transients([],[],8);
% Save with compression
save('-v7.3',['CaObj_' CaObj(1).FileName_prefix], 'CaObj');
save(['CaObj_' CaObj(1).FileName_prefix], 'CaObj');


 %% Sort Ca Trial objects - Aug, 09
% CaObj_hit=[]; CaObj_miss=[]; CaObj_cr=[]; CaObj_fa=[];
% for i = 1:length(CaObj)
%     if CaObj(i).behavTrial.trialType==1
%         if CaObj(i).behavTrial.trialCorrect==1
%             CaObj_hit=[CaObj_hit CaObj(i)];
%         else
%             CaObj_miss=[CaObj_miss CaObj(i)];
%         end
%     else
%         if CaObj(i).behavTrial.trialCorrect==1
%             CaObj_cr=[CaObj_cr CaObj(i)];
%         else
%             CaObj_fa=[CaObj_fa CaObj(i)];
%         end
%     end
% end
 %% Sort Ca hit trials by go positions
% goPos_hit = [];
% for i = 1:length(CaObj_hit)
%     goPos_hit(i) = CaObj_hit(i).behavTrial.goPosition;
% end;
% [goPos_hit_sort, inds_sort_by_pos] = sort(goPos_hit);
% CaObj_hit_sort_by_go = CaObj_hit(inds_sort_by_pos);
% %% Put sorted Ca trials together
% CaObj_sorted = [CaObj_hit CaObj_miss CaObj_cr CaObj_fa];
% 
% save('-v7.3', ['CaObj_trial_sorted_' CaObj(1).FileName_prefix], 'CaObj_sorted', 'CaObj_hit',...
%     'CaObj_miss', 'CaObj_cr', 'CaObj_fa', 'CaObj_hit_sort_by_go');
