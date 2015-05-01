clear all;
clipfactor=20;
GaussianValue=0.5;                                 % Value of Gaussian blur parameter
MatrixSize=3;                                      % Value of Gaussian blur parameter
Erosion_Factor=1;  
[FileName,PathName] = uigetfile({'*.sif','All Image Files';...
    '*.*','All Files' },'mytitle',...
    'C:\Documents and Settings\Chris\Desktop\Andor Data\2009_05_21');
%ImageFileName=sprintf('%s%s',PathName,FileName);
[Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(sprintf('%s%s',PathName,FileName));
temp=Image.data;
exposuretime=InstaImage.exposure_time;
ch1=temp(1:size(temp,1)/2,:,:);
ch2=temp(size(temp,1)/2+1:size(temp,1),:,:);
liveave=squeeze(mean(mean(ch1(size(ch1,1)/4:3*size(ch1,1)/4,size(ch1,2)/4:3*size(ch1,2)/4,:))));
dliveave=diff(liveave);

%%  Get Shutter Open and close frames
[trash, illumination_start]=max(dliveave);
[trash, illumination_end]=min(dliveave);
illumination_start=illumination_start+clipfactor;
illumination_end=illumination_end-clipfactor;

%% Clip Dark Frames from front and end of Fluorescence exposure
darkframe=FrameAverage(temp,1,illumination_start-10);
Fluorescence_dark_clipped=(temp(:,:,illumination_start:illumination_end));
%%  Calculate Frame Times
%%% Compute times off of standard exp+delay time
for isd=1:Image.no_images
    estimated_time(isd)=(isd-1)*InstaImage.kinetic_cycle_time;
end
estimated_time_clipped=estimated_time(1,illumination_start:illumination_end);
%%  Subtract Darkfield from Fluorescent images
subframe=zeros(size(Fluorescence_dark_clipped,1),size(Fluorescence_dark_clipped,2),size(Fluorescence_dark_clipped,3));

for ii=1:size(Fluorescence_dark_clipped, 3)
    tframe=Fluorescence_dark_clipped(:,:,ii);
    subframe(:,:,ii)=tframe-darkframe;
end

%%  Split Channels
Ch1=subframe(1:size(subframe,1)/2,:,:);
Ch2=subframe(size(subframe,1)/2+1:size(subframe,1),:,:);

%%Curve Fitting
ch1tofit=squeeze(mean(mean(Ch1)));
ch2tofit=squeeze(mean(mean(Ch2)));

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

fit_ch1=[fit_ch1;ch1tofit(x_restart:size(ch1tofit,1))];
fit_ch2=[fit_ch2;ch2tofit(x_restart:size(ch1tofit,1))];
close
for hh=1:size(ch1tofit,1)
    time(hh)=hh;
end
fit_time=[time(1:x_cutoff),time(x_restart:size(ch1tofit,1))];
if x_restart==size(ch1tofit,3)
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
for hh=1:size(ch1tofit,1)
    Ch1_fit_results(hh)=coeffvalues1(1)*exp(coeffvalues1(2)*hh)+coeffvalues1(3)*exp(coeffvalues1(4)*hh);
    Ch2_fit_results(hh)=coeffvalues2(1)*exp(coeffvalues2(2)*hh)+coeffvalues2(3)*exp(coeffvalues2(4)*hh);
end

ch1sub=ch1tofit-Ch1_fit_results';
ch2sub=ch2tofit-Ch2_fit_results';
ch1sub=ch1sub+ch1tofit(1,1);
ch2sub=ch2sub+ch2tofit(1,1);
ratiosub=ch1sub./ch2sub;

ch1start=Ch1(:,:,1);
ch2start=Ch2(:,:,1);

ch1end=Ch1(:,:,size(Ch1,3));
ch2end=Ch2(:,:,size(Ch1,3));


%%% Subtractive normalization based on curve fit
ch1fitmax=max(Ch1_fit_results);
ch2fitmax=max(Ch2_fit_results);
ch1fitmin=min(Ch1_fit_results);
ch2fitmin=min(Ch2_fit_results);
ch1diff=ch1fitmax-ch1fitmin;
ch2diff=ch2fitmax-ch2fitmin;
Ch1_Normalized=zeros(size(Ch1,1),size(Ch1,2),size(Ch1,3));
Ch2_Normalized=zeros(size(Ch1,1),size(Ch1,2),size(Ch1,3));
   for i=1:size(Ch1,3)
       
            ThisFrame1=Ch1(:,:,i);
            ThisFrame2=Ch2(:,:,i);
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
 
%%  Create the ratio
 ratio=Ch1_Normalized./Ch2_Normalized;
  disp ('Ratio Completed');



%%  Normalize Images
normsingle=FrameAverage(ratio, 2,10);
basenorm=mean(mean(normsingle));
normframe=zeros(size(ratio,1),size(ratio,2),size(ratio,3));
for gg=1:size(ratio, 3)
    tframe=ratio(:,:,gg);
    normframetemp=tframe-normsingle;
    normframetemp=normframetemp+basenorm;
    normframe(:,:,gg)=normframetemp;
end
[SummedFrame]=SumFrames(normframe, 1, size(normframe, 3));
figure(2)
[Ratio]=Gaussian_Filter_streamlined(normframe, MatrixSize, GaussianValue);
[Ratio]=Gaussian_Filter_streamlined(Ratio, MatrixSize, GaussianValue);
gross_ratio=squeeze(mean(mean(Ratio)));
plot(estimated_time_clipped,gross_ratio)
implay(Ratio);
