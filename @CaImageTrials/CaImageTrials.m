% Class for calcium imaging trial containing Ca signal traces from multiple
% ROIs
% NX Feb 2009
%
classdef CaImageTrials < handle
    
    properties
        FileName = '';
        FileName_prefix = ''; 
        TrialNo = [];
        nFrames = [];
        FrameTime = [];  % in ms
        nROIs = [];
        ROIMask = {};
        ROIPos = {}; 
        ROIType = {};
%         meanImage = [];
        DaqInfo = struct([]); % header info of the image file
        nChannel = 1;
        nTrials = [];
        
        EphusData = [];
        WhiskerTrial = []; 
        SessionName = '';
        AnimalName = '';
        ExpDate = '';
        CaTrace_orig = [] % nFrames-by-nROIs of Fluo signal
        CaTrace = []; % corrected delta F/F using subtraction or normalization
        CaTrace_raw = []; % raw intensity
        CaTransients = {};
        behavTrial = [];
    end
    
%     properties (Dependent = true, SetAccess = private)
%         CaTransients = {}; % each entry is a multi-entry struct for an ROI
%     end
%     
    methods (Access = public)
        function obj = CaImageTrials(CaTrials,trialInds)
            if nargin~=0
                if nargin<2
                    n = length(CaTrials);
                    trialInds = 1:n;
                else
                    n = numel(trialInds);
                end
                obj(1,n) = CaImageTrials;
                for i = 1:n
                    trialNo = trialInds(i);
                    obj(i).FileName = CaTrials(trialNo).FileName;
                    obj(i).FileName_prefix = CaTrials(trialNo).FileName_prefix;
                    obj(i).TrialNo = CaTrials(trialNo).TrialNo;
                    obj(i).nFrames = CaTrials(trialNo).nFrames;
                    obj(i).FrameTime = CaTrials(trialNo).FrameTime;  % in ms
                    obj(i).nROIs = CaTrials(trialNo).nROIs;
                    obj(i).ROIMask = CaTrials(trialNo).ROIinfo.ROIMask;
                    obj(i).ROIPos = CaTrials(trialNo).ROIinfo.ROIpos;
                    obj(i).ROIType = CaTrials(trialNo).ROIinfo.ROIType(1:CaTrials(trialNo).nROIs);
                    
                    obj(i).DaqInfo = CaTrials(trialNo).DaqInfo; % header info of the image file
                    obj(i).nChannel = 1;
                    obj(i).nTrials = n;
                    obj(i).EphusData = [];
                    
                    if isfield(CaTrials(trialNo), 'behaveTrial')
                    obj(i).behavTrial = CaTrials(trialNo).behavTrial;
                    end
                    if isfield(CaTrials(trialNo),'WhiskerTrial')
                        obj(i).WhiskerTrial = CaTrials(trialNo).behavTrial;
                    end 
                    obj(i).SessionName = CaTrials(trialNo).SessionName;
                    obj(i).AnimalName = CaTrials(trialNo).AnimalName;
                    obj(i).ExpDate = CaTrials(trialNo).ExpDate;
                    
                    obj(i).CaTrace = CaTrials(trialNo).CaTrace; 
                    obj(i).CaTrace_orig = CaTrials(trialNo).CaTrace; % uncorrected deltaF/F
                    
                    obj(i).CaTrace_raw = CaTrials(trialNo).CaTrace_raw; % raw intensity
%                     obj(i).meanImage = CaTrials(trialNo).meanImage;
                    if isfield(CaTrials,'behavTrial')
                        obj(i).behavTrial = CaTrials(trialNo).behavTrial;
                    end
                end
            end
        end
    end
    
    methods
        
    end % methods
end
    