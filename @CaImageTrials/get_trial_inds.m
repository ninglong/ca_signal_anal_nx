function trial_inds = get_trial_inds(obj)

ind_hit = []; ind_miss=[]; ind_cr=[]; ind_fa=[];
for i = 1:length(obj)
    if obj(i).behavTrial.trialType==1
        if obj(i).behavTrial.trialCorrect==1
            ind_hit =[ind_hit i];
        else
            ind_miss=[ind_miss i];
        end
    else
        if obj(i).behavTrial.trialCorrect==1
            ind_cr=[ind_cr i];
        else
            ind_fa = [ind_fa i];
        end
    end
end
trial_inds.go = [ind_hit ind_miss];
trial_inds.nogo = [ind_cr ind_fa];
trial_inds.hit = ind_hit;
trial_inds.miss = ind_miss;
trial_inds.cr = ind_cr;
trial_inds.fa = ind_fa;