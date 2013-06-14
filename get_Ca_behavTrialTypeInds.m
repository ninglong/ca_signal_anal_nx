function Inds = get_Ca_behavTrialTypeInds(CaTrials, trialType)
%
%
%
% NX - 6/2009

nTrials = length(CaTrials);
if ~isfield(CaTrials, 'behavTrial')
    error('Behavioral info not present in CaTrials');
end

hitInds = []; % hit
missInds = []; % miss
faInds = [];   % false alarm 
crInds = [];   % correct rejection

for i = 1:nTrials
    if CaTrials.behavTrial.trialType == 1 
        if CaTrials.behavTrial.trialCorrect == 1
            hitInds = [hitInds i];
        else
            missInds = [misInds i];
        end
    else
        if CaTrials.behavTrial.trialCorrect == 1
            crInds = [crInds i]; 
        else
            faInds = [faInds i];
        end
    end
end

switch trialType
    case 'hit'
        Inds = hitInds;
    case 'miss'
        Inds = missInds;
    case 'FA'
        Inds = faInds;
    case 'CR'
        Inds = crInds;
end
       
    