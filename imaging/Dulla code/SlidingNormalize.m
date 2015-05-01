function[NormalizedImage]=SlidingNormalize(AveStartImages,AveEndImages,Images,FrameTimes,  ExposureNumber, IgnoreFirstXFrames)

for exposure=1:ExposureNumber
    tempStart=Images{exposure};
    Frames=size(tempStart,3);
    Height=size(tempStart,2);
    Width=size(tempStart,1);
    StartAveragedFrame=AveStartImages{exposure};
    EndAveragedFrame=AveEndImages{exposure};
    clear Normalized;
    DoesThisCellArrayObjectContainData=1;
    if DoesThisCellArrayObjectContainData(exposure)>0 %This is a check for empty exposures in the cooke camera
        Normalize=zeros(Width,Height,Frames-IgnoreFirstXFrames);
        StartTime=FrameTimes(exposure, IgnoreFirstXFrames);
        EndTime=FrameTimes(exposure, Frames-IgnoreFirstXFrames);
        for i=IgnoreFirstXFrames:Frames-IgnoreFirstXFrames
            ThisFrame=tempStart(:,:,i);
            ThisTime=FrameTimes(exposure, i);
            TimeRelativeToStart=(EndTime-ThisTime)/(EndTime-StartTime);
            TimeRelativeToEnd=1-TimeRelativeToStart;
            tempFrame=StartAveragedFrame*TimeRelativeToStart+EndAveragedFrame*TimeRelativeToEnd;
            NormFrame=ThisFrame-tempFrame+mean(mean(mean(StartAveragedFrame(Width/4:3*Width/4,Height/8:7*Height/8))));
            Normalized(:,:,i-IgnoreFirstXFrames+1)=NormFrame;
            fprintf('Exposure %d Normalized', i);
            disp ('NEXT');
        end
     
        if exposure==1
              NormalizedImage = {Normalized};
        else
              NormalizedImage =[NormalizedImage; Normalized];
        end 
    else
       if exposure==1
            NormalizedImage = {0};
       else
            NormalizedImage =[NormalizedImage; 0];
       end
       fprintf('Exposure %d Empty', exposure);
       fprintf('');
    end
end
end
