function [andorscaled, cookscaled, L_R_OffsetFactor, U_D_OffsetFactor]=registration_test_calcium(Andor_Images, path, ScaleFactor, L_R_OffsetFactor, U_D_OffsetFactor, andormin, andormax) 
Andor=Andor_Images;

%Open Brightfield tiff from Cooke Camera
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
disp(fna);
fnc= sprintf('%s/%s.%s',path,fna,ext);
cookcam=imread(fnc);
cookcam=single(cookcam);
Intensityscalefactor=max(max(Andor(2*(size(Andor,1))/4:3*(size(Andor,1))/4,2*(size(Andor,2))/4:3*(size(Andor,2))/4)))/max(max(cookcam(500:600,500:600)));
cookeflipped=cookcam';
cookcam_scaled=cookeflipped*Intensityscalefactor;

% Define Scale Parameters
scalematrix=[ScaleFactor 0 0
              0 ScaleFactor 0
              0 0 1];
          
txmatrix=[1 0 0
          0 1 0
          L_R_OffsetFactor U_D_OffsetFactor 1];        
scform=maketform('affine',scalematrix);
txform=maketform('affine',txmatrix);

%Scale Andor image into 0-128 Range


andorhist=reshape(Andor,1,[]);
andor_sd=std(andorhist);
andor_mean=mean(andorhist);
andormin=0;
andormax=andor_mean+2*andor_sd;
Andor=Andor*128/andormax;
andor_sat=find(Andor>128);
andorscaled_128(andor_sat)=128;
andor_undersat=find(Andor<0);
Andor(andor_undersat)=0;


% Scale Up Andor Images Based on Scale Factors
Andor=imresize(Andor, ScaleFactor);

% Create buffer padz for cook image translocation
L_R_Pad=zeros(size(cookcam_scaled,1),abs(L_R_OffsetFactor));

if L_R_OffsetFactor~=0
if L_R_OffsetFactor>0
   cookcam_scaled=[cookcam_scaled L_R_Pad ]; 
else
   cookcam_scaled=[ L_R_Pad cookcam_scaled];
end
end
if U_D_OffsetFactor~=0
if U_D_OffsetFactor>0
   U_D_Pad=zeros(abs(U_D_OffsetFactor),size(cookcam_scaled,2));
   cookcam_scaled=[U_D_Pad; cookcam_scaled]; 
else
   U_D_Pad=zeros(abs(U_D_OffsetFactor),size(Andor,2));
   Andor=[U_D_Pad; Andor];
end
end

% Get Scaling Values for Andor and Cooke Color Schemes
imageROIave=mean(mean(Andor(size(Andor,1)/3:2*size(Andor,1)/3,size(Andor,2)/3:2*size(Andor,2)/3)));
cook_sd=mean(mean(std(cookcam_scaled)));
cook_mean=mean(mean(mean(cookcam_scaled)));

%Scale Cooke image into 0-128 Range
cookmax=cook_mean+2*cook_sd;
cookscaled_128=cookcam_scaled*128/cookmax;
cook_saturated=find(cookscaled_128>128);
cookscaled_128(cook_saturated)=128;

% Adjust Rescaled Andor to Match Cooke size format
x_adjust=size(cookscaled_128,2)-size(Andor,2);
if x_adjust>0
x_pad=zeros(size(Andor,1),x_adjust,size(Andor,3));
Andor=[Andor x_pad];
else
    x_adjust=-x_adjust;
    x_pad=zeros(size(cookscaled_128,1),x_adjust);
    cookscaled_128=[cookscaled_128 x_pad];
    end
y_adjust=size(cookscaled_128,1)-size(Andor,1);
y_pad=zeros(y_adjust, size(cookscaled_128,2),size(Andor,3));
Andor=[Andor; y_pad];


repositionedslice=find(Andor>0);
Andor(repositionedslice)=Andor(repositionedslice)+128;

threshold=find(Andor>129);


combined=zeros(size(Andor));

for i=1:size(combined,3)
   combined(:,:,i)=cookscaled_128;   
end

combined(threshold)=Andor(threshold);
andorscaled=Andor;
cookscaled=cookscaled_128;
[BW_RGBCustom]=CreateBW_RGBColorTable_inverted;
image(combined,'cdatamapping','direct')
colormap(BW_RGBCustom)
box off
axis off
cookscaled=cookcam_scaled;
end