 function [Images, Width, Height, Frames, ExposureNumber, filename, FrameTimes, TraceData, DarkFrame, FrameInterval]=RedShirtOpen(filename,dfsubtract, MS_of_Data_to_Discard_Start, MS_of_Data_to_Discard_End)
% **  function
% [Images,Width,Height,Frames,Timeseries,TraceData,DarkFrame]=openredshirt(fn)

% loads red shirt data file and returns 3 dimensional array as a series of frames

%                    >>> INPUT VARIABLES >>>
%
% NAME        TYPE, DEFAULT      DESCRIPTION
% fn          char array         redshirt data file name
% dfsubtract    double  flag to indicate whether Image array should be
%                       DarkFrame corrected
%
%                    <<< OUTPUT VARIABLES <<<
%
% NAME        TYPE            DESCRIPTION
% Images      double                      the data read, in a x,y,t dataformat
% Width      double                     Width of frame in pixels
% Height      double                    Height of frame in pixels
% Frames      double                     Number of frames
% Timeseries  double                     an array of sample times [1..Frames]
% TraceData  double                     an array of electrophysiological samples  [1..Frames][1..numchannels]
% DarkFrame double   an array of pixels from camera representing  a dark frame
% 
fid=0;
ExposureNumber=1;
datafilename='file.da';  %works if the file is in the current directory 
replaced='file';

datafilename=strrep(datafilename,replaced,filename);
    
    [fid, message] = fopen(datafilename, 'rb');
    
    if fid==-1;
        if fid==-1
            disp (message)
        end
    end
    


Header=fread(fid,2560,'short');
Height=Header(386,1);
Width=Header(385,1);
Frames=Header(5,1);
FrameInterval=Header(389,1)/1000;
disp('Header read');
TempHolder=zeros(Width,Height,Frames, 'single');
Images=zeros(Width,Height,Frames, 'single');
Images=reshape(Images, Width,Height,Frames);
TempHolder=fread(fid,Width*Height*Frames, 'int16');
TempHolder=reshape(TempHolder, Frames, []);
TraceData=zeros(8,Frames);
TempTraceData=zeros(1,Frames,'single');
for i=1:8
    TraceData(i,:)=fread(fid,Frames,'int16');
end
TraceData=(TraceData*10/2^15)-5;
DarkFrame=fread(fid,Width*Height, 'int16');
DarkFrame=reshape(DarkFrame,Width,Height);
DarkFrame=rot90(DarkFrame);
fclose(fid);
disp('File read');
FrameTimes=[1:Frames]*(Header(389,1)/1000.); %check header structure to find frame interval (ms?)


for thisFrame=1:Frames
        datapoint=TempHolder(thisFrame,:);
        tempframe=reshape(datapoint,Width,Height);
        Images(:,:,thisFrame)=tempframe-DarkFrame;   
end
clear TempHolder;
disp('DarkFrame subtracted');
Images{1}=Images(:,:,MS_of_Data_to_Discard_Start/FrameInterval:MS_of_Data_to_Discard_End/FrameInterval);
TraceData=TraceData(MS_of_Data_to_Discard_Start/FrameInterval:MS_of_Data_to_Discard_End/FrameInterval,:);
end