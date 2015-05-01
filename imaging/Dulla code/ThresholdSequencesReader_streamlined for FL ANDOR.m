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

 
%%%%%%%%%%%%%%%% Sets Constants
MS_of_Data_to_Discard_Start=250;                    % Amount of time to be excluded from analysis - Front End
MS_of_Data_to_Discard_End=3000;                      % Amount of time to be excluded from analysis - Front End
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
FramesBlurred=5;
NormalizationImageBlur=50;                         % ms of data to blur for start and end frames of sliding normalization
Starting_Fret_Ratio_for_Thresholds=1.8;
Clip_Bottom_Extra=3;
camerafileextension='.da';
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
  [Images, FrameTimes,TraceData, FrameInterval ]=RedShirtOpenSequences_streamlined(fullfilename);
  
  %%% Clip Start and Finish of file
  
  Image_c=Images(:,:,MS_of_Data_to_Discard_Start/FrameInterval:size(Images,3)-MS_of_Data_to_Discard_End/FrameInterval);
  clear Images;
  Images=Image_c;
  clear Image_c;
 
  Trace_c=TraceData(:,MS_of_Data_to_Discard_Start/FrameInterval:size(TraceData,2)-MS_of_Data_to_Discard_End/FrameInterval);
  clear TraceData;
  TraceData=Trace_c;
  clear Trace_c;
   
  FT_c=FrameTimes(1,MS_of_Data_to_Discard_Start/FrameInterval:size(FrameTimes,2)-MS_of_Data_to_Discard_End/FrameInterval);
  clear FrameTimes;
  FrameTimes=FT_c;
  clear FT_c;
 
  
%%% Draw Mask of the Slice  
  
  if thisfile==1
     testimage=Images(1:40,:,500);
     image(testimage,'CDataMapping','scaled');
     Inside_Mask=roipoly;
     Outside_Mask=find(Inside_Mask==0);
  end
     opposite_mask=Outside_Mask; 
       
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%% Finding the stimulation time %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    d_stim=diff(TraceData(1,:));
    stimframeplus=find(d_stim>0.2);
    stimframeminus=find(d_stim<-0.2);
    t=size(stimframeminus,2);
    tt=size(stimframeplus,2);
    if (tt>0)&&(t>0)
    
    if stimframeplus(1)>stimframeminus(1)
        stimframe=stimframeminus(1);
    else
        stimframe=stimframeplus(1);
    end
    else
        %stimframe=370;
        stimframe=870; %% For slices on 1/28/09
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
  
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Takes the Ratio of CH1 and CH2 %%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ch1=Images(1:(size(Images,1)/2),:,:);
  ch2=Images((size(Images,1)/2)+1:size(Images,1),:,:);
  

%Curve Fitting
ch1tofit=squeeze(mean(mean(ch1)));
ch2tofit=squeeze(mean(mean(ch2)));

