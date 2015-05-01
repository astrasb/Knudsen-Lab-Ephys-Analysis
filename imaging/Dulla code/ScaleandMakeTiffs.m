function [MinCutoff, Step]=ScaleandMakeTiffs(FRatio, filename, directoryname, type, ExposureNumber, RGBCustom,  Offsetfactor,FrameInterval,MSforNormBaselineStart,MSforNormBaselineEnd);
replacedda='.da';
replacedtif='_FILL_LLIF.tif';
replacedavi='.avi';
stringfill='FILL';
stringfill2='LLIF';
filebase=filename(1:10);
filenumber=filename(12:15);

if Timing_Movie==0
filedirectory=sprintf('%s/%s/%s', directoryname, filenumber, type);
mkdir(filedirectory);
else
 filedirectory=sprintf('%s/%s', directoryname, filenumber);
mkdir(filedirectory);
end
imagefilename=strrep(filename,replacedda,replacedtif);
imagefilename=strrep(imagefilename, stringfill, type);
imagefilename=sprintf('%s/%s',filedirectory, imagefilename); 
for exposure=1:ExposureNumber
    clear MinMatrix;
    clear StepMatrix;
    clear tempimage3;
    clear tempimage;
    clear Subtracted;
    clear Stepped;
    

        %%%%%%%%%%%%% Get Exposure Pixel info
        tempimage=FRatio{exposure};
         
        Frames=size(tempimage,3);
        Height=size(tempimage,2);
        Width=size(tempimage,1);

        LeftROI=size(tempimage,2)/4;
        RightROI=3*size(tempimage,2)/4;
        TopROI=size(tempimage,1)/4;
        BottomROI=3*size(tempimage,1)/4;
        
        if Frames==1    
        Tstd=std(std(tempimage(TopROI:BottomROI,LeftROI:RightROI)));
        Tmean=mean(mean(tempimage(TopROI:BottomROI,LeftROI:RightROI)));
        else    
        Tstd=std(std(std(tempimage(TopROI:BottomROI,LeftROI:RightROI,MSforNormBaselineStart/FrameInterval:MSforNormBaselineEnd/FrameInterval))));
        Tmean=mean(mean(mean(tempimage(TopROI:BottomROI,LeftROI:RightROI,MSforNormBaselineStart/FrameInterval:MSforNormBaselineEnd/FrameInterval))));
        end  
        if Timing_Movie==0
        MaxCutoff=Tmean+Tstd*Offsetfactor;
        MinCutoff=Tmean-Tstd*Offsetfactor;
        else

        MaxCutoff=Max_Time_Cutoff*Iteration;
        MinCutoff=0;
        end
        if MinCutoff<0
            MinCutoff=0;
        end
        Range=MaxCutoff-MinCutoff;
        Step=256/Range;
        
        i=find(tempimage>MaxCutoff);
        tempimage(i)=MaxCutoff;
        i=find(tempimage<MinCutoff);
        tempimage(i)=MinCutoff;
        
        if Frames==1 
        MinMatrix=ones(Width, Height);
        MinMatrix=MinMatrix*MinCutoff;
        StepMatrix=ones(Width,Height);
        StepMatrix=StepMatrix*Step;
        else
        MinMatrix=ones(Width, Height,Frames);
        MinMatrix=MinMatrix*MinCutoff;
        StepMatrix=ones(Width,Height, Frames);
        StepMatrix=StepMatrix*Step;
        end
        
        
        Subtracted=tempimage-MinMatrix;
        Stepped=Subtracted.*StepMatrix;
        
        %%%%%%%%%%%%%%% Creates Images directly from Memory
        if Frames==1
        
        framestring=int2str(Frames);
        imagefilename=strrep(imagefilename, stringfill2, framestring);
        tempimage2=Stepped(:,:);
        tiffcomments=sprintf('Date = %s, Exposure = %d, Frame = %d, Color Scaling Min = %d, Colorscaling Step = %d',filename, exposure, Frames, MinCutoff, Step); 
        
        imwrite(tempimage2, RGBCustom, imagefilename, 'Description', tiffcomments, 'Compression', 'none'); 
        fprintf('Frame %d Saved', Frames);
        disp('NEXT');
       % M(frame)=getframe;
        
        else
        framestring=int2str(exposure);
        imagefilenameave=strrep(imagefilename, stringfill2, framestring);
        
        for frame=1:Frames
        framestring=int2str(frame);
        imagefilenameFilled=strrep(imagefilename, stringfill2, framestring);
        tempimage2=Stepped(:,:,frame);
        
        
        
        tiffcomments=sprintf('Date = %s, Exposure = %d, Frame = %d, Color Scaling Min = %d, Colorscaling Step = %d',filename, exposure, frame, MinCutoff, Step); 
         
        imwrite(tempimage2, RGBCustom, imagefilenameFilled, 'Description', tiffcomments, 'Compression', 'none'); 
        
        end
        
        
        end
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
    
    
end
end
