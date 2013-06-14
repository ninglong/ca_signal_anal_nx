function Inds = get_Ca_behavInds(CaTrials, trialType)
%
%
%
% NX - 6/2009

nTrials = length(CaTrials);
Inds = struct([]);

for i = 1:nTrials
    Inds(i) = CaTrials(i).behavTrialInd;
end

    