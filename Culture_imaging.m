function  [integrated_image, timecourse, soma, df_frames] = Culture_imaging(filename, autodetect, shortened)
%This program calculates the delta F/F from a fluorescent imaging movie, and
%automatically or interactively lets the user select spots in the movie to analyze over time. It also
%creates an avi movie with time stamps included for presentation
%
%The program imports multi-image *.tif and *.stk files
%
%---Inputs---
%
% filename = if left empty, you will be prompted for a file.
%
% autodetect = set to 1 if you want to utilize the automatic soma detection
%       method - uses a preset threshold to find spots that are active during
%       the acquisition. Set to 0 (or leave empty) to manually select
%       spots.
%
% shortened = for importing only some of the frames. it will analzye frames
%       up to the number entered (i.e. if 200 is entered, only 200 frames
%       will be analyzed). If left empty, it will import the whole movie.
%
%---Outputs---
%
% integrated_image = an image that sums all signals across the entire
%   acquisition.
%
% timecourse = an array which displays the delta F/F signal across each
%   frame for each spot selected.
%
% soma = an array of x-y coordinates indicating the spots selected.
%
% df_frames = the deltaF/F data for each frame.
%
% C. Alex Goddard
% alex.goddard@gmail.com
% 5/2013

%% Import files,

%find currently no of open figs
figno = size(get(0,'Children'), 1);

warning('OFF')
%prompt user for file if not included in call
if exist('filename', 'var') == 0 | isempty(filename);
    % Open file
    [filename pathname] = (uigetfile('*.tif; *.stk'));
    cd(pathname);
    
end

%Shortened is a variable that controls the duration of the analysis. enter
%in a number (in sec) less than the movie duration to truncate it
if exist('shortened', 'var') == 0 | isempty(shortened);
    shortened = 0;
    
end

%this variable will enable autodetection of somata using a simplistic
%thresholding algorithm
if exist('autodetect', 'var') == 0 | isempty(autodetect);
    autodetect = 0;
end

nfo = imfinfo(filename);    %gather info on file

%find sampling rate from nfo
%q = regexp(nfo.ImageDescription, 'Exposure', 'start');
%NOT completed due to imprecise nature of encoding this value in character
%array

disp('movie loading')
%Load moviefile

%read in images, one at a time, since I can't figure out how determine the
%# of images through nfo..
x = 1;
update = 100;

tic

frames(nfo(1).Width, nfo(1).Height, 1:100) = uint16(ones);

img = tiffread2(filename, x); %open first image in file

while ~isempty(img)
    frames(:, :, x) = img.data;     %add image to array
    
    x = x+1;        %advance to next image
    
    if x > update   %give user update if takign a while to load
        disp([num2str(x), ' images loaded'])
        update = update+100;        %reset update variable
        frames(:, :, x:update) = uint16(ones); %preallocate the data array for speed
    end
    
    if x > shortened & shortened ~= 0        %stop import if user has put an end point to analysis
        break
    end
    
    %now check to see if the next image is there
    img = tiffread2(filename, x); %open file
end

toc
frameno = x-1;
frames(:, :, frameno:end) = '';     %delete "unused" frames
disp([filename, ' loaded and parsed'])

%% calculate baseline, dF/F
baseline = min(frames(:, :, :), [], 3); %find the minimal value for any given pixel throughout the entire movie
baseline = repmat(baseline, [1, 1, size(frames, 3)]);   %create an array of the baseline frames
df_frames = ((frames - baseline)./baseline);  %calculate dF/F
clear baseline


%filter the movie
parfor f = 1:size(frames, 3)
    df_frames(:, :, f) = medfilt2(df_frames(:, :, f), [3 3]);    %filter each image
end

