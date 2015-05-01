function [out_Images, Subtracted_Image]=Variable_Integrater(CellArrayImages, TraceData, FrameTimes,FrameInterval, Start_Stim_Epoch,End_Stim_Epoch,stim );


figure (1);

this_image=CellArrayImages{1};
this_trace=TraceData;
time_trace=FrameTimes;
FrameInterval=FrameInterval;
  ExposureNumber=1;


  
topI=this_image(1:40,:,:);
bottomI=this_image(41:80,:,:);


  

prestim=mean(topI(:,:,stim-floor(75/FrameInterval):stim-floor(25/FrameInterval)),3);
  prestimb=mean(bottomI(:,:,stim-floor(75/FrameInterval):stim-floor(25/FrameInterval)),3);
  prestim_image=prestim./prestimb;


holder=0;
for i=floor(Start_Stim_Epoch/FrameInterval):floor(End_Stim_Epoch/FrameInterval);
poststim=(topI(:,:,stim+i));
poststimb=(bottomI(:,:,stim+i));
poststim_image=poststim./poststimb;
final=poststim_image-prestim_image;
holder=holder+final;

Subtracted_Image=holder;
out_Images=1;
end
end