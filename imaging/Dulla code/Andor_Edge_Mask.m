function [Inside_Mask, Outside_Mask]=Erode_Mask(Images, ThisExposure, Mask, Erosion_Factor,Clip, Clip_Bottom_Extra, Additional_Mask_Points, Additional_Points)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% **  function
% [Inside_Mask, Outside_Mask]=Erode_Mask(Images, ThisExposure, Mask, Erosion_Factor)

% Erodes the mask to smooth it

%                    >>> INPUT VARIABLES >>>
%
% NAME                        TYPE, DEFAULT                   DESCRIPTION
% Images                                                      Cell Arraylocation of the image data
% ThisExposure                                                Which cell in the array to open
% Mask                                                        Raw Mask
% Erosion_Factor                                              Sets the size of the erosion structure element
% Clip                                                        Number of pixels to clip on each edge
%                    <<< OUTPUT VARIABLES <<<
%
% NAME                      TYPE                        DESCRIPTION
% Inside_Mask                                           Mask of the slice area
% Ouside_Mask                                           Mask where there is no slice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OpenImages=Images{ThisExposure};       %%%%%%%%%%% Open Images and get size properties
Frames=size(OpenImages,3);
Height=size(OpenImages,1);
Width=size(OpenImages,2);

tempmask=ones(Height,Width);          %%%%%%%%%%% Allocate memory for the new mask
                    %%%%%%%%%%% Set all pixels in the new mask = 1

tempmask(1:Clip,:)=0;                    %%%%%%%%%%% Clips the edges
tempmask(Height-Clip_Bottom_Extra+1:Height,:)=0;
tempmask(:,1:Clip)=0;
tempmask(:,Width-Clip+1:Width)=0;



Inside_Mask=find(tempmask>0);       %%%%%%%%%%% Create the eroded masks
Outside_Mask=find(tempmask==0);

end