integrated_image = sum(df_frames, 3); %creates a summed image (not including the borders that might appear, depending on the scope
integrated_image = (sum(df_frames, 3)-min(integrated_image(integrated_image > 0)))/range(integrated_image(integrated_image > 0))*255;



%% Now threshold the summed image and detect somata

%plot the integrated image
figure(figno+1), set(gcf, 'OuterPosition', [200 100 700 800], 'Name', filename); %make a nice big window
subplot(3, 2, 1:4);
image(integrated_image), hold on
set(gca, 'ytick', 0, 'xtick', 0); %Get rid of annoying axes on image

if autodetect == 1
    
    thresh_integrated_image = bwlabel(im2bw(integrated_image, 0.1), 8);    %use a 5% threshold cutoff, find connections w/ 8x8 connectivity
    rprops = regionprops(thresh_integrated_image);            %acquire data, i.e. locations, of all spots
    
    %identify spot size
    for x = 1:size(rprops, 1)
        spotarea(x)= rprops(x).Area;
    end
    
    %select the spots that are large (> median value)
    i= 1;
    for x = find(spotarea > median(spotarea))
        soma(i, 1:2) = [rprops(x).Centroid(1), rprops(x).Centroid(2)];      %identify soma coordinates
        plot(soma(i, 1), soma(i, 2), 'ow');                                 % plot a spot on image
        text(soma(i, 1)+10, soma(i, 2), num2str(i), 'Color', 'w', 'FontSize', 15, 'fontweight', 'bold')             %identify spot with a #
        %find boundary box for doing timecourse
        boundarybox{i, 1}  = floor([rprops(x).BoundingBox(1):rprops(x).BoundingBox(1)+rprops(x).BoundingBox(3)]);
        boundarybox{i, 2}   = floor([ rprops(x).BoundingBox(2):rprops(x).BoundingBox(2)+rprops(x).BoundingBox(4)]);
        leg{i} = sprintf('Spot %2.0d', i);
        i = i +1;
    end
    
else
    
    
    disp('Select cells of interest with the mouse, and press return when done');
    [x y] = ginput;
    x = round(x); y = round(y);
    soma = [x, y];
    %     disp('coordinates:');
    %     disp([x y])
    
    for i = 1:size(x, 1);
        %timecourse(i, :) = squeeze((df_frames(y(i), x(i), :)));
        plot(soma(i, 1), soma(i, 2), 'ow');
        leg{i} = sprintf('Spot %2.0d', i);
        text(x(i)+10, y(i), num2str(i), 'Color', 'w', 'fontsize', 15, 'fontweight', 'bold');
        boundarybox{i, 1}  = floor([x(i)-2:x(i)+2]);
        boundarybox{i, 2}   = floor([y(i)-2:y(i)+2]);
        
    end
end



all_ev = 0;
all_dur = 0;
all_peak = 0;
all_ibi = 0;
k = 1;
figure(figno+2);  set(gcf, 'OuterPosition', [500 100 600 900], 'Name', filename); 
subplot(4, 2, 1:2); hold on
for i = 1:size(soma, 1) %for each detected soma
    for j = 1:size(df_frames, 3)    %at each time point
        timecourse(i, j) = 100*mean(mean(df_frames( boundarybox{i,2}, boundarybox{i,1}, j)));       %note that x and y are reversed in clearly obvious matlab hilarity
    end
    
    %calculte a cutoff by using the mean and std from lowest 5th percentile
    %of the signal
    sortedtc = sort(timecourse(i, :)); %sort the trace by ascending values
    sortedtc = sortedtc(find(sortedtc > 0));    %find all nonzero values
    stcl = ceil(length(sortedtc)/20);   %select the 5% (nonzero) percentile
    cutoff(i) = std(sortedtc(1:stcl))+mean(sortedtc(1:stcl));
    t_crossing{i} = (find(timecourse(i, :) > cutoff(i)));
    ev_st{i} = t_crossing{i}(diff([0 t_crossing{i}]) > 5);
    
  
    for j = 1:size(ev_st{i}, 2) %capture each event
       % disp(i)
        if ev_st{i}(j)+199 < frameno
            event(k, 1:200) = timecourse(i, ev_st{i}(j):ev_st{i}(j)+199);    %capture the event
            evend =  find(event(k, :)<cutoff(i), 1);  %find the first time it dips below threshold; this is the duration
            if ~isempty(evend)
                ev_dur{i}(j) =evend;
            else
                ev_dur{i}(j) = 200;
            end
            ev_peak{i}(j) = max(event(k, :));   %find peak value
            k = k+1;
        end
    end
    plot(ev_st{i}, i, 'ok') % raster plot 
    interburst_interval{i} = diff([0 ev_st{i}]);
    
    
    all_ev = [all_ev ev_st{i}];
    all_dur = [all_dur ev_dur{i}];
    all_peak = [all_peak ev_peak{i}];
    all_ibi = [all_ibi interburst_interval{i}];
    
    mean_duration(i) = mean(ev_dur{i});
    mean_peak(i) = mean(ev_peak{i});
    mean_ibi(i) = mean(interburst_interval{i});
    
end
%label raster plot 
xlabel('time (frame #)'); ylabel('cell'); xlim([0 max(all_ev)+50]); ylim([0 i+2]);
title('Raster of events by cell')


%plot histogram of durations
subplot(4, 2, 3:4);
xax = [0:5:200]; bar(xax, histc(all_dur, xax));
xlabel('duration of events (frames)'); ylabel('# of events'); xlim([-5 max(xax)]); 
title('Event duration histogram')


%plot histogram of durations
subplot(4, 2, 5:6);
xax = [0:5:100]; bar(xax, hist(all_peak, xax));
xlabel('peak dF/F of events'); ylabel('# of events'); xlim([-5 max(xax)]); 
title('Event peak fluorescence histogram')

%plot histogram of durations
subplot(4, 2, 7:8);
xax = [0:max(all_ibi)/20:max(all_ibi)]; bar(xax, hist(all_ibi, xax));   %make a variable histogram binning
xlabel('interburst interval (frames)'); ylabel('# of events'); xlim([-5 max(xax)]); 
title('interburst interval histogram (within cell, not between cells)')





%plot a PSTH of all events
figure(figno+1), subplot(3, 2, 5:6); xax = [0:frameno]; bar(xax, hist((sort(all_ev)), xax));
xlabel('time (frame #)'); ylabel('# of active cells'); xlim([0 frameno+10]);

disp('The following means were constructed by cell, not from the distribution of events')
disp(sprintf('Mean event duration: %3.1f +/- %3.1f frames ', mean(mean_duration), std(mean_duration)))
disp(sprintf('Mean peak fluorescence: %3.1f +/- %3.1f  ', mean(mean_peak), std(mean_peak)))
disp(sprintf('Mean interburst interval: %3.1f +/- %3.1f frames ', mean(mean_ibi), std(mean_ibi)))


%plot autocorrelation of synchrony of events

synchronicity = diff(sort(all_ev));
lags = [-100:100];
cross_correlation = xcorr(synchronicity, max(lags), 'coeff');
figure(figno+4), plot(lags, cross_correlation);
xlabel('lags (in frames)');


display = 0;
if display == 1
    figure(figno+4), set(gcf, 'OuterPosition', [700 100 1200 800], 'Name', filename); %make a nice big window
    for f = 1:size(frames, 3)
        imshow(df_frames(:, :, f), []); text(450, 25, num2str(f), 'Color', 'w', 'FontSize', 15); pause(0.01);
    end
end
zoom on



%% plot timecourse and label

figure(figno+3), plot(timecourse');
xlabel('time (in frames)'), ylabel('delta F/F'), title('Timecourse of fluorescence change at selected spots');
legend(leg)

set(gcf,'Units','inches','PaperUnits','inches');
set(gcf,'PaperPosition',[ .5 .5 7.5 10 ]);
saveas (gcf,[filename, ' dF analysis.jpg'], 'jpg')

save([filename, '.mat'], 'soma', 'timecourse', 'ev_st', 'ev_dur', 'ev_peak', 'event', 'integrated_image', 'cross_correlation');

%% generate avi movie

go = input('Press enter to continue - will generate avi file, or type n to stop -->   ', 's');

if isempty(go)
    figure
    damov = VideoWriter(['df ', filename]);
    damov.FrameRate = 5;
    
    open(damov);
    for f = 1:size(frames, 3)
        imshow(df_frames(:, :, f), []); text(450, 25, num2str(f), 'Color', 'w', 'FontSize', 15);
        currFrame = getframe;
        writeVideo(damov,currFrame);
        %dfmov(f) = im2frame((imfm(:, :, f)), jet);
    end
    %disp(['writing df ', filename]);
    close(damov)
    close
end

%movie2avi(dfmov, , 'fps', 4);
disp('fin')



