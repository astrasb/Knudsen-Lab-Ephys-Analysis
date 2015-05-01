%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This code opens all Redshirt Files within a selected folder, and creates
%  ratioed, normalized images of every frame from every file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%%%%%%%%% Creat File List    %%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
%directoryname = uigetdir('/mnt/newhome/mirror/home/chris/MATLAB/');    %%%%% Opens files from MATLAB directory

path1=sprintf('%s//*Centroid*',directoryname);
d = dir (path1);
numfiles=length(d);
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end
start=450;
ending=2000;
filename=dd(1,:)
fullfilename=sprintf('%s//%s',directoryname,filename);
load(fullfilename);

Length=size(Centroid_Coordinates,2);
Length=ending-start;
 z=ones(Length,3); 

 for fill=1:Length
     if (fill> 0 && fill<(Length/4))
     z(fill,1)=0;
     z(fill,2)=fill*4/Length;
     z(fill,3)=1;
     end
     
     if (fill>(Length/4)&& fill<(2*Length/4))
     z(fill,1)=0;
     z(fill,2)=1;
     z(fill,3)=1-(((fill-Length/4)*4)/Length);
     end
     
     if (fill>(2*Length/4)&& fill<(3*Length/4))
     z(fill,1)=1-(((fill-Length/2-1)*4)/Length);
     z(fill,2)=1;
     z(fill,3)=0;
     end
      
     if (fill>(3*Length/4)&& fill<(4*Length/4))
     z(fill,1)=1;
     z(fill,2)=(fill-3*Length/4)*4/Length;
     z(fill,3)=0;
     end
     
    
     
 end
for thisfile =67:numfiles
 %try
 filename=dd(thisfile,:)
fullfilename=sprintf('%s/%s',directoryname,filename);
load(fullfilename);
y=-Centroid_Coordinates(1,start:ending-1)';
x=Centroid_Coordinates(2,start:ending-1)';
scatter(x,y,20,z);
axis image;
xlim([0 80]);
ylim([-40 0]);

strout='.mat';
outname=strrep(fullfilename,strout,'.jpg');
text(10,5,fullfilename(23:size(fullfilename,2)),'interpreter', 'none');

saveas(gcf, outname);
  
end

disp('Loaded');