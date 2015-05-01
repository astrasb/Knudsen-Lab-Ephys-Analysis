%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Subtractive FL profiling for Redshirt imaging
%%%% This code will perform the following secquence of functions
%%%%    -Open a folder with a series of Redshirt Images
%%%%    -Split the images into channels and take the ratio
%%%%    -Filter high and low end noise 
%%%%    -Compute the stimulation time
%%%%    -Allow you to draw a mask of the slice
%%%%    -Normalize the images using a subtractive linear normalization
%%%%    -Allow you to rotate the image so that the cortex is aligned
%%%%        properly for compression
%%%%    - Vertically and horizontaly compress the first 50 time bins
%%%%    - Average all the time bins for the multiple images in the folder
%%%%    - Output a average and individual file for the compression
%%%%        profiling analysis
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
RotAlign='No';
Rot=0;
endclip=25;   % number of frames to clip off the front and back end to remove artifacts
VertAdjust=0;
HorizAdjust=0;

directory = uigetdir('/mnt/m022a/')

fd=dir(directory);
numdirectories=length(fd);
if numdirectories<1
    disp('No directories found');
end

for tt = 1:numdirectories-2
  t = length(getfield(fd,{tt+2},'name')) ;
  fdd(tt, 1:t) = getfield(fd,{tt+2},'name') ;
end

for hh=1:numdirectories-2
clear dd;

thisdir=sprintf('%s/%s',directory,fdd(hh,:));
path1=sprintf('%s/*.da',thisdir);
d = dir (path1);
numfiles=length(d);
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end

for i=1:numfiles
filename=sprintf('%s/%s',thisdir,dd(i,:));

[Images, filename, FrameTimes, TraceData, DarkFrame, FrameInterval]=SimpleRedShirtOpen(filename);

Images=Images(:,:,endclip:size(Images,3)-endclip);
FrameTimes=FrameTimes(:,endclip:size(Images,3)-endclip);
TraceData=TraceData(:,endclip:size(Images,3)-endclip);

ch1=Images(1:size(Images,1)/2,:,:);
ch2=Images(size(Images,1)/2+1:size(Images,1),:,:);

ch1tofit=squeeze(mean(mean(ch1)));
ch2tofit=squeeze(mean(mean(ch2)));

[Ch1,Ch2,VertAdjust,HorizAdjust]=Align_Redshirt(ch1, ch2, i, hh, VertAdjust, HorizAdjust);

ratio=Ch1./Ch2;

outliers_up=find(ratio>3);
outliers_down=find(ratio<1);
ratio_median=median(median(median(ratio)));

ratio(outliers_up)=ratio_median;
ratio(outliers_down)=ratio_median;

d_trace=diff(TraceData(1,:));
[stimtime stimloc]=min(d_trace);
stimframe=stimloc;

if ((i==1)&(hh==1))
image(ratio(:,:,stimframe+50),'cdatamapping','scaled')
maskpoly=impoly;
mask=maskpoly.createMask;
outside=find(mask<1);
end



%%% Subtractive normalization based on curve fit
ratio_norm=zeros(size(ratio,1),size(ratio,2),size(ratio,3));
ratio_start=ratio(:,:,1);
ratio_end=ratio(:,:,size(ratio,3));
contant_background=mean(mean(mean(ratio_start(size(ratio,1)/4:3*size(ratio,1)/4,size(ratio,2)/8:7*size(ratio,2)/8))));
   for j=1:size(ch1,3)
       
            ThisFrame=ratio(:,:,j);
                 
            TimeRelativeToStart=(size(ch1,3)-j+1)/size(ch1,3);
            TimeRelativeToEnd=1-TimeRelativeToStart;
            tempFrame=ratio_start*TimeRelativeToStart+ratio_end*TimeRelativeToEnd;
            NormFrame=ThisFrame-tempFrame+contant_background;
            ratio_norm(:,:,j)=NormFrame;
     end
ratio=ratio_norm;
for fr=1:size(ratio,3)
    tempframe=ratio(:,:,fr);
    tempframe(outside)=0;
    ratio(:,:,fr)=tempframe;
end




%[GaussianArrayImages]=Gaussian_Filter(CellArrayImages, MatrixSize, ThisExposure, GaussianValue);
%  [GaussianArrayImages]=Gaussian_Filter(GaussianArrayImages, MatrixSize, ThisExposure, GaussianValue);




if ((i==1)&(hh==1))
this_image_file=ratio(:,:,stimframe+100/FrameInterval);
while (strcmp(RotAlign,'No')==1)
    if (strcmp(RotAlign,'No')==1)
        prompt = {'Enter the degrees of Rotation                 '};
        dlg_title = 'Rotate Rotons             ';
        num_lines = 1;
        def = {num2str(Rot)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        Rot=str2num(answer{1,1});
        Peak_Rot_Tx=imrotate(this_image_file,Rot,'bilinear');
        image(Peak_Rot_Tx,'cdatamapping','scaled')
        colormap jet
        axis image;
        RotAlign=questdlg('Are you happy with the Rotational alignment','Registration Checkpoint');
    end
end
end
rotated=imrotate(ratio,Rot,'bilinear');





blank=sum(rotated(:,:,stimframe));
vertblank=sum(rotated(:,:,stimframe)');

profile=zeros(50,size(blank,2));
profilevert=zeros(50,size(vertblank,2));


for k=1:50
profile(k,:)=sum(rotated(:,:,stimframe+k-1))-blank;    
profilevert(k,:)=sum(rotated(:,:,stimframe+k-1)')-vertblank;
end

prof_horiz_ave(i,:,:)=profile;
prof_vert_ave(i,:,:)=profilevert;
text_f=sprintf('%sFL_profile_horiz.txt',filename(1:size(filename,2)-3));
text_f2=sprintf('%sFL_profile_vert.txt',filename(1:size(filename,2)-3));
save (text_f, 'profile', '-ascii','-tabs');
save (text_f2, 'profilevert', '-ascii','-tabs');

end
flavevert=squeeze(mean(prof_vert_ave));  
flavehoriz=squeeze(mean(prof_horiz_ave)); 
text_f3=sprintf('%sFL_profile_horiz_ave.txt',filename(1:size(filename,2)-8));
text_f4=sprintf('%sFL_profile_vert_ave.txt',filename(1:size(filename,2)-8));
save (text_f3, 'flavehoriz', '-ascii','-tabs');
save (text_f4, 'flavevert', '-ascii','-tabs');
end