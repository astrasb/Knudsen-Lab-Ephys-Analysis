
clear all;
dfsubtract=1;

filename=input('Open file: ', 's');
[Images, Width, Height, Frames,ExposureNumber, filename, FrameTimes,TraceData, DarkFrame, FrameInterval]=RedShirtOpen(filename,dfsubtract);
%%%%%%%%%%%%%%% Grab and ROI from Ch1 and Ch2 of the FRET Sensor Images
%%%%%%%%%%%%%%% Outputs ROI values to Ch1ROIoutput & Ch1ROIoutput
for exposure=1:ExposureNumber
    
    ROICh1 = [Width/8,Height/4;3*Width/8,3*Height/4];
    ROICh2 = [5*Width/8,Height/4;7*Width/8,3*Height/4];

    for ThisFrame=1:Frames
        [RoiAveCh1, RoiAveCh2] = DualChannelROI (Width, Height, Frames, Images, ROICh1, ROICh2, ThisFrame,exposure);
        %[ImageLocation, RoiAveCh1, RoiAveCh2]= frameprocessing (Width, Height, Frames, Images, ROICh1, ROICh2, ThisFrame, filename);

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
[MinCutoff, Step]=AutoScaleMakeTiffs(FRatio, filename,Frames, ExposureNumber,Width, Height, ClippedParameters, RGBCustom, 'raw', ShutterOpenValues, ShutterCloseValues, IgnoreFirstXFrames, 200);
disp ('Raw Images Written');

%%%%%%%%%%%%%% Create Images Used for Pixel by Pixel Normalization

[AveStartImages, AveEndImages]=CreateNormImages(ExposureNumber, FRatio, ShutterOpenValues, ShutterCloseValues,Height, Width/2, ClippedParameters, IgnoreFirstXFrames);
disp ('Normalization Images Created');
AdjustedTime=FrameTimes';
%%%%%%%%%%%%%%%%%% Sliding Normalization
[NormalizedImage]=SlidingNormalize(AveStartImages,AveEndImages, FRatio,Width/2, Height, AdjustedTime, Frames, ExposureNumber, exposure, ClippedParameters, ShutterOpenValues, ShutterCloseValues, IgnoreFirstXFrames);
NormClippedParameters=[ShutterOpenValues+IgnoreFirstXFrames, ShutterCloseValues-IgnoreFirstXFrames*2-1];
%%%%%%%%%%%%%%% Make Normalized Ratio Movies
[MinCutoff, Step]=AutoScaleMakeTiffs(NormalizedImage, filename,Frames, ExposureNumber,Width, Height, NormClippedParameters, RGBCustom, 'norm', ShutterOpenValues, ShutterCloseValues, IgnoreFirstXFrames,250);
disp ('Raw Images Written');
