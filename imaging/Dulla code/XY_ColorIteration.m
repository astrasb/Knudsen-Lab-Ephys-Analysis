function XY_ColorIteration(data,data2, timescalefactor)
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
m=mean(data);
se=std(data)/sqrt(size(data,2));
m2=mean(data2);
se2=std(data2)/sqrt(size(data2,2));
for i=1:number_of_lines
    
   errorbar(i*timescalefactor,m(i),se(i),se(i),'Color',[0 0 0], 'MarkerEdgeColor','black','MarkerFaceColor',RGBCustom(i,:),'MarkerSize',10,'Marker','o','LineWidth',3);
   hold on
   errorbar(i*timescalefactor,m2(i),se2(i),se2(i),'Color', [.5 .5 .5], 'MarkerEdgeColor',[.5 .5 .5] ,'MarkerFaceColor',RGBCustom(i,:),'MarkerSize',10,'Marker','o','LineWidth',3);
   hold on
end


end