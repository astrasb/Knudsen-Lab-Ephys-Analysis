function [CellArrayImages]=Apply_Mask(Images,ThisExposure, Inside_Mask, Outside_Mask,DoesThisCellArrayObjectContainData);
%masks area outside of the slice mask with the zeros
%
%                    >>> INPUT VARIABLES >>>
%
% NAME                  TYPE, DEFAULT           DESCRIPTION
% Images                                        Cell Array Containing the data
% ThisExposure                                  Cell within the cell array to get the data from
% Inside_Mask                                   Mask are area inside of the slice
% Outside_Mask                                  Mask are area outside of the slice
% DoesThisCellArrayObjectContainData            Flag for empty dataset
%
%                    <<< OUTPUT VARIABLES <<<
%
% NAME                 TYPE                    DESCRIPTION
% CellArrayImages                              Cell Array Containing the filtered data
% 
%
        


%%%%%%%%%%%%%%% Because redshirt images don't need shutter detection SOV
%%%%%%%%%%%%%%% and SCV are set to the starting and ending frame numbers
OpenImages=Images{ThisExposure};
Frames=size(OpenImages,3);
Height=size(OpenImages,2);
Width=size(OpenImages,1);

if DoesThisCellArrayObjectContainData(ThisExposure)>0 %This is a check for empty exposures in the cooke camera
    
for thisframe=1:Frames
        Pre_Threshold=OpenImages(:,:,thisframe);
        if Outside_Mask>0
        Pre_Threshold(Outside_Mask)=0;  
        end
        OpenImages(:,:,thisframe)=Pre_Threshold;
end
else
    Ratio=0;
end
    disp ('Image Masking Complete');
if ThisExposure==1
    CellArrayImages={OpenImages};
else
    CellArrayImages=[CellArrayImages; OpenImages];
end

disp ('Ratioing Complete');
clear Images;
end