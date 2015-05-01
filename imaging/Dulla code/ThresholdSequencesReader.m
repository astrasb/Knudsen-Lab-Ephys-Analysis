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
% list for ???? Additional_Points=[35,34,34,34,33,34,35,35,34,35,33,35,35,36,34,36,35,37,32,34,30,27,28,23,27,21,25,21,26,21,27,22,27,23,28,24,28,25];
% to list extra points list, Y then X coord for each point
% list for 3_18_2008_slice 6 
% Additional_Points=[30,30,29,30,28,30,28,29,30,31,29,31,30,33,30,32,30,34,30,35,30,36,31,36,16,20,15,20,14,20,17,20,18,21,17,21,16,21,18,22,17,22,16,22,19,24,20,25,19,25,23,27,24,28,27,29,26,29,25,29,27,30,26,30,28,31,27,31,29,32,28,32,29,33,28,33,29,34,28,34,29,35,31,37];
% list for 3_02_08_slice 2
%Additional_Points=[35,5,34,5,33,5,32,5,35,6,34,6,33,6,35,7,34,7,35,8,35,58,34,58,33,58,35,57,34,57,33,57,35,56,34,56,33,56];
% list for 12_10_07_slice 1
%for ypoint=1:10
%for xpoint=67+ypoint:80
    
 %   Additional_Points=[Additional_Points ypoint xpoint];    
%    end
%end


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


  if ROI_ON==1
   filename=dd(2,:)  %  SET THE IMAGE TO DEFINE ROIS
  fullfilename=sprintf('%s/%s',directoryname,filename);
  Inside_Mask=0;
  Outside_Mask=0;
  [CellArrayImages, FrameTimes,TraceData, FrameInterval,Inside_Mask, Outside_Mask ]=RedShirtOpenSequences(fullfilename,dfsubtract,MS_of_Data_to_Discard_Start, MS_of_Data_to_Discard_End, Masking_Factor,Mask_Counter, Inside_Mask, Outside_Mask);
  [out_Images]=Make_Composite_Image_RedShirt(CellArrayImages, TraceData, FrameTimes,FrameInterval);
  final=CellArrayImages{1};
  %image(final(1:40,:,500),'cdatamapping','scaled')  
  %axis image;
  msgbox('Click OK then draw a line outlining the pial surface');
  h=impoly(gca,[],'Closed',false); %% this allows you to draw a non closed polygon.
  api = iptgetapi(h);
  Pia_Pos = api.getPosition();
  msgbox('Click OK then draw a line outlining the white matter surface');
  m=impoly(gca,[],'Closed',false); %% this allows you to draw a non closed polygon.
  api = iptgetapi(m);
  White_Matter_Pos = api.getPosition();
  msgbox('Click OK then draw a line outlining the Freeze Lesion');
  t=impoly(gca,[],'Closed',false); %% this allows you to draw a non closed polygon.
  api = iptgetapi(t);
  FL_Pos = api.getPosition();
  %colormap(hsv(128));
  msgbox('Click OK then draw a point on the stimulating electorde');
  e=impoint(gca,[]); %% this allows you to draw a non closed polygon.
  api = iptgetapi(e);
  Stim_Pos = api.getPosition();
  

FL_Slope=diff(FL_Pos(:,2))./diff(FL_Pos(:,1));
FL_Ave_Slope=sum(FL_Slope)/size(find(FL_Slope~=0),1)
Starting_X=min(FL_Pos(:,1));
Starting_Cortical_Thickness=sqrt((FL_Pos(1,1)-FL_Pos(2,1))^2+(FL_Pos(1,2)-FL_Pos(2,2))^2);
Pia_Slope=diff(Pia_Pos(:,2))./diff(Pia_Pos(:,1));
WhiteMatter_Slope=diff(White_Matter_Pos(:,2))./diff(White_Matter_Pos(:,1));
Step_in_out_from_surface=Starting_Cortical_Thickness*0.15;
Drawnsize(1)=size(Pia_Pos,1);
Drawnsize(2)=size(White_Matter_Pos,1);

