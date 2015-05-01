%%%%%%%%  Analyzing Andor Slow Calibration Files %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Use this program to open, draw roi's and compute ratio/time
%  courses for slow (1 image every 10 secs) local perfursion
% calibration files with darkfield subtraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%keep ratiotracker;
clear all;

[RGBCustom]=CreateRGBColorTableInverted;


%%%%%%%%%%%% Open Andor File
path1dir=questdlg('Please Select your local perfusion Andor File','GOULET INC');

ddir = dir (path1dir);
numfilesdir=length(ddir)-2;
if numfilesdir<1
    disp('No files found');
end

for i = 1:numfilesdir
    t = length(getfield(ddir,{i+2},'name')) ;
    dddir(i, 1:t) = getfield(ddir,{i+2},'name') ;
end


%%%% NOT SURE WHAT THE FUCK IS UP RIGHT HERE

or number_of_slices=1:numslices
    PathName=sprintf('%s/%s/',directoryname,dddir(number_of_slices,:));
    glutfile=sprintf('%s/%s/*Glut*',directoryname,dddir(number_of_slices,:));
    dadir = dir (glutfile);
    numfiles=length(dadir);
    if numfiles<1
        disp('No files found');
    end
    clear daddir;
    clear dd2;
    clear d2;
    for i = 1:numfiles
        t = length(getfield(dadir,{i},'name')) ;
        daddir(i, 1:t) = getfield(dadir,{i},'name') ;
    end
    %%%  Look for a Parameter file
    path2=sprintf('%s/%s/*aram*',directoryname,dddir(number_of_slices,:));
    d2 = dir (path2);
    numfiles2=length(d2);
    if numfiles2<1
        disp('No files found');
        paramfound=0;
    else
        paramfound=1;
    end
    
    if paramfound==1
        clear dd2;
        for i = 1:numfiles2
            t = length(getfield(d2,{i},'name')) ;
            dd2(i, 1:t) = getfield(d2,{i},'name') ;
        end
        params_in=open(sprintf('%s/%s/%s',directoryname,dddir(number_of_slices,:),dd2(1,:)));
        Outside_Mask=params_in.params.mask;
        Rot=params_in.params.rot;
        stim_loc_data=params_in.params.stim_loc;
    end
        
    fn=sprintf('%s/%s/%s',directoryname,dddir(number_of_slices,:),daddir(number_of_slices,:));



