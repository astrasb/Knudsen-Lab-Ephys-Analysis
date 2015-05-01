%%%%%%  Opens 
%%%%%%          SR101 compiled maps
%%%%%%          

clear all
close all


%%%%%%  Points to a file to process
[ Path]=uigetdir('/mnt/m022a/SR101_FL');
[ Path2]=dirr(Path);
for this_compiled_map=1:size(Path2,1)
    found=0;
    while found==0
        for checking=1:size(Path2(this_compiled_map,1).isdir,1)
           check=strfind(Path2(this_compiled_map,1).isdir(checking,1).name, 'ompiled')
           if isempty(check)
               cool=0;
           else
               fn=sprintf('%s/%s/%s', Path,Path2(this_compiled_map,1).name,Path2(this_compiled_map,1).isdir(checking,1).name);
               found=1;
           end
    
        end
    end
%[ Path, directoryname]=uigetfile('/mnt/m022a/');
[BW_RGBCustom]=CreateBW_RGBColorTable_inverted;





cdata=imread(fn);
if size(cdata,3)>1
    cdata(:,:,1)=[];
    cdata(:,:,2)=[];
end
   



%%%Look for preprocessed image data 
fn2=sprintf('%s/%s*BinaryMap*', Path,Path2(this_compiled_map,1).name);
PreProcessed_dir = dir (fn2);
PreProcessed_dir_L=length(PreProcessed_dir);
fn4=sprintf('%s/%s*blobProps*', Path,Path2(this_compiled_map,1).name);
PreProcessed_dir4 = dir (fn4);
if PreProcessed_dir_L<1
    disp('Preprocessed Image Data Not Found');
    
else
    P_Bin_Map=open(sprintf('%s/%s/%s', Path,Path2(this_compiled_map,1).name, PreProcessed_dir.name));
    labeledImageR=P_Bin_Map.labeledImageR;
    coloredLabelsR = label2rgb (labeledImageR, 'hsv', 'k', 'shuffle'); % pseudo random color labels

      
    P_blobs=open(sprintf('%s/%s/%s', Path,Path2(this_compiled_map,1).name, PreProcessed_dir4.name));
    blobMeasurementsR=P_blobs.blobMeasurementsR;
    DataFound=1;
end

%%%%% Removing ROI Aspect from processing for batch 

ROIsOn=0;

if ROIsOn==1

%%%Look for existing ROI's
fn2=sprintf('%s/%s/*ROIMaps*', Path,Path2(this_compiled_map,1).name);
PreProcessed_dir = dir (fn2);
PreProcessed_dir_L=length(PreProcessed_dir);
if PreProcessed_dir_L<1
    disp('No existing ROI File');
    
else
    P_ROI_Map=open(sprintf('%s/%s/%s', Path,Path2(this_compiled_map,1).name, PreProcessed_dir.name));
    map=P_ROI_Map.map;
    ROIFound=1;
    ROIcounter=0;
    outofROIs=0;
while outofROIs==0;
    for check=1:50
        tt=find(map==check*10);
        
        if size(tt,1)>2
            ROIcounter=ROIcounter+1;
        else
            outofROIs=1;
        end
    end
end
  glia_counts=zeros(1,ROIcounter);  
end
end


%%% Creating multiple copies of the original data set for processing
b=cdata;
c=cdata;
d=zeros(size(cdata,1),size(cdata,2));


%%% Apply gausian filter
for i=1:500
    d=Gaussian_Filter_streamlined(b,5,0.5);
    b=d;
    i
    
    if i==100
        pause=1;
        b=uint8(b);
        tempblur1=c-b;
        image(tempblur1,'cdatamapping','scaled')
        axis image
    end
    
      if i==200
        pause=1;
        b=uint8(b);
        tempblur2=c-b;
        image(tempblur2,'cdatamapping','scaled')
        axis image
      end
    
        if i==300
        pause=1;
        b=uint8(b);
        tempblur3=c-b;
        image(tempblur3,'cdatamapping','scaled')
        axis image
        end
        
        if i==400
        pause=1;
        b=uint8(b);
        tempblur4=c-b;
        image(tempblur4,'cdatamapping','scaled')
        axis image
    end
