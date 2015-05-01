function [ImagesOut]=Gaussian_Filter_streamlined(Images, MatrixSize, GaussianValue)
 
%Applies a Gaussian filter to an image array
%
%                    >>> INPUT VARIABLES >>>
%
% NAME                  TYPE, DEFAULT           DESCRIPTION
% CellArrayImages                               Cell Array Containing the data
% Matrix Size                                   Size of the structure element used in filtering
% exposure                                      Cell within the Cell Array to get data from
% GaussianValue                                 Parameter of gaussian filter
% 
%                    <<< OUTPUT VARIABLES <<<
%
% NAME                 TYPE                    DESCRIPTION
% CellArrayImages                              Cell Array Containing the filtered data
% 
%

tempimage=Images; %enables cell array matrix processing
Frames=size(tempimage,3);
Height=size(tempimage,2);
Width=size(tempimage,1);
ImagesOut=zeros(Width,Height,Frames);
H=fspecial('Gaussian', [MatrixSize MatrixSize], GaussianValue); 
for frame=1:Frames
       
        tempimage2=tempimage(:,:,frame);
        tempimage2=imfilter(tempimage2, H);
        ImagesOut(:,:,frame)=tempimage2;
             
end
end