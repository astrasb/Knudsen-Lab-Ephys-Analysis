
function [RoiAveCh1, RoiAveCh2] = DualChannelROIRedShirt (Width, Height, Frames, Images, ROICh1, ROICh2, ThisFrame, exposure);

    imgreshape=reshape(:,:,ThisFrame);
    RoiAveCh1=mean(mean(imgreshape(ROICh1(1,1):ROICh1(2,1),ROICh1(1,2):ROICh1(2,2))));
    RoiAveCh2=mean(mean(imgreshape(ROICh2(1,1):ROICh2(2,1),ROICh2(1,2):ROICh2(2,2)))); 
end