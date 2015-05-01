function [FRatio]=TakeTheRatioRedShirt(Images,ShutterOpenValues, Frames, ExposureNumber,Width, Height);
for exposure=1:ExposureNumber

    if ShutterOpenValues(exposure)>0
        temp=Images;
        %temp=Images((Frames*Width*Height*(exposure-1))+1:(Frames*Width*Height*(exposure)));
        %imgreshape=reshape(temp,Width,Height,Frames);
        Ch1 = temp(1:Height/2,1:Width,:);
        Ch2 = temp(Height/2+1:Height,1:Width,:);
        Ratio=Ch1./Ch2;
    else
        Ratio=0;
    end
    
    
   
if exposure==1
    FRatio={Ratio};
else
    FRatio=[FRatio; Ratio];
end
end