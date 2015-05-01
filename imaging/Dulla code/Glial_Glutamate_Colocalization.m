close all
clear all

%%% Create color tables for combined image
[RedColorTable]=CreatePureRedColorTable;
[BlueColorTable]=CreatePureBlueColorTable;
[RedColorTable_0]=CreatePureRedColorTable_0;
[BlueColorTable_0]=CreatePureBlueColorTable_0;
%%% Pick Glial Density and FRET Files
Gpath=uigetdir('/mnt/m022a/SR101_FL/');
Glia_d=dir(sprintf('%s/*Glia_Tiered.mat',Gpath));
Glut_d=dir(sprintf('%s/*Glut_Tiered.mat',Gpath));


Glial_Density=open(sprintf('%s/%s',Gpath, Glia_d.name));
Glut_Density=open(sprintf('%s/%s',Gpath, Glut_d.name));
Aligned=open(sprintf('%s/PhotoCompiled.tif',Gpath));

Glial_Density=Glial_Density.Glia_Combined;
Glut_Density=Glut_Density.Glut_Combined;
Aligned=Aligned.PhotoCompiled;


top=subplot(2,1,1)
    imshow(Aligned)
    bottom=subplot(2,1,2)
    imshow(Glut_Density)
    
    %%% Select the features
    tophandle=cpselect(Aligned,Glut_Density);
    Xscaled=((base_points(1,1)-base_points(2,1))/(input_points(1,1)-input_points(2,1)));
    Yscaled=((base_points(1,2)-base_points(2,2))/(input_points(1,2)-input_points(2,2)));
    
    ScalingFactor=1/((Xscaled+Yscaled)/2);
    xform = [ ScalingFactor  0  0; 0  ScalingFactor  0;  0 0  1 ];
    tform_scale = maketform('affine',xform);
    [cb_trans xdata ydata]= imtransform(Glut_Density, tform_scale);
    test=imresize(Glut_Density,ScalingFactor*ScalingFactor);
    