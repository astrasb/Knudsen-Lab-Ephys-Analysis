function [FRatio]=InvertedTakeTheRatio(Images,ThisExposure, DoesThisCellArrayObjectContainData);
% **  function
% [FRatio]=TakeTheRatio(Images,ThisExposure, DoesThisCellArrayObjectContainData)

% 1. Loads data from a cell array 
% 2. Takes the Ratio
% 3. Outputs the ratioed data into the cell array FRatio

%                    >>> INPUT VARIABLES >>>
%
% NAME                        TYPE, DEFAULT                   DESCRIPTION
% Images                                                      Cell Array location of the Raw data
% ThisExposure                                                Cell within the array to grab the data from
% DoesThisCellArrayObjectContainData                          Flag if there is data present
%   
%                   <<< OUTPUT VARIABLES <<<
%
% NAME                      TYPE                        DESCRIPTION
% FRatio                                                Cell Array containing the ratioed data
% 

%%%%%%%%%%%%%%% Loading the data and getting its properties

OpenImages=Images{ThisExposure};
Frames=size(OpenImages,3);
Height=size(OpenImages,2);
Width=size(OpenImages,1);

%%%% Take the ratio
if DoesThisCellArrayObjectContainData(ThisExposure)>0 %This is a check for empty exposures in the cooke camera
   Ch1 = OpenImages(1:Width/2,1:Height,:);
   Ch2 = OpenImages(Width/2+1:Width,1:Height,:);
   Ratio=Ch2./Ch1;
else
    Ratio=0;
end
    disp ('Image Masking Complete');
if ThisExposure==1
    FRatio={Ratio};
else
    FRatio=[FRatio; Ratio];
end

disp ('Ratioing Complete');
clear Images;
end


