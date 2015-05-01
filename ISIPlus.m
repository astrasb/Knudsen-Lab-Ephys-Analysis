
function [] = ISIPlus ()
%Script for taking an abf file with field and spiking channels, and
%detecting the ISI of the spikes. Can be used to plot spikes in gamma
%oscillation versus spikes on an individual neuron.
%

[filename.ctrl pathname.ctrl] = (uigetfile('*.abf','Pick a control condition trace'));
cd(pathname.ctrl);
[filename.drug pathname.drug] = (uigetfile('*.abf','Pick a drug condition trace'));

[trace dt] = abf2load(filename.ctrl,'channels',{'Im_scaled', 'I_MTest 1', 'microstim'});
[drugtrace] = abf2load(filename.drug,'channels',{'Im_scaled', 'I_MTest 1', 'microstim'});



sfq = 1/(dt*1e-6);
dt=dt/1000;

cch = 1;    %single cell channel
fch = 2;    %field recording channel
sch = 3;    %stim channel

sweepno = length(trace(1, 1, :));
drugsweepno=length(drugtrace(1,1,:));

%control of unequal sweep numbers in two conditions
if sweepno<drugsweepno
    drugsweepno=sweepno;
elseif sweepno>drugsweepno
    sweepno=drugsweepno;
end

[ss]= epochdetect (sweepno,sch,cch, fch,trace,dt,sfq);
[cond]=spikedetect(ss, dt, sweepno);
display('Control Condition Spikes Detected');

cond(1).isi=cond(1).isi*dt; %Single Cell Channel Spikes

%cond(2).isi=cond(2).isi*dt; %Field Channel Spikes. 

[ds]=epochdetect(drugsweepno,sch,cch,fch,drugtrace,dt,sfq);
[drug]=spikedetect(ds,dt,drugsweepno);
display('Drug Condition Spikes Detected');

drug(1).isi=drug(1).isi*dt; %Single Cell Channel Spikes
%drug(2).isi=drug(2).isi*dt; %Field Channel Spikes

%% Plotting ISI Histogram, as a function of discrete bins.
binranges=[5:5:100];
bccontrol=histc(cond(1).isi(find(cond(1).isi>0)),binranges);
bcdrug=histc(drug(1).isi(find(drug(1).isi>0)),binranges);

% figure;
% bar(binranges,bccontrol,'histc');
% hold on;
% bar(binranges,bcdrug,'histc');
% hold off;

a=cond.isi(find(cond.isi>0));
b=drug.isi(find(drug.isi>0));
dlmwrite(fullfile('control.txt'),a,'delimiter','\t','precision',10);
dlmwrite(fullfile('drug.txt'),b,'delimiter','\t','precision',10);

%iei_fit('control.txt',3);
%iei_fit('drug.txt',3); hold off;
display(filename);

%keyboard

%% Calling Chronux for spike-field coherence. Aw yeah.
for x=1:sweepno
    simplearray(:,x)=ss(:,4,x);
end

for x=1:sweepno
    temp=cond.times(:,x);
    times(x).tm=temp(find(temp>0));
    times(x).tm=times(x).tm/sfq;
    clear temp
end

for x=1:sweepno
    drugarray(:,x)=ds(:,4,x);
end

for x=1:sweepno
    temp=drug.times(:,x);
    dtimes(x).tm=temp(find(temp>0));
    dtimes(x).tm=dtimes(x).tm/sfq;
    clear temp
end

 %SpikeField parameters
        params.tapers = [10 19];
        params.pad = -1;
        params.Fs = sfq;
        params.fpass = [0 200];
        params.trialave = 1;
        params.err = [2 0.05]; %0;

[C, phi, S12, S1, S2, f, zerosp, confC, phistd, Cerr]=coherencycpt(simplearray, times,params);

[dC, dphi, dS12, dS1, dS2, df, dzerosp, dconfC, dphistd, dCerr]=coherencycpt(drugarray, dtimes,params);

figure; plot(f,C,'k','LineWidth',2);
hold on; plot(f, Cerr,'k--');
plot(df,dC,'r','LineWidth',2); %plot(df,dCerr,'r--');
plot(f,confC,'b-','Linewidth',1.25);


%save.controlisi=(cond(1).isi(find(cond(1).isi>0)));
%save.drugisi=(drug(1).isi(find(drug(1).isi>0)));
% save.controlisi(1,1)=str2double(strrep(filename.ctrl,'.abf',''));
% save.controlisi(1, 2:(1+size(bccontrol,1)))=bccontrol;
% 
% save.drugisi(1,1)=str2double(strrep(filename.drug,'.abf',''));
% save.drugisi(1, 2:(1+size(bcdrug,1)))=bcdrug;
% 
% save.binranges=binranges;
%iei_fitasb(save.controlisi,3,'Control');
%iei_fitasb(save.drugisi,3,'nAChR block');
%dlmwrite (fullfile('test.txt'),save.controlisi,'delimiter','\t','precision', 10);


end


