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
  [RGBCustomInverted]=CreateRGBColorTableInverted;
  [RGBCustom]=CreateRGBColorTable;
  disp ('ColorMap Created');

  %%%% Starting and Ending Image numbers for each slice

iteration=0;
pixelcount=0;
slicecounter=0;
 Inside_Mask=0; 
  Outside_Mask=0;
  %date=02_08_2008
  %SliceStart=[1,25,26,50,51,75,76,100];
  %date=02_06_2008
  %SliceStart=[1,20,21,49,50,76,77,106,107,126,127,150];
  %date=02_04_2008
  %SliceStart=[1,15,16,33,34,53,54,68,69,84];
   
  %date=02_05_2008
  
  %date=1_28_2008
  %SliceStart=[1,13,14,30,31,40];
  %date=1_15_2008
  %SliceStart=[1,19,20,45,46,70,71,96];
  %date=12_12_2007 
  SliceStart=[1,25,26,48,49,66,67,85];
  %date=12_11_2007
  %SliceStart=[1,21,22,43,44,63,64,83];
  %date=12_10_2007
  %SliceStart=[1,19,20,40,41,62,63,84];
  %date=1_14_2008
  %SliceStart=[1,19,20,39,40,61];
  %date=1_10_2008
  %SliceStart=[1,14,15,33,34,48,50,64];
 
  %date=03-18-2008
  %SliceStart=[1,6,11,15,21,26,31,36,41,46,51,58,63,68,73,78,100];
  %date=03-17-2008
  %SliceStart=[1,6,11,16,21,26,31,36,41,46,51,58,63,68,73,78,100];
  %date=03-14-2008
  %SliceStart=[1,6,11,16,22,27,32,37,42,47,52,57,70];
  Number_of_Slices=size(SliceStart,2)/2;

%%% Check if masks already exist
strout='.da';
filename=dd(SliceStart(1),:);
fullfilename=sprintf('%s/%s',directoryname,filename);
datafileoutputmask=strrep(fullfilename, strout, '_Image_Masks.mat');
datafileoutputstimtimes=strrep(fullfilename, strout, '_Stim_Times.mat');
path2=sprintf('%s/*Image_Masks.*',directoryname);
d2 = dir (path2);
numfiles2=length(d2);

%%%% Open / Make new Slice Masks
if numfiles2==1;
maskholder=load(datafileoutputmask);
stimtimeholder=load(datafileoutputstimtimes);
else
for i=1:Number_of_Slices
    %thisSlice=SliceStart((i-1)*2+1)
    %filename=dd(thisSlice,:)
    filename=dd(SliceStart((i-1)*2+1),:);
    fullfilename=sprintf('%s/%s',directoryname,filename);
    
    %%%%  Open RedShirt File
    [CellArrayImages, FrameTimes,TraceData, FrameInterval,Inside_Mask, Outside_Mask ]=RedShirtOpenSequences(fullfilename,dfsubtract,MS_of_Data_to_Discard_Start, MS_of_Data_to_Discard_End, Masking_Factor,Mask_Counter, Inside_Mask, Outside_Mask);
    %%%%  Create Data Storage File
      %%%%  Detect stimulation time
  temp=CellArrayImages{1};
  ch1=temp(1:40,:,:);
  ch1ave=squeeze(mean(mean(ch1)));
  ch1avesm=smooth(ch1ave);
  ch1avesm=smooth(ch1ave);
  ddd=diff(ch1avesm);
  stimtime=min(ddd)*FrameInterval
  [stimtime loc]=min(ddd)
  framestim=loc;
  StimTime=loc*FrameInterval-4/FrameInterval;
        
    figure(88)
    subplot(2,1,1)
    plot (ch1avesm)
    subplot(2,1,2)
    plot (ddd)
    pause
    Happiness='No';
       while (strcmp(Happiness,'No')==1)
           stimdlg=sprintf('Stim Time was detected at t=%d .  Are you happy with this?',loc);
           Happiness=questdlg(stimdlg,'Registration Checkpoint');
            if (strcmp(Happiness,'No')==1)
                prompt = {'Enter Stim Time                 '};
                dlg_title = 'Adjust Registration              ';
                num_lines = 1;
                def = {num2str(loc)};
                options.WindowStyle='normal';
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                StimTime=str2num(answer{1,1});
                Happiness='Yes';
            end
        end  
    %%%%  Generate subtractive image and select ROI of the entire slice slice 
    [out_Images, Subtracted_Image]=Make_Composite_Image_RedShirt_Modifiable(CellArrayImages, TraceData, FrameTimes,FrameInterval,10,50,StimTime );
    testimage=CellArrayImages{1};
    testimage=testimage(1:40,:,500);
    subplot(2,1,2)
    image(testimage,'CDataMapping','scaled');
    axis image;
    Happiness=questdlg('Please Draw an ROI around the entire slice','GOULET INC');
    maskedarea=roipoly;
    stimtimeholder{i}=StimTime;
    maskholder{i}=maskedarea;
    
end
    save( datafileoutputmask,'maskholder');
    save( datafileoutputstimtimes,'stimtimeholder');
end





