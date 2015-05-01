%% This code runs spectrum analysis on pre-determined time bins.
%Made to compare power spectrum across time points of a OT gamma
%oscillation RECORDED FROM L10B OF A DISCONNECTED SLICE!
% also compare power of gamma between drug conditions
%asbryant 03.15.13
%inputs: fileno = fileno - Assumes alternative puff+stim, stim. In that
%order.
function [R, t] = asb_disc_osc_spectrum(fileno, path)

close all
%%Import files
warning('OFF')
%prompt user for file if not included in call

%Write code for comparing multiple time bins across conditions.

if exist('fileno') == 0 || isempty('fileno');
    % Open file
    [filename pathname] = (uigetfile('*.abf','Pick a trace'));
    cd(pathname);
   
else
    pathname=path;
    cd(pathname);
    filename = [num2str(fileno), '.abf'];
end

finalpath= cd;%'\\Knu-farva\patchrig\2014\';

[trace dt] = abf2load(filename, 'channels',{'Im_scaled'});
[stims dt] = abf2load(filename, 'channels',{'microstim'});

%%General parameters
sfq = 1/(dt*1e-6); %generates sampling rate in Hz
sweepno = length(trace(1,1,:));

%separate alternating ctrl and puff traces into distinct bins
if sweepno>5
cswp=[1:2:sweepno];
pswp=[2:2:sweepno];
ctrl=trace(:,1,cswp);
drug=trace(:,1,pswp);
cstims=stims(:,1,cswp);
dstims=stims(:,1,cswp);
context=1;
sweepno=sweepno/2;
else
    cswp=[1:sweepno];
    ctrl=trace(:,1,cswp);
    cstims=stims(:,1,cswp);
    context=0;
end


% Replace stimulus artifact values with baseline in ctrl traces
for x=1:sweepno
    stim_val = find(cstims(:, 1, x) > 10);
    if isempty(stim_val)
        stim_val= find(cstims(:,1,x)<-10);
    end
    
    baseline= mean(mean(ctrl(:,1,x))); %one baseline per sweep
    ctrl((stim_val(1)-10:stim_val(1)+100),1,x)=baseline;
    
end
if context>0;
% Replace stimulus artifact values with baseline in drug traces
for x=1:sweepno
   stim_val = find(dstims(:, 1, x) > 10);
    if isempty(stim_val)
        stim_val= find(dstims(:,1,x)<-10);
    end
    baseline= mean(mean(drug(:,1,x))); %one baseline per sweep
    drug((stim_val(1)-10:stim_val(1)+100),1,x)=baseline;
    
end
end
%Analysis bin parameters

%% Old Values
% bins(1,1) = 200;
% bins(1,2)= 400; %median(durations.ctrl);
% bins(1,3)= 200+1000;
% bins(2,1) = 2800;
% bins(2,2) = 2800+200;%(median(durations.ctrl)-180);
% bins(2,3) = 2800+1000;
% bins=bins*(sfq*(1e-3));

%% New Bins, trigger off of Stimulus
bins(1,1) = stim_val(1)+ 50*(sfq*(1e-3));
bins(1,2) = bins(1,1)+ 200*(sfq*(1e-3));
bins(1,3) = bins(1,1)+ 1000*(sfq*(1e-3));
bins(2,1) = stim_val(1)+ 2800*(sfq*(1e-3));
bins(2,2) = bins(2,1)+ 200*(sfq*(1e-3));
bins(2, 3) = bins(2,1)+ 1000*(sfq*(1e-3));
%bins=bins-600; %allow for temporal offset initiated by filter. Otherwise, I'm skipping an entire gamma cycle.
%% Make Bins

for x=1:sweepno;
    traces.ctrl(x,:)=ctrl(bins(1,1):bins(1,3),1,x); %ctrl(3600:23600,1,x);
    tracesbase.ctrl(x,:)=ctrl(bins(2,1):bins(2,3),1,x); %ctrl(40000:50000,1,x);
    if context>0;
    traces.drug(x,:)=drug(bins(1,1):bins(1,3),1,x); %(3600:23600,1,x);
    tracesbase.drug(x,:)=drug(bins(2,1):bins(2,3),1,x); %40000:50000,1,x);
    end
