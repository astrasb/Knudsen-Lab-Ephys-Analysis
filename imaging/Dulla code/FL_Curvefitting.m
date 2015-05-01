%% FL_ROI Opener and curvefitting
clear all;
Happiness=questdlg('Select FL ROI file','GOULET INC');

[FileName,PathName,FilterIndex] = uigetfile('/mnt/m022a/2009_02_17/')
fname=sprintf('%s%s',PathName,FileName);
 ROIs=load(fname);
 
ch1=ROIs(3,:);
ch2=ROIs(4,:);

subplot(2,1,1)
plot(ch1)
subplot(2,1,2)
plot(ch2)
x_cutoff=0;
x_restart=100;
prompt = {'Enter the last x-value pre-glutamate application to use for curve fitting                 '};
dlg_title = 'Adjust Registration              ';
num_lines = 1;
def = {num2str(x_cutoff)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
x_cutoff=str2num(answer{1,1});

fit_ch1=ch1(1:x_cutoff);
fit_ch2=ch2(1:x_cutoff);


prompt = {'Enter the first x-value post-glutamte application to use for curve fitting                 '};
dlg_title = 'Adjust Registration              ';
num_lines = 1;
def = {num2str(x_restart)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
x_restart=str2num(answer{1,1});

fit_ch1=[fit_ch1,ch1(x_restart:size(ch1,2))];
fit_ch2=[fit_ch2,ch2(x_restart:size(ch1,2))];

for hh=1:size(ch1,2)
    time(hh)=hh;
end
fit_time=[time(1:x_cutoff),time(x_restart:size(ch1,2))];
if x_restart==size(ch1,2)
   fit_ch1=fit_ch1(1:size(fit_ch1,2)-1);
   fit_ch2=fit_ch2(1:size(fit_ch2,2)-1);
   fit_time=fit_time(1:size(fit_ch1,2));
end
    


figure(2)
plot(fit_time,fit_ch1);
           
cftool

ch1sub=ch1-analysisresults1.yfit';
ch2sub=ch2-analysisresults2.yfit';
ch1sub=ch1sub+ch1(1,1);
ch2sub=ch2sub+ch2(1,1);
ratiosub=ch1sub./ch2sub;


out_roi(1,:)=ratiosub;
out_roi(2,:)=ch1sub;
out_roi(3,:)=ch2sub;
out_roi(4,:)=ch1./ch2;

ROI_values_out=sprintf('%sroi_out_subracted.txt',PathName);

save (ROI_values_out, 'out_roi', '-ascii','-tabs');

                
                