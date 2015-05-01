function[FImages, ClippedParameters]=HeightWidthFormatClipDarkImages(Images, ShutterOpenValues, ShutterCloseValues, Height, Width, Frames, ExposureNumber, exposure);
for exposure=1:ExposureNumber
            temp=Images((Frames*Width*Height*(exposure-1))+1:(Frames*Width*Height*(exposure)));
            imgreshape=reshape(temp,Width,Height,Frames);
            if exposure==1
                if ShutterOpenValues(exposure)>1
                     ClippedImages=imgreshape(:,:,ShutterOpenValues(exposure):ShutterCloseValues(exposure));    
                     ClippedParameters=exposure;
                     ClippedParameters=[ClippedParameters ; ShutterCloseValues(exposure)-ShutterOpenValues(exposure)];
                     
                else
                     ClippedImages=0;
                     ClippedParameters=exposure;
                     ClippedParameters=[ClippedParameters ; ShutterCloseValues(exposure)-ShutterOpenValues(exposure)];
                     
                end
            else
                if ShutterOpenValues(exposure)>1
                     ClippedImages=imgreshape(:,:,ShutterOpenValues(exposure):ShutterCloseValues(exposure));    
                     ClippedParameters=[ClippedParameters ; exposure];
                     ClippedParameters=[ClippedParameters; ShutterCloseValues(exposure)-ShutterOpenValues(exposure)];
                     
                else
                     ClippedImages=0;
                     ClippedParameters=[ClippedParameters ; exposure];
                     ClippedParameters=[ClippedParamaeters; ShutterCloseValues(exposure)-ShutterOpenValues(exposure)];
                     
                

                
                end
            end
        if exposure==1
            FImages = {ClippedImages};
        else
            FImages =[FImages; ClippedImages];
        end
        end
end

    