function [ss]= epochdetect (sweepno,sch,cch, fch,trace,dt,sfq);
c=mean(squeeze(trace(:,fch,:)),2);
for x = 1:sweepno
    stim_val = find(trace(:, sch, x) > 1);
    if isempty(stim_val)
        stim_val= find(trace(:,sch,x)<-1);
    end
    %% Filter for spike detection
    
    [bh,ah] = butter(4, 100/(sfq/2), 'high'); 
    temp=trace(:,cch,x);
    temp=temp-mean(temp);
    temp=filter(bh,ah,temp(end:-1:1));
    temp=temp(end:-1:1);
    cell(:,x)=temp;
    clear temp
    
    %%Filter for spike field coherence
    [bh,ah] = butter(4, 200/(sfq/2), 'low');
    temp=trace(:,fch,x);
    temp=temp-c; %removing some of the low frequency movement that is common btwn swps
    temp=temp-mean(temp);
    temp=filter(bh,ah,temp(end:-1:1));
    temp=temp(end:-1:1);
    field(:,x)=temp;
    clear temp
    
   
    %%Code for filtering at gamma band.
%     [bh,ah] = butter(4, 25/(sfq/2), 'high'); %usually 25
%     [bl,al] = butter(4, 200/(sfq/2), 'low');    
%     temp=trace(:,fch,x);
%     temp=temp-mean(temp);
%     temp=filter(bh,ah,temp(end:-1:1));
%     temp=filter(bl,al,temp);
%     temp=temp(end:-1:1);
%     field(:,x)=temp;
    
    rawfield(:,x)=trace(:,fch,x);
    
    
    % Replace stimulus artifact values with baseline in current channel
    baseline= mean(mean(cell(:,x))); %one baseline per sweep
    cell((stim_val(1)-400:stim_val(1)+50),x)=baseline;
    
    % Replace stimulus artifact values with baseline in field channel
    baseline= mean(mean(field(:,x))); %one baseline per sweep
    field((stim_val(1)-1950:stim_val(1)+50),x)=baseline;
    
    baseline= mean(mean(rawfield(:,x))); %one baseline per sweep
    rawfield((stim_val(1)-1950:stim_val(1)+50),x)=baseline;
    
    %% Select Epochs for Further Analysis
    ss(:,1,x) = stim_val(1)+51:stim_val(1)+40051; %epoch of 2 seconds
    ss(:,2,x) = trace(ss(:,1,x),sch,x);
    ss(:,3,x) = cell(ss(:,1,x),x);
    ss(:,4,x) = field(ss(:,1,x),x);
    ss(:,5,x) = rawfield(ss(:,1,x),x);
    
    
end


end

function [cond]=spikedetect(ss, dt, sweepno);
%Determine artifact polarity and stimulus threshold for entire file. using test pulse

[artifactpolaritycch] =set_threshold (ss,dt,sweepno,3);
ss(:,3,:)=artifactpolaritycch*ss(:,3,:);

[artifactpolarityfch] =set_threshold (ss,dt,sweepno,5);
ss(:,5,:)=artifactpolarityfch*ss(:,5,:);


[cond(1).peaks, cond(1).times, cond(1).isi]=stimulus_detection(sweepno, ss, 3);
%[cond(2).peaks, cond(2).times, cond(2).isi]=stimulus_detection(sweepno, ss, 5);


end

%% Set spike detection threshold and spike polarity.
function [artifactpolarity] = set_threshold (ss,dt,sweepno,channel);

fig=figure(1);
clf(fig);
set(gcf,'Name','Threshold Selection');
hold on
for x=1:sweepno
    plot(ss(1:length(ss),1,x)*dt,ss(1:length(ss),channel,x));
end
hold off
zoom on

%Ask for spike polarity
prompt={'What is the Spike Polarity?'}; %user prompt for setting threshold
title='Spike Polarity';
str1='Neg.';
str2='Pos.';
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='none';
spike_direction=questdlg(prompt,title,str1,str2,str1);
switch spike_direction
    case 'Neg.'
        artifactpolarity = -1;
    case 'Pos.'
        artifactpolarity = 1;
end



close(fig);

end


%% Detect stimuli - limited to detecting single spike

function [peaks, times, isi]= stimulus_detection(sweepno, data, channel)
for x=1:sweepno
    swps(:,x)=data(:,channel,x);
    stms(:,x)=data(:,2,x);
    tms(:,x)=data(:,1,x);
end
z=0;

    %detect all stimuli, not just the first one.
    peaks=zeros(500,sweepno);
    times=peaks;
    tmultiply=2; %(used 2 for oct 21 #21,22) Have also used 5. Usually 6
    
    for x=1:sweepno
        
        baseline=mean(swps(:,x));
        dev=std(swps(:,x));
        if ~isempty(find(swps(:,x)>(baseline+(dev*tmultiply))))
            
            [a, b]=findpeaks(swps(:,x),'MINPEAKHEIGHT',(baseline+(dev*tmultiply)),'MINPEAKDISTANCE',20,'NPEAKS',500);
            
            peaks(1:length(a),x)=a;
            times(1:length(b),x)=b;
            
        end
        displaysweeps=0;
        %VISUAL CONFIRMATION OF SPIKE DETECTION ACCURACY
        if displaysweeps>0
        figure('name', 'Confirm Accuracy of Spike Detection'); plot(swps(:,x)); hold on; plot(times(:,x),peaks(:,x),'ro'); hold off;
        display(strcat('Sweep -', num2str(x)));
        pause
        close('Confirm Accuracy of Spike Detection');
        end
    end
%display('Hit Ctrl+C to rerun analysis with altered spike detection values');
%pause

isi=zeros(100,sweepno);
for x=1:sweepno
    z=2;
    spikeno = size(find(times(:,x)>0),1);
    while z<=spikeno
        isi(z-1,x)=times(z,x)-times(z-1,x);
        z=z+1;
    end
end

end
