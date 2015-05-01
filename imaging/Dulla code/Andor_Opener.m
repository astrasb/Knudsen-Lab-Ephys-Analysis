function [CellArrayImages, FrameTimes,TraceData, FrameInterval]=Andor_Opener(masterdata, ThisExposure)
Images=masterdata.images(1,ThisExposure).data;
FrameTimes=masterdata.imagetimes;
TraceData=masterdata.subsampleddata(ThisExposure,:);
FrameInterval=masterdata.imagetimes(1,1);
shuttertest=mean(mean(Images(1:32,:,:)));
shuttertest=squeeze(shuttertest);
shutterderiv=diff(shuttertest);
[dmax, shutteropen]=max(shutterderiv(100:size(shutterderiv,1))); 
[Smin, shutterclose]=min(shutterderiv(100:size(shutterderiv,1)));
shutteropen=shutteropen+100;
shutterclose=shutterclose+100;
[darkframe]=FrameAverage(Images, shutteropen-round(shutteropen/2), shutteropen-1);
TempHolder=zeros(size(Images,1),size(Images,2));

 
   

for thisFrame=1:size(Images,3)                                         %%%%%%%%%%%%%%%%%%% Reshapes each frame into X and Y dimensions
        datapoint=Images(:,:,thisFrame);
        Images(:,:,thisFrame)=datapoint-darkframe;
        
end
subzero=find(Images<0);
Images(subzero)=1;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%  Find Shutter Open and Close Times
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 
  ImagesOut=Images(:,:,shutteropen+25:shutterclose-25);
  FrameTimes=FrameTimes(shutteropen+25:shutterclose-25);
  TraceData=TraceData(shutteropen+25:shutterclose-25);
CellArrayImages{1}=ImagesOut;
end