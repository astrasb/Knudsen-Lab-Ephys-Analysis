%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This code opens all Redshirt Files within a selected folder, and creates
%  ratioed, normalized images of every frame from every file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
ROI_ON=0;
FLcount=0;
Ccount=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Create File List    %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opening top most directory
directoryname = uigetdir('/mnt/m022a/FL_LP_Round2');                                 %%%% Opens files from my shared drive
%directoryname = uigetdir('/mnt/newhome/mirror/home/c;/hris/MATLAB/');    %%%%% Opens files from MATLAB directory

path1dir=sprintf('%s/',directoryname);
ddir = dir (path1dir);
numfilesdir=length(ddir)-2;
if numfilesdir<1
    disp('No files found');
end

for i = 1:numfilesdir
    t = length(getfield(ddir,{i+2},'name')) ;
    dddir(i, 1:t) = getfield(ddir,{i+2},'name') ;
end
counter=0;

%%%  Look for a Control/GABAzine trials

path21222=sprintf('%s/*FileNumbers*',directoryname);
d21222 = dir (path21222);
numfiles21222=length(d21222);
if numfiles21222<1
    disp('No files found');
    paramfound_y_n=0;
else
    paramfound_y_n=1;
end

if paramfound_y_n==1
    
    for i = 1:numfiles21222
        t = length(getfield(d21222,{i},'name')) ;
        dd21222(i, 1:t) = getfield(d21222,{i},'name') ;
    end
    params_in1222=open(sprintf('%s/%s',directoryname,dd21222));
    this_sl=params_in1222;
    this_one=this_sl.this_one;
end


%%%  Look for a FL/Contra file

pathFL=sprintf('%s/*FL_yes_or_no*',directoryname);
dFL= dir (pathFL);
numfilesFL=length(dFL);
if numfilesFL<1
    disp('No files found');
    paramfound_FL=0;
else
    paramfound_FL=1;
end

if paramfound_FL==1
    
    for i = 1:numfilesFL
        t = length(getfield(dFL,{i},'name')) ;
        ddFL(i, 1:t) = getfield(dFL,{i},'name') ;
    end
    params_inFL=open(sprintf('%s/%s',directoryname,ddFL));
    this_Fl=params_inFL;
    FL=this_Fl.FL;
