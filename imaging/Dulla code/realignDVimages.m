function [ratio, ratio_raw,Aligned,VertAdjust,HorizAdjust]=realignDVimages(ch1, ch2, Ch1_Normalized, Ch2_Normalized,Aligned, parameters_present,VertAdjust,HorizAdjust)

while (strcmp(Aligned,'No')==1)

   if VertAdjust>0
        ch2test=ch2(abs(VertAdjust)+1:size(ch2,1),:,:);
        ch1test=ch1(1:size(ch1,1)-abs(VertAdjust),:,:);
        ch2test_n=Ch2_Normalized(abs(VertAdjust)+1:size(Ch2_Normalized,1),:,:);
        ch1test_n=Ch1_Normalized(1:size(Ch1_Normalized,1)-abs(VertAdjust),:,:);
   end
   if VertAdjust<0
        ch2test=ch2(1:size(ch2,1)-abs(VertAdjust),:,:);
        ch1test=ch1(abs(VertAdjust)+1:size(ch1,1),:,:);
        ch2test_n=Ch2_Normalized(1:size(Ch2_Normalized,1)-abs(VertAdjust),:,:);
        ch1test_n=Ch1_Normalized(abs(VertAdjust)+1:size(Ch1_Normalized,1),:,:);
   end
    if VertAdjust==0;
        ch2test=ch2;
        ch1test=ch1;
        ch2test_n=Ch2_Normalized;
        ch1test_n=Ch1_Normalized;
    end
    if HorizAdjust>0
        ch2test=ch2test(:,abs(HorizAdjust)+1:size(ch2test,2),:);
        ch1test=ch1test(:,1:size(ch1test,2)-abs(HorizAdjust),:);
        ch2test_n=ch2test_n(:,abs(HorizAdjust)+1:size(ch2test_n,2),:);
        ch1test_n=ch1test_n(:,1:size(ch1test_n,2)-abs(HorizAdjust),:);
        
    end
    if HorizAdjust<0
        ch2test=ch2(:,1:size(ch2,2)-abs(HorizAdjust),:);
        ch1test=ch1(:,abs(HorizAdjust)+1:size(ch1,2),:);
        ch2test_n=Ch2_Normalized(:,1:size(Ch2_Normalized,2)-abs(HorizAdjust),:);
        ch1test_n=Ch1_Normalized(:,abs(HorizAdjust)+1:size(Ch1_Normalized,2),:);
    end
     
    testratio=ch1test(:,:,10)./ch2test(:,:,10);
    oversat=find(testratio>5);
    testratio(oversat)=5;
    undersat=find(testratio<1);
    testratio(undersat)=1;
    
    if (parameters_present==0)
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
    
    
    close;
end


ratio_raw=ch1test./ch2test;
ratio=ch1test_n./ch2test_n;
if VertAdjust>0
ratio_raw=ratio_raw(1:size(ratio_raw,1)-abs(VertAdjust),:,:);
ratio=ratio(1:size(ratio,1)-abs(VertAdjust),:,:);
end
if VertAdjust<0
ratio_raw=ratio_raw(abs(VertAdjust)+1:size(ratio_raw,1),:,:);
ratio=ratio(abs(VertAdjust)+1:size(ratio,1),:,:);
end
if VertAdjust==0
ratio_raw=ratio_raw;
ratio=ratio;
end
if HorizAdjust>0
ratio_raw=ratio_raw(:,1:size(ratio_raw,2)-abs(HorizAdjust),:);
ratio=ratio(:,1:size(ratio,2)-abs(HorizAdjust),:);;
end
if HorizAdjust<0
ratio_raw=ratio_raw(:,abs(HorizAdjust)+1:size(ratio_raw,2),:);
ratio=ratio(:,abs(HorizAdjust)+1:size(ratio,2),:);
end
if HorizAdjust==0
ratio_raw=ratio_raw;
ratio=ratio;
end
end