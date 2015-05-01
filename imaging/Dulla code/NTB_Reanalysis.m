all=NTB_ROI_DATA.Activated_Area;
mz=NTB_ROI_DATA.Activated_Area_MZ;
pmz=NTB_ROI_DATA.Activated_Area_PMZ;
t5=NTB_ROI_DATA.NTB_Activated_Area_05;
t10=NTB_ROI_DATA.NTB_Activated_Area_10;

plot(all');
x_cutoff=5;
prompt = {'How many of these should be included?                 '};
                    dlg_title = 'NO GABAZINE PLEASE              ';
                    num_lines = 1;
                    def = {num2str(x_cutoff)};
                    answer = inputdlg(prompt,dlg_title,num_lines,def);
                    this_many=str2num(answer{1,1});
                    
all_ave=mean(all(1:this_many,:));
mz_ave=mean(mz(1:this_many,:));
pmz_ave=mean(pmz(1:this_many,:));
t5_ave=mean(t5(1:this_many,:));
t10_ave=mean(t10(1:this_many,:));
