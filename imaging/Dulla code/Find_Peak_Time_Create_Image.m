function [outimage]=Find_Peak_Time_Create_Image(CellArrayImages, Inside_Mask, Outside_Mask)

tempimage=CellArrayImages{1};
Frames=size(tempimage,3);
Height=size(tempimage,2);
Width=size(tempimage,1);
timeimage=zeros(Width,Height);
for h=1:Height
    for w=1:Width
    [minval mintime]=min(tempimage(w,h,:));    
    timeimage(w,h)=mintime;
    end
end
adjust=min(min(timeimage(Inside_Mask)));
subtract=ones(w,h);
subtract=subtract*adjust;

outimage=timeimage-subtract;
i=find(outimage<0);
outimage(i)=0;
end