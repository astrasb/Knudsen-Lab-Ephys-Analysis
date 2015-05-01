%%% Local MAT File Opener
clear all;

directoryname = uigetdir('D://fromredshirt_2_6/');                                 %%%% Opens files from my shared drive
%directoryname = uigetdir('/mnt/newhome/mirror/home/c;/hris/MATLAB/');    %%%%% Opens files from MATLAB directory
%%% Open Files
path=sprintf('%s/*streamlined*',directoryname);
d = dir (path);
numfiles=length(d);
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
    t = length(getfield(d,{i},'name')) ;
    dd(i, 1:t) = getfield(d,{i},'name') ;
end

%%% Memory locations for data
%%% FL, Contra, FL_GBZ, Contra_GBZ
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%
%%%  1=FL_max;
%%%  2=mean_peak_01;
%%%  3=mean_peak_05;
%%%  4=mean_peak_10;
%%%  5=mean_peak_15;
%%%  6=AA1;
%%%  7=AA5;
%%%  8=AA10;
%%%  9=AA15;
%%%  10=Column_skew_01_write;
%%%  11=Layer_skew_01_write;
%%%  12=Column_kurt_01_write;
%%%  13=Layer_kurt_01_write;
%%%  14=Column_skew_05_write;
%%%  15=Layer_skew_05_write;
%%%  16=Column_kurt_05_write;
%%%  17=Layer_kurt_05_write;
%%%  18=Column_skew_10_write;
%%%  19=Layer_skew_10_write;
%%%  20=Column_kurt_10_write;
%%%  21=Layer_kurt_10_write;
%%%  22=Column_skew_15_write;
%%%  23=Layer_skew_15_write;
%%%  24=Column_kurt_15_write;
%%%  25=Layer_kurt_15_write;


if 2>1
    values=[1 3 4 8;
        1 5 6 10;
        1 5 6 9;
        0 6 7 11;
        1 5 6 10;
        1 5 6 10;
        1 5 6 10;
        1 5 6 10;
        1 3 4 8;
        1 5 6 10;
        0 4 5 9;
        0 5 6 10;
        1 5 6 10;
        1 5 10 15;
        1 5 6 10;
        0 5 6 10;
        1 6 7 11;
        1 4 5 9;
        1 5 6 10;
        1 5 6 10;
        0 5 6 10;
        1 5 6 9;
        1 4 5 9;
        0 5 6 10;
        1 5 6 10;
        1 5 10 15;
        1 5 10 15;
        1 5 10 15;
        0 5 10 15;
        0 5 10 15;
        1 5 10 15;
        1 5 10 15;
        1 5 10 15;
        0 5 10 15]
end
FL=zeros(25,1,60);
FL_GBZ=zeros(25,1,60);
Contra=zeros(25,1,60);
Contra_GBZ=zeros(25,1,60);
for ti=1:numfiles
    FLsize=size(FL,2);
    FLGBZsize=size(FL_GBZ,2);
    Contrasize=size(Contra,2);
    ContraGBZsize=size(Contra_GBZ,2);
    thisfile=sprintf('%s/%s',directoryname,dd(ti,:));
    load(thisfile);

    if 2<1
        %%% Select Control Files
        prompt=sprintf('Is Slice %s a Freeze Lesion Slice or a Contralateral? 1=FL, 0=Sham', thisfile(25:37));
        dlg_title = 'Select Control Files          ';
        num_lines = 1;
        default=1;
        def = {num2str(default)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        Freeze=str2num(answer{1,1});

        %%% Select Control Files
        prompt=sprintf('For slice %s how many control exposures are there?', thisfile(25:37));
        dlg_title = 'Select Control Files          ';
        num_lines = 1;
        default=5;
        def = {num2str(default)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        number_of_exposures=str2num(answer{1,1});


        %%% Select GABA Files
        prompt=sprintf('For slice %s which is the first GABAzine exposures you want to use?', thisfile(25:37));
        dlg_title = 'Select GABAzine Files          ';
        num_lines = 1;
        default=5;
        def = {num2str(default)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        number_of_exposures_GBZ_1=str2num(answer{1,1});

        prompt=sprintf('For slice %s which is the last GABAzine exposures you want to use?', thisfile(25:37));
        dlg_title = 'Select GABAzine Files          ';
        num_lines = 1;
        default=10;
        def = {num2str(default)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        number_of_exposures_GBZ_2=str2num(answer{1,1});
    else
        Freeze=values(ti,1);
        number_of_exposures=values(ti,2);
        number_of_exposures_GBZ_1=values(ti,3);
        number_of_exposures_GBZ_2=values(ti,4);
    end

    if Freeze==1
        pause=1;
        for exposure=1:number_of_exposures
            for ii=1:25
                FL(ii,exposure+FLsize-1,:)=Data_output(exposure,ii+1,:);
            end
        end
        for exposure=number_of_exposures_GBZ_1:number_of_exposures_GBZ_2
            for ii=1:25
                FL_GBZ(ii,FLGBZsize+exposure-number_of_exposures,:)=Data_output(exposure,ii+1,:);
            end
        end
    else
        for exposure=1:number_of_exposures
            for ii=1:25
                Contra(ii, exposure+Contrasize-1,:)=Data_output(exposure,ii+1,:);
            end
        end
        for exposure=number_of_exposures_GBZ_1:number_of_exposures_GBZ_2
            for ii=1:25
                Contra_GBZ(ii,ContraGBZsize+exposure-number_of_exposures,:)=Data_output(exposure,ii+1,:);
            end
        end



    end
end

output_location=sprintf('%s/outputfiles',directoryname);
mkdir(output_location);

filenames={'FRET_max';'mean_peak_01';'mean_peak_05';'mean_peak_10';'mean_peak_15';'AA1';'AA5';'AA10';'AA15';'Column_skew_01_write';'Layer_skew_01_write';'Column_kurt_01_write';
    'Layer_kurt_01_write';'Column_skew_05_write';'Layer_skew_05_write';'Column_kurt_05_write';'Layer_kurt_05_write';'Column_skew_10_write';'Layer_skew_10_write';'Column_kurt_10_write';
    'Layer_kurt_10_write';'Column_skew_15_write';'Layer_skew_15_write';'Column_kurt_15_write';'Layer_kurt_15_write'};

for kk=1:25
    file_n1=sprintf('%s/FL_%s.txt',output_location,filenames{kk});
    file_n2=sprintf('%s/FL_GBZ_%s.txt',output_location,filenames{kk});
    file_n3=sprintf('%s/Contra_%s.txt',output_location,filenames{kk});
    file_n4=sprintf('%s/Contra_GBZ_%s.txt',output_location,filenames{kk});
    out1=squeeze(FL(kk,:,:));
    out2=squeeze(FL_GBZ(kk,:,:));
    out3=squeeze(Contra(kk,:,:));
    out4=squeeze(Contra_GBZ(kk,:,:));
    save(file_n1,'out1','-ascii','-tabs');
    save(file_n2,'out2','-ascii','-tabs');
    save(file_n3,'out3','-ascii','-tabs');
    save(file_n4,'out4','-ascii','-tabs');
end

