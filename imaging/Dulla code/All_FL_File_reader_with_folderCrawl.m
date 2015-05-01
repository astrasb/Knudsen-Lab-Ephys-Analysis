%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This code opens all Redshirt Files within a selected folder, and creates
%  ratioed, normalized images of every frame from every file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
ROI_ON=0;
filecounter=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Create File List    %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opening top most directory
directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
%directoryname = uigetdir('/mnt/newhome/mirror/home/c;/hris/MATLAB/');    %%%%% Opens files from MATLAB directory

path1dir=sprintf('%s/',directoryname);
ddir = dir (path1dir);
numfilesdir=length(ddir)-2;
if numfilesdir<1
    disp('No files found');
end

for i = 1:numfilesdir
    t = length(getfield(ddir,{i+2},'name')) ;
    dddir(i, 1:t) = getfield(ddir,{i+2},'name') ;
end

% Opening each day's folder
for number_of_directories=1:numfilesdir
    clear dslice;
    subdirectoryname=sprintf('%s/%s',directoryname,ddir(number_of_directories+2,:).name);
    path1slice=sprintf('%s/%s',directoryname,ddir(number_of_directories+2,:).name);
    dslice = dir (path1slice);
    numfilesslice=length(dslice)-2;
    if numfilesslice<1
        disp('No files found');
    end
    clear ddslice;
    for i = 1:numfilesslice
        t = length(getfield(dslice,{i+2},'name')) ;
        ddslice(i, 1:t) = getfield(dslice,{i+2},'name') ;
    end

    
    for number_of_slices=1:numfilesslice
        clear streamdir;
    clear streamddir;
    clear col_skewddir;
    clear col_skewdir;
     clear winddir;
    clear windir;
    clear aligndir;
    clear alignddir;
        slicesubdirectoryname=sprintf('%s/%s/%s',directoryname,dddir(number_of_directories,:),ddslice(number_of_slices,:));
        path1streamfile=sprintf('%s/%s/*stream*',subdirectoryname,ddslice(number_of_slices,:));
        streamdir = dir (path1streamfile);
        numfilesstream=length(streamdir);
        if numfilesstream<1
            disp('No files found');
        end
        if numfilesstream>1
            disp('Too Many Files Found');
        end
        for i = 1:numfilesstream
            t = length(getfield(streamdir,{i},'name')) ;
            streamddir(i, 1:t) = getfield(streamdir,{i},'name') ;
        end

        path1winfile=sprintf('%s/%s/*window*',subdirectoryname,ddslice(number_of_slices,:));
        windir = dir (path1winfile);
        numfileswin=length(windir);
        if numfileswin<1
            disp('No files found');
        end
        if numfileswin>1
            disp('Too Many Files Found');
        end
        for i = 1:numfileswin
            t = length(getfield(windir,{i},'name')) ;
            winddir(i, 1:t) = getfield(windir,{i},'name') ;
        end
        
        path1col_skew=sprintf('%s/%s/*col_skew.mat',subdirectoryname,ddslice(number_of_slices,:));
        col_skewdir = dir (path1col_skew);
        numfilescol_skew=length(col_skewdir);
        if numfilescol_skew<1
            disp('No files found');
        end
        if numfilescol_skew>1
            disp('Too Many Files Found');
        end
        for i = 1:numfilescol_skew
            t = length(getfield(col_skewdir,{i},'name')) ;
            
            col_skewddir(i, 1:t) = getfield(col_skewdir,{i},'name') ;
        end

        path1col_align=sprintf('%s/%s/*align*',subdirectoryname,ddslice(number_of_slices,:));
        aligndir = dir (path1col_align);
        numfilescol_skew=length(aligndir);
        if numfilescol_skew<1
            disp('No files found');
        end
        if numfilescol_skew>1
            disp('Too Many Files Found');
        end
        for i = 1:numfilescol_skew
            t = length(getfield( aligndir ,{i},'name')) ;
            
             alignddir (i, 1:t) = getfield( aligndir ,{i},'name') ;
        end
        pause=1;
        
        %%%%%  import MAT files
        filecounter=filecounter+1;
        skew=open(sprintf('%s/%s',slicesubdirectoryname,streamddir(1, :)));
        skewraw=open(sprintf('%s/%s',slicesubdirectoryname,col_skewddir(1, :)));
        skewwindow=open(sprintf('%s/%s',slicesubdirectoryname,winddir(1, :)));
        align=open(sprintf('%s/%s',slicesubdirectoryname,alignddir(1, :)));
        
        skewout(filecounter,:)=squeeze(mean(skew.Data_output(1:3,15,:)));
        skewrawour(filecounter,:)=squeeze(mean(skewraw.Column_skew_instant_write(1:3,:)));
        skewoutwindow(filecounter,:)=squeeze(mean(skewwindow.Column_skew_instant_write_window(1:3,:)));
        skewoutalign(filecounter,:)=squeeze(mean(align.Column_skew_instant_write_align(1:3,:)));
        filenames{filecounter,1}=sprintf('%s/%s',slicesubdirectoryname,streamddir(1, :));
        filenames{filecounter,2}=sprintf('%s/%s',slicesubdirectoryname,col_skewddir(1, :));
        end
    end

