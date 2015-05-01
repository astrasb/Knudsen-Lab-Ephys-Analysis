function []= crawl()


%manual running list of oscillation experiments to analyze. Column 1 =
%control conditions, column 2 = drug conditions
%Sham Wash
filenames=[13327000, 13327002; 
 13408000, 13408001;
 13409000, 13409001;
 13409003, 13409004;
 13409005, 13409006;
 13409012, 13409013;
 13409024, 13409025;
 13501000, 13501001;
 13501002, 13501003;
 13501007, 13501008;
 ];

%nAChRs
directory = '/Users/Batcave/Documents/EPhys Recordings/Gamma Oscillations + nAchR Block/nAChR Block';
filenames= [13328003, 13328004;
 13328008, 13328009;
 13329005, 13329006;
 13402000, 13402001;
 13418005, 13418006;
 13419001, 13419002;
 13425001, 13425002;
 13425004, 13425005;
 13426004, 13426005;
 13426007, 13426008;
 13426010, 13426011;
 13429008, 13429009;
 13429004, 134290056;
 134290001, 134290023;];

%mAChRs and nAChRs
filenames=[13521003, 13521004;
    13522000,13522001;
    13522003, 13522004;
    13522006, 13522007;];

%aBTX alone
directory = '/Users/Batcave/Documents/EPhys Recordings/Gamma Oscillations + nAchR Block/aBTX Experiments';
filenames=[13612001, 13612002;
    13612003, 13612004;
    13614000, 13614001;
    13614002, 13614003;
    13619000, 13619001;
    13619002, 13619003;
    13626000, 13626001;
    13626002, 13626003;
    13626004, 13626005;
    13703000, 13703001;
    13705000, 13705002;
    13705003, 13705005;
    13705006, 13705007;
    13708000, 13708001;
    13708005, 13708006;];

%mAChR block
directory = '/Users/Batcave/Documents/EPhys Recordings/mAChR Block';
filenames=[14324000, 14324001;
    14402000, 14402001;
    14402002, 14402003;
    14402005, 14402006;
    14402007, 14402008;
    14403003, 14403004;
    14403005, 14403006;
    14407005, 14407006;
    14409002, 14409003;
    14409004, 14409005;
    14410002, 14410004;
    14410007, 14410008;
    14421000, 14421001;
    14421003, 14421004;
    14421006, 14421007;];

%ACh Puff in L10a
directory = '/Users/Batcave/Documents/EPhys Recordings/Disconnected Gamma plus ACh Puff';
filenames=[
    14121000;
    14121001;
    14121002;
    14121003;
    14121005;
    14121006;
    14121007;
    14121009;
    14124000;
    14124001;
    14124002;
    14124003;
    14124004;
    14124006;
    14124007;
    14124008;
    14124009;
    14129001;
    14520002;
    14520004;
    14520011;
    14520013;
    14520017;
    14520018;
    14520021;];
%ACh Puff in L5
directory = '/Users/Batcave/Documents/EPhys Recordings/Disconnected Gamma plus ACh Puff/L5 Puff';
filenames=[14312000;
    14312003;
    14312005;
    14312008;
    14312009;
    14312011;
    14312012;
    14312014;
    14312015;
    14312017;
    14313000;
    14313004;
    14313006;
    14313011;
    14313015;
    14313022;
    14313026;
    14313030;
    14313034;];
    
directory = '/Users/Batcave/Documents/EPhys Recordings/Disconnected Gamma plus ACh Puff/a7';
filenames=[14129000;
    14129001;
    14129002;
    14129004;
    14129006;
    14204000;
    14204005;
    14204010;
    14204011;
    14416000;
    14416001;
    14416002;
    14416007;
    14527003;
    14527011;
    14527014;
    14527015;
    14527021;
    14527023;
    14527024;
    14527032;
    14527035;
    14527036;
%      14129005;
%      14204001;
%     14204003;
%     14204004;
%      14204008;
%     14204009;
%     14416003;
%     14416005;
    ];

