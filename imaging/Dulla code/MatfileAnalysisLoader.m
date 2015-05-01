directoryname = uigetdir('/mnt/m022a');

path1=sprintf('%s/*.mat',directoryname);
d = dir (path1);
numfiles=length(d);
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end

for thisfile = 20:numfiles
  filename=dd(thisfile,:)
  fullfilename=sprintf('%s/%s',directoryname,filename);
  [ThresholdDone]=MatFileAnalysis(fullfilename,directoryname);
end

