%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                    Image Aligner                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
[RedMap]=CreateRedColorTable;
[GreenMap]=CreateGreenColorTable;


%%%%%%%%%%%%%%%% Selceting the first two images to register
begin = questdlg('Pick a folder containg LSM files',...
    'Sure I would love to!','Sure I would love to!');

% Opening top most directory
[path1] = uigetdir('/mnt/m022a/','Pick your folder containing LSM files');

files=dir(sprintf('%s/*.lsm',path1));
mkdir(sprintf('%s/Channel 1/',path1));
mkdir(sprintf('%s/Channel 2/',path1));


for i=1:size(files,1)
   this=imread(sprintf('%s/%s', path1,files(i,1).name));
   
   for j=1:size(this,3)
   
   c1=figure(1)
   iptsetpref('ImshowBorder','tight')
   imshow(this(:,:,1),[0, 2^12])
   axis image;
   colormap(GreenMap);
   axis off;
   options.Format='tiff';
   options.Bounds='tight';
   hgexport(c1,sprintf('%s/Channel 1/%s_Channel%d.tif', path1, files(i,1).name(1:size(files(i,1).name,2)-4),j),options);
   close
   end  
  
    
    
end