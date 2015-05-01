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
%directoryname = uigetdir('/mnt/newhome/mirror/home/chris/MATLAB/');    %%%%% Opens files from MATLAB directory

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
iteration=0;
pixelcount=0;
slicecounter=0;
 Inside_Mask=0;
  Outside_Mask=0;
  %date=03-18-2008
  %SliceStart=[1,6,11,15,21,26,31,36,41,46,51,58,63,68,73,78,100];
  %date=03-17-2008
  %SliceStart=[1,6,11,16,21,26,31,36,41,46,51,58,63,68,73,78,100];
  %date=03-14-2008
  SliceStart=[1,6,11,16,22,27,32,37,42,47,52,57,70];
Number_of_Slices=size(SliceStart,2)/2;

for i=1:Number_of_Slices
    thisSlice=SliceStart((i-1)*2+1)
    filename=dd(thisSlice,:)
    fullfilename=sprintf('%s/%s',directoryname,filename);
    [CellArrayImages, FrameTimes,TraceData, FrameInterval,Inside_Mask, Outside_Mask ]=RedShirtOpenSequences(fullfilename,dfsubtract,MS_of_Data_to_Discard_Start, MS_of_Data_to_Discard_End, Masking_Factor,Mask_Counter, Inside_Mask, Outside_Mask);
  
      testimage=CellArrayImages{1};
      testimage=testimage(1:40,:,500);
      image(testimage,'CDataMapping','scaled');
      maskedarea=roipoly;
      maskholder{i}=maskedarea;

end
  
  
for thisfile =1:100 

for i=1:Number_of_Slices
   StartExposure=SliceStart((i-1)*2+1);
   EndExposure=SliceStart((i-1)*2+3);
   if ((thisfile>=StartExposure)&(thisfile<=EndExposure))
       MaskNumber=i;
   end
end

    %numfiles       %%%%%  Controls which files are being analyzed
 %try
 iteration=iteration+1;
 %%% The next line indicates which imaging experiment is the first for each
 %%% slice

  
   filename=dd(thisfile,:)
  fullfilename=sprintf('%s/%s',directoryname,filename);
  [CellArrayImages, FrameTimes,TraceData, FrameInterval,Inside_Mask, Outside_Mask ]=RedShirtOpenSequences(fullfilename,dfsubtract,MS_of_Data_to_Discard_Start, MS_of_Data_to_Discard_End, Masking_Factor,Mask_Counter, Inside_Mask, Outside_Mask);
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%% Finding the stimulation time %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dataout=[FrameTimes;TraceData]; 
  dx=dataout(2,100/FrameInterval:size(dataout,2)-100/FrameInterval);
  dy=dataout(1,100/FrameInterval:size(dataout,2)-100/FrameInterval);
  dxpre=dx(1:size(dx,2)-1);
  dxpost=dx(2:size(dx,2));
  ddif=dxpre-dxpost;
  dderiv=ddif./dy(1:size(dy, 2)-1);
  [peakvalue, peaktime]=max(dderiv);
  StimTime=peaktime*FrameInterval+100/FrameInterval;
  [RGBCustomInverted]=CreateRGBColorTableInverted;
  [RGBCustom]=CreateRGBColorTable;
   strout='.da';
  
  datafileoutput=strrep(fullfilename, strout, 'pixels_over_thresh.txt');
  datafileoutput1=strrep(fullfilename, strout, 'pixels_intensity_thresh.txt');
  for this_window=1:5
  extension=sprintf('_%d_%d_ms_activation.jpg',(this_window-1)*10,(this_window)*10);
  Time_Ave_Filename=strrep(fullfilename,strout,extension);
  [out_Images,subtracted_Image]=Make_Composite_Image_RedShirt_Modifiable(CellArrayImages, TraceData, FrameTimes,FrameInterval,(this_window-1)*10,(this_window)*10,StimTime);
  close;
  temp3=subtracted_Image;
  this_mask=maskholder{MaskNumber};
  opposite_mask=find(this_mask==0);
  temp3(opposite_mask)=0;
  remove1=find(temp3<-.5);
  remove=find(temp3>.5);
  temp3(remove1)=0;
  temp3(remove)=0;
  iii=find(temp3>-0.1);
  inverse_iii=find(temp3<-0.1);
  pixelcount(thisfile,this_window)=size(inverse_iii,1);
  pixelintensity(thisfile,this_window)=sum(temp3(inverse_iii));
  temp3(iii)=0;
  hand1=image(temp3,'CDataMapping','scaled')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%% Creates the RGB and RGB Inverted Color table %%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  
  saveas(hand1, Time_Ave_Filename);
  end
 

  end

  
  save( datafileoutput,'pixelcount','-ASCII');
  save( datafileoutput1,'pixelintensity','-ASCII');


  
