function [frames sumstim avgstim] = OGB_puff(fileno, shortened)
%This program calculates the delta F/F of a calcium imaging movie, and
%interactively lets the user select spots in the movie to analyze over the time of the movie. It also
%creates an avi movie with time stamps included for presentation, and an animated gif of the
%integrated OGB signal mixing with a brightfield image for cell targeting with a patch electrode.
%
%The program imports the image stack from the multi-image TIFF created
%by the Qcapture software, and aligns it to the frame capture and electrical
%stimulation signals from pClamp. It uses time stamps to choose the most
%likely abf file that contains information about the movie. 
%
%Thus, for full functionality, it requires 3 files: the multi-image TIFF,
%the pclamp file for timing, and a single brightfield image for making the
%animated tiff

%Switch commented line to analysisfolder=cd unless being run by Astra on her macbookpro
%analysisfolder='/Users/Batcave/Documents/Matlab';
analysisfolder=cd 

close all
add_abf = 1;    

ROI = 100:924;  %50:464
presetROI=1; %set to 1 if you want to automatically use preset ROI when making dF analysis. Will bypass ROI selection
presetx=[1];
presety=[1];
zz=5; %ylim for dF analysis image.

%% Import files, determine timings

warning('OFF')
%prompt user for file if not included in call
if exist('fileno') == 0 || isempty('fileno');
    % Open file
    [filename pathname] = (uigetfile('*.tif'));
    cd(pathname);
else
    filename = [num2str(fileno), '.tif'];
end

%Shortened is a variable that controls the duration of the analysis. enter
%in a number (in sec) less than the movie duration to truncate it
if exist('shortened') == 0 || isempty('shortened');
   shortened = 0;
end


nfo = imfinfo(filename);    %gather info on file
imf_time = [str2num(nfo(1).FileModDate(end-7:end-6)), str2num(nfo(1).FileModDate(end-4:end-3))];

disp('movie loading')
%Load moviefile
for x = 3:length(nfo)
    frames(:, :, x-2) = double(imread(filename, x));    %subtract 2 for the offset..
end
disp([filename, ' loaded and parsed'])

%if abf file to be included (now standard function)

if add_abf == 1
    %first try to find matching abf file based on time stamp
    abf = dir('*.abf');
    for i = 1:size(abf, 1)
        abf_t(i, :) = [str2num(abf(i).date(end-7:end-6)), str2num(abf(i).date(end-4:end-3))];
    end
    
    imf_time=repmat(imf_time,size(abf_t, 1),1);
    for x = 1:2 %try to compare time stamps (two times)
        time_check = abf_t./imf_time;  %divide imf_time coordinates by abf_times. If it == 1, we have a match!
        a = find(time_check(:,1) > 0.99999 & time_check(:,1) < 1.00001 & time_check(:,2) > 0.9999 & time_check(:,2) < 1.00001);
        if ~isempty(a)
            break
        else
            imf_time(:,2) = imf_time(:,2)-1;
        end
    end
    
    if ~isempty(a)  %if we have a hit, upload the abf file
        abf_filename = abf(a).name; disp('Matching abf file found!'); disp(' ')
    else            %otherwise prompt user
        [abf_filename] = uigetfile('*.abf', 'Pick the associated abf file');
    end
    [trace dt header] = abf2load(abf_filename); sfq = 1/(dt*1e-6);
    
    %ch 3 is cam out, ch 5 is stim
     camchan = find(strncmp(header.recChNames, 'cam', 3) >0);
    % camchan = 5;
     
    [pks tms] = findpeaks(diff(trace(:, camchan, 1)), 'MINPEAKHEIGHT', 1);
     tms = tms/sfq;
    if shortened ~= 0
        newend = find(tms > shortened)+1;
         tms([11:2 newend:end]) = '';
         frames(:, :, size(tms,1)+1:end) = '';
    else
         tms([1:2 length(nfo)+1:end]) = ''; %take out because I didn't capture the first two images (first image has already started w/ acquisition), and often stop the image acquisition prior to the end of the trace
    end
   
    if size(frames, 3) < size(tms, 1)
        tms([size(frames, 3)+1 end]) = '';
    end
    
    framerate = 1/mean(diff(tms));
    
    %Find time of stimulations
    stimchan = find(strncmp(header.recChNames, 'puff', 4)>0);  %find the channel with stim.
    %stimchan = 3;
  
    stim_cutoff = 0.5*max(abs(trace(:, stimchan)));
    %stim_cutoff = 5*std(trace(:, stimchan));
    [s stimtime] = findpeaks(abs(trace(:, stimchan)), 'minpeakheight', stim_cutoff);  %find the time of the stimuli
    stimtime = stimtime/sfq;
    
    if isempty(stimtime)
        stimtime = input('Enter the time of the stim (in sec). -->  ');
        %stimtime = floor(stimtime*sfq);
    end
    
    if size(frames, 3) > length(tms)
        frames(:, :, (length(tms)+1):end) = '';
    end
    
    baseframe = find(tms > stimtime(1), 1) -3;     % find the time of the stimulus, and back up a frame to end the baseline period
else
    baseframe = 4;     % find the time of the stimulus, and back up two frames to end the baseline period
    
end
% baseframe = 20;

disp('analysis proceeding')

%% Now calculate the delta F/F

baseline = (mean(frames(:, :, 1:baseframe), 3));     %create an average baseline from the prestim period (currently 6 images), assuming a 120 ms IFI
baseline = repmat(baseline, [1, 1, size(frames, 3)]);   %create an array of the baseline frames
frames = 100*((frames - baseline)./baseline);       %calculate the dF/F by matrix math - uberfast
tic
%now smooth out the images with medfilt - takes time.
for f = 1:size(frames, 3)
    frames(:, :, f) = medfilt2(frames(:, :, f), [5 5]);    %filter each image
