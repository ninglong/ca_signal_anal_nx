function new_img = im_transl(img, shift)
% Take the output from dftregistration.m and translate the image
% acoordingly. Creating a larger image accomadating the translation, no
% pixel cut off.

% shift, a 2xnFrame array of net_row_shift and net_col_shift 

% - NX 7/2009

top_pad = min(shift(1,:));
bottom_pad = max(shift(1,:));
left_pad = min(shift(2,:));
right_pad = max(shift(2,:));

if top_pad >=0
    top_pad = 0;
end
top_pad = abs(top_pad);

if bottom_pad <= 0
    bottom_pad = 0;
end

if left_pad >= 0
    left_pad = 0;
end
left_pad = abs(left_pad);

if right_pad <= 0
    right_pad = 0;
end

new_img = zeros(size(img) + [top_pad+bottom_pad, left_pad+right_pad, 0]);

ind_row = top_pad+1 : top_pad+size(img,1);
ind_col = left_pad+1 : left_pad+size(img,2);
for i = 1:size(img,3)
    new_img(ind_row+shift(1,i), ind_col+shift(2,i), i) = img(:,:,i);
end


