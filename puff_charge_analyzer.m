function [out] = puff_charge_analyzer(filename)
% This program will analyze various parameters of epscs from a pClamp file.
%
%
% Class Support
%   -------------
%   enter as puff_charge_analyzer('filename'), or puff_charge_analyzer('') to choose file
%   Uses abfload.m to import a trace.
%   Trace has the structure of trace(data, channel# , sweep#)

%   CA Goddard 2/08 Matlab R14
%   updated for 4 channel recordin (recording, Vm, electrical, puff) 5/10
%	cgoddard@stanford.edu

clc
%if isempty(filename);
    % Open file
    [filename, pathname] = get_filename;
    expname=regexprep(filename,'.abf','');
%end

%abfload requires .abf files saved in ABF 1.8 (integer) format
[trace dt] = abfload(strcat(pathname,filename));
%disp(['file ', filename, ' opened.'])

prompt={'Condition 1','Condition 2','Condition 3'};
dlg_title='Condition Details';
num_lines=1;
defans={'Control','',''};
conditions=inputdlg(prompt,dlg_title,num_lines,defans);

%%Config
firstswp=[1]; %for more than one drug condition [1,10,20]
binsize=19;
pufftype='ACh';
sweepshow='n';
saver='n';

   
np = input('Do you want to analyze negative (n) or positive (p) events? -->  ', 's');

if np == 'n'
    artifactpolarity = 1;
else
    artifactpolarity = -1;
end
% 
% 
% pufftype = input('What was puffed? (default is ACh) -->  ', 's');
% if isempty(pufftype)
%     pufftype = 'ACh';
% end
% 
% go = 0;     %dummy variable to skip the following two questions.
% if go == 1
%     
%     sweepshow = input('Do you want to show the sweeps? (default = n) -->  ', 's');
%     if isempty(sweepshow)
%         sweepshow = 'n';
%     end
%     
%     saver = input('Do you want to save an eps file of the figure? (default = n) -->  ', 's');
%     if isempty(saver)
%         saver = 'n';
%     end
%     
% end


%% File parameters
dt = dt/1000;      %convert dt from us to ms = sampling rate in Hz

swp = 1;           %sweep number
cch = 1;           %current channel
sch = 4;           %electrical stim channel
pch = 3;           % puffer channel

sweepno = length(trace(1, 1, :));


%% Filter parameters
%butterworth parameters for 1k lowpass, 2k high limit of -10db,
%normalizing by dt.
Wp = 1000/(0.5*1000/dt);
Ws = 2000/(0.5*1000/dt);
[N W] = buttord(Wp, Ws, 0.01, 10);
[bf af] = butter(N, W, 'low');

%build a ultra-low pass butterworth for baselines (10 Hz cutoff)
Wp = 10/(0.5*1000/dt);
Ws = 50/(0.5*1000/dt);
[N W] = buttord(Wp, Ws, 0.01, 10);
[bflow aflow] = butter(N, W, 'low');

%% Begin process

sweeps = filter(bf, af, squeeze(trace(:, 1, :))); %filter sweep

for swp = 1:sweepno
    %find time, duration of puff
    puff_val = find(trace(1:6000, pch, swp) > 4); %CHANGED THIS SO IT LOOKS FOR A PUFF IN 1ST SECOND
    if ~isempty(puff_val)
        puff(swp, :) = [puff_val(1), length(puff_val)]; %find begin of puff and its duration, in ms
    else
        puff(swp, :) = [0 0];                   %else declare no puff as being [0 0]
    end
    
    stim_val = find(trace(:, sch, swp) > 1);
    st(swp,:)=stim_val(1);
end
keyboard


%% Acquire baseline

period = [st(:, 1)];        %select the first one in time, and move 50 ms before.
for x = 1:size(sweeps, 2)
    baseline(x) = mean(sweeps(1:(period(x)-1050), x));
    sweeps(:, x) = sweeps(:, x) - baseline(x);
    hifreqbase = sweeps(1:period(x), x) - filter(bflow, aflow, sweeps(1:period(x), x));
    noise(x) = std(hifreqbase);
end
%% Replace Stim artifact with baseline
sweeps((period:period+40),:)=repmat(baseline,41,1);


[spont_pos spont_neg] = charge_transfer(sweeps([ones(sweepno, 1):period], :), noise);

%% Define length of period to be measured, find area

[pos_area neg_area] = charge_transfer(sweeps( [puff(:, 1):(puff(:, 1)+period)], :), noise);

pos_charge = pos_area-spont_pos;
neg_charge = neg_area-spont_neg;



%this value is pC ???, calculated from pA at a given time point * 0.1 ms
%(0.0001 s)


%% now build graph
%NEED TO SEPARATE INTO PUFF AND NO PUFF TO QUANTIFY. MAYBE DO THIS BEFORE
%FEEDING INTO CHARGE_TRANSFER ABOVE
barcolors=['k','b','r'];
for i= 1:(size(conditions,1))
    barraw(:,i)=(pos_charge((firstswp(i)):(firstswp(i)+binsize)));
    barplot(1,i)= sum(pos_charge((firstswp(i)):(firstswp(i)+binsize)));
%     barraw(:,i)=(pos_charge((5+(15*(i-1))):(14+(15*(i-1)))));
%     barplot(1,i)= sum(pos_charge((5+(15*(i-1))):(14+(15*(i-1)))));
end
figure;
hold on;
for i=1:size(barplot,2);
    bar(i,barplot(1,i),barcolors(i));
end
set(gca,'XTick',1:size(barplot,2));
set(gca,'XTickLabel',conditions);
ylabel('Total Charge (pC)');
title(strcat('Total Charge',' (',expname,')'));
hold off

print('-dpng',fullfile(pathname,strcat(expname,'_TC.png')));
%close
%%Now export all charge values into excel-readable file
dlmwrite ((fullfile(pathname, strcat(expname,'_TC.mua'))),barraw,'\t');
disp(['Finished Analyzing ', filename,'!'])
return
%% For detecting charge transfer

function [pos_area neg_area] = charge_transfer(sweeps, noise)

for x = 1:size(sweeps, 2)
    s = sweeps(:, x);
    neg_area(x) = sum(s(find(s < -2*noise(x))));
    pos_area(x) = sum(s(find(s > 2*noise(x))));
end


return

function [filename, pathname] = get_filename
[filename, pathname, filterindex] = uigetfile('.abf', 'Pick a File to Analyze');
return




