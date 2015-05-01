if 1>2
%%%% Plotting the means of Ch1 and Ch2 for Curve fitting
subplot(2,1,1)
plot(ch1tofit)
subplot(2,1,2)
plot(ch2tofit)

if 2>1
x_cutoff=0;
x_restart=100;
prompt = {'Enter the last x-value to use for curve fitting                 '};
dlg_title = 'Adjust Registration              ';
num_lines = 1;
def = {num2str(x_cutoff)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
x_cutoff=str2num(answer{1,1});

fit_ch1=ch1tofit(1:x_cutoff);
fit_ch2=ch2tofit(1:x_cutoff);


prompt = {'Enter the first x-value to use for curve fitting                 '};
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
try
fo_ = fitoptions('method','NonlinearLeastSquares','Robust','On','Algorithm','Levenberg-Marquardt');
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

catch
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

end
% Or use coefficients from the original fit:
if 0
   cv_ = { 52.697750977965384322, -0.57107350967034153921, 1082.9534326239570419, -0.0012917054854730896599};
   cf_ = cfit(ft_,cv_{:});
end


% --- Create fit "fit 2"
try 
fo2_ = fitoptions('method','NonlinearLeastSquares','Robust','On','Algorithm','Levenberg-Marquardt');
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
catch
fo2_ = fitoptions('method','NonlinearLeastSquares');%,'Robust','On'%,'Algorithm','Levenberg-Marquardt');
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
end
    
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
ratio=ch1sub./ch2sub;

ch1fit_zero_to_1=Ch1_fit_results-(Ch1_fit_results(1,size(Ch1_fit_results,2)));
ch1fit_zero_to_1=ch1fit_zero_to_1/ch1fit_zero_to_1(1,1);

ch2fit_zero_to_1=Ch2_fit_results-(Ch2_fit_results(1,size(Ch2_fit_results,2)));
ch2fit_zero_to_1=ch2fit_zero_to_1/ch2fit_zero_to_1(1,1);

%%%%%%%%%%  Normalization
ch1start=ch1(:,:,1);
ch2start=ch2(:,:,1);

ch1end=ch1(:,:,size(ch1,3));
ch2end=ch2(:,:,size(ch2,3));


Ch1_Normalized=zeros(size(ch1,1),size(ch1,2),size(ch1,3));
Ch2_Normalized=zeros(size(ch1,1),size(ch1,2),size(ch1,3));
   for j=1:size(ch1,3)
       
            ThisFrame1=ch1(:,:,j);
            ThisFrame2=ch2(:,:,j);
            
            
            TimeRelativeToStart1=ch1fit_zero_to_1(j);
            TimeRelativeToEnd1=1-TimeRelativeToStart1;
            
            TimeRelativeToStart2=ch2fit_zero_to_1(j);
            TimeRelativeToEnd2=1-TimeRelativeToStart2;
            
            tempFrame1=ch1start*TimeRelativeToStart1+ch1end*TimeRelativeToEnd1;
            tempFrame2=ch2start*TimeRelativeToStart2+ch2end*TimeRelativeToEnd2;
             
            NormFrame1=ThisFrame1-tempFrame1+mean(mean(mean(ch1start(size(ch1,1)/4:3*size(ch1,1)/4,size(ch1,2)/8:7*size(ch1,2)/8))));
            NormFrame2=ThisFrame2-tempFrame2+mean(mean(mean(ch2start(size(ch1,1)/4:3*size(ch1,1)/4,size(ch1,2)/8:7*size(ch1,2)/8))));
            Ch1_Normalized(:,:,j)=NormFrame1;
            Ch2_Normalized(:,:,j)=NormFrame2;
   end
%%%%%%%%%%%%%%%%%%%%%%% Adjust alignment
Aligned='No';

VertAdjust=0;
HorizAdjust=0;
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
            
       
            
        end
 
    
    close;
end
ch1=ch1test;
    ch2=ch2test;
    Ch1_Normalized=ch1test_n;
    Ch2_Normalized=ch2test_n;
        





ratio_raw=ch1./ch2;
ratio=Ch1_Normalized./Ch2_Normalized;

else
  ratio=ch1./ch2;  
end