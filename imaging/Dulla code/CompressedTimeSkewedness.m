clear all;
directoryname = uigetdir('/mnt/m022a');  % Open Top Level directory - each folder must contain a brightfield Tiff(Cooke), brightfield sif, PClamp file, and relevant sif files
dir_tree = dirr(directoryname, 'profile.m'); % Use dirr to create the directory sturcture variable
folders=size(dir_tree,1); % determine the number of folder (approx equal to number of slices)

c_count=0;
f_count=0;
for thisfolder=1:folders;  %%%%%  Begin crawling through the folders 
    number_slices=size(dir_tree(thisfolder,1).isdir,1);
    for thisfile=1:number_slices
               
    searchparameter2=sprintf('%s/%s/%s/*FL_stim*',directoryname,dir_tree(thisfolder,1).name,dir_tree(thisfolder,1).isdir(thisfile,1).name );
    
    %%%  Look for a Parameter file
        d3 = dir (searchparameter2);
        numfiles3=length(d3);
        if numfiles3<1
            disp('No files found');
            paramfound=0;
        else
            paramfound=1;
        end
        
        if paramfound==1
            
            locations=open(sprintf('%s/%s/%s/%s',directoryname,dir_tree(thisfolder,1).name,dir_tree(thisfolder,1).isdir(thisfile,1).name, d3.name));
            FL_site=round(locations.geometery.freeze(2));
            stim_loc_data=round(locations.geometery.stim(2));
        end
    
        
    profile=open(sprintf('%s/%s/%s/%s', directoryname, dir_tree(thisfolder,1).name, dir_tree(thisfolder,1).isdir(thisfile,1).name, dir_tree(thisfolder,1).isdir(thisfile,1).isdir.name));
    thismap=profile.profile;
    stimlocation=stim_loc_data;
    clear forskew;
    clear forskewclipped;
    for i=1:3
        forskew(i,:)=smooth(squeeze(mean(thismap(i,30:50,:))));
                    
    end
    
    thisskew=squeeze(mean(forskew));
    thisskew=smooth(smooth(thisskew));  
    [peakmin peakloc]=min(thisskew);
    peak_50=peakmin*0.5;
    [ location50 values ]=find(thisskew>peak_50);
    [val diffloc]=max(diff(location50));
    
    if thisfolder==5
        pause=1
    end
    if FL_site>10
        f_count=f_count+1;
        orientation=FL_site-stimlocation;
        skew_val=(location50(diffloc)-peakloc)+(location50(diffloc+1)-peakloc);
        if orientation>0
           skew_val=-skew_val;            
        end
        FL_skew_this_slice(thisfile,thisfolder)=skew_val;
        FL_skew_this_slice_distance_btw(thisfile,thisfolder)=abs(orientation);
        if orientation>0
        FL_skew_this_slice_stim(thisfile,thisfolder)=(peakloc-stimlocation);
        else
        FL_skew_this_slice_stim(thisfile,thisfolder)=-(peakloc-stimlocation);
        end
        filetracker{thisfile,thisfolder}=sprintf('%s/%s/%s/%s', directoryname, dir_tree(thisfolder,1).name, dir_tree(thisfolder,1).isdir(thisfile,1).name, dir_tree(thisfolder,1).isdir(thisfile,1).isdir.name);
        filetracker_B(thisfile,thisfolder)=1;
        fl_combined(f_count,2)=skew_val;
        fl_combined(f_count,1)=abs(orientation);
        fl_combined(f_count,3)=FL_skew_this_slice_stim(thisfile,thisfolder);
        fl_combined(f_count,4)=peakmin;
        
    else
        c_count=c_count+1;
        skew_val=(location50(diffloc)-peakloc)+(location50(diffloc+1)-peakloc);
        Contra_skew_this_slice(thisfile,thisfolder)=skew_val;
        Contra_skew_this_slice_stim(thisfile,thisfolder)=(peakloc-stimlocation);
        
       c_combined(c_count,1)=skew_val;
       c_combined(c_count,2)=(peakloc-stimlocation);
        c_combined(c_count,3)=peakmin;
        
        filetracker{thisfile,thisfolder}=sprintf('%s/%s/%s/%s', directoryname, dir_tree(thisfolder,1).name, dir_tree(thisfolder,1).isdir(thisfile,1).name, dir_tree(thisfolder,1).isdir(thisfile,1).isdir.name);
        filetracker_B(thisfile,thisfolder)=2;
    end
    end
    end
    

 