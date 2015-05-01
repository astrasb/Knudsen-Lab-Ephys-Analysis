%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This code opens all Redshirt Files within a selected folder, and creates
%  ratioed, normalized images of every frame from every file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
%%% Using this script to analyze ISI data from 2008_03_18
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%%%%%%%%% Creat File List    %%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
%directoryname = uigetdir('/mnt/newhome/mirror/home/chris/MATLAB/');    %%%%% Opens files from MATLAB directory

path1=sprintf('%s//*.mat',directoryname);
d = dir (path1);
numfiles=length(d);
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end

Number_of_experiments=8;
Exposure_end_number_this_slice=[1 10 21 30 40 50 66 72 ];
sums=zeros(numfiles,3);
for this_experiment=7:Number_of_experiments
    
    Number_of_exposures_in_this_experiment=Exposure_end_number_this_slice(this_experiment+1)-Exposure_end_number_this_slice(this_experiment)+1;
    if (Number_of_exposures_in_this_experiment>2 && Number_of_exposures_in_this_experiment<18)
      for This_exposure=Exposure_end_number_this_slice(this_experiment):Exposure_end_number_this_slice(this_experiment+1)
        
        filename=dd(This_exposure,:);
        loadfullfilename=sprintf('%s//%s',directoryname,filename);
        load(loadfullfilename);
        
        if This_exposure==Exposure_end_number_this_slice(this_experiment)
            Threshold_2=zeros(Number_of_exposures_in_this_experiment,size(dataout,2));
            Threshold_3=zeros(Number_of_exposures_in_this_experiment,size(dataout,2));
            Threshold_4=zeros(Number_of_exposures_in_this_experiment,size(dataout,2));
        end
        
        Threshold_2(This_exposure-Exposure_end_number_this_slice(this_experiment)+1,:)=dataout(3,:);
        Threshold_3(This_exposure-Exposure_end_number_this_slice(this_experiment)+1,:)=dataout(4,:);
        Threshold_4(This_exposure-Exposure_end_number_this_slice(this_experiment)+1,:)=dataout(5,:);
        Thresh_2_sum=sum(dataout(3,:));
        Thresh_3_sum=sum(dataout(4,:));
        Thresh_4_sum=sum(dataout(5,:));
        sums(This_exposure,1)=Thresh_2_sum;
        sums(This_exposure,2)=Thresh_3_sum;
        sums(This_exposure,3)=Thresh_4_sum;
        
    end
    
    filename2=sprintf('%s/Thresh2_%s',directoryname,filename);
    save(filename2, 'Threshold_2');
    filename3=sprintf('%s/Thresh3_%s',directoryname,filename);
    save(filename3, 'Threshold_3');
    filename4=sprintf('%s/Thresh4_%s',directoryname,filename);
    save (filename4, 'Threshold_4');
    else
    end
end
