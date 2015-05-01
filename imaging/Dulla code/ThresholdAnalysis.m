function [dataout]=Threshold_Analysis(Input, NumberofThresholds, Tmean, Tstd, dataout, MSforNormBaselineStart, MSforNormBaselineEnd, filename, FrameInterval,directoryname);

%%%%%%%%%%%%%%% Make Set ROI for treshhold setting
tempimage=Input{1};
Frames=size(tempimage,3);
Height=size(tempimage,2);
Width=size(tempimage,1);
IgnoreFirstXFrames=50/FrameInterval;
STDFactor=10;
decimatefactor=4;
 
for ThresholdCycle=1:NumberofThresholds

[PBT]=ThresholdCounter(tempimage, Tmean, Tstd, 1,Frames, STDFactor,ThresholdCycle);
dataout = [dataout; PBT'];
    [maxpixels, maxframe]=max(PBT);
    
    if maxframe<200
       
        baselinepixels=0;
        pixelchange=0;
        halframe=0;
        halftime=0;
        MinFretIntensity=0;
        BaselineFretIntensity=0; 
    else    
        baselinepixels=mean(PBT(MSforNormBaselineStart/FrameInterval:MSforNormBaselineEnd/FrameInterval));
        pixelchange=maxpixels-baselinepixels;
        halframe=find(PBT(maxframe:Frames)<(pixelchange/2+baselinepixels));   
        halfframetest=isempty(halframe);
        if halfframetest==1
             baselinepixels=0;
             pixelchange=0;
             halframe=0;
             halftime=0;
             MinFretIntensity=0;
             BaselineFretIntensity=0;
        else
        halftime=(halframe(1)+maxframe)*FrameInterval;
        MinFretIntensity=mean(mean(mean(tempimage(TopROI:BottomROI,LeftROI:RightROI,maxframe))));
        BaselineFretIntensity=mean(mean(mean(tempimage(TopROI:BottomROI,LeftROI:RightROI,MSforNormBaselineStart/FrameInterval:MSforNormBaselineEnd/FrameInterval))));
        dPBT=decimate(PBT,decimatefactor);
        end
        RiseTime10=find(dPBT>(baselinepixels+(pixelchange*0.1)));
        RiseTime90=find(dPBT>(baselinepixels+(pixelchange*0.9)));
        test90=isempty(RiseTime90);
            if test90==1
                 RT90=0;
                 RT10=0;
            else
            RT10=(RiseTime10(1)*decimatefactor)*FrameInterval;
            RT90=(RiseTime90(1)*decimatefactor)*FrameInterval;
            end
    end
if ThresholdCycle==1
    BaselinePixels=baselinepixels;
    PixelChange=pixelchange;
    MaxTime=(maxframe)*FrameInterval;
    HalfTime=halftime;
    MinFRETIntensity=MinFretIntensity;
    BaselineFRETIntensity=BaselineFretIntensity;
    Rise10=RT10;
    Rise90=RT90;
else
    BaselinePixels=[BaselinePixels; baselinepixels];
    PixelChange=[PixelChange;pixelchange];
    MaxTime=[MaxTime; (maxframe)*FrameInterval];
    HalfTime=[HalfTime; halftime];
    MinFRETIntensity=[MinFRETIntensity; MinFretIntensity];
    BaselineFRETIntensity=[BaselineFRETIntensity; BaselineFretIntensity];
    Rise10=[Rise10;RT10];
    Rise90=[Rise90; RT90];
    
end
    
end

figure (1);
set(1, 'PaperUnits', 'inches');
set(1, 'PaperPosition', [0.25 0.25 8.5 11] );


replacedmat='.mat';  %works if the file is in the current directory 
replacedda='.da';
replacedjpg='.jpg';

filenamejpeg=strrep(filename,replacedda,replacedjpg);
filenamemat=strrep(filename,replacedda,replacedmat);


for ThresholdCycle=1:NumberofThresholds
    Threshvalue=sprintf('Threshold Value = %.3f', Tmean-STDFactor*Tstd*((ThresholdCycle-1)*10));
    HalfTimevalue=sprintf('Half Life = %.3f', HalfTime(ThresholdCycle));
    subplot(NumberofThresholds+1,1,ThresholdCycle); 
    plot(dataout(1,:),dataout(ThresholdCycle+2,:), 'DisplayName', 'PBT', 'YDataSource', 'PAT');
    box off;
    xlabel('Time');
    ylabel('Pixels Below Treshhold');
    xL=xlim;
    yL=ylim;
    if ThresholdCycle==1
        text(xL(2)/2,yL(2),filename,'interpreter', 'none');
    end
    text(xL(1)/25,yL(2),Threshvalue);
    text(xL(2)-xL(2)/10,yL(2)-yL(2)/10,HalfTimevalue);
end

subplot(NumberofThresholds+1,1,NumberofThresholds+1);
plot(dataout(1,:),dataout(2,:));
%plot(tracewithtime(1,NormClippedParameters(1):NormClippedParameters(2)),tracewithtime(2,NormClippedParameters(1):NormClippedParameters(2)), 'DisplayName', 'PAT', 'YDataSource', 'PAT');
box off;
ylim([traceave-1 traceave+1]);
xlabel('Time');
ylabel('mV');

saveas(1, filenamejpeg);
save (filenamemat, 'dataout');
%print -P lj8500;
close;
ThresholdDone=1;

%Print out the image of the maximum response
tstemp=NormalizedImage{1};

timeseriestemp=mean(mean(tstemp(TopROI:BottomROI,LeftROI:RightROI,IgnoreFirstXFrames:Frames-IgnoreFirstXFrames*2)));
timeseriestmep=squeeze(timeseriestemp);
minpoint=min(timeseriestemp);
minpointframe=find(timeseriestemp==minpoint);
StartFrame=minpointframe+IgnoreFirstXFrames;
Offsetfactor=250;
MaxTemp=tstemp(:,:,StartFrame);
MaxTempCell{1}=MaxTemp;
[MinCutoff, Step]=AutoScaleMakeTiffsBatch(MaxTempCell, filename,'max', ExposureNumber,RGBCustom,  0, Offsetfactor);
% Create Output Text File
for ThresholdCycle=1:NumberofThresholds
    Tresh=Tmean-STDFactor*Tstd*((ThresholdCycle-1)*10);
    outstring=sprintf(('%s\t%.3f\t%f\t%.1f\t%.1f\t%.1f\t%.1f\t%.3f\t%.3f\t%.1f\t%.1f\n\r'), filename, Tresh, ThresholdCycle, BaselinePixels(ThresholdCycle), PixelChange(ThresholdCycle), HalfTime(ThresholdCycle), MinFRETIntensity(ThresholdCycle), MaxTime(ThresholdCycle), BaselineFRETIntensity(ThresholdCycle), Rise10(ThresholdCycle), Rise90(ThresholdCycle));
    outcout=fwrite(fidout, outstring);
end

status = fclose(fidout)
end

