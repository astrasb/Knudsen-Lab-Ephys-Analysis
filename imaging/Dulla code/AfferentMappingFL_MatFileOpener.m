clear all
f_count=0;
c_count=0;
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
path1dir=sprintf('%s/*FL*',PathName);
FLdir = dir (path1dir);
numfilesdir=length(FLdir);
if numfilesdir<1
    disp('No files found');
end

%%%% Get Brightfield File Name
path2dir=sprintf('%s/*Stim*',PathName);
Stimdir = dir (path2dir);
numfilesdir2=length(Stimdir);
if numfilesdir2<1
    disp('No files found');
end

%%%% Get Brightfield File Name
path2dir=sprintf('%s/*Peak*',PathName);
Peakdir = dir (path2dir);
numfilesdir2=length(Peakdir);
if numfilesdir2<1
    disp('No files found');
end

%%%%  Enter the First Slice folder and process it


    Peakfn=sprintf('%s/%s',PathName,Peakdir(1,1).name);
    Peak=open(Peakfn);
    FLfn=sprintf('%s/%s',PathName,FLdir(1,1).name);
    FL_=open(FLfn);
    Stimfn=sprintf('%s/%s',PathName,Stimdir(1,1).name);
    Stim_=open(Stimfn);
    
    Data=Peak.ROut;
    FL=FL_.FL;
    Stim=Stim_.StimSite;
    
    
   [waste Stim_loc]=max(sum(Stim));
   [waste FL_loc]=max(sum(FL));
   
   image(Data,'cdatamapping','scaled')
   m=roipoly;
   outside=find(m==0);
   Data(outside)=0;
    
   vert=mean(Data);
   vert=smooth(vert);
   horiz=mean(Data');
   Profile(this_folder,:)=vert;
   
   [peakmin peakloc]=min(vert);
    peak_50=peakmin*0.5;
    [ location50 values ]=find(vert<peak_50);
    loc1=location50(1);
    loc2=location50(size(values,1));
   
    
        orientation=FL_loc-Stim_loc;
        skew_val=(loc1-Stim_loc)+(loc2-Stim_loc);
        if orientation>0
           skew_val=-skew_val;            
        end
        FL_skew_this_slice(1,this_folder)=skew_val;
        FL_skew_this_slice_distance_btw(1,this_folder)=abs(orientation);
        if orientation>0
        FL_skew_this_slice_stim(1,this_folder)=(peakloc-Stim_loc);
        else
        FL_skew_this_slice_stim(1,this_folder)=-(peakloc-Stim_loc);
        end
         FL_peak(1,this_folder)=peakmin;
        
    
        
    

end
