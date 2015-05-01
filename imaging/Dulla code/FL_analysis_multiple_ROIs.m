path='/mnt/m022a/FL to analyze tonight/';
ext='ROI';
path1=sprintf('%s/*%s*',path,ext);
d = dir (path1);
numfiles=length(d);
directoryname=path;
if numfiles<1
    disp('No files found');
end
 for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end

Lat_ROI=zeros(numfiles,100);
Med_ROI=zeros(numfiles,100);
Bottom_ROI=zeros(numfiles,100);
Lat_roi_sub=zeros(numfiles,100);
Med_ROI_sub=zeros(numfiles,100);
Bottom_ROI_sub=zeros(numfiles,100);
for i=1:numfiles
   FL_s_point=[23,23,29,28,25,23,33,31,33,26,26,28,24,31];
   % Contralater FL_s_point=[26, 23, 26, 27, 25, 28, 21, 23, 32, 33];
   path2=sprintf('%s%s',path,dd(i,:));
   thisfile=load(path2);
   Lat_ROI(i,:)=thisfile(1,:);
   Med_ROI(i,:)=thisfile(2,:);
   Bottom_ROI(i,:)=thisfile(3,:);
   meanL=mean(Lat_ROI(i,FL_s_point(i)));
   meanB=mean(Bottom_ROI(i,FL_s_point(i)));
   meanM=mean(Med_ROI(i,FL_s_point(i)));
   Lat_ROI_sub(i,:)=thisfile(1,:)-meanL;
   Med_ROI_sub(i,:)=thisfile(2,:)-meanM;
   Bottom_ROI_sub(i,:)=thisfile(3,:)-meanB;
end

%%% Padding the front end to aling washin

maxpad=max(FL_s_point)-min(FL_s_point);
maxstart=max(FL_s_point);
Lat_ROI_p=zeros(numfiles,100+maxpad);
Med_ROI_p=zeros(numfiles,100+maxpad);
Bottom_ROI_p=zeros(numfiles,100+maxpad);
Lat_roi_sub_p=zeros(numfiles,100+maxpad);
Med_ROI_sub_p=zeros(numfiles,100+maxpad);
Bottom_ROI_sub_p=zeros(numfiles,100+maxpad);

for i=1:numfiles
    padtest=maxstart-FL_s_point(i);
    padend=maxpad-padtest;
    for j=1:padtest
       Lat_ROI_p(i,j)=Lat_ROI(i,1); 
       Med_ROI_p(i,j)=Med_ROI(i,1);
       Bottom_ROI_p(i,j)=Bottom_ROI(i,1);
       Lat_ROI_sub_p(i,j)=Lat_ROI_sub(i,1); 
       Med_ROI_sub_p(i,j)=Med_ROI_sub(i,1);
       Bottom_ROI_sub_p(i,j)=Bottom_ROI_sub(i,1);
    end
    for j=padtest+1:100+padtest
     Lat_ROI_p(i,j)=Lat_ROI(i,j-padtest);
     Med_ROI_p(i,j)=Med_ROI(i,j-padtest);
     Bottom_ROI_p(i,j)=Bottom_ROI(i,j-padtest);
     Lat_ROI_sub_p(i,j)=Lat_ROI_sub(i,j-padtest); 
     Med_ROI_sub_p(i,j)=Med_ROI_sub(i,j-padtest);
     Bottom_ROI_sub_p(i,j)=Bottom_ROI_sub(i,j-padtest);
    end
    
    for j=100+padtest+1:100+padend
     Lat_ROI_p(i,j)=Lat_ROI(i,100); 
     Med_ROI_p(i,j)=Med_ROI(i,100);
     Bottom_ROI_p(i,j)=Bottom_ROI(i,100);
     Lat_ROI_sub_p(i,j)=Lat_ROI_sub(i,100); 
     Med_ROI_sub_p(i,j)=Med_ROI_sub(i,100);
     Bottom_ROI_sub_p(i,j)=Bottom_ROI_sub(i,100);
    end
      
end




text_f=sprintf('%sbottomroi.txt',path);
save (text_f, 'Bottom_ROI_p', '-ascii','-tabs');
text_f=sprintf('%sMedroi.txt',path);
save (text_f, 'Med_ROI_p', '-ascii','-tabs');
text_f=sprintf('%sLatroi.txt',path);
save (text_f, 'Lat_ROI_p', '-ascii','-tabs');

text_f=sprintf('%sbottomroi_sub.txt',path);
save (text_f, 'Bottom_ROI_sub_p', '-ascii','-tabs');
text_f=sprintf('%sMedroi_sub.txt',path);
save (text_f, 'Med_ROI_sub_p', '-ascii','-tabs');
text_f=sprintf('%sLatroi_sub.txt',path);
save (text_f, 'Lat_ROI_sub_p', '-ascii','-tabs');

