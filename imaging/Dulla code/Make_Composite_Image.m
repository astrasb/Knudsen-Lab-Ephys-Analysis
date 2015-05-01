function [out_Images]=Make_Composite_Image(masterdata);


figure (1);

this_image=masterdata.images(1,1).imageData;
this_trace=masterdata.subsampleddata(1,:);
time_trace=masterdata.imagetimes;
FrameInterval=masterdata.imagetimes(1,1);
  ExposureNumber=size((masterdata.images),2);
  maxtrial=double(int16(ExposureNumber/5))
if maxtrial<2
    maxtrial=2;
end
shuttertest=mean(mean(this_image(1:32,:,:)));
shuttertest=squeeze(shuttertest);
shutterderiv=diff(shuttertest);
[dmax, shutteropen]=max(shutterderiv); 
[Smin, shutterclose]=min(shutterderiv);
if shutterclose<1000
    shutterclose=3500;
end
[darkframe]=FrameAverage(this_image, shutteropen-shutteropen/2, shutteropen-1);
TempHolder=zeros(size(this_image,1),size(this_image,2));

for thisFrame=1:size(this_image,3)                                         %%%%%%%%%%%%%%%%%%% Reshapes each frame into X and Y dimensions
        datapoint=this_image(:,:,thisFrame);
        this_image(:,:,thisFrame)=datapoint-darkframe;
        
end
  ImagesOut=this_image(:,:,shutteropen+25:shutterclose-25);
  FrameTimes=time_trace(shutteropen+25:shutterclose-25);
  TraceData=this_trace(shutteropen+25:shutterclose-25);
 topI=ImagesOut(1:32,:,:);
bottomI=ImagesOut(33:64,:,:);
sm_trace=smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(squeeze(mean(mean(topI)))))))))))))))))));
dx=diff(sm_trace);
dy=diff(FrameTimes);
derivd=smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(dx./dy')))))))))))))))))))));
derivd=derivd(100:(size(derivd)-1500));
[val stim]=min(derivd);
stim=stim+100;
for Exposure=1:maxtrial
subplot(maxtrial,1,Exposure);   
this_image=masterdata.images(1,Exposure).imageData;
this_trace=masterdata.subsampleddata(Exposure,:);
time_trace=masterdata.imagetimes;
FrameInterval=masterdata.imagetimes(1,1);
  
shuttertest=mean(mean(this_image(1:32,:,:)));
shuttertest=squeeze(shuttertest);
shutterderiv=diff(shuttertest);
[dmax, shutteropen]=max(shutterderiv); 
[Smin, shutterclose]=min(shutterderiv);
[darkframe]=FrameAverage(this_image, shutteropen-shutteropen/2, shutteropen-1);
TempHolder=zeros(size(this_image,1),size(this_image,2));

for thisFrame=1:size(this_image,3)                                         %%%%%%%%%%%%%%%%%%% Reshapes each frame into X and Y dimensions
        datapoint=this_image(:,:,thisFrame);
        this_image(:,:,thisFrame)=datapoint-darkframe;
        
end
  ImagesOut=this_image(:,:,shutteropen+25:shutterclose-25);
  FrameTimes=time_trace(shutteropen+25:shutterclose-25);
  TraceData=this_trace(shutteropen+25:shutterclose-25);
 topI=ImagesOut(1:32,:,:);
bottomI=ImagesOut(33:64,:,:);

prestim=mean(topI(:,:,stim-75:stim-25),3);
  prestimb=mean(bottomI(:,:,stim-75:stim-25),3);
  prestim_image=prestim./prestimb;

poststim=mean(topI(:,:,stim+25:stim+75),3);
poststimb=mean(bottomI(:,:,stim+25:stim+75),3);
poststim_image=poststim./poststimb;
final=poststim_image-prestim_image;
image(final,'cdatamapping','scaled')
axis image;
colormap(hsv(128));

  
end
out_Images=1;
end