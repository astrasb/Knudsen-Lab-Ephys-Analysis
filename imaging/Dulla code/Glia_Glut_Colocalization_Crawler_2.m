close all
clear all
Cmap=CreateBW_RGBColorTable;


%%% Create color tables for combined image
d=uigetdir('/mnt/m022a/SR101_FL_with_Glut_Perfusion','Choose the Main Folder');
dd=dirr(d);
counter=0;
for day=1:size(dd,1)
    for slice=1:size(dd(day,1).isdir,1)
        counter=counter+1;
        %%%% Find and open Glial Aligned Tiff
        Glia_search=sprintf('%s/%s/%s/*Glia_Scaled_Aligned.tif*',d,dd(day,1).name,dd(day,1).isdir(slice,1).name );
        GD = dir (Glia_search);
        Gnum=length(GD);
        if Gnum<1
            disp('No files found');
        else
        Glia_file=sprintf('%s/%s/%s/%s',d,dd(day,1).name,dd(day,1).isdir(slice,1).name, GD.name );
        
        Glial_Density=importdata(Glia_file);
        Glial_Density=Glial_Density(:,:,2);        
        
        %%%%  Determine the treshold for Glia Intensity
        compensate=find(Glial_Density==0);
        Glial_Density(compensate)=254;
        erase=find(Glial_Density==255);
        Glial_Density(erase)=0;
        testGlia=find(Glial_Density~=0);
        sortedGlia=sort(Glial_Density(testGlia));
        
        [fd dg]=find(diff(sortedGlia)>10);
        first_cut=sortedGlia(fd(1,1));
        second_cut=sortedGlia(fd(2,1));
                                               
        a1g=find(Glial_Density==254);
        a2g=find(Glial_Density==second_cut);
        a3g=find(Glial_Density==first_cut);
        Glia_map=zeros(size(Glial_Density,1),size(Glial_Density,2));
        Glia_map(a1g)=3;
        Glia_map(a2g)=1;
        Glia_map(a3g)=2;
        end
        
        %%%%  Seach for a Glutamate Aligned Tiff

        FRET_search=sprintf('%s/%s/%s/*Glut_Scaled_Aligned.tif*',d,dd(day,1).name,dd(day,1).isdir(slice,1).name );
        FD = dir (FRET_search);
        Fnum=length(FD);
        if Fnum<1
            disp('No Aligned Glut files found');
            colocalization_index(counter)=0;
            file_tracker(counter,:)=FRET_search;
        else
            ohyeahbebe=1;
            Glut_file=sprintf('%s/%s/%s/%s',d,dd(day,1).name,dd(day,1).isdir(slice,1).name, FD.name );
      
            Glut_Signal=importdata(Glut_file);
            
            Glut_Signal=Glut_Signal(:,:,2);
            Glut_Density=Glut_Signal;
             compensate=find(Glut_Signal==0);
        Glut_Signal(compensate)=254;
        erase=find(Glut_Signal==255);
        Glut_Signal(erase)=0;
        erase2=find((Glut_Signal>125)&(Glut_Signal~=254));
        Glut_Signal(erase2)=0;
        testGlut=find(Glut_Signal~=0);
        sortedGlut=sort(Glut_Signal(testGlut));
        
        
        first_cut=sortedGlut(floor(size(sortedGlut,1)*.2),1);
        second_cut=sortedGlut(floor(size(sortedGlut,1)*.4),1);
                                               
        a1g=find(Glut_Signal==254);
        a2g=find((Glut_Signal<=second_cut)&(Glut_Signal>first_cut)&(Glut_Signal~=254));
        a3g=find((Glut_Signal<=first_cut)&(Glut_Signal~=0));
        Glut_map=zeros(size(Glut_Signal,1),size(Glut_Signal,2));
        Glut_map(a1g)=3;
        Glut_map(a2g)=1;
        Glut_map(a3g)=2;
        end
        
        %%%% Find and open Brightfield Andor SIF file
        B_search=sprintf('%s/%s/%s/*rightfield.sif*',d,dd(day,1).name,dd(day,1).isdir(slice,1).name );
        BD = dir (B_search);
        Bnum=length(BD);
        if Bnum<1
            disp(sprintf('No brightfield SIF file found %s',B_search));
        else
        B_file=sprintf('%s/%s/%s/%s',d,dd(day,1).name,dd(day,1).isdir(slice,1).name, BD.name );   
        [BImage,BInstaImage,BCalibImage,Bvers]=andorread_chris_local_knownfilename(B_file);
        Brightfield=BImage.data;
        Brightfield=Brightfield(1:size(Brightfield,2)/2,:);
        Brightfield_scaled=Brightfield*(128/(mean(mean(Brightfield)))*.5);
        tttt=find(Brightfield_scaled>128);
        Brightfield_scaled(tttt)=128;
        ck2=image(Brightfield,'cdatamapping','scaled');
        colormap(gray);
        axis image
        Picture_Filename=sprintf('%s/%s/%s/Brightfield_Andor.tif',d,dd(day,1).name,dd(day,1).isdir(slice,1).name);
        saveas(ck2, Picture_Filename);
        
        %%%% Find and open Brightfield Andor SIF file
        GG_search=sprintf('%s/%s/%s/*Glut_Tiered.mat*',d,dd(day,1).name,dd(day,1).isdir(slice,1).name );
        GGD = dir (GG_search);
        GGnum=length(GGD);
        if GGnum<1
            disp(sprintf('No Tiered Glut Image found %s', GG_search));
        end
        Raw_GlutF=sprintf('%s/%s/%s/%s',d,dd(day,1).name,dd(day,1).isdir(slice,1).name, GGD.name );   
        
        Raw_Glut=open(Raw_GlutF);
        Raw_Glut=Raw_Glut.Glut_map;
        Raw_Glut2=Raw_Glut*40;
        
        Combined_Bright_Glut=Brightfield_scaled+Raw_Glut2;
        cko=image(Combined_Bright_Glut,'cdatamapping','direct');
        colormap(Cmap);
        axis image
        Picture_Filename=sprintf('%s/%s/%s/Combined_Andor.tif',d,dd(day,1).name,dd(day,1).isdir(slice,1).name);
        saveas(cko, Picture_Filename);
     
        coloc=Glia_map.*Glut_map;
        ckn=figure(3);
        image(coloc,'cdatamapping','scaled')
        axis image
        Picture_Filename=sprintf('%s/%s/%s/Colocalization.tif',d,dd(day,1).name,dd(day,1).isdir(slice,1).name);
        saveas(ckn, Picture_Filename);
        
        incident=Glia_map+Glut_map;
        incident_both=find(incident~=0);
        total_pixel=size(incident_both,1);
        
        total_coloc=sum(sum(coloc));
        
        colocalization_index(counter)=total_coloc/(total_pixel*4.6666666666666);
        file_tracker(counter,:)=FRET_search;
     
      
        
        end
        
        
        
     
        
    end  %% End Slice Loop
end  %% End Day Loop