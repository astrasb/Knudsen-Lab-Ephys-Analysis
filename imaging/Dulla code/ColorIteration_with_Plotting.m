%%% Color Itteration with plotting
number_of_lines=20;
PaletteSize=number_of_lines;
QuadrantSize=(PaletteSize)/4;
PaletteStepSize=PaletteSize/QuadrantSize;
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

for i=1:number_of_lines
    x=1:100;
    data(i,:)=1:i:i*100;
end
spacing_step=max(max(data))/number_of_lines;
for i=1:number_of_lines
   plot(x,data(i,:),'Color',RGBCustom(i,:), 'LineWidth', 2);
   text(.2,spacing_step*i,'Label', 'Color',RGBCustom(i,:))
   hold on
end