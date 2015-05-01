%%% LSM Opener %%%%
clear all;
[GreenColorTable]=CreateGreenColorTable;
[RedColorTable]=CreateRedColorTable;
[BlueColorTable]=CreateBlueColorTable;
loc='/mnt/m022a/Chris images 7_31_09/';
filename='7_31_09_slice_5';
thispath=uigetdir(loc);
pathfile=sprintf('%s/*.lsm',thispath);


d = dir (pathfile);
numfiles=length(d);
for i = 1:numfiles
    t = length(getfield(d,{i},'name')) ;
    files(i, 1:t) = getfield(d,{i},'name') ;
end

for i=1:numfiles
GFAP=sprintf('%s/GFAP_image_%s_image_%d', thispath,filename, i);
NeuN=sprintf('%s/NeuN_image_%s_image_%d', thispath,filename, i);
ithfile=sprintf('%s/%s', thispath,files(i,:));
[stack, nbImages] =tiffread2(ithfile);
image(stack(1,1).red,'cdatamapping','scaled');
axis image;
box off;
colormap(BlueColorTable);
set(gca,'xtick',[]);
set(gca,'ytick',[]);
print ('-dtiff', NeuN);

image(stack(1,1).green,'cdatamapping','scaled');
axis image;
box off;
colormap(GreenColorTable);
set(gca,'xtick',[]);
set(gca,'ytick',[]);
print ('-dtiff',GFAP);

end