end





filt_band=[20 60];

[durations.ctrl, rms_vals.ctrl] = calc_duration_lfpband (traces.ctrl, tracesbase.ctrl, sfq, filt_band, 50);
%[durations.drug, rms_vals.drug] = calc_duration_lfpband (traces.drug, tracesbase.drug, sfq, filt_band, 200);
close all


[R.ctrl Rstd.ctrl t.ctrl trace.ctrl base.ctrl R.swpctrl] = analysis (ctrl, sfq, bins);
if context>0
    [R.drug Rstd.drug t.drug trace.drug base.drug R.swpdrug] = analysis (drug, sfq, bins);
end
%%Filter traces for plotting and for quantification

[bh,ah] = butter(4, 20/(sfq/2), 'high'); %usually 25
[bl,al] = butter(4, 60/(sfq/2), 'low');
%traces

for z=1:size(trace.ctrl,2)
    temp=ctrl(:,1,z); %trace.ctrl(:,z); 
    %temp=temp-mean(ctrl,3);
    temp=filter(bh,ah,temp(end:-1:1)); temp=filter(bl,al,temp);
    temp=temp(end:-1:1); lfpplot.ctrl(:,z)=temp(bins(1):round(bins(3)));%
    lfp.ctrl(:,z)=temp(round(bins(1)):round(bins(3)));
    %bins(3)==bins(1,2), so first bin of activity
    lfp.ctrlb(:,z)=temp(round(bins(2,1)):round(bins(2,2)));
