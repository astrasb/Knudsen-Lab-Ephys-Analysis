function [Tstd, Tmean]=DetermineThisThreshold(Input);

%%%%%%%%%%%%%%% Make Set ROI for treshhold setting
tempimage=Input{1};

LeftROI=size(tempimage,2)/4;
RightROI=3*size(tempimage,2)/4;
TopROI=size(tempimage,1)/4;
BottomROI=3*size(tempimage,1)/4;
StartFrames=size(tempimage,3)/50;
EndFrames=5*(size(tempimage,3)/50);

%%%%%%%%%%%%% Calculating the threshold values
Tstd=std(std(std(tempimage(TopROI:BottomROI,LeftROI:RightROI,StartFrames:EndFrames))));
Tmean=mean(mean(mean(tempimage(TopROI:BottomROI,LeftROI:RightROI,IgnoreFirstXFrames:IgnoreFirstXFrames*2))));
