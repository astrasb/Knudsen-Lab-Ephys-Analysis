function [NormalizedImage]=Normalize(Images, FrameTimes, FrameInterval, ExposureNumber,RGBCustom, Outside_Mask, FramesBlurred);
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

Ch1=OpenImages(1:32,:,:);
Ch2=OpenImages(33:64,:,:);
Ch1Images{1}=Ch1;
Ch2Images{1}=Ch2;
FrameT=FrameTimes';
Ch1Ave=mean(mean(Ch1));
Ch2Ave=mean(mean(Ch2));
Ch1Ave=squeeze(Ch1Ave);
Ch2Ave=squeeze(Ch2Ave);
Ch1Ave=double(Ch1Ave);
Ch2Ave=double(Ch2Ave);
excluded1=excludedata(FrameT, Ch1Ave, 'indices', 570:3400);
excluded2=excludedata(FrameT, Ch2Ave, 'indices', 570:3400);
fitexcluded1=fitoptions('Exclude', excluded1);
fitexcluded2=fitoptions('Exclude', excluded2);
[Ch1Fit]=fit(FrameT, Ch1Ave, 'exp2', fitexcluded1);
[Ch2Fit]=fit(FrameT, Ch2Ave, 'exp2', fitexcluded1);


Frames=size(Ch1,3);
Height=size(Ch1,2);
Width=size(Ch1,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Create Images Used for Pixel by Pixel Normalization %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[AveStartImagesCh1, AveEndImagesCh1]=CreateNormImages(ExposureNumber,Ch1Images,FramesBlurred, FrameInterval);

[AveStartImagesCh2, AveEndImagesCh2]=CreateNormImages(ExposureNumber,Ch2Images,FramesBlurred, FrameInterval); 


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

StartAveragedFrameCh1=AveStartImagesCh1{ExposureNumber};
EndAveragedFrameCh1=AveEndImagesCh1{ExposureNumber};
clear NormalizedCh1;
DoesThisCellArrayObjectContainData=1;
if DoesThisCellArrayObjectContainData(ExposureNumber)>0 %This is a check for empty exposures in the cooke camera
        NormalizedCh1=zeros(Width,Height,Frames);
        NormalizedCh1=zeros(Width,Height,Frames);
        Normalized=zeros(Width*2,Height,Frames);
        StartTime=FrameTimes(ExposureNumber, 1);
        EndTime=FrameTimes(ExposureNumber, Frames);
        for i=1:Frames
            ThisFrame=Ch1(:,:,i);
            ThisTime=FrameTimes(ExposureNumber, i);
            TimeRelativeToStart=(EndTime-ThisTime)/(EndTime-StartTime);
            TimeRelativeToEnd=1-TimeRelativeToStart;
            tempFrame=StartAveragedFrameCh1*TimeRelativeToStart+EndAveragedFrameCh1*TimeRelativeToEnd;
            NormFrameCh1=ThisFrame-tempFrame+mean(mean(mean(StartAveragedFrameCh1(Width/4:3*Width/4,Height/8:7*Height/8))));
            NormFrameCh1(Outside_Mask)=mean(mean(mean(StartAveragedFrameCh1(Width/4:3*Width/4,Height/8:7*Height/8))));  %%  Changed for Andor Processing used to be =0;
            NormalizedCh1(:,:,i)=NormFrameCh1;
            
        end
        
        StartAveragedFrameCh2=AveStartImagesCh2{ExposureNumber};
        EndAveragedFrameCh2=AveEndImagesCh2{ExposureNumber};
        clear NormalizedCh2;
	
        
        NormalizedCh2=zeros(Width,Height,Frames);
        StartTime=FrameTimes(ExposureNumber, 1);
        EndTime=FrameTimes(ExposureNumber, Frames);
        for i=1:Frames
            ThisFrame=Ch2(:,:,i);
            ThisTime=FrameTimes(ExposureNumber, i);
            TimeRelativeToStart=(EndTime-ThisTime)/(EndTime-StartTime);
            TimeRelativeToEnd=1-TimeRelativeToStart;
            tempFrame=StartAveragedFrameCh2*TimeRelativeToStart+EndAveragedFrameCh2*TimeRelativeToEnd;
            NormFrameCh2=ThisFrame-tempFrame+mean(mean(mean(StartAveragedFrameCh2(Width/4:3*Width/4,Height/8:7*Height/8))));
            NormFrameCh2(Outside_Mask)=mean(mean(mean(StartAveragedFrameCh2(Width/4:3*Width/4,Height/8:7*Height/8))));  %%  Changed for Andor Processing used to be =0;
            NormalizedCh2(:,:,i)=NormFrameCh2;
            
        end
            
            Normalized(1:32,:,:)=NormalizedCh1;
            Normalized(33:64,:,:)=NormalizedCh2;
        
        
        
        
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