close;
iteration=0;
lastfile=Number_of_Slices;
lastfile=SliceStart(lastfile*2);
for thisfile =1:lastfile      %%%%  Select the files to analyze within the selected folder

    iteration=iteration+1;
 
    if 2>1              %%% Use this if you want to batch analyze multiple slics
    for i=1:Number_of_Slices
           StartExposure=SliceStart((i-1)*2+1);
           EndExposure=SliceStart((i-1)*2+2);
           if ((thisfile>=StartExposure)&(thisfile<=EndExposure))
                MaskNumber=i;
           end
    end
    

    if Mask_Counter==1
      Inside_Mask=0;
      Outside_Mask=0;
    end
    else
        MaskNumber=1;
    end
    
    
  this_mask=maskholder.maskholder{1,MaskNumber};
  StimTime=stimtimeholder.stimtimeholder{1,MaskNumber};
  opposite_mask=find(this_mask==0);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  %%%%%%%%%%%%%%%%%%%% Opens each RedShirt File %%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  filename=dd(thisfile,:)
  fullfilename=sprintf('%s/%s',directoryname,filename);
  [CellArrayImages, FrameTimes,TraceData, FrameInterval,Inside_Mask, Outside_Mask ]=RedShirtOpenSequences(fullfilename,dfsubtract,MS_of_Data_to_Discard_Start, MS_of_Data_to_Discard_End, Masking_Factor,Mask_Counter, Inside_Mask, Outside_Mask);
  dataout=[FrameTimes;TraceData]; 
  dy=diff(dataout(2,:));
  

  
  %%%% Integrate the number of pixels
  [out_Images, integration_50_ms]=Variable_Integrater(CellArrayImages, TraceData, FrameTimes,FrameInterval, 10,50,StimTime );
  integration_50_ms(opposite_mask)=0;
  blank=find(integration_50_ms>0);
  integration_50_ms(blank)=0;
  integration_50_ms_peak=min(min(integration_50_ms));
  Intergated_output(iteration,1)=integration_50_ms_peak;
  image(integration_50_ms,'CDataMapping','scaled');
  colormap=(RGBCustomInverted);
  strout='.da';
  Picture_Filename=strrep(fullfilename,strout,'50ms_integrated_signal.jpg');
  saveas(gcf, Picture_Filename);
  
  
  
  [out_Images, integration_100_ms]=Variable_Integrater(CellArrayImages, TraceData, FrameTimes,FrameInterval, 10,100,StimTime );
  integration_100_ms(opposite_mask)=0;
   blank=find(integration_100_ms>0);
  integration_100_ms(blank)=0;
  integration_100_ms_peak=min(min(integration_100_ms));
  Intergated_output(iteration,2)=integration_100_ms_peak;
  
   image(integration_100_ms,'CDataMapping','scaled');
  strout='.da';
  Picture_Filename=strrep(fullfilename,strout,'100ms_integrated_signal.jpg');
  saveas(gcf, Picture_Filename);
  
  [out_Images, integration_500_ms]=Variable_Integrater(CellArrayImages, TraceData, FrameTimes,FrameInterval, 10,500,StimTime );
  integration_500_ms(opposite_mask)=0;
   blank=find(integration_500_ms>0);
  integration_500_ms(blank)=0;
  integration_500_ms_peak=min(min(integration_500_ms));
  Intergated_output(iteration,3)=integration_500_ms_peak;
   image(integration_500_ms,'CDataMapping','scaled');
  strout='.da';
  Picture_Filename=strrep(fullfilename,strout,'500ms_integrated_signal.jpg');
  saveas(gcf, Picture_Filename);





  
  for timewindows=1:60
  [out_Images, Subtracted_Image]=Make_Composite_Image_RedShirt_Modifiable(CellArrayImages, TraceData, FrameTimes,FrameInterval,-100+((timewindows-1)*10),-100+((timewindows)*10),StimTime );
  temp3=Subtracted_Image;
  temp4=Subtracted_Image;
 
  temp3(opposite_mask)=0;
  temp4(opposite_mask)=0;
  remove1=find(temp4<-.2);
  remove=find(temp4>0);
  temp4(remove1)=-.2;
  temp4(remove)=0; 
  mask_size=size(find(this_mask==1),1);
  
  H=fspecial('Gaussian', [2 2], 0.5); 
  temp3=imfilter(temp3, H);
  temp4=imfilter(temp4, H);
temp4=-temp4;
temp4(1,1)=.3;
temp4(1,2)=-.05;
image(temp4,'CDataMapping','scaled');

% Create colorbar

  image(temp4,'CDataMapping','scaled');
 
  strout='.da';
  file_label=sprintf('%d_%d_Activation_window.jpg',-100+((timewindows-1)*10),-100+((timewindows)*10));
  Picture_Filename=strrep(fullfilename,strout,file_label);
  saveas(gcf, Picture_Filename);
  
  FL_max=min(temp3(this_mask));
  
  Active_Area_01=find(temp3(this_mask)<-0.01);
  Active_Area_05=find(temp3(this_mask)<-0.05);
  Active_Area_10=find(temp3(this_mask)<-0.10);
  Active_Area_15=find(temp3(this_mask)<-0.15);
  AA1=size(Active_Area_01,1)/mask_size;
  AA5=size(Active_Area_05,1)/mask_size;
  AA10=size(Active_Area_10,1)/mask_size;
  AA15=size(Active_Area_15,1)/mask_size;
  Data_output(iteration,(timewindows-1)*5+2)=FL_max;
  Data_output(iteration,(timewindows-1)*5+3)=AA1;
  Data_output(iteration,(timewindows-1)*5+4)=AA5;
  Data_output(iteration,(timewindows-1)*5+5)=AA10;
  Data_output(iteration,(timewindows-1)*5+6)=AA15;
end
end
strout='.da';
datafileoutput1=strrep(fullfilename, strout, 'pixels_intensity_thresh.txt');
datafileoutput2=strrep(fullfilename, strout, 'Integrated_Output.txt');
dataoutdouble=double(Data_output);
Integratedoutdouble=double(Intergated_output);
save( datafileoutput1,'dataoutdouble','-ASCII','-tabs');
save( datafileoutput2,'Integratedoutdouble','-ASCII','-tabs');