end

%%% subtract blurred data from original data
b=uint8(b);
s=c-b;

%%% Salt and Pepper Filtering
L = medfilt2(s,[3 3]);
q=L;

%%% Tresholding Subtracted image
gg=find(q>30);
q(gg)=0;

figure(2)
image(q,'cdatamapping','scaled')
axis image;

%%% Blob analysis
thresholdValue = 2;
binaryImage = q > thresholdValue; 
%binaryImage = imfill(binaryImage, 'holes');
% Display the binary image.
imagesc(binaryImage); colormap(gray(256)); title('Binary Image, obtained by thresholding'); axis image;
labeledImage = bwlabel(binaryImage, 8);     % Label each blob so we can make measurements of it
coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
blobMeasurements = regionprops(labeledImage, cdata, 'all');   
numberOfBlobs = size(blobMeasurements, 1);
binaryImageCorrected=binaryImage;
redone=binaryImage;

%%% Removing Blob Artifacts (blobs which are too large)
for i=1:size(blobMeasurements,1)
    if blobMeasurements(i,:).Area>200
    [xloc]=blobMeasurements(i,:).BoundingBox(1,1)-0.5;
    [yloc]=blobMeasurements(i,:).BoundingBox(1,2)-0.5;
    [xsize]=blobMeasurements(i,:).BoundingBox(1,3);
    [ysize]=blobMeasurements(i,:).BoundingBox(1,4);
        
    ycomp=yloc-ysize;
    xcomp=xloc-xsize;   
    
    if ycomp<size(binaryImage,1)
       thisarea=blobMeasurements(i,:).Image;
       left_pad=zeros(ysize, xloc);
       right_pad=zeros(ysize,size(binaryImage,2)-xloc-xsize);
       outarea=[left_pad,thisarea, right_pad];
    end
    
    if xcomp<size(binaryImage,2)
      top_pad=zeros(yloc,size(outarea,2));
      bottom_pad=zeros(size(binaryImage,1)-yloc-size(outarea,1),size(outarea,2));
      finalreplacer=[top_pad;outarea;bottom_pad];   
        
    end
      redone=redone-finalreplacer;  
    end
end

%%% Erode filtered image
se = strel('disk',1);        
redone = imerode(redone,se);

%%% Redo Blob analysis
imagesc(redone); colormap(gray(256)); title('Binary Image, obtained by thresholding'); axis image;
labeledImageR = bwlabel(redone, 8);     % Label each blob so we can make measurements of it
coloredLabelsR = label2rgb (labeledImageR, 'hsv', 'k', 'shuffle'); % pseudo random color labels

% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
blobMeasurementsR = regionprops(labeledImageR, cdata, 'all');   
numberOfBlobsR = size(blobMeasurementsR, 1);



%%% Show the filetered image for labeling the Freeze Lesion
figure(1)
image(coloredLabelsR,'cdatamapping','scaled');
axis image

if ROIsOn==1

happy=questdlg('Please Label the Freeze Lesion');
FL=roipoly;
 

sd=coloredLabelsR;
sd(FL)=100;

DataFound=1;


