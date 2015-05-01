function[ThresholdedImages, Thresholded_Unmasked]=Threshold_Image_Creation(CellArrayImages, NumberofThresholds, filename,directoryname,Tmean, Tstd,ThisThreshold, Starting_Fret_Ratio_for_Thresholds);
tempimage=CellArrayImages{1};
Frames=size(tempimage,3);
Height=size(tempimage,2);
Width=size(tempimage,1);
STDFactor=10;
ThreshValue=Starting_Fret_Ratio_for_Thresholds-((ThisThreshold)*.10);
tempimage_Unmasked=zeros(Width,Height,Frames);

    
    for thisframe=1:Frames
        Pre_Threshold=tempimage(:,:,thisframe);
        Pre_Threshold_Unmasked_Image=tempimage(:,:,thisframe);
        AboveThreshValue=find(Pre_Threshold>ThreshValue);
        BelowThreshValue=find(Pre_Threshold<ThreshValue);
        Pre_Threshold(AboveThreshValue)=2;
        Pre_Threshold_Unmasked_Image(AboveThreshValue)=0;
        %Pre_Threshold(BelowThreshValue)=255;
        tempimage(:,:,thisframe)=Pre_Threshold;
        tempimage_Unmasked(:,:,thisframe)=Pre_Threshold_Unmasked_Image;
    end
ThresholdedImages{1}=tempimage;
Thresholded_Unmasked{1}=tempimage_Unmasked;



end