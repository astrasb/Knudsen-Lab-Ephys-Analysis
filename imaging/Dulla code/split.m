 function [Ratio,Left,Right]=split(Images,LeftShift,DownShift,RatioReturned)
% **  function [Ratio,Left,Right]=split(Images,LeftShift,DownShift,ReturnRatio,DarkFrame)
% Splits a series of frames into left and right halves, and optionally shifts the right, and optionally returns ratio array

%                    >>> INPUT VARIABLES >>>
%
% NAME        TYPE, DEFAULT      DESCRIPTION
% Images      double                      the data, in a x,y,t dataformat
% LeftShift   double (could be int),0         amount to shift right image laterally
% DownShift   double (could be int),0         amount to shift right image  vertically
% ReturnRatio   double (could be int),0         if non zero, then return new ratio array
% DarkFrame     double                  Dark Frame from camera for image subtraction
%                    <<< OUTPUT VARIABLES <<<
%
% NAME        TYPE            DESCRIPTION
% Left      double                      the data for the left half-frames, in a x,y,t dataformat
% Right      double                      the data for the right half-frames, in a x,y,t dataformat
% Ratio      double                      the data containing the ratio image,half-frames, in a x,y,t dataformat

%  process optional arguments

if nargin < 4
  ReturnRation = 0;      % default
  if nargin < 3
    DownShift = 0;     % default
    if nargin < 2
      LeftShift = 0;   % default
    end
  end
end

arsize=size(Images);
Width=arsize(1);
Height=arsize(2);
Frames=arsize(3);

HalfWidth=Width/2;
% amounts to shift each right image to align with left
Shifts = [ LeftShift, DownShift ];

%preallocate these to avoid dynamic allocating later
Left=zeros(Height,HalfWidth,Frames);
Right=zeros(Height,HalfWidth,Frames);
if RatioReturned~=0
  Ratio=zeros(Height,HalfWidth,Frames);
end

for k=1:Frames
  Left(:,:,k)=Images(:,1:HalfWidth,k);
  Right(:,:,k)=Images(:,HalfWidth+1:Width,k);
  % the circular shift command is reversible.  If you negate the LeftShift and DownShift and
  % repeat the command it will put the frame image back like it was.
  if (LeftShift~=0) && (DownShift~=0)
    Right(:,:,k)=circshift(Right(:,:,k),Shifts);
  end
  if RatioReturned~=0
    Ratio(:,:,k)=Left(:,:,k)./Right(:,:,k);
  end
end


   