image(coloredLabelsR,'cdatamapping','scaled');
axis image;
axis off;
complete=0;
counter=1;
ROIFound=0;
while ROIFound==0;
while complete==0;
    happy=questdlg('Please draw 3 Rois Lateral to the FL (First ROI - most superficial)');
    for co=1:3
    
    M1=impoint;
    M1=floor(getPosition(M1));
    M1z=zeros(size(coloredLabelsR,1),size(coloredLabelsR,2));
    M1z(M1(1,2)-50:M1(1,2)+50,M1(1,1)-50:M1(1,1)+50)=1;
    M1roi(counter,:)=find(M1z==1);
    sd(M1roi(counter))=100;
    counter=counter+1;
    end
     happy=questdlg('Please draw 3 Rois Medial to the FL (First ROI - most superficial)');
    for co=1:3
   
    M1=impoint;
    M1=floor(getPosition(M1));
    M1z=zeros(size(coloredLabelsR,1),size(coloredLabelsR,2));
    M1z(M1(1,2)-50:M1(1,2)+50,M1(1,1)-50:M1(1,1)+50)=1;
    M1roi(counter,:)=find(M1z==1);
    sd(M1roi(counter))=100; 
    counter=counter+1;
    end
    
    dd=questdlg('Would you like to add more ROIs?');
    if strcmp(dd,'No')
        complete=1;
    end
    
    if counter>24
        complete=1;
    end
    
end
map=zeros(size(coloredLabelsR,1),size(coloredLabelsR,2));
for t=1:size(M1roi,1)
map(M1roi(t,:))=t*10;
end
glia_counts=zeros(1,size(M1roi,1));
ROIFound=1;
end


end
singlemap=zeros(size(labeledImageR,1),size(labeledImageR,2));
for i =1:size(blobMeasurementsR,1)
 thisone=floor(blobMeasurementsR(i,1).BoundingBox(1,2));
 thistwo=floor(blobMeasurementsR(i,1).BoundingBox(1,1));
 
 if thisone==0
     thisone=1;
 end
 if thistwo==0;
     thistwo=1;
 end
 
 singlemap(thisone,thistwo)=1;
end

if ROIsOn==1
combinedmap=singlemap+map;

exist ROIcounter;
if ans==0
ROIcounter=size(M1roi,1);
end
for tg=1:ROIcounter
        fg=find(combinedmap==(tg*10+1));
        
        if fg>0
            glia_counts(1,tg)=glia_counts(1,tg)+size(fg,1);
        end
end
end
%%% Drawing an outline of the slice to count pixels
border_m=mean(mean(cdata));
border_std=std(std(double(cdata)));
border_map=find(cdata>(border_m-4*border_std));
average_density=size(blobMeasurementsR,1)/size(border_map,1);

compression_size=25;
scale_factor=compression_size^2*average_density;
for sub_h=1:floor(size(singlemap,1)/compression_size)
    
for sub_v=1:floor(size(singlemap,2)/compression_size)
    thisspot(sub_h,sub_v)=size(find(singlemap(((sub_h*compression_size)-compression_size+1):((sub_h*compression_size)), ((sub_v*compression_size)-compression_size+1):((sub_v*compression_size)))==1),1)/scale_factor;
    thisspot_raw(sub_h,sub_v)=size(find(singlemap(((sub_h*compression_size)-compression_size+1):((sub_h*compression_size)), ((sub_v*compression_size)-compression_size+1):((sub_v*compression_size)))==1),1);
    
    
end

end


compression_size=10;
scale_factor=compression_size^2*average_density;
for sub_h=1:floor(size(singlemap,1)/compression_size)
    
for sub_v=1:floor(size(singlemap,2)/compression_size)
    thisspot_S(sub_h,sub_v)=size(find(singlemap(((sub_h*compression_size)-compression_size+1):((sub_h*compression_size)), ((sub_v*compression_size)-compression_size+1):((sub_v*compression_size)))==1),1)/average_density;
    thisspot_raw_S(sub_h,sub_v)=size(find(singlemap(((sub_h*compression_size)-compression_size+1):((sub_h*compression_size)), ((sub_v*compression_size)-compression_size+1):((sub_v*compression_size)))==1),1);
    
    
end

end

thisspot_G=Gaussian_Filter_streamlined(thisspot, 5, .9);
thisspot_G_raw=Gaussian_Filter_streamlined(thisspot_raw, 5, .9);
thisspot_G_S=Gaussian_Filter_streamlined(thisspot_S, 5, .9);
thisspot_G_S_raw=Gaussian_Filter_streamlined(thisspot_raw_S, 5, .9);

if ROIsOn==1

fn=sprintf('%s/%s/Glial_Counts',Path,Path2(this_compiled_map,1).name);
save(fn,'glia_counts');
fn=sprintf('%s/s/ROIMaps',Path,Path2(this_compiled_map,1).name);
save(fn,'map');
fn=sprintf('%s/%s/CombinedMap',Path,Path2(this_compiled_map,1).name);
save(fn,'combinedmap');
end




fn=sprintf('%s/%s/BinaryMap',Path,Path2(this_compiled_map,1).name);
save(fn,'labeledImageR');

fn=sprintf('%s/%s/blobProps',Path,Path2(this_compiled_map,1).name);
save(fn,'blobMeasurementsR');



fn=sprintf('%s/%s/AverageIntensity',Path,Path2(this_compiled_map,1).name);
save(fn,'thisspot_G');

fn=sprintf('%s/%s/RawIntensity',Path,Path2(this_compiled_map,1).name);
save(fn,'thisspot_G_raw');

fn=sprintf('%s/%s/AverageIntensity_small',Path,Path2(this_compiled_map,1).name);
save(fn,'thisspot_G');

fn=sprintf('%s/%s/RawIntensity_small',Path,Path2(this_compiled_map,1).name);
save(fn,'thisspot_G_S_raw');
if ROIsOn==1

figure(1)
image(labeledImageR,'cdatamapping','scaled')
axis image
axis off
ROI_Picture_Filename=sprintf('%s/%s/GlialMap.jpg',Path,Path2(this_compiled_map,1).name);  
saveas(gcf, ROI_Picture_Filename);


figure(2)
image(combinedmap,'cdatamapping','scaled')
axis image;
axis off;
ROI_Picture_Filename=sprintf('%s/%s/ROIMap.jpg',Path,Path2(this_compiled_map,1).name);  
saveas(gcf, ROI_Picture_Filename);
end
figure(3)


tt=find(labeledImageR>1);
labeledImageR(tt)=1;
image(labeledImageR,'cdatamapping','scaled')
axis image
axis off
colormap(hot)
ROI_Picture_Filename=sprintf('%s/%s/GlialMap_binary.jpg',Path,Path2(this_compiled_map,1).name);  
saveas(gcf, ROI_Picture_Filename);

figure(4)
thisspot_G=Gaussian_Filter_streamlined(thisspot, 5, .9);
image(thisspot_G,'cdatamapping','scaled');
axis image
axis off
ROI_Picture_Filename=sprintf('%s/%s/AverageMap.jpg',Path,Path2(this_compiled_map,1).name);  
saveas(gcf, ROI_Picture_Filename);

figure(4)

image(thisspot_G_raw,'cdatamapping','scaled');
axis image
axis off
ROI_Picture_Filename=sprintf('%s/%s/AverageMap_raw.jpg',Path,Path2(this_compiled_map,1).name);  
saveas(gcf, ROI_Picture_Filename);

figure(4)

image(thisspot_G_S,'cdatamapping','scaled');
axis image
axis off
ROI_Picture_Filename=sprintf('%s/%s/AverageMap_smalled_scale_factor.jpg',Path,Path2(this_compiled_map,1).name);  
saveas(gcf, ROI_Picture_Filename);

figure(4)
thisspot_G=Gaussian_Filter_streamlined(thisspot, 5, .9);
image(thisspot_G_S_raw,'cdatamapping','scaled');
axis image
axis off
ROI_Picture_Filename=sprintf('%s/%s/AverageMap_small_and_raw.jpg',Path,Path2(this_compiled_map,1).name);  
saveas(gcf, ROI_Picture_Filename);
close all
keep this_compiled_map Path Path2;
    end

