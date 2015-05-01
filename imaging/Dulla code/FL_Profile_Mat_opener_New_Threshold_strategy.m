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
     %%%  Get the FL mat file
    PathName=sprintf('%s/%s/New_analysis_6_30_2009/', directoryname,dddir(this_slice,:));
    search_folder_ons=sprintf('%s*onset*',PathName);
    onsdir = dir (search_folder_ons);
    Numberons=length(onsdir);
    if  Numberons<1
     disp('No files found');
    end
    
    
% Open Files
fn_FL=sprintf('%s%s',PathName,FLdir.name);
fn_Int=sprintf('%s%s',PathName,Intdir.name);
fn_Norm=sprintf('%s%s',PathName,Normdir.name);
fn_Ons=sprintf('%s%s',PathName,onsdir.name);

FL_Holder{this_slice}=open(fn_FL);
Int_Holder{this_slice}=open(fn_Int);
Norm_Holder{this_slice}=open(fn_Norm);
Ons_Holder{this_slice}=open(fn_Ons);

%Align Integrated Images based on FL location
this_mask=find(FL_Holder{1,this_slice}.FL_image==1);
trail(this_mask)=this_slice;
centering(this_mask)=1;
centering_profile_compressed=mean(centering);
[sum, loc]=max(centering_profile_compressed);
adjust(this_slice)=100-loc;
pad_Int=zeros(size(Int_Holder{1,this_slice}.integrated_peak_rot,1),adjust(this_slice));
otherside=zeros(size(Int_Holder{1,this_slice}.integrated_peak_rot,1), 200-adjust(this_slice)-size(centering,2));
FL_temp=FL_Holder{1,this_slice}.FL_image;
starting=squeeze(Int_Holder{1,this_slice}.integrated_peak_rot);
middle=horzcat(pad_Int,starting);
last=horzcat(middle,otherside);
    
starting_Ons=squeeze(Ons_Holder{1,this_slice}.integrated_glut_application_rot);
middle_Ons=horzcat(pad_Int,starting_Ons);
last_Ons=horzcat(middle,otherside);


%Check Alignment with FL maps
FL_temp=horzcat(pad_Int, FL_temp);
FL_temp=horzcat(FL_temp,otherside);
FL_adjusted{this_slice}=FL_temp;
FRET_adjusted{this_slice}=last;
adjusted_FL=find(FL_temp==1);

if size(last,1)<64
   filler=zeros((64-size(last,1))/2,size(last,2));
   last=vertcat(filler,last);
   last=vertcat(last,filler) ; 
    
end

if size(last_Ons,1)<64
   filler_Ons=zeros((64-size(last_Ons,1))/2,size(last_Ons,2));
   last_Ons=vertcat(filler_Ons,last_Ons);
   last_Ons=vertcat(last_Ons,filler_Ons) ; 
    
end
output{this_slice}=last;
output_Ons{this_slice}=last_Ons;

end









