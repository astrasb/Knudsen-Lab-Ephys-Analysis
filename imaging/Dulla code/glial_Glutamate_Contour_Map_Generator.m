close all
clear all

%%% Create color tables for combined image
[RedColorTable]=CreatePureRedColorTable;
[BlueColorTable]=CreatePureBlueColorTable;
[RedColorTable_0]=CreatePureRedColorTable_0;
[BlueColorTable_0]=CreatePureBlueColorTable_0;
%%% Pick Glial Density and FRET Logical File
[G_Density Gpath]=uigetfile('/mnt/m022a/SR101_FL_with_Glut_Perfusion','Choose the Glial Density MAT file');
[Glu_Response Glutpath]=uigetfile('/mnt/m022a/SR101_FL_with_Glut_Perfusion/','Choose the FRET Logical MAT file');
Glial_Density=open(sprintf('%s%s',Gpath,G_Density));
Glut_Response=open(sprintf('%s%s',Glutpath,Glu_Response));
Glial_Density=Glial_Density.thisspot_G_raw;
Glut_Response=Glut_Response.FRET_logicals;
Glut_Response=-squeeze(Glut_Response(2,:,:));
Glut_Response=flipud(Glut_Response);
Glut_Response=fliplr(Glut_Response);
Glial_Density=rot90(Glial_Density);
Glial_Density=fliplr(Glial_Density);
se = strel('disk',1); 
%%% Manipulating Glial Density Map into 3-tiered binary image
c1=figure(1)
[Glia_cont,Glia_h]=contour(Glial_Density,[0.01,0.15,0.30],'LineWidth',2);  %Graphing the original Contour
colormap(BlueColorTable);
axis image
axis off
[Glial_Matrix_With_Contours]=Contour_Matrix_Parse(Glia_cont,size(Glial_Density));  % Parsing the contour matrix into a actual matrix
Glia_bottom=find(Glial_Matrix_With_Contours==0.01); %% Converting to 3 tiered binar
Glia_middle=find(Glial_Matrix_With_Contours==0.15);
Glia_top=find(Glial_Matrix_With_Contours==0.3);
GBmap=zeros(size(Glial_Density,1),size(Glial_Density,2));
GMmap=zeros(size(Glial_Density,1),size(Glial_Density,2));
GTmap=zeros(size(Glial_Density,1),size(Glial_Density,2));
GBmap(Glia_bottom)=1;
GMmap(Glia_middle)=2;
GTmap(Glia_top)=3;
GBmap = imdilate(GBmap,se);
GMmap = imdilate(GMmap,se);
GTmap = imdilate(GTmap,se);


GBmap=imfill(GBmap);
GMmap=imfill(GMmap);
GTmap=imfill(GTmap);

GBmap = imerode(GBmap,se);
GMmap = imerode(GMmap,se);
GTmap = imerode(GTmap,se);
Glia_bottomf=find(GBmap==1);
Glia_middlef=find(GMmap==2);
Glia_topf=find(GTmap==3);
Glia_Combined=zeros(size(Glial_Density,1),size(Glial_Density,2));
Glia_Combined(Glia_bottomf)=1;
Glia_Combined(Glia_middlef)=2;
Glia_Combined(Glia_topf)=3;
Glia_Combined=flipud(Glia_Combined);
c2=figure(2)
image(Glia_Combined,'cdatamapping','scaled')
axis image
axis off
colormap(BlueColorTable_0);

%%% Manipulating Glutamate Signal Map into 3-tiered binary image
c3=figure(3)
%[Glut_cont,Glut_h]=contour(Glut_Response,[.5, 1.6, 2], 'LineWidth',2); %3_17_5

%[Glut_cont,Glut_h]=contour(Glut_Response,[2, 4.2, 4.8], 'LineWidth',2);%%3_16_1_2
[Glut_cont,Glut_h]=contour(Glut_Response,[1.5, 3.2, 3.8], 'LineWidth',2); %3_17_4


axis image
colormap(RedColorTable);
axis off
c4=figure(4)

[Glut_Matrix_With_Contours]=Contour_Matrix_Parse(Glut_cont,size(Glut_Response));

Glut_bottom=find(Glut_Matrix_With_Contours==1.5); %% Converting to 3 tiered binar
Glut_middle=find(Glut_Matrix_With_Contours==3.2);
Glut_top=find(Glut_Matrix_With_Contours==3.8);
GlutBmap=zeros(size(Glut_Response,1),size(Glut_Response,2));
GlutMmap=zeros(size(Glut_Response,1),size(Glut_Response,2));
GlutTmap=zeros(size(Glut_Response,1),size(Glut_Response,2));

       


GlutBmap(Glut_bottom)=1;
GlutMmap(Glut_middle)=2;
GlutTmap(Glut_top)=3;
GlutBmap = imdilate(GlutBmap,se);
GlutMmap = imdilate(GlutMmap,se);
GlutTmap = imdilate(GlutTmap,se);
GlutBmap=imfill(GlutBmap);
GlutMmap=imfill(GlutMmap);
GlutTmap=imfill(GlutTmap);
GlutBmap = imerode(GlutBmap,se);
GlutMmap = imerode(GlutMmap,se);
GlutTmap = imerode(GlutTmap,se);

Glut_bottomf=find(GlutBmap==1);
Glut_middlef=find(GlutMmap==2);
Glut_topf=find(GlutTmap==3);
Glut_Combined=zeros(size(Glut_Response,1),size(Glut_Response,2));
Glut_Combined(Glut_bottomf)=1;
Glut_Combined(Glut_middlef)=2;
Glut_Combined(Glut_topf)=3;
Glut_Combined=flipud(Glut_Combined);

image(Glut_Combined,'cdatamapping','scaled')
axis image
axis off
colormap(RedColorTable_0);

ROI_Picture_Filename=sprintf('%sGlial_Contour.tif',Gpath);  
saveas(c1, ROI_Picture_Filename);

ROI_Picture_Filename=sprintf('%sGlial_Tiered.tif',Gpath);  
saveas(c2, ROI_Picture_Filename);

ROI_Picture_Filename=sprintf('%sGlut_Contour.tif',Gpath);  
saveas(c3, ROI_Picture_Filename);

ROI_Picture_Filename=sprintf('%sGlut_Tiered.tif',Gpath);  
saveas(c4, ROI_Picture_Filename);

ROI_Picture_Filename=sprintf('%sGlut_Tiered',Gpath);  
save(ROI_Picture_Filename,'Glut_Combined');

ROI_Picture_Filename=sprintf('%sGlia_Tiered',Gpath);  
save(ROI_Picture_Filename,'Glia_Combined');
