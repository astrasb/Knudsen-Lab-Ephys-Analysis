function [out_Images, Subtracted_Image]=Make_Composite_Image_RedShirt_Modifiable(CellArrayImages, TraceData, FrameTimes,FrameInterval, Start_Stim_Epoch,End_Stim_Epoch,stim );
[RGBCustomInverted]=CreateRGBColorTableInverted;
[RGBCustom]=CreateRGBColorTable;

figure (1);

this_image=CellArrayImages{1};
this_trace=TraceData;
time_trace=FrameTimes;
FrameInterval=FrameInterval;
  ExposureNumber=1;
this_image=CellArrayImages{1};
topI=this_image(1:40,:,:);
bottomI=this_image(41:80,:,:);


  

  prestim=mean(topI(:,:,stim-floor(75/FrameInterval):stim-floor(25/FrameInterval)),3);
  prestimb=mean(bottomI(:,:,stim-floor(75/FrameInterval):stim-floor(25/FrameInterval)),3);
  prestim_image=prestim./prestimb;
  
poststim=mean(topI(:,:,stim+floor(Start_Stim_Epoch/FrameInterval):stim+floor(End_Stim_Epoch/FrameInterval)),3);
poststimb=mean(bottomI(:,:,stim+floor(Start_Stim_Epoch/FrameInterval):stim+floor(End_Stim_Epoch/FrameInterval)),3);

%poststim=mean(topI(:,:,((stim+Start_Stim_Epoch)/FrameInterval:(stim+End_Stim_Epoch/FrameInterval)),3));
%poststimb=mean(bottomI(:,:,((stim+Start_Stim_Epoch)/FrameInterval:(stim+End_Stim_Epoch)/FrameInterval),3));
poststim_image=poststim./poststimb;
final=poststim_image-prestim_image;
final_for_plotting=final;
final_clear=find(final>0.2);
final_clear_low=find(final<-1);
final_for_plotting(final_clear_low)=0;
final_for_plotting(final_clear)=0;
subplot(2,1,1)
image(final_for_plotting,'cdatamapping','scaled')
axis image;
%subplot(2,1,2)
 % image(this_image(1:40,:,500),'cdatamapping','scaled')  
  %axis image;
Subtracted_Image=final;
out_Images=1;
end