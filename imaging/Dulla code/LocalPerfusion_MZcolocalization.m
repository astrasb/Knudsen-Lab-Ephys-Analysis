%%%%%%%%  Analyzing Andor Slow Calibration Files %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Use this program to open, draw roi's and compute ratio/time
%  courses for slow (1 image every 10 secs) local perfursion
% calibration files with darkfield subtraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
FLcount=0;
ContraCounter=0;
FLCounter=0;
%%%% Choose a folder with multple slices from 1 day in it
directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
path1dir=sprintf('%s/*lice*',directoryname);
ddir = dir (path1dir);
numfilesdir=length(ddir);
if numfilesdir<1
    disp('No files found');
end

%%%%  Create a variable with all the folder names
for i = 1:numfilesdir
    t = length(getfield(ddir,{i},'name')) ;
    dddir(i, 1:t) = getfield(ddir,{i},'name') ;
end


%%%%  Creata an Average Map of MZ location for Pixel Counting
%%%%  and calculate the average MZ size in pixels
ContraCount=0;
FLMaskAve=zeros(64,128);
Thresh4mask=zeros(size(dddir,1),64,128);

for this_slices=1:size(dddir,1)
    
    PathName=sprintf('%s/%s/', directoryname,dddir(this_slices,:));
    search_folder_MZ=sprintf('%sNew_analysis_8_1_2009/MZmask*',PathName);
    ddirMZ = dir (search_folder_MZ);
    NumberMZ=length(ddirMZ);
    if NumberMZ<1
        disp('No files found');
        MZmaskfound=0;
    else
        thisMZ=open(sprintf('%sNew_analysis_8_1_2009/MZmask.mat', PathName));
        FLMZ=thisMZ.FLMZ;
        MZmaskfound=1;
        [t loc]=max(mean(FLMZ));
        if loc<10
            Contra(this_slices)=1;
        else
            Contra(this_slices)=0;
            ContraCount=ContraCount+1;
            FLMaskAve=FLMaskAve+FLMZ;
            MaskSize(ContraCount)=size(find(FLMZ==1),1);
            
        end
    end
    
    
end
MaskSize=mean(MaskSize);
FLMaskAve=FLMaskAve/ContraCount;
FLAveMask=find(FLMaskAve>0.5);
FLAveM=zeros(64,128);
FLAveM(FLAveMask)=1;

numb_contra=size(find(Contra==1),2);
Thresh4mask_Contra=zeros(numb_contra,64,128);
numb_FL=size(find(Contra~=1),2);
Thresh4mask_Contra=zeros(numb_FL,64,128);
Thresh1mask_Contra=zeros(numb_contra,64,128);
Thresh1mask_Contra=zeros(numb_FL,64,128);

%%% Save an image of the average Map
image(FLAveM,'cdatamapping','scaled');
fnOut=sprintf('%s/AveMZMask', directoryname);
print ('-djpeg','-r400', fnOut)

ttt=find(mean(FLAveM)>0);
FLAveEdgeRight=ttt(size(ttt,2));
FLAveEdgeLeft=ttt(size(ttt,1));
FLAveMaskClipped=FLAveM(:,FLAveEdgeLeft:FLAveEdgeRight);

%%%  Get the Perfusion Location file
PathNameSt=sprintf('%s/StimLoc.mat', directoryname);
ddirSt = dir (PathNameSt);
NumberStim=length(ddirSt);
if NumberStim<1
    disp('No files found');
    Stimfound=0;
else
    Stimfound=1;
    St=open(PathNameSt);
    StimLoc=St.StimLoc;
end

