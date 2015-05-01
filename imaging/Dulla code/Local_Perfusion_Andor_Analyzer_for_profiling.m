%%%%%%%%  Analyzing Andor Slow Calibration Files %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Use this program to open, draw roi's and compute ratio/time
%  courses for slow (1 image every 10 secs) local perfursion
% calibration files with darkfield subtraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
parameters_present=0;
[RGBCustom]=CreateRGBColorTableInverted;

%%%% Choose a folder with multple slices from 1 day in it
directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
path1dir=sprintf('%s/*lice*',directoryname);
ddir = dir (path1dir);
numfilesdir=length(ddir);
if numfilesdir<1
    disp('No files found');
end

%%%%  Create a variable with all the folder names
for i = 1:numfilesdir
    t = length(getfield(ddir,{i},'name')) ;
    dddir(i, 1:t) = getfield(ddir,{i},'name') ;
end

%%%%  Enter the First Slice folder and process it
for this_slice=1:size(dddir,1)
clear ddir;
clear NumberGlut;
clear fn;
clear Ch1_fit_results;
clear Ch2_fit_results;
    %%%  Get the Glut perfusion andor file
    PathName=sprintf('%s/%s/', directoryname,dddir(this_slice,:));
    search_folder_Glut=sprintf('%s/*tit*.sif',PathName);
    ddir = dir (search_folder_Glut);
    NumberGlut=length(ddir)-2;
    if NumberGlut<1
     disp('No files found');
    end


