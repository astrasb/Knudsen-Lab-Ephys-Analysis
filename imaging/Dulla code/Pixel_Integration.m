function[dataout]=Pixel_Integration(CellArrayImages, filename, directoryname,Outside_Mask, Inside_Mask, RGBCustom, MSforNormBaselineStart, MSforNormBaselineEnd, FrameInterval);

%Integrates the change at each pixel over the entire course of the exposure
%and outputs one image
%
%                    >>> INPUT VARIABLES >>>
%
% NAME                  TYPE, DEFAULT           DESCRIPTION
% CellArrayImages                               Cell Array Containing the data
% filename                                      File name ending in .da
% directoryname                                 Directory in which file is located
% Inside_Mask                                   Mask are area inside of the slice
% Outside_Mask                                  Mask are area outside of the slice
% RGBCustom                                     Colormap
% MSforNormBaselineStart                        Amount of time to use for Normalizing Purposes
% MSforNormBaselineEnd                          Amount of time to use for Normalizing Purposes 
% FrameInterval                                 Time between samples
%
%                    <<< OUTPUT VARIABLES <<<
%
% NAME                 TYPE                    DESCRIPTION
% Dataout                                      Single Intergrated image
% 
%

%%%%%%%%%%%%%%%%%% Get data and its properties
Image_To_Integrate=CellArrayImages{1};
Frames=size(Image_To_Integrate,3);
Height=size(Image_To_Integrate,2);
Width=size(Image_To_Integrate,1);

Integrated_Holder=zeros(Width,Height);                   %%% Allocating memory

BaseLine=FrameAverage(Image_To_Integrate,MSforNormBaselineStart/FrameInterval, MSforNormBaselineEnd/FrameInterval);  % Baseline average within normalization window
        
        % Averages multiple frames into one output frame

        %                    >>> INPUT VARIABLES >>>
        %
        % NAME                        TYPE, DEFAULT                   DESCRIPTION
        % Input                                                       Matrix (NOT CELL ARRAY) to get the frames from
        % StartFrame                                                  First Frame to Avergae
        % EndFrame                                                    Last Frame to Average
        %                       <<< OUTPUT VARIABLES <<<
        %
        % NAME                      TYPE                              DESCRIPTION
        % Averaged Frame                                              Output averaged frame
        % 


for frame=1:Frames
    This_Image=Image_To_Integrate(:,:,frame);
    Integrated_Holder=Integrated_Holder+abs((This_Image-BaseLine)/Frames);
    
end
        Max=max(max(max(Integrated_Holder(Inside_Mask))));
        Min=min(min(min(Integrated_Holder(Inside_Mask))));
        step=254/(Max-Min);
        Integrated_Holder_Fixed=Integrated_Holder;
        
        MaxFixed=0.155;
        MinFixed=0.02;
        StepFixed=254/(MaxFixed-MinFixed);
        Integrated_Holder_Fixed(Inside_Mask)=(Integrated_Holder_Fixed(Inside_Mask)-MinFixed)*StepFixed;
        Integrated_Holder(Inside_Mask)=(Integrated_Holder(Inside_Mask)-Min)*step;
        
        image(Integrated_Holder, 'CDataMapping','scaled');
        imagefilename=sprintf('%s/%s', directoryname,filename);
        imagefilename1=strrep(imagefilename, '.da', '_Integrated.tif');
        imagefilenamefixed=strrep(imagefilename,'.da','_Integrated_Fixed.tif');
        tiffcomments=sprintf('Date = %s , Inside Mask Minimum = %f, Inside Mask Maximum = %f, Color Scale Step = %f ',filename, Min, Max, step); 
        tiffcomments1=sprintf('Date = %s , Inside Mask Minimum = %f, Inside Mask Maximum = %f, Color Scale Step = %f ',filename, MinFixed, MaxFixed, StepFixed); 
        imwrite(Integrated_Holder, RGBCustom, imagefilename1, 'Description', tiffcomments, 'Compression', 'none'); 
        imwrite(Integrated_Holder_Fixed, RGBCustom, imagefilenamefixed, 'Description', tiffcomments1, 'Compression', 'none'); 
        dataout=1;
end
