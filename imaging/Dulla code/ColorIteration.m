function [peaks, g1p,g1w,g2p,g2w, peaks_summed,peaks_g1, peaks_g2, centroid,SGhalfwidth, SummedG,sumR2,singleR2, STheshwidth, SQuarterwidth, Area,SHalfwidthDirInd,SHalfwidthDirInd2, SQwidthDirInd, SQwidthDirInd2,STwidthDirInd,STwidthDirInd2, FirstPeak, FirstIndex, SecondPeak, SecondIndex, Area1, Area2 ]=ColorIteration_for_Profiling(data)
%%% Color Itteration with plotting
number_of_lines=ceil(size(data,2));
PaletteSize=number_of_lines;
QuadrantSize=ceil((PaletteSize)/4);
PaletteStepSize=ceil(PaletteSize/QuadrantSize);
RGBCustom=zeros(QuadrantSize, 3);
%Table Goes R, G, B for the third dimension

for i=1:QuadrantSize
    RGBCustom(i,1)=0;
    RGBCustom(i,2)=((i-1)*PaletteStepSize)/PaletteSize;
    RGBCustom(i,3)=1;
end

for i=QuadrantSize+1:2*QuadrantSize
    RGBCustom(i,1)=0;
    RGBCustom(i,2)=1;
    RGBCustom(i,3)=((QuadrantSize*2-i)*PaletteStepSize)/number_of_lines;
end

for i=QuadrantSize*2+1:3*QuadrantSize
    RGBCustom(i,1)=((i-QuadrantSize*2)*PaletteStepSize-1)/number_of_lines;
    RGBCustom(i,2)=1;
    RGBCustom(i,3)=0;
end


for i=QuadrantSize*3+1:4*QuadrantSize
    RGBCustom(i,1)=1;
    RGBCustom(i,2)=(QuadrantSize*4-i)*PaletteStepSize/number_of_lines;
    RGBCustom(i,3)=0;
end
x=1:size(data,1)';
dot_threshold=0.01;

overshot=find(RGBCustom>1);
RGBCustom(overshot)=1;
for i=1:number_of_lines
    centroid(i)=0;
    plot(data(:,i),'Color',RGBCustom(i,:), 'LineWidth', 4);
    hold on
    [maxim(i) index(i)]=max(data(:,i));
    if maxim(i)>dot_threshold
        plot(index(i),maxim(i)+0.005,'MarkerEdgeColor',RGBCustom(i,:),'MarkerFaceColor',RGBCustom(i,:),'MarkerSize',8,'Marker','o')
    end
    peaks=[maxim; index];
    [cfs, sumR2(i,:)]=Sum_of_Gaussiancs(x',data(:,i));
    [cfs1, singleR2(i,:)]=Single_Gaussiancs(x',data(:,i));
    
    FirstG(i,:)=ProjectFirstGaussianFromDoubleGaussianCoeefs(size(x,2),cfs);
    SecondG(i,:)=ProjectSecondGaussianFromDoubleGaussianCoeefs(size(x,2),cfs);
    SummedG(i,:)=ProjectSummedGaussianFromDoubleGaussianCoeefs(size(x,2),cfs);
    
    if max(FirstG(i,:))<max(SecondG(i,:))
        temp=FirstG(i,:);
        FirstG(i,:)=SecondG(i,:);
        SecondG(i,:)=temp;
    end
    [FirstPeak(i) FirstIndex(i)]=max(FirstG(i,:));
    [SecondPeak(i) SecondIndex(i)]=max(SecondG(i,:));
    Area1(i)=sum(FirstG(i,:));
    Area2(i)=sum(SecondG(i,:));
    
    Area(i)=sum(data(:,i));
    for kk=1:size(x,2)
        centroid(i)=SummedG(i,kk)*kk+centroid(i);
    end
    
    centroid(i)=centroid(i)/sum(SummedG(i,:));
    if maxim(i)>dot_threshold
        plot(centroid(i),maxim(i)+0.005,'MarkerEdgeColor',RGBCustom(i,:),'MarkerFaceColor','white','MarkerSize',8,'Marker','o', 'LineWidth',3)
               
    end
    plot(FirstG(i,:),':','color',RGBCustom(i,:),'LineWidth',3)
    plot(SecondG(i,:),':','color',RGBCustom(i,:),'LineWidth',3)
    plot(SummedG(i,:),':','color',RGBCustom(i,:),'LineWidth',3)
    
    [maximgsum(i) indexgsum(i)]=max(SummedG(i,:));
    peaks_summed=[maximgsum; indexgsum];
    [maximg1(i) indexg1(i)]=max(FirstG(i,:));
    peaks_g1=[maximg1; indexg1];
    [maximg2(i) indexg2(i)]=max(SecondG(i,:));
    peaks_g2=[maximg2; indexg2];
    g1p(i)=cfs.b1;
    g1w(i)=cfs.c1;
    g2p(i)=cfs.b2;
    g2w(i)=cfs.c2;
    
    [halfvals halfindex]=find(SummedG(i,:)>maximgsum(i)/2);
    [quartervals quarterindex]=find(SummedG(i,:)>maximgsum(i)/4);
    [theshvals theshindex]=find(SummedG(i,:)>0.01);
    if (maxim(i)>dot_threshold)&(size(halfindex,2)>1)&(size(theshindex>2))
                 SGhalfwidth(i)=max(halfindex)-min(halfindex);
                 SQuarterwidth(i)=max(quarterindex)-min(quarterindex);
                 STheshwidth(i)=max(theshindex)-min(theshindex);
                 SHalfwidthDirInd(i)=max(halfindex);
                 SHalfwidthDirInd2(i)=min(halfindex);
                 SQwidthDirInd(i)=max(quarterindex);
                 SQwidthDirInd2(i)=min(quarterindex);
                 STwidthDirInd(i)=max(theshindex);
                 STwidthDirInd2(i)=min(theshindex);
            else
        SGhalfwidth(i)=0;
        STheshwidth(i)=0;
        SQuarterwidth(i)=0;
        SHalfwidthDirInd(i)=0;
        SHalfwidthDirInd2(i)=0;
        SQwidthDirInd(i)=0;
        SQwidthDirInd2(i)=0;
        STwidthDirInd(i)=0;
        STwidthDirInd2(i)=0;
    end
    if maxim(i)<dot_threshold
       sumR2(i,:)=0;
       singleR2(i,:)=0;
       centroid(i)=0;
    end
    
end


end