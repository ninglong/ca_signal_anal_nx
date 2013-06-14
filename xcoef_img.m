function xcoef = xcoef_img(img, ROImask)

if nargin<2
    ROImask = true(size(img,1),size(img,2));
end
for i = 2:size(img,3)
    a = img(:,:,i-1);
    b = img(:,:,i);
    R = corrcoef(double(a(ROImask)),double(b(ROImask)));
    xcoef(i-1) = R(1,2);
end
% figure; plot(xcoef);
