path = uigetdir('/mnt/m022a'); 
ext='AIT';
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
differential_Peak=zeros(numfiles,1);
raw_Peak=zeros(numfiles,1);

for i=1:numfiles
fn= sprintf('%s/%s',path,d(imageorder(i),1).name);
test=load('-mat', fn);
differential_Peak(i,1)=max(test.dataout_AIT(3,:));
raw_Peak(i,1)=max(test.dataout_AIT(4,:));

end


    

