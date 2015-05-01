function [Created]=generatemovie_Andor(Input, filename, directoryname,exposure,Offsetfactor,FrameInterval,MSforNormBaselineStart,MSforNormBaselineEnd, RGBCustom, StartMovieFrame, EndMovieFrame,ThreshCycle, type, dynamic_color_scale, FPS, dataout, adjust, Max_Time_Cutoff, IterationNumber,Centroid_Coordinates,camerafileextension,cookscaled  )
 % Generates movies for different data types with field traces
 %                    >>> INPUT VARIABLES >>>
 %
 % NAME                  TYPE, DEFAULT           DESCRIPTION
 % Input                                         Cell Array Containing the data
 % filename                                      File name ending in .da
 % directoryname                                 Directory in which file is located
 % exposure                                      Cell within cell array where data is located
 % Offsetfactor                                  Used in dynamic color to widen the range of values allowed in the colormap
 % FrameInterval                                 Time between samples
 % MSforNormBaselineEnd                          Amount of time to use for normalizing Purposes and for setting the baseline of the field recording
 % MSforNormBaselineStart                        Amount of time to use for normalizing Purposes and for setting the baseline of the field recording
 % RGBCustom                                     Colormap
 % StartMovieFrame                               Frame of Input used to start making movie = Frame #1 of the movie
 % EndMovieFrame                                 Frame of Input used to end making movie = Final Frame of the movie
 % ThreshCycle                                   Used to create 'type' when making tresholded movies
 % type                                          Label for file to define the type of movie we're making
 % dynamic_color_scale                           1=dynamic scale, 2=fixed scale, 3=timing movies
 % FPS                                           Frames per second parameter used to make movies
 % dataout                                       Location of capture times and field trace
 % adjust                                        Minimum time of peak for TIMING ANALYSIS ONLY
 % Max_Time_Cutoff                               Amount of time in each time bin TIMING ANALYSIS ONLY
 % IterationNumber                               Number of time bins TIMING ANALYSIS ONLY
 %                    <<< OUTPUT VARIABLES <<<
 %
 % NAME                 TYPE                    DESCRIPTION
 % Created                                      =1 when done 

tempimage=Input{exposure};                                                                  % Get data
replacedda=camerafileextension;                                                                           % Format Strings for file name
replacedavi='Movie_FILL.avi';
stringfill='FILL';
directorybase1=directoryname(12:size(directoryname,2));
fnlength=size(filename,2);
filebase=filename(1:10);
filenumber=filename(size(filename,2)-4:size(filename,2)-3);
%filedirectory=sprintf('%s/%s', directoryname, filenumber);
filedirectory=sprintf('%s', directoryname);
mkdir(filedirectory);
avifilename=strrep(filename,replacedda,replacedavi);
avifilename=sprintf('%s/%s',filedirectory, avifilename);

label=sprintf('%s_%d_%d',type, exposure, ThreshCycle);
avifilenameave=strrep(avifilename, stringfill, label);

