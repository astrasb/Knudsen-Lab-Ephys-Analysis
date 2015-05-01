function [Ch1,Ch2,VertAdjust,HorizAdjust]=Align_Andor(Ch1, Ch2, i,hh, VertAdjust, HorizAdjust)

%%%%%%%%%%%%%%%%%%%%%%% Adjust alignment
Aligned='No';



    while (strcmp(Aligned,'No')==1)
        pad=ones(size(Ch1,1),abs(VertAdjust),size(Ch1,3));
        if VertAdjust>0
        Ch2test=[pad,Ch2];
        Ch1test=[Ch1, pad];
        
        else
        Ch2test=[Ch2,pad];
        Ch1test=[pad,Ch1]; 
        
        end
        padtop=ones(abs(HorizAdjust),size(Ch2test,2),size(Ch1,3));
        if HorizAdjust>0
        Ch1test=[Ch1test;padtop];
        Ch2test=[padtop;Ch2test];
       
        
        else
        Ch1test=[padtop;Ch1test];
        Ch2test=[Ch2test;padtop];  
         
        end
       
        testratio=Ch1test(:,:,10)./Ch2test(:,:,10);
        oversat=find(testratio>5);
        testratio(oversat)=5;
        undersat=find(testratio<1);
        testratio(undersat)=1;
        
        if ((i==1)&(hh==1))
        image(testratio,'cdatamapping','scaled')
        axis image;
         Aligned=questdlg('Are you happy with the alignment','Registration Checkpoint');
            if (strcmp(Aligned,'No')==1)
                prompt = {'Enter vertical adjustment                 ','Enter Horizonatal adjustment                  '};
                dlg_title = 'Adjust Registration              ';
                num_lines = 1;
                def = {num2str(VertAdjust),num2str(HorizAdjust)};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                VertAdjust=str2num(answer{1,1});
                HorizAdjust=str2num(answer{2,1});
            end     
        else
            Aligned='Yes';
        end
    end
 
    
    close;
    Ch1=Ch1test;
    Ch2=Ch2test;
end
    
        

