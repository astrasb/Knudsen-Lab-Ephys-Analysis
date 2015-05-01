%%%%%%%%  Analyzing Andor Slow Calibration Files %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Use this program to open, draw roi's and compute ratio/time
%  courses for slow (1 image every 10 secs) local perfursion
% calibration files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all; 
[Image,InstaImage,CalibImage,vers]=andorread_chris_local()
temp=CellArrayImages{1};
ch1=temp(1:64,:,:);
ch2=temp(65:128,:,:);
ch1ave=squeeze(mean(mean(ch1)));
ch2ave=squeeze(mean(mean(ch2)));
ratiotemp=ch1ave./ch2ave;