for i=1:4   
normpoints=[24,23,26,27];
   
[FileName,PathName,FilterIndex] = uigetfile('/mnt/m022a/')
fname=sprintf('%s%s',PathName,FileName);
open(fname);

sulcus_sub(i,:)=ans.out_roi(1,:);
pmz_sub(i,:)=ans.out_roi(2,:);
outside_pmz_sub(i,:)=ans.out_roi(3,:);

sulcus_raw(i,:)=ans.out_roi(4,:);
pmz_raw(i,:)=ans.out_roi(5,:);
outside_pmz_raw(i,:)=ans.out_roi(6,:);

norm_sulcus(i,:)=sulcus_raw(i,:)/sulcus_raw(i,normpoints(i))*100;
norm_pmz(i,:)=pmz_raw(i,:)/pmz_raw(i,normpoints(i))*100;
norm_outside(i,:)=outside_pmz_raw(i,:)/outside_pmz_raw(i,normpoints(i))*100;

figure (1)
subplot(3,1,1)
plot(sulcus_sub(i,:));
subplot(3,1,2)
plot(pmz_sub(i,:));
subplot(3,1,3)
plot(outside_pmz_sub(i,:));
ROI_Picture_Filename=sprintf('%ssubROIs.jpg',PathName);
saveas(gcf, ROI_Picture_Filename);
close

figure (1)
subplot(3,1,1)
plot(sulcus_raw(i,:));
subplot(3,1,2)
plot(pmz_raw(i,:));
subplot(3,1,3)
plot(outside_pmz_raw(i,:));
ROI_Picture_Filename=sprintf('%sraw_sub_ROIs.jpg',PathName);
saveas(gcf, ROI_Picture_Filename);
close

figure (1)
subplot(3,1,1)
plot(norm_sulcus(i,:));
subplot(3,1,2)
plot(norm_pmz(i,:));
subplot(3,1,3)
plot(norm_outside(i,:));
ROI_Picture_Filename=sprintf('%snorm_sub_ROIs.jpg',PathName);
saveas(gcf, ROI_Picture_Filename);
close
 



end