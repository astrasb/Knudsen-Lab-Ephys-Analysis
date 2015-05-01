function [Tstd, Tmean]=DetermineImageSTD_MEAN(Input, MSforNormBaselineStart, MSforNormBaselineEnd, FrameInterval);

%%%%%%%%%%%%%%% Make Set ROI for treshhold setting
tempimage=Input{1};
NumberofFrames=size(tempimage,3);
LeftROI=size(tempimage,2)/4;
RightROI=3*size(tempimage,2)/4;
TopROI=size(tempimage,1)/4;
BottomROI=3*size(tempimage,1)/4;
StartFrames=MSforNormBaselineStart/FrameInterval;
EndFrames=MSforNormBaselineEnd/FrameInterval;

%%%%%%%%%%%%% Calculating the threshold values
Tstd=std(std(std(tempimage(TopROI:BottomROI,LeftROI:RightROI,StartFrames:EndFrames))));
Tmean=mean(mean(mean(tempimage(TopROI:BottomROI,LeftROI:RightROI,StartFrames:EndFrames))));
