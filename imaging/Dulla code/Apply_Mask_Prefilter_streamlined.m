function [Images]=Apply_Mask_PreFilter_streamlined(Images, Inside_Mask, Outside_Mask);
% **  function [CellArrayImages]=Apply_Mask_PreFilter(Images,ThisExposure, Inside_Mask, Outside_Mask,DoesThisCellArrayObjectContainData);
%
%masks area outside of the slice mask with the average intensity inside the mask
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

%%%%%%%%%%%%%%% Getting the data and its properties

OpenImages=Images;
Frames=size(OpenImages,3);
Height=size(OpenImages,2);
Width=size(OpenImages,1);

avevalue=mean(mean(OpenImages(Width/4:(Width/4)*3,Height/4:(Height/4)*3,1)));  % value to fill outside the mask
for thisframe=1:Frames
    Pre_Threshold=OpenImages(:,:,thisframe);
    Pre_Threshold(Outside_Mask)=avevalue;  
    Images(:,:,thisframe)=Pre_Threshold;
end
disp ('Ratioing Complete');
end