orientation=inputdlg('Is the Freeze Lesion to the left(1) or to the right(2) of the stimulator?');
orientation=str2double(orientation);
if orientation==1
for Columns=1:min(Drawnsize)-1
    Pia_X_Value=Pia_Pos(1,1);
    Pia_Y_Value=Pia_Pos(1,2);
    WhiteMatter_X_Value=White_Matter_Pos(1,1);
    WhiteMatter_Y_Value=White_Matter_Pos(1,2);
    
    if Columns==1
       if FL_Ave_Slope>0  
       ROI_Y_Pia=FL_Pos(1,2)-sin(atan(-1/FL_Ave_Slope))*3 - sin(atan(FL_Ave_Slope))*Step_in_out_from_surface;
       ROI_Y_WhiteMatter=FL_Pos(2,2)-sin(atan(-1/FL_Ave_Slope))*3 + sin(atan(FL_Ave_Slope))*Step_in_out_from_surface;
       else
           
      ROI_Y_Pia=FL_Pos(1,2)+sin(atan(-1/FL_Ave_Slope))*3 + sin(atan(FL_Ave_Slope))*Step_in_out_from_surface;
       ROI_Y_WhiteMatter=FL_Pos(2,2)+sin(atan(-1/FL_Ave_Slope))*3 - sin(atan(FL_Ave_Slope))*Step_in_out_from_surface;
       end
       
       ROI_X_Pia=Pia_X_Value+cos(atan(-1/FL_Ave_Slope))*3 - cos(atan(FL_Ave_Slope))*Step_in_out_from_surface;
       
       ROI_X_WhiteMatter=WhiteMatter_X_Value+cos(atan(-1/FL_Ave_Slope))*3 + cos(atan(FL_Ave_Slope))*Step_in_out_from_surface;
        
    else
        
        Pia_Seg_Ind=find(Pia_Pos(:,1)>ROI_X_Pia(Columns-1));
        This_Slope_Pia=Pia_Slope(Pia_Seg_Ind(1));
        WhiteMatter_Seg_Ind=find(White_Matter_Pos(:,1)>ROI_X_WhiteMatter(Columns-1));
        This_Slope_WhiteMatter=WhiteMatter_Slope(Pia_Seg_Ind(1));
        This_ROI_Y_Pia=ROI_Y_Pia(Columns-1)+sin(atan(This_Slope_Pia))*5;
        This_ROI_X_Pia=ROI_X_Pia(Columns-1)+cos(atan(This_Slope_Pia))*5;
        This_ROI_Y_WhiteMatter=ROI_Y_WhiteMatter(Columns-1)+sin(atan(This_Slope_WhiteMatter))*5;
        This_ROI_X_WhiteMatter=ROI_X_WhiteMatter(Columns-1)+cos(atan(This_Slope_WhiteMatter))*5;
        
       if (This_ROI_X_Pia<80) && (This_ROI_X_WhiteMatter<80) 
       ROI_Y_Pia=[ROI_Y_Pia, This_ROI_Y_Pia];
       ROI_X_Pia=[ROI_X_Pia, This_ROI_X_Pia];
       ROI_Y_WhiteMatter=[ROI_Y_WhiteMatter, This_ROI_Y_WhiteMatter];
       ROI_X_WhiteMatter=[ROI_X_WhiteMatter, This_ROI_X_WhiteMatter];
        end
    end
end
end
if orientation==2

  for Columns=1:min(Drawnsize)-1
    Pia_X_Value=Pia_Pos(1,1);
    Pia_Y_Value=Pia_Pos(1,2);
    WhiteMatter_X_Value=White_Matter_Pos(1,1);
    WhiteMatter_Y_Value=White_Matter_Pos(1,2);
    
    if Columns==1
        if FL_Ave_Slope>0  
       ROI_Y_Pia=FL_Pos(1,2)-sin(atan(-1/FL_Ave_Slope))*3 - sin(atan(FL_Ave_Slope))*Step_in_out_from_surface;
       ROI_Y_WhiteMatter=FL_Pos(2,2)-sin(atan(-1/FL_Ave_Slope))*3 + sin(atan(FL_Ave_Slope))*Step_in_out_from_surface;
       else
           
      ROI_Y_Pia=FL_Pos(1,2)+sin(atan(-1/FL_Ave_Slope))*3 + sin(atan(FL_Ave_Slope))*Step_in_out_from_surface;
       ROI_Y_WhiteMatter=FL_Pos(2,2)+sin(atan(-1/FL_Ave_Slope))*3 - sin(atan(FL_Ave_Slope))*Step_in_out_from_surface;
       end
       
          
       ROI_X_Pia=Pia_X_Value-cos(atan(-1/FL_Ave_Slope))*3 - cos(atan(FL_Ave_Slope))*Step_in_out_from_surface;
       
       ROI_X_WhiteMatter=WhiteMatter_X_Value-cos(atan(-1/FL_Ave_Slope))*3 + cos(atan(FL_Ave_Slope))*Step_in_out_from_surface;
        
    else
        
        Pia_Seg_Ind=find(Pia_Pos(:,1)<ROI_X_Pia(Columns-1));
        This_Slope_Pia=Pia_Slope(Pia_Seg_Ind(1));
        WhiteMatter_Seg_Ind=find(White_Matter_Pos(:,1)<ROI_X_WhiteMatter(Columns-1));
        This_Slope_WhiteMatter=WhiteMatter_Slope(Pia_Seg_Ind(1));
        This_ROI_Y_Pia=ROI_Y_Pia(Columns-1)-sin(atan(This_Slope_Pia))*5;
        This_ROI_X_Pia=ROI_X_Pia(Columns-1)-cos(atan(This_Slope_Pia))*5;
        This_ROI_Y_WhiteMatter=ROI_Y_WhiteMatter(Columns-1)-sin(atan(This_Slope_WhiteMatter))*5;
        This_ROI_X_WhiteMatter=ROI_X_WhiteMatter(Columns-1)-cos(atan(This_Slope_WhiteMatter))*5;
        
       if (This_ROI_X_Pia<80) && (This_ROI_X_WhiteMatter<80) 
       ROI_Y_Pia=[ROI_Y_Pia, This_ROI_Y_Pia];
       ROI_X_Pia=[ROI_X_Pia, This_ROI_X_Pia];
       ROI_Y_WhiteMatter=[ROI_Y_WhiteMatter, This_ROI_Y_WhiteMatter];
       ROI_X_WhiteMatter=[ROI_X_WhiteMatter, This_ROI_X_WhiteMatter];
        end
    end
