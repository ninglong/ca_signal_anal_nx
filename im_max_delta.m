function [im_out, fig] = im_max_delta(im, show_img, clim, hfig)

mean_im = mean(im,3);
im = im_mov_avg(im,5);
max_im = double(max(im,[],3));
im_out = max_im - mean_im;

if show_img ==1
    if nargin < 4
        fig = figure('Name','max Delta Image','Position',[960   40   512   512]);
    else
        fig = hfig;
    end
    
    imagesc(im_out);
    colormap(gray);
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    axis square
    if ~isempty(clim)
        set(gca,'CLim',clim);
    end
end