function y_den = Ca_waveden(y, wname, level)

if ~exist('wname','var')
    wname='db2';
end
if ~exist('level', 'var')
    level=3;
end
[C,L]=wavedec(y,level,wname);

first = cumsum(L)+1; first = first(end-2:-1:1);
longs = L(end-1:-1:2);
last = first+longs-1;

Cdn = C;

for i= 1:level
    cD{i} = detcoef(C,L,i);
    th(i) = std(cD{i})*sqrt(2*log(length(cD{i})));
    cD{i}(abs(cD{i})< th(i))=0;
    Cdn(first(i):last(i))=cD{i};
end

y_den = waverec(Cdn,L,wname);