Frames=size(tempimage,3);                                                                   % Get Data properties
Height=size(tempimage,2);
Width=size(tempimage,1);
traceave=mean(dataout(2,MSforNormBaselineStart/FrameInterval:MSforNormBaselineEnd/FrameInterval));  % Get field recording baseline


        if dynamic_color_scale==1                                                                   % Dynamic Color Scaling
             LeftROI=size(tempimage,2)/4;
             RightROI=3*size(tempimage,2)/4;
             TopROI=size(tempimage,1)/4;
             BottomROI=3*size(tempimage,1)/4;
             Tstd=std(std(std(tempimage(TopROI:BottomROI,LeftROI:RightROI,MSforNormBaselineStart/FrameInterval:MSforNormBaselineEnd/FrameInterval))));
             Tmean=mean(mean(mean(tempimage(TopROI:BottomROI,LeftROI:RightROI,MSforNormBaselineStart/FrameInterval:MSforNormBaselineEnd/FrameInterval))));
             MaxCutoff=Tmean+Tstd*Offsetfactor/10;
             MinCutoff=Tmean-Tstd*Offsetfactor;
            if MinCutoff<0
                MinCutoff=0;
            end
        end
        if dynamic_color_scale==2                                                                   % Fixed Color Scaling
            MaxCutoff=1.8;
            MinCutoff=1;
        end
        if dynamic_color_scale==5                                                                   % Fixed Color Scaling For Andor
            MaxCutoff=1.7;
            MinCutoff=1.3;
        end
        if dynamic_color_scale==3                                                                   % Timing ColorScaling
            MaxCutoff=256;
            MinCutoff=0;
        end
        if (dynamic_color_scale~=4)
        Range=MaxCutoff-MinCutoff;                                                                  % Processing data
        Step=256/Range;
        i=find(tempimage>MaxCutoff);
        tempimage(i)=MaxCutoff;
        i=find(tempimage<MinCutoff);
        tempimage(i)=MinCutoff;
        MinMatrix=ones(Width, Height,Frames);
        MinMatrix=MinMatrix*MinCutoff;
        StepMatrix=ones(Width,Height, Frames);
        StepMatrix=StepMatrix*Step;        
        Subtracted=tempimage-MinMatrix;
        Stepped=Subtracted.*StepMatrix;
        end
        h=figure;
        if dynamic_color_scale==3                                                                   % Making timing movie
            temptime=dataout(2,:);
         
            Total_Time=Max_Time_Cutoff*IterationNumber+adjust;
           
             h=figure;
           
            for frame=StartMovieFrame:EndMovieFrame
                
                SliceImage=subplot(2,1,1);
                TimeStep=Max_Time_Cutoff*IterationNumber/EndMovieFrame;
                tempimage2=Stepped(:,:,frame);
                image (tempimage2,'CDataMapping', 'scaled');
                set(gca,'xtick',[],'ytick',[]);
               
                
                %h=image (tempimage2,'CDataMapping', 'scaled');
                TraceImage=subplot(2,1,2);
                plot(dataout(1,1:(StartMovieFrame+adjust/FrameInterval)+(frame-1)*TimeStep/FrameInterval), dataout(2,1:(StartMovieFrame+adjust/FrameInterval)+(frame-1)*TimeStep/FrameInterval));
                xlim([0 Total_Time]);
                ylim([traceave-1 traceave+1]);
                box off;
                %getframe(h);
                colormap(RGBCustom);
                set(SliceImage, 'OuterPosition', [0,.2,1,.8])
                set(TraceImage, 'OuterPosition', [0,0,1,.2])
                F(frame-StartMovieFrame+1)=getframe(h);
                %mov=addframe(mov,F);
                
            end
        end
        if ((dynamic_color_scale==1)|(dynamic_color_scale==2))

        h=figure;
                    if 2>4
                    CookMax=max(max(max(cookscaled)));
                    CookFactor=CookMax/256;
                    cookscaled=cookscaled/CookFactor;
                    
                    end
                    
        for frame=StartMovieFrame:EndMovieFrame                                                    % Making a normal movie
                 numberofbrighfield=100;
                 if frame==1
                 for showbrightfield=1:numberofbrighfield
                      SliceImage=subplot(2,1,1);
                      hh=image(cookscaled,'cdatamapping','scaled');
                      colormap gray;
                     
                      if showbrightfield>10
                         set(hh,'AlphaData', 1-1/(numberofbrighfield/showbrightfield));
                      end
                      box off;
                      set(gca,'xtick',[],'ytick',[]);
                      TraceImage=subplot(2,1,2);
                      set(SliceImage, 'OuterPosition', [0,.2,1,.8])
                      set(TraceImage, 'OuterPosition', [0,0,1,.2])
                      F(frame-StartMovieFrame+showbrightfield)=getframe(h);
                 end
                 end
                 SliceImage=subplot(2,1,1);
                 tempimage2=Stepped(:,:,frame);
                 
                 image (tempimage2,'CDataMapping', 'scaled');
                    colormap(RGBCustom);
                   
                 set(gca,'xtick',[],'ytick',[]);
                  hold(SliceImage,'on');
                 if size(Centroid_Coordinates,2)>1
                
                  plot(SliceImage,uint8(Centroid_Coordinates(2,frame)), uint8(Centroid_Coordinates(1,frame)), 'b*');
                  
                 end
                                    
                   
                 
                  hold(SliceImage,'off');
                 TraceImage=subplot(2,1,2);
                 
                 plot(dataout(1,StartMovieFrame:frame), dataout(2,StartMovieFrame:frame));
                 
                 xlim([dataout(1,StartMovieFrame) dataout(1,EndMovieFrame-1)]);
                 ylim([traceave-1 traceave+1]);
                 box off;
                 
                 set(SliceImage, 'OuterPosition', [0,.2,1,.8])
                 set(TraceImage, 'OuterPosition', [0,0,1,.2])
                 F(frame-StartMovieFrame+1)=getframe(h);
                 %mov=addframe(mov,F);
                F(frame-StartMovieFrame+1+numberofbrighfield)=getframe(h);
            end
        end
