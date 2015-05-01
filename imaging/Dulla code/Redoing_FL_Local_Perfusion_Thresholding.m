clear all;
directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
path1dir=sprintf('%s/*New_Analysis_6_30_2009*',directoryname);
ddir = dir (path1dir);
numfilesdir=length(ddir);
if numfilesdir<1
    disp('No files found');
end
