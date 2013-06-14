function behavTrials = Ca_add_behavTrialObj(obj,solo_data, behavTrialStartEnd)
% Instantiate behavioral trial objects, and add each to each Ca Image Trial
% objects. 
% obj, CaImageTrials object array
% behavTrialStartEnd, the trial numbers in behavioral session corresponding
%                     to the first and last trials of Ca imaging session
% behaveSessionName, usually in the form '090717a'
%
% - NX, 8/2009
%
if nargin < 3
    behavTrialNums = solo_data.trialStartEnd(1):solo_data.trialStartEnd(2);
else
    behavTrialNums = behavTrialStartEnd(1):behavTrialStartEnd(2);
end
if length(behavTrialNums) ~= length(obj)
    error('Number of behavior trials NOT equal to Number of Ca Image Trials!')
end
for i = 1:length(behavTrialNums)
    behavTrials(i) = Solo.BehavTrial(solo_data,behavTrialNums(i),1);
    obj(i).behavTrial = behavTrials(i);
end
