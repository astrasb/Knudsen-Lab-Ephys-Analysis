clear all


[Bfile Bpath] = uigetfile('/mnt/m022a/','Select the brighfield Andor Image');
[Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(sprintf('%s%s',Bpath,Bfile));
BrightA=Image.data(1:64,:);

disp('Andor Brightfield Image Read')

FRET_LP=dir(sprintf('%sNew_analysis_8_1_2009/*FRET*',Bpath));
Fr=open(sprintf('%sNew_analysis_8_1_2009/%s',Bpath,FRET_LP(1,1).name));
FRET_logicals=Fr.FRET_logicals;

[Gpath] = uigetdir('/mnt/m022a/SR101_FL','Select the Glial Map file');
GMap=dir(sprintf('%s/*BinaryMap*',Gpath));
open(sprintf('%s/%s',Gpath,GMap(1,1).name));
GMaps=dir(sprintf('%s/*AverageIntensity*',Gpath));
open(sprintf('%s/%s',Gpath,GMaps(1,1).name));
GMaps=dir(sprintf('%s/*GLT1*',Gpath));
GLT=imread(sprintf('%s/%s',Gpath,GMaps(1,1).name));
GMaps=dir(sprintf('%s/*brightfield*',Gpath));
BrightC=imread(sprintf('%s/%s',Gpath,GMaps(1,1).name));
BrightC(:,:,2:3)=[];
GLT(:,:,1)=[];
GLTs=(GLT(:,:,1)+GLT(:,:,2))/2;
