%%%%%%%%%%%%% FL Peak Image Profiling
clear all

RLAlign='No';
TBAlign='No';
RotAlign='No';
L_R_pad=0;
T_B_pad=0;
Rot=0;
fileloc='/mnt/m022a/2009_01_27/';
Happiness=questdlg('Please Select your FL Peak image file','GOULET INC');
        [FileName,PathName,FilterIndex] = uigetfile(fileloc)
        fname=sprintf('%s%s',PathName,FileName);
        f=open(fname);
        this_image_file=f.Peak_Image;
        
        Happiness=questdlg('Please Select your FL Baseline image file','GOULET INC');
        [FileName,PathName,FilterIndex] = uigetfile(fileloc)
        fname=sprintf('%s%s',PathName,FileName);
        b=open(fname);
        
        base_image_file=b.Baseline_Frame;
        image(this_image_file,'cdatamapping','scaled')
        axis image;
        colormap jet;
        
        while (strcmp(RotAlign,'No')==1)


if (strcmp(RotAlign,'No')==1)
    prompt = {'Enter the degrees of Rotation                 '};
    dlg_title = 'Rotate Rotons             ';
    num_lines = 1;
    def = {num2str(Rot)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    Rot=str2num(answer{1,1});
    
    Peak_Rot_Tx=imrotate(this_image_file,Rot,'bilinear');
    image(Peak_Rot_Tx,'cdatamapping','scaled')
    colormap jet
    axis image;
    
    RotAlign=questdlg('Are you happy with the Rotational alignment','Registration Checkpoint');
end

end
 Peak_Rot_Tx_B=imrotate(base_image_file,Rot,'bilinear');       



image(Peak_Rot_Tx,'cdatamapping','scaled')
axis image
colormap jet
rt=imrect
p=getPosition(rt)

clippedi=Peak_Rot_Tx(round(p(2)):round(p(2))+round(p(4)),round(p(1)):round(p(1))+round(p(3)));
clippedb=Peak_Rot_Tx_B(round(p(2)):round(p(2))+round(p(4)),round(p(1)):round(p(1))+round(p(3)));
image(clippedi,'cdatamapping','scaled')
axis image
colormap jet

fl_prof(:,1)=mean(clippedi);
fl_prof(:,2)=mean(clippedb);
fname=sprintf('%s/FL_profile_clipped.mat',PathName);
bname=sprintf('%s/FL_profile_clipped_baseline.mat',PathName);
save (fname,'clippedi');
save (bname,'clippedb');

text_f=sprintf('%s/FL_profile.txt',PathName);
save (text_f, 'fl_prof', '-ascii','-tabs');
