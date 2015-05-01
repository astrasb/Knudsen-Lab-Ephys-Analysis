%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This code opens all ANDOR Files within a selected folder, and creates
%  ratioed, normalized images of every frame from every file, 
%
%   Each foled must contain all the ANDOR files and pClamp Files for each
%   set of experiments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clear masterdata;

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
Erosion_Factor=5;                                  % Size of Erosion Structure used
Masking_Factor=4;                                 % Masking Adjustment parameter - bigger number = more points farther from the mean will be included in the mask
Max_Time_Cutoff=5;                                 % Size of each time bin in ms for timing analysis
IterationNumber=200;                               % Number of time bins for timing analysis                 
%StimTime=500;                                      % Time of Stimulation in ms10
dfsubtract=1;                                      % Variable indication that dark frame subtraction is ON
clip=4;                                            % Number of pixels to clip off the mask
%2008_02_08_slice#1 clip=5

NormalizationImageBlur=50;                         % ms of data to blur for start and end frames of sliding normalization
Starting_Fret_Ratio_for_Thresholds=1.75;
Clip_Bottom_Extra=4;
camerafileextension='.sif';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Adding additional masking points manually%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Inside_Mask=1;
Outside_Mask=1;
Additional_Mask_Points=0;
Additional_Points=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Start analyzing files %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[masterdata,directoryname,dd, ScaleFactor, OffsetFactor,andorscaled, cookscaled, txmatrix ]=andortest();
ExposureNumber=size((masterdata.images),2);
%cookscaled=cookscaled(:,size(cookscaled,1)/4:3*size(cookscaled,1)/4);
AnalyzeAll=questdlg('Do you want to analyze all the SIF files in this folder?','Goulet Technologies');
if strcmp(AnalyzeAll,'Yes')~=1
which_file = inputdlg('Which single SIF file would you like to analyze');
adjust_file=str2num(which_file{1});
else
    adjust_file=1;
end
for ThisExposure=1:ExposureNumber
clear CellArrayImages;
clear FrameTimes;
clear TraceData;
clear FrameInterval;
clear GaussianArrayImages;

filename=dd(ThisExposure+adjust_file,:);
fullfilename=sprintf('%s/%s',directoryname,filename);
[CellArrayImages, FrameTimes,TraceData, FrameInterval]=Andor_Opener(masterdata, ThisExposure);






