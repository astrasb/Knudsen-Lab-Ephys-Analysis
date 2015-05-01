function [out_Images]=Make_Composite_Image_Andor(CellArrayData, StimTime, FrameInterval,timewindow);
Images=CellArrayData{1};

prestim=mean(Images(:,:,StimTime/FrameInterval-100/FrameInterval:StimTime/FrameInterval-20/FrameInterval),3);
poststim=mean(Images(:,:,StimTime/FrameInterval:StimTime/FrameInterval+timewindow/FrameInterval),3);
final=poststim-prestim;
image(final,'cdatamapping','scaled')
axis image;
colormap(hsv(128));

  

out_Images=1;
end