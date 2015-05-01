function [MinCutoff, Step]=AutoScaleMakeTiffsSelectFrames(FRatio, filename, ExposureNumber, type, StartFrame, NumberofFramesToProduce, RGBCustom,  IgnoreFirstXFrames, Offsetfactor);
replacedda='.da';
replacedtif='_FILL_LLIF.tif';
stringfill='FILL';
stringfill2='LLIF';

imagefilename=strrep(filename,replacedda,replacedtif);
imagefilename=strrep(imagefilename, stringfill, type);

for exposure=1:ExposureNumber
    clear MinMatrix;
    clear StepMatrix;
    clear tempimage3;
    clear tempimage;
    clear Subtracted;
    clear Stepped;
    
    if ClippedParameters((exposure-1)*2+2)>0
        %%%%%%%%%%%%% Get Exposure Pixel info
        tempimage=FRatio{exposure};
         
       Frames=size(OpenImages,3);
       Height=size(OpenImages,2);
       Width=size(OpenImages,1);

        LeftROI=size(tempimage,2)/4;
        RightROI=3*size(tempimage,2)/4;
        TopROI=size(tempimage,1)/4;
        BottomROI=3*size(tempimage,1)/4;
        
                 
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
        
        MinMatrix=ones(Width/2, Height,Frames-IgnoreFirstXFrames*2);
        MinMatrix=MinMatrix*MinCutoff;
        StepMatrix=ones(Width/2,Height, Frames-IgnoreFirstXFrames*2);
        StepMatrix=StepMatrix*Step;
        
        Subtracted=tempimage-MinMatrix;
        Stepped=Subtracted.*StepMatrix;
        
        %%%%%%%%%%%%%%% Creates Images directly from Memory
        for frame=StartFrame:StartFrame+NumberofFramesToProduce
        framestring=int2str(frame);
        imagefilename=strrep(imagefilename, stringfill2, framestring);
        tempimage2=Stepped(:,:,frame);
        
        
        
        tiffcomments=sprintf('Date = %s, Exposure = %d, Frame = %d, Color Scaling Min = %d, Colorscaling Step = %d',filename, exposure, frame, MinCutoff, Step); 
         
        imwrite(tempimage2, RGBCustom, imagefilename, 'Description', tiffcomments, 'Compression', 'none'); 
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
