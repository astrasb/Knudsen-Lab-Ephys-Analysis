function [Inside_Mask, Outside_Mask]=Erode_Mask_non_cellarray(Images, ThisExposure, Mask, Erosion_Factor,Clip, Clip_Bottom_Extra, Additional_Mask_Points, Additional_Points)
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

OpenImages=Images;       %%%%%%%%%%% Open Images and get size properties
Frames=size(OpenImages,3);
Height=size(OpenImages,2);
Width=size(OpenImages,1);

tempmask=zeros(Height,Width);          %%%%%%%%%%% Allocate memory for the new mask
tempmask(Mask)=1;                      %%%%%%%%%%% Set all pixels in the new mask = 1

if 2>3 %%%%%%%%%%%%%%%% Pre-dialation of mask
se = strel('square',5);
tempmask=imdilate(tempmask,se);
end

se=strel('square',Erosion_Factor);
Eroded_Mask=imerode(tempmask, se);     %%%%%%%%%%% Double erosion
Eroded_Mask=imerode(Eroded_Mask, se);

Eroded_Mask(1:Clip,:)=0;                    %%%%%%%%%%% Clips the edges
%Eroded_Mask(Height-Clip+1:Height,:)=0;
Eroded_Mask(Height-Clip_Bottom_Extra+1:Height,:)=0;
Eroded_Mask(:,1:Clip)=0;
Eroded_Mask(:,Width-Clip+1:Width)=0;

if Additional_Mask_Points>0
for i=0:Additional_Mask_Points-1              %%%%%%%%%%% Clips extra individual points contained in the array Additional_Points (Y1,X1,Y2,X2....)
    Y_Coord=Additional_Points(i*2+1);
    X_Coord=Additional_Points(i*2+2);
    Eroded_Mask(Y_Coord,X_Coord)=0;
end
end

Inside_Mask=find(Eroded_Mask>0);       %%%%%%%%%%% Create the eroded masks
Outside_Mask=find(Eroded_Mask==0);

end