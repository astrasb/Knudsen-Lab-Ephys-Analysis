function [MinCutoff, Step]=AutoScaleMakeTiffs(FRatio, filename, Frames, ExposureNumber,Width, Height, ClippedParameters, RGBCustom, type,ShutterOpenValues,ShutterCloseValues, IgnoreFirstXFrames, Offsetfactor);
imagefilenamedir=sprintf('%s/%s',filename, 'images');
mkdir(imagefilenamedir);
for exposure=1:ExposureNumber
    clear MinMatrix;
    clear StepMatrix;
    clear tempimage3;
    clear tempimage;
    clear Subtracted;
    clear Stepped;
    imagefilenamedir=sprintf('%s/%s/Exposure_%d',filename, type, exposure);
    mkdir(imagefilenamedir);
    if ClippedParameters((exposure-1)*2+2)>0
        %%%%%%%%%%%%% Get Exposure Pixel info
        tempimage=FRatio{exposure};
        
       
        LeftROI=size(tempimage,2)/4;
        RightROI=3*size(tempimage,2)/4;
        TopROI=size(tempimage,1)/4;
        BottomROI=3*size(tempimage,1)/4;
        
        
        %tempimage3=tempimage(LeftROI:RightROI,TopROI:BottomROI,ROIStart:ROIEnd);
        
       
       % Tmax=max(max(max(tempimage(TopROI:BottomROI,LeftROI:RightROI,IgnoreFirstXFrames:ShutterCloseValues(exposure)-ShutterOpenValues(exposure)))));
        %Tmin=min(min(min(tempimage(TopROI:BottomROI,LeftROI:RightROI,IgnoreFirstXFrames:ShutterCloseValues(exposure)-ShutterOpenValues(exposure)))));
        Tstd=std(std(std(tempimage(TopROI:BottomROI,LeftROI:RightROI,IgnoreFirstXFrames:IgnoreFirstXFrames*2))));
        Tmean=mean(mean(mean(tempimage(TopROI:BottomROI,LeftROI:RightROI,IgnoreFirstXFrames:IgnoreFirstXFrames*2))));
        
       
        
        MaxCutoff=Tmean+Tstd*Offsetfactor;
        MinCutoff=Tmean-Tstd*Offsetfactor;
        Range=MaxCutoff-MinCutoff;
        Step=256/Range;
        
        i=find(tempimage>MaxCutoff);
        tempimage(i)=MaxCutoff;
        i=find(tempimage<MinCutoff);
        tempimage(i)=MinCutoff;
        
        MinMatrix=ones(Width/2, Height,ClippedParameters((exposure-1)*2+2)+1);
        MinMatrix=MinMatrix*MinCutoff;
        StepMatrix=ones(Width/2,Height, ClippedParameters((exposure-1)*2+2)+1);
        StepMatrix=StepMatrix*Step;
        
        Subtracted=tempimage-MinMatrix;
        Stepped=Subtracted.*StepMatrix;
        
        %%%%%%%%%%%%%%% Creates Images directly from Memory
        for frame=1:ClippedParameters((exposure-1)*2+2)
        imagefilename=sprintf('%s/%s/Exposure_%d/Frame_%d.tif',filename, type, exposure, frame);
        tempimage2=Stepped(:,:,frame);
        
        
        
        tiffcomments=sprintf('Date = %s, Exposure = %d, Frame = %d, Color Scaling Min = %d, Colorscaling Step = %d',filename, exposure, frame, MinCutoff, Step); 
        %temp2=(tempimage2-MinCutoff*Step)*256;
         
        imwrite(tempimage2, RGBCustom, imagefilename, 'Description', tiffcomments, 'Compression', 'none'); 
        image (tempimage2, 'CDataMapping', 'scaled');
        axis image;
        axis off;
        fprintf('Frame %d Saved', frame);
        disp('NEXT');
       % M(frame)=getframe;
        end
        %movie(M,100);
         
        %%%%%%%%%%%%%%% Creats Images using a Figure Command
        %figure (frame)
        %tempimage=FRatio{exposure};
        %image (tempimage(:,:,frame),'CDataMapping', 'scaled');
        %axis image;
        %axis off;
        %print ('-dtiff', imagefilename);
        %close;
        
        %%%%%%%%%%%%% Create a Movie
        
       
    
    fprintf('Exposure %d Processed', exposure);
    fprintf('');
    
    else
    fprintf('Exposure %d Empty', exposure);
    fprintf('');
    end
end
end
