function [frames] = OGB_photobleach(fileno, shortened)
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
analysisfolder='/Users/Batcave/Documents/Matlab';
%analysisfolder=cd

close all

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

disp('photobleaching image loading')
%Load moviefile
for x = 3:length(nfo)
    frames(:, :, x-2) = double(imread(filename, x));    %subtract 2 for the offset..
end
disp([filename, ' loaded and parsed'])

end



