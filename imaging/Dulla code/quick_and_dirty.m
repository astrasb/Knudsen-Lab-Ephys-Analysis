%%%%%%%%  Hippocampal Glutamate Imaging          %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
parameters_present=0;
[RGBCustom]=CreateRGBColorTableInverted;

directoryname = uigetdir('/mnt/m022a');

%%%% Opens files from my shared drive
    path1dir=sprintf('%s/*tit*',directoryname);
    ddirx = dir (path1dir);
    numfilesdir=length(ddirx);
    if numfilesdir<1
        disp('No files found');
    end
    
    %%%% Get Brightfield File Name
    path2dir=sprintf('%s/*righ*',directoryname);
    ddir2 = dir (path2dir);
    numfilesdir2=length(ddir2);
    if numfilesdir2<1
        disp('No files found');
    end
    fnb=sprintf('%s/%s',directoryname,ddir2(1,:).name);
    [Bright,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(fnb);
    bright=Bright.data;
for this_image=1:numfilesdir
        
    
        clear NumberGlut;
        clear fn;
        clear Ch1_fit_results;
        clear Ch2_fit_results;
        %%%  Get the Glut perfusion andor file
        
        fn=sprintf('%s/%s',directoryname,ddirx(this_image,:).name);
        [Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(fn)
        temp=Image.data;
        fn
        %%%% Detect Shutter Opening and Closing
        shutter_scan=squeeze(mean(mean(temp)));
        shutter_deriv=diff(shutter_scan);
        [waste, shutter_open_frame]=max(shutter_deriv);
        [waste, shutter_close_frame]=min(shutter_deriv);
        dark=FrameAverage(temp,2,shutter_open_frame-2);
        temp(:,:,shutter_close_frame-5:size(temp,3))=[];
        temp(:,:,1:shutter_open_frame+8)=[];
        %%%%%%%%%%  Darkfield subtraction
        for i=1:size(temp,3)
            tempframe=temp(:,:,i);
            tempframe=tempframe-dark;
            temp(:,:,i)=tempframe;
            
        end
        %%%%% Breaking up Ch1 and Ch2
        ch1=temp(1:size(temp,1)/2,:,:);
        ch2=temp(size(temp,1)/2+1:size(temp,1),:,:);
        ch1tofit=squeeze(mean(mean(ch1)));
        ch2tofit=squeeze(mean(mean(ch2)));
        
        %%%% Plotting the means of Ch1 and Ch2 for Curve fitting
        StimFrame=75;
        ratio=ch1./ch2;
        PreStim=FrameAverage(ratio, StimFrame-10, StimFrame-5);
        PostStim=FrameAverage(ratio,StimFrame+5, StimFrame+10);
        Response(this_image,:,:)=PostStim-PreStim;
        
        for i=1:size(ratio,3)
        
        Subt(:,:,i)=ratio(:,:,i)-PreStim;
        
        end
        
        %%% Integrated Response Analysis
        Int_Response=zeros(size(PreStim,1),size(PreStim,2));
        for i=1:10
            this_frame=ratio(:,:,StimFrame+2+i)-PreStim;
            Int_Response=Int_Response+this_frame;
        end
        Int_Res_out(this_image,:,:)=Int_Response;
    
    ROutI=squeeze(mean(Int_Res_out));
    ROut=squeeze(mean(Response));
    ROut=Gaussian_Filter_streamlined(ROut, 2, 0.5);
    ROutI=Gaussian_Filter_streamlined(ROutI, 2, 0.5);
    Int_Response=Gaussian_Filter_streamlined(Int_Response, 2, 0.5);
    
    image(ROut,'cdatamapping','scaled')
    outside=zeros(size(ROut,1),size(ROut,2));
    outside(1,:)=1;
    outside(:,1)=1;
    outside(size(outside,1),:)=1;
    outside(:,size(outside,2))=1;
    out=find(outside==1);
    in=find(outside==0);
    ROut(out)=0;
    Int_Response(out)=0;
    
    fnB=sprintf('%s/%s',PathName,ddir2(1,:).name);
    [ImageB,InstaImageB,CalibImageB,versB]=andorread_chris_local_knownfilename(fnB);
    Bright=ImageB.data;
    image(Bright(1:size(Bright,1)/2,:),'cdatamapping','scaled');
    colormap('gray')
    if FLMaskFound~=1
    Happiness=questdlg('Draw the Freeze Lesion (put an ROI in the upper left corner if Contra)','GOULET INC');
    FL=roipoly;
    end
    if StimFound~=1
    Happiness=questdlg('Draw the Stim Site','GOULET INC');
    StimSite=roipoly;
    end
    close
    
    [waste Stim_loc]=max(sum(StimSite));
    [waste FL_loc]=max(sum(FL));
    
    
    vert=mean(ROutI);
    vert=smooth(vert);
    Profile(this_folder,:)=vert;
    vert_I=mean(Int_Response);
    vert_I=smooth(vert_I);
    Profile_I(this_folder,:)=vert_I;
    
    [peakmin peakloc]=min(vert);
    peak_50=peakmin*0.5;
    [ location50 values ]=find(vert<peak_50);
    loc1=location50(1);
    loc2=location50(size(values,1));
    
    [peakmin_I peakloc_I]=min(vert_I);
    peak_50_I=peakmin_I*0.5;
    [ location50_I values_I ]=find(vert_I<peak_50_I);
    loc1_I=location50_I(1);
    loc2_I=location50_I(size(values_I,1));
    if peakloc_I>2&peakloc_I<size(Int_Response,2)-2
    Profile_otherDir_I(this_folder,:)=mean(ROut(:,peakloc_I-2:peakloc_I+2)');
    end
    
    orientation=FL_loc-Stim_loc;
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
        FL_skew_this_slice_stim(1,this_folder)=(peakloc-Stim_loc);
        FL_skew_this_slice_stim_I(1,this_folder)=(peakloc_I-Stim_loc);
    else
        FL_skew_this_slice_stim(1,this_folder)=-(peakloc-Stim_loc);
        FL_skew_this_slice_stim_I(1,this_folder)=-(peakloc_I-Stim_loc);
    end
    FL_peak(1,this_folder)=peakmin;
    FL_peak_I(1,this_folder)=peakmin_I;
    
   
    
    
    fnOut= sprintf('%s/PeakImage',PathName);
    save(fnOut, 'ROut');
    fnOut= sprintf('%s/FLMask',PathName);
    save(fnOut, 'FL');
    fnOut= sprintf('%s/StimSite',PathName);
    save(fnOut, 'StimSite');
    

end