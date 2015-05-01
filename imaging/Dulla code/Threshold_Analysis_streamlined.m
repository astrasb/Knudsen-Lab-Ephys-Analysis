function [dataout, dataout_AIT,dataout_AIT_NS, dataout_MIT, dataout_Filtered_Max]=Threshold_Analysis_streamlined(Input, NumberofThresholds, MSforNormBaselineStart, MSforNormBaselineEnd, filename, FrameInterval,directoryname,Outside_Mask, Inside_Mask,Starting_Fret_Ratio_for_Thresholds,FrameTimes,TraceData );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Consturcting output .mat file data matrix %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataout_Filtered_Max=[FrameTimes;TraceData(1,:)];
dataout=[FrameTimes;TraceData(1,:)];
dataout_AIT=[FrameTimes;TraceData(1,:)];
dataout_AIT_NS=[FrameTimes;TraceData(1,:)];
dataout_MIT=[FrameTimes;TraceData(1,:)];

%%%%%%%%%%%%%%% Make Set ROI for treshhold setting
tempimage=Input;
Frames=size(tempimage,3);
Height=size(tempimage,2);
Width=size(tempimage,1);

frame_base=FrameAverage(tempimage,MSforNormBaselineStart/FrameInterval, MSforNormBaselineEnd/FrameInterval);
BaselineFretIntensity=mean(frame_base(Inside_Mask));
    

for ThresholdCycle=1:NumberofThresholds
    
    for frame=1:size(tempimage,3)
        tempframethresh=tempimage(:,:,frame);
        PixelsBelowThreshold1=find(tempframethresh<Starting_Fret_Ratio_for_Thresholds-((ThresholdCycle)*.10));
        PixelsBelowThreshold=size(PixelsBelowThreshold1,1)-size(Outside_Mask,1);
        PixelsBelowThreshold_no_zeroes=find((tempframethresh<Starting_Fret_Ratio_for_Thresholds-((ThresholdCycle)*.10)) & (tempframethresh>0));
        if size(tempframethresh(PixelsBelowThreshold_no_zeroes),1)>0
            Peak=min(min(tempframethresh(PixelsBelowThreshold_no_zeroes)));
            Max_Intensity_Within_Threshold=-(min(tempframethresh(PixelsBelowThreshold_no_zeroes))-BaselineFretIntensity);
            Ave_Intensity_Within_Threshold=-(sum(tempframethresh(PixelsBelowThreshold_no_zeroes))/size(tempframethresh(PixelsBelowThreshold_no_zeroes),1)-BaselineFretIntensity);
            Ave_Intensity_Within_Threshold_NOSUBTRACTION=-(sum(tempframethresh(PixelsBelowThreshold_no_zeroes))/size(tempframethresh(PixelsBelowThreshold_no_zeroes),1));
            
        else
            Peak=0;
            Max_Intensity_Within_Threshold=0;
            Ave_Intensity_Within_Threshold=0;
            Ave_Intensity_Within_Threshold_NOSUBTRACTION=0;
        end
        
        if frame==1
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
    dataout = [dataout; PBT'];
    dataout_Filtered_Max=[dataout_Filtered_Max; Filtered_Max'];
    dataout_AIT=[dataout_AIT; AIT'];
    dataout_MIT=[dataout_MIT; MIT'];
    dataout_AIT_NS=[dataout_AIT_NS; AIT_NS'];
    
    
    
   
end
end

