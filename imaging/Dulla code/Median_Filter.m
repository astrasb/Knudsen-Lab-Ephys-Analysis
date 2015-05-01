function [CellArrayImages]=Median_Filter(CellArrayImages, MatrixSize, exposure)


tempimage=CellArrayImages{exposure};
Frames=size(tempimage,3);
Height=size(tempimage,2);
Width=size(tempimage,1);
ImagesOut=zeros(Width,Height,Frames);
for frame=1:Frames
       
        tempimage2=tempimage(:,:,frame);
        tempimage2=medfilt2(tempimage2, [MatrixSize MatrixSize]);
        ImagesOut(:,:,frame)=tempimage2;
             
end
CellArrayImages{exposure}=ImagesOut;

end