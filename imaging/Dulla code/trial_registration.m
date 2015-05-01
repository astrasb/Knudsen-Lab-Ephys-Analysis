clear all
VertAdjust=0;
HorizAdjust=0;
clipfactor=20;
ScaleFactor=10;
L_R_OffsetFactor=-350;
U_D_OffsetFactor=0;
directory = uigetdir('/mnt/m022a/')
[Image,InstaImage,CalibImage,vers]=andorread_chris_local();
temp=Image.data;

ch1=temp(1:size(temp,1)/2,:,:);
ch2=temp(size(temp,1)/2+1:size(temp,1),:,:);
brightandor=ch1./ch2;
Happiness='No';
       while (strcmp(Happiness,'No')==1)
            
            [andorscaled, cookscaled, L_R_OffsetFactor, U_D_OffsetFactor]=registration_test_calcium(brightandor, directory, ScaleFactor, L_R_OffsetFactor, U_D_OffsetFactor) ;
           
           
            Happiness=questdlg('Are you happy with the alignment','Registration Checkpoint');
            if (strcmp(Happiness,'No')==1)
                prompt = {'Enter Scale Factor                 ','Enter Left/Right Factor                  ','Enter Up/Down Factor                  '};
                dlg_title = 'Adjust Registration              ';
                num_lines = 1;
                def = {num2str(ScaleFactor),num2str(L_R_OffsetFactor),num2str(U_D_OffsetFactor)};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                ScaleFactor=str2num(answer{1,1});
                L_R_OffsetFactor=str2num(answer{2,1});
                U_D_OffsetFactor=str2num(answer{3,1});
                
            end
           
           end    