fn=sprintf('%s%s',PathName,ddir.name);
[Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(fn)
temp=Image.data;

%%% use this only for 3/6/2009
if 2>4
if this_slice==2
    temp(:,:,73:100)=[];
end
end
exposuretime=InstaImage.exposure_time;


%%%%%%%%%%%% Open Darkfield file
ext='ark';
path1=sprintf('%s/*%s*',PathName,ext);
d = dir (path1);
numfiles_d=length(d);

if numfiles_d<1
    disp('No files found');
end

for i = 1:numfiles_d
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end

fn_d= sprintf('%s%s',PathName,dd(1,:));


[DarkImage,DarkInstaImage,DarkCalibImage,Darkvers]=andorread_chris_local_knownfilename(fn_d)
dark=DarkImage.data;
if 2>5  %%  changes for different size of dark images
dark_Image=FrameAverage(dark,1,size(dark,3)-1);
else
    dark_Image=dark;
end
%%%%%%%%%%  Darkfield subtraction
for i=1:size(temp,3)
    tempframe=temp(:,:,i);
    tempframe=tempframe-dark_Image;
    temp(:,:,i)=tempframe;

end

%%%%% Breaking up Ch1 and Ch2
Aligned='No';
VertAdjust=0;
HorizAdjust=0;
ch1=temp(1:64,:,:);
ch2=temp(65:128,:,:);
ch1tofit=squeeze(mean(mean(ch1)));
ch2tofit=squeeze(mean(mean(ch2)));

%%%% Plotting the means of Ch1 and Ch2 for Curve fitting
subplot(2,1,1)
plot(ch1tofit)
subplot(2,1,2)
plot(ch2tofit)
x_cutoff=0;
x_restart=100;
prompt = {'Enter the last x-value pre-glutamate application to use for curve fitting                 '};
dlg_title = 'Adjust Registration              ';
num_lines = 1;
def = {num2str(x_cutoff)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
x_cutoff=str2num(answer{1,1});

fit_ch1=ch1tofit(1:x_cutoff);
fit_ch2=ch2tofit(1:x_cutoff);


prompt = {'Enter the first x-value post-glutamte application to use for curve fitting                 '};
dlg_title = 'Adjust Registration              ';
num_lines = 1;
def = {num2str(x_restart)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
x_restart=str2num(answer{1,1});

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
   %%%%%%%%%%%%%%%%%%%%%%% Adjust alignment

              %%%%%%%%%%%%%%%%%%%%%%% Adjust alignment
[ratio, ratio_raw,Aligned,VertAdjust,HorizAdjust]=realignDVimages(ch1, ch2, Ch1_Normalized, Ch2_Normalized,Aligned,parameters_present,VertAdjust,HorizAdjust);   

%% Currently Scripted Out
if 2>7  
    while (strcmp(Aligned,'No')==1)
        pad=ones(size(ch1,1),abs(VertAdjust),size(ch1,3));
        if size(pad,2)>0
        ch2test=[pad,ch2];
        ch1test=[ch1, pad];
        else
        ch2test=[ch2,pad];
        ch1test=[pad,ch1]; 
        end
        padtop=ones(abs(HorizAdjust),size(ch2test,2),100);
        if size(padtop,1)>0
        ch1test=[ch1test;padtop];
        ch2test=[padtop;ch2test];
        else
        ch1test=[padtop;ch1test];
        ch2test=[ch2test;padtop];  
        end
       
        testratio=ch1test(:,:,10)./ch2test(:,:,10);
        %testratio(outside)=0;
        oversat=find(testratio>5);
        testratio(oversat)=5;
        undersat=find(testratio<1);
        testratio(undersat)=1;
        image(testratio,'cdatamapping','scaled')
        axis image;
         Aligned=questdlg('Are you happy with the alignment','Registration Checkpoint');
            if (strcmp(Aligned,'No')==1)
                prompt = {'Enter vertical adjustment                 ','Enter Horizonatal adjustment                  '};
                dlg_title = 'Adjust Registration              ';
                num_lines = 1;
                def = {num2str(VertAdjust),num2str(HorizAdjust)};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                VertAdjust=str2num(answer{1,1});
                HorizAdjust=str2num(answer{2,1});
            end
    end
    ch1=ch1test;
    ch2=ch2test;
    close;
end
%%% End of scripted out section
        


%% Filtering Ratioed Images
[ratio]=Gaussian_Filter_streamlined(ratio, 3, 0.5);

ratio(1:size(ratio, 1),1,:)=0;
ratio(1:size(ratio, 1),size(ratio,2),:)=0;
ratio(1,1:size(ratio, 2),:)=0;
ratio(size(ratio, 1), 1:size(ratio, 2),:)=0;
ratioave=squeeze(mean(mean(ratio)));



peak_frame=0;

%%%% Pick Max peak and create an average to analyze
plot (ratioave);
prompt = {'Enter the Frame number of the peak response                 '};
dlg_title = 'Peak Frame Number              ';
num_lines = 1;
def = {num2str(peak_frame)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
peak_frame=str2num(answer{1,1});
peak_frame_image=FrameAverage(ratio,peak_frame-2,peak_frame+3);
image(peak_frame_image,'cdatamapping','scaled')
%%%% Pick onset of Glut Perfusion
plot (ratioave);
prompt = {'Enter the Frame number when Glutamate was applied                 '};
dlg_title = 'Glut Application              ';
num_lines = 1;
def = {num2str(peak_frame)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
glut_application_frame=str2num(answer{1,1});


Baseline_Frame=FrameAverage(ratio,x_cutoff-5,x_cutoff);
if 2>4
%%% Create Image for baseline adjustment
Peak_Image=peak_frame_image-Baseline_Frame;
image(Peak_Image,'cdatamapping','scaled')
axis image
colormap(RGBCustom);

%%% Baseline Normalize Ratio
end

norm_ratio=zeros(size(ratio,1),size(ratio,2),size(ratio,3));
for framenorm=1:size(ratio,3)
    norm_ratio(:,:,framenorm)=ratio(:,:,framenorm)-Baseline_Frame+squeeze(mean(mean(Baseline_Frame)));
    norm_ratio_baseline_subtracted(:,:,framenorm)=ratio(:,:,framenorm)-Baseline_Frame;
end
if 2>4
%%%% Save baseline and peak images as MAT files
peakimagefilename=sprintf('%s/PeakImage.mat',PathName);
save (peakimagefilename,'Peak_Image');
baseimagefilename=sprintf('%s/BaseImage.mat',PathName);
save (baseimagefilename,'Baseline_Frame');
end

RLAlign='No';
TBAlign='No';
RotAlign='No';
L_R_pad=0;
T_B_pad=0;
Rot=0;

%%%%  Integration of 6 peak frames
integration_value=6;
integrated_peak=zeros(size(ratio,1),size(ratio,2));
for integration_number=1:integration_value;
peak_frame_image_t=ratio(:,:,peak_frame+(integration_number-1))-Baseline_Frame;
integrated_peak=integrated_peak+peak_frame_image_t;
end
integrated_glut_application=zeros(size(ratio,1),size(ratio,2));
for integration_number=1:integration_value;
onset_frame_image_t=ratio(:,:,glut_application_frame+(integration_number-1))-Baseline_Frame;
integrated_glut_application=integrated_glut_application+onset_frame_image_t;
end


while (strcmp(RotAlign,'No')==1)


if (strcmp(RotAlign,'No')==1)
    prompt = {'Enter the degrees of Rotation                 '};
    dlg_title = 'Rotate Rotons             ';
    num_lines = 1;
    def = {num2str(Rot)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    Rot=str2num(answer{1,1});
    
    Peak_Rot_Tx=imrotate(integrated_peak,Rot,'bilinear');
    image(Peak_Rot_Tx,'cdatamapping','scaled')
    colormap jet
    axis image;
    
    RotAlign=questdlg('Are you happy with the Rotational alignment','Registration Checkpoint');
end

end
     
integrated_peak_rot=imrotate(integrated_peak,Rot,'bilinear');  


integrated_glut_application_rot=imrotate(integrated_glut_application,Rot,'bilinear');





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Beginning of New Analysis Method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NewPath=sprintf('%sNew_analysis_6_30_2009/',PathName);
NewPath=sprintf('%sNew_analysis_8_1_2009/',PathName);
mkdir(NewPath);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Detection of Peak Perfusion Response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
number_of_thresholds=5;   % For area and peak analysis
test_mean=mean(mean(integrated_peak)); % Parameter for peak analysis
test_std=std(mean(integrated_peak)); % Parameter for peak analysis

%%%%%  Mask the FL
testimage=integrated_peak_rot; 
tt=find(testimage >4);
testimage(tt)=3;
image(testimage,'cdatamapping','scaled')
axis image
Happiness=questdlg('Draw the mask of FL','GOULET INC');
mask=roipoly;
FL_site=find(mask==1);
FL_image=zeros(size(integrated_peak_rot,1),size(integrated_peak_rot,2));
FL_image(FL_site)=1;


ROIs_out=zeros(size(norm_ratio,3),number_of_thresholds+1);
Areas_out=zeros(size(norm_ratio,3),number_of_thresholds+1);
ROIs_out_Baseline_Subtracted=zeros(size(norm_ratio,3),number_of_thresholds+1);
ROI_logicals=zeros(number_of_thresholds,size(integrated_peak,1),size(integrated_peak,2));
for threshold_number=1:number_of_thresholds
    peak_location=find(integrated_peak_rot<test_mean-(0.75*threshold_number*test_std)); % Defines the region that will be used for peak analysis
    %peak_val=-.1+threshold_number*-0.1; % Delta Fret Cutoff for area analysis for 5 mM Glut application]
    peak_val=threshold_number*-0.05; % Delta Fret Cutoff for area analysis for 1 mM Glut application
    for frame=1:size(norm_ratio,3)
        if threshold_number==1
            ROIs_out(frame,1)=frame;  % Filling in the frame numbers for each both area and peak analysis
            Areas_out(frame,1)=frame;
        end
        thisframe=norm_ratio(:,:,frame); % Grabbing each frame for analysis
        thisframe_Baseline_Subtracted=norm_ratio_baseline_subtracted(:,:,frame);
        ROIs_out(frame,threshold_number+1)=mean(thisframe(peak_location));
        Areas_out(frame,threshold_number+1)=size(find(thisframe_Baseline_Subtracted<peak_val),1);
        ROIs_out_Baseline_Subtracted(frame,threshold_number+1)=mean(thisframe_Baseline_Subtracted(peak_location));
    end
    roidraw=zeros(size(integrated_peak_rot,1),size(integrated_peak_rot,2));
    roidraw_FRET=zeros(size(integrated_peak_rot,1),size(integrated_peak_rot,2));
    roidraw(peak_location)=1;
    roidraw_FRET(peak_location)=integrated_peak_rot(peak_location);
    ROI_logicals(threshold_number,:,:)=roidraw;
    FRET_logicals(threshold_number,:,:)=roidraw_FRET;
    clear roidraw;
    test_image=integrated_peak_rot;
    test_image(peak_location)=0;
    
    image(test_image,'cdatamapping','scaled')
    axis image
    ROI_Picture_Filename=sprintf('%sROI_Map_threshold_%d.jpg',NewPath, threshold_number);  
    saveas(gcf, ROI_Picture_Filename);
    ta=1;
end

ROI_Data_out=sprintf('%sROI_outs.txt',NewPath); 
save(ROI_Data_out,'ROIs_out','-ascii','-tabs');

ROI_Data_out_baseline_subtraced=sprintf('%sROI_outs_baseline_subtracted.txt',NewPath); 
save(ROI_Data_out_baseline_subtraced,'ROIs_out_Baseline_Subtracted','-ascii','-tabs');

Areas_Data_out=sprintf('%sArea_outs.txt',NewPath); 
save(Areas_Data_out,'Areas_out','-ascii','-tabs');

ROI_Logs_out=sprintf('%sROI_Logicals_%s_%s',NewPath, directoryname(size(directoryname,2)-9:size(directoryname,2)), dddir(this_slice,size(dddir,2):size(dddir,2))); 
save(ROI_Logs_out,'ROI_logicals');

FL_Logs_out=sprintf('%sFL_Logical_%s_%s',NewPath, directoryname(size(directoryname,2)-9:size(directoryname,2)), dddir(this_slice,size(dddir,2):size(dddir,2))); 
save(FL_Logs_out,'FL_image');

FL_FRET_out=sprintf('%sFRET_Logical_%s_%s',NewPath, directoryname(size(directoryname,2)-9:size(directoryname,2)), dddir(this_slice,size(dddir,2):size(dddir,2))); 
save(FL_FRET_out,'FRET_logicals');

Integrated_Data_out=sprintf('%sIntegrated_map',NewPath); 
save(Integrated_Data_out,'integrated_peak_rot');

Norm_Data_out=sprintf('%sNormalized Data',NewPath); 
save(Norm_Data_out,'norm_ratio');

integrated_onset_out=sprintf('%sIntegrated_onset_%s_%s',NewPath, directoryname(size(directoryname,2)-9:size(directoryname,2)), dddir(this_slice,size(dddir,2):size(dddir,2))); 
save(integrated_onset_out,'integrated_glut_application_rot');


end