for i = 1:length(CaObj)
    CaStruct(i) = struct(CaObj(i));
end;
save('-v7.3',[CaStruct(1).FileName_prefix 'CaStruct'], 'CaStruct');
%%
P = fieldnames(CaStruct(1));
for i = 1:length(CaStruct)
    % CaStruct(i) = struct(CaObj(i));
    for j = 1:length(P)
        eval(['CaObj(' num2str(i) ').' P{j} '=CaStruct(' num2str(i) ').' P{j}]);
    end
end;
    