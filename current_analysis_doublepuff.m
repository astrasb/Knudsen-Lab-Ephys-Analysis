function [out] = current_analysis_doublepuff(ctrlfileno, path)
% This program will analyze various parameters of currents (epscs, ipscs) from a pClamp file.
%
%
% Class Support
%   -------------
%   enter as current_analysis_multiplefiles(ctrlfileno, drugfileno, path),
%   or puff_charge_analyzer('') to choose files
%   Uses abf2load.m to import a trace.
%   Trace has the structure of trace(data, channel# , sweep#)

%   AS Bryant 11/13 Matlab R14
%	abryant@stanford.edu

clc
if exist('ctrlfileno') == 0 || isempty('ctrlfileno');
    % Open file
    [filename.ctrl pathname.ctrl] = (uigetfile('*.abf','Pick a control condition trace'));
    cd(pathname.ctrl);
    
else
    pathname.ctrl=path;
    cd(pathname.ctrl);
    filename.ctrl = [num2str(ctrlfileno), '.abf'];
end

finalpath= cd% '\Users\Batcave\Documents\Matlab\';

[trace dt] = abf2load(filename.ctrl,'channels',{'Im_scaled', 'puff'});

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
sfq = 1/(dt*1e-6);
dt=dt/1000; %convert dt from us to ms = sampling rate in Hz

swp = 1;           %sweep number
cch = 1;           %current channel
sch = 2;           %electrical stim channel
%pch = 3;           % puffer channel

sweepno = length(trace(1, 1, :));

ap=-1; %artifact polarity. -1 for inward currents, 1 for outward currents


%% Filter parameters

%butterworth parameters for 1k lowpass, 2k high limit of -10db,
%normalizing by dt.
Wp = 100/(0.5*1000/dt);
Ws = 500/(0.5*1000/dt);
[N W] = buttord(Wp, Ws, 0.01, 10);
[bf af] = butter(N, W, 'low');


[bflow,aflow] = butter(4, 1000/(sfq/2), 'low');

%% Begin process

sweeps = filter(bf, af, squeeze(trace(:, 1, :))); %filter sweep

for swp = 1:sweepno
    %find time, duration of stim
    stim_val = find(diff(trace(:, sch, swp)) > 4);
    stim_no = length(stim_val);
    if isempty(stim_val)
        stim_val= find(trace(:,sch,swp)<-4);
    end
   
    for s=1:stim_no
        stim(swp,s) = [stim_val(s)];
    end
end


%% Acquire baseline
bins(1,1) = stim_val(1)+ (20*(sfq*(1e-3))); %start analysis 20 ms after stimulus
bins(1,2) = stim_val(1)+ (1520*(sfq*(1e-3))); %analysis window is 2 seconds
bins (2,1) = stim_val(2)+ (20*(sfq*(1e-3)));
bins (2,2) = stim_val(2)+ (1520*(sfq*(1e-3)));

period = [stim(:, 1)-50*(sfq*(1e-3))];        %select the first one in time, and move 50 ms before.
for x = 1:size(sweeps, 2)
    baseline(x) = mean(sweeps(200:period(x), x)); %the 200:period(x) used to be 1:period(x), but in some traces, there is a recording artefact at the beginning
    sweeps(:, x) = sweeps(:, x) - baseline(x);
    temp=filter(bflow,aflow,sweeps(:,x));
    hifreqbase = sweeps(200:period(1),x) - temp(200:period(1));
    noise(x) = std(hifreqbase);
    clear temp
end

[spont_pos spont_neg] = charge_transfer(sweeps([(ones(sweepno, 1)*100):period], :), noise,-1,ap);

%% Define length of period to be measured, find area

[pos_area neg_area] = charge_transfer(sweeps( [bins(1,1):bins(1,2)], :), noise,1,ap);
[pos_areatwo neg_areatwo] = charge_transfer(sweeps( [bins(2,1):bins(2,2)],:), noise,1,ap);

pos_charge = pos_area-spont_pos; %value is currently pA * sample rate
neg_charge = neg_area-spont_neg; %value is currently pA * sample rate

pos_chargetwo = pos_areatwo-spont_pos;
neg_chargetwo = neg_areatwo-spont_neg;

%converting from pA*sample rate into pA*ms
pos_charge = pos_charge*dt;
neg_charge = neg_charge*dt;
pos_chargetwo = pos_chargetwo*dt;
neg_chargetwo = neg_chargetwo*dt;

%values are now pA*ms. a coulomb is defined as A*s. pA*ms == (A*10^-12)*
%(S*10^-3), which equals C*10^-9, or nC. Although, as this is giving a
%rather large number, may want to divide by 10^3, which will get to uC



dlmwrite(fullfile('filenames'),(strrep(filename.ctrl,'.abf','')),'-append','delimiter','\t','precision',10);

dlmwrite (fullfile('FirstPuff.csv'),pos_charge,'-append','delimiter','\t','precision', 10);
dlmwrite(fullfile('SecondPuff.csv'),pos_chargetwo,'-append','delimiter','\t','precision',10);


%keyboard
%% For detecting charge transfer

function [pos_area neg_area] = charge_transfer(sweeps, noise,type,ap)
if ap<0;
    sweeps=sweeps*-1;
    noise=noise*-1;
end
for x = 1:size(sweeps, 2)
    s = sweeps(:, x);
    neg_area(x) = sum(s(find(s < -5*noise(x))));
    pos_area(x) = sum(s(find(s > 5*noise(x))));
    
    if type<0
    figure('name', 'Observe areas greater than noise'); plot(s); hold on; plot(find(s > 5*noise(x)),s(find(s > 5*noise(x))),'ro');
    %display(strcat('Sweep -', num2str(x)));
        pause
        close('Observe areas greater than noise');
    else
        if ~isempty(find(s>5*noise(x)))
        figure('name', 'Observe spontaneous activity greater than noise'); plot(s); 
        hold on; plot(find(s > 5*noise(x)),s(find(s > 5*noise(x))),'ro');
        plot(find(s < -5*noise(x)), s(find(s < -5*noise(x))), 'bo');
        hold off
        
    %display(strcat('Sweep -', num2str(x)));
        pause
        close('Observe spontaneous activity greater than noise');
        end
    end
end


return

function [filename, pathname] = get_filename
[filename, pathname, filterindex] = uigetfile('.abf', 'Pick a File to Analyze');
return




