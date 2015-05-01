function [out] = image_stats(filename)
%This function displays the histogram of pixel values in a given image, as
%well as a sorted distribution of those values. It can also compare the
%histograms/distributions of two separate images. To
%compare two images, call function as follows:
%image_stats(['filename1.tif';'filename2.tif'])
%
%alex.goddard@gmail.com - 11.09.12

if exist('filename') == 0 || isempty('filename');
    % Open file
    [filename fpath] = (uigetfile('*.tif'));      %acquire filename and path
    %error handling of file open
    if filename == 0;
        disp ('-------------No file opened-------------');
        return
    else
        
        cd(fpath)
        
    end
    
    filepath = [fpath, filename];
end

figure,
subplot(1,2,1);hold on
subplot(1,2,2);hold on

xaxis=1:255;
for f = 1:size(filename,1)
    img=imread(filename(f,:));
    limg(f,:) = reshape(img, 1, size(img, 1)*size(img, 2));
    h(f,:) =histc(limg(f,:), xaxis);
end
subplot(1,2,1); plot(h', 'linewidth', 1); xlim([0 260]); title('histogram'); xlabel('pixel intensity'); ylabel('# of pixels');
legend(filename)

subplot(1,2,2); plot(sort(double(limg)')/255); xlim([0 size(limg, 2)]); title('sorted values'); xlabel('pixel #'); ylabel('cumulative probability')
legend(filename)


return