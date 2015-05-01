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

counter=0;
for this_experiment=20:30
    
   
     
        counter=counter+1;
        filename=dd(this_experiment,:);
        loadfullfilename=sprintf('%s//%s',directoryname,filename);
        load(loadfullfilename);
        
        if counter==1
            Threshold=zeros(10,size(dataout,2));
            Sweep=zeros(10,size(dataout,2));
            time=zeros(10,size(dataout,2));
        end
        
        Threshold(counter,:)=dataout(4,:);
        Sweep(counter,:)=dataout(2,:);
        time(counter,:)=dataout(1,:);
       
        
    end
    
    
    
  

