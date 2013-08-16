function ICAComp = run_ICA(Data, param)

S = param{1};
V = param{2};

SVDCompVec = 1:param{3};
SVDComponentNum = length(SVDCompVec);
SVDBase = Data*...
  (S(SVDCompVec,SVDCompVec)*...
  V(:,SVDCompVec)')';

%% ICA
IComponentNum = param{4};
[A, W]=fastica(SVDBase','numOfIC',IComponentNum);
ICAComp = W*...
  (V(:,SVDCompVec)*S(SVDCompVec,SVDCompVec))';