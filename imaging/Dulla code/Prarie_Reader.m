%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This code opens all Redshirt Files within a selected folder, and creates
%  ratioed, normalized images of every frame from every file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

close all;
ROI_ON=0;
  [RGBCustom]=CreateRGBColorTable;
  [RGBCustomInverted]=CreateRGBColorTableInverted;
%camera=1 = prarie 2-p
%camera=2 = redshirt
camera=2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%%%%%%%%% Create File List    %%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
if camera==1
directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
%directoryname = uigetdir('/mnt/newhome/mirror/home/chris/MATLAB/');    %%%%% Opens files from MATLAB directory
pathtiming=sprintf('%s/*xml*',directoryname);
pathCh1=sprintf('%s/*Ch1*',directoryname);
pathCh2=sprintf('%s/*Ch2*',directoryname);
d1 = dir (pathCh1);
d2 = dir (pathCh2);
d3 = dir (pathtiming);
numfiles1=length(d1);
numfiles2=length(d2);
numfilest=length(d3)

if numfiles1<1
    disp('No files found');
end

for i = 1:numfiles1
  t = length(getfield(d1,{i},'name')) ;
  dd1(i, 1:t) = getfield(d1,{i},'name') ;
  t = length(getfield(d2,{i},'name')) ;
  dd2(i, 1:t) = getfield(d2,{i},'name') ;
end

t=length(getfield(d3,{1},'name'));
ddt(1,1:t)=getfield(d3,{1},'name');
testfilename=dd1(1,:);
fulltestfilename=sprintf('%s/%s',directoryname,testfilename);
test=imread(fulltestfilename);
imagesize=size(test);
Ch1ImageData=zeros(imagesize(1),imagesize(2),numfiles1);
Ch2ImageData=zeros(imagesize(1),imagesize(2),numfiles1);
filenamet=ddt(1,:);
timingfilename=sprintf('%s/%s',directoryname,filenamet);

strval=search_val(timingfilename,'Frame relativeTime', numfiles1)
time=strval;
for i=1:numfiles1
    
    filename1=dd1(i,:);
    filename2=dd2(i,:);
    fullfilename1=sprintf('%s/%s',directoryname,filename1);
    fullfilename2=sprintf('%s/%s',directoryname,filename2);
    Ch1ImageData(:,:,i)=imread(fullfilename1);
    Ch2ImageData(:,:,i)=imread(fullfilename2);
end

else 
directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
%directoryname = uigetdir('/mnt/newhome/mirror/home/chris/MATLAB/');    %%%%% Opens files from MATLAB directory

path1=sprintf('%s/*.da',directoryname);
d = dir (path1);
numfiles=length(d);
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end
filename=dd(1,:);
fullfilename=sprintf('%s/%s',directoryname,filename);

[fid, message] = fopen(fullfilename, 'rb');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  Reading the header %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Header=fread(fid,2560,'short');
Height=Header(386,1);
Width=Header(385,1);
Frames=Header(5,1);
FrameInterval=Header(389,1)/1000;
disp('Header read');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Allocating Memory %%%%%%%%%%%%%
%%%%%%%%%% & Reading         %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TempHolder=zeros(Width,Height,Frames, 'single');
Images=zeros(Width,Height,Frames, 'single');
TraceData=zeros(8,Frames);
TempTraceData=zeros(1,Frames,'single');
Images=reshape(Images, Width,Height,Frames);
TempHolder=fread(fid,Width*Height*Frames, 'int16');             %%%%%%%%%%%%%%%%%% Reads the image data
TempHolder=reshape(TempHolder, Frames, []);

for i=1:8                                                       %%%%%%%%%%%%%%%%%% Reads in BNC inputs
    TraceData(i,:)=fread(fid,Frames,'int16');
end
TraceData=(TraceData*10/2^15)-5;                                %%%%%%%%%%%%%%%%%% Scales the BNC data into mV
DarkFrame=fread(fid,Width*Height, 'int16');                     %%%%%%%%%%%%%%%%%% Reads the Dark Frame
DarkFrame=reshape(DarkFrame,Width,Height);
DarkFrame=rot90(DarkFrame);
fclose(fid);
disp('File read');


FrameTimes=[1:Frames]*(Header(389,1)/1000.);                    %%%%%%%%%%%%%%%%%%% check header structure to find frame interval (ms?)


for thisFrame=1:Frames                                          %%%%%%%%%%%%%%%%%%% Reshapes each frame into X and Y dimensions
        datapoint=TempHolder(thisFrame,:);
        tempframe=reshape(datapoint,Width,Height);
        Images(:,:,thisFrame)=tempframe-DarkFrame;
        
end
i=Images<0;
Images(i)=0;
clear TempHolder;
disp('DarkFrame subtracted');
Ch1ImageData=Images(1:40,:,:);
Ch2ImageData=Images(41:80,:,:);
numfiles1=size(Ch1ImageData,3);
Ch1ImageData=Ch1ImageData(4:36,4:76,:);
Ch2ImageData=Ch2ImageData(4:36,4:76,:);
 dataout_Filtered_Max=[FrameTimes;TraceData]; 
  dataout=[FrameTimes;TraceData];  
   


end

for i=1:size(Ch1ImageData,1)
    for j=1:size(Ch1ImageData,2)
    ch1Stream=squeeze(Ch1ImageData(i,j,:));
    ch2Stream=squeeze(Ch2ImageData(i,j,:));
    COV1out(i,j)=cov(ch1Stream);
    COV2out(i,j)=cov(ch2Stream);
    SummedChange1(i,j)=sum(ch1Stream);
    SummedChange2(i,j)=sum(ch2Stream);
    end

    
end

image(COV1out,'CDataMapping','scaled');


ROI_Number_String=inputdlg('How many ROI would you like to draw?');
ROI_Number=str2double(ROI_Number_String);
for j=1:ROI_Number
image(COV1out,'CDataMapping','scaled');
hotspot=roipoly;
%hotspot=find(Ch1ImageData(:,:,20)>1000);
for i=1:numfiles1

    Ch1Temp=(Ch1ImageData(:,:,i));
    Ch2Temp=(Ch2ImageData(:,:,i));
    if camera ==2
    time(i,1)=i*FrameInterval;
    else
        if i<numfiles1-1
        subtimes(i)=time(i+1)-time(i);
        end
    end
    ROIsCh1(i,j)=mean(Ch1Temp(hotspot));
    ROIsCh2(i,j)=mean(Ch2Temp(hotspot));
    ROIsRatio(i,j)=mean(Ch1Temp(hotspot))./mean(Ch2Temp(hotspot));
    
end
normChs(:,(j-1)*2+1)=ROIsCh1(:,j)/mean(ROIsCh1(25:30,j));
normChs(:,(j-1)*2+2)=ROIsCh2(:,j)/mean(ROIsCh2(25:30,j));
normRatio=ROIsRatio(:,j)/ROIsRatio(25:30,j);
if camera==1
FrameInterval=100*mean(subtimes);
end
Fs=1000/FrameInterval;
L=size(ROIsRatio,1);
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(ROIsRatio(:,j),NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2);
FFT_ROIs(:,(j-1)*2+1)=2*abs(Y(1:NFFT/2));
FFT_ROIs(:,(j-1)*2+2)=f;
% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

end
normChs=normChs(5:numfiles1-5,:);
normRatio=normRatio(5:numfiles1-5,:);
FFTStructure=FFT_StructureGenerator(normRatio(:,4),time(5:595),FrameInterval);



