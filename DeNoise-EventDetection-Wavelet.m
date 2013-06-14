%%
wname='db2';
y=reshape(traces',1,[]);
[C,L]=wavedec(y,2,wname);
[cD1,cD2]=detcoef(C,L,[1,2]);

th1=std(cD1)*4.5;
th2=std(cD2(cD2<2*std(cD2)))*sqrt(2*log(length(cD2)));

first = cumsum(L)+1; first = first(end-2:-1:1);
longs = L(end-1:-1:2);
last = first+longs-1;

cD1(abs(cD1)< th1)=0;
cD2(abs(cD2)<th2)=0;
Cdn = C;
Cdn(first(1):last(1))=cD1;
Cdn(first(2):last(2))=cD2;

ydn = waverec(Cdn,L,wname);

%A3=wrcoef('a',C,L,wname,3);
%ydn = A3;

tracesDen = reshape(ydn,size(traces'))';
sigma= std(ydn(ydn<2*std(ydn)));%std(ydn(ydn<0)); % SD for noise
th_factor= 4.5; %sqrt(2*log(length(ydn)));
th=sigma*th_factor;
dth=sigma;


%%
close all
scrsz = get(0, 'ScreenSize');
figW=scrsz(3)/4;
figH=scrsz(4)-500;
j=0;
count=0;
chunk=10;
for i=1:size(traces,1)
    eventt{i}=CaEventDetector(smooth(tracesDen(i,:),3),th,dth);
    count=count+1;
    if count>=chunk || i==size(traces,1)
        j=j+1;
        h_fig(j) = figure('Position', [100*j, j*20, figW, figH], 'Color', 'w');
        traceArray = traces(i-count+1:i,:);
        Ca_plot_trace_array(traceArray, [], h_fig(j), 1, eventt(i-count+1:i));
        title(['Trial' num2str(i-count+1) ' to ' num2str(i)],'FontSize',18);
        count=0;
        % keyboard;
    end
end    
        