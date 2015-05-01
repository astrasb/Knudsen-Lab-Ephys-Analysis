function [peaks, g1p,g1w,g2p,g2w, peaks_summed,peaks_g1, peaks_g2, centroid,SGhalfwidth, SummedG,sumR2,singleR2, STheshwidth, SQuarterwidth, Area, SHalfwidthDirInd,SHalfwidthDirInd2, SQwidthDirInd, SQwidthDirInd2,STwidthDirInd,STwidthDirInd2,FirstPeak, FirstIndex, SecondPeak, SecondIndex, Area1, Area2]=ColorIteration_for_Afferent_Mapping(data)
%%% Color Itteration with plotting

number_of_lines=ceil(size(data,2));

x=1:size(data,2);
dot_threshold=0.01;

centroid=0;
[maxim index]=max(data);
    peaks=[maxim; index];
    [cfs, sumR2]=Sum_of_Gaussiancs(x',data');
    [cfs1, singleR2]=Single_Gaussiancs(x',data');
    
    FirstG=ProjectFirstGaussianFromDoubleGaussianCoeefs(size(x,2),cfs);
    SecondG=ProjectSecondGaussianFromDoubleGaussianCoeefs(size(x,2),cfs);
    SummedG=ProjectSummedGaussianFromDoubleGaussianCoeefs(size(x,2),cfs);
    
    if max(FirstG)<max(SecondG)
        temp=FirstG;
        FirstG=SecondG;
        SecondG=temp;
    end
    [FirstPeak FirstIndex]=max(FirstG);
    [SecondPeak SecondIndex]=max(SecondG);
    Area1=sum(FirstG);
    Area2=sum(SecondG);
      
    Area=sum(data);
    for kk=1:size(x,2)
        centroid=SummedG(kk)*kk+centroid;
    end
    
    centroid=centroid/sum(SummedG);
    plot(data,'Color','black', 'LineWidth', 4);
    hold on
    plot(centroid,maxim+0.005,'MarkerEdgeColor','black','MarkerFaceColor','white','MarkerSize',8,'Marker','o', 'LineWidth',3)
    plot(index,maxim+0.005,'MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8,'Marker','o')  
  
    [maximgsum indexgsum]=max(SummedG);
    peaks_summed=[maximgsum; indexgsum];
    [maximg1 indexg1]=max(FirstG);
    peaks_g1=[maximg1; indexg1];
    [maximg2 indexg2]=max(SecondG);
    peaks_g2=[maximg2; indexg2];
    g1p=cfs.b1;
    g1w=cfs.c1;
    g2p=cfs.b2;
    g2w=cfs.c2;
    
    [halfvals halfindex]=find(SummedG>maximgsum/2);
    [quartervals quarterindex]=find(SummedG>maximgsum/4);
    [theshvals theshindex]=find(SummedG>0.01);
    if (maxim>dot_threshold)&(size(halfindex,2)>1)&(size(theshindex>2))
                 SGhalfwidth=max(halfindex)-min(halfindex);
                 SQuarterwidth=max(quarterindex)-min(quarterindex);
                 STheshwidth=max(theshindex)-min(theshindex);
                 SHalfwidthDirInd=max(halfindex);
                 SHalfwidthDirInd2=min(halfindex);
                 SQwidthDirInd=max(quarterindex);
                 SQwidthDirInd2=min(quarterindex);
                 STwidthDirInd=max(theshindex);
                 STwidthDirInd2=min(theshindex);
                 
    else
            SGhalfwidth=0;
                 SQuarterwidth=0;
                 STheshwidth=0;
                 SHalfwidthDirInd=0;
                 SHalfwidthDirInd2=0;
                 SQwidthDirInd=0;
                 SQwidthDirInd2=0;
                 STwidthDirInd=0;
                 STwidthDirInd2=0;
    end
    if maxim<dot_threshold
       sumR2=0;
       singleR2=0;
       centroid=0;
    end
    
end


