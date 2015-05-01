%%%%  Calcium Mouse Imaging - Multiple ROI analyis no movies
%%%%  
clear all
ScaleFactor=10;
L_R_OffsetFactor=-350;
U_D_OffsetFactor=0;
VertAdjust=0;
HorizAdjust=0;

%%%%%%%%%%%% Open Andor File
Happiness=questdlg('Please Select your Calcium Imaging Andor File','GOULET INC');
[Image,InstaImage,CalibImage,vers,PathName,FileName]=andorread_chris_local();
temp=Image.data;
exposuretime=InstaImage.exposure_time;
%%%% Detect Shutter Opening and Closing
shutter_scan=squeeze(mean(mean(temp)));
shutter_deriv=diff(shutter_scan);
[waste, shutter_open_frame]=max(shutter_deriv);
[waste, shutter_close_frame]=min(shutter_deriv);
dark=FrameAverage(temp,2,shutter_open_frame-2);

%%%%%%%%%%  Darkfield subtraction
for i=1:size(temp,3)
    tempframe=temp(:,:,i);
    tempframe=tempframe-dark;
    temp(:,:,i)=tempframe;

end

%%%%%%%%%%%% Open Parameter file
ext='RoiParam';
path1=sprintf('%s/*%s*',PathName,ext);
disp(PathName);
d = dir (path1);
numfiles=length(d);
directoryname=path;
if numfiles<1
    disp('No files found');
    parameters_present=0;
else


for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end
pmfn=sprintf('%s%s',PathName,d.name);
Parameters_in=open(pmfn);
parameters_present=1;

Roi_test_mask=Parameters_in.parameters{1};
Roi_test_mask2=Parameters_in.parameters{2};
end



%%%%% Breaking up Ch1 and Ch2
ch1=temp(1:64,:,shutter_open_frame+4:shutter_close_frame-3);
ch2=temp(65:128,:,shutter_open_frame+4:shutter_close_frame-3);
ch1tofit=squeeze(mean(mean(ch1)));
ch2tofit=squeeze(mean(mean(ch2)));
Aligned='No';


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

if 2<1
%%% Biexponential Fit
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
end

%%%% End Biexponential Fit

%%%% 4th Degree Polynomial Fit
% --- Create fit "fit 2"
ok_ = isfinite(fit_time) & isfinite(fit_ch1);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
ft_ = fittype('poly3');
% Fit this model using new data
cf_ = fit(fit_time(ok_),fit_ch1(ok_),ft_);
% Or use coefficients from the original fit:
if 0
   cv_ = { 2.3144090326105146956e-10, 3.1104183683390897728e-06, -0.0016362342370089329614, 0.40081345298555087764, 515.72380652729395933};
   cf_ = cfit(ft_,cv_{:});
end

