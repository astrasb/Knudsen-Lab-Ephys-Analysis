function [SummedFrame]=SumFrames(Input, StartFrame, EndFrame);
% **  function
% [AveragedFrame]=FrameAverage(Input, StartFrame, EndFrame)
% Averages multiple frames into one output frame

%                    >>> INPUT VARIABLES >>>
%
% NAME                        TYPE, DEFAULT                   DESCRIPTION
% Input                                                       Matrix (NOT CELL ARRAY) to get the frames from
% StartFrame                                                  First Frame to Avergae
% EndFrame                                                    Last Frame to Average
%                       <<< OUTPUT VARIABLES <<<
%
% NAME                      TYPE                              DESCRIPTION
% Averaged Frame                                              Output averaged frame
% 
%%%%%% Gets data properties
Frames=size(Input,3);
Height=size(Input,2);
Width=size(Input,1);

%%%%%% Allocates Memory
AveragedFrame=zeros(Width, Height);

%%%%%% Averages frames for output
for i= StartFrame:EndFrame
    tempFrame=Input(:,:,i);
    if i-StartFrame+1==1
        SummedFrame=tempFrame;
    else
        SummedFrame=AveragedFrame+tempFrame;
    end

   


end
