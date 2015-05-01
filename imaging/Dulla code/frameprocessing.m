function [ImageLocation, RoiAveCh1, RoiAveCh2] = frameprocessing (Width, Height, Frames, Images, ROICh1, ROICh2, ThisFrame, filename)

    temp=Images((ThisFrame-1)*Width*Height+1:(ThisFrame)*Width*Height);
    imgreshape=reshape(temp,Width,Height);
    RoiAveCh1=mean(mean(imgreshape(ROICh1(1,1):ROICh1(2,1),ROICh1(1,2):ROICh1(2,2))));
    RoiAveCh2=mean(mean(imgreshape(ROICh2(1,1):ROICh2(2,1),ROICh2(1,2):ROICh2(2,2))));    
    ThisFrameStr=int2str(ThisFrame);
    replaced='file';
    replaced2='fr';
    ImageLocation='file/file_fr.tif';
    ImageLocation=strrep(ImageLocation,replaced,filename);
    ImageLocation=strrep(ImageLocation,replaced2,ThisFrameStr);
    figure(ThisFrame)
    image(imgreshape, 'CDataMapping', 'scaled');
    axis image;
    
    %imwrite(imgreshape,ImageLocation,'tif');
    
    
end