%%%% Plotting the means of Ch1 and Ch2 for Curve fitting
subplot(2,1,1)
plot(ch1tofit)
subplot(2,1,2)
plot(ch2tofit)
x_cutoff=0;
x_restart=100;
if thisfile==1
prompt = {'Enter the last x-value pre-glutamate application to use for curve fitting                 '};
dlg_title = 'Adjust Registration              ';
num_lines = 1;
def = {num2str(x_cutoff)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
x_cutoff=str2num(answer{1,1});
end
fit_ch1=ch1tofit(1:x_cutoff);
fit_ch2=ch2tofit(1:x_cutoff);

if thisfile==1
prompt = {'Enter the first x-value post-glutamte application to use for curve fitting                 '};
dlg_title = 'Adjust Registration              ';
num_lines = 1;
def = {num2str(x_restart)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
x_restart=str2num(answer{1,1});
end
fit_ch1=[fit_ch1;ch1tofit(x_restart:size(ch1,3))];
fit_ch2=[fit_ch2;ch2tofit(x_restart:size(ch1,3))];
close
for hh=1:size(ch1,3)
    time(hh)=hh;
end
fit_time=[time(1:x_cutoff),time(x_restart:size(ch1,3))];
if x_restart==size(ch1,2)
   fit_ch1=fit_ch1(1:size(fit_ch1,2)-1);
   fit_ch2=fit_ch2(1:size(fit_ch2,2)-1);
   fit_time=fit_time(1:size(fit_ch1,2));
end
fit_ch1=double(fit_ch1);
fit_ch2=double(fit_ch2);
fit_time=fit_time';

%%%% Fitting Ch1 and Ch2 independently
% --- Create fit "fit 1"
fo_ = fitoptions('method','NonlinearLeastSquares');%,'Robust','On','Algorithm','Levenberg-Marquardt');
ok_ = isfinite(fit_time) & isfinite(fit_ch1);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [12.157435039177022063 -0.047832406644661290551 1080.5679694878069768 -0.0011811405752495413718 ];
set(fo_,'Startpoint',st_);
ft_ = fittype('exp2');

% Fit this model using new data
cf_ = fit(fit_time(ok_),fit_ch1(ok_),ft_,fo_);

% Or use coefficients from the original fit:
if 0
   cv_ = { 52.697750977965384322, -0.57107350967034153921, 1082.9534326239570419, -0.0012917054854730896599};
   cf_ = cfit(ft_,cv_{:});
end


% --- Create fit "fit 2"
fo2_ = fitoptions('method','NonlinearLeastSquares');%,'Robust','On','Algorithm','Levenberg-Marquardt');
ok2_ = isfinite(fit_time) & isfinite(fit_ch2);
if ~all( ok2_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st2_ = [12.157435039177022063 -0.047832406644661290551 1080.5679694878069768 -0.0011811405752495413718 ];
set(fo2_,'Startpoint',st2_);
ft2_ = fittype('exp2');

% Fit this model using new data
cf2_ = fit(fit_time(ok2_),fit_ch2(ok2_),ft2_,fo2_);

% Or use coefficients from the original fit:
if 0
   cv2_ = { 52.697750977965384322, -0.57107350967034153921, 1082.9534326239570419, -0.0012917054854730896599};
   cf2_ = cfit(ft2_,cv2_{:});
end

%%%%%%%%%%%  Curve fit subtraction
coeffvalues1=coeffvalues(cf_);
coeffvalues2=coeffvalues(cf2_);
for hh=1:size(ch1,3)
    Ch1_fit_results(hh)=coeffvalues1(1)*exp(coeffvalues1(2)*hh)+coeffvalues1(3)*exp(coeffvalues1(4)*hh);
    Ch2_fit_results(hh)=coeffvalues2(1)*exp(coeffvalues2(2)*hh)+coeffvalues2(3)*exp(coeffvalues2(4)*hh);
end

ch1sub=ch1tofit-Ch1_fit_results';
ch2sub=ch2tofit-Ch2_fit_results';
ch1sub=ch1sub+ch1tofit(1,1);
ch2sub=ch2sub+ch2tofit(1,1);
ratiosub=ch1sub./ch2sub;

ch1start=ch1(:,:,1);
ch2start=ch2(:,:,1);

ch1end=ch1(:,:,size(ch1,3));
ch2end=ch2(:,:,size(ch2,3));


%%% Subtractive normalization based on curve fit
ch1fitmax=max(Ch1_fit_results);
ch2fitmax=max(Ch2_fit_results);
ch1fitmin=min(Ch1_fit_results);
ch2fitmin=min(Ch2_fit_results);
ch1diff=ch1fitmax-ch1fitmin;
ch2diff=ch2fitmax-ch2fitmin;
Ch1_Normalized=zeros(size(ch1,1),size(ch1,2),size(ch1,3));
Ch2_Normalized=zeros(size(ch1,1),size(ch1,2),size(ch1,3));
   for i=1:size(ch1,3)
       
            ThisFrame1=ch1(:,:,i);
            ThisFrame2=ch2(:,:,i);
            TimeRelativeToStart1=(Ch1_fit_results(i)-ch1fitmin)/ch1diff;
            TimeRelativeToStart2=(Ch2_fit_results(i)-ch2fitmin)/ch2diff;
            TimeRelativeToEnd1=1-TimeRelativeToStart1;
            TimeRelativeToEnd2=1-TimeRelativeToStart2;
            tempFrame1=ch1start*TimeRelativeToStart1+ch1end*TimeRelativeToEnd1;
            tempFrame2=ch2start*TimeRelativeToStart2+ch2end*TimeRelativeToEnd2;
            NormFrame1=ThisFrame1-tempFrame1+mean(mean(mean(ch1start(size(ch1,1)/4:3*size(ch1,1)/4,size(ch1,2)/8:7*size(ch1,2)/8))));
            NormFrame2=ThisFrame2-tempFrame2+mean(mean(mean(ch2start(size(ch1,1)/4:3*size(ch1,1)/4,size(ch1,2)/8:7*size(ch1,2)/8))));
            Ch1_Normalized(:,:,i)=NormFrame1;
            Ch2_Normalized(:,:,i)=NormFrame2;
   end
  Ratio=Ch1_Normalized./Ch2_Normalized;
  disp ('Ratio Completed');
 
  for maskframe=1:size(Ratio,3)
     tempframe=Ratio(:,:,maskframe);
     tempframe(Outside_Mask)=0;
     Ratio(:,:,maskframe)=tempframe;      
  end
  

  
       
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Apply a Prefilter Mask = area outside of
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% the mask is filled with the average
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% intensity within the mask
  [Ratio]=Apply_Mask_PreFilter_streamlined(Ratio, Inside_Mask, Outside_Mask);
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
  

  [Ratio]=Gaussian_Filter_streamlined(Ratio, MatrixSize, GaussianValue);
  [Ratio]=Gaussian_Filter_streamlined(Ratio, MatrixSize, GaussianValue);
  for maskframe=1:size(Ratio,3)
     tempframe=Ratio(:,:,maskframe);
     tempframe(Outside_Mask)=0;
     Ratio(:,:,maskframe)=tempframe;      
  end
  
  
  
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
  
if thisfile==1
RotAlign='No';
Rot=0;
this_image_file=ch1(:,:,500);
while (strcmp(RotAlign,'No')==1)
    if (strcmp(RotAlign,'No')==1)
        prompt = {'Enter the degrees of Rotation                 '};
        dlg_title = 'Rotate Rotons             ';
        num_lines = 1;
        def = {num2str(Rot)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        Rot=str2num(answer{1,1});
        Peak_Rot_Tx=imrotate(this_image_file,Rot,'bilinear');
        image(Peak_Rot_Tx,'cdatamapping','scaled')
        colormap jet
        axis image;
        RotAlign=questdlg('Are you happy with the Rotational alignment','Registration Checkpoint');
    end
end
end
if thisfile==1
labelimage=ch1(:,:,500);
rotated=imrotate(labelimage,Rot,'bilinear');
image(rotated,'cdatamapping','scaled')
point=roipoly;
[stimrow, stimcol]=find(point==1);
stim_loc_data=[mean(stimrow),mean(stimcol)];
end

rotated_profiling=imrotate(Ratio(:,:,stimframe-10:stimframe+49),Rot,'bilinear');
blanktemp=FrameAverage(rotated_profiling,1,9);
blank=sum(blanktemp);
vertblank=sum(blanktemp');
if thisfile==1
profile=zeros(numfiles, 60,size(blank,2));
profilevert=zeros(numfiles,60,size(vertblank,2));
Column_skew_instant_write=zeros(numfiles, 60);
Layer_skew_instant_write=zeros(numfiles, 60);
Column_kurt_instant_write=zeros(numfiles, 60);
Layer_kurt_instant_write=zeros(numfiles, 60);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%% Treshhold analysis
 for timewindows=1:60
  %%% Create baseline subtracted images     
  [out_Images, Subtracted_Image]=Make_Composite_Image_RedShirt_Modifiable_non_cellarray(Ratio, TraceData, FrameTimes,FrameInterval,-100+((timewindows-1)*10),-100+((timewindows)*10),stimframe );
  
  % Mask and Filter the subtraced image
  temp3=Subtracted_Image;
  temp3(opposite_mask)=0;
  mask_size=size(find(Inside_Mask==1),1);
  H=fspecial('Gaussian', [2 2], 0.5); 
  temp3=imfilter(temp3, H);
  

  
  % Find Max FRET change
  FL_max=min(temp3(Inside_Mask));
  
  % Find Ave Max Fret Change, Skewness, Kurtosis for 4 different thresholds
  % of actice areas
  
  % threshold 1 = <0.01
  Active_Area_01=find(temp3(Inside_Mask)<-0.01);
  A_test=find(temp3<-0.01);
  % Skewness and Kurtosis
  if size(Active_Area_01,1)>1
  kurt_image=temp3;
  rotated=imrotate(kurt_image,Rot,'bilinear');
  Active_Area=find( rotated<-0.01);
  In_Active_Area=find( rotated>-0.01);
  rotated(Active_Area)=1;
  rotated(In_Active_Area)=0;
  Column_skew_01=sum(rotated);
  Layer_skew_01=sum(rotated');
  Column_skew_01_out=Column_skew_01(find(Column_skew_01>1));
  Layer_skew_01_out=Layer_skew_01(find(Layer_skew_01>1));
  Column_skew_01_write=skewness(Column_skew_01_out);
  Layer_skew_01_write=skewness(Layer_skew_01_out);
  Column_kurt_01_write=kurtosis(Column_skew_01_out);
  Layer_kurt_01_write=kurtosis(Layer_skew_01_out);
  else
  Column_skew_01_write=0;
  Layer_skew_01_write=0;
  Column_kurt_01_write=0;
  Layer_kurt_01_write=0;
  end
  hist_peak=sort(temp3(A_test));
  if size(hist_peak,1)>25
      mean_peak_01=squeeze(mean(hist_peak(1:25)));
  else
      mean_peak_01=0;
  end
  
  % threshold 2<0.05
  Active_Area_05=find(temp3(Inside_Mask)<-0.05);
  % Skewness and Kurtosis
  if size(Active_Area_05,1)>1
  kurt_image=temp3;
  rotated=imrotate(kurt_image,Rot,'bilinear');
  Active_Area=find( rotated<-0.05);
  In_Active_Area=find( rotated>-0.05);
  rotated(Active_Area)=1;
  rotated(In_Active_Area)=0;
  Column_skew_05=sum(rotated);
  Layer_skew_05=sum(rotated');
  Column_skew_05_out=Column_skew_05(find(Column_skew_05>1));
  Layer_skew_05_out=Layer_skew_05(find(Layer_skew_05>1));
  Column_skew_05_write=skewness(Column_skew_05_out);
  Layer_skew_05_write=skewness(Layer_skew_05_out);
  Column_kurt_05_write=kurtosis(Column_skew_05_out);
  Layer_kurt_05_write=kurtosis(Layer_skew_05_out);
  else
  Column_skew_05_write=0;
  Layer_skew_05_write=0;
  Column_kurt_05_write=0;
  Layer_kurt_05_write=0;
  end
  
  % Ave Delta FRET
  A_test_5=find(temp3<-0.05);
  hist_peak_5=sort(temp3(A_test_5));
  if size(hist_peak_5,1)>25
      mean_peak_05=squeeze(mean(hist_peak_5(1:25)));
  else
      mean_peak_05=0;
  end
  
  % threshold 2<0.10
  Active_Area_10=find(temp3(Inside_Mask)<-0.10);
  if size(Active_Area_10,1)>1
  kurt_image_2=temp3;
  rotated=imrotate(kurt_image_2,Rot,'bilinear');
  Active_Area=find( rotated<-0.10);
  In_Active_Area=find( rotated>-0.10);
  rotated(Active_Area)=1;
  rotated(In_Active_Area)=0;
  Column_skew_10=sum(rotated);
  Layer_skew_10=sum(rotated');
  Column_skew_10_out=Column_skew_10(find(Column_skew_10>1));
  Layer_skew_10_out=Layer_skew_10(find(Layer_skew_10>1));
  Column_skew_10_write=skewness(Column_skew_10_out);
  Layer_skew_10_write=skewness(Layer_skew_10_out);
  Column_kurt_10_write=kurtosis(Column_skew_10_out);
  Layer_kurt_10_write=kurtosis(Layer_skew_10_out);
  else
  Column_skew_10_write=0;
  Layer_skew_10_write=0;
  Column_kurt_10_write=0;
  Layer_kurt_10_write=0;
  end
  
  
  A_test_10=find(temp3<-0.1);
  hist_peak_10=sort(temp3(A_test_10));
  if size(hist_peak_10,1)>25
      mean_peak_10=squeeze(mean(hist_peak_10(1:25)));
  else
      mean_peak_10=0;
  end
  
  % threshold 3<0.15
  Active_Area_15=find(temp3(Inside_Mask)<-0.15);
  if size(Active_Area_15,1)>1
  kurt_image_15=temp3;
  rotated=imrotate(kurt_image_15,Rot,'bilinear');
  Active_Area=find( rotated<-0.05);
  In_Active_Area=find( rotated>-0.05);
  rotated(Active_Area)=1;
  rotated(In_Active_Area)=0;
  Column_skew_15=sum(rotated);
  Layer_skew_15=sum(rotated');
  Column_skew_15_out=Column_skew_15(find(Column_skew_15>1));
  Layer_skew_15_out=Layer_skew_15(find(Layer_skew_15>1));
  Column_skew_15_write=skewness(Column_skew_15_out);
  Layer_skew_15_write=skewness(Layer_skew_15_out);
  Column_kurt_15_write=kurtosis(Column_skew_15_out);
  Layer_kurt_15_write=kurtosis(Layer_skew_15_out);
  else
  Column_skew_15_write=0;
  Layer_skew_15_write=0;
  Column_kurt_15_write=0;
  Layer_kurt_15_write=0;
  end
  
  
  A_test_15=find(temp3<-0.15);
  hist_peak_15=sort(temp3(A_test_15));
  if size(hist_peak_15,1)>25
      mean_peak_15=squeeze(mean(hist_peak_15(1:25)));
  else
      mean_peak_15=0;
  end
  
  AA1=size(Active_Area_01,1)/mask_size;
  AA5=size(Active_Area_05,1)/mask_size;
  AA10=size(Active_Area_10,1)/mask_size;
  AA15=size(Active_Area_15,1)/mask_size;
  Data_output(thisfile,1,(timewindows))=-100+((timewindows-1)*10);
  Data_output(thisfile,2,(timewindows))=FL_max;
  Data_output(thisfile,3,(timewindows))=mean_peak_01;
  Data_output(thisfile,4,(timewindows))=mean_peak_05;
  Data_output(thisfile,5,(timewindows))=mean_peak_10;
  Data_output(thisfile,6,(timewindows))=mean_peak_15;
  Data_output(thisfile,7,(timewindows))=AA1;
  Data_output(thisfile,8,(timewindows))=AA5;
  Data_output(thisfile,9,(timewindows))=AA10;
  Data_output(thisfile,10,(timewindows))=AA15;
  Data_output(thisfile,11,(timewindows))=Column_skew_01_write;
  Data_output(thisfile,12,(timewindows))=Layer_skew_01_write;
  Data_output(thisfile,13,(timewindows))=Column_kurt_01_write;
  Data_output(thisfile,14,(timewindows))=Layer_kurt_01_write;
  Data_output(thisfile,15,(timewindows))=Column_skew_05_write;
  Data_output(thisfile,16,(timewindows))=Layer_skew_05_write;
  Data_output(thisfile,17,(timewindows))=Column_kurt_05_write;
  Data_output(thisfile,18,(timewindows))=Layer_kurt_05_write;
  Data_output(thisfile,19,(timewindows))=Column_skew_10_write;
  Data_output(thisfile,20,(timewindows))=Layer_skew_10_write;
  Data_output(thisfile,21,(timewindows))=Column_kurt_10_write;
  Data_output(thisfile,22,(timewindows))=Layer_kurt_10_write;
  Data_output(thisfile,23,(timewindows))=Column_skew_15_write;
  Data_output(thisfile,24,(timewindows))=Layer_skew_15_write;
  Data_output(thisfile,25,(timewindows))=Column_kurt_15_write;
  Data_output(thisfile,26,(timewindows))=Layer_kurt_15_write;
end


for k=1:60
profile(thisfile,k,:)=sum(rotated_profiling(:,:,k))-blank;    
profilevert(thisfile,k,:)=sum(rotated_profiling(:,:,k)')-vertblank;
pro=sum(rotated_profiling(:,:,k))-blank;    
prov=sum(rotated_profiling(:,:,k)')-vertblank;

Column_skew_instant_out=pro(find(pro~=0));
Layer_skew_instant_out=prov(find(prov~=0));
Column_skew_instant_write(thisfile,k)=skewness(Column_skew_instant_out);
Layer_skew_instant_write(thisfile,k)=skewness(Layer_skew_instant_out);
Column_kurt_instant_write(thisfile,k)=kurtosis(Column_skew_instant_out);
Layer_kurt_instant_write(thisfile,k)=kurtosis(Layer_skew_instant_out);
end

pause=1;

end
params.mask=Outside_Mask;
params.rot=Rot;
params.stim_loc=stim_loc_data;

dataouput_filename1=sprintf('%s/%s_profilevert.mat',directoryname,filename(1:size(filename,2)-3));
dataouput_filename2=sprintf('%s/%s_profile',directoryname,filename(1:size(filename,2)-3));
dataouput_filename3=sprintf('%s/%s_col_skew.mat',directoryname,filename(1:size(filename,2)-3));
dataouput_filename4=sprintf('%s/%s_lay_skew.mat',directoryname,filename(1:size(filename,2)-3));
dataouput_filename5=sprintf('%s/%s_col_kurt.mat',directoryname,filename(1:size(filename,2)-3));
dataouput_filename6=sprintf('%s/%s_lay_kurt.mat',directoryname,filename(1:size(filename,2)-3));
dataouput_filename7=sprintf('%s/%s_params.mat',directoryname,filename(1:size(filename,2)-3));

dataouput_filename=sprintf('%s/%s_streamlinedoutput.mat',directoryname,filename(1:size(filename,2)-3));
save(dataouput_filename,'Data_output');
save (dataouput_filename2, 'profile');
save (dataouput_filename1, 'profilevert');
save (dataouput_filename3, 'Column_skew_instant_write');
save (dataouput_filename4, 'Layer_skew_instant_write');
save (dataouput_filename5, 'Column_kurt_instant_write');
save (dataouput_filename6, 'Layer_kurt_instant_write');
save (dataouput_filename7, 'params');


  