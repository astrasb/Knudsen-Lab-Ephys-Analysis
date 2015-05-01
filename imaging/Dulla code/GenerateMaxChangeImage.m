%Print out the image of the maximum response
function [Done]=GenerateMaxChangeImage(Input,
tstemp=Input{1};

timeseriestemp=mean(mean(tstemp(Width/4:3*Width/4,Height/3:2*Height/3,:)));
timeseriestmep=squeeze(timeseriestemp);
minpoint=min(timeseriestemp);
minpointframe=find(timeseriestemp==minpoint);
StartFrame=minpointframe;
Offsetfactor=250;
MaxTemp=tstemp(:,:,StartFrame);
MaxTempCell{1}=MaxTemp;
[MinCutoff, Step]=AutoScaleMakeTiffsBatch(MaxTempCell, filename,'max', ExposureNumber,RGBCustom,  0, Offsetfactor);
% Create Output Text File
