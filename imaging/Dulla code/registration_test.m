function [OutImage, andorscaled, cookscaled, txmatrix]=registration_test(fn,path, ScaleFactor, OffsetFactor)
[Image,InstaImage,CalibImage,vers]=andorread_chris_local(fn);
ext='tif';
path1=sprintf('%s/*.%s',path,ext);
disp(path);
d = dir (path1);
numfiles=length(d);
directoryname=path;
if numfiles<1
    disp('No bright field files found');
end
if numfiles>1
    disp('Too Many Brightfield Images')
end
for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end
fna=dd(1,:);
 
  fna=strtok(fna,'.');
  %fna=fna(1:length(fna)-4);
disp(fna);
%fna='eeg3';
fnc= sprintf('%s/%s.%s',path,fna,ext);

cookcam=imread(fnc);
cookcam=single(cookcam);
Intensityscalefactor=max(max(Image.data(50:60,50:60)))/max(max(cookcam(500:600,500:600)));
andor=Image.data';
cookcam_scaled=cookcam*Intensityscalefactor;
scalematrix=[ScaleFactor 0 0
              0 ScaleFactor 0
              0 0 1];
txmatrix=[1 0 0
          0 1 0
          OffsetFactor OffsetFactor 1];   
scform=maketform('affine',scalematrix);
txform=maketform('affine',txmatrix);

if 2<1
cookscaled=imtransform(cookcam_scaled, scform);
cookscaled=imtransform(cookscaled, txform, 'Xdata',[1 (size(cookscaled,2)+txmatrix(3,1))],'Ydata', [1 (size(cookscaled,1)+txmatrix(3,2))],'FillValues', 0);
end
andorscaled=imresize(andor, ScaleFactor);
andorscaled=imtransform(andorscaled, txform, 'Xdata',[1 (size(andorscaled,2)+txmatrix(3,1))],'Ydata', [1 (size(andorscaled,1)+txmatrix(3,2))],'FillValues', 0);
transmatrix=[1 0 0; 0 1 0; 0 0 1];
forcetoandor=maketform('affine', transmatrix);
%andorscaled=imtransform(andorscaled, forcetoandor,'size', [size(cookcam_scaled, 1) size(cookcam_scaled, 2)]);

OutImage=figure (1)
if 2<1
image(andor,'cdatamapping','scaled');
end
image(andorscaled,'cdatamapping','scaled');
axis image;
colormap gray;
hold on;
if 2<1
h=image(cookcam_scaled,'cdatamapping','scaled');
end
h=image(cookcam_scaled,'cdatamapping','scaled');
set(h, 'AlphaData', 0.4);
hold off;
andorscaled=andorscaled;
cookscaled=cookcam_scaled;
end