% CellArrayImages           double                      the data read, in a x,y,t dataformat
% FrameTimes                double                      an array of sample times [1..Frames]
% TraceData                 double                      an array of electrophysiological samples  [1..Frames]- ONLY CH1 is output in this script
% FrameInterval             double                      sampling interval in ms
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%  Adjust the mask to smooth and shape it %%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%% Consturcting output .mat file data matrix %%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dataout_Filtered_Max=[FrameTimes;TraceData]; 
  dataout=[FrameTimes;TraceData];  
  dataout_AIT=[FrameTimes;TraceData];  
  dataout_MIT=[FrameTimes;TraceData];  

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%% Finding the stimulation time %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %dx=masterdata.subsampleddata(ThisExposure,:);
  dx=dataout(2,:);
  dderiv=diff(dx);
  [peakvalue, peaktime]=max(dderiv);
  StimTime=max(dataout(1,peaktime));
    if ((StimTime-100)<0)
      disp ('Stimulation Time Calculated Incorrectly');
      break
    end

    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%% Creates the RGB and RGB Inverted Color table %%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  [RGBCustomInverted]=CreateRGBColorTableInverted;
  [RGBCustom]=CreateRGBColorTable;
  [BW_RGBCustom]=CreateBW_RGBColorTable;
  disp ('ColorMap Created');
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Goes through individual exposures and %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% performs all analysis         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
  
  
  
      
  DoesThisCellArrayObjectContainData=1;           %%%%%%%%%%% Tests if this exposure has any data - NOT IMPLEMENTED YET
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%% Sliding normalization %%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  testing=0;
  if testing==1;
  [CellArrayImages]=Normalize_Andor_Images(CellArrayImages, FrameTimes,FrameInterval, 1,RGBCustomInverted, Outside_Mask, NormalizationImageBlur);
  disp ('Normalization Completed');
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Takes the Ratio of CH1 and CH2 %%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  [CellArrayImages]=TakeTheRatio(CellArrayImages,1,DoesThisCellArrayObjectContainData);
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



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
  %%%%%%%% Time trace of the ratio values %%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  Time_Average_Temp=CellArrayImages{1};
  Average_Height=size(Time_Average_Temp,1);
  Average_Width=size(Time_Average_Temp,2);
  Time_Average=mean(mean(Time_Average_Temp(Average_Height/4:(Average_Height/4)*3,Average_Width/4:(Average_Width/4)*3,:)));
  Time_Average=squeeze(Time_Average);
  plot(Time_Average);
  strout='.sif';
  U_Ave_Filename=strrep(fullfilename,strout,'_NOT_NORMALIZED_Ratio_Time_Course.jpg');
  saveas(gcf, U_Ave_Filename);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%% Sliding normalization %%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if testing<1;
  [CellArrayImages]=Normalize(CellArrayImages, FrameTimes,FrameInterval, 1,RGBCustomInverted, Outside_Mask, NormalizationImageBlur,2);
  disp ('Normalization Completed');
  end

  
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
        % sliding_blank                                 1=blank & bleaching subtraction 2= blank subtraction only
        %                    <<< OUTPUT VARIABLES <<<
        %
        % NAME                 TYPE                    DESCRIPTION
        % Normalize                                    Cell Array Containing the data normalized data
        % 
        % 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Apply a Prefilter Mask = area outside of
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% the mask is filled with the average
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% intensity within the mask
  if ThisExposure==1
    [Inside_Mask, Outside_Mask]=Andor_Edge_Mask(CellArrayImages, 1, Inside_Mask, Erosion_Factor, clip,Clip_Bottom_Extra, Additional_Mask_Points, Additional_Points);
    
  end
  [CellArrayImages]=Apply_Mask_PreFilter(CellArrayImages,1, Inside_Mask, Outside_Mask,DoesThisCellArrayObjectContainData);
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
  %[GaussianArrayImages]=Gaussian_Filter(CellArrayImages, MatrixSize, 1, GaussianValue);
  %[GaussianArrayImages]=Gaussian_Filter(GaussianArrayImages, MatrixSize, 1, GaussianValue);
  GaussianArrayImages=CellArrayImages;
  %%% Extra Filtering for picking peak amplitude
  [GaussianArrayImages_LargeFilterElement]=Gaussian_Filter(CellArrayImages, MatrixSize*2, 1, GaussianValue);
  [GaussianArrayImages_LargeFilterElement2]=Gaussian_Filter(GaussianArrayImages_LargeFilterElement, MatrixSize*2, 1, GaussianValue);
  
  
  
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
  [GaussianArrayImages]=Apply_Mask(GaussianArrayImages,1, Inside_Mask, Outside_Mask,DoesThisCellArrayObjectContainData);
  
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
  Average_Frames=size(Time_Average_Temp,3);
 
  
  Time_Average=mean(mean(Time_Average_Temp(Average_Height/4:(Average_Height/4)*3,Average_Width/4:(Average_Width/4)*3,:)));
  strout='.sif';
  Time_Average=squeeze(Time_Average);
  plot(Time_Average);
  Time_Ave_Filename=strrep(fullfilename,strout,'_Ratio_Time_Course.jpg');
  %saveas(gcf, Time_Ave_Filename);
  if 1>2
  for ROI_Cycle=1:ROI_Number
  for ROICount=1:Average_Frames
     tempim=Time_Average_Temp(:,:,ROICount);
     ROI_Data(ROICount)=mean(tempim(ROI_Masks{ROI_Cycle}));
  end
  
  plot(ROI_Data);
  Time_Ave_Filename=strrep(fullfilename,strout,'_Ratio_Time_Course.jpg');
  strout1='Ratio_Time_Course';
  Time_Ave_Filename1=strrep(Time_Ave_Filename,strout1,ROI_Number_Name{ROI_Cycle});
  %saveas(gcf, Time_Ave_Filename1);
  close;
  ROI_Composite_Data.ROI(1,ROI_Cycle).Exposure(ThisExposure,:)=ROI_Data;
  ROI_Composite_Data.ROI(1,ROI_Cycle).FileName(ThisExposure,:)=dd(ThisExposure,:);
  ROI_Composite_Data.ROI(1,ROI_Cycle).Times(ThisExposure,:)=FrameTimes;
  end
  end
  

  
  
  
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
            
            
[TimingCellArray, adjust]=MakeTimingImages(CellArrayImages, filename, directoryname, 1, RGBCustom,  FrameInterval, Max_Time_Cutoff, IterationNumber, Inside_Mask, Outside_Mask,StimTime,camerafileextension);
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



 
 
 
%[Created]=generatemovie_Andor(GaussianArrayImages, filename, directoryname,1, 200,FrameInterval,MSforNormBaselineStart,500,RGBCustomInverted,1, size(CellArrayImages{1},3),1 , 'Gaussian', 2 , 100 , dataout, adjust, Max_Time_Cutoff, IterationNumber,0, camerafileextension, cookscaled);
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
 Make_an_Composite_Image=questdlg('Do you want to make a sample composite image?','Fast as it gets YO!!!');
 if strcmp(Make_an_Composite_Image,'No')~=1
 timewindow=100;
 [out_Images]=Make_Composite_Image_Andor(GaussianArrayImages, StimTime, FrameInterval, timewindow);
 end
 
 Make_an_Overlayed_Movie=questdlg('Do you want to make an overlayed movie?','This will be slow as hell');
 if strcmp(Make_an_Overlayed_Movie,'No')~=1
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%% Complile Brightfield and Glut SensorData;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 %%% Mask and scale Cooke Brightfiled image
 if ThisExposure==1
 cookscaled=cookscaled';
 [cooka cookxout]=hist(reshape(cookscaled,1,[]),100);
 cookaa=smooth(cooka,'moving');
 cookaa=smooth(cookaa,'moving');
 cookdaa=diff(cookaa);
 Crosspoint=find(cookdaa>0);
 [testpoint, val]=find(Crosspoint>20);
 clipvalue=cookxout(Crosspoint(testpoint(1)));
 maskcook=find(cookscaled>clipvalue);
 maskcookout=find(cookscaled<clipvalue);
 cookscaled(maskcook)=0;
 cookmax=max(max(cookscaled));
 cook128factor=128/cookmax;
 cook128=cookscaled*cook128factor;
 
 clear maskcook;
 clear maskcookout;
 %transmatrix=[1 0 0; 0 1 0; 0 0 1];
 %forcetoandor=maketform('affine', transmatrix);
 %cookrescaled=imtransform(cook128, forcetoandor,'size', [64 128]);
 end
 %%%%%%%%%%% Create new array for dual overlaid image and insert Cooke
 %%%%%%%%%%% Image
 moviesize=size(GaussianArrayImages{1}); 
 getglutsignal=GaussianArrayImages{1};
 if ThisExposure==1
 padright=moviesize(2)*10-size(cook128,2);
 padleft=abs(OffsetFactor);
 paddingleft=zeros(size(cook128, 1),padleft);
 padding=zeros(size(cook128, 1),padright);
 cook128=[paddingleft cook128 padding];
 end
 z=zeros(size(getglutsignal,1)/2,size(getglutsignal,2),size(getglutsignal,3));
 zz=zeros(size(getglutsignal,1)/2,size(getglutsignal,2),size(getglutsignal,3));
 getglutsignal=[zz;getglutsignal; z];
 glutmin=1.4;%min(min(min(getglutsignal(20:30,20:30,:))));
 glutmax=2;%max(max(max(getglutsignal)));
 glutscalefactor=128/(glutmax-glutmin);

 
 
