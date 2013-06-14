function padding = get_im_padding(min1,max1,min2,max2)

% min1, maximum up shift pixels
% max1, maximum down shift pixels
% min2, maximum left shift pixels
% max2, maximum right shif pixels

if min1 >=0
    top_pad = 0;
else
    top_pad = abs(min1);
end
if max1 <= 0
    bottom_pad = 0;
else
    bottom_pad = max1;
end

if min2 >= 0
    left_pad = 0;
else
    left_pad = abs(min2);
end
if max2 <= 0
    right_pad = 0;
else
    right_pad = max2;
end
padding = [top_pad, bottom_pad, left_pad, right_pad];