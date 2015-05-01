%%%%%%%%  Afferent Mapping Analysis for FL %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
parameters_present=0;
[RGBCustom]=CreateRGBColorTableInverted;

directoryname = uigetdir('/mnt/m022a');
path3dir=sprintf('%s/*lic*',directoryname);
ddir3 = dir (path3dir);
numfilesdir3=length(ddir3);
if numfilesdir3<1
    disp('No files found');
end

for this_folder=1:size(ddir3,1);
    
    %%%% Choose a folder with multple images from 1 slice
    PathName=sprintf('%s/%s', directoryname, ddir3(this_folder,:).name);
    %%%% Opens files from my shared drive
    path1dir=sprintf('%s/*titled_*',PathName);
    ddir = dir (path1dir);
    numfilesdir=length(ddir);
    if numfilesdir<1
        disp('No files found');
    end
    
    %%%% Get Brightfield File Name
    path2dir=sprintf('%s/*righ*',PathName);
    ddir2 = dir (path2dir);
    numfilesdir2=length(ddir2);
    if numfilesdir2<1
        disp('No files found');
    end
    
    
    
    
    %%%% Get MZ Mask File Name
    pathydir=sprintf('%s/*FLMZ*',PathName);
    ddiry = dir (pathydir);
    numfilesdiry=length(ddiry);
    if numfilesdiry<1
        disp('No MZ mask files found');
        StimFound=0;
        
    else
        FLMZ=open(sprintf('%s/%s',PathName,ddiry.name));
        FLMZ=FLMZ.FLMZ;
        StimFound=1;
    end
    
    if StimFound~=1
     %%%% Get Cooke Image File Name
    pathtdir=sprintf('%s/*.tif',PathName);
    ddirt = dir (pathtdir);
    numfilesdirt=length(ddirt);
    if numfilesdirt<1
        disp('No files found');
    else
    
        CookeImage=open(sprintf('%s/%s',PathName,ddirt(1,1).name));
        
    end
    end
     %%%% Get Stim File Name
    path4dir=sprintf('%s/*StimSite*',PathName);
    ddir4 = dir (path4dir);
    numfilesdir4=length(ddir4);
    if numfilesdir4<1
        disp('No Stime files found');
        StimFound=0;
        
    else
        StimSite=open(sprintf('%s/%s',PathName,ddir4.name));
        StimSite=StimSite.StimSite;
        StimFound=1;
    end
        %%%% Get Stim File Name
    path5dir=sprintf('%s/*FLMask*',PathName);
    ddir5 = dir (path5dir);
    numfilesdir5=length(ddir5);
    if numfilesdir5<1
        disp('No FL Map files found');
        FLMaskFound=0;
        
    else
        FLMask=open(sprintf('%s/%s',PathName,ddir5.name));
        FL=FLMask.FL;
        FLMaskFound=1;
    end
    %StimFrame=120; %first two days
    
    %StimFrame=165; %third day
    StimFrame=167; %fourth Day
    
    %%%%  Enter the First Slice folder and process it
    for this_slice=1:size(ddir,1)
        clear NumberGlut;
        clear fn;
        clear Ch1_fit_results;
        clear Ch2_fit_results;
        %%%  Get the Glut perfusion andor file
        
        fn=sprintf('%s/%s',PathName,ddir(this_slice,:).name);
        [Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(fn)
        temp=Image.data;
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
            
        end
        %%%%% Breaking up Ch1 and Ch2
        ch1=temp(1:size(temp,1)/2,:,shutter_open_frame+8:shutter_close_frame-5);
        ch2=temp(size(temp,1)/2+1:size(temp,1),:,shutter_open_frame+8:shutter_close_frame-5);
        ch1tofit=squeeze(mean(mean(ch1)));
        ch2tofit=squeeze(mean(mean(ch2)));
        
        %%%% Plotting the means of Ch1 and Ch2 for Curve fitting
        if this_slice==1
            subplot(2,1,1)
            plot(ch1tofit)
            subplot(2,1,2)
            plot(ch2tofit)
            
            
            
            prompt = {'Enter the Stim Frame                 '};
            dlg_title = 'Adjust Registration              ';
            num_lines = 1;
            def = {num2str(StimFrame)};
            %answer = inputdlg(prompt,dlg_title,num_lines,def);
            %StimFrame=str2num(answer{1,1});
        end
        close
        ratio=ch1./ch2;
        PreStim=FrameAverage(ratio, StimFrame-6, StimFrame-1);
        PostStim=FrameAverage(ratio,StimFrame+1, StimFrame+10);
        Response(this_slice,:,:)=PostStim-PreStim;
        
        %%% Integrated Response Analysis
        Int_Response=zeros(size(PreStim,1),size(PreStim,2));
        for i=1:25
            this_frame=ratio(:,:,StimFrame+1+i)-PreStim;
            Int_Response=Int_Response+this_frame;
        end
        Int_Res_out(this_slice,:,:)=Int_Response;
    end
    ROutI=squeeze(mean(Int_Res_out));
    ROut=squeeze(mean(Response));
        
    Imean=mean(mean(ROutI));
    Istd=std(std(ROutI));
    
    for i=1:10
    Imask=find(ROutI<Imean-Istd*i);
    Itest=zeros(size(FLMZ,1),size(FLMZ,2));
    Itest(Imask)=1;
    [Itest]=Gaussian_Filter_streamlined(Itest, 2, 0.2);
    Imask=find(Itest==1);
    Icombined=Itest+FLMZ;
    Ifound=find(Icombined==2);
    Overlapout=zeros(size(FLMZ,1),size(FLMZ,2));  
    Overlapout(FLMZ)=1;
    Overlapout(Imask)=2;
    Overlapout(Ifound)=3;
    image(Overlapout,'cdatamapping','scaled');
    printfilenamesm=sprintf('%s/Overlap_%d',PathName, i);
    print ('-djpeg','-r400', printfilenamesm)
    close
    PercentInMZ(i)=size(Ifound,1)/size(Imask,1);
    end
    
    
    
    
    outside=zeros(size(ROut,1),size(ROut,2));
    outside(1,:)=1;
    outside(:,1)=1;
    outside(size(outside,1),:)=1;
    outside(:,size(outside,2))=1;
    out=find(outside==1);
    in=find(outside==0);
    ROut(out)=0;
    ROutI(out)=0;
    
    ROut=Gaussian_Filter_streamlined(ROut, 2, 0.5);
    ROutI=Gaussian_Filter_streamlined(ROutI, 2, 0.5);
    
    vert=mean(ROut);
    vert=smooth(vert);
    Profile(this_folder,:)=vert;
    vert_I=mean(ROutI);
    vert_I=smooth(vert_I);
    Profile_I(this_folder,:)=vert_I;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  Getting Brightfield Image and Labeling FL, MZ, and stim site
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if StimFound ~=1
    fnB=sprintf('%s/%s',PathName,ddir2(1,:).name);
    [ImageB,InstaImageB,CalibImageB,versB]=andorread_chris_local_knownfilename(fnB);
    Bright=ImageB.data;
    testimageC=CookeImage.cdata';
    brighten=0;
    
    
     
    while brighten==0
    image(testimageC,'cdatamapping','scaled');
    colormap(CookeImage.colormap);
    axis image
     Happiness=questdlg('Would you like to brighten the image?','GOULET INC');
     if strcmp(Happiness,'Yes')==1
         testimageC=testimageC+15;
     else
         brighten=1;
     end
    end
    figure(2)
    
    brighten=0;
    peak_brighten=255/max(max(Bright(1:size(Bright,1)/2,:)));
    testbright=Bright(1:size(Bright,1)/2,:)*peak_brighten;
    while brighten==0
    image(testbright,'cdatamapping','direct');
     colormap(CookeImage.colormap)
    axis image;
     Happiness=questdlg('Would you like to brighten the image?','GOULET INC');
     if strcmp(Happiness,'Yes')==1
         
         testbright=testbright+15;
     else
         brighten=1;
     end
    end
    end
    
    
    
 
    if FLMaskFound~=1
    Happiness=questdlg('Draw the Freeze Lesion (put an ROI in the upper left corner if Contra)','GOULET INC');
    FL=roipoly;
    end
    
    if FLMaskFound~=1
    Happiness=questdlg('Draw the Microgyral Zone (put an ROI in the upper left corner if Contra)','GOULET INC');
    FLMZ=roipoly;
    end
    
    if StimFound~=1
    Happiness=questdlg('Draw the Stim Site','GOULET INC');
    StimSite=roipoly;
    end
    close
    
    [waste Stim_loc]=max(sum(StimSite));
    [waste FL_loc]=max(sum(FL));
    stim_out(this_folder,:)=Stim_loc;
    FL_out(this_folder,:)=FL_loc;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [peakmin(this_folder,:) peakloc(this_folder,:)]=min(vert);
    peak_50=peakmin(this_folder,:)*0.5;
    [ location50 values ]=find(vert<peak_50);
    loc1=location50(1);
    loc2=location50(size(values,1));
    
    [peakmin_I(this_folder,:) peakloc_I(this_folder,:)]=min(vert_I);
    peak_50_I=peakmin_I(this_folder,:)*0.5;
    [ location50_I values_I ]=find(vert_I<peak_50_I);
    loc1_I=location50_I(1);
    loc2_I=location50_I(size(values_I,1));
    %if peakloc_I>2&peakloc_I<size(Int_Response,2)-2
    Profile_otherDir_I(this_folder,:)=mean(ROutI(:,peakloc_I-10:peakloc_I+10)');
    %end
    
    orientation=(FL_loc-Stim_loc);
    skew_val=(loc1-Stim_loc)+(loc2-Stim_loc);
    skew_val_I=(loc1_I-Stim_loc)+(loc2_I-Stim_loc);
    if orientation>0
        skew_val=-skew_val;
        skew_val_I=-skew_val_I;
    end
    FL_skew_this_slice(1,this_folder)=skew_val;
    FL_skew_this_slice_I(1,this_folder)=skew_val_I;
    FL_skew_this_slice_distance_btw(1,this_folder)=abs(orientation);
    if orientation>0
        FL_skew_this_slice_stim(1,this_folder)=(peakloc(this_folder,:)-Stim_loc);
        FL_skew_this_slice_stim_I(1,this_folder)=(peakloc_I(this_folder,:)-Stim_loc);
    else
        FL_skew_this_slice_stim(1,this_folder)=-(peakloc(this_folder,:)-Stim_loc);
        FL_skew_this_slice_stim_I(1,this_folder)=-(peakloc_I(this_folder,:)-Stim_loc);
    end
    FL_peak(1,this_folder)=peakmin(this_folder,:);
    FL_peak_I(1,this_folder)=peakmin_I(this_folder,:);
    
   PercentMZ(this_folder,:)=PercentInMZ;
    
    
    fnOut= sprintf('%s/PeakImage',PathName);
    save(fnOut, 'ROut');
    fnOut= sprintf('%s/FLMask',PathName);
    save(fnOut, 'FL');
    fnOut= sprintf('%s/StimSite',PathName);
    save(fnOut, 'StimSite');
    fnOut= sprintf('%s/FLMZMask',PathName);
    save(fnOut, 'FLMZ');
end
 output(1,:)=FL_skew_this_slice_distance_btw;
 output(2,:)=FL_skew_this_slice;
 output(3,:)=FL_skew_this_slice_stim;
    output(4,:)=FL_peak;
    output(5,:)=FL_skew_this_slice_I;
    output(6,:)=FL_skew_this_slice_stim_I;
    output(7,:)=FL_peak_I;
fnOut=sprintf('%s/SkewedNessOutputtxt2',directoryname);
save(fnOut,'output','-tabs','-ascii');
fnOut=sprintf('%s/AfferentProfiling_I',directoryname);
save(fnOut,'Profile_I');
fnOut=sprintf('%s/AfferentProfiling',directoryname);
save(fnOut,'Profile');
fnOut=sprintf('%s/AfferentProfiling_I.txt',directoryname);
save(fnOut,'Profile_I','-tabs','-ascii');
fnOut=sprintf('%s/AfferentProfiling.txt',directoryname);
save(fnOut,'Profile','-tabs','-ascii');
fnOut=sprintf('%s/AfferentProfiling_otherDirection',directoryname);
save(fnOut,'Profile_otherDir_I');
fnOut=sprintf('%s/AplfferentProfiling_FileNames',directoryname);
save(fnOut,'ddir3');      

fnOut=sprintf('%s/Stim_Loc.txt',directoryname);
save(fnOut,'stim_out','-tabs','-ascii');  
fnOut=sprintf('%s/FL_Loc.txt',directoryname);
save(fnOut,'FL_out','-tabs','-ascii'); 

fnOut=sprintf('%s/Peak_Loc.txt',directoryname);
save(fnOut,'peakloc','-tabs','-ascii'); 

fnOut=sprintf('%s/Peak_Loc_I.txt',directoryname);
save(fnOut,'peakloc_I','-tabs','-ascii'); 

fnOut=sprintf('%s/Peak_Val.txt',directoryname);
save(fnOut,'peakmin','-tabs','-ascii'); 

fnOut=sprintf('%s/Peak_Val_I.txt',directoryname);
save(fnOut,'peakmin_I','-tabs','-ascii'); 

fnOut=sprintf('%s/PercentMZ.txt',directoryname);
save(fnOut,'PercentMZ','-tabs','-ascii'); 
