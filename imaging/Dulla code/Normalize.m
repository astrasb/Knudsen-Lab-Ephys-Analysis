function [NormalizedImage]=Normalize(Images, FrameTimes, FrameInterval, ExposureNumber,RGBCustom, Outside_Mask, FramesBlurred, sliding_blank );
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

OpenImages=Images{ExposureNumber};
Frames=size(OpenImages,3);
Height=size(OpenImages,2);
Width=size(OpenImages,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Create Images Used for Pixel by Pixel Normalization %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[AveStartImages, AveEndImages]=CreateNormImages(ExposureNumber,Images,FramesBlurred, FrameInterval);
    

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
if sliding_blank==1;
AdjustedTime=FrameTimes';
tempStart=Images{ExposureNumber};
Frames=size(tempStart,3);
Height=size(tempStart,2);
Width=size(tempStart,1);
StartAveragedFrame=AveStartImages{ExposureNumber};
EndAveragedFrame=AveEndImages{ExposureNumber};
clear Normalized;
DoesThisCellArrayObjectContainData=1;
if DoesThisCellArrayObjectContainData(ExposureNumber)>0 %This is a check for empty exposures in the cooke camera
        Normalized=zeros(Width,Height,Frames);
        StartTime=FrameTimes(ExposureNumber, 1);
        EndTime=FrameTimes(ExposureNumber, Frames);
        for i=1:Frames
            ThisFrame=tempStart(:,:,i);
            ThisTime=FrameTimes(ExposureNumber, i);
            TimeRelativeToStart=(EndTime-ThisTime)/(EndTime-StartTime);
            TimeRelativeToEnd=1-TimeRelativeToStart;
            tempFrame=StartAveragedFrame*TimeRelativeToStart+EndAveragedFrame*TimeRelativeToEnd;
            NormFrame=ThisFrame-tempFrame+mean(mean(mean(StartAveragedFrame(Width/4:3*Width/4,Height/8:7*Height/8))));
            if Outside_Mask>0
            NormFrame(Outside_Mask)=0;
            end
            Normalized(:,:,i)=NormFrame;
            
        end
            fprintf('Exposure %d Normalized', ExposureNumber);
            disp ('NEXT');
        if ExposureNumber==1
              NormalizedImage = {Normalized};
            
        else
              NormalizedImage =[NormalizedImage; Normalized];
        end 
    else
       if ExposureNumber==1
            NormalizedImage = {0};
       else
            NormalizedImage =[NormalizedImage; 0];
       end
       fprintf('Exposure %d Empty', ExposureNumber);
       fprintf('');
end
    
end

if sliding_blank==2;
AdjustedTime=FrameTimes';
tempStart=Images{ExposureNumber};
Frames=size(tempStart,3);
Height=size(tempStart,2);
Width=size(tempStart,1);
StartAveragedFrame=AveStartImages{ExposureNumber};
EndAveragedFrame=AveEndImages{ExposureNumber};
clear Normalized;
DoesThisCellArrayObjectContainData=1;
if DoesThisCellArrayObjectContainData(ExposureNumber)>0 %This is a check for empty exposures in the cooke camera
        Normalized=zeros(Width,Height,Frames);
        StartTime=FrameTimes(ExposureNumber, 1);
        EndTime=FrameTimes(ExposureNumber, Frames);
        for i=1:Frames
            ThisFrame=tempStart(:,:,i);
            NormFrame=ThisFrame-StartAveragedFrame+mean(mean(mean(StartAveragedFrame(Width/4:3*Width/4,Height/8:7*Height/8))));
            NormFrame(Outside_Mask)=0;
            Normalized(:,:,i)=NormFrame;
            
        end
            fprintf('Exposure %d Normalized', ExposureNumber);
            disp ('NEXT');
        if ExposureNumber==1
              NormalizedImage = {Normalized};
            
        else
              NormalizedImage =[NormalizedImage; Normalized];
        end 
    else
       if ExposureNumber==1
            NormalizedImage = {0};
       else
            NormalizedImage =[NormalizedImage; 0];
       end
       fprintf('Exposure %d Empty', ExposureNumber);
       fprintf('');
end
    
end



end


