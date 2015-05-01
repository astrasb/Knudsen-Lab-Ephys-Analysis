function [Normalized]=Normalize_non_cell_array(Images, FrameTimes, FrameInterval,FramesBlurred);
% **  function
% [NormalizedImage]=Normalize(Images, FrameTimes, FrameInterval, ExposureNumber,RGBCustom, Outside_Mask);
%
% Normalies Data using a sliding average based on the first and last 50 ms of data
%
%                    >>> INPUT VARIABLES >>>
%
% NAME                  TYPE, DEFAULT           DESCRIPTION
% Images                                        Cell Array Containing the data
% FrameTimes                                    Array of sample times [1 Frames]
% FrameInterval                                 Time between samples
% ExposureNumber                                Cell within the cell array to get the data from
% RGBCustom                                     Colormap
% Outside_Mask                                  Mask are area outside of the slice
% FramesBlurred                                 ms of data to blur for the start and end normalization images 
%
%                    <<< OUTPUT VARIABLES <<<
%
% NAME                 TYPE                    DESCRIPTION
% Normalize                                    Cell Array Containing the data normalized data
% 
% 


%%%%%%%%%%%%%%% Opening the data and getting its properties

OpenImages=Images;
Frames=size(OpenImages,3);
Height=size(OpenImages,2);
Width=size(OpenImages,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Create Images Used for Pixel by Pixel Normalization %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AveStartImages=FrameAverage(Images,1,FramesBlurred);
AveEndImages=FrameAverage(Images,size(Images,3)-FramesBlurred, size(Images,3));
    

    % Creates the normalized images used for the sliding normalization
    %
    %                    >>> INPUT VARIABLES >>>
    %
    % NAME                  TYPE, DEFAULT           DESCRIPTION
    % ExposureNumber                                Cell within the cell array to use                               
    % CellArrayObject                               Cell Array Containing the data
    % FramesBlurred                                 ms of data to blur for each image
    % FrameInterval                                 Time between samples
    %
    %
    %                    <<< OUTPUT VARIABLES <<<
    %
    % NAME                 TYPE                    DESCRIPTION
    % AveStartImages                               Single image of the first FramesBlurred ms of data averaged
    % AveEndImages                                 Single image of the first FramesBlurred ms of data averaged
    % 

disp ('Normalization Images Created');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Sliding Normalization %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AdjustedTime=FrameTimes';
tempStart=Images;
clear Normalized;

Normalized=zeros(Width,Height,Frames);
StartTime=FrameTimes(1, 1);
EndTime=FrameTimes(1, Frames);
        for i=1:Frames
            ThisFrame=tempStart(:,:,i);
            ThisTime=FrameTimes(1, i);
            TimeRelativeToStart=(EndTime-ThisTime)/(EndTime-StartTime);
            TimeRelativeToEnd=1-TimeRelativeToStart;
            tempFrame=AveStartImages*TimeRelativeToStart+AveEndImages*TimeRelativeToEnd;
            NormFrame=ThisFrame-tempFrame+mean(mean(mean(AveStartImages(Width/4:3*Width/4,Height/8:7*Height/8))));
            Normalized(:,:,i)=NormFrame;
        end
            
end
    








