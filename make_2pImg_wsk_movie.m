%%
imgFile2p = CaObj(1).FileName;
t_off = 5;
frameTime = 0.0742; % CaObj(1).FrameTime/1000;
h_fig = figure('Position', [138   431   327   535]);
ha(1) = axes('Position', [0.01 0.39 0.98 0.6]); % 320x320
ha(2) = axes('Position', [0.01 0.01 0.98 0.38]); % 320*200 

Img2p = imread_multi(imgFile2p,'g');
ts2p = (1:size(Img2p,3)).*frameTime;
fr2p = find(ts2p<=t_off);
count = 0;
for i = fr2p
    t1 = (i-1)*frameTime;
    t2 = i*frameTime;
    frWsk = [round(t1/0.002) round(t2/0.002)];
    wskImg = get_seq_frames(wskfile, frWsk, 5);
    axes(ha(1)); colormap(gray);
    imagesc(Img2p(:,:,i),[0 300]); set(gca,'visible', 'off'); 
    for j = 1:size(wskImg,3)
        axes(ha(2)); set(gca,'visible','off');
        imshow(wskImg(:,:,j),[]);
        count = count + 1;
        F(count) = getframe(gcf);
    end
end
% movie2avi(F,imgFile2p,'compression','none','fps',15);


  