Happiness='No';
    while (strcmp(Happiness,'No')==1)
           
             txmatrix=[1 0 0
             0 1 0
            OffsetFactor OffsetFactor 1]; 
            testingandor=imresize(getglutsignal(:,:,1),ScaleFactor);
            txform=maketform('affine',txmatrix);
            
            
            txtop=zeros(abs(OffsetFactor),size(cook128,2));
            cook128=[txtop; cook128 ];
            txleft=zeros(size(testingandor,1),abs(OffsetFactor));
            testingandor=[testingandor txleft ];
            
            %testingandor=imtransform(testingandor, txform, 'Xdata',[1 (size(andorscaled,2)+txmatrix(3,1))],'Ydata', [1 (size(andorscaled,1)+txmatrix(3,2))],'FillValues', 0);
            figure(1)
            image(cook128,'cdatamapping','scaled')
             hold on
            omg=image(testingandor,'cdatamapping','scaled')
            set(omg,'AlphaData',0.8)
            colormap jet
%             Happiness=questdlg('Are you happy with the alignment','Registration Checkpoint');
%             if (strcmp(Happiness,'No')==1)
                prompt = {'Enter Scale Factor                 ','Enter Offset Factor                  '};
                dlg_title = 'Adjust Registration              ';
                num_lines = 1;
                def = {num2str(ScaleFactor),num2str(OffsetFactor)};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                ScaleFactor=str2num(answer{1,1});
                OffsetFactor=str2num(answer{2,1});
            end
        end    

  andortxmatrix=[1 0 0
             0 1 0
            OffsetFactor/ScaleFactor OffsetFactor/ScaleFactor 1]; 
   andortxform=maketform('affine',andortxmatrix);   
   
           
            txleft=zeros(size(getglutsignal,1),abs(OffsetFactor)/ScaleFactor, size(getglutsignal,3));
            getglutsignal=[getglutsignal txleft ];
            
