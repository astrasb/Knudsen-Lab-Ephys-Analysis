function [out_Images, Subtracted_Image]=Make_Composite_Image_RedShirt(CellArrayImages, TraceData, FrameTimes,FrameInterval );


figure (1);

this_image=CellArrayImages{1};
this_trace=TraceData;
time_trace=FrameTimes;
FrameInterval=FrameInterval;
  ExposureNumber=1;


  
topI=this_image(1:40,:,:);
bottomI=this_image(41:80,:,:);
sm_trace=smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(squeeze(mean(mean(topI)))))))))))))))))));
dx=diff(sm_trace);
dy=diff(FrameTimes);
derivd=smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(dx./dy')))))))))))))))))))));
derivd=derivd(100:(size(derivd)-1500));
[val stim]=min(derivd);
stim=stim+100;



  

prestim=mean(topI(:,:,stim-75:stim-25),3);
  prestimb=mean(bottomI(:,:,stim-75:stim-25),3);
  prestim_image=prestim./prestimb;

poststim=mean(topI(:,:,stim+25:stim+75),3);
poststimb=mean(bottomI(:,:,stim+25:stim+75),3);
poststim_image=poststim./poststimb;
final=poststim_image-prestim_image;
final_clear=find(final>0.2);
final_clear_low=find(final<-0.2);
final(final_clear_low)=0;
final(final_clear)=0;
subplot(2,1,1)
image(final,'cdatamapping','scaled')
axis image;
colormap(hsv(128));
%subplot(2,1,2)
 % image(this_image(1:40,:,500),'cdatamapping','scaled')  
  %axis image;
Subtracted_Image=final;
out_Images=1;
end