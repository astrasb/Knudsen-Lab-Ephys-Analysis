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

OutFile=zeros(1,60);
for ti=1:numfiles
    OutFilesize=size(OutFile,1);
    thisfile=sprintf('%s/%s',directoryname,dd(ti,:));
    load(thisfile);

 %%% Select Files
        
        t=1:60;
        Ave_Fret=squeeze(Data_output(:,2,:));
        
        Skew_05=squeeze(Data_output(:,15,:));
        Skew_05_layer=squeeze(Data_output(:,16,:));
        
        plot(t,Ave_Fret(2,:),t,Ave_Fret(3,:),t,Ave_Fret(4,:),t,Ave_Fret(5,:),t,Ave_Fret(6,:))
            
        %%% Select Control Files
        prompt=sprintf('For slice %s how many control exposures are there?', thisfile(25:37));
        dlg_title = 'Select Control Files          ';
        num_lines = 1;
        default=5;
        def = {num2str(default)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        number_of_exposures=str2num(answer{1,1});
        
        OutFile(OutFilesize+1,:)=mean(Ave_Fret(1:number_of_exposures,:));
        OutFile_skew(OutFilesize+1,:)=mean(Skew_05(1:number_of_exposures,:));
        OutFile_skew_layer(OutFilesize+1,:)=mean(Skew_05_layer(1:number_of_exposures,:));
        

    
       
end

