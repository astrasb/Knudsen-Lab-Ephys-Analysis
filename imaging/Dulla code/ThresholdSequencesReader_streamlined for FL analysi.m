%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This code opens all Redshirt Files within a selected folder, and creates
%  ratioed, normalized images of every frame from every file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
ROI_ON=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%%%%%%%%% Create File List    %%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
%directoryname = uigetdir('/mnt/newhome/mirror/home/c;/hris/MATLAB/');    %%%%% Opens files from MATLAB directory

path1=sprintf('%s/*.da',directoryname);
d = dir (path1);
numfiles=length(d);
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end

%%%%%%%%%%%%%%% Open the Notation File


 
%%%%%%%%%%%%%%%% Sets Constants
MS_of_Data_to_Discard_Start=50;                    % Amount of time to be excluded from analysis - Front End
MS_of_Data_to_Discard_End=50;                      % Amount of time to be excluded from analysis - Front End
Offsetfactor=250;                                  % Adjusts the color scaling
MSforNormBaselineEnd=250;                          % Amount of time to use for Normalizing Purposes
MSforNormBaselineStart=50;                         % Amount of time to use for Normalizing Purposes
NumberofThresholds=5;                              % Number of threshold points for threshold analysis                 
GaussianValue=0.5;                                 % Value of Gaussian blur parameter
MatrixSize=3;                                      % Value of Gaussian blur parameter
Erosion_Factor=1;                                  % Size of Erosion Structure used
Masking_Factor=4;                                 % Masking Adjustment parameter - bigger number = more points farther from the mean will be included in the mask
Max_Time_Cutoff=5;                                 % Size of each time bin in ms for timing analysis
IterationNumber=200;                               % Number of time bins for timing analysis                 
%StimTime=500;                                      % Time of Stimulation in ms10
dfsubtract=1;                                      % Variable indication that dark frame subtraction is ON
clip=2;                                            % Number of pixels to clip off the mask
%2008_02_08_slice#1 clip=5

NormalizationImageBlur=50;                         % ms of data to blur for start and end frames of sliding normalization
Starting_Fret_Ratio_for_Thresholds=1.75;
Clip_Bottom_Extra=3;
camerafileextension='.da';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Adding additional masking points manually%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%script out the next line if extra mask points are needed
Additional_Points=[1,1]


if size(Additional_Points,2)>1
Additional_Mask_Points=size(Additional_Points,2)/2;
else
Additional_Mask_Points=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      THIS IS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      THE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      MAIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      PART OF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      THE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
%%%%%%%%%%%%%%% Start analyzing files %%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mask_Counter=0;


  

