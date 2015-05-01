function [FRatio]=TakeTheRatio(FImages,DoesThisCellArrayObjectContainData, ExposureNumber);
for exposure=1:ExposureNumber
      Frames=size(FImages,3);
      Height=size(FImages,2);
      Width=size(FImages,1);
    if DoesThisCellArrayObjectContainData(exposure)>0
        
        Ch1 = FImages(1:Width/2,1:Height,:);
        Ch2 = FImages(Width/2+1:Width,1:Height,:);
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