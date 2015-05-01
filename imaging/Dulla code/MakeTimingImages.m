function [TimingCellArray, adjust]=MakeTimingImages(CellArrayImages, filename, directoryname, ExposureNumber, RGBCustom,  FrameInterval, Max_Time_Cutoff, IterationNumber, Inside_Mask,Outside_Mask,StimTime,camerafileextension );
  
 % 1. Finds the peak change for each pixel
 % 2. Creates an image for each time bin contain the pixels that reached their peak within that bin
 % 3. Creates a single image in which each pixel is colored based on at which time bin it reached its peak 
 %                    >>> INPUT VARIABLES >>>
 %
 % NAME                  TYPE, DEFAULT           DESCRIPTION
 % CellArrayImages                               Cell Array Containing the data
 % filename                                      File name ending in .da
 % directoryname                                 Directory in which file is located
 % ExposureNumber                                Cell within cell array where data is located
 % RGBCustom                                     Colormap
 % FrameInterval                                 Time between samples
 % Max_Time_Cutoff                               Size of each time bin in ms for timing analysis
 % IterationNumber                               Number of time bins for timing analysis    
 % Inside_Mask                                   Mask are area inside of the slice
 % Outside_Mask                                  Mask are area outside of the slice
 % StimTime                                      Time of Stimulation in ms
 %
 %                    <<< OUTPUT VARIABLES <<<
 %
 % NAME                 TYPE                    DESCRIPTION
 % TimingCellArray                              Cell Array containing the timing images
 % adjust                                       Minimum peak time


 clear MinMatrix;
 clear StepMatrix;
 clear tempimage3;
 clear tempimage;
 clear Subtracted;
 clear Stepped;
    

 %%%%%%%%%%%%% Get data and its properties
 tempimage=CellArrayImages{ExposureNumber};
 Frames=size(tempimage,3);
 Height=size(tempimage,2);
 Width=size(tempimage,1);
 
 %%%%%%%%%%%%% Allocate memory
    
 Timing_Images=zeros(Width,Height);
 timeimage=zeros(Width,Height);
 singleframe=zeros(Width,Height);
 
 %%%%%%%%%%%% Find the peak time for each pixel
 for h=1:Height
     for w=1:Width
         [minval mintime]=min(tempimage(w,h,StimTime/FrameInterval:Frames));    
          timeimage(w,h)=mintime*FrameInterval; % timeimage is in ms NOT in frame #s
     end
 end
 
 %%%%%%%%%%%  Finds the minimum peak time
 adjust=min(min(timeimage(Inside_Mask))); % adjust is in ms NOT in frame #s
 subtract=ones(w,h);
 subtract=subtract*adjust*FrameInterval;

 %%%%%%%%%% Creates the adjusted matrix
 outimage=timeimage-subtract;
 i=find(outimage<0);
 outimage(i)=0;
 
 %%%%%%%%%%%%  Creates matrices to adjust main matrix
 Adjusted_Images=zeros(Width,Height,IterationNumber); % timing movie image location
 StepMatrix=ones(Width,Height);
 MinMatrix=zeros(Width,Height);
 Adjusted=zeros(Width,Height);
 singleframe(Inside_Mask)=1;  % image that contains all the pixel peaks in one image
        
 %%%%%%%%%%%  Goes throught the peak time matrix and finds if a pixel has
 %%%%%%%%%%%  reached its peak within the each time bin.  A new image is
 %%%%%%%%%%%  created for each time bin
 
 for Iteration=1:IterationNumber
     Max_Time_Window = Iteration*Max_Time_Cutoff;                                                           % End time of this bin
     Min_Time_Window = 0;                                                                                   % For movie generation start bin always = 0
     Single_Image_Min_Time=(Iteration-1)*Max_Time_Cutoff;                                                   % Start time of this bin
     Activated_Pixels=find(outimage<Max_Time_Window & outimage>Min_Time_Window);                            % Finds the pixels activated since the start time
     Single_Image_Activated_Pixels=find(outimage<Max_Time_Window & outimage>Single_Image_Min_Time);         % Finds the pixels activated in this bin
     if size(Activated_Pixels)>0
        Current_Peak=max(max(outimage(Activated_Pixels)));                                                  % Colorscales images for movie
        Step=255/Current_Peak;
        StepMatrix=StepMatrix*Step;
        Adjusted(Inside_Mask)=1;
        Adjusted(Activated_Pixels)=outimage(Activated_Pixels)*Step;
        singleframe(Single_Image_Activated_Pixels)=Iteration;
        Adjusted(Outside_Mask)=255;
        singleframe(Outside_Mask)=0;
           Adjusted_Images(:,:, Iteration)=Adjusted;
           else
           Adjusted_Images(:,:,Iteration)=tempimage(:,:,Iteration);    
           end
           
 end
        Single_Max=max(max(singleframe));                                                                    % Colorscales single image
        Single_Min=min(min(singleframe(Inside_Mask)));
        Single_Scale=255/(Single_Max-Single_Min);
        singleframe=singleframe-Single_Min;
        singleframe=singleframe*Single_Scale;
        singleframe(Inside_Mask)=256-singleframe(Inside_Mask);
        image(singleframe, 'CDataMapping','scaled');
        imagefilename=sprintf('%s/%s', directoryname,filename);
        imagefilename=strrep(imagefilename, camerafileextension, '_Single_Timing.tif');
        tiffcomments=sprintf('Date = %s, Max Time = %d, Min Peak Time = %d, Time Scaling = %f ',filename,Single_Max*Max_Time_Cutoff, Single_Min, Single_Scale); 
        
        imwrite(singleframe, RGBCustom, imagefilename, 'Description', tiffcomments, 'Compression', 'none');         % Write single image 
        
        TimingCellArray{ExposureNumber}=Adjusted_Images;                                                            % Output timing movie matrix
        
        end