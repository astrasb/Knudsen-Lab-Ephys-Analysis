function [out] = puff_charge_analyzer(filename)
% This program will analyze various parameters of epscs from a pClamp file.
%
%
% Class Support
%   -------------
%   enter as puff_charge_analyzer('filename'), or puff_charge_analyzer('') to choose file
%   Uses abfload.m to import a trace.
%   Trace has the structure of trace(data, channel# , sweep#)

%   AS Bryant 12/11 Matlab R14
%   updated for 4 channel recordin (recording, Vm, electrical, puff) 5/10
%   updated for greater flexibility with multiple file structures 12/11
%	abryant@stanford.edu

clc
%if isempty(filename);
    % Open file
    [filename, pathname] = get_filename;
    expname=regexprep(filename,'.abf','');
%end

%abfload requires .abf files saved in ABF 1.8 (integer) format
[trace dt] = abf2load(strcat(pathname,filename));
%disp(['file ', filename, ' opened.'])


% np = input('Do you want to analyze negative (n) or positive (p) events? -->  ', 's');
% 
% if np == 'n'
%     artifactpolarity = 1;
% else
%     artifactpolarity = -1;
% end
% 
% 

%% File parameters
dt = dt/1000;      %convert dt from us to ms = sampling rate in Hz

swp = 1;           %sweep number
cch = 1;           %current channel
sch = 3;           %electrical stim channel
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
    puff_val = find(trace(:, pch, swp) > 4);
    if ~isempty(puff_val)
        puff(swp, :) = [puff_val(1), length(puff_val)]; %find begin of puff and its duration, in ms
    else
        puff(swp, :) = [0 0];                   %else declare no puff as being [0 0]
    end
end


%% Acquire baseline

period = [puff(:, 1)];        %select the first one in time, and move 50 ms before.
for x = 1:size(sweeps, 2)
    baseline(x) = mean(sweeps(1:period(x), x));
    sweeps(:, x) = sweeps(:, x) - baseline(x);
    hifreqbase = sweeps(1:period(x), x) - filter(bflow, aflow, sweeps(1:period(x), x));
    noise(x) = std(hifreqbase);
end

[spont_pos spont_neg] = charge_transfer(sweeps([ones(sweepno, 1):period], :), noise);

%% Define length of period to be measured, find area

[pos_area neg_area] = charge_transfer(sweeps( [puff(:, 1):(puff(:, 1)+period)], :), noise);

pos_charge = pos_area-spont_pos;
neg_charge = neg_area-spont_neg;



%this value is pC ???, calculated from pA at a given time point * 0.1 ms
%(0.0001 s)


% %% now build graph barcolors=['k','b','r']; for i= 1:(size(conditions,1))
%     barraw(:,i)=(pos_charge((firstswp(i)):(firstswp(i)+binsize)));
%     barplot(1,i)= sum(pos_charge((firstswp(i)):(firstswp(i)+binsize)));
% %     barraw(:,i)=(pos_charge((5+(15*(i-1))):(14+(15*(i-1))))); %
% barplot(1,i)= sum(pos_charge((5+(15*(i-1))):(14+(15*(i-1))))); end
% figure; hold on; for i=1:size(barplot,2);
%     bar(i,barplot(1,i),barcolors(i));
% end set(gca,'XTick',1:size(barplot,2)); set(gca,'XTickLabel',conditions);
% ylabel('Total Charge (pC)'); title(strcat('Total Charge','
% (',expname,')')); hold off

%print('-dpng',fullfile(pathname,strcat(expname,'_TC.png')));
%close
%%Now export all charge values into excel-readable file
%dlmwrite ((fullfile(pathname, strcat(expname,'_TC.mua'))),barraw,'\t');
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




