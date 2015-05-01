Happiness=questdlg('Time to start the alignment','GOULET INC');
RLAlign='No';
TBAlign='No';
RotAlign='No';
L_R_pad=0;
T_B_pad=0;
Rot=0;
NewAve=questdlg('Do you have a current running average?','New file or old file');
if (strcmp(NewAve,'Yes')==1)
        Happiness=questdlg('Please Select your running average file','GOULET INC');
        [FileName,PathName,FilterIndex] = uigetfile('/mnt/m022a/')
        fname=sprintf('%s%s',PathName,FileName);
        f=open(fname);
        out_ave_image=f.out_ave_image{1};
        numslices=f.out_ave_image{2};
        
        
        
end
Happiness=questdlg('Please Select your FL Peak image file','GOULET INC');
        [FileName,PathName,FilterIndex] = uigetfile('/mnt/m022a/')
        fname=sprintf('%s%s',PathName,FileName);
        f=open(fname);
        this_image_file=f.Peak_Image;
        image(this_image_file,'cdatamapping','scaled')
        axis image;
        colormap jet;
        
while (strcmp(RLAlign,'No')==1)
RLAlign=questdlg('Are you happy with the Right/Left alignment','Registration Checkpoint');

if (strcmp(RLAlign,'No')==1)
    prompt = {'Enter the left/right padding                 '};
    dlg_title = 'Moving Left/Right              ';
    num_lines = 1;
    def = {num2str(L_R_pad)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    L_R_pad=str2num(answer{1,1});
    txmatrix=[1 0 0
          0 1 0
          L_R_pad 0 1];
    txform=maketform('affine',txmatrix);
    Peak_RL_Tx=imtransform(this_image_file, txform, 'Xdata',[1 (size(this_image_file,2)+txmatrix(3,1))],'Ydata', [1 (size(this_image_file,1)+txmatrix(3,2))],'FillValues', 0);
    image(Peak_RL_Tx,'cdatamapping','scaled')
    colormap jet
    axis image;
    
end
end
while (strcmp(TBAlign,'No')==1)
TBAlign=questdlg('Are you happy with the Top/Bottom alignment','Registration Checkpoint');

if (strcmp(TBAlign,'No')==1)
    prompt = {'Enter the Top/Bottom padding                 '};
    dlg_title = 'Moving Top/Bottom             ';
    num_lines = 1;
    def = {num2str(T_B_pad)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    T_B_pad=str2num(answer{1,1});
    txmatrix=[1 0 0
          0 1 0
          0 T_B_pad 1];
    txform=maketform('affine',txmatrix);
    Peak_TB_Tx=imtransform(Peak_RL_Tx, txform, 'Xdata',[1 (size(Peak_Image,2)+txmatrix(3,1))],'Ydata', [1 (size(Peak_Image,1)+txmatrix(3,2))],'FillValues', 0);
    image(Peak_TB_Tx,'cdatamapping','scaled')
    colormap jet
    axis image;
end

end


while (strcmp(RotAlign,'No')==1)
RotAlign=questdlg('Are you happy with the Rotational alignment','Registration Checkpoint');

if (strcmp(RotAlign,'No')==1)
    prompt = {'Enter the degrees of Rotation                 '};
    dlg_title = 'Rotate Rotons             ';
    num_lines = 1;
    def = {num2str(Rot)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    Rot=str2num(answer{1,1});
    
    Peak_Rot_Tx=imrotate(Peak_TB_Tx,Rot,'bilinear');
    image(Peak_Rot_Tx,'cdatamapping','scaled')
    colormap jet
    axis image;
end

end



          if (strcmp(NewAve,'No')==1)
             out_ave_image{1}=Peak_RL_Tx;
             out_ave_image{2}=1;
             save ('/mnt/m022a/running_FL_average.mat','out_ave_image');
          else
             tempave=out_ave_image{1};
             numslices=out_ave_image{2};
             tempave=tempave*numslices;
             tempave=tempave+Peak_RL_Tx;
             tempave=tempave/(numslices+1);
             out_ave_image{1}=tempave;
             out_ave_image{2}=numslices+1;
             save ('/mnt/m022a/running_FL_average.mat','out_ave_image');
              
              
          end