%%%%  Enter the First Slice folder and process it
for this_slice=1:size(dddir,1)
    
    %%%  Get the brightfield SIF file
    PathName=sprintf('%s/%s/', directoryname,dddir(this_slice,:));
    search_folder_Glut=sprintf('%s/*right*.sif',PathName);
    ddir = dir (search_folder_Glut);
    NumberGlut=length(ddir)-2;
    if NumberGlut<1
        disp('No files found');
    end
    
    %%%  Get the FL location file
    PathName2=sprintf('%s/', directoryname);
    search_folder_Glut=sprintf('%sAll_FL_locs.mat',PathName2);
    ddir = dir (search_folder_Glut);
    NumberGlut=length(ddir);
    if NumberGlut<1
        disp('No files found');
        FLspot=0;
    else
        FLspot=1;
        FLloc=open(sprintf('%s/All_FL_locs.mat',PathName2));
        FLloc=FLloc.FLloc;
    end
    
    
    
    %%%  Get the MZ mask file if it exists file
    PathName=sprintf('%s/%s/', directoryname,dddir(this_slice,:));
    search_folder_MZ=sprintf('%sNew_analysis_8_1_2009/MZmask*',PathName);
    ddirMZ = dir (search_folder_MZ);
    NumberMZ=length(ddirMZ);
    if NumberMZ<1
        disp('No files found');
        MZmaskfound=0;
    else
        thisMZ=open(sprintf('%sNew_analysis_8_1_2009/MZmask.mat', PathName));
        FLMZ=thisMZ.FLMZ;
        MZmaskfound=1;
        [t loc]=max(mean(FLMZ));
        
    end
    
    %%% Brighten Images and Select ROIs if the files don't already exist
    if (MZmaskfound==0) | (Stimfound==0);
        fn=sprintf('%s%s',PathName,ddir.name);
        [Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(fn)
        bright=Image.data(1:64,:);
        fac=64/(max(max(bright)));
        bright=bright*fac;
        brighten=0;
        while brighten==0
            
            image(bright,'cdatamapping','direct')
            colormap('gray')
            axis image;
            Happiness=questdlg('Would you like to brighten the image?','GOULET INC');
            if strcmp(Happiness,'Yes')==1
                
                bright=bright+15;
            else
                brighten=1;
            end
        end
        
        if Stimfound==0
            Happiness=questdlg('Draw the perfusion tip location','GOULET INC');
            PerfLoc=roipoly;
            [t StimLoc(this_slice,1)]=max(mean(PerfLoc));
        end
        
        
        
        if MZmaskfound==0
            Happiness=questdlg('Draw the Microgyral Zone (put an ROI in the upper left corner if Contra)','GOULET INC');
            FLMZ=roipoly;
        end
    end
    
    
    %%%% Open matlab files containging the ROI maps of the thresholded
    %%%% perfusion data
    FLmap=find(FLMZ==1);
    testimage=zeros(size(FLMZ,1),size(FLMZ,2));
    testimage(FLmap)=-2;
    fn2=sprintf('%s/New_analysis_8_1_2009/FRET_Log*',PathName);
    ddir2 = dir (fn2);
    fn3=sprintf('%s/New_analysis_8_1_2009/%s',PathName, ddir2.name);
    roi=open(fn3);
    Rois=squeeze(roi.FRET_logicals(4,:,:));
    ThisROI=find(Rois~=0);
    Rois(ThisROI)=1;
    Overlay=testimage+Rois;
    inMZ=find(Overlay==-1);
    outofMZ=find(Overlay==1);
    image(Overlay,'cdatamapping','scaled')
    axis image;
    fnOut=sprintf('%s/New_analysis_8_1_2009/MZmaskJPG',PathName);
    print ('-djpeg','-r400', fnOut)
    close
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% Generating a random mask with the same number of pixels as
    %%%%%%%%% the ROI
    NumberofPixels=size(FLmap,1)/(64*128);
    RandM=rand(64,128);
    RandMa=find(RandM<NumberofPixels);
    testcontraR=zeros(64,128);
    testcontraR(RandMa)=-2;
    testcontraR=testcontraR+Rois;
    inMZcontra=find(testcontraR==-1);
    outMZcontra=find(testcontraR==1);
    image(testcontraR,'cdatamapping','scaled')
    fnOut=sprintf('%s/New_analysis_8_1_2009/MZContramaskR_JPG',PathName);
    print ('-djpeg','-r400', fnOut)
    close
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% Generating a randon mask with the same number of pixels as
    %%%%%%%%% the Average ROI
    AverageNumberofPixels=MaskSize/(64*128);
    RandMA=rand(64,128);
    RandMaAve=find(RandMA<AverageNumberofPixels);
    testcontraRA=zeros(64,128);
    testcontraRA(RandMaAve)=-2;
    testcontraRA=testcontraRA+Rois;
    inMZcontraRA=find(testcontraRA==-1);
    outMZcontraRA=find(testcontraRA==1);
    image(testcontraRA,'cdatamapping','scaled')
    fnOut=sprintf('%s/New_analysis_8_1_2009/MZContramask_RAJPG',PathName);
    print ('-djpeg','-r400', fnOut)
    close
    
    
    %Sort Data into the right output files
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Contra(1, this_slice)==0
        FLCounter=FLCounter+1;
        Thresh4mask(FLCounter,:,:)=squeeze(roi.FRET_logicals(4,:,:)); 
        Thresh1mask(FLCounter,:,:)=squeeze(roi.FRET_logicals(1,:,:)); 
        Thresh2mask(FLCounter,:,:)=squeeze(roi.FRET_logicals(2,:,:)); 
        
        if FLspot==0;
        Happiness=questdlg('Draw the exact FL location - 1 pixel at the microgyrus','GOULET INC');
        image(FLMZ,'cdatamapping','scaled')
        toots=roipoly;
        [dump FLloc(FLcount)]=max(mean(toots));
        end
        if size(inMZ,1)>0
            MZPercentage(1,this_slice)=size(inMZ,1);
        else
            MZPercentage(1,this_slice)=0;
        end
        if size(outofMZ)>0
            MZPercentage(2,this_slice)=size(outofMZ,1);
        else
            MZPercentage(2,this_slice)=0;
        end
        
        if size(inMZcontra,1)>0
            MZPercentage(5,this_slice)=size(inMZcontra,1);
        else
            MZPercentage(5,this_slice)=0;
        end
        if size(outMZcontra,1)>0
            MZPercentage(6,this_slice)=size(outMZcontra,1);
        else
            MZPercentage(6,this_slice)=0;
        end
        
        if size(inMZcontraRA,1)>0
            MZPercentage(9,this_slice)=size(inMZcontraRA,1);
        else
            MZPercentage(9,this_slice)=0;
        end
        if size(outMZcontraRA,1)>0
            MZPercentage(10,this_slice)=size(outMZcontraRA,1);
        else
            MZPercentage(10,this_slice)=0;
        end
        
    else
        ContraCounter=ContraCounter+1;
        Thresh4mask_Contra(ContraCounter,:,:)=squeeze(roi.FRET_logicals(4,:,:)); 
        Thresh1mask_Contra(ContraCounter,:,:)=squeeze(roi.FRET_logicals(1,:,:)); 
         Thresh2mask_Contra(ContraCounter,:,:)=squeeze(roi.FRET_logicals(2,:,:));
        if size(inMZ,1)>0
            
            MZPercentage(3,this_slice)=size(inMZ,1);
        else
            MZPercentage(3,this_slice)=0;
        end
        if size(outofMZ)>0
            MZPercentage(4,this_slice)=size(outofMZ,1);
        else
            MZPercentage(4,this_slice)=0;
        end
        
        if size(inMZcontra,1)>0
            MZPercentage(7,this_slice)=size(inMZcontra,1);
        else
            MZPercentage(7,this_slice)=0;
        end
        if size(outMZcontra,1)>0
            MZPercentage(8,this_slice)=size(outMZcontra,1);
        else
            MZPercentage(8,this_slice)=0;
        end
        
        if size(inMZcontraRA,1)>0
            MZPercentage(11,this_slice)=size(inMZcontraRA,1);
        else
            MZPercentage(11,this_slice)=0;
        end
        if size(outMZcontraRA,1)>0
            MZPercentage(12,this_slice)=size(outMZcontraRA,1);
        else
            MZPercentage(12,this_slice)=0;
        end
        
    end
 
   
    fnOut=sprintf('%s/New_analysis_8_1_2009/MZmask',PathName);
    save(fnOut,'FLMZ');
    
    
end

fnOut=sprintf('%s/MZpercentage', directoryname);
save(fnOut,'MZPercentage','-tabs','-ascii');

fnOut=sprintf('%s/StimLoc', directoryname);
save(fnOut,'StimLoc');

fnOut=sprintf('%s/AllThresh4_ROIs', directoryname);
save(fnOut,'Thresh4mask');
 
fnOut=sprintf('%s/All_FL_locs', directoryname);
save(fnOut,'FLloc');
        
fnOut=sprintf('%s/AllThresh4_ROIs_Contra', directoryname);
save(fnOut,'Thresh4mask_Contra');
        
fnOut=sprintf('%s/AllThresh1_ROIs_Contra', directoryname);
save(fnOut,'Thresh1mask_Contra');
fnOut=sprintf('%s/AllThresh1_ROIs', directoryname);
save(fnOut,'Thresh1mask');
fnOut=sprintf('%s/AllThresh2_ROIs_Contra', directoryname);
save(fnOut,'Thresh2mask_Contra');
fnOut=sprintf('%s/AllThresh2_ROIs', directoryname);
save(fnOut,'Thresh2mask');