%getglutsignal=imtransform(getglutsignal, andortxform, 'Xdata',[1 (size(getglutsignal,2)+abs((andortxmatrix(3,1))))],'Ydata', [1 (size(getglutsignal,1)+abs((andortxmatrix(3,2))))],'FillValues', 0);

 
 
 overlayedmovie=zeros(size(cook128,1),size(cook128,2),moviesize(3));
 
 for i=1:moviesize(3)
 tempcook=cook128;
 tempglut=imresize(getglutsignal(:,:,i),ScaleFactor);
 zz=zeros(size(tempcook,1)-size(tempglut,1),size(tempglut,2));
 tempglut=[tempglut;zz];
 rezero=find(tempglut<1);
 tempglut(rezero)=0;
 glutsignalloc=find((tempglut>1) & (tempglut<2));
 tempglut=(tempglut-glutmin)*glutscalefactor+128;
 
 tempcook(glutsignalloc)=tempglut(glutsignalloc);
 overlayedmovie(:,:,i)=tempcook;
 end
  
 ComboArray{1}=overlayedmovie;
 [Created]=generatemovie_Andor(ComboArray, filename, directoryname,1, 200,FrameInterval,MSforNormBaselineStart,500,BW_RGBCustom,1, size(CellArrayImages{1},3),1 , 'Combo', 4 , 100 , dataout, adjust, Max_Time_Cutoff, IterationNumber,0, camerafileextension, cookscaled);
 else
 
 Make_an_Andor_Movie=questdlg('Do you want to make a simple Andor-only movie?','This will be much faster');
 if strcmp(Make_an_Andor_Movie,'No')~=1
     
 [Created]=generatemovie_Andor(GaussianArrayImages, filename, directoryname,1, 200,FrameInterval,MSforNormBaselineStart,500,RGBCustom,1, size(CellArrayImages{1},3),1 , 'Combo', 5 , 100 , dataout, adjust, Max_Time_Cutoff, IterationNumber,0, camerafileextension, cookscaled);
 end
 end

 
  %%%%%%%%%%%%% E-phys trace baseline averagae for fitting graph y-axis
  %traceave=mean(TraceData(MSforNormBaselineStart/FrameInterval:MSforNormBaselineEnd/FrameInterval));
  %[Tstd, Tmean]=DetermineImageSTD_MEAN(CellArrayImages, MSforNormBaselineStart, MSforNormBaselineEnd, FrameInterval);
            
  %%%%%%%%%%%%%%%%%%%%%%%%%%% Treshhold analysis
  %[dataout, dataout_AIT, dataout_MIT,dataout_Filtered_Max]=Threshold_Analysis(GaussianArrayImages, GaussianArrayImages_LargeFilterElement2, NumberofThresholds, dataout, dataout_AIT, dataout_MIT, dataout_Filtered_Max, traceave, Tmean, Tstd, MSforNormBaselineStart, MSforNormBaselineEnd, filename, FrameInterval,directoryname,Outside_Mask, Inside_Mask, Starting_Fret_Ratio_for_Thresholds);

  %%%%%%%%%%%%%%%%%%%%%%%%%%% Create Thresholded Images
  %[Max_at_Each_Threshold]=ThresholdCounter_Spectrum(GaussianArrayImages, Outside_Mask, filename, directoryname);
  
  for ThisThreshold=2:NumberofThresholds-1
 % type='thresh';
 % [ThresholdedImages, Thresholded_Unmasked]=Threshold_Image_Creation(GaussianArrayImages, NumberofThresholds, filename,directoryname,Tmean, Tstd,ThisThreshold, Starting_Fret_Ratio_for_Thresholds);
 % [Centroid_Coordinates]=Centroid_Coordinates(Thresholded_Unmasked, ThisExposure,directoryname,filename, ThisThreshold);
  %[ThresholdedImages]=Gaussian_Filter(ThresholdedImages, MatrixSize, ThisExposure, GaussianValue);
  %[ThresholdedImages]=Gaussian_Filter(ThresholdedImages, MatrixSize, ThisExposure, GaussianValue);
 % threshlabel=sprintf('Thresh_%d', ThisThreshold);
  %[MinCutoff, Step]=ScaleandMakeTiffs(ThresholdedImages, filename, directoryname, threshlabel, ThisExposure, RGBCustom,  1, FrameInterval,MSforNormBaselineStart,MSforNormBaselineEnd);
%  [Created]=generatemovie(ThresholdedImages, filename, directoryname,ThisExposure, 500,FrameInterval,MSforNormBaselineStart,500,RGBCustomInverted, (StimTime-100)/FrameInterval, (StimTime+1000)/FrameInterval, ThisThreshold, type,2 , 100, dataout, adjust, Max_Time_Cutoff, IterationNumber,Centroid_Coordinates);
 % disp ('Images Made');
 % clear Centroid_Coordinates;
  end
end
 

 filenamemat=strrep(fullfilename,strout,'_ROI.mat');
 %save (filenamemat, 'ROI_Composite_Data');


