clear all;
directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
path1dir=sprintf('%s/*Slice*',directoryname);
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
ROI_Holder={numfilesdir};
FL_Holder={numfilesdir};
Int_Holder={numfilesdir};
Norm_Holder={numfilesdir};
master_map=zeros(64,200);
master_map_ROI=zeros(64,200);
master_map_FRET=zeros(64,200);


for this_slice=1:size(dddir,1)
trail=zeros(64,128);
centering=zeros(64,128);
clear ROI_temp_t;
    %%%  Get the ROI mat file
    PathName=sprintf('%s/%s/New_analysis_6_30_2009/', directoryname,dddir(this_slice,:));
    search_folder_ROI=sprintf('%s*ROI_Logicals_2009*',PathName);
    ddir = dir (search_folder_ROI);
    NumberGlut=length(ddir);
    if NumberGlut<1
     disp('No files found');
    end

    %%%  Get the FL mat file
    PathName=sprintf('%s/%s/New_analysis_6_30_2009/', directoryname,dddir(this_slice,:));
    search_folder_FL=sprintf('%s*FL_Logical_2009*',PathName);
    FLdir = dir (search_folder_FL);
    NumberGlut=length(FLdir);
    if NumberGlut<1
     disp('No files found');
    end
    
     %%%  Get the FL mat file
    PathName=sprintf('%s/%s/New_analysis_6_30_2009/', directoryname,dddir(this_slice,:));
    search_folder_FRET=sprintf('%s*FRET_Logical_2009*',PathName);
    FRETdir = dir (search_folder_FRET);
    NumberGlut=length(FLdir);
    if NumberGlut<1
     disp('No files found');
    end

    
         %%%  Get the FL mat file
    PathName=sprintf('%s/%s/New_analysis_6_30_2009/', directoryname,dddir(this_slice,:));
    search_folder_Int=sprintf('%s*Integrated_map*',PathName);
    Intdir = dir (search_folder_Int);
    NumberInt=length(Intdir);
    if  NumberInt<1
     disp('No files found');
    end
    
         %%%  Get the FL mat file
    PathName=sprintf('%s/%s/New_analysis_6_30_2009/', directoryname,dddir(this_slice,:));
    search_folder_Norm=sprintf('%s*Norm*',PathName);
    Normdir = dir (search_folder_Norm);
    NumberNorm=length(Normdir);
    if NumberNorm<1
     disp('No files found');
    end
    
fn=sprintf('%s%s',PathName,ddir.name);
fn_FL=sprintf('%s%s',PathName,FLdir.name);
fn_FRET=sprintf('%s%s',PathName,FRETdir.name);
fn_Int=sprintf('%s%s',PathName,Intdir.name);
fn_Norm=sprintf('%s%s',PathName,Normdir.name);


ROI_Holder{this_slice}=open(fn);
FL_Holder{this_slice}=open(fn_FL);
FRET_Holder{this_slice}=open(fn_FRET);
Int_Holder{this_slice}=open(fn_Int);
Norm_Holder{this_slice}=open(fn_Norm);

this_mask=find(FL_Holder{1,this_slice}.FL_image==1);
trail(this_mask)=this_slice;

centering(this_mask)=1;
centering_profile_compressed=mean(centering);
[sum, loc]=max(centering_profile_compressed);
adjust(this_slice)=100-loc;

pad_ROI=zeros(64,adjust(this_slice));
pad_FL=zeros(64,adjust(this_slice));
otherside=zeros(64, 200-adjust(this_slice)-size(centering,2));

ROI_temp=ROI_Holder{1,this_slice}.ROI_logicals;
FL_temp=FL_Holder{1,this_slice}.FL_image;
FRET_temp=FRET_Holder{1,this_slice}.FRET_logicals;
for i=1:5
    starting=squeeze(ROI_temp(i,:,:));
    middle=horzcat(pad_ROI,starting);
    last=horzcat(middle,otherside);
    ROI_temp_t(i,:,:)=last;
    
    Fstarting=squeeze(FRET_temp(i,:,:));
    Fmiddle=horzcat(pad_ROI,Fstarting);
    Flast=horzcat(Fmiddle,otherside);
    FRET_temp_t(i,:,:)=Flast;
    
end
FL_temp=horzcat(pad_FL, FL_temp);
FL_temp=horzcat(FL_temp,otherside);
ROI_adjusted{this_slice}=ROI_temp_t;
FL_adjusted{this_slice}=FL_temp;
FRET_adjusted{this_slice}=FRET_temp_t;

adjusted_FL=find(FL_temp==1);
adjusted_ROI=find(ROI_temp_t(1,:,:)==1);
this_slice_FRET_Hotspots=zeros(64,200);
tempFRET=FRET_temp_t(1,:,:);
FRET_hot=find(tempFRET<0);

this_slice_FRET_Hotspots(FRET_hot)=tempFRET(FRET_hot);
Map_output{this_slice}=this_slice_FRET_Hotspots;
master_map_FRET=master_map_FRET+this_slice_FRET_Hotspots;
clear this_slice_FRET_Hotspots;
master_map(adjusted_FL)=this_slice;
master_map_ROI(adjusted_ROI)=this_slice;


end


