
clear

im(:, :, :, 1) = imread(uigetfile('*.TIF; *.tif' ,'Select fluorescence image', 'MultiSelect','on'));
mask = roipoly(im);
im = (im - mean(im(mask)))/((max(max(im))-mean(im(mask)))/255);


filename = uigetfile('*.TIF; *.tif' ,'Select brightfield image', 'MultiSelect','on');
im(:, :, :, 2) = imread(filename);
im(:, :, :, 1) = imadd(im(:, :, :, 1), im(:, :, :, 2));

imwrite(im, [filename(1:5), ' DIC cell finder.gif'],  'DelayTime', 0.4,'LoopCount',inf)

disp('cell finder.gif written');

%merge(:, :, :, 1) = imadd(im(:, :, :, 1), im(:, :, :, 2));