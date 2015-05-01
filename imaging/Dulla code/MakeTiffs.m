function MakeTiffs(FRatio, ClippedParameters, Height, Width, ExposureNumber);
for exposure=1:ExposureNumber
if ClippedParameters(exposure*2)>0
    
figure (1)
tempimage=FRatio{2};
image (tempimage(:,:,50),'CDataMapping', 'scaled');
axis image;
axis off;
print -f1 -dtiff testing.tif;       

else
sprintf('Exposure % Empty', exposure);


end