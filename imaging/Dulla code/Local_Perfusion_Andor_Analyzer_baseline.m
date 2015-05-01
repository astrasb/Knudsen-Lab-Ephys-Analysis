%%%%%%%%  Analyzing Andor Slow Calibration Files %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Use this program to open, draw roi's and compute ratio/time
%  courses for slow (1 image every 10 secs) local perfursion
% calibration files with darkfield subtraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%keep ratiotracker;
clear all;

[RGBCustom]=CreateRGBColorTable;

Happiness=questdlg('Please Select your local perfusion Andor File','GOULET INC');
[Image,InstaImage,CalibImage,vers,PathName,FileName]=andorread_chris_local()
temp=Image.data;
exposuretime=InstaImage.exposure_time;

Happiness=questdlg('Please Select your local perfusion Andor DARKFIELD File','GOULET INC');
[DarkImage,DarkInstaImage,DarkCalibImage,Darkvers,DarkPathName,DarkFileName]=andorread_chris_local()

dark=DarkImage.data;
dark_Image=FrameAverage(dark,1,size(dark,3)-1);

for i=1:size(temp,3)
    tempframe=temp(:,:,i);
    tempframe=tempframe-dark_Image;
    temp(:,:,i)=tempframe;

end

%%%%% Realignment of raw channels
Aligned='No';
VertAdjust=0;
HorizAdjust=0;
ch1=temp(1:64,:,:);
ch2=temp(65:128,:,:);



if 2<1
    while (strcmp(Aligned,'No')==1)
        pad=ones(size(ch1,1),abs(VertAdjust),size(ch1,3));
        if size(pad,2)>0
        ch2test=[pad,ch2];
        ch1test=[ch1, pad];
        else
        ch2test=[ch2,pad];
        ch1test=[pad,ch1]; 
        end
        padtop=ones(abs(HorizAdjust),size(ch2test,2),100);
        if size(padtop,1)>0
        ch1test=[ch1test;padtop];
        ch2test=[padtop;ch2test];
        else
        ch1test=[padtop;ch1test];
        ch2test=[ch2test;padtop];  
        end
       
        testratio=ch1test(:,:,10)./ch2test(:,:,10);
        %testratio(outside)=0;
        oversat=find(testratio>5);
        testratio(oversat)=5;
        undersat=find(testratio<1);
        testratio(undersat)=1;
        image(testratio,'cdatamapping','scaled')
        axis image;
         Aligned=questdlg('Are you happy with the alignment','Registration Checkpoint');
            if (strcmp(Aligned,'No')==1)
                prompt = {'Enter vertical adjustment                 ','Enter Horizonatal adjustment                  '};
                dlg_title = 'Adjust Registration              ';
                num_lines = 1;
                def = {num2str(VertAdjust),num2str(HorizAdjust)};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                VertAdjust=str2num(answer{1,1});
                HorizAdjust=str2num(answer{2,1});
            end
    end
    ch1=ch1test;
    ch2=ch2test;
    close;
end

        



if 2>1

end
ratio=ch1./ch2;
[AveragedFrame]=FrameAverage(ratio, 2, 5);
AveragedFrame(62:64,:,:)=0;
findhigh=find(AveragedFrame>5)
AveragedFrame(findhigh)=5;
findlow=find(AveragedFrame<1)
AveragedFrame(findlow)=1.5;

image(AveragedFrame,'cdatamapping','scaled')
axis image;
colorbar('location','eastOutside')
box off;
axis off;
subplot(3,1,1)
plot(squeeze(mean(mean(ratio))));
subplot(3,1,2)
plot(squeeze(mean(mean(ch1))));
subplot(3,1,3)
plot(squeeze(mean(mean(ch2))));
close

normsingle=FrameAverage(ratio, 15,20);
normredraw=normsingle;
overload=find(normredraw>5);
underload=find(normredraw<1);
normredraw(overload)=5;
normredraw(underload)=1;
image(normredraw,'cdatamapping','scaled')
Happiness=questdlg('Draw the mask of the slice','GOULET INC');
mask=roipoly;
inside=find(mask==1);
outside=find(mask==0);



normframe=zeros(size(ratio,1),size(ratio,2),size(ratio,3));
for i=1:size(ratio, 3)
    tframe=ratio(:,:,i);
    normframetemp=tframe-normsingle;
    normframetemp(outside)=0;
    normframe(:,:,i)=normframetemp;
end





if 2>1

%Happiness=questdlg('Trace the Sulcus','GOULET INC'); 
%sulcus=roipoly;
Happiness=questdlg('Trace the PMZ','GOULET INC');
pmz=roipoly;
%Happiness=questdlg('Trace the region outside the PMZ','GOULET INC');
%outsidepmz=roipoly;
for i=1:size(ratio,3)
    thisimage=normframe(:,:,i);
    thisimageraw=ratio(:,:,i);
    thisch1=ch1(:,:,i);
    thisch2=ch2(:,:,i);
    %out_roi(1,i)=mean(thisimage(sulcus));
    %out_roi(4,i)=mean(thisimageraw(sulcus));
    out_roi(1,i)=mean(thisimage(pmz));
    out_roi(2,i)=mean(thisimageraw(pmz));
    out_roi(3,i)=mean(thisch1(pmz));
    out_roi(4,i)=mean(thisch2(pmz));
    %out_roi(3,i)=mean(thisimage(outsidepmz));
    %out_roi(6,i)=mean(thisimageraw(outsidepmz));
    
    time(1,i)=i;
end
end
ROI_values_out=sprintf('%sroi_out.txt',PathName);

save (ROI_values_out, 'out_roi', '-ascii','-tabs');

temp=normframe(:,:,1);
%temp(sulcus)=1.2;
temp(pmz)=1.4;
%temp(outsidepmz)=1.6;
image(temp,'cdatamapping','scaled')

ROI_Picture_Filename=sprintf('%sROI_Map.jpg',PathName);
%roifiles=sprintf('%sRois.mat',PathName);
saveas(gcf, ROI_Picture_Filename);
close all;
%save(roifiles,'out_roi');