end
toc

%make an ROI around the part of the image that has signal (not the
%corners)

f1 = frames(ROI, ROI, :);

fmax = max(f1(f1>0));
fmin = min(f1(f1>0));
clear f1
f1 = uint8((frames-fmin)/(fmax-fmin)*255);      %(frames-min)/range

%now highlight some ROIs.
im_sum = sum(f1(:, :, baseframe:end), 3); %creates a summed image (not including the borders that might appear, depending on the scope
im_sum = (sum(f1(:, :, baseframe:end), 3)-min(im_sum(im_sum > 0)))/range(im_sum(im_sum > 0))*255;   %normalizes frames with the min and range of the summed image

%im_mn = mean(f1(:, :, baseframe:end), 3);
%im_sum = (im_mn-min(im_mn(im_mn > 0)))/range(im_mn(im_mn > 0))*255;
%im_sum = im_mn;


%% DIsplay and select ROI for time-series analysis
%figure, set(gcf, 'OuterPosition', [200 100 700 1000], 'Name', filename);
%subplot(3, 2, 1:4); image(im_sum);

figure, set(gcf, 'OuterPosition', [500 100 600 800], 'Name', filename);
subplot(3, 2, 1:4);  image(im_sum); %image(im_sum);%
 set(gca, 'ytick', 0, 'xtick', 0)
 
 
%To analyze repeated ROI across files, add x and y single column arrays
if presetROI>0
    x=presetx;
    y=presety;
end
if presetROI<1
disp('Select cells of interest with the mouse, and press return when done');
[x y] = ginput;
x = round(x); y = round(y);
end

     disp('ROI x values'); disp(x);
     disp('ROI y values'); disp(y);

%plot the timecourse at for each selected location
for i = 1:size(x, 1);
    dFspot(:, i) = squeeze((frames(y(i), x(i), :)));
    leg{i} = sprintf('Spot %2.0g', i);
    text(x(i), y(i), num2str(i), 'Color', 'w', 'fontsize', 15, 'fontweight', 'bold');
end

zoom on
%display the time of frames and stim on the axes
if add_abf == 1
    subplot(3, 2, 5:6); plot(tms, dFspot, 'LineWidth', 3); legend(leg); xlabel('time (s)'); ylabel('dF/F (% percent fluorescence)');
    hold on; line([stimtime stimtime], [0 max(max(dFspot))], 'LineStyle', '--', 'Color', 'k'); 
    %ylim([0 max(max(dFspot))]);
    %if presetROI>0;
    %Set up plot line/y axis for comparison across multiple figures
    %hold on; line([stimtime stimtime], [0 zz], 'LineStyle', '--', 'Color', 'k'); 
    
    %ylim([0 zz]);
    %subplot(3, 2, 5:6); plot(dFspot); legend(leg); xlabel('frame'); ylabel('dF/F (% percent fluorescence)'); ylim([0 max(max(dFspot))])

    %end
else
    subplot(3, 2, 5:6); plot(dFspot); legend(leg); xlabel('frame'); ylabel('dF/F (% percent fluorescence)'); ylim([0 max(max(dFspot))])

end

plot(tms(1):1/sfq:tms(end), 0.1/5* max(max(dFspot))*trace(tms(1)*sfq:tms(end)*sfq, camchan, 1), 'Color', [0.5 .5 .5])
 set(gcf,'Units','inches','PaperUnits','inches');
set(gcf,'PaperPosition',[ .5 .5 7.5 10 ]);
saveas (gcf,[filename, ' dF analysis.jpg'], 'jpg')



print(gcf, '-depsc', [fullfile(analysisfolder,filename), ' dF analysis']);

disp(' '); disp('Press return to continue')

pause

%% now create the movie
figure
damov = VideoWriter(['df ', filename]);
damov.FrameRate = 5;

open(damov);
for f = 1:size(frames, 3)
    imshow(f1(:, :, f));%;, jet);
    hold on; line([800 910], [1000 1000], 'Color', 'w', 'LineWidth', 5); %this inserts a 25 um scale bar (assuming 1024^2, 63x image)
    
    if sum(stimtime >= tms(f) & stimtime <= tms(f)+diff(tms(1:2))) > 0
        plot(80, 80, 'o', 'MarkerFaceColor', 'y', 'MarkerSize', 25)
    end
        
    
    if add_abf == 1
        text(nfo(1).Width-150, 25, num2str(tms(f)), 'Color', 'w', 'FontSize', 15); %add time stamp
    end
    currFrame = getframe;
    writeVideo(damov,currFrame);
    %dfmov(f) = im2frame((imfm(:, :, f)), jet);
end
%disp(['writing df ', filename]);
close(damov)
close

%figure, imshow(uint8(baseline(:, :, 1)));

%movie2avi(dfmov, , 'fps', 4);
disp('fin')


%% now create an animated gif of the background and the found spots
fname = [filename(1:2),'bf.tif'];
if exist(fname) ~= 2
    fname =  uigetfile('*.tif','Select a brightfield image to merge');   %'MultiSelect','on'););
end
if fname ~= 0
        im = imread(fname);
        gif(:, :, 1, 1) = uint8(imread(fname));
        gif(:, :, 1, 2) = imadd(gif, uint8(im_sum));
        %gif(:, :, 1, 2) = uint8(im_sum);
        %uint8(baseline(:, :, 1));
   
    
    imwrite(gif,  [filename, ' cell finder.gif'],  'DelayTime', 0.5,'LoopCount',inf);
    disp('animated gif written'); disp(' ');
end