if dynamic_color_scale==4

        h=figure;
                    if 2>4
                    CookMax=max(max(max(cookscaled)));
                    CookFactor=CookMax/256;
                    cookscaled=cookscaled/CookFactor;
                    
                    end
                    
        for frame=StartMovieFrame:EndMovieFrame                                                    % Making a normal movie
                 numberofbrighfield=20;
                 if frame==1
                 for showbrightfield=1:numberofbrighfield
                      SliceImage=subplot(2,1,1);
                      hh=image(cookscaled,'cdatamapping','scaled');
                      colormap gray;
                                       
                      box off;
                      set(gca,'xtick',[],'ytick',[]);
                      TraceImage=subplot(2,1,2);
                      set(SliceImage, 'OuterPosition', [0,.2,1,.8])
                      set(TraceImage, 'OuterPosition', [0,0,1,.2])
                      F(frame-StartMovieFrame+showbrightfield)=getframe(h);
                 end
                 end
                 SliceImage=subplot(2,1,1);
                 
                 tempimage2=tempimage(:,:,frame);
                 
                 image (tempimage2,'CDataMapping', 'direct');
                    colormap(RGBCustom);
                   
                 set(gca,'xtick',[],'ytick',[]);
                  hold(SliceImage,'on');
                 if size(Centroid_Coordinates,2)>1
                
                  plot(SliceImage,uint8(Centroid_Coordinates(2,frame)), uint8(Centroid_Coordinates(1,frame)), 'b*');
                  
                 end
                                    
                   
                 
                  hold(SliceImage,'off');
                 TraceImage=subplot(2,1,2);
                 
                 plot(dataout(1,StartMovieFrame:frame), dataout(2,StartMovieFrame:frame));
                 
                 xlim([dataout(1,StartMovieFrame) dataout(1,EndMovieFrame-1)]);
                 ylim([traceave-1 traceave+1]);
                 box off;
                 
                 set(SliceImage, 'OuterPosition', [0,.2,1,.8])
                 set(TraceImage, 'OuterPosition', [0,0,1,.2])
                 F(frame-StartMovieFrame+1)=getframe(h);
                 %mov=addframe(mov,F);
                F(frame-StartMovieFrame+1+numberofbrighfield)=getframe(h);
            end
        end
%movie(F);
if dynamic_color_scale==5
 
        h=figure;
                                        
        for frame=StartMovieFrame:EndMovieFrame                                                    % Making a normal movie
                 
                 SliceImage=subplot(2,1,1);
                 
                 tempimage2=Stepped(:,:,frame);
                 
                 image (tempimage2,'CDataMapping', 'scaled');
                    colormap(RGBCustom);
                   
                 set(gca,'xtick',[],'ytick',[]);
                  hold(SliceImage,'on');
                 if size(Centroid_Coordinates,2)>1
                
                  plot(SliceImage,uint8(Centroid_Coordinates(2,frame)), uint8(Centroid_Coordinates(1,frame)), 'b*');
                  
                 end
                                    
                   
                 
                  hold(SliceImage,'off');
                 TraceImage=subplot(2,1,2);
                 
                 plot(dataout(1,StartMovieFrame:frame), dataout(2,StartMovieFrame:frame));
                 
                 xlim([dataout(1,StartMovieFrame) dataout(1,EndMovieFrame-1)]);
                 ylim([traceave-1 traceave+1]);
                 box off;
                 
                 set(SliceImage, 'OuterPosition', [0,.2,1,.8])
                 set(TraceImage, 'OuterPosition', [0,0,1,.2])
                 F(frame-StartMovieFrame+1)=getframe(h);
                 %mov=addframe(mov,F);
                F(frame-StartMovieFrame+1)=getframe(h);
            end
        end

movie2avi(F,avifilenameave, 'fps', FPS);

close all;
Created=1;
end
        
        
