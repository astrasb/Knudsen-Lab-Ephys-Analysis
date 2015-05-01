function [Max_at_Each_Threshold]=ThresholdCounter_Spectrum(Input, Outside_Mask, filename, directoryname);
Starting_Threshold=1.8;
Threshold_Step=0.01;
Min_Thresh=1.2;
MaxThresholdNumber=(Starting_Threshold - Min_Thresh)/Threshold_Step;

Max_at_Each_Threshold=zeros(MaxThresholdNumber,2);
ImagesToThreshold=Input{1};
Frames=size(ImagesToThreshold,3);
Height=size(ImagesToThreshold,2);
Width=size(ImagesToThreshold,1);


replacedmat='_ThreshHold_Spectrum.mat';  %works if the file is in the current directory 
replacedda='.da';
replacedjpg='ThreshHold_Spectrum.jpg';
filenamejpeg=sprintf('%s/%s', directoryname, filename);
filenamemat=sprintf('%s/%s', directoryname, filename);
filenamejpeg=strrep(filenamejpeg,replacedda,replacedjpg);
filenamemat=strrep(filenamemat,replacedda,replacedmat);


for threshold=1:MaxThresholdNumber
This_Thresh=Starting_Threshold-Threshold_Step*threshold;
PBT=zeros(Frames);
    for frame=1:Frames
        tempframethresh=ImagesToThreshold(:,:,frame);
        PixelsBelowThreshold1=find(tempframethresh<This_Thresh);
        PixelsBelowThreshold=size(PixelsBelowThreshold1,1)-size(Outside_Mask,1); 
       
        if frame==1
                    
        PBT=PixelsBelowThreshold;
        else
    
        PBT=[PBT; PixelsBelowThreshold];  
    
        end  
        clear PixelsAboveThreshold1;
        clear PixelsBelowThreshold1;   
        
        
    end
 Max_at_Each_Threshold(threshold,1)=This_Thresh;
 Max_at_Each_Threshold(threshold,2)=max(PBT);  
 clear PBT;
end
plot(Max_at_Each_Threshold(:,1), Max_at_Each_Threshold(:,2));
xlim([1.2 1.8]);
text(1.2,1000, filename, 'interpreter', 'none');
xlabel('Threshold');
ylabel('Pixels Below Threshold');

saveas(1, filenamejpeg);
save (filenamemat, 'Max_at_Each_Threshold');
end