function shift = batch_dft_reg(targetImage, source_filenames, padding_flag,save_path)

% Using dftregistration.m to register imaging data from multiple trials.
% 
% If padding_flag=0, the output images are of the same size as the original
% source_image. The pixels shifted outside the image size are cut off. This
% is faster, because the translation can be done in the same loop as of
% registration. This option is perferred for Ca imaging. 
%
% If padding_flag=1, the output images are padded such that the image size accomadates the
% maximum shift of pixels accross all files. But the output image size
% is constrained such that it does not exceed 10% more than the original
% image size. This has too be done in a loop after the loop where all the 
% shifts to be computed by registration of all files.
% 
% The number of pixels of each frame to be shifted is computed by the
% algorithm in dftregistration.m
% The actual padding and shifting of the images is implemented by
% ImageTranslation_nx.m

% Output: shift, 2-by-nframes-by-ntrials
%

% - NX, 7/2009

if nargin < 4
    save_path = [pwd filesep 'dft_reg'];
end
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

disp('registering images for the whole session ...');
h_wait = waitbar(0, 'Registering trial 0 to the target image ...');

[pathstr, Name] = fileparts(source_filenames{1});
file_basename = Name(1:end-3);
for i = 1:length(source_filenames)
    waitbar(i/length(source_filenames), h_wait, ...
        ['Registering trial ' num2str(i) ' to the target image ...']);
    [pathstr,fname] = fileparts(source_filenames{i});
    [src_img header] = imread_multi(source_filenames{i}, 'green');
    for j=1:size(src_img,3);
        output(:,j) = dftregistration(fft2(double(targetImage)),fft2(double(src_img(:,:,j))),1);
    end
    shift(:,:,i) = output(3:4,:);
    
    if padding_flag == 0
        im_info = imfinfo(source_filenames{i});
        if isfield(im_info(1),'ImageDescription')
            im_describ = im_info(1).ImageDescription; % to be put back to the header
        else
            im_describ = '';
        end
        % Change channel number if necessary, the out put should be single channel
        % data
        if ~isempty(strfind(im_describ,'numberOfChannelsSave=2'))
            im_describ = strrep(im_describ, 'numberOfChannelsSave=2','numberOfChannelsSave=1');
        end;
        if ~isempty(strfind(im_describ, 'saveDuringAcquisition=1'))&& ~isempty(strfind(im_describ, 'numberOfChannelsAcquire=2'))
            im_describ = strrep(im_describ, 'numberOfChannelsAcquire=2','numberOfChannelsAcquire=1');
        end
        
        save_name = [file_basename 'dftReg_' fname(end-2:end) '.tif'];
        
        if ~exist(save_path, 'dir')
            mkdir(save_path);
        end
        ImageTranslation_nx(src_img,shift(:,:,i),[0 0 0 0],1,save_path,save_name,im_describ);
    end
end
close(h_wait);
disp(['Batch dft_registration for files ' file_basename ' is completed!']);
% padding the sorce image with maximum number of pixels to be shifted
% in the whole session. Trials with shift larger than 10% of the
% image size were exluded.
row_shift = squeeze(shift(1,:,:));

max_row_up_shift_in_trials = min(row_shift,[],1);
max_row_up_shift_in_trials(max_row_up_shift_in_trials < -size(src_img,1)*0.1)=0;
min1 = min(max_row_up_shift_in_trials);

max_row_down_shift_in_trials = max(row_shift,[],1);
max_row_down_shift_in_trials(max_row_down_shift_in_trials > size(src_img,1)*0.1) = 0;
max1 = max(max_row_down_shift_in_trials);

col_shift = squeeze(shift(2,:,:));

max_col_left_shift_in_trials = min(col_shift,[],1);
max_col_left_shift_in_trials(max_col_left_shift_in_trials < -size(src_img,2)*0.1) = 0;
min2 = min(max_col_left_shift_in_trials);

max_col_right_shift_in_trials = max(col_shift,[],1);
max_col_right_shift_in_trials(max_col_right_shift_in_trials > size(src_img,2)*0.1) = 0;
max2 = max(max_col_right_shift_in_trials);

padding = get_im_padding(min1,max1,min2,max2);

if padding_flag ==1
    h_wait = waitbar(0, 'Shifting and saving images in trial 0 ...');
    for i = 1:length(source_filenames)
        [pathstr,fname] = fileparts(source_filenames{i});
        [src_img header] = imread_multi(source_filenames{i}, 'green');
        im_info = imfinfo(source_filenames{i});
        if isfield(im_info(1),'ImageDescription')
            im_describ = im_info(1).ImageDescription; % to be put back to the header
        else
            im_describ = '';
        end
        % Change channel number if necessary, the out put should be single channel
        % data
        if ~isempty(strfind(im_describ,'numberOfChannelsSave=2'))
            im_describ = strrep(im_describ, 'numberOfChannelsSave=2','numberOfChannelsSave=1');
        end;
        
        save_name = [file_basename 'dftReg_' fname(end-2:end) '.tif'];
        
        ImageTranslation_nx(src_img,shift(:,:,i),padding,1,save_path,save_name,im_describ);
        waitbar(i/length(source_filenames), h_wait, ...
            ['Shifting and saving images in trial' num2str(i) ' ...']);
    end
    close(h_wait);
end
% save([save_path filesep file_basename '[dftShift].mat'], 'shift');

