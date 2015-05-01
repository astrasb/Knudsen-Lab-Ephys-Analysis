clear all;
dfsubtract=1;

filename=input('Open file: ', 's');
[Images, Width, Height, Frames,ExposureNumber, filename, FrameTimes,TraceData, DarkFrame, FrameInterval]=RedShirtOpen(filename,dfsubtract);
%%%%%%%%%%%%%%% Grab and ROI from Ch1 and Ch2 of the FRET Sensor Images
%%%%%%%%%%%%%%% Outputs ROI values to Ch1ROIoutput & Ch1ROIoutput

ShutterOpenValues=1;
ShutterCloseValues=Frames;

%%%%%%%%%%%%  Creat New Color Map
[RGBCustom]=CreateRGBColorTable;
disp ('ColorMap Created');


ShutterOpenValues=1;
ShutterCloseValues=Frames;
ClippedParameters=1;
ClippedParameters=[ClippedParameters ; ShutterCloseValues(1)-ShutterOpenValues(1)];
     

LeftShift=0;
DownShift=0;
ReturnRatio=1;

[FRatio]=TakeTheRatioRedShirt(Images, ShutterOpenValues, Frames, ExposureNumber,Width, Height);
disp ('Ratioing Complete');
clear Images;
Redshirt=1;
IgnoreFirstXFrames=50;

%%%%%%%%%%%%%% Create Images Used for Pixel by Pixel Normalization

[AveStartImages, AveEndImages]=CreateNormImages(ExposureNumber, FRatio, ShutterOpenValues, ShutterCloseValues,Height, Width/2, ClippedParameters, IgnoreFirstXFrames);
disp ('Normalization Images Created');
AdjustedTime=FrameTimes';
%%%%%%%%%%%%%%%%%% Sliding Normalization
%[NormalizedImage]=SlidingNormalize(AveStartImages,AveEndImages, FRatio,Width/2, Height, AdjustedTime, Frames, ExposureNumber, 1, ClippedParameters, ShutterOpenValues, ShutterCloseValues, IgnoreFirstXFrames);
NormClippedParameters=[ShutterOpenValues+IgnoreFirstXFrames, ShutterCloseValues-IgnoreFirstXFrames*2-1];
%%%%%%%%%%%%%%% Make Normalized Ratio Movies
tempimage=FRatio{1};
LeftROI=size(tempimage,2)/4;
RightROI=3*size(tempimage,2)/4;
TopROI=size(tempimage,1)/4;
BottomROI=3*size(tempimage,1)/4;
StartFrames=size(tempimage,3)/50;
EndFrames=5*(size(tempimage,3)/50);


Tstd=std(std(std(tempimage(TopROI:BottomROI,LeftROI:RightROI,StartFrames:EndFrames))));
Tmean=mean(mean(mean(tempimage(TopROI:BottomROI,LeftROI:RightROI,IgnoreFirstXFrames:IgnoreFirstXFrames*2))));
tracewithtime=[FrameTimes;TraceData(1,:)];  
traceave=mean(tracewithtime(2,StartFrames:EndFrames));
[PAT, PBT]=ThresholdCounter(tempimage, Tmean, Tstd);
figure (1);
filenamejpeg=sprintf('%s.jpg', filename);
subplot(3,1,1);
plot(PAT, 'DisplayName', 'PAT', 'YDataSource', 'PAT');
box off;
xlabel('Time');
ylabel('Pixels Above Treshhold');
subplot(3,1,2);
plot(PBT, 'DisplayName', 'PAT', 'YDataSource', 'PAT');
box off;
xlabel('Time');
ylabel('Pixels Below Treshhold');
subplot(3,1,3);
plot(tracewithtime(1,NormClippedParameters(1):NormClippedParameters(2)),tracewithtime(2,NormClippedParameters(1):NormClippedParameters(2)), 'DisplayName', 'PAT', 'YDataSource', 'PAT');
box off;
ylim([traceave-1 traceave+1]);
xlabel('Time');
ylabel('mV');

saveas(1, filenamejpeg);
close;


