%%Double Puff Experiments
%nona7
directory = '/Users/Batcave/Documents/EPhys Recordings/ACh currents desensitization/nona7 currents';
filenames=[
    12121020;
    12121045;
    12121120;
    12121136;
    13123015;
    13123025;
    13719011;
    13813010;
    14117005;
    14117010;];
directory = '/Users/Batcave/Documents/EPhys Recordings/ACh currents desensitization/a7 currents';
filenames=[
    12120539;
    12121008;
    12121033;
    12121125;
    12121824;
    13107015;
    13123004;
    13206011;
    13807045;
    14117031;];

directory = '/Users/Batcave/Documents/EPhys Recordings/ACh-triggered IPSCs in L10b/in a7 blockers';
filenames=[
    13807037, 13807040;
    13807047, 13807052;
    13812007, 13812010;
    13812043, 13812047;
    13813007, 13813017;];

directory = '/Users/Batcave/Documents/EPhys Recordings/ACh-triggered IPSCs in L10b/';
filenames=[
    14304037;
    14304013;
    14304003;
    14303034;
    14303028;
    13121324;
    13121313;
    13819060;
    13819026;
    13819014;
     14304051;
    14304045;
    14304025;
    14303019;
    14117028;
    13121330;
    13121305;
    13819048;
    13814047;
    13814041;
    13814024;
    13814009;
    ];

directory = '/Users/Batcave/Documents/EPhys Recordings/Localizing Gamma in Disconnected Slice/3.13.14/';
filenames=[
    14313000;
    14313001;
    14313004;
    14313005;
    14313006;
    14313007;
    14313008;
    14313009;
    14313010;
    14313011;
    14313012;
    14313013;
    14313014;
    14313015;
    14313016;
    14313017;
    14313018;
    14313019;
    14313020;
    14313022;
    14313023;
    14313024;
    14313025;
    14313026;
    14313027;
    14313028;
    14313030;
    14313031;
    14313032;
    14313033;
    14313034;
    14313035;
    14313036;];

directory = '/Users/Batcave/Documents/EPhys Recordings/Localizing Gamma in Disconnected Slice/5.20.14/';
filenames=[
    14520001;
    14520002;
    14520003;
    14520009;
    14520011;
    14520012;
    14520013;
    14520014;
    14520015;
    14520016;
    14520017;
    14520018;
    14520019;
    14520021;
    14520022;];
directory = '/Users/Batcave/Documents/EPhys Recordings/Localizing Gamma in Disconnected Slice/5.27.14/';
filenames=[
     %14527001;
     %14527003;
     14527007;
     %14527009;
     %14527011;
     %14527012;
    %14527015;
    %14527016;
    %14527017;
    %14527018;
    %14527019;
    14527020;
     %14527024;
     %14527025;
     %14527026;
     %14527027;
     14527028;
     %14527029;
     %14527030;
    ];


    
for x=1:length(filenames);
    temp=num2str(filenames(x,1));
    %dirr= fullfile(directory,strcat('0',temp(3),'.',temp(4:5),'.',temp(1:2),'/'));
    ctrlfileno= strcat(num2str(filenames(x,1)));
    %drugfileno= strcat(num2str(filenames(x,2)));
    %asb_osc_spectrum(ctrlfileno, drugfileno, directory);
    asb_disc_osc_spectrum(ctrlfileno,directory);
    %[ctrlsdf]=PSTHGaussian(ctrlfileno,directory);
    %[drugsdf]=PSTHGaussian(drugfileno,directory);
    %IPSC_peaks(ctrlfileno,directory);
    %CountGammaSpikes(ctrlfileno,directory,'ctrl');
    %CountGammaSpikes(drugfileno,directory,'drug');
    %current_analysis_multiplefiles(ctrlfileno, directory, 1);
    %current_analysis_multiplefiles(drugfileno, directory, -1);
end


