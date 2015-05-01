function [PBT,AIT,MIT,Filtered_Max, AIT_NS]=ThresholdCounter(ImagesToThreshold, tempimage_max, Tmean, Tstd, Start, End, STDFactor,ThresholdCycle, Outside_Mask,Starting_Fret_Ratio_for_Thresholds,BaselineFretIntensity );
for frame=Start:End
tempframethresh=ImagesToThreshold(:,:,frame);
tempimage_frame=tempimage_max(:,:,frame);
PixelsBelowThreshold1=find(tempframethresh<Starting_Fret_Ratio_for_Thresholds-((ThresholdCycle)*.10));
PixelsBelowThreshold=size(PixelsBelowThreshold1,1)-size(Outside_Mask,1);
PixelsBelowThreshold_no_zeroes=find((tempframethresh<Starting_Fret_Ratio_for_Thresholds-((ThresholdCycle)*.10)) & (tempframethresh>0));
if size(tempframethresh(PixelsBelowThreshold_no_zeroes),1)>0
Peak=min(min(tempimage_frame(PixelsBelowThreshold_no_zeroes)));
Max_Intensity_Within_Threshold=-(min(tempframethresh(PixelsBelowThreshold_no_zeroes))-BaselineFretIntensity);
Ave_Intensity_Within_Threshold=-(sum(tempframethresh(PixelsBelowThreshold_no_zeroes))/size(tempframethresh(PixelsBelowThreshold_no_zeroes),1)-BaselineFretIntensity);
Ave_Intensity_Within_Threshold_NOSUBTRACTION=-(sum(tempframethresh(PixelsBelowThreshold_no_zeroes))/size(tempframethresh(PixelsBelowThreshold_no_zeroes),1));

else
Peak=0;
Max_Intensity_Within_Threshold=0;
Ave_Intensity_Within_Threshold=0;
Ave_Intensity_Within_Threshold_NOSUBTRACTION=0;
end

if frame==Start
    Filtered_Max=Peak;
    PBT=PixelsBelowThreshold;
    AIT=Ave_Intensity_Within_Threshold;
    MIT=Max_Intensity_Within_Threshold;
    AIT_NS=Ave_Intensity_Within_Threshold_NOSUBTRACTION;
else
    Filtered_Max=[Filtered_Max; Peak];
    PBT=[PBT; PixelsBelowThreshold];  
    AIT=[AIT; Ave_Intensity_Within_Threshold];
    MIT=[MIT; Max_Intensity_Within_Threshold];
    AIT_NS=[AIT_NS; Ave_Intensity_Within_Threshold_NOSUBTRACTION];
end  
clear PixelsAboveThreshold1;
clear PixelsBelowThreshold1;

end

end
