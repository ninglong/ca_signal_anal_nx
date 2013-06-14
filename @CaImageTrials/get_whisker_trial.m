function whiskerTrials = get_whisker_trial(obj, whiskerResults_dir)
if ~exist(whiskerResults_dir,'dir') == 7
    error('Incorrect whisker data directory!')
    return
end
pwd0 = pwd;
cd(whiskerResults_dir);
wsk_files = dir(['*' obj(1).SessionName '*.mat']);
if length(wsk_files)~= obj(1).nTrials
    error('Number of whisker trial NOT matching number of Ca trial! Check filename or directory!')
    return
end
for i=1:length(obj)
    load(wsk_files(obj(i).TrialNo).name);
    disp(wsk_files(obj(i).TrialNo).name);
    if ~isempty(measurements)
        whiskerTrials(i) = WhiskerTrial(measurements, obj(i).TrialNo, ...
            obj(i).FileName, obj(i).behavTrial.trialNum, obj(i).AnimalName,...
            obj(i).SessionName, obj(i).ExpDate);
    end
end
cd(pwd0)