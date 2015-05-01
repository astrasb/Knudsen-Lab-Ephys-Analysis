%------------------------------------------------------------------------------------------------
% Demo to illustrate simple blob detection, measurement, and filtering.
% Requires the Image Processing Toolbox (IPT) because it demonstates some functions
% supplied by that toolbox, plus it uses the "coins" demo image supplied with that toolbox.
% If you have the IPT (you can check by typing ver on the command line), you should be able to
% run this demo code simply by copying and pasting this code into a new editor window,
% and then clicking the green "run" triangle on the toolbar.
% Running time = 7.5 seconds the first run and 2.5 seconds on subsequent runs.
% A similar Mathworks demo:
% http://www.mathworks.com/products/image/demos.html?file=/products/demos/shipping/images/ipexprops.html
% Code written and posted by ImageAnalyst, July 2009.
%------------------------------------------------------------------------------------------------

% Startup code.
tic; % Start timer.
clc; % Clear command window.
clear all; % Get rid of variables from prior run of this m-file.
disp('Running BlobsDemo.m...'); % Message sent to command window.
workspace; % Show panel with all the variables.

% Read in standard MATLAB demo image
originalImage = imread('coins.png'); 
subplot(3, 3, 1); imagesc(originalImage); colormap(gray(256)); 
caption = sprintf('Original "coins" image showing\n6 nickels (the larger coins) and 4 dimes (the smaller coins).');
title(caption); 
axis square; % Make sure image is not artificially stretched because of screen's aspect ratio.
% Maximize the figure window.
set(gcf, 'Position', get(0, 'ScreenSize'));

% Just for fun, let's get its histogram.
[pixelCount grayLevels] = imhist(originalImage);
subplot(3, 3, 2); 
bar(pixelCount); title('Histogram of original image');
xlim([0 grayLevels(end)]); % Scale x axis manually.

% Threshold the image to get a binary image (only 0's and 1's) of class "logical."
% Method #1: using im2bw()
%   normalizedThresholdValue = 0.4; % In range 0 to 1.
%   thresholdValue = normalizedThresholdValue * max(max(originalImage)); % Gray Levels.
%   binaryImage = im2bw(originalImage, normalizedThresholdValue);       % One way to threshold to binary
% Method #2: using a logical operation.
  thresholdValue = 100;
  binaryImage = originalImage > thresholdValue; % Bright objects will be the chosen if you use >.
%   binaryImage = originalImage < thresholdValue; % Dark objects will be the chosen if you use <.

% Do a "hole fill" to get rid of any background pixels inside the blobs.
binaryImage = imfill(binaryImage, 'holes');

% Show the threshold as a vertical red bar on the histogram.
hold on;
maxYValue = ylim;
hStemLines = stem(thresholdValue, maxYValue(2), 'r');
children = get(hStemLines, 'children');
set(children(2),'visible', 'off');
% Place a text label on the bar chart showing the threshold.
annotationText = sprintf('Thresholded at %d gray levels', thresholdValue);
% For text(), the x and y need to be of the data class "double" so let's cast both to double.
text(double(thresholdValue + 5), double(0.5 * maxYValue(2)), annotationText, 'FontSize', 10, 'Color', [0 .5 0]);
text(double(thresholdValue - 70), double(0.94 * maxYValue(2)), 'Background', 'FontSize', 10, 'Color', [0 0 .5]);
text(double(thresholdValue + 50), double(0.94 * maxYValue(2)), 'Foreground', 'FontSize', 10, 'Color', [0 0 .5]);


% Display the binary image.
subplot(3, 3, 3); imagesc(binaryImage); colormap(gray(256)); title('Binary Image, obtained by thresholding'); axis square;

labeledImage = bwlabel(binaryImage, 8);     % Label each blob so we can make measurements of it
coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels

subplot(3, 3, 4); imagesc(labeledImage); title('Labeled Image, from bwlabel()'); axis square;
subplot(3, 3, 5); imagesc(coloredLabels); title('Pseudo colored labels, from label2rgb()'); axis square;

% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
blobMeasurements = regionprops(labeledImage, originalImage, 'all');   
numberOfBlobs = size(blobMeasurements, 1);

% bwboundaries returns a cell array, where each cell
% contains the row/column coordinates for an object in the image.
% Plot the borders of all the coins on the original
% grayscale image using the coordinates returned by bwboundaries.
subplot(3, 3, 6); imagesc(originalImage); title('Outlines, from bwboundaries()'); axis square;
hold on;
boundaries = bwboundaries(binaryImage);	
for k = 1 : numberOfBlobs
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end
hold off;