mctrlp=[];
    mctrlt=[];
    mdrugp=[];
    mdrugt=[];
for x=1:length(filenames);
    temp=num2str(filenames(x,1));
    ctrlfileno= strcat(num2str(filenames(x,1)));
    drugfileno= strcat(num2str(filenames(x,2)));
    [ctrlsdf]=PSTHGaussian(ctrlfileno,directory);
    [drugsdf]=PSTHGaussian(drugfileno,directory);
    clear a b c d e f
    ctrlpeak=[];
    ctrltrough=[];
    drugpeak=[];
    drugtrough=[];
    for i=1:size(ctrlsdf,1)
        [a,b]=findpeaks(ctrlsdf(i,:));
        [c,d]=findpeaks(ctrlsdf(i,:)*-1);
        c=c*-1;
        %plot(ctrlsdf(i,:)'); hold on; plot(b,a,'ko'); plot(d,c,'ro'); hold off
        %pause
        e=median(a);
        f=median(c);
        ctrlpeak=horzcat(ctrlpeak,e);
        ctrltrough=horzcat(ctrltrough,f);
    end
    
    clear a b c d e f
    for i=1:size(drugsdf,1)
        [a,b]=findpeaks(drugsdf(i,:));
        [c,d]=findpeaks(drugsdf(i,:)*-1);
        c=c*-1;
        %plot(drugsdf(i,:)'); hold on; plot(b,a,'ko'); plot(d,c,'ro'); hold off
        %pause
        e=median(a);
        f=median(c);
        drugpeak=horzcat(drugpeak,e);
        drugtrough=horzcat(drugtrough,f);
    end
    mctrlp=horzcat(mctrlp,median(ctrlpeak));
    mctrlt=horzcat(mctrlt,median(ctrltrough));
    mdrugp=horzcat(mdrugp,median(drugpeak));
    mdrugt=horzcat(mdrugt,median(drugtrough));
    
end





    A.ctrl(:,x)=R.ctrl;
    A.drug(:,x)=R.drug;
    A.deltapower(:,x)=R.deltapower;
    times.ctrl(:,x)=t.ctrl.full;
    times.drug(:,x)=t.drug.full;
end
Rmean.ctrl=mean(A.ctrl,2);
Rmean.drug=mean(A.drug,2);
Rstd.ctrl=std(A.ctrl,[],2)/sqrt(size(A.ctrl,2));
Rstd.drug=std(A.drug,[],2)/sqrt(size(A.drug,2));
figure; set(gcf,'Name','nAChR population Rspectrum');

shadedErrorBar(t.ctrl.full,Rmean.ctrl,Rstd.ctrl,'k',1);
    hold on;
    shadedErrorBar(t.drug.full,Rmean.drug,Rstd.drug,'r',1);
    xlabel('Frequency (Hz)'); ylabel('R-spectrum (dB)');
    hold off
print(gcf, '-depsc', strcat('C:\Documents and Settings\astra\My Documents\My Dropbox\Astra\OscAnalysis\',  get(gcf,'Name')));
% 
disp('Crawl Completed!');

%% Crawl for ISI
    directory = '\\Knu-farva\patchrig\2013';
for x=1:length(filenames);
    temp=num2str(filenames(x,1));
    dirr= fullfile(directory,strcat('0',temp(3),'.',temp(4:5),'.',temp(1:2),'\'));
    ctrlfileno= strcat(num2str(filenames(x,1)));
    drugfileno= strcat(num2str(filenames(x,2)));
    [isi] = asb_ipc_bursts(ctrlfileno, drugfileno, dirr);
end

[files,bytes,paths] = dirr(directory, '.abf', 'name') ;
%Find the paths of the ABF files in the directory and subdirectory

clear abfs ;
if length(paths)>0
for i=1:length(paths)
	tmp = cell2mat(paths(i)) ;
	abfs(i, 1:length(tmp)) = tmp ;
	clear tmp ;
end