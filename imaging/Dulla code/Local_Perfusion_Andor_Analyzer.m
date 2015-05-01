%%%%%%%%  Analyzing Andor Slow Calibration Files %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Use this program to open, draw roi's and compute ratio/time
%  courses for slow (1 image every 10 secs) local perfursion
% calibration files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
Happiness=questdlg('Please Select your brightfield Andor File','GOULET INC');
[Image,InstaImage,CalibImage,vers]=andorread_chris_local()
brightfield=Image.data;
Happiness=questdlg('Please Select your local perfusion Andor File','GOULET INC');
[Image,InstaImage,CalibImage,vers]=andorread_chris_local()
temp=Image.data;
ch1=temp(1:64,:,:);
ch2=temp(65:128,:,:);
ratio=ch1./ch2;
subplot(2,1,1)
image(brightfield(1:64,:), 'cdatamapping','scaled');
subplot(2,1,2)
image(ratio(:,:,10),'cdatamapping','scaled')
region=roipoly;
value=zeros(1, size(ratio,3));
for i=1:size(ratio,3)
    thisimage=ratio(:,:,i);
    value(1,i)=mean(mean(thisimage(region)));  
   
end

figure(2)
plot(value);