fprintf(1,'Blob #      Mean Intensity  Area     Perimeter  Centroid\n');
for k = 1 : numberOfBlobs           % Loop through all blobs.
	% Find the mean of each blob.  (R2008a has a better way where you can pass the original image
	% directly into regionprops.  The way below works for all versions including earlier versions.)
    thisBlobsPixels = blobMeasurements(k).PixelIdxList;  % Get list of pixels in current blob.
    meanGL = mean(originalImage(thisBlobsPixels)); % Find mean intensity (in original image!)
	meanGL2008a = blobMeasurements(k).MeanIntensity; % Mean again, but only for version >= R2008a
	
	blobArea = blobMeasurements(k).Area;		% Get area.
	blobPerimeter = blobMeasurements(k).Perimeter;		% Get perimeter.
	blobCentroid = blobMeasurements(k).Centroid;		% Get centroid.
    fprintf(1,'#%d %18.1f %11.1f %8.1f %8.1f %8.1f\n', k, meanGL, blobArea, blobPerimeter, blobCentroid);
end

% Now I'll demonstrate how to select certain blobs based using the ismember function.
% Let's say that we wanted to find only those blobs 
% with an intensity between 150 and 220 and an area less than 2000 pixels.
% This would give us the three brightest dimes (the smaller coin type).
allBlobIntensities = [blobMeasurements.MeanIntensity];
allBlobAreas = [blobMeasurements.Area];
% Get a list of the blobs that meet our criteria and we need to keep. 
allowableIntensityIndexes = (allBlobIntensities > 150) & (allBlobIntensities < 220);
allowableAreaIndexes = allBlobAreas < 2000; % Take the small objects.
keeperIndexes = find(allowableIntensityIndexes & allowableAreaIndexes); 
% Extract only those blobs that meet our criteria, and 
% eliminate those blobs that don't meet our criteria. 
% Note how we use ismember() to do this.
keeperBlobsImage = ismember(labeledImage, keeperIndexes); 
% Re-label with only the keeper blobs kept.
labeledDimeImage = bwlabel(keeperBlobsImage, 8);     % Label each blob so we can make measurements of it
% Now we're done.  We have a labeled image of blobs that meet our specified criteria.
subplot(3, 3, 7); 
imshow(labeledDimeImage, []);
axis square;
title('"Keeper" blobs (3 brightest dimes in a re-labeled image)');

% Now use the keeper blob as a mask on the original image.
% This will let us display the original image in the regions of the keeper blobs.
maskedImageDime = originalImage; % Simply a copy at first.
maskedImageDime(~keeperBlobsImage) = 0;  % Set all non-keeper pixels to zero.
subplot(3, 3, 8); 
imshow(maskedImageDime);
axis square;
title('Only the 3 brightest dimes from the original image');

% Now let's get the nickels (the larger coin type)
keeperIndexes = find(allBlobAreas > 2000);  % Take the larger objects.
% Note how we use ismember to select the blobs that meet our criteria.
nickelBinaryImage = ismember(labeledImage, keeperIndexes); 
maskedImageNickel = originalImage; % Simply a copy at first.
maskedImageNickel(~nickelBinaryImage) = 0;  % Set all non-nickel pixels to zero.
subplot(3, 3, 9); 
imshow(maskedImageNickel, []);
axis square;
title('Only the nickels from the original image');

elapsedTime = toc;
% Alert user that the demo is done and give them the option to save an image.
message = sprintf('Finished running BlobsDemo.m.\n\nElapsed time = %.2f seconds.', elapsedTime);
message = sprintf('%s\n\nCheck out the figure window for the images.\nCheck out the command window for the numerical results.', message);
message = sprintf('%s\n\nDo you want to save the pseudo-colored image?', message);
reply = questdlg(message, 'Done. Save image?', 'Yes', 'No', 'No');
% Note: reply will = '' for Upper right X, 'Yes' for Yes, and 'No' for No.
if strcmpi(reply, 'Yes')
	% Ask user for a filename.
	FilterSpec = {'*.tif', 'TIFF images (*.tif)'; '*.*', 'All Files (*.*)'};
	DialogTitle = 'Save image file name';
	% Get the default filename.  Make sure it's in the folder where this m-file lives.
	% (If they run this file but the cd is another folder then pwd will show that folder, not this one.
	thisFile = mfilename('fullpath');
	[thisFolder, baseFileName, ext, version] = fileparts(thisFile);
	DefaultName = sprintf('%s/%s.tif', thisFolder, baseFileName);
	[fileName, specifiedFolder] = uiputfile(FilterSpec, DialogTitle, DefaultName);
	% Parse what they actually specified.
	[folder, baseFileName, ext, version] = fileparts(fileName);
	% Create the full filename, making sure it has a tif filename.
	fullImageFileName = fullfile(specifiedFolder, [baseFileName '.tif']);
	% Save the labeled image as a tif image.
	imwrite(uint8(coloredLabels), fullImageFileName);
	% Just for fun, read image back into the imtool utility to demonstrate that tool.
	tifimage = imread(fullImageFileName);
	imtool(tifimage, []);
end
	