%%%%%%%%%%%%%%%%%%%
[Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(fn)
temp=Image.data;
exposuretime=InstaImage.exposure_time;
%%%%%%%%%%%% Open Darkfield file
ext='ark';
path1=sprintf('%s/*%s*',PathName,ext);
disp(PathName);
d = dir (path1);
numfiles=length(d);
directoryname=path;
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end
for thisfile = 1:numfiles
 %try/mnt/m022a
    
  fna=dd(thisfile,:);
 
  fna=strtok(fna,'.');
  %fna=fna(1:length(fna)-4);
disp(fna);
%fna='eeg3';
fn= sprintf('%s%s.sif',PathName,fna);
end

[DarkImage,DarkInstaImage,DarkCalibImage,Darkvers]=andorread_chris_local_knownfilename(fn)

dark=DarkImage.data;
dark_Image=FrameAverage(dark,1,size(dark,3)-1);
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
if 2>1
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

        



if 2>1

end
ratio=Ch1_Normalized./Ch2_Normalized;
ratioave=squeeze(mean(mean(ratio)));



peak_frame=0;
%%%%%  Mask the cortex
testimage=ratio(:,:,20);
tt=find(testimage >4);
testimage(tt)=3;
image(testimage,'cdatamapping','scaled')
axis image
Happiness=questdlg('Draw the mask of cortex','GOULET INC');
mask=roipoly;
inside=find(mask==1);
outside=find(mask==0);
close
for i=1:size(ratio, 3)
    tframe=ratio(:,:,i);
    tframe(outside)=0;
    ratio(:,:,i)=tframe;
end

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





%%% Create Image for baseline adjustment
Baseline_Frame=FrameAverage(ratio,x_cutoff-5,x_cutoff);
Baseline_Frame(outside)=0;
Peak_Image=peak_frame_image-Baseline_Frame;
image(Peak_Image,'cdatamapping','scaled')
axis image
colormap(RGBCustom);

%%% Baseline Normalize Ratio

norm_ratio=zeros(size(ratio,1),size(ratio,2),size(ratio,3));
for framenorm=1:size(ratio,3)
    norm_ratio(:,:,framenorm)=ratio(:,:,framenorm)-Baseline_Frame;
end

%%%% Save baseline and peak images as MAT files
peakimagefilename=sprintf('%s/PeakImage.mat',PathName);
save (peakimagefilename,'Peak_Image');
baseimagefilename=sprintf('%s/BaseImage.mat',PathName);
save (baseimagefilename,'Baseline_Frame');


RLAlign='No';
TBAlign='No';
RotAlign='No';
L_R_pad=0;
T_B_pad=0;
Rot=0;

%%% ROI and Spatial analysi
this_image_file=Peak_Image;
base_image_file=Baseline_Frame;

if 2>1
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
 Peak_Rot_Tx_B=imrotate(base_image_file,Rot,'bilinear');       



%%%%  Spatial compression analysis
image(Peak_Rot_Tx,'cdatamapping','scaled')
axis image
colormap jet
Happiness=questdlg('Draw the area to use for Spatial Compression Analysi','GOULET INC');
rt=imrect
p=getPosition(rt)
clippedi=Peak_Rot_Tx(round(p(2)):round(p(2))+round(p(4)),round(p(1)):round(p(1))+round(p(3)));
clippedb=Peak_Rot_Tx_B(round(p(2)):round(p(2))+round(p(4)),round(p(1)):round(p(1))+round(p(3)));
image(clippedi,'cdatamapping','scaled')
axis image
colormap jet

fl_prof(:,1)=mean(clippedi);
fl_prof(:,2)=mean(clippedb);

%%%%  Integration of 6 peak frames
integration_value=6;
integrated_peak=zeros(size(ratio,1),size(ratio,2));
for integration_number=1:integration_value;
peak_frame_image_t=ratio(:,:,peak_frame+(integration_number-1))-Baseline_Frame;
integrated_peak=integrated_peak+peak_frame_image_t;
end
integrated_peak_rot=imrotate(integrated_peak,Rot,'bilinear');  
clippedint=integrated_peak_rot(round(p(2)):round(p(2))+round(p(4)),round(p(1)):round(p(1))+round(p(3)));
fl_prof(:,3)=mean(clippedint);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Beginning of New Analysis Method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NewPath=sprintf('%sNew_analysis_4_2009/',PathName);
mkdir(NewPath);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Detection of Peak Perfusion Response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
number_of_thresholds=5;
test_mean=mean(mean(integrated_peak));
test_std=std(mean(integrated_peak));

ROIs_out=zeros(size(norm_ratio,3),number_of_thresholds+1);

for threshold_number=1:number_of_thresholds
    
    peak_location=find(integrated_peak<test_mean-(0.75*threshold_number*test_std));
    peak_val=integrated_peak<test_mean-(0.75*threshold_number*test_std);
    for frame=1:size(norm_ratio,3)
        if threshold_number==1
            ROIs_out(frame,1)=frame;
          
        end
        
        thisframe=norm_ratio(:,:,frame);
        ROIs_out(frame,threshold_number+1)=mean(thisframe(peak_location));
      
    end
    test_image=integrated_peak;
    test_image(peak_location)=0;
    
    image(test_image,'cdatamapping','scaled')
    
    ROI_Picture_Filename=sprintf('%sROI_Map_threshold_%d.jpg',NewPath, threshold_number);  
    saveas(gcf, ROI_Picture_Filename);
end

ROI_Data_out=sprintf('%sROI_outs.txt',NewPath); 
save(ROI_Data_out,'ROIs_out','-ascii','-tabs');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Freeze Lesion Physical Profiling in Time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Old Analysis method

if 3<1
%%%% Creating a transformation parameter files
if 2>1
roipoints=[round(p(1)) round(p(2)) round(p(3)) round(p(4)) Rot];



image(Peak_Image,'cdatamapping','scaled')
axis image
colormap(RGBCustom);
end

%%%%  Multiple ROI analysis - 
%%%%  3 FLs - left, right, and bottom
%%%%  5 non-FL ROIs - 1 selected - 4 automated 
if 2>1
Happiness=questdlg('Trace the Lateral PMZ','GOULET INC');
Lat_pmz=impoly;
Lat_pmz_roi=Lat_pmz.createMask;
Happiness=questdlg('Trace the Medial PMZ','GOULET INC');
Med_pmz=impoly;
Med_pmz_roi=Med_pmz.createMask;
Happiness=questdlg('Trace the bottom PMZ','GOULET INC');
bottom_pmz=impoly;
bottom_pmz_roi=bottom_pmz.createMask;
bottom_coords=getPosition(bottom_pmz);
coords_size=size(bottom_coords,1);



FL_ROI_Check='No';
while (strcmp(FL_ROI_Check,'No')==1)

if (strcmp(FL_ROI_Check,'No')==1)
 Happiness=questdlg('Click 5 points outside the PMZ','GOULET INC');
 RoiPoint1=impoint;
 RoiPoint2=impoint;
 RoiPoint3=impoint;
 RoiPoint4=impoint;
 RoiPoint5=impoint;
 
 pt1_coords=getPosition(RoiPoint1);
 pt2_coords=getPosition(RoiPoint2);
 pt3_coords=getPosition(RoiPoint3);
 pt4_coords=getPosition(RoiPoint4);
 pt5_coords=getPosition(RoiPoint5);
 
 for filling=1:coords_size
    bottom_coords_adjust(filling,:)=bottom_coords(filling,:)-bottom_coords(1,:); 
    pt1_coords(filling,:)=pt1_coords(1,:);
    pt2_coords(filling,:)=pt2_coords(1,:);
    pt3_coords(filling,:)=pt3_coords(1,:);
    pt4_coords(filling,:)=pt4_coords(1,:);
    pt5_coords(filling,:)=pt5_coords(1,:);
 end
 
 roicreated1=bottom_coords_adjust+pt1_coords;
 roicreated2=bottom_coords_adjust+pt2_coords;
 roicreated3=bottom_coords_adjust+pt3_coords;
 roicreated4=bottom_coords_adjust+pt4_coords;
 roicreated5=bottom_coords_adjust+pt5_coords;
 
 out_roi_1=poly2mask(roicreated1(:,1),roicreated1(:,2),size(Peak_Image,1),size(Peak_Image,2));
 out_roi_2=poly2mask(roicreated2(:,1),roicreated2(:,2),size(Peak_Image,1),size(Peak_Image,2));
 out_roi_3=poly2mask(roicreated3(:,1),roicreated3(:,2),size(Peak_Image,1),size(Peak_Image,2));
 out_roi_4=poly2mask(roicreated4(:,1),roicreated4(:,2),size(Peak_Image,1),size(Peak_Image,2));
 out_roi_5=poly2mask(roicreated5(:,1),roicreated5(:,2),size(Peak_Image,1),size(Peak_Image,2));
 
 testimage=Peak_Image;
 testimage(out_roi_1)=.05;
 testimage(out_roi_2)=.1;
 testimage(out_roi_3)=.15;
 testimage(out_roi_4)=.2;
 testimage(out_roi_5)=.25;
 if 2>1
 testimage(Lat_pmz_roi)=.3;
 testimage(Med_pmz_roi)=.35;
 testimage(bottom_pmz_roi)=.4;
 else
 testimage(Max_pmz_roi)=.3;  
 end
 
 
 ihand=image(testimage,'cdatamapping','scaled')
 FL_ROI_Check=questdlg('Are you happy with the Rois alignment','Registration Checkpoint');
 
end

end
if 2>1
ROI_Picture_Filename=sprintf('%sROI_Map.jpg',PathName);
else
ROI_Picture_Filename=sprintf('%sROI_Map_final.jpg',PathName);  
end
saveas(gcf, ROI_Picture_Filename);
close

for i=1:size(ratio,3)
    tempimage=ratio(:,:,i);
    if 2>1
    Lateral_FL(i)=mean(tempimage(Lat_pmz_roi));
    Medial_FL(i)=mean(tempimage(Med_pmz_roi));
    Bottom_FL(i)=mean(tempimage(bottom_pmz_roi));
    else
    MaxPMZ(i)=mean(tempimage(Max_pmz_roi));  
    end
    Out_1(i)=mean(tempimage(out_roi_1));
    Out_2(i)=mean(tempimage(out_roi_2));
    Out_3(i)=mean(tempimage(out_roi_3));
    Out_4(i)=mean(tempimage(out_roi_4));
    Out_5(i)=mean(tempimage(out_roi_5));
    
end
if 2>1
out_roi_ts=[Lateral_FL; Medial_FL; Bottom_FL; Out_1; Out_2; Out_3; Out_4; Out_5];
roi_logicals={mask, Lat_pmz_roi, Med_pmz_roi,bottom_pmz_roi, out_roi_1, out_roi_2, out_roi_3, out_roi_4, out_roi_5};
else
out_roi_ts=[MaxPMZ; Out_1; Out_2; Out_3; Out_4; Out_5];
roi_logicals={mask, Max_pmz_roi, out_roi_1, out_roi_2, out_roi_3, out_roi_4, out_roi_5};
end
end
parameter_file=[x_cutoff,x_restart,peak_frame];
%%%% Saving spatial analysis images in MAT format
fname=sprintf('%s/%s_%s_FL_profile_clipped.mat',PathName, PathName(12:21), PathName((size(PathName,2)-2):(size(PathName,2)-1)));
bname=sprintf('%s/%s_%s_FL_profile_clipped_baseline.mat',PathName, PathName(12:21), PathName((size(PathName,2)-2):(size(PathName,2)-1)));
if 2>1
roiname=sprintf('%s/%s_%s_ROI_Points_spatial_compression.mat',PathName, PathName(12:21), PathName((size(PathName,2)-2):(size(PathName,2)-1)));
roits=sprintf('%s/%s_%s_ROI_Points_time_series.mat',PathName, PathName(12:21), PathName((size(PathName,2)-2):(size(PathName,2)-1)));
rois=sprintf('%s/%s_%s_ROI_Logicals.mat',PathName, PathName(12:21), PathName((size(PathName,2)-2):(size(PathName,2)-1)));
end

params=sprintf('%s/%s_%s_Parameter_File',PathName, PathName(12:21), PathName((size(PathName,2)-2):(size(PathName,2)-1)));

%%%%  Saving output files


if 2>1
save (roiname,'roipoints');
save (fname,'clippedi');
save (bname,'clippedb');
save (roits,'out_roi_ts');
save (rois,'roi_logicals');
save (params,'parameter_file');
text_f=sprintf('%s/%s_%s_FL_profile.txt',PathName, PathName(12:21), PathName((size(PathName,2)-2):(size(PathName,2)-1)));
save (text_f, 'fl_prof', '-ascii','-tabs');
text_r=sprintf('%s/%s_%s_ROI_Points_time_series.txt',PathName, PathName(12:21), PathName((size(PathName,2)-2):(size(PathName,2)-1)));
save (text_r, 'out_roi_ts', '-ascii','-tabs');
else
text_f=sprintf('%s/%s_%s_FL_profile.txt',PathName, PathName(12:21), PathName((size(PathName,2)-2):(size(PathName,2)-1)));
save (text_f, 'fl_prof', '-ascii','-tabs');

end
end