function [dataout, dataout_AIT,dataout_AIT_NS, dataout_MIT, dataout_Filtered_Max]=Threshold_Analysis(Input, GaussianArrayImages_LargeFilterElement2, NumberofThresholds, dataout, dataout_AIT,dataout_AIT_NS, dataout_MIT, dataout_Filtered_Max, traceave, Tmean, Tstd, MSforNormBaselineStart, MSforNormBaselineEnd, filename, FrameInterval,directoryname,Outside_Mask, Inside_Mask,Starting_Fret_Ratio_for_Thresholds );

%%%%%%%%%%%%%%% Make Set ROI for treshhold setting
tempimage=Input{1};
tempimage_max=GaussianArrayImages_LargeFilterElement2{1};
Frames=size(tempimage,3);
Height=size(tempimage,2);
Width=size(tempimage,1);
IgnoreFirstXFrames=50/FrameInterval;
STDFactor=10;
decimatefactor=4;
intwidth=uint8(Width/4);
intheight=uint8(Height/3);
BaselineFretIntensity=mean(mean(mean(tempimage(intwidth:3*intwidth,intheight:2*intheight,MSforNormBaselineStart/FrameInterval:MSforNormBaselineEnd/FrameInterval))));
for ThresholdCycle=1:NumberofThresholds

[PBT,AIT,MIT,Filtered_Max,AIT_NS]=ThresholdCounter(tempimage, tempimage_max, Tmean, Tstd, 1,Frames, STDFactor,ThresholdCycle, Outside_Mask,Starting_Fret_Ratio_for_Thresholds,BaselineFretIntensity);
dataout = [dataout; PBT'];
dataout_Filtered_Max=[dataout_Filtered_Max; Filtered_Max'];
dataout_AIT=[dataout_AIT; AIT'];
dataout_MIT=[dataout_MIT; MIT'];
dataout_AIT_NS=[dataout_AIT_NS; AIT_NS'];

    [maxpixels, maxframe]=max(PBT);
    
    if maxframe<500/FrameInterval
       
        baselinepixels=0;
        pixelchange=0;
        halframe=0;
        halftime=0;
        MinFretIntensity=0;
        BaselineFretIntensity=0; 
        RT90=0;
        RT10=0;
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
             RT90=0;
             RT10=0;
            
        else
        halftime=(halframe(1)+maxframe)*FrameInterval;

        MinFretIntensity=mean(mean(mean(tempimage(intwidth:3*intwidth,intheight:2*intheight, maxframe))));
        
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
clear PBT;  
end

figure (1);
set(1, 'PaperUnits', 'inches');
set(1, 'PaperPosition', [0.25 0.25 8.5 11] );


replacedmat='.mat';  %works if the file is in the current directory 
replacedmat_AIT='_AIT.mat';
replacedmat_AIT_NS='_AIT_NS.mat';
replacedmat_MIT='_MIT.mat';
replacedmat_MAX='_MAX.mat';
replacedda='.da';
replacedjpg='.jpg';
filenamejpeg=sprintf('%s/%s', directoryname, filename);
filenamemat=sprintf('%s/%s', directoryname, filename);
filenamemat_AIT=sprintf('%s/%s', directoryname, filename);
filenamemat_AIT_NS=sprintf('%s/%s', directoryname, filename);
filenamemat_MIT=sprintf('%s/%s', directoryname, filename);
filenamemat_MAX=sprintf('%s/%s', directoryname, filename);
filenamejpeg=strrep(filenamejpeg,replacedda,replacedjpg);
filenamemat=strrep(filenamemat,replacedda,replacedmat);
filenamemat_AIT=strrep(filenamemat_AIT,replacedda,replacedmat_AIT);
filenamemat_MIT=strrep(filenamemat_MIT,replacedda,replacedmat_MIT);
filenamemat_MAX=strrep(filenamemat_MAX,replacedda,replacedmat_MAX);
filenamemat_AIT_NS=strrep(filenamemat_AIT_NS,replacedda,replacedmat_AIT_NS);
for ThresholdCycle=1:NumberofThresholds
    Threshvalue=sprintf('Threshold Value = %.3f',Starting_Fret_Ratio_for_Thresholds-((ThresholdCycle-1)*.10));
    HalfTimevalue=sprintf('Half Life = %.3f', HalfTime(ThresholdCycle));
    subplot(NumberofThresholds+1,1,ThresholdCycle); 
    plot(dataout(1,:),dataout(ThresholdCycle+2,:), 'DisplayName', 'PBT', 'YDataSource', 'PAT');
    box off;
    xlabel('Time');
    ylabel('Pixels Below Treshhold');
    xL=xlim;
    upperlimit=size(Inside_Mask,1);
    ylim([0 upperlimit]);
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
%save (filenamemat, 'dataout');
%save (filenamemat_AIT, 'dataout_AIT');
%save (filenamemat_MIT, 'dataout_MIT');
%save (filenamemat_MAX, 'dataout_Filtered_Max');
save (filenamemat_AIT_NS, 'dataout_AIT_NS');
%print -P lj8500;
close;
ThresholdDone=1;

todaysdate=date;
fidout1=sprintf(('%s/%s.txt'), directoryname,todaysdate);
fidout=fopen(fidout1, 'a');
for ThresholdCycle=1:NumberofThresholds
    Tresh=Starting_Fret_Ratio_for_Thresholds-((ThresholdCycle-1)*.10);
    outstring=sprintf(('%s\t%.3f\t%f\t%.1f\t%.1f\t%.3f\t%.6f\t%.3f\t%.6f\t%.6f\t%.6f\n\r'), filename, Tresh, ThresholdCycle, BaselinePixels(ThresholdCycle), PixelChange(ThresholdCycle), HalfTime(ThresholdCycle), MinFRETIntensity(ThresholdCycle), MaxTime(ThresholdCycle), BaselineFRETIntensity(ThresholdCycle), Rise10(ThresholdCycle), Rise90(ThresholdCycle));
    outcout=fwrite(fidout, outstring);
end
status=fclose(fidout);


end

