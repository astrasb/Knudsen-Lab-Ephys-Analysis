%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This code opens all Redshirt Files within a selected folder, and creates
%  ratioed, normalized images of every frame from every file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
%%% Using this script to Make the ISI figure 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%%%%%%%%% Creat File List    %%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
%directoryname = uigetdir('/mnt/newhome/mirror/home/chris/MATLAB/');    %%%%% Opens files from MATLAB directory

path1=sprintf('%s//*MAX*',directoryname);
d = dir (path1);
numfiles=length(d);
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end

counter=0;
for this_experiment=1:numfiles
    
   
     
        counter=counter+1;
        filename=dd(this_experiment,:);
        loadfullfilename=sprintf('%s//%s',directoryname,filename);
        load(loadfullfilename);
        
        if counter==1
            Mins=zeros(10,1);
           
        end
        this_sweep_baseline=dataout_Filtered_Max(4,1:300);
        this_sweep_baseline_index=find(this_sweep_baseline>0);
        this_sweep_baseline_no_zeroes=this_sweep_baseline(this_sweep_baseline_index);
        this_sweep_baseline_ave=mean(this_sweep_baseline_no_zeroes);
        this_sweep=dataout_Filtered_Max(4,:);
        this_sweep_no_zeros=find(this_sweep>0);
        %Mins(counter)=this_sweep_baseline_ave-min(this_sweep(this_sweep_no_zeros));
        if this_sweep_no_zeros>0
        Mins(counter)=min(this_sweep(this_sweep_no_zeros));
        else
            Min(counter)=0;
        end
       
        
    end
    
    
    
  

