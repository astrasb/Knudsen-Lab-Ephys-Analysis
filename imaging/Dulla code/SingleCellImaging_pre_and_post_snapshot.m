%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Single Cell Glutamate Imaging                     %%%%%%
%%%%  Compiles multiple SIF files and averages them     %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
shutterbuffersize=10;           %%% the number of frames to clip beyond/befor shutter open/close
startfit=130;
endfit=600;
[RGBCustom]=CreateRGBColorTableInverted;

%%%% Choose a folder with multple images from 1 cell
directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
path1dir=sprintf('%s/*Untit*',directoryname);
ddir = dir (path1dir);                                                   
numfiles=length(ddir);
if numfiles<1
    disp('No files found');
end

%%%%  Create a variable with all the folder names
for i = 1:numfiles
    t = length(getfield(ddir,{i},'name')) ;
    filelist(i, 1:t) = getfield(ddir,{i},'name') ;                      %%%% filelist contains the list of sif files
end

for this_image=1:numfiles
clear fn;   
fn=sprintf('%s/%s',directoryname,filelist(this_image,:));
[Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(fn)
temp=Image.data;
exposuretime=InstaImage.exposure_time;   

%%% Detect shutter times
shutterdetect=squeeze(diff(mean(mean(temp))));

%%%% Split Data into Pre and Post Activation
opens=find(shutterdetect>200);
closes=find(shutterdetect<-200);

if size(opens,1)>2
    opens=[opens(1,1); opens(size(opens,1))];
end 
    
if size(closes)>2
    closes=[closes(1); closes(size(closes,1))];
end

pre_data=temp(:,:,opens(1,1)+shutterbuffersize:closes(1,1)-shutterbuffersize);
post_data=temp(:,:,opens(2,1)+shutterbuffersize:closes(2,1)-shutterbuffersize);

if size(pre_data,3)==size(post_data,3)
    equalsizes(this_image)=1;
else
    equalsize(this_image)=0;
    if size(pre_data,3)>size(post_data,3)
        correction=size(pre_data,3)-size(post_data,3);
        pre_data(:,:,size(pre_data,3)-correction:size(pre_data,3))=[];
    else
       correction=size(post_data,3)-size(pre_data,3);
       post_data(:,:,size(post_data,3)-correction:size(post_data,3))=[]; 
    end
end

%%% Subtract darkframe
darkframe=FrameAverage(temp,1,opens(2,1)-shutterbuffersize);
temp_darksubtracted_pre=zeros(size(temp,1),size(temp,2),size(pre_data,3));
temp_darksubtracted_post=zeros(size(temp,1),size(temp,2),size(post_data,3));

for i=1:size(pre_data,3)
tpre=pre_data(:,:,i);
temp_darksubtracted_pre(:,:,i)=tpre-darkframe;            %%temp_darksubtracted_pre has the data now
tpost=post_data(:,:,i);
temp_darksubtracted_post(:,:,i)=tpost-darkframe;            %%temp_darksubtracted_post has the data now


end

%%%%% Breaking up Ch1 and Ch2
Aligned='No';
VertAdjust=0;
HorizAdjust=0;
ch1pre=temp_darksubtracted_pre(1:64,:,:);
ch2pre=temp_darksubtracted_pre(65:128,:,:);
ch1post=temp_darksubtracted_post(1:64,:,:);
ch2post=temp_darksubtracted_post(65:128,:,:);

ratio_pre=ch1pre./ch2pre;
ratio_post=ch1post./ch2post;
final=ratio_post-ratio_pre;
if this_image==1
group_ratio_pre=zeros(size(ratio_pre,1), size(ratio_pre,2), size(ratio_pre,3));
group_ratio_post=zeros(size(ratio_post,1), size(ratio_post,2), size(ratio_post,3));
group_final=zeros(size(ratio_post,1), size(ratio_post,2), size(ratio_post,3));
end
group_final=group_final+final;
group_ratio_pre=group_ratio_pre+ratio_pre;
group_ratio_post=group_ratio_post+ratio_post;
ind_ratios_pre(:,this_image)=squeeze(mean(mean(ratio_pre)));
ind_ratios_post(:,this_image)=squeeze(mean(mean(ratio_post)));
end
Averaged_movie_pre=group_ratio_pre/numfiles;
Averaged_movie_post=group_ratio_post/numfiles;

