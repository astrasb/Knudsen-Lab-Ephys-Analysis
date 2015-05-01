%%%%%%%%  Hippocampal Glutamate Imaging          %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%edited by CAG 5/2010
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
parameters_present=0;
[RGBCustom]=CreateRGBColorTableInverted;

%%% Get the directory of interest - it should contain a subfolder for each
%%% experimental condition and a brightfield sif image and a .abf file
directoryname = uigetdir('/mnt/farva/imaging');

%%% Open the brightfield file
bright_dir=sprintf('%s/*bright*',directoryname);
B_dir = dir (bright_dir);
B_numfilesdir=length(B_dir);
if B_numfilesdir<1
    disp('No brightfield file found');
end
B_fn=sprintf('%s/%s',directoryname,B_dir.name);
[B_Image,B_InstaImage,B_CalibImage,B_vers]=andorread_chris_local_knownfilename(B_fn)
Bright=B_Image.data;
Bright=Bright(1:64,:);

%%% Open the ABF file
abf_dir=sprintf('%s/*.abf',directoryname);
ABF_dir = dir (abf_dir);
ABF_numfilesdir=length(ABF_dir);
if ABF_numfilesdir<1
    disp('No ABF file found');
end
PathName_abffile=sprintf('%s/%s', directoryname, ABF_dir.name);
PClampData=abfload2(PathName_abffile);

%%%  Finds all the sweeps with images and outputs the subsampled data, the
%%%  location within each sweep of each image capture, and the number of
%%%  the sweep that contains the image
[subsampled_data, image_locations,Sweeps_with_images]=Andor_Frame_Capture_Detection_2(PClampData);

%%% Find each directory within the main directory for each experimental
%%% condtions
Conditions_dir=sprintf('%s/*',directoryname);
Conditions_directory = dir (Conditions_dir);
[Directory_Array]=Find_Subdirectories(Conditions_dir);

image(Bright,'cdatamapping','scaled')
axis image
colormap(gray)

ROI=roipoly;