% Fit this model using new data
% --- Create fit "fit 2"
ok2_ = isfinite(fit_time) & isfinite(fit_ch2);
if ~all( ok2_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
ft2_ = fittype('poly3');
cf2_ = fit(fit_time(ok2_),fit_ch2(ok2_),ft2_);
% Or use coefficients from the original fit:
if 0
   cv_2 = { 2.3144090326105146956e-10, 3.1104183683390897728e-06, -0.0016362342370089329614, 0.40081345298555087764, 515.72380652729395933};
   cf2_ = cfit(ft2_,cv_2{:});
end
%%%%%%%%%%%  Curve fit subtraction
coeffvalues1=coeffvalues(cf_);
coeffvalues2=coeffvalues(cf2_);
for hh=1:size(ch1,3)
    Ch1_fit_results(hh)=coeffvalues1(1)*hh^3+coeffvalues1(2)*hh^2+coeffvalues1(3)*hh+coeffvalues1(4);
    Ch2_fit_results(hh)=coeffvalues2(1)*hh^3+coeffvalues2(2)*hh^2+coeffvalues2(3)*hh+coeffvalues2(4);
end 

%%%%%  End 4th Degree Polynomial Fit





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
           
            TimeRelativeToStart=(size(ch1,3)-i+1)/size(ch1,3);
            TimeRelativeToEnd=1-TimeRelativeToStart;
            tempFrame1=ch1start*TimeRelativeToStart+ch1end*TimeRelativeToEnd;
            tempFrame2=ch2start*TimeRelativeToStart+ch2end*TimeRelativeToEnd;
             
            %TimeRelativeToStart1=(Ch1_fit_results(i)-ch1fitmin)/ch1diff;
            %TimeRelativeToStart2=(Ch2_fit_results(i)-ch2fitmin)/ch2diff;
            %TimeRelativeToEnd1=1-TimeRelativeToStart1;
            %TimeRelativeToEnd2=1-TimeRelativeToStart2;
            %tempFrame1=ch1start*TimeRelativeToStart1+ch1end*TimeRelativeToEnd1;
            %tempFrame2=ch2start*TimeRelativeToStart2+ch2end*TimeRelativeToEnd2;
            
            NormFrame1=ThisFrame1-tempFrame1+mean(mean(mean(ch1start(size(ch1,1)/4:3*size(ch1,1)/4,size(ch1,2)/8:7*size(ch1,2)/8))));
            NormFrame2=ThisFrame2-tempFrame2+mean(mean(mean(ch2start(size(ch1,1)/4:3*size(ch1,1)/4,size(ch1,2)/8:7*size(ch1,2)/8))));
            Ch1_Normalized(:,:,i)=NormFrame1;
            Ch2_Normalized(:,:,i)=NormFrame2;
   end
   %%%%%%%%%%%%%%%%%%%%%%% Adjust alignment
pause=1;
    while (strcmp(Aligned,'No')==1)
        pad=ones(size(ch1,1),abs(VertAdjust),size(ch1,3));
        if VertAdjust>0
        ch2test=[pad,ch2];
        ch1test=[ch1, pad];
        ch2test_n=[pad,Ch2_Normalized];
        ch1test_n=[Ch1_Normalized, pad];
        else
        ch2test=[ch2,pad];
        ch1test=[pad,ch1]; 
        ch2test_n=[Ch2_Normalized,pad];
        ch1test_n=[pad,Ch1_Normalized]; 
        
        end
        padtop=ones(abs(HorizAdjust),size(ch2test,2),size(ch1,3));
        if HorizAdjust>0
        ch1test=[ch1test;padtop];
        ch2test=[padtop;ch2test];
        ch1test_n=[ch1test_n;padtop];
        ch2test_n=[padtop;ch2test_n];
        
        else
        ch1test=[padtop;ch1test];
        ch2test=[ch2test;padtop];  
        ch1test_n=[padtop;ch1test_n];
        ch2test_n=[ch2test_n;padtop]; 
        end
       
        testratio=ch1test(:,:,10)./ch2test(:,:,10);
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
       
    
    close;

ch1=ch1test;
    ch2=ch2test;
    Ch1_Normalized=ch1test_n;
    Ch2_Normalized=ch2test_n;
end
ratio_raw=ch1./ch2;
ratio=Ch1_Normalized./Ch2_Normalized;
ratioave=squeeze(mean(mean(ratio)));
close;
over=find(ratio>6);
ratio(over)=6;
under=find(ratio<3);
ratio(under)=3;

over_R=find(ratio_raw>6);
ratio_raw(over_R)=6;
under_raw=find(ratio_raw<3);
ratio_raw(under_raw)=3;
image(ratio_raw(:,:,100),'cdatamapping','scaled');


if (parameters_present==0)
Happiness=questdlg('Trace ROI 1','GOULET INC');
Roi_test=roipoly;
end


if (parameters_present==0)
Happiness=questdlg('Trace ROI 2','GOULET INC');
Roi_test2=roipoly;
end
if (parameters_present==0)
Happiness=questdlg('Trace ROI 3','GOULET INC');
Roi_test3=roipoly;
end

for i=1:size(ratio,3)
    tempimage=ratio(:,:,i);
    Roi_out(i,2)=mean(tempimage(Roi_test));
    Roi_out(i,3)=mean(tempimage(Roi_test2));
    Roi_out(i,4)=mean(tempimage(Roi_test3));
end


ext='abf';
path1=sprintf('%s/*%s*',PathName,ext);
disp(PathName);
dddd = dir (path1);
fn= sprintf('%s%s',PathName, dddd.name);
[d,si,sw,tags,et,cn,timestamp]=abfload(fn);
timestamps(thisfile)=timestamp;
numsweeps=0;
prompt = {'Which Sweep Corresponds with this Image:'};
dlg_title = 'Pick the Sweep';
num_lines = 1;

answer = inputdlg(prompt,dlg_title,num_lines);
sweep_number=str2num(answer{1});


%this codes finds camera busy signals and creates subsampled pclamp data
% traces based on the timing of these signals

e_trace=d(:,1,sweep_number);
camera_trigger=d(:,2,sweep_number);
  
%%% Compute E_phystime

for i=1:size(d,1)
e_time(i)=si*i/1000000;
end

%%%  Compute times off camera trigger
trigger=diff(camera_trigger);
triggertimes_locs=find(trigger>1);
for i=1:size(triggertimes_locs,1)
triggertimes(i)=si*triggertimes_locs(i,1)/1000000;
end



%%% Compute times off of standard exp+delay time
for i=1:Image.no_images
   estimated_time(i)=(i-1)*InstaImage.kinetic_cycle_time;
end
  

%%% Subsample e_phys at same frequency as imaging
for i=1:size(triggertimes,2)
      e_trace_subsampled(i)=e_trace(triggertimes_locs(i));
end

%%% Subsample e_phys at 10X frequency as imaging
suprasample=10;
for i=1:size(triggertimes,2)
        for k=1:suprasample
        interval=InstaImage.kinetic_cycle_time*10000/suprasample;
        holder=round(triggertimes(1,i)*10000+interval*(k-1));
        e_trace_subsampled_supra((i-1)*suprasample+k)=e_trace(holder);
        time_subsampled_supra((i-1)*suprasample+k)=e_time(holder);
        
        end
end


e_trace_subsampled=e_trace_subsampled(:,shutter_open_frame+3:shutter_close_frame-3);
time_subsampled=triggertimes(:,shutter_open_frame+3:shutter_close_frame-3);
e_trace_subsampled_supra=e_trace_subsampled_supra(:,(shutter_open_frame+3)*suprasample:(shutter_close_frame-2)*suprasample-1);
time_subsampled_supra=time_subsampled_supra(:,(shutter_open_frame+3)*suprasample:(shutter_close_frame-2)*suprasample-1);

traceave=mean(e_trace_subsampled_supra);
imageROIave=mean(Roi_out);
Roi_out(:,1)=time_subsampled;
Roi_out_sw(:,2)=e_trace_subsampled_supra;
Roi_out_sw(:,1)=time_subsampled_supra;

text_f=sprintf('%s%s-%smulti_ROI',PathName,InstaImage.filename(52:61),InstaImage.filename(71:79));
save (text_f, 'Roi_out', '-ascii','-tabs');

text_f=sprintf('%s%s-%smulti_ROI_sweep',PathName,InstaImage.filename(52:61),InstaImage.filename(71:79));
save (text_f, 'Roi_out_sw', '-ascii','-tabs');

parameters{1}=Roi_test_mask;
parameters{2}=Roi_test_mask2;
parameterfile=sprintf('%sRoiParam',PathName);
save (parameterfile,'parameters');