end
clear temp
% for z=1:size(trace.ctrl,2)
%     %figure('name', 'Detrend');
%     tempfull=(ctrl((bins(1,1): bins(1,3)),1,z));
%     %plot(tempfull); hold on
%     tempfull=tempfull-(mean(ctrl((bins(1,1):bins(1,3)),1,:),3));
%     %tempfull=detrend(tempfull);
%     %plot(tempfull,'k');
% %     tdata=[1:length(tempfull)]*dt;
% %     X=lsqcurvefit(@expon,[1, 500, 1, 500], tdata', tempfull);
% %     trend=expon(X,tdata);
% %     tempfull=tempfull-trend';
%     tempfull=filter(bh,ah,tempfull(end:-1:1));
%     tempfull=filter(bl,al,tempfull);
%     tempfull=tempfull(end:-1:1);
%     %plot(tempfull,'r','linewidth',2);
%     lfpplot.ctrl(:,z)=tempfull(1:(round(bins(1,2)-bins(1,1))));
%     lfp.ctrl(:,z)=tempfull(1:(round(bins(1,2)-bins(1,1))));
%     
%     tempbase=(ctrl((bins(2,1):bins(2,3)),1,z));
%     tempbase=tempbase-(mean(ctrl((bins(2,1):bins(2,3)),1,:),3));
%     tempbase=filter(bh,ah,tempbase(end:-1:1));
%     tempbase=filter(bl,al,tempbase);
%     tempbase=tempbase(end:-1:1);
%     lfp.ctrlb(:,z)=tempbase(1:round(bins(1,2)-bins(1,1)));
%     %plot(tempbase,'g','linewidth',2);
%     %pause
%     %close('Detrend');
%     
% end
% clear tempfull tempbase

if context>0
for z=1:size(trace.drug,2)
    temp=drug(:,1,z); %trace.drug(:,z);
    %temp=temp-mean(drug,3);
    temp=filter(bh,ah,temp(end:-1:1));
    temp=filter(bl,al,temp);
    temp=temp(end:-1:1);
    lfpplot.drug(:,z)=temp(bins(1):bins(3));
    lfp.drug(:,z)=temp(round(bins(1)):round(bins(3))); %bins(3)==bins(1,2), so first bin of activity
    lfp.drugb(:,z)=temp(round(bins(2,1)):round(bins(2,2)));
end
 clear temp
% for z=1:size(trace.drug,2)
%     %figure('name', 'Detrend Drug');
%     tempfull=(drug((bins(1,1): bins(1,3)),1,z));
%     %plot(tempfull); hold on
%     tempfull=tempfull-(mean(drug((bins(1,1):bins(1,3)),1,:),3));
%     %plot(tempfull,'k');
% %     tdata=[1:length(tempfull)]*dt;
% %     X=lsqcurvefit(@expon,[1, 500, 1, 500], tdata', tempfull);
% %     trend=expon(X,tdata);
% %     tempfull=tempfull-trend';
%     tempfull=filter(bh,ah,tempfull(end:-1:1));
%     tempfull=filter(bl,al,tempfull);
%     tempfull=tempfull(end:-1:1);
%     %plot(tempfull,'r','linewidth',2);
%     lfpplot.drug(:,z)=tempfull(1:(round(bins(1,2)-bins(1,1))));
%     lfp.drug(:,z)=tempfull(1:(round(bins(1,2)-bins(1,1))));
%     tempbase=(drug((bins(2,1):bins(2,3)),1,z));
%     tempbase=tempbase-(mean(drug((bins(2,1):bins(2,3)),1,:),3));
%     tempbase=filter(bh,ah,tempbase(end:-1:1));
%     tempbase=filter(bl,al,tempbase);
%     tempbase=tempbase(end:-1:1);
%     lfp.drugb(:,z)=tempbase(1:round(bins(1,2)-bins(1,1)));
%     %plot(tempbase,'g','linewidth',2);
%     %pause
%     %close('Detrend Drug');
%     
%    end
% 
% clear tempfull tempbase
end
%Calculate power for 200 ms. Replace the time variable with calculated
%oscillation duration once Shridar gives it to me.
for x=1:size(lfp.ctrl,2)
    RMS.ctrl(x) = sqrt(nanmean(lfp.ctrl(:,x).^2));
    RMS.basec(x) = sqrt(nanmean(lfp.ctrlb(:,x).^2));
end
if context>0
for x=1:size(lfp.drug,2)
    RMS.drug(x) = sqrt(nanmean(lfp.drug(:,x).^2));
    RMS.based(x) = sqrt(nanmean(lfp.drugb(:,x).^2));
end
end
power.ctrl=20*log(RMS.ctrl./RMS.basec);

if context>0
power.drug=20*log(RMS.drug./RMS.based);
R.deltapower=(mean(RMS.drug)/mean(RMS.based))/(mean(RMS.ctrl)/mean(RMS.basec)); %taking into account potential shifts in baseline.
%R.deltapower=mean(RMS.drug)/mean(RMS.ctrl); %RMS reduced to % of control.
R.deltapower=R.deltapower^2; %putting this as % of control (power) rather than RMS
rdrug=max(range(lfpplot.drug));
end
rctrl=max(range(lfpplot.ctrl));



%% Exporting Figures and Raw Data to dedicated Dropbox Folder
%Make R-spectrum Figure

figure; set(gcf,'Name', strcat(strrep(filename,'.abf','')));

%subplot(5,18, [1 21]);
%plot(1,durations.ctrl,'ko','MarkerSize',2); hold on;
%plot(1.5,durations.drug,'ro','MarkerSize',2);
%plot(1,median(durations.ctrl),'ko','MarkerFaceColor','k','MarkerSize',7);
%plot(1.5,median(durations.drug),'ro','MarkerFaceColor','r','MarkerSize',7);
%hold off
%xlim([.5 2]);
%title('Oscillation Duration');
%ylabel('Duration (ms)');
%set(gca,'xticklabel',{},'xtick',[]);

% subplot(5,18,[6 26]);
% set(gca,'LooseInset',get(gca,'TightInset'));
% plot(1,power.ctrl,'ko','MarkerSize',2); hold on;
% plot(1,median(power.ctrl),'ko','MarkerFaceColor','k','MarkerSize',7);
% if context>0
% plot(1.5,power.drug,'ro','MarkerSize',2);
% plot(1.5,median(power.drug),'ro','MarkerFaceColor','r','MarkerSize',7);
% end
% hold off
% xlim([.5 2])
%title('Power Spectrum');
ylabel('Power (dB)');
set(gca,'xticklabel',{},'xtick',[]);

%subplot(5,18,[37 80]);
shadedErrorBar(t.ctrl.full,R.ctrl,Rstd.ctrl,'k',0);
hold on;
if context>0
%shadedErrorBar(t.drug.full,R.drug,Rstd.drug,'r',0);
end
xlabel('Frequency (Hz)'); ylabel('R-spectrum (dB)');
ylim([0 30]);
xlim([0 100]);
hold off

%Make Sweeps Figure
% subplot(6,18,[11 54]);
% hold on
% for y=1:size(lfpplot.ctrl,2)
%     if y>1;
%         ptrace=lfpplot.ctrl(:,y)+ (rctrl*y);
%     else
%         ptrace=lfpplot.ctrl(:,y);
%     end
%     plot((1:length(ptrace))/sfq,ptrace,'k');
%     set(gca,'XLim',[0 length(ptrace)/sfq]);
%     title('Sweeps'); ylabel('mV');
%     set(gca,'xticklabel',{});
%     
% end
% hold off
% if context>0
% subplot(6,18,[65 108])
% hold on
% for y=1:size(lfpplot.drug,2)
%     if y>1;
%         ptrace=lfpplot.drug(:,y)+ (rdrug*y);
%     else
%         ptrace=lfpplot.drug(:,y);
%     end
%     plot((1:length(ptrace))/sfq,ptrace,'r');
%     set(gca,'XLim',[0 length(ptrace)/sfq]);
%     xlabel('Time (s)'); ylabel('mV');
% end
% hold off
% end
%pause
%Export Figure
print(gcf, '-depsc', strcat(finalpath,'/',  get(gcf,'Name')));

%% Export Data

save.ctrlpwr(1,1)=str2double(strrep(filename,'.abf',''));
save.ctrlpwr(1, 3:(2+size(power.ctrl,2)))=power.ctrl; %Use this line to
%save dB values

save.ctrldur(1,1)=str2double(strrep(filename,'.abf',''));
save.ctrldur(1,2:(1+size(durations.ctrl,2)))=durations.ctrl;

if context>0
save.ctrlpwr(1,2)=R.deltapower; %use this to save power as percent of control (normalized values from RMS^2)

save.drugpwr(1,1)=str2double(strrep(filename,'.abf',''));
save.drugpwr(1, 3:(2+size(power.drug,2)))=power.drug;%Use this line to
%save dB values
save.drugpwr(1,2)=R.deltapower; %use this to save power as percent of control (normalized values from RMS^2)
end

%save.drugdur(1,1)=str2double(strrep(filename.drug,'.abf',''));
%save.drugdur(1, 2:(1+size(durations.drug,2)))=durations.drug;

% save.means(1,1)=mean(power.ctrl);
% save.means(1,2)=mean(power.drug);
% save.means(1,3)=mean(durations.ctrl);
% save.means(1,4)=mean(durations.drug);

%dlmwrite (fullfile(strcat(finalpath,'/ctrlpwr.csv')),save.ctrlpwr,'-append','delimiter','\t','precision', 10);
dlmwrite (fullfile(strcat(finalpath,'/ctrldur.csv')),save.ctrldur,'-append','delimiter','\t','precision', 10);
if context>0
%dlmwrite (fullfile(strcat(finalpath,'/drugpwr.csv')),save.drugpwr,'-append','delimiter','\t','precision', 10);
%dlmwrite (fullfile(strcat(finalpath,'drugdur.csv')),save.drugdur,'-append','delimiter','\t','precision', 10);
end
%dlmwrite (fullfile(strcat(finalpath,'pwr_durmeans.mua')),save.means,'-append','delimiter','\t','precision', 10);

%, strcat(get(gcf,'Name'),'.mua'))

% figure; set(gcf,'Name', strcat(strrep(filename.ctrl,'.abf',''),'_', strrep(filename.drug,'.abf','for_grant')));
%
% shadedErrorBar(t.ctrl.full,R.ctrl,Rstd.ctrl,'k');
%     hold on;
%     shadedErrorBar(t.drug.full,R.drug,Rstd.drug,'r');
%     xlabel('Frequency (Hz)'); ylabel('R-spectrum (dB)');
%     hold off
% print(gcf, '-depsc', strcat('C:\Documents and Settings\astra\My Documents\My Dropbox\Astra\OscAnalysis\',  get(gcf,'Name')));

%

%% Analysis Function
    function [Rmean Rstd t full baseline Rfull] = analysis(trace, sfq, bins)
        
        
        
        sweepno = length(trace(1,1,:));
        
        %first highpass at 1 then lowpass 200.
        
        
        %MTS parameters
        params.tapers = [3 5];
        params.pad = -1;
        params.Fs = sfq;
        params.fpass = [5 100];
        params.trialave = 1;
        params.err = 0; %[2 0.05];
        
        [bh,ah] = butter(4, 5/(sfq/2), 'high');
        [bl,al] = butter(4, 200/(sfq/2), 'low');
        
        %% Generate time bins for analysis
        
%         for x=1:sweepno
%             tempfull=(trace((bins(1,1): bins(1,3)),1,x));
%             tempfull=tempfull-(mean(trace((bins(1,1):bins(1,3)),1,:),3));
%             tempfull=filter(bh,ah,tempfull(end:-1:1));
%             tempfull=filter(bl,al,tempfull); tempfull=tempfull(end:-1:1);
%             %full(:,x)=tempfull(1:round(500*(sfq*(1e-3))));
%             full(:,x)=tempfull(1:round(bins(1,2)-bins(1,1)));
%             
%             tempbase=(trace((bins(2,1):bins(2,3)),1,x));
%             tempbase=tempbase-(mean(trace((bins(2,1):bins(2,3)),1,:),3));
%             tempbase=filter(bh,ah,tempbase);
%             tempbase=filter(bl,al,tempbase);
%             baseline(:,x)=tempbase(1:round(bins(1,2)-bins(1,1)));
%         end
%         
         for x=1:sweepno
            figure('name', 'Detrend');
            tempfull=(trace((bins(1,1): bins(1,3)),1,x));
            plot(tempfull); hold on
            %tempfull=tempfull-(mean(trace((bins(1,1):bins(1,3)),1,:),3));
            %tempfull=detrend(tempfull);
            %plot(tempfull,'k');
            tempfull=filter(bh,ah,tempfull(end:-1:1));
            tempfull=filter(bl,al,tempfull);
            tempfull=tempfull(end:-1:1);
            plot(tempfull,'r','linewidth',2);
            full(:,x)=tempfull(1:(round(bins(1,2)-bins(1,1))));
            
            %baseline(:,x)=tempfull(round(bins(2,1)-round(bins(1,1))):(round(bins(2,1))-round(bins(1,1))));
            tempbase=(trace((bins(2,1):bins(2,3)),1,x));
            
            %tempbase=tempbase-mean(tempbase);
            %tempbase=tempbase-(mean(trace((bins(2,1):bins(2,3)),1,:),3));
            tempbase=filter(bh,ah,tempbase(end:-1:1));
            tempbase=filter(bl,al,tempbase);
            tempbase=tempbase(end:-1:1);
            baseline(:,x)=tempbase(1:round(bins(1,2)-bins(1,1)));
            plot(tempbase,'g','linewidth',2);
            %pause
            close('Detrend');
        end
        
        [S.baseline,t.baseline]=mtspectrumc((baseline),params);
        
        params.trialave = 0;
        
        [S.full,t.full]=mtspectrumc((full),params);
        
        for x=1:size(S.full,2)
            Rfull(:,x)=(S.full(:,x)./S.baseline);
        end
        
        Rmean=mean(Rfull,2);%decibel
        Rstd=std(Rfull,[],2)/sqrt(size(S.full,2));
        
        
        
        %keyboard
        
        
    end
end