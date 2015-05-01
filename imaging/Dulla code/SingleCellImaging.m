%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Single Cell Glutamate Imaging                     %%%%%%
%%%%  Compiles multiple SIF files and averages them     %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
shutterbuffersize=10;           %%% the number of frames to clip beyond/befor shutter open/close
startfit=130;
endfit=600;
[RGBCustom]=CreateRGBColorTableInverted;

%%%% Choose a folder with multple images from 1 cell
directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
path1dir=sprintf('%s/*Untit*',directoryname);
ddir = dir (path1dir);                                                   
numfiles=length(ddir);
if numfiles<1
    disp('No files found');
end

%%%%  Create a variable with all the folder names
for i = 1:numfiles
    t = length(getfield(ddir,{i},'name')) ;
    filelist(i, 1:t) = getfield(ddir,{i},'name') ;                      %%%% filelist contains the list of sif files
end

for this_image=1:numfiles
clear fn;   
fn=sprintf('%s/%s',directoryname,filelist(this_image,:));
[Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(fn)
temp=Image.data;
exposuretime=InstaImage.exposure_time;   

%%% Detect shutter times
shutterdetect=squeeze(diff(mean(mean(temp))));
[shutteropen openindex(this_image)]=max(shutterdetect);
[shutterclose closeindex(this_image)]=min(shutterdetect);

%%% Clip dark data and check frame number is idenditcal between images
number_of_frames(this_image)=closeindex(this_image)-openindex(this_image);
data=temp(:,:,openindex(this_image)+shutterbuffersize:closeindex(this_image)-shutterbuffersize);

%%% Subtract darkframe
darkframe=FrameAverage(temp,1,openindex(this_image)-shutterbuffersize);
temp_darksubtracted=zeros(size(temp,1),size(temp,2),size(data,3));
for i=1:size(data,3)
td=data(:,:,i);
temp_darksubtracted(:,:,i)=td-darkframe;            %%temp_darksubtracted has the data now
end

%%%%% Breaking up Ch1 and Ch2
Aligned='No';
VertAdjust=0;
HorizAdjust=0;
ch1=temp_darksubtracted(1:64,:,:);
ch2=temp_darksubtracted(65:128,:,:);

%%%% Curvefitting each channel
ch1tofit=squeeze(mean(mean(ch1)));
ch2tofit=squeeze(mean(mean(ch2)));
fit_ch1=ch1tofit(1:startfit);
fit_ch2=ch2tofit(1:startfit);
fit_ch1=[fit_ch1;ch1tofit(endfit:size(ch1,3))];
fit_ch2=[fit_ch2;ch2tofit(endfit:size(ch1,3))];

for hh=1:size(ch1,3)
    time(hh)=hh;
end
fit_time=[time(1:startfit),time(endfit:size(ch1,3))]; 
fit_ch1=double(fit_ch1);
fit_ch2=double(fit_ch2);
fit_time=fit_time';

[coeffvalues1, coeffvalues2]=DualChannelCurveFitting(fit_ch1, fit_ch2, fit_time);
[Ch1_norm, ch1fitresults]=FrameNormalization_rising_signal(ch1, coeffvalues1);    
[Ch2_norm, ch2fitresults]=FrameNormalization_rising_signal(ch2, coeffvalues2);
ratio=Ch1_norm./Ch2_norm;
ratio_raw=ch1./ch2;
%%% Filtering Ratioed Images
[ratio]=Gaussian_Filter_streamlined(ratio, 3, 0.5);
if this_image==1
group_ratio=zeros(size(ratio,1), size(ratio,2), size(ratio,3));
end
group_ratio=group_ratio+ratio;
ind_ratios(:,this_image)=squeeze(mean(mean(ratio)));
ind_ratios_raw(:,this_image)=squeeze(mean(mean(ratio_raw)));
ind_ch1(:,this_image)=ch1tofit;
ind_ch2(:,this_image)=ch2tofit;
end
means=mean(ind_ratios(1:100,:));
means_r=mean(ind_ratios_raw(1:100,:));
for i=1:numfiles
bls_ratio(:,i)=ind_ratios(:,i)-means(i);
bls_ratio_raw(:,i)=ind_ratios_raw(:,i)-means_r(i);
end
Averaged_movie=group_ratio/numfiles;
integratedout=zeros(size(ratio,1),size(ratio,2));
baselineimage=FrameAverage(Averaged_movie,143,173);
for i=1:60
integrated=Averaged_movie(:,:,i+173)-baselineimage;
integratedout=integratedout+integrated;
end