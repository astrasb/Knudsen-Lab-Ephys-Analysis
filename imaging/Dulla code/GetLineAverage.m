function [LineData, TimeStretchedLineData]=GetLineAverage(ExposureNumber,Frames,NormalizedImage,ShutterOpenValues, ShutterCloseValues, filename, AdjustedTime, RGBCustom);
for exposure=1:ExposureNumber
    clear LineHolder;
    if ShutterOpenValues(exposure)>1
    temp=NormalizedImage{exposure};
    ShutterOpenTime=AdjustedTime(ShutterOpenValues(exposure),exposure);
    ShutterCloseTime=AdjustedTime(ShutterCloseValues(exposure),exposure);
    
    for frame=1:ShutterCloseValues(exposure)-ShutterOpenValues(exposure)
        temp2=temp(:,:,frame);
        temp3=mean(temp2');
        LineHolder(:,frame)=temp3;
        CurrentTime=AdjustedTime(frame+ShutterOpenValues(exposure)-1,exposure);
        NextTime=AdjustedTime(frame+ShutterOpenValues(exposure),exposure);
        for FillLine=CurrentTime-ShutterOpenTime:NextTime-ShutterOpenTime
            TimeStretched(:,FillLine+1)=temp3;
        end
  
    end
    LineData(exposure)={LineHolder};
    TimeStretchedLineData(exposure)={TimeStretched};




       %%%%%%%%% Creats Images using a Figure Command
        figure ('Colormap', RGBCustom);
        image (LineHolder,'CDataMapping', 'scaled');
        axis image;
        axis off;
        LineFileName=sprintf ('%s/LinePlot_%d',filename, exposure);
        print ('-dtiff', LineFileName);
        close;
        figure ('Colormap', RGBCustom);
        image (TimeStretched,'CDataMapping', 'scaled');
        LineFileName=sprintf ('%s/TimeStreched_LinePlot_%d',filename, exposure);
        print ('-dtiff', LineFileName);
        close;
end
end
end