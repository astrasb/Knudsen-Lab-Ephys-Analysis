function [ThresholdDone, NormalizedImage]=Normalize(Images, fullfilename,directoryname, ExposureNumber, filename, FrameTimes,TraceData, FrameInterval, fidout);
% **  function
% [ThresholdDone]=ThresholdSequences(filename);

% loads red shirt data file and outputs treshhold graphs, e-phsytraces,
% jpeg images, as well as a .mat file containing the e-phys trace and each
% threshold point time series


%                    >>> INPUT VARIABLES >>>
%
% NAME        TYPE, DEFAULT      DESCRIPTION
% filename          char array         redshirt data file name
% 
%
%                    <<< OUTPUT VARIABLES <<<
%
% NAME        TYPE            DESCRIPTION
% ThresholdDone      double            1= succesfully processed data
% 
% 


%%%%%%%%%%%%%%% Because redshirt images don't need shutter detection SOV
%%%%%%%%%%%%%%% and SCV are set to the starting and ending frame numbers
OpenImages=Images{ExposureNumber};
Frames=size(OpenImages,3);
Height=size(OpenImages,2);
Width=size(OpenImages,1);

IgnoreFirstXFrames=50/FrameInterval;

%%%%%%%%%%%%%% Create Images Used for Pixel by Pixel Normalization
FramesBlurred=50;

[AveStartImages, AveEndImages]=CreateNormImages(ExposureNumber,Images, IgnoreFirstXFrames, FramesBlurred);
disp ('Normalization Images Created');
AdjustedTime=FrameTimes';
%%%%%%%%%%%%%%%%%% Sliding Normalization
[NormalizedImage]=SlidingNormalize(AveStartImages,AveEndImages,Images,FrameTimes,  ExposureNumber, IgnoreFirstXFrames);
end
