%%%%%%%%  Analyzing Andor Slow Calibration Files %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Use this program to open, draw roi's and compute ratio/time
%  courses for slow (1 image every 10 secs) local perfursion
% calibration files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
%close all;


[RGBCustom]=CreateRGBColorTable;

Happiness=questdlg('Please Select your local perfusion Andor File','GOULET INC');
[Image,InstaImage,CalibImage,vers]=andorread_chris_local()
temp=Image.data;
exposuretime=InstaImage.exposure_time;

ch1=temp(1:64,:,:);
ch2=temp(65:128,:,:);

liveave=squeeze(mean(mean(ch1(20:40,60:80,:))));
dliveave=diff(liveave);
[trash, illumination_start]=max(dliveave);
[trash, illumination_end]=min(dliveave);

darkframe=FrameAverage(temp,5,illumination_start);

linedark=reshape(darkframe,1,[]);
figure, set(gcf, 'Name', 'Linedark')
hist(linedark,500)
Fluorescence_dark_clipped=(temp(:,:,illumination_start:illumination_end));
subframe=zeros(size(Fluorescence_dark_clipped,1),size(Fluorescence_dark_clipped,2),size(Fluorescence_dark_clipped,3));

for i=1:size(Fluorescence_dark_clipped, 3)
    tframe=Fluorescence_dark_clipped(:,:,i);
    subframe(:,:,i)=tframe-darkframe;
end

subtractedhist=reshape(subframe,1,[]);
figure, set(gcf, 'Name', 'subtracted hist')
hist(subtractedhist,500)

ch1sub=subframe(1:64,:,:);
ch2sub=subframe(65:128,:,:);



ratio=ch1sub./ch2sub;
normsingle=FrameAverage(ratio, 2,10);
figure, set(gcf, 'Name', 'image')
image(ch1(:,:,100),'cdatamapping','scaled');



return


mask=roipoly;

inside=find(mask==1);
outside=find(mask==0);

normframe=zeros(size(ratio,1),size(ratio,2),size(ratio,3));
for i=1:size(ratio, 3)
    tframe=ratio(:,:,i);
    normframetemp=tframe-normsingle;
    normframetemp(outside)=0;
    normframe(:,:,i)=normframetemp;
end


