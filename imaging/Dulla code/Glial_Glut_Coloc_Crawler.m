close all
clear all


%%% Create color tables for combined image
[RedColorTable]=CreatePureRedColorTable;
[BlueColorTable]=CreatePureBlueColorTable;
[RedColorTable_0]=CreatePureRedColorTable_0;
[BlueColorTable_0]=CreatePureBlueColorTable_0;
d=uigetdir('/mnt/m022a/SR101_FL_with_Glut_Perfusion','Choose the Main Folder');
dd=dirr(d);
for day=6:size(dd,1)
    for slice=1:size(dd(day,1).isdir,1)
        
        %%%% Find and open Glial SR101 Processed Map
        Glia_search=sprintf('%s/%s/%s/*RawIntensity_small*',d,dd(day,1).name,dd(day,1).isdir(slice,1).name );
        GD = dir (Glia_search);
        Gnum=length(GD);
        if Gnum<1
            disp('No files found');
        end
        Glia_file=sprintf('%s/%s/%s/%s',d,dd(day,1).name,dd(day,1).isdir(slice,1).name, GD.name );
        
        Glial_Density=open(Glia_file);
        Glial_Density=Glial_Density.thisspot_G_S_raw;
        
        
        
        %%%% Find and open Glial SR101 Processed Map - Spatially Binned
        Glia_search_B=sprintf('%s/%s/%s/*RawIntensity.mat',d,dd(day,1).name,dd(day,1).isdir(slice,1).name );
        GDB = dir (Glia_search_B);
        GBnum=length(GDB);
        if GBnum<1
            disp('No files found');
        end
        Glia_fileB=sprintf('%s/%s/%s/%s',d,dd(day,1).name,dd(day,1).isdir(slice,1).name, GDB.name );
        Glial_DensityB=open(Glia_fileB);
        Glial_DensityB=Glial_DensityB.thisspot_G_raw;
        
        
        
        %%%%  Seach for a Glutamate Perfusion File
        FRET_search=sprintf('%s/%s/%s/*FRET_Logical*',d,dd(day,1).name,dd(day,1).isdir(slice,1).name );
        FD = dir (FRET_search);
        Fnum=length(FD);
        if Fnum<1
            disp('No files found');
        else
            FRET_file=sprintf('%s/%s/%s/%s',d,dd(day,1).name,dd(day,1).isdir(slice,1).name,FD.name );
            Glut_Response=open(FRET_file);
            Glut_Response=Glut_Response.FRET_logicals;
            Glut_Response=-squeeze(Glut_Response(2,:,:));
            Glut_Response=flipud(Glut_Response);
            Glut_Response=fliplr(Glut_Response);
            Glial_Density=rot90(Glial_Density);
            Glial_Density=fliplr(Glial_Density);
        end
        
        
        
        
        
        %%% Manipulating Glial Density Map into 3-tiered binary image
      
        %[Glia_cont,Glia_h]=contour(Glial_DensityB,[0.01,0.15,0.30],'LineWidth',2);  %Graphing the original Contour
        %[Glia_cont,Glia_h]=contour(Glial_DensityB,[.2,.8,1.4],'LineWidth',2);  %Graphing the original Contour
        
        %%%%  Determine Tresholds for Glial Density
        test=find(Glial_DensityB~=0);
        sorted=sort(Glial_DensityB(test));
        first_cut=sorted(1,1);
        second_cut=sorted(floor(size(sorted,1)/3));
        third_cut=sorted(floor(size(sorted,1)/3*2));
        
        %%% Create a 3 colored map of glial density based on high, med, low
        a1=find((Glial_DensityB>first_cut)&(Glial_DensityB<second_cut));
        a2=find((Glial_DensityB>second_cut)&(Glial_DensityB<third_cut));
        a3=find(Glial_DensityB>third_cut);
        Glia_map=zeros(size(Glial_DensityB,1),size(Glial_DensityB,2));
        Glia_map(a1)=1;
        Glia_map(a2)=2;
        Glia_map(a3)=3;
        
        %%% Plot the contour map of glial density
        c1=figure(1)
        contour(Glial_DensityB,[first_cut,second_cut,third_cut], 'LineWidth',2); %3_17_4
        colormap(BlueColorTable);
        axis image
        axis off
        
        
        %%% Plot the 3 tiered Glial Density
        c2=figure(2)
        image(Glia_map,'cdatamapping','scaled')
        axis image
        axis off
        colormap(BlueColorTable_0);
        
        %%% Plot the spatially binned glial density map
        c3=figure(3)
        image(Glial_DensityB,'cdatamapping','scaled')
        axis image
        axis off
        colormap(BlueColorTable_0);
        colorbar
        
        if Fnum<1
            disp('No files found');
        else
        %%% Manipulating Glutamate Signal Map into 3-tiered binary image
        %[Glut_cont,Glut_h]=contour(Glut_Response,[.5, 1.6, 2], 'LineWidth',2); %3_17_5
        %[Glut_cont,Glut_h]=contour(Glut_Response,[2, 4.2, 4.8], 'LineWidth',2);%%3_16_1_2
        %[Glut_cont,Glut_h]=contour(Glut_Response,[1.5, 3.2, 3.8], 'LineWidth',2); %3_17_4
        
        
        %%%%  Determine the treshold for Glutamate Intensity
        testGlut=find(Glut_Response~=0);
        sortedGlut=sort(Glut_Response(testGlut));
        first_cut=sortedGlut(1,1);
        second_cut=sortedGlut(floor(size(sortedGlut,1)/3),1);
        third_cut=sortedGlut(floor(size(sortedGlut,1)/3*2),1);
        
        
        %%%% Contour map of Glutamate signal
        c4=figure(4)
        [Glut_cont,Glut_h]=contour(Glut_Response,[first_cut,second_cut,third_cut], 'LineWidth',2); %3_17_4
        axis image
        colormap(RedColorTable);
        axis off
        
        %%%%  3 Tiered Image of GLutamate signal
        c5=figure(5)
        a1g=find((Glut_Response>first_cut)&(Glut_Response<second_cut));
        a2g=find((Glut_Response>second_cut)&(Glut_Response<third_cut));
        a3g=find(Glut_Response>third_cut);
        Glut_map=zeros(size(Glut_Response,1),size(Glut_Response,2));
        Glut_map(a1g)=1;
        Glut_map(a2g)=2;
        Glut_map(a3g)=3;
        Glut_map=rot90(Glut_map);
        Glut_map=rot90(Glut_map);
        image(Glut_map,'cdatamapping','scaled')
        axis image
        axis off
        colormap(RedColorTable_0);
        
          
        
        
        
        end
        
        Folder_Header=sprintf('%s/%s/%s/',d,dd(day,1).name,dd(day,1).isdir(slice,1).name);
        
        ROI_Picture_Filename=sprintf('%sGlial_Contour.tif',Folder_Header);
        saveas(c1, ROI_Picture_Filename);
        
        ROI_Picture_Filename=sprintf('%sGlial_Tiered.tif',Folder_Header);
        saveas(c2, ROI_Picture_Filename);
        
        ROI_Picture_Filename=sprintf('%sGlial_Density_Large_Blur_Element.tif',Folder_Header);
        saveas(c3, ROI_Picture_Filename);
        
        ROI_Picture_Filename=sprintf('%sGlia_Tiered',Folder_Header);
        save(ROI_Picture_Filename,'Glia_map');
        
        if Fnum>=1
         ROI_Picture_Filename=sprintf('%sGlut_Contour.tif',Folder_Header);
        saveas(c4, ROI_Picture_Filename);
        
        ROI_Picture_Filename=sprintf('%sGlut_Tiered.tif',Folder_Header);
        saveas(c5, ROI_Picture_Filename);
        
        ROI_Picture_Filename=sprintf('%sGlut_Tiered',Folder_Header);
        save(ROI_Picture_Filename,'Glut_map');
        end
        clear test
        clear sorted
        clear a1
        clear a2
        clear a3
        clear testGlut
        clear sortedGlut
        clear a1g
        clear a2g
        clear a3g
        close all
        
    end  %% End Slice Loop
end  %% End Day Loop