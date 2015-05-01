function [MinCutoff, Step]=AutoScaleMakeSingleTiff(ImageData, filename, Frames, ExposureNumber,Width, Height, ClippedParameters, RGBCustom, ShutterOpenValues,ShutterCloseValues, IgnoreFirstXFrames, Offsetfactor, FrameToImage);

for exposure=1:ExposureNumber
    clear MinMatrix;
    clear StepMatrix;
    clear tempimage3;
    clear tempimage;
    clear Subtracted;
    clear Stepped;
    
    if ClippedParameters((exposure-1)*2+2)>0
        %%%%%%%%%%%%% Get Exposure Pixel info
        tempimage=ImageData;
        
       
        LeftROI=size(tempimage,2)/4;
        RightROI=3*size(tempimage,2)/4;
        TopROI=size(tempimage,1)/4;
        BottomROI=3*size(tempimage,1)/4;
        
        
        %tempimage3=tempimage(LeftROI:RightROI,TopROI:BottomROI,ROIStart:ROIEnd);
        
       
       % Tmax=max(max(max(tempimage(TopROI:BottomROI,LeftROI:RightROI,IgnoreFirstXFrames:ShutterCloseValues(exposure)-ShutterOpenValues(exposure)))));
        %Tmin=min(min(min(tempimage(TopROI:BottomROI,LeftROI:RightROI,IgnoreFirstXFrames:ShutterCloseValues(exposure)-ShutterOpenValues(exposure)))));
        Tstd=std(std(std(tempimage(TopROI:BottomROI,LeftROI:RightROI))));
        Tmean=mean(mean(mean(tempimage(TopROI:BottomROI,LeftROI:RightROI))));
        
       
        
        MaxCutoff=Tmean+Tstd*Offsetfactor;
        MinCutoff=Tmean-Tstd*Offsetfactor;
        Range=MaxCutoff-MinCutoff;
        Step=256/Range;
        
        i=find(tempimage>MaxCutoff);
        tempimage(i)=MaxCutoff;
        i=find(tempimage<MinCutoff);
        tempimage(i)=MinCutoff;
        
        MinMatrix=ones(Width/2, Height);
        MinMatrix=MinMatrix*MinCutoff;
        StepMatrix=ones(Width/2,Height);
        StepMatrix=StepMatrix*Step;
        
        Subtracted=tempimage-MinMatrix;
        Stepped=Subtracted.*StepMatrix;
        
        %%%%%%%%%%%%%%% Creates Images directly from Memory
        replacedda='.da';
        replacedtif='.tif';
        imagefilename=strrep(filename,replacedda,replacedtif);
       
        tempimage2=Stepped(:,:);
        
        
        
        tiffcomments=sprintf('Date = %s, Exposure = %d, Frame = %d, Color Scaling Min = %d, Colorscaling Step = %d',filename, exposure,FrameToImage, MinCutoff, Step); 
        %temp2=(tempimage2-MinCutoff*Step)*256;
         
        imwrite(tempimage2, RGBCustom, imagefilename, 'Description', tiffcomments, 'Compression', 'none'); 
        image (tempimage2, 'CDataMapping', 'scaled');
        axis image;
        axis off;
        fprintf('Frame %d Saved', FrameToImage);
        disp('NEXT');
    
       
    
    fprintf('Exposure %d Processed', exposure);
    fprintf('');
    
    else
    fprintf('Exposure %d Empty', exposure);
    fprintf('');
    end
end
end
