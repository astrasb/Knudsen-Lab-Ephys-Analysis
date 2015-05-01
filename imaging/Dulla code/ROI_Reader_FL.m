


path = uigetdir('/mnt/m022a'); 
ext='ROI';
path1=sprintf('%s/*%s*',path,ext);
disp(path);
d = dir (path1);
numfiles=length(d);
directoryname=path;
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
  File_Names{i}=getfield(d,{i},'name') ;
  This_Tag=str2double(dd(i,t-10:t-8));
  
  if isnan(This_Tag)==1
      This_Tag=str2double(dd(i,t-9:t-8));
  end
  Tag_Sorter(i,1)=This_Tag;
 
  
end

[srt,imageorder]=sort(Tag_Sorter);

for i=1:numfiles

fn= sprintf('%s/%s',path,d(imageorder(i),1).name);
test=load('-mat', fn);
ROI_Data{i}=test;

end

for ggg=1:10
    
Slice_To_Analyze=inputdlg('Which Slice would you like to examine you ROCK STAR?');
slice=str2double(Slice_To_Analyze);
Image_Start=inputdlg('Which Image Numbers would you like to START on you amazing beast?');
Image_Start=str2double(Image_Start);
Image_Stop=inputdlg('Which Image Numbers would you like to STOP on you magnificent angel?');
Image_Stop=str2double(Image_Stop);
This_filename=ROI_Data{1,slice}.ROI_Composite_Data.FileName(1,1).FileName(slice);
Pia_Average(:,1)=ROI_Data{1,slice}.ROI_Composite_Data.Times(1,1).Times(1,:)';
White_Matter_Average(:,1)=ROI_Data{1,slice}.ROI_Composite_Data.Times(1,1).Times(1,:)';

for i=1:size(ROI_Data{1,slice}.ROI_Composite_Data.ROI.WhiteMatter,2)
    
   Pia_Average(:,i+1)=mean(ROI_Data{1,slice}.ROI_Composite_Data.ROI.Pia(1,i).Exposure(Image_Start:Image_Stop,:))';
   White_Matter_Average(:,i+1)=mean(ROI_Data{1,slice}.ROI_Composite_Data.ROI.WhiteMatter(1,i).Exposure(Image_Start:Image_Stop,:))';
    
end
savename_p=sprintf('%s/P_%d%s',path,slice,d(imageorder(slice),1).name);
savename_p=strrep(savename_p,'_ROI.mat','_Pia.txt');
save(savename_p,'Pia_Average','-ASCII');
savename_wm=sprintf('%s/WM_%d%s',path,slice,d(imageorder(slice),1).name);
savename_wm=strrep(savename_wm,'_ROI.mat','_WhiteMatter.txt');
save(savename_wm,'Pia_Average','-ASCII');


end