end  
    
end

hold(gca,'on');
plot(int16(ROI_X_Pia), int16(ROI_Y_Pia), 'b*');
plot(int16(ROI_X_WhiteMatter), int16(ROI_Y_WhiteMatter), 'b*');
hold(gca,'off');

for i=1:size(ROI_X_Pia,2)
p_ellipse = imellipse(gca,[ROI_X_Pia(i)-1 ROI_Y_Pia(i)-1 3 3]);
api = iptgetapi(p_ellipse);
vert = api.getVertices();
mask = poly2mask(vert(:,1),vert(:,2),40,80);
ROI_Composite_Data.PialMask(1,i).Mask=mask;
wm_ellipse = imellipse(gca,[ROI_X_WhiteMatter(i)-1 ROI_Y_WhiteMatter(i)-1 3 3]);
api = iptgetapi(wm_ellipse);
vert = api.getVertices();
mask = poly2mask(vert(:,1),vert(:,2),40,80);
ROI_Composite_Data.WhiteMatterMask(1,i).Mask=mask;
end

  strout='.da';
  ROI_Picture_Filename=strrep(fullfilename,strout,'_ROI_Map.jpg');
  saveas(gcf, ROI_Picture_Filename);


%ROI_Number_String=inputdlg('How many ROI would you like to draw?');
%ROI_Number=str2double(ROI_Number_String);

close;
end
 
if ROI_ON==2
    ROI_Number=inputdlg('How Many ROI would you like to draw?');
    ROI_Number=str2double(ROI_Number);
     filename=dd(2,:)  %  SET THE IMAGE TO DEFINE ROIS
    fullfilename=sprintf('%s/%s',directoryname,filename);
  Inside_Mask=0;
  Outside_Mask=0;
    [CellArrayImages, FrameTimes,TraceData, FrameInterval,Inside_Mask, Outside_Mask ]=RedShirtOpenSequences(fullfilename,dfsubtract,MS_of_Data_to_Discard_Start, MS_of_Data_to_Discard_End, Masking_Factor,Mask_Counter, Inside_Mask, Outside_Mask);
  [out_Images,subtracted_Image]=Make_Composite_Image_RedShirt(CellArrayImages, TraceData, FrameTimes,FrameInterval);
for ROI_Cycle=1:ROI_Number
BW=roipoly;
ROI_Masks{ROI_Cycle}=BW;
ROI_Composite_Data.ROI(ROI_Cycle).Mask=BW;
ROI_Number_Name(ROI_Cycle)=inputdlg('Please Give your ROI a Name?');
ROI_Composite_Data.ROI(ROI_Cycle).Label=ROI_Number_Name(ROI_Cycle);
end
end 

drawmask=1;

for thisfile =72:75      %%%%%  Controls which files are being analyzed
 %try
 
 %%% The next line indicates which imaging experiment is the first for each
 %%% slice
  if ((thisfile==1)|(thisfile== 15 )|(thisfile== 31)|(thisfile== 74))   
      Mask_Counter=0;
  end
  Mask_Counter=Mask_Counter+1;
  if Mask_Counter==1
      Inside_Mask=0;
      Outside_Mask=0;
  end
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  %%%%%%%%%%%%%%%%%%%% Opens each RedShirt File %%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  %%%  Put a stop on the next line to alter the masking - 
  % then step into RedShirtOpenSequences by hitting (F11) 

  
   filename=dd(thisfile,:)
  fullfilename=sprintf('%s/%s',directoryname,filename);
  [CellArrayImages, FrameTimes,TraceData, FrameInterval,Inside_Mask, Outside_Mask ]=RedShirtOpenSequences(fullfilename,dfsubtract,MS_of_Data_to_Discard_Start, MS_of_Data_to_Discard_End, Masking_Factor,Mask_Counter, Inside_Mask, Outside_Mask);
  if ROI_ON==1
      Outside_Mask=0;
  end
  if drawmask==1
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
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%  Adjust the mask to smooth and shape it %%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  if drawmask==0
  if Mask_Counter==1
  [Inside_Mask, Outside_Mask]=Erode_Mask(CellArrayImages, 1, Inside_Mask, Erosion_Factor, clip,Clip_Bottom_Extra, Additional_Mask_Points, Additional_Points);
  end
  end
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
  
%  catch ME
    %  disp('Try Again')
  %end

end
  if ROI_ON==1
   filenamemat=strrep(fullfilename,strout,'_ROI.mat');
 save (filenamemat, 'ROI_Composite_Data'); 
  end