end
% Opening each day's folder
for number_of_directories=1:numfilesdir
    
    subdirectoryname=sprintf('%s/%s',directoryname,ddir(number_of_directories+2,:).name);
    path1slice=sprintf('%s/%s',directoryname,ddir(number_of_directories+2,:).name);
    dslice = dir (path1slice);
    numfilesslice=length(dslice)-2;
    if numfilesslice<1
        disp('No files found');
    end
    
    for i = 1:numfilesslice
        t = length(getfield(dslice,{i+2},'name')) ;
        ddslice(i, 1:t) = getfield(dslice,{i+2},'name') ;
    end
    clear dadir;
    
    for number_of_slices=1:numfilesslice
        counter=counter+1;
        if FLcount==11;
            pause=1;
        end
        slicesubdirectoryname=sprintf('%s/%s/%s',directoryname,dddir(number_of_directories,:),ddslice(number_of_slices,:));
        path1dafile=sprintf('%s/%s/*.da*',subdirectoryname,ddslice(number_of_slices,:));
        dadir = dir (path1dafile);
        numfiles=length(dadir);
        if numfiles<1
            disp('No files found');
        end
        clear daddir;
        clear dd2;
        clear d2;
        clear dd212;
        clear dd21;
        clear dd2122;
        for i = 1:numfiles
            t = length(getfield(dadir,{i},'name')) ;
            daddir(i, 1:t) = getfield(dadir,{i},'name') ;
        end
        %%%  Look for a Parameter file
        path2=sprintf('%s/%s/*param*',subdirectoryname,ddslice(number_of_slices,:));
        d2 = dir (path2);
        numfiles2=length(d2);
        if numfiles2<1
            disp('No files found');
            paramfound=0;
        else
            paramfound=1;
        end
        
        if paramfound==1
            clear dd2;
            for i = 1:numfiles2
                t = length(getfield(d2,{i},'name')) ;
                dd2(i, 1:t) = getfield(d2,{i},'name') ;
            end
            params_in=open(sprintf('%s/%s',slicesubdirectoryname,dd2));
            Outside_Mask=params_in.params.mask;
            Rot=params_in.params.rot;
            stim_loc_data=params_in.params.stim_loc;
        end
        
        
        %%%  Look for a Stim_FL Parameter file
        path21=sprintf('%s/%s/*FL_stim_loc*',subdirectoryname,ddslice(number_of_slices,:));
        d21 = dir (path21);
        numfiles21=length(d21);
        if numfiles21<1
            disp('No files found');
            paramfound1=0;
        else
            paramfound1=1;
        end
        
        if paramfound1==1
            
            for i = 1:numfiles21
                t = length(getfield(d21,{i},'name')) ;
                dd21(i, 1:t) = getfield(d21,{i},'name') ;
            end
            params_in1=open(sprintf('%s/%s',slicesubdirectoryname,dd21));
            stim_loc_data=params_in1.geometery.stim;
            FL_loc_data=params_in1.geometery.freeze;
        end
        
        %%%  Look for a Mask file
        path212=sprintf('%s/%s/*MZ_mask*',subdirectoryname,ddslice(number_of_slices,:));
        d212 = dir (path212);
        numfiles212=length(d212);
        if numfiles212<1
            disp('No files found');
            paramfound12=0;
        else
            paramfound12=1;
        end
        
        if paramfound12==1
            
            for i = 1:numfiles212
                t = length(getfield(d212,{i},'name')) ;
                dd212(i, 1:t) = getfield(d212,{i},'name') ;
            end
            params_in12=open(sprintf('%s/%s',slicesubdirectoryname,dd212));
            MZmask=params_in12.masks.MZ;
            AMZmask=params_in12.masks.MZ_Active;
            APMZmask=params_in12.masks.PMZ_Active;
            
        end
        
        %%%  Look for a NTB Data file
        path2122=sprintf('%s/%s/*NTB_ROI_DATA*',subdirectoryname,ddslice(number_of_slices,:));
        d2122 = dir (path2122);
        numfiles2122=length(d2122);
        if numfiles2122<1
            disp('No files found');
            paramfound122=0;
        else
            paramfound122=1;
        end
        
        if paramfound122==1
            
            for i = 1:numfiles2122
                t = length(getfield(d2122,{i},'name')) ;
                dd2122(i, 1:t) = getfield(d2122,{i},'name') ;
            end
            params_in122=open(sprintf('%s/%s',slicesubdirectoryname,dd2122));
            data=params_in122;
            
        end
        
        
        
        
        
        Activated_Area=data.NTB_ROI_DATA.Activated_Area;
        
        MZ=data.NTB_ROI_DATA.Activated_Area_MZ;
        PMZ=data.NTB_ROI_DATA.Activated_Area_PMZ;
        T5=data.NTB_ROI_DATA.NTB_Activated_Area_05;
        T10=data.NTB_ROI_DATA.NTB_Activated_Area_10;
        T5_sub=data.NTB_ROI_DATA.NTB_Activated_Area_05_sub;
        T10_sub=data.NTB_ROI_DATA.NTB_Activated_Area_10_sub;
        
        this_many=1;
        
        if paramfound_y_n==0
            plot(Activated_Area');
            prompt = {'How many of these should be included?                 '};
            dlg_title = 'NO GABAZINE PLEASE              ';
            num_lines = 1;
            def = {num2str(this_many)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            this_one(1,counter)=str2num(answer{1,1});
        end
        
        AA_ave=mean(Activated_Area(1:this_one(counter),:));
        MZ_ave=mean(MZ(1:this_one(counter),:));
        PMZ_ave=mean(PMZ(1:this_one(counter),:));
        T5_ave=mean(T5(1:this_one(counter),:));
        T10_ave=mean(T10(1:this_one(counter),:));
        T5_ave_sub=mean(T5_sub(1:this_one(counter),:));
        T10_ave_sub=mean(T10_sub(1:this_one(counter),:));
        
        FL_Loc(counter)=FL_loc_data(1,2);
        
        if 2>5
        if FL_Loc(counter)<5
            FL(counter)=0;
        else
            FL(counter)=1;
        end
        end
        if paramfound_FL==0
             plot( AA_ave');
            prompt = {sprintf('Is %s a FL? 1=Yes, 0=No',slicesubdirectoryname)                 };
            dlg_title = 'NO GABAZINE PLEASE              ';
            num_lines = 1;
            def = {num2str(this_many)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            FL(counter)=str2num(answer{1,1});
        end
        
        dist(counter)=stim_loc_data(1,2)-FL_loc_data(1,2);
        
        
        if FL(counter)==0
            Ccount=Ccount+1;
            Cdata(1,Ccount,:)=AA_ave;
            Cdata(2,Ccount,:)=MZ_ave;
            Cdata(3,Ccount,:)=PMZ_ave;
            Cdata(4,Ccount,:)=T5_ave;
            Cdata(5,Ccount,:)=T10_ave;
            Cdata(6,Ccount,:)=T5_ave_sub;
            Cdata(7,Ccount,:)=T10_ave_sub;
            
        else
            FLcount=FLcount+1;
            FLdata(1,FLcount,:)=AA_ave;
            FLdata(2,FLcount,:)=MZ_ave;
            FLdata(3,FLcount,:)=PMZ_ave;
            FLdata(4,FLcount,:)=T5_ave;
            FLdata(5,FLcount,:)=T10_ave;
            FLdata(6,FLcount,:)=T5_ave_sub;
            FLdata(7,FLcount,:)=T10_ave_sub;
            FLdist(1,FLcount)=dist(counter);
            MZvsPMZratio(1,FLcount)=size(AMZmask,1)/(size(AMZmask,1)+size(APMZmask,1));
            MZsize(1,FLcount)=size(AMZmask,1);
        end
    end
end
FileNumber_filename=sprintf('%s/FileNumbers.mat',directoryname);
save(FileNumber_filename,'this_one');
FL_Y_filename=sprintf('%s/FL_yes_or_no.mat',directoryname);
save(FL_Y_filename,'FL');
FL_Y_filename=sprintf('%s/FL_data.mat',directoryname);
save(FL_Y_filename,'FLdata');
FL_Y_filename=sprintf('%s/Contra_data.mat',directoryname);
save(FL_Y_filename,'Cdata');

FL_DFRET=mean(squeeze(FLdata(1,:,:)));
FL_T5=mean(squeeze(FLdata(4,:,:)));
FL_T10=mean(squeeze(FLdata(5,:,:)));
C_DFRET=mean(squeeze(Cdata(1,:,:)));
C_T5=mean(squeeze(Cdata(4,:,:)));
C_T10=mean(squeeze(Cdata(5,:,:)));


FL_DFRET_s=std(squeeze(FLdata(1,:,:)))/sqrt(size(FLdata,2));
FL_T5_s=std(squeeze(FLdata(4,:,:)))/sqrt(size(FLdata,2));
FL_T10_s=std(squeeze(FLdata(5,:,:)))/sqrt(size(FLdata,2));
C_DFRET_s=std(squeeze(Cdata(1,:,:)))/sqrt(size(Cdata,2));
C_T5_s=std(squeeze(Cdata(4,:,:)))/sqrt(size(Cdata,2));
C_T10_s=std(squeeze(Cdata(5,:,:)))/sqrt(size(Cdata,2));


FLMZ=squeeze(FLdata(2,:,:));
pFLMZ=squeeze(FLdata(3,:,:));
FLall=squeeze(FLdata(1,:,:));

for i=1:19
    FLmin(i)=min(smooth(smooth(FLall(i,:))));
    FLMZmin(i)=min(smooth(smooth(FLMZ(i,:))));
    FLPMZmin(i)=min(smooth(smooth(pFLMZ(i,:))));
    Whichy(i)=FLMZmin(i)-FLPMZmin(i);
    [loc val]=find(FLall(i,:)<(FLmin(i)/2));
    All_half(i)=val(size(val,2));
    [loc valMZ]=find(FLMZ(i,:)<(FLMZmin(i)/2));
    MZ_half(i)=valMZ(size(valMZ,2));
    [loc valPMZ]=find(pFLMZ(i,:)<(FLPMZmin(i)/2));
    PMZ_half(i)=valPMZ(size(valPMZ,2));
    Subtracted(i,:)=smooth(smooth(FLMZ(i,:)))-smooth(smooth(pFLMZ(i,:)));
    MZsm(i,:)=smooth(smooth(FLMZ(i,:)));
    PMZsm(i,:)=smooth(smooth(pFLMZ(i,:)));
    Sub_norm(i,:)=(smooth(smooth(FLMZ(i,:)))/FLMZmin(i))-(smooth(smooth(pFLMZ(i,:)))/FLPMZmin(i));
    NormMZ(i,:)=(smooth(smooth(FLMZ(i,:)))/FLMZmin(i));
    NormPMZ(i,:)=(smooth(smooth(pFLMZ(i,:)))/FLPMZmin(i));
    PeakMZPMZdiff(i)=max(abs(MZsm(i,:)))-max(abs(PMZsm(i,:)));
    
    MZLP_late(i)=mean(smooth(smooth(FLMZ(i,600:800))));
    PMZLP_late(i)=mean(smooth(smooth(pFLMZ(i,600:800))));
    
end

for i=1:19
    
    M_max=min(MZsm(i,:));
    PM_max=min(PMZsm(i,:));
    
    [loc valMN]=find(MZsm(i,:)<(M_max/2));
    M_half(i)=valMN(size(valMN,2));
    [loc valPMN]=find(PMZsm(i,:)<(PM_max/2));
    PM_half(i)=valPMN(size(valPMN,2));
    HW_diff(i)=M_half(i)-PM_half(i);

    
end

for i=1:19
    subplot(3,1,1)
    plot(1:1000,MZsm(i,:),1:1000,PMZsm(i,:));
    subplot(3,1,2)
    plot(1:1000,FLMZ(i,:),1:1000,pFLMZ(i,:));
    subplot(3,1,3)
    plot(1:1000,NormMZ(i,:),1:1000,NormPMZ(i,:));
    close all;
end

NormMZ_S=NormMZ;
NormPMZ_S=NormPMZ;
Sub_norm_S=Sub_norm;
PMZsm_S=PMZsm;
MZsm_S=MZsm;
HW_diff_S=HW_diff;
Subtracted_S=Subtracted;
M_half_S=M_half;
PM_half_S=PM_half;





for i=1:5;
   
    gone=[18,14,12,11,10];
    
    NormMZ_S(gone(i),:)=[];
    NormPMZ_S(gone(i),:)=[];
    Sub_norm_S(gone(i),:)=[];
    PMZsm_S(gone(i),:)=[];
    MZsm_S(gone(i),:)=[];
    Subtracted_S(gone(i),:)=[];
    HW_diff_S(:,gone(i))=[];
    M_half_S(:,gone(i))=[];
    PM_half_S(:,gone(i))=[];
    MZLP_late(i)=[];
    PMZLP_late(i)=[];
end

for i=1:7
Cmin(i)=min(smooth(smooth(hh(i,:))));
[loc val]=find(hh(i,:)<(Cmin(i)/2));
C_half(i)=val(size(val,2));
NormC(i,:)=(smooth(smooth(hh(i,:)))/Cmin(i));
C_late(i)=mean(smooth(smooth(hh(i,600:800))));  
end