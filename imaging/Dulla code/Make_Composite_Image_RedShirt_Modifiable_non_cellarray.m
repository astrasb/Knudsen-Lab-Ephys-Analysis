function [out_Images, Subtracted_Image]=Make_Composite_Image_RedShirt_Modifiable_non_cellarray(CellArrayImages, TraceData, FrameTimes,FrameInterval, Start_Stim_Epoch,End_Stim_Epoch,stim );
[RGBCustomInverted]=CreateRGBColorTableInverted;
[RGBCustom]=CreateRGBColorTable;

figure (1);

this_image=CellArrayImages;
this_trace=TraceData;
time_trace=FrameTimes;
FrameInterval=FrameInterval;
  ExposureNumber=1;
this_image=CellArrayImages;



  

  prestim=mean(this_image(:,:,stim-floor(75/FrameInterval):stim-floor(25/FrameInterval)),3);
  
  
poststim=mean(this_image(:,:,stim+floor(Start_Stim_Epoch/FrameInterval):stim+floor(End_Stim_Epoch/FrameInterval)),3);
final=poststim-prestim;
final_for_plotting=final;
final_clear=find(final>0.2);
final_clear_low=find(final<-1);
final_for_plotting(final_clear_low)=0;
final_for_plotting(final_clear)=0;
Subtracted_Image=final;
out_Images=1;
end