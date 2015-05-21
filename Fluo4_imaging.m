function  [integrated_image, timecourse, soma, df_frames] = Fluo4_imaging(filename, shortened)
%This program calculates the delta F/F from a fluorescent imaging movie, and
%automatically or interactively lets the user select spots in the movie to analyze over time. It also
%creates an avi movie with time stamps included for presentation

%It was based off of a program named calcium_imaging.m, written by C. Alex
%Goddard in 5/2013. This current version is designed for greater image
%loading speed, to deal with larger datasets.

%---Inputs---
%
% filename = if left empty, you will be prompted for a file.
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

%Astra S. Bryant
%5/2015

%% Import Files
warning('OFF')
%prompt user for file if not included in call
if exist('filename', 'var') == 0 | isempty(filename);
    % Open file
    [filename pathname] = (uigetfile('*.tif'));
    cd(pathname);
    
end
figno = size(get(0,'Children'), 1);


%Shortened is a variable that controls the duration of the analysis. enter
%in a number (in frames) less than the movie duration to truncate it
if exist('shortened', 'var') == 0 | isempty(shortened);
    shortened = 3300;
end

nfo = imfinfo(filename);    %gather info on file
imgno = numel(nfo); %number of images in the movie
 %legacy from alex's code.

if imgno > shortened & shortened ~= 0 %stopping import if user has asked for a shortened duration
    imgno = shortened;
end

frameno=imgno;
frames(nfo(1).Height, nfo(1).Width, 1:imgno) = double(ones); %preallocate 3D data array for speed

disp('movie loading')
% Load tiff image stack
tic
for x = 1:imgno
    frames(:, :, x) = double(imread(filename, x));
end
toc

disp([filename, ' loaded and parsed'])

%filter the movie - median filte
parfor f = 1:size(frames, 3)
    temp(:, :, f) = medfilt2(frames(:, :, f), [3 3]);    %filter each image - 3 pixels in m and n direction
end

%filter the movie with a gaussian filter
%temp = Gaussian_Filter_streamlined(frames_unfilt, 3, 0.5);


frames_unfilt=frames;
clear frames;

mins=min(temp(:,:,:),[],3);
indmin=find(mins==0);
disp([num2str(numel(indmin)),' minima equal to zero after filtering']);

%trim edges of the filtered movie, set at 2 pixels from all sides
%(because medfilt2 pads image with zeros on the edges, leading to disortion
%at [m n]/2 near edges.
%, may need adjusting...
trim = 2;
frames=temp(1+trim:(nfo(1).Height-trim),1+trim:(nfo(1).Width-trim),:);
clear temp

mins=min(frames(:,:,:),[],3);
indmin=find(mins==0);
disp([num2str(numel(indmin)),' minima equal to zero after trimming']);

%frames(:,:,4129:end)=[];

%% Calculate min-subtracted dF/F
if ~isempty(indmin)
    temp=frames;
    temp(~temp)=inf; %set all remaining zero values to infinity - this will exclude them from min on the next line (find non-zero minimum values)
    
    %baseline = min(temp(:,:,:),[],3); %find the minimal non-zero value for any given pixel throughout the entire movie
    temp=sort(temp,3); %sort all pixels in ascending rank
    baseline = mean(temp(:,:,1:round(imgno*.01)),3); %average of lowest 5% of values at each pixel
    baseline = repmat(baseline, [1,1,size(frames,3)]); %create an array of minimal pixels
    clear temp
else
    % no zero values, so can just find minimal value of frames
    %baseline = min(frames(:,:,:), [], 3); %find the minimal value for any given pixel throughout the entire movie
    temp=sort(frames,3); %sort all pixels in ascending rank
    baseline = mean(temp(:,:,1:round(imgno*.01)),3); %average of lowest 5% of values at each pixes
    baseline = repmat(baseline, [1,1,size(frames,3)]); %create an array of minimal pixels
    clear temp
end

df_frames = (frames-baseline)./baseline; %calculate min-subtracted signal.


%% Now threshold the summed image and detect somata
integrated_image=sum((frames-baseline),3);

%plot the integrated image
figure(figno+1), set(gcf, 'OuterPosition', [200 100 700 800], 'Name', filename); %make a nice big window
subplot(3, 2, 1:4);
imagesc(integrated_image), hold on
set(gca, 'ytick', 0, 'xtick', 0); %Get rid of annoying axes on image

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
    text(x(i)+1, y(i), num2str(i), 'Color', 'w', 'fontsize', 15, 'fontweight', 'bold');
    boundarybox{i, 1}  = floor([x(i)-2:x(i)+2]);
    boundarybox{i, 2}   = floor([y(i)-2:y(i)+2]);
    %Add part here that will adjust boundary box so it fits the size of the
    %image.
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
    
    
    smooth_timecourse(i,:)=smoothME(timecourse(i,:),5,0.1); %smooth the trace with a 2.3 ssecond window this may be overfitting to this data..
    
    %runmean=smooth(smooth_timecourse(i,:),.2,'loess');
    [runperc(i,:), runstd(i,:)]=running_percentile(smooth_timecourse(i,:),ceil(length(smooth_timecourse(i,:))*.2),5);
    corrected_timecourse(i,:)=smooth_timecourse(i,:)-runperc(i,:);
    sortedtc=sort(corrected_timecourse(i,:)); %sort the baseline-corrected trace by ascending values
    stcl = ceil(length(sortedtc)/5);   %select the 20% percentile
    cutoff(i)= std(sortedtc(1:stcl))*10+mean(sortedtc(1:stcl));
    t_crossing{i} = (find(corrected_timecourse(i, :) > cutoff(i)));
    
    %cutoff(i,:)=runstd*2+runperc;
    %t_crossing{i} = (find(smooth_timecourse(i,:)>cutoff(i,:)));
    if ~isempty(t_crossing{i})
        ev_st{i}=t_crossing{i}(diff([0 t_crossing{i}])>3);
    
    %Figure out how to add the first activity, if the cell starts out above
    %threshold, or if it goes up faster than 5 frames from start
        if t_crossing{i}(1)<5
            ev_st{i}= [t_crossing{i}(1) ev_st{i}];
        end
    
    %calculte a cutoff by using the mean and 2 times std from lowest 50th percentile
    %of the signal
    %     smooth_timecourse(i,:)=smooth(timecourse(i,:),3); %smooth the trace with a 600 nssecond window
    %     sortedtc = sort(smooth_timecourse(i, :)); %sort the trace by ascending values
    %     sortedtc = sortedtc(find(sortedtc > 0));    %find all nonzero values
    %     stcl = ceil(length(sortedtc)/2);   %select the 5% (nonzero) percentile
    %     cutoff(i) = std(sortedtc(1:stcl))+mean(sortedtc(1:stcl));
    %cutoff(i) = std(sortedtc(1:end))+mean(sortedtc(1:end));
    %t_crossing{i} = (find(smooth_timecourse(i, :) > cutoff(i)));
    %[peaks, times] = findpeaks(smooth_timecourse(i,:),'minpeakheight',cutoff(i), 'minpeakdistance',10);
    
    %ev_st{i} = t_crossing{i}(diff([0 t_crossing{i}]) > 2);%used to be 5 - figure out what this means... I think it's only count something as an event if it didn't cross threshold after 2 (or 5) frames.
    
    
    for j = 1:size(ev_st{i}, 2) %capture each event
        % disp(i)
        if ev_st{i}(j)+199 < imgno
            event(k, 1:200) = corrected_timecourse(i, ev_st{i}(j):ev_st{i}(j)+199);    %capture the event
            %something odd is happening on the next time of code. figure
            %out what it is...
            
            evend =  find(event(k, :)<cutoff(i), 1);  %find the first time it dips below threshold; this is the duration
            if ~isempty(evend)
                ev_dur{i}(j) =evend;
            else
                temp=corrected_timecourse(i, ev_st{i}(j):end);
                
                tempd=find(temp<cutoff(i),1); %find the first time it dips below threshold; this is the duration
                ev_dur{i}(j) = tempd;
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
end
%label raster plot
xlabel('time (frame #)'); ylabel('cell'); xlim([0 max(all_ev)+50]); ylim([0 i+2]);
set(gca,'YTick',[1:1:i]);
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
figure(figno+1), subplot(3, 2, 5:6); xax = [0:10:frameno]; %bins are 10 frames - make this based on actual timing
if xax(end)<frameno;
    xax(end)=frameno;
end
bar(xax, hist((sort(all_ev)), xax));
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



%% plot baseline-corrected smoothed timecourses and label

figure(figno+3);
for i=1:size(soma, 1)
    subplot(size(soma, 1),1,i); plot(corrected_timecourse(i,:),'k'); hold on;
    plot(ev_st{i},corrected_timecourse(i, ev_st{i}),'ro');
    xlim([0 length(corrected_timecourse)]);
    ylim([floor(min(corrected_timecourse(i,:))) ceil(max(corrected_timecourse(i,:)))]);
    ylabel('delta F/F');
    title(['Cell ' num2str(i)]);
    if i~=size(soma,1)
        set(gca,'XTickLabel',[]);
    else
        xlabel('time (in frames)')
    end
    
end
suptitle('Timecourse of fluorescence change at selected spots');
set(gcf,'OuterPosition',[100 100 500 (150*size(soma,1))]);

set(gcf,'Units','inches','PaperUnits','inches');
set(gcf,'PaperPosition',[ .5 .5 7.5 10 ]);
saveas (gcf,[filename, ' dF analysis.jpg'], 'jpg');

save([filename, '.mat'], 'soma', 'timecourse', 'corrected_timecourse', 'cutoff','ev_st', 'ev_dur', 'ev_peak', 'event', 'integrated_image', 'cross_correlation');

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

end