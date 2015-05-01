%%%%%%%%%%%%%%%%%%% Main.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                          %
%  Reads in full frame moveis from Cooke Sensicam 
%  Data from the Cooke Camera is already Dark Noise
%  subtracted in the data collection program
%                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;          

%%%%%%%%%%%%%%% Asks for file name - file must be in MATLAB directory in a
%%%%%%%%%%%%%%% folder with the same name as the file.  Matlab will look
%%%%%%%%%%%%%%% for a .out and a .t file

filename=input('Open file: ', 's');
[Images,Width,Height,Frames,ExposureNumber,filename, FrameTimes]=openCookeFullFrame(filename); 

%%%%%%%%%%%% Adjusts Shuttertime based on camera and stimulation triggering
AdjustmentFactor=1300;
TimeAdjust=zeros(Frames, ExposureNumber);
TimeAdjust=TimeAdjust-AdjustmentFactor;
AdjustedTime=FrameTimes+TimeAdjust;
clear TimeAdjust;
clear AdjustmentFactor;

%%%%%%%%%%%%%%% Grab and ROI from Ch1 and Ch2 of the FRET Sensor Images
%%%%%%%%%%%%%%% Outputs ROI values to Ch1ROIoutput & Ch1ROIoutput
for exposure=1:ExposureNumber
    
    ROICh1 = [Width/8,Height/4;3*Width/8,3*Height/4];
    ROICh2 = [5*Width/8,Height/4;7*Width/8,3*Height/4];

    for ThisFrame=1:Frames
        [RoiAveCh1, RoiAveCh2] = DualChannelROI (Width, Height, Frames, Images, ROICh1, ROICh2, ThisFrame,exposure);
       
        if ((ThisFrame==1)&&(exposure==1));
            Ch1ROI=RoiAveCh1;
            Ch2ROI=RoiAveCh2;
        else
            Ch1ROI=[Ch1ROI; RoiAveCh1];
            Ch2ROI=[Ch2ROI; RoiAveCh2];
        end
    end
  
end
    Ch1ROI=reshape(Ch1ROI,Frames, []);
    Ch2ROI=reshape(Ch2ROI,Frames, []);
disp ('Dual Channel ROI Complete');
    
    
%%%%%%%%%%%%%%% Using Ch1ROIOutput this script get the shutter opening and
%%%%%%%%%%%%%%% closing frame number.
 
[ShutterOpenValues, ShutterCloseValues] = ShutterTimes(Ch1ROI, Ch2ROI, ExposureNumber,FrameTimes, AdjustedTime);
disp ('Shutter Open and Close times Computer');

%%%%%%%%%%%%%%% ResizesImages
[FImages, ClippedParameters]=HeightWidthFormatClipDarkImages(Images, ShutterOpenValues, ShutterCloseValues, Height, Width, Frames, ExposureNumber, exposure);
disp ('Images Clipped to Open Shutter Times Only');

%%% All file opening and formating stages complete
%%% Beyond this point in the code the processing is fully automated


%%%%%%%%%%%%%%% Taking the ratio of Ch1 and Ch2

[FRatio]=TakeTheRatio(FImages, ShutterOpenValues, Frames, ExposureNumber,Width, Height);
disp ('Ratioing Complete');

%%%%%%%%%%%%  Creat New Color Map
        
[RGBCustom]=CreateRGBColorTable;
disp ('ColorMap Created');

%%%%%%%%%%%%%%% Make Raw Ratio Movies
IgnoreFirstXFrames=1; % 1=start at the first frame
[MinCutoff, Step]=AutoScaleMakeTiffs(FRatio, filename,Frames, ExposureNumber,Width, Height, ClippedParameters, RGBCustom, 'raw', ShutterOpenValues, ShutterCloseValues, IgnoreFirstXFrames);
disp ('Raw Images Written');

%%%%%%%%%%%%%% Create Images Used for Pixel by Pixel Normalization

[AveStartImages, AveEndImages]=CreateNormImages(ExposureNumber, FRatio, ShutterOpenValues, ShutterCloseValues,Height, Width/2, ClippedParameters, ShutterDelayCompensation);
disp ('Normalization Images Created');

%%%%%%%%%%%%%%%%%% Sliding Normalization
[NormalizedImage]=SlidingNormalize(AveStartImages,AveEndImages, FRatio,Width, Height, AdjustedTime, Frames, ExposureNumber, exposure, ClippedParameters, ShutterOpenValues, ShutterCloseValues, RedShirt);

%%%%%%%%%%%%%%% Make Normalized Ratio Movies
[MinCutoff, Step]=AutoScaleMakeTiffs(NormalizedImage, filename,Frames, ExposureNumber,Width, Height, ClippedParameters, RGBCustom, 'norm', ShutterOpenValues, ShutterCloseValues,IgnoreFirstXFrames);
disp ('Raw Images Written');

%%%%%%%%%%%%%% Compress images into Lines for Simple Regional analysis

[LineData,TimeStretchedLineData]=GetLineAverage(ExposureNumber,Frames,NormalizedImage,ShutterOpenValues, ShutterCloseValues, filename, AdjustedTime, RGBCustom);
disp ('Line Plots Written');

%%Create Contour plot of Maximum Change time point

for exposure=1:ExposureNumber
if ShutterOpenValues(exposure)>1
    ThisExposure=FRatio{exposure};
    This1DExposure1=mean(mean(ThisExposure));
    This1DExposure=squeeze(This1DExposure1);
    x=This1DExposure;
    t=AdjustedTime(ShutterOpenValues(exposure):ShutterCloseValues(exposure),exposure);
    dx=diff(x);
    dt=diff(t);
    deriv=dx./dt;
    dderiv=deriv./dt;
    dMax=max(dderiv);
    dMin=min(dderiv);
    FrameMax=find(dderiv==dMax);
    contour(ThisExposure(:,:,ShutterOpenValues(exposure)+FrameMax)); 
    
    end
    
end

    
    