for thisfile =1:numfiles     %%%%%  Controls which files are being analyzed
 
 
 
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  %%%%%%%%%%%%%%%%%%%% Opens each RedShirt File %%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
  filename=dd(thisfile,:)
  fullfilename=sprintf('%s/%s',directoryname,filename);
  [CellArrayImages, FrameTimes,TraceData, FrameInterval,Inside_Mask, Outside_Mask ]=RedShirtOpenSequences(fullfilename,dfsubtract,MS_of_Data_to_Discard_Start, MS_of_Data_to_Discard_End, Masking_Factor,Mask_Counter, Inside_Mask, Outside_Mask);
  
  if thisfile==1
     testimage=CellArrayImages{1};
     testimage=testimage(1:40,:,500);
     image(testimage,'CDataMapping','scaled');
     Inside_Mask=roipoly;
     Outside_Mask=find(Inside_Mask==0);
  end
      
        % CellArrayImages           double                      the data read, in a x,y,t dataformat
        % FrameTimes                double                      an array of sample times [1..Frames]
        % TraceData                 double                      an array of electrophysiological samples  [1..Frames]- ONLY CH1 is output in this script
        % FrameInterval             double                      sampling interval in ms

        
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%% Consturcting output .mat file data matrix %%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dataout_Filtered_Max=[FrameTimes;TraceData]; 
  dataout=[FrameTimes;TraceData];  
  dataout_AIT=[FrameTimes;TraceData];  
  dataout_AIT_NS=[FrameTimes;TraceData]; 
  dataout_MIT=[FrameTimes;TraceData];  
  ExposureNumber=size(CellArrayImages,1);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%% Finding the stimulation time %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  dx=dataout(2,100/FrameInterval:size(dataout,2)-100/FrameInterval);
  dy=dataout(1,100/FrameInterval:size(dataout,2)-100/FrameInterval);
  dxpre=dx(1:size(dx,2)-1);
  dxpost=dx(2:size(dx,2));
  ddif=dxpre-dxpost;
  dderiv=ddif./dy(1:size(dy, 2)-1);
  [peakvalue, peaktime]=max(dderiv);
  StimTime=peaktime*FrameInterval+100/FrameInterval;
  if ((StimTime-200)<0)
      StimTime=2000
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%% Creates the RGB and RGB Inverted Color table %%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  [RGBCustomInverted]=CreateRGBColorTableInverted;
  [RGBCustom]=CreateRGBColorTable;
  disp ('ColorMap Created');
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Goes through individual exposures and %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% performs all analysis         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
  
  
  for ThisExposure=1:ExposureNumber
      
  DoesThisCellArrayObjectContainData=1;           %%%%%%%%%%% Tests if this exposure has any data - NOT IMPLEMENTED YET
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Takes the Ratio of CH1 and CH2 %%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  [CellArrayImages]=TakeTheRatio(CellArrayImages,ThisExposure,DoesThisCellArrayObjectContainData);
                    % 1. Loads data from a cell array 
                    % 2. Takes the Ratio
                    % 3. Outputs the ratioed data into the cell array FRatio

                    %                    >>> INPUT VARIABLES >>>
                    % NAME                        TYPE, DEFAULT                   DESCRIPTION
                    % Images                                                      Cell Array location of the Raw data
                    % ThisExposure                                                Cell within the array to grab the data from
                    % DoesThisCellArrayObjectContainData                          Flag if there is data present
                    %   
                    %                   <<< OUTPUT VARIABLES <<<
                    %
                    % NAME                      TYPE                        DESCRIPTION
                    % FRatio                                                Cell Array containing the ratioed data
                    % 
  
  disp ('Ratio Completed');
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%% Sliding normalization %%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  [CellArrayImages]=Normalize(CellArrayImages, FrameTimes,FrameInterval, ThisExposure,RGBCustomInverted, Outside_Mask, NormalizationImageBlur,1);
  disp ('Normalization Completed');
  
  
        %
        % Normalies Data using a sliding average based on the first and last 50 ms of data
        %
        %                    >>> INPUT VARIABLES >>>
        %
        % NAME                  TYPE, DEFAULT           DESCRIPTION
        % Images                                        Cell Array Containing the data
        % FrameTimes                                    Array of sample times [1 Frames]
        % FrameInterval                                 Time between samples
        % ExposureNumber                                Cell within the cell array to get the data from
        % RGBCustom                                     Colormap
        % Outside_Mask                                  Mask are area outside of the slice
        % FramesBlurred                                 ms of data to blur for the start and end normalization images 
        %
        %                    <<< OUTPUT VARIABLES <<<
        %
        % NAME                 TYPE                    DESCRIPTION
        % Normalize                                    Cell Array Containing the data normalized data
        % 
        % 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Apply a Prefilter Mask = area outside of
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% the mask is filled with the average
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% intensity within the mask
  
  [CellArrayImages]=Apply_Mask_PreFilter(CellArrayImages,ThisExposure, Inside_Mask, Outside_Mask,DoesThisCellArrayObjectContainData);
        %masks area outside of the slice mask with the average intensity inside the mask
        %
        %                    >>> INPUT VARIABLES >>>
        %
        % NAME                  TYPE, DEFAULT           DESCRIPTION
        % Images                                        Cell Array Containing the data
        % ThisExposure                                  Cell within the cell array to get the data from
        % Inside_Mask                                   Mask are area inside of the slice
        % Outside_Mask                                  Mask are area outside of the slice
        % DoesThisCellArrayObjectContainData            Flag for empty dataset
        %
        %                    <<< OUTPUT VARIABLES <<<
        %
        % NAME                 TYPE                    DESCRIPTION
        % CellArrayImages                              Cell Array Containing the filtered data
        % 
        %
        
        
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
  %%%%%%%% Filter Images %%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  Normlabel=sprintf('Norm_%d', ThisExposure);
  %[CellArrayImages]=Median_Filter(CellArrayImages, MatrixSize, ThisExposure);
  %disp ('Median Filter Applied');
  [GaussianArrayImages]=Gaussian_Filter(CellArrayImages, MatrixSize, ThisExposure, GaussianValue);
  [GaussianArrayImages]=Gaussian_Filter(GaussianArrayImages, MatrixSize, ThisExposure, GaussianValue);
  
  %%% Extra Filtering for picking peak amplitude
  [GaussianArrayImages_LargeFilterElement]=Gaussian_Filter(CellArrayImages, MatrixSize*2, ThisExposure, GaussianValue);
  [GaussianArrayImages_LargeFilterElement2]=Gaussian_Filter(GaussianArrayImages_LargeFilterElement, MatrixSize*2, ThisExposure, GaussianValue);
  
  
  
  %Applies a Gaussian filter to an image array
        %
        %                    >>> INPUT VARIABLES >>>
        %
        % NAME                  TYPE, DEFAULT           DESCRIPTION
        % CellArrayImages                               Cell Array Containing the data
        % Matrix Size                                   Size of the structure element used in filtering
        % exposure                                      Cell within the Cell Array to get data from
        % GaussianValue                                 Parameter of gaussian filter
        % 
        %                    <<< OUTPUT VARIABLES <<<
        %
        % NAME                 TYPE                    DESCRIPTION
        % CellArrayImages                              Cell Array Containing the filtered data
        % 
        %
  
  
  disp ('Gaussian Filter Applied');
  
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Apply a Postfilter Mask = area outside of
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% the mask is filled with zeros
  %[CellArrayImages]=Apply_Mask(CellArrayImages,ThisExposure, Inside_Mask, Outside_Mask,DoesThisCellArrayObjectContainData);
  [GaussianArrayImages]=Apply_Mask(GaussianArrayImages,ThisExposure, Inside_Mask, Outside_Mask,DoesThisCellArrayObjectContainData);
  
        %masks area outside of the slice mask with zeros
        %
        %                    >>> INPUT VARIABLES >>>
        %
        % NAME                  TYPE, DEFAULT           DESCRIPTION
        % Images                                        Cell Array Containing the data
        % ThisExposure                                  Cell within the cell array to get the data from
        % Inside_Mask                                   Mask are area inside of the slice
        % Outside_Mask                                  Mask are area outside of the slice
        % DoesThisCellArrayObjectContainData            Flag for empty dataset
        %
        %                    <<< OUTPUT VARIABLES <<<
        %
        % NAME                 TYPE                    DESCRIPTION
        % CellArrayImages                              Cell Array Containing the filtered data
        % 
        %
        
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
  %%%%%%%% Time trace of the ratio values %%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  Time_Average_Temp=GaussianArrayImages{1};
  Average_Height=size(Time_Average_Temp,1);
  Average_Width=size(Time_Average_Temp,2);
  Time_Average=mean(mean(Time_Average_Temp(Average_Height/4:(Average_Height/4)*3,Average_Width/4:(Average_Width/4)*3,:)));
  Time_Average=squeeze(Time_Average);
  plot(Time_Average);
  strout='.da';
  Time_Ave_Filename=strrep(fullfilename,strout,'_Ratio_Time_Course.jpg');
  %saveas(gcf, Time_Ave_Filename);
  
  
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
  %%%%%%%% Pixel Integraton %%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %[Worked]=Pixel_Integration(GaussianArrayImages, filename, directoryname,Outside_Mask, Inside_Mask, RGBCustom, MSforNormBaselineStart, MSforNormBaselineEnd, FrameInterval);
   
            %Integrates the change at each pixel over the entire course of the exposure
            %and outputs one image
            %
            %                    >>> INPUT VARIABLES >>>
            %
            % NAME                  TYPE, DEFAULT           DESCRIPTION
            % CellArrayImages                               Cell Array Containing the data
            % filename                                      File name ending in .da
            % directoryname                                 Directory in which file is located
            % Inside_Mask                                   Mask are area inside of the slice
            % Outside_Mask                                  Mask are area outside of the slice
            % RGBCustom                                     Colormap
            % MSforNormBaselineStart                        Amount of time to use for Normalizing Purposes
            % MSforNormBaselineEnd                          Amount of time to use for Normalizing Purposes 
            % FrameInterval                                 Time between samples
            %
            %                    <<< OUTPUT VARIABLES <<<
            %
            % NAME                 TYPE                    DESCRIPTION
            % Dataout                                      Single Intergrated image
            % 
            %    
            
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
  %%%%%%%% Create Time to Peak Movie %%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            
             %[TimingCellArray, adjust]=MakeTimingImages(GaussianArrayImages, filename, directoryname, ThisExposure, RGBCustom,  FrameInterval, Max_Time_Cutoff, IterationNumber, Inside_Mask, Outside_Mask,StimTime, camerafileextension);
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
                 % adjust  