for this_folder=1:size(Directory_Array,1)
    %%% Enter Subfolders 
    PathName=sprintf('%s/%s', directoryname, Directory_Array(this_folder,:).name);
    %%%% Opens files from my shared drive
    path1dir=sprintf('%s/**',PathName);
    ddir = dir (path1dir);
    ddir(1:2,:)=[];
    numfilesdir=length(ddir);
    if numfilesdir<1
        disp('No files found');
    end
    Base=zeros(64,128);
    Base2=zeros(64,128);
    BaseG=zeros(64,128);
    Base2G=zeros(64,128);
    for this_exposure=1:size(ddir,1)
        
    
        clear fn;
        clear Ch1_fit_results;
        clear Ch2_fit_results;
        %%%  Get the Glut perfusion andor file
        
        fn=sprintf('%s/%s',PathName,ddir(this_exposure,:).name);
        [Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(fn)
        temp=Image.data;
        tempguassian=zeros(size(Image.data));
        fn
        %%%% Detect Shutter Opening and Closing
        shutter_scan=squeeze(mean(mean(temp)));
        shutter_deriv=diff(shutter_scan);
        [waste, shutter_open_frame]=max(shutter_deriv);
        [waste, shutter_close_frame]=min(shutter_deriv);
        dark=FrameAverage(temp,2,shutter_open_frame-2);
        
        %%%%%%%%%%  Darkfield subtraction
        for i=1:size(temp,3)
            tempframe=temp(:,:,i);
            tempframe=tempframe-dark;
            temp(:,:,i)=tempframe;
            tempgaussian(:,:,i)=Gaussian_Filter_streamlined(tempframe, 2, 0.5);
        end
        %%%%% Breaking up Ch1 and Ch2
        ch1=temp(1:size(temp,1)/2,:,shutter_open_frame+8:shutter_close_frame-5);
        ch2=temp(size(temp,1)/2+1:size(temp,1),:,shutter_open_frame+8:shutter_close_frame-5);
        ch1g=tempgaussian(1:size(temp,1)/2,:,shutter_open_frame+8:shutter_close_frame-5);
        ch2g=tempgaussian(size(temp,1)/2+1:size(temp,1),:,shutter_open_frame+8:shutter_close_frame-5);
        
        for i=1:size(ch1,3)
            thisframe1=ch1(:,:,i);
            thisframe2=ch2(:,:,i);
            thisframe1g=ch1g(:,:,i);
            thisframe2g=ch2g(:,:,i);
            ch1tofit(i)=double(mean(thisframe1(ROI)));
            ch2tofit(i)=double(mean(thisframe2(ROI)));
            ch1tofitg(i)=double(mean(thisframe1g(ROI)));
            ch2tofitg(i)=double(mean(thisframe2g(ROI)));
        end
        
        ch1tofitg=ch1tofitg';
        ch2tofitg=ch2tofitg';
        time=double(1:size(ch1tofit,2));
        ch1fit=HippocampalCh1CurveFitting_10X(time',ch1tofit');
        ch2fit=HippocampalCh1CurveFitting_10X_Ch2(time',ch2tofit');
        Ch1N=FrameNormalization(ch1,ch1fit);
        Ch2N=FrameNormalization(ch2,ch2fit);
        

        ch1fitg=HippocampalCh1CurveFitting_10X(time',ch1tofitg');
        ch2fitg=HippocampalCh1CurveFitting_10X_Ch2(time',ch2tofitg');
        Ch1Ng=FrameNormalization(ch1g,ch1fitg);
        Ch2Ng=FrameNormalization(ch2g,ch2fitg);
        ch1goodnessoffit=ch1tofit-ch1fit';
        ch2goodnessoffit=ch2tofit-ch2fit';
        ROIRatio=ch1goodnessoffit./ch2goodnessoffit;
        
        [waste, StimFrame]=max(abs(diff(subsampled_data(1,:))));
        StimFrame=StimFrame-shutter_open_frame;
        StimFrame=63;
        ratio=ch1./ch2;
        ratiog=ch1g./ch2g;
        ratioN=Ch1N./Ch2N;
        ratioNg=Ch1Ng./Ch2Ng;
        
        for q=1:size(ratio,3)
           temp=ratio(:,:,q);
           tempQG=ratiog(:,:,q);
           tempQN=ratioN(:,:,q);
           tempQNG=ratioNg(:,:,q);
           trace(q)=mean(temp(ROI));     
           traceG(q)=mean(tempQG(ROI));
           traceN(q)=mean(tempQN(ROI));
           traceGN(q)=mean(tempQNG(ROI));
           
        end
        
        PreStim=FrameAverage(ratioN, StimFrame-10, StimFrame-5);
        PostStim=FrameAverage(ratioN,StimFrame+1, StimFrame+10);
         PreStimG=FrameAverage(ratioNg, StimFrame-10, StimFrame-5);
        PostStimG=FrameAverage(ratioNg,StimFrame+1, StimFrame+10);
        
        
        for compile=1:10
           
            Base=Base+ratioN(:,:,StimFrame+compile)-PreStim;
            BaseG=BaseG+ratioNg(:,:,StimFrame+compile)-PreStimG;
        end
         for compile=1:50
           
            Base2=Base2+ratioN(:,:,StimFrame+compile)-PreStim;
            Base2G=Base2G+ratioNg(:,:,StimFrame+compile)-PreStimG;
        end
        Bases(this_folder,this_exposure,:,:)=Base;
        BasesG(this_folder,this_exposure,:,:)=BaseG;
        Bases2(this_folder,this_exposure,:,:)=Base2;
        Bases2G(this_folder,this_exposure,:,:)=Base2G;
        Response(this_folder,this_exposure,:,:)=PostStim-PreStim;
        ResponseG(this_folder,this_exposure,:,:)=PostStimG-PreStimG;
        traces_noROI(this_folder,this_exposure,:)=ch1goodnessoffit./ch2goodnessoffit;
        
        traces(this_folder,this_exposure,:)=trace;
        tracesG(this_folder,this_exposure,:)=traceG;
        tracesN(this_folder,this_exposure,:)=traceN;
        tracesGN(this_folder,this_exposure,:)=traceGN;
        traces_BSLS(this_folder,this_exposure,:)=trace-trace(1,StimFrame);
        tracesG_BSLS(this_folder,this_exposure,:)=traceG-traceG(1,StimFrame);
        tracesN_BSLS(this_folder,this_exposure,:)=traceN-traceN(1,StimFrame);
        tracesGN_BSLS(this_folder,this_exposure,:)=traceGN-traceGN(1,StimFrame);
        Movies(this_folder,this_exposure,:,:,:)=ratio;
        MoviesNG(this_folder,this_exposure,:,:,:)=ratioNg;
        ch1all(this_folder,this_exposure,:,:)=ch1tofit;
        ch2all(this_folder,this_exposure,:,:)=ch2tofit;
        ch1GOF(this_folder,this_exposure,:,:)=ch1goodnessoffit;
        ch2GOF(this_folder,this_exposure,:,:)=ch2goodnessoffit;
        ROIRatios(this_folder,this_exposure,:,:)=ch1goodnessoffit./ch2goodnessoffit;
        
    end 
    
end
channelA.ROItraces_filtered=squeeze(tracesG(1,:,:));
channelA.ROItraces=squeeze(traces(1,:,:));
channelA.ROItraces_filtered_normalized=squeeze(tracesGN(1,:,:));
channelA.ROItraces_normalized=squeeze(tracesN(1,:,:));
channelA.ROItraces_filtered_BSLS=squeeze(tracesG_BSLS(1,:,:));
channelA.ROItraces_BSLS=squeeze(traces_BSLS(1,:,:));
channelA.ROItraces_filtered_normalized_BSLS=squeeze(tracesGN_BSLS(1,:,:));
channelA.ROItraces_normalized_BSLS=squeeze(tracesN_BSLS(1,:,:));
channelA.ROItraces_noROI=squeeze(traces_noROI(1,:,:));
channelA.Ch1=squeeze(ch1all(1,:,:));
channelA.Ch2=squeeze(ch2all(1,:,:));
channelA.Ch1GOF=squeeze(ch1GOF(1,:,:));
channelA.Ch2GOF=squeeze(ch2GOF(1,:,:));
channelA.ROIRatios=squeeze(ROIRatios(1,:,:));
channelA.IntegratedImages10=Bases(1,:,:,:);
channelA.IntegratedImages10_filtered=BasesG(1,:,:,:);
channelA.IntegratedImages50=Bases2(1,:,:,:);
channelA.IntegratedImages50_filtered=Bases2G(1,:,:,:);
channelA.SingleImage_10FramePostStimAverage=Response(1,:,:,:);
channelA.SingleImage_10FramePostStimAverage_filetered=ResponseG(1,:,:,:);
channelA.Movies=MoviesNG(1,this_exposure,:,:,:);


channelB.ROItraces_filtered=squeeze(tracesG(3,:,:));
channelB.ROItraces=squeeze(traces(3,:,:));
channelB.ROItraces_filtered_normalized=squeeze(tracesGN(3,:,:));
channelB.ROItraces_normalized=squeeze(tracesN(3,:,:));
channelB.ROItraces_filtered_BSLS=squeeze(tracesG_BSLS(3,:,:));
channelB.ROItraces_BSLS=squeeze(traces_BSLS(3,:,:));
channelB.ROItraces_filtered_normalized_BSLS=squeeze(tracesGN_BSLS(3,:,:));
channelB.ROItraces_normalized_BSLS=squeeze(tracesN_BSLS(3,:,:));
channelB.ROItraces_noROI=squeeze(traces_noROI(3,:,:));
channelB.Ch1=squeeze(ch1all(3,:,:));
channelB.Ch2=squeeze(ch2all(3,:,:));
channelB.Ch1GOF=squeeze(ch1GOF(3,:,:));
channelB.Ch2GOF=squeeze(ch2GOF(3,:,:));
channelB.ROIRatios=squeeze(ROIRatios(3,:,:));
channelB.IntegratedImages10=Bases(3,:,:,:);
channelB.IntegratedImages10_filtered=BasesG(3,:,:,:);
channelB.IntegratedImages50=Bases2(3,:,:,:);
channelB.IntegratedImages50_filtered=Bases2G(3,:,:,:);
channelB.SingleImage_10FramePostStimAverage=Response(3,:,:,:);
channelB.SingleImage_10FramePostStimAverage_filetered=ResponseG(3,:,:,:);
channelB.Movies=MoviesNG(3,this_exposure,:,:,:);

channelApost.ROItraces_filtered=squeeze(tracesG(2,:,:));
channelApost.ROItraces=squeeze(traces(2,:,:));
channelApost.ROItraces_filtered_normalized=squeeze(tracesGN(2,:,:));
channelApost.ROItraces_normalized=squeeze(tracesN(2,:,:));
channelApost.ROItraces_filtered_BSLS=squeeze(tracesG_BSLS(2,:,:));
channelApost.ROItraces_BSLS=squeeze(traces_BSLS(2,:,:));
channelApost.ROItraces_filtered_normalized_BSLS=squeeze(tracesGN_BSLS(2,:,:));
channelApost.ROItraces_normalized_BSLS=squeeze(tracesN_BSLS(2,:,:));
channelApost.ROItraces_noROI=squeeze(traces_noROI(2,:,:));
channelApost.Ch1=squeeze(ch1all(2,:,:));
channelApost.Ch2=squeeze(ch2all(2,:,:));
channelApost.Ch1GOF=squeeze(ch1GOF(2,:,:));
channelApost.Ch2GOF=squeeze(ch2GOF(2,:,:));
channelApost.ROIRatios=squeeze(ROIRatios(2,:,:));
channelApost.IntegratedImages10=Bases(2,:,:,:);
channelApost.IntegratedImages10_filtered=BasesG(2,:,:,:);
channelApost.IntegratedImages50=Bases2(2,:,:,:);
channelApost.IntegratedImages50_filtered=Bases2G(2,:,:,:);
channelApost.SingleImage_10FramePostStimAverage=Response(2,:,:,:);
channelApost.SingleImage_10FramePostStimAverage_filetered=ResponseG(2,:,:,:);
channelApost.Movies=MoviesNG(2,this_exposure,:,:,:);

channelBpost.ROItraces_filtered=squeeze(tracesG(4,:,:));
channelBpost.ROItraces=squeeze(traces(4,:,:));
channelBpost.ROItraces_filtered_normalized=squeeze(tracesGN(4,:,:));
channelBpost.ROItraces_normalized=squeeze(tracesN(4,:,:));
channelBpost.ROItraces_filtered_BSLS=squeeze(tracesG_BSLS(4,:,:));
channelBpost.ROItraces_BSLS=squeeze(traces_BSLS(4,:,:));
channelBpost.ROItraces_filtered_normalized_BSLS=squeeze(tracesGN_BSLS(4,:,:));
channelBpost.ROItraces_normalized_BSLS=squeeze(tracesN_BSLS(4,:,:));
channelBpost.ROItraces_noROI=squeeze(traces_noROI(4,:,:));
channelBpost.Ch1=squeeze(ch1all(4,:,:));
channelBpost.Ch2=squeeze(ch2all(4,:,:));
channelBpost.Ch1GOF=squeeze(ch1GOF(4,:,:));
channelBpost.Ch2GOF=squeeze(ch2GOF(4,:,:));
channelBpost.ROIRatios=squeeze(ROIRatios(4,:,:));
channelBpost.IntegratedImages10=Bases(4,:,:,:);
channelBpost.IntegratedImages10_filtered=BasesG(4,:,:,:);
channelBpost.IntegratedImages50=Bases2(4,:,:,:);
channelBpost.IntegratedImages50_filtered=Bases2G(4,:,:,:);
channelBpost.SingleImage_10FramePostStimAverage=Response(4,:,:,:);
channelBpost.SingleImage_10FramePostStimAverage_filetered=ResponseG(4,:,:,:);
channelBpost.Movies=MoviesNG(4,this_exposure,:,:,:);
figure(1)
subplot(2,2,1)
plot(1:159,channelA.ROItraces_filtered')
subplot(2,2,2)
plot(channelB.ROItraces_filtered')
subplot(2,2,3)
plot(channelApost.ROItraces_filtered')
subplot(2,2,4)
plot(channelBpost.ROItraces_filtered')
printfilenamesm=sprintf('%s/ROI',directoryname)
print ('-djpeg','-r400', printfilenamesm)
figure(2)
subplot(2,2,1)
plot(1:159,channelA.Ch1')
subplot(2,2,2)
plot(channelB.Ch1')
subplot(2,2,3)
plot(channelApost.Ch1')
subplot(2,2,4)
plot(channelBpost.Ch1')

figure(3)
subplot(2,2,1)
plot(1:159,channelA.Ch2')
subplot(2,2,2)
plot(channelB.Ch2')
subplot(2,2,3)
plot(channelApost.Ch2')
subplot(2,2,4)
plot(channelBpost.Ch2')

figure(4)
subplot(2,2,1)
plot(1:159,channelA.ROItraces_filtered_normalized')
subplot(2,2,2)
plot(channelB.ROItraces_filtered_normalized')
subplot(2,2,3)
plot(channelApost.ROItraces_filtered_normalized')
subplot(2,2,4)
plot(channelBpost.ROItraces_filtered_normalized')

figure(5)
subplot(2,2,1)
plot(1:159,channelA.ROItraces_filtered_normalized_BSLS')
subplot(2,2,2)
plot(channelB.ROItraces_filtered_normalized_BSLS')
subplot(2,2,3)
plot(channelApost.ROItraces_filtered_normalized_BSLS')
subplot(2,2,4)
plot(channelBpost.ROItraces_filtered_normalized_BSLS')


figure(6)
subplot(2,2,1)
plot(1:159,channelA.Ch1GOF')
subplot(2,2,2)
plot(channelB.Ch1GOF')
subplot(2,2,3)
plot(channelApost.Ch1GOF')
subplot(2,2,4)
plot(channelBpost.Ch1GOF')

printfilenamesm=sprintf('%s/1Ch1',directoryname)
print ('-djpeg','-r400', printfilenamesm)

figure(7)
subplot(2,2,1)
plot(1:159,channelA.Ch2GOF')
subplot(2,2,2)
plot(channelB.Ch2GOF')
subplot(2,2,3)
plot(channelApost.Ch2GOF')
subplot(2,2,4)
plot(channelBpost.Ch2GOF')
printfilenamesm=sprintf('%s/Ch2',directoryname)
print ('-djpeg','-r400', printfilenamesm)

figure(8)
subplot(2,2,1)
plot(1:159,channelA.ROItraces_noROI')
subplot(2,2,2)
plot(channelB.ROItraces_noROI')
subplot(2,2,3)
plot(channelApost.ROItraces_noROI')
subplot(2,2,4)
plot(channelBpost.ROItraces_noROI')


%%% Finding the Peak Responses

for i=1:size(channelA.ROItraces_filtered_normalized_BSLS,1)
channelApeaks(i)=min(channelA.ROItraces_filtered_normalized_BSLS(i,40:80));
end

for i=1:size(channelB.ROItraces_filtered_normalized_BSLS,1)
channelBpeaks(i)=min(channelB.ROItraces_filtered_normalized_BSLS(i,40:80));
end

for i=1:size(channelApost.ROItraces_filtered_normalized_BSLS,1)
channelApostpeaks(i)=min(channelApost.ROItraces_filtered_normalized_BSLS(i,40:80));
end

for i=1:size(channelBpost.ROItraces_filtered_normalized_BSLS,1)
channelBpostpeaks(i)=min(channelBpost.ROItraces_filtered_normalized_BSLS(i,40:80));
end

outdata=[channelApeaks;channelBpeaks;channelApostpeaks;channelBpostpeaks];
outdataname=sprintf('%s/PeakData',directoryname);
save(outdataname,'outdata','-ASCII')

alldata.A=channelA;
alldata.B=channelB;
alldata.Apost=channelApost;
alldata.Bpost=channelBpost;
outdataname=sprintf('%s/OutData',directoryname);
save(outdataname,'alldata');

%%%%%%%%% Create 10 frame integrated images
A_10_Ave_Image=channelA.IntegratedImages10_filtered;
B_10_Ave_Image=channelB.IntegratedImages10_filtered;
Apost_10_Ave_Image=channelApost.IntegratedImages10_filtered;
Bpost_10_Ave_Image=channelBpost.IntegratedImages10_filtered;
A_10_Ave_Image=squeeze(mean(A_10_Ave_Image));
B_10_Ave_Image=squeeze(mean(B_10_Ave_Image));
Apost_10_Ave_Image=squeeze(mean(Apost_10_Ave_Image));
Bpost_10_Ave_Image=squeeze(mean(Bpost_10_Ave_Image));

figure9=figure(9)
subplot1 = subplot(2,2,1,'Parent',figure9,'YDir','reverse','Layer','top',...
    'CLim',[-20 1]);
box('on');
hold('all');
image(A_10_Ave_Image,'Parent',subplot1, 'cdatamapping','scaled')
axis image
axis off
subplot2 = subplot(2,2,2,'Parent',figure9,'YDir','reverse','Layer','top',...
    'CLim',[-20 1]);
box('on');
hold('all');
image(B_10_Ave_Image,'Parent',subplot2,'cdatamapping','scaled')
axis image
axis off
subplot3 = subplot(2,2,3,'Parent',figure9,'YDir','reverse','Layer','top',...
    'CLim',[-20 1]);
box('on');
hold('all');
image(Apost_10_Ave_Image,'Parent',subplot3,'cdatamapping','scaled')
axis image
axis off
subplot4 = subplot(2,2,4,'Parent',figure9,'YDir','reverse','Layer','top',...
    'CLim',[-20 1]);
box('on');
hold('all');
image(Bpost_10_Ave_Image,'Parent',subplot4,'cdatamapping','scaled')
axis image
axis off
printfilenamesm=sprintf('%s/10Integrated',directoryname)
print ('-djpeg','-r400', printfilenamesm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%% Create 1 frame integrated images
A_50_Ave_Image=channelA.SingleImage_10FramePostStimAverage_filetered;
B_50_Ave_Image=channelB.SingleImage_10FramePostStimAverage_filetered;
Apost_50_Ave_Image=channelApost.SingleImage_10FramePostStimAverage_filetered;
Bpost_50_Ave_Image=channelBpost.SingleImage_10FramePostStimAverage_filetered;
A_50_Ave_Image=squeeze(mean(A_50_Ave_Image));
B_50_Ave_Image=squeeze(mean(B_50_Ave_Image));
Apost_50_Ave_Image=squeeze(mean(Apost_50_Ave_Image));
Bpost_50_Ave_Image=squeeze(mean(Bpost_50_Ave_Image));
figure10=figure(10)
subplot11 = subplot(2,2,1,'Parent',figure10,'YDir','reverse','Layer','top',...
    'CLim',[-.1 0.01]);
box('on');
hold('all');
image(A_50_Ave_Image,'Parent',subplot11, 'cdatamapping','scaled')
axis image
axis off
subplot21 = subplot(2,2,2,'Parent',figure10,'YDir','reverse','Layer','top',...
    'CLim',[-.1 0.01]);
box('on');
hold('all');
image(B_50_Ave_Image,'Parent',subplot21,'cdatamapping','scaled')
axis image
axis off
subplot31 = subplot(2,2,3,'Parent',figure10,'YDir','reverse','Layer','top',...
    'CLim',[-.1 0.01]);
box('on');
hold('all');
image(Apost_50_Ave_Image,'Parent',subplot31,'cdatamapping','scaled')
axis image
axis off
subplot41 = subplot(2,2,4,'Parent',figure10,'YDir','reverse','Layer','top',...
    'CLim',[-.1 0.01]);
box('on');
hold('all');
image(Bpost_50_Ave_Image,'Parent',subplot41,'cdatamapping','scaled')
axis image
axis off
printfilenamesm=sprintf('%s/SingleIntegrated',directoryname)
print ('-djpeg','-r400', printfilenamesm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



