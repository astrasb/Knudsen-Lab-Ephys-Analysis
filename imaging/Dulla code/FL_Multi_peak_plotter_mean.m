Plotting=0;
FLa=0;
Contraa=0;
number_of_lines=1;
FLcount=0;
Ccount=0;
% Goes thru each slice
for t=1:26
    if t~=1
        clear SGProfileFit;
    end
    thistrace=SummedG{t};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Assigns FL/Contra and Slice orientation and keeps track of file names
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if FL_yes_or_no(t)==1
        FLa=FLa+1;
        FLFileNames{FLa}=filenameoutput{t};
        if FL_yes_or_no(1,t)==1
            FL_North(FLa)=1;  %%  FL_north means that the medial/FL side is to the right
        else
            FL_North(FLa)=0;  %%  FL_north means that the medial/FL side is to the left
        end
    else
        Contraa=Contraa+1;
       CFileNames{Contraa}=filenameoutput{t};
    end
    SGProfileFit=SummedG{t};
    for i=1:number_of_lines
         
        if FL_yes_or_no(1,t)==1
            if FL_North_or_South(3,t)==0
                if Plotting==1
                figure (1)
                plot((peaks(t,2,i)-stims(1,t)),peaks(t,1,i),'Color','red', 'MarkerEdgeColor','black','MarkerFaceColor',RGBCustom(i,:),'MarkerSize',12,'Marker','o','LineWidth', 2);
                hold on
                figure(3)
                plot((centroid(t,i)-peaks(t,2,i)),peaks(t,1,i),'Color','red', 'MarkerEdgeColor',[0.5 0.5 0.5],'MarkerFaceColor',RGBCustom(i,:),'MarkerSize',12,'Marker','o','LineWidth', 2);
                hold on
                end
                if peaks(t,1,i)>0.01
                    
                    FLweighted(FLa,i)=(peaks(t,2,i)-stims(1,t))*peaks(t,1,i);
                    FLcount=FLcount+1;
                    FLIntens(FLcount)=peaks(t,1,i);
                    FLhist_Raw(FLcount)=(peaks(t,2,i)-stims(1,t));
                    FLhist_Centroid(FLcount)=centroid(t,i)-peaks(t,2,i);
                else
                    FLweighted(FLa,i)=0;
                end
                FLraw(FLa,i)=(peaks(t,2,i)-stims(1,t));
                FLPeaks(FLa,i)=peaks(t,2,i);
                FLInsensity(FLa,i)=peaks(t,1,i);
                 if centroid(t,i)~=0
                FL_Centroid_peak_ref(FLa,i)=centroid(t,i)-peaks(t,2,i);
                FL_Centroid_stim_ref(FLa,i)=centroid(t,i)-stims(1,t);
                else
                    FL_Centroid_peak_ref(FLa,i)=0;
                    FL_Centroid_stim_ref(FLa,i)=0;
                 end
                FL_Centroid_peakweighted_ref(FLa,i)=(centroid(t,i)-peaks(t,2,i))*peaks(t,2,i);
                FL_SummedG_Half_Width(FLa,i)=SGhalfwidth(t,i);
                FL_SummedG_Half_Width_Thresh(FLa,i)=STheshwidth(t,i);
                FL_SummedG_Quarter_Width(FLa,i)=SQuarterwidth(t,i);
                FL_sumR2(FLa,i)=sumR2(t,i);
                FL_singleR2(FLa,i) =singleR2(t,i);
                FL_differentialFit(FLa,i)=sumR2(t,i)-singleR2(t,i);
                FL_500uM_Lateral(FLa,i)=mean(thistrace(i,stims(1,t)+19:stims(1,t)+21));
                FL_500uM_Medial(FLa,i)=mean(thistrace(i,stims(1,t)-21:stims(1,t)-19));
                FL_250uM_Lateral(FLa,i)=mean(thistrace(i,stims(1,t)+9:stims(1,t)+11));
                FL_250uM_Medial(FLa,i)=mean(thistrace(i,stims(1,t)-11:stims(1,t)-9));
                FL_Area(FLa,i)=Area(t,i);
                FL_Dir_Ind_H(FLa,i)=(peaks(t,2)-SHalfwidthDirInd2(t,1))-(SHalfwidthDirInd(t,1)-peaks(t,2));
                FL_Dir_Ind_Q(FLa,i)=(peaks(t,2)-SQwidthDirInd2(t,1))-(SQwidthDirInd(t,1)-peaks(t,2));
                FL_Dir_Ind_T(FLa,i)=(peaks(t,2)-STwidthDirInd2(t,1))-(STwidthDirInd(t,1)-peaks(t,2));
            else
                if Plotting==1
                figure (1)
                plot(-(peaks(t,2,i)-stims(1,t)),peaks(t,1,i),'Color','black', 'MarkerEdgeColor','black','MarkerFaceColor',RGBCustom(i,:),'MarkerSize',12,'Marker','o','LineWidth', 2);
                hold on
                figure(3)
                plot(-(centroid(t,i)-peaks(t,2,i)),peaks(t,1,i),'Color','black', 'MarkerEdgeColor',[0.5 0.5 0.5],'MarkerFaceColor',RGBCustom(i,:),'MarkerSize',12,'Marker','o','LineWidth', 2);
                hold on
                end
                if peaks(t,1,i)>0.01
                    FLweighted(FLa,i)=-(peaks(t,2,i)-stims(1,t))*peaks(t,1,i);
                    FLcount=FLcount+1;
                    FLIntens(FLcount)=peaks(t,1,i);
                    FLhist_Raw(FLcount)=-(peaks(t,2,i)-stims(1,t));
                    FLhist_Centroid(FLcount)=-(centroid(t,i)-peaks(t,2,i));
                else
                    FLweighted(FLa,i)=0;
                end
                FLraw(FLa,i)=-(peaks(t,2,i)-stims(1,t));
                FLPeaks(FLa,i)=peaks(t,2,i);
                FLInsensity(FLa,i)=peaks(t,1,i);
                 if centroid(t,i)~=0
                FL_Centroid_peak_ref(FLa,i)=-(centroid(t,i)-peaks(t,2,i));
                FL_Centroid_stim_ref(FLa,i)=-(centroid(t,i)-stims(1,t));
                 else
                    FL_Centroid_peak_ref(FLa,i)=0;
                    FL_Centroid_stim_ref(FLa,i)=0;
                 end
                FL_Centroid_peakweighted_ref(FLa,i)=-(centroid(t,i)-peaks(t,2,i))*peaks(t,2,i);
                FL_SummedG_Half_Width(FLa,i)=SGhalfwidth(t,i);
                FL_SummedG_Half_Width_Thresh(FLa,i)=STheshwidth(t,i);
                FL_SummedG_Quarter_Width(FLa,i)=SQuarterwidth(t,i);
                FL_sumR2(FLa,i)=sumR2(t,i);
                FL_singleR2(FLa,i) =singleR2(t,i);
                FL_differentialFit(FLa,i)=sumR2(t,i)-singleR2(t,i);
                FL_500uM_Lateral(FLa,i)=mean(thistrace(i,stims(1,t)-21:stims(1,t)-19));
                FL_500uM_Medial(FLa,i)=mean(thistrace(i,stims(1,t)+19:stims(1,t)+21));
                FL_250uM_Lateral(FLa,i)=mean(thistrace(i,stims(1,t)-11:stims(1,t)-9));
                FL_250uM_Medial(FLa,i)=mean(thistrace(i,stims(1,t)+9:stims(1,t)+11));
                FL_Area(FLa,i)=Area(t,i);
                FL_Dir_Ind_H(FLa,i)=-(peaks(t,2)-(SHalfwidthDirInd2(t,1))-(SHalfwidthDirInd(t,1)-peaks(t,2)));
                FL_Dir_Ind_Q(FLa,i)=-(peaks(t,2)-(SQwidthDirInd2(t,1))-(SQwidthDirInd(t,1)-peaks(t,2)));
                FL_Dir_Ind_T(FLa,i)=-(peaks(t,2)-(STwidthDirInd2(t,1))-(STwidthDirInd(t,1)-peaks(t,2)));
            end
            
        else
            if FL_North_or_South(3,t)==0
                if Plotting==1
                figure (2)
                plot((peaks(t,2,i)-stims(1,t)),peaks(t,1,i),'Color',RGBCustom(i,:), 'MarkerEdgeColor','black','MarkerFaceColor',RGBCustom(i,:),'MarkerSize',12,'Marker','o','LineWidth', 2);
                hold on
                figure(4)
                plot((centroid(t,i)-peaks(t,2,i)),peaks(t,1,i),'Color',RGBCustom(i,:), 'MarkerEdgeColor',[0.5 0.5 0.5],'MarkerFaceColor',RGBCustom(i,:),'MarkerSize',12,'Marker','o','LineWidth', 2);
                hold on
                end
                if peaks(t,1,i)>0.01
                    Contraweighted(Contraa,i)=(peaks(t,2,i)-stims(1,t))*peaks(t,1,i);
                    Ccount=Ccount+1;
                    CIntens(Ccount)=peaks(t,1,i);
                    Chist_Raw(Ccount)=(peaks(t,2,i)-stims(1,t));
                    Chist_Centroid(Ccount)=(centroid(t,i)-peaks(t,2,i));
                else
                    Contraweighted(Contraa,i)=0;
                end
                Contraraw(Contraa,i)=(peaks(t,2,i)-stims(1,t));
                C_Peaks(Contraa,i)=(peaks(t,2,i));
                CInsensity(Contraa,i)=peaks(t,1,i);
                if centroid(t,i)~=0
                C_Centroid_peak_ref(Contraa,i)=centroid(t,i)-peaks(t,2,i);
                C_Centroid_stim_ref(Contraa,i)=centroid(t,i)-stims(1,t);
                else
                    C_centroid_peak_ref(Contraa,i)=0;
                    C_Centroid_stim_ref(Contraa,i)=0;
                end
                C_Centroid_peakweighted_ref(Contraa,i)=(centroid(t,i)-peaks(t,2,i))*peaks(t,2,i);
                C_SummedG_Half_Width(Contraa,i)=SGhalfwidth(t,i);
                C_SummedG_Half_Width_Thresh(Contraa,i)=STheshwidth(t,i);
                C_SummedG_Quarter_Width(Contraa,i)=SQuarterwidth(t,i);
                C_sumR2(Contraa,i)=sumR2(t,i);
                C_singleR2(Contraa,i) =singleR2(t,i);
                C_differentialFit(Contraa,i)=sumR2(t,i)-singleR2(t,i);
                C_500uM_Lateral(Contraa,i)=mean(thistrace(i,stims(1,t)+19:stims(1,t)+21));
                C_500uM_Medial(Contraa,i)=mean(thistrace(i,stims(1,t)-21:stims(1,t)-19));
                C_250uM_Lateral(Contraa,i)=mean(thistrace(i,stims(1,t)+9:stims(1,t)+11));
                C_250uM_Medial(Contraa,i)=mean(thistrace(i,stims(1,t)-11:stims(1,t)-9));
                C_Area(Contraa,i)=Area(t,i);
                C_Dir_Ind_H(Contraa,i)=(peaks(t,2)-(SHalfwidthDirInd2(t,1))-(SHalfwidthDirInd(t,1)-peaks(t,2)));
                C_Dir_Ind_Q(Contraa,i)=(peaks(t,2)-(SQwidthDirInd2(t,1))-(SQwidthDirInd(t,1)-peaks(t,2)));
                C_Dir_Ind_T(Contraa,i)=(peaks(t,2)-(STwidthDirInd2(t,1))-(STwidthDirInd(t,1)-peaks(t,2)));
            else
                if Plotting==1
                figure (2)
                plot((peaks(t,2,i)-stims(1,t)),peaks(t,1,i),'Color',RGBCustom(i,:), 'MarkerEdgeColor','black','MarkerFaceColor',RGBCustom(i,:),'MarkerSize',12,'Marker','o','LineWidth', 2);
                hold on
                figure(4)
                plot(-(centroid(t,i)-peaks(t,2,i)),peaks(t,1,i),'Color',RGBCustom(i,:), 'MarkerEdgeColor',[0.5 0.5 0.5],'MarkerFaceColor',RGBCustom(i,:),'MarkerSize',12,'Marker','o','LineWidth', 2);
                hold on
                end
                if peaks(t,1,i)>0.01
                    Contraweighted(Contraa,i)=-(peaks(t,2,i)-stims(1,t))*peaks(t,1,i);
                    Ccount=Ccount+1;
                    CIntens(Ccount)=peaks(t,1,i);
                    Chist_Raw(Ccount)=-(peaks(t,2,i)-stims(1,t));
                    Chist_Centroid(Ccount)=-(centroid(t,i)-peaks(t,2,i));
                else
                    Contraweighted(Contraa,i)=0;
                end
                Contraraw(Contraa,i)=-(peaks(t,2,i)-stims(1,t));
                C_Peaks(Contraa,i)=(peaks(t,2,i));
                CInsensity(Contraa,i)=peaks(t,1,i);
                if centroid(t,i)~=0
                C_Centroid_peak_ref(Contraa,i)=-(centroid(t,i)-peaks(t,2,i));
                C_Centroid_stim_ref(Contraa,i)=-(centroid(t,i)-stims(1,t));
                else
                    C_centroid_peak_ref(Contraa,i)=0;
                    C_Centroid_stim_ref(Contraa,i)=0;
                end
                C_Centroid_peakweighted_ref(Contraa,i)=-(centroid(t,i)-peaks(t,2,i))*peaks(t,2,i);
                C_SummedG_Half_Width(Contraa,i)=SGhalfwidth(t,i);
                C_SummedG_Half_Width_Thresh(Contraa,i)=STheshwidth(t,i);
                C_SummedG_Quarter_Width(Contraa,i)=SQuarterwidth(t,i);
                C_sumR2(Contraa,i)=sumR2(t,i);
                C_singleR2(Contraa,i) =singleR2(t,i);
                C_differentialFit(Contraa,i)=sumR2(t,i)-singleR2(t,i);
                C_500uM_Lateral(Contraa,i)=mean(thistrace(i,stims(1,t)-21:stims(1,t)-19));
                C_500uM_Medial(Contraa,i)=mean(thistrace(i,stims(1,t)+19:stims(1,t)+21));
                C_250uM_Lateral(Contraa,i)=mean(thistrace(i,stims(1,t)-11:stims(1,t)-9));
                C_250uM_Medial(Contraa,i)=mean(thistrace(i,stims(1,t)+9:stims(1,t)+11));
                C_Area(Contraa,i)=Area(t,i);
                C_Dir_Ind_H(Contraa,i)=-(peaks(t,2)-(SHalfwidthDirInd2(t,1))-(SHalfwidthDirInd(t,1)-peaks(t,2)));
                C_Dir_Ind_Q(Contraa,i)=-(peaks(t,2)-(SQwidthDirInd2(t,1))-(SQwidthDirInd(t,1)-peaks(t,2)));
                C_Dir_Ind_T(Contraa,i)=-(peaks(t,2)-(STwidthDirInd2(t,1))-(STwidthDirInd(t,1)-peaks(t,2)));
            end
        end
    end
    if FL_yes_or_no(t)~=1
    C_Diff_Sm(Contraa,:)=smooth(C_differentialFit(Contraa,:));
    C_Centroid_peak_ref_sm(Contraa,:)=smooth(C_Centroid_peak_ref(Contraa,:));
    C_Centroid_stim_ref_sm(Contraa,:)=smooth(C_Centroid_stim_ref(Contraa,:));
    else
    FL_Diff_Sm(FLa,:)=smooth(FL_differentialFit(FLa,:));
    FL_Centroid_peak_ref_sm(FLa,:)=smooth(FL_Centroid_peak_ref(FLa,:));
    FL_Centroid_stim_ref_sm(FLa,:)=smooth(FL_Centroid_stim_ref(FLa,:));
    end
    myasshurts='yes';
    clear thistrace;
end
if Plotting==1
figure(1)
box off
set(gca,'xlim',[-30 30],'xtick',[ -20 0 20 ], 'ytick',[0.1 0.2])
set(gca,'FontSize',28);
printfilenamesm=sprintf('%s/FLPeaks.tif',dirname);
print ('-dtiff','-r400', printfilenamesm)
figure(3)
box off
set(gca,'xlim',[-30 30],'xtick',[ -20 0 20 ], 'ytick',[0.1 0.2])
set(gca,'FontSize',28);
printfilenamesm=sprintf('%s/CPeaks.tif',dirname);
print ('-dtiff','-r400', printfilenamesm)
figure(2)
box off
set(gca,'xlim',[-30 30],'xtick',[ -20 0 20 ], 'ytick',[0.1 0.2])
set(gca,'FontSize',28);
printfilenamesm=sprintf('%s/CCent.tif',dirname);
print ('-dtiff','-r400', printfilenamesm)
figure(4)
box off
set(gca,'xlim',[-30 30],'xtick',[ -20 0 20 ], 'ytick',[0.1 0.2])
set(gca,'FontSize',28);
printfilenamesm=sprintf('%s/FLCent.tif',dirname);
print ('-dtiff','-r400', printfilenamesm)
end