%[Created]=generatemovie(TimingCellArray, filename, directoryname,ThisExposure, 1,FrameInterval,MSforNormBaselineStart,500,RGBCustom, 1, IterationNumber, 1 , 'timing', 3 , 5, dataout, StimTime, Max_Time_Cutoff, IterationNumber,0, camerafileextension);
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

 
 disp ('Images Made');
 %ype='norm';
%[Created]=generatemovie(GaussianArrayImages, filename, directoryname,ThisExposure, 200,FrameInterval,MSforNormBaselineStart,500,RGBCustomInverted,(StimTime-200)/FrameInterval, (StimTime+1500)/FrameInterval, 1 , 'Gaussian', 2 , 1000/FrameInterval , dataout, adjust, Max_Time_Cutoff, IterationNumber,0,camerafileextension );
 %disp ('Median Filtered Movies Made');
%                 % Generates movies for different data types with field traces
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

 
 
 
 disp ('Gaussian Filtered Movies Made');
 %%%%%%%%%%%%%%% Generate A Movie
  
  
  
 

  %%%%%%%%%%%%% E-phys trace baseline averagae for fitting graph y-axis
  traceave=mean(TraceData(MSforNormBaselineStart/FrameInterval:MSforNormBaselineEnd/FrameInterval));
  [Tstd, Tmean]=DetermineImageSTD_MEAN(CellArrayImages, MSforNormBaselineStart, MSforNormBaselineEnd, FrameInterval);
            
  %%%%%%%%%%%%%%%%%%%%%%%%%%% Treshhold analysis
 [dataout, dataout_AIT,dataout_AIT_NS, dataout_MIT,dataout_Filtered_Max]=Threshold_Analysis(GaussianArrayImages, GaussianArrayImages_LargeFilterElement2, NumberofThresholds, dataout, dataout_AIT, dataout_AIT_NS, dataout_MIT, dataout_Filtered_Max, traceave, Tmean, Tstd, MSforNormBaselineStart, MSforNormBaselineEnd, filename, FrameInterval,directoryname,Outside_Mask, Inside_Mask, Starting_Fret_Ratio_for_Thresholds);

  %%%%%%%%%%%%%%%%%%%%%%%%%%% Create Thresholded Images
 %[Max_at_Each_Threshold]=ThresholdCounter_Spectrum(GaussianArrayImages, Outside_Mask, filename, directoryname);
  
  for ThisThreshold=2:NumberofThresholds-1
  type='thresh';
 % [ThresholdedImages, Thresholded_Unmasked]=Threshold_Image_Creation(GaussianArrayImages, NumberofThresholds, filename,directoryname,Tmean, Tstd,ThisThreshold, Starting_Fret_Ratio_for_Thresholds);
  %[Centroid_Coordinates]=Centroid_Coordinates(Thresholded_Unmasked, ThisExposure,directoryname,filename, ThisThreshold);
  %[ThresholdedImages]=Gaussian_Filter(ThresholdedImages, MatrixSize, ThisExposure, GaussianValue);
  %[ThresholdedImages]=Gaussian_Filter(ThresholdedImages, MatrixSize, ThisExposure, GaussianValue);
  threshlabel=sprintf('Thresh_%d', ThisThreshold);
  %[MinCutoff, Step]=ScaleandMakeTiffs(ThresholdedImages, filename, directoryname, threshlabel, ThisExposure, RGBCustom,  1, FrameInterval,MSforNormBaselineStart,MSforNormBaselineEnd);
  %[Created]=generatemovie(ThresholdedImages, filename, directoryname,ThisExposure, 500,FrameInterval,MSforNormBaselineStart,500,RGBCustomInverted, (StimTime-100)/FrameInterval, (StimTime+1000)/FrameInterval, ThisThreshold, type,2 , 100, dataout, adjust, Max_Time_Cutoff, IterationNumber,Centroid_Coordinates, camerafileextension);
  disp ('Images Made');
  clear Centroid_Coordinates;
  end
  end
  if ROI_ON==1
  for ROI_Cycle=1:size(ROI_X_Pia,2)
  Time_Average_Temp=CellArrayImages{1};
  Average_Frames=size(Time_Average_Temp,3);
  for ROICount=1:Average_Frames
     tempim=Time_Average_Temp(:,:,ROICount);
     ROI_Data_Pial(ROICount)=mean(tempim(ROI_Composite_Data.PialMask(1,ROI_Cycle).Mask));
     ROI_Data_WhiteMatter(ROICount)=mean(tempim(ROI_Composite_Data.WhiteMatterMask(1,ROI_Cycle).Mask));
  end
  
 
  
  strout1='Ratio_Time_Course';
 
  
  
  ROI_Composite_Data.ROI.Pia(1,ROI_Cycle).Exposure(thisfile,:)=ROI_Data_Pial;
  ROI_Composite_Data.ROI.WhiteMatter(1,ROI_Cycle).Exposure(thisfile,:)=ROI_Data_WhiteMatter;
  ROI_Composite_Data.FileName(1,ROI_Cycle).FileName(thisfile,:)=dd(thisfile,:);
  ROI_Composite_Data.Times(1,ROI_Cycle).Times(thisfile,:)=FrameTimes;
  end
 
  end
  if ROI_ON==2
  for ROI_Cycle=1:ROI_Number
  Time_Average_Temp=CellArrayImages{1};
  Average_Frames=size(Time_Average_Temp,3);
  for ROICount=1:Average_Frames
     tempim=Time_Average_Temp(:,:,ROICount);
     ROI_Data(ROI_Cycle,ROICount)=mean(tempim(ROI_Composite_Data.ROI(1,ROI_Cycle).Mask));
     
  end
  
 
  
  strout1='Ratio_Time_Course';
 
  
  
  ROI_Composite_Data.Output=ROI_Data;
 
  ROI_Composite_Data.FileName(1,ROI_Cycle).FileName(thisfile,:)=dd(thisfile,:);
  ROI_Composite_Data.Times(1,ROI_Cycle).Times(thisfile,:)=FrameTimes;
  end
 
  end
  

end
  if ROI_ON==1
   filenamemat=strrep(fullfilename,strout,'_ROI.mat');
 save (filenamemat, 'ROI_Composite_Data'); 
  end
