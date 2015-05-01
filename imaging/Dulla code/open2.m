fid=0;
while fid <1
%    filename=input('Open file: ', 's');
    [fid, message] = fopen('/mnt/striperaid/tempstorage/chris/2008_02_06_0030.da', 'rb');
    if fid==-1;
        if fid==-1
            disp (message)
        end
    end
Header=cast(0.0,'int16');
Header=fread(fid,2560,'short');

Height=Header(386,1);
Width=Header(385,1);
NumberFrames=Header(5,1);
%Images=(Height, Width, NumberFrames);
end
disp('Header read');
TempHolder=fread(fid,Width*Height*NumberFrames, 'short');
fclose(fid);
disp('File read');
% first reshape the array so that it is nframes tall and x*y wide
TempHolder=reshape(TempHolder,NumberFrames,[]);
disp('First Reshape Done');
%now have frames, but each one is xy transposed... getting closer?
TempHolder=reshape(TempHolder',Height,Width,NumberFrames);
disp('Second Reshape Done');
% the following seems to be a quick way to fix the fact that each frame is xy transposed
Images=permute(TempHolder,[2 1 3 ]);


HalfWidth=Width/2;
% amounts to shift each right image to align with left
LeftShift=1;
DownShift=1;
Shifts = [ LeftShift DownShift ];


%preallocate these to avoid dynamic allocating later
Images=zeros(Width,Height,NumberFrames);
Left=zeros(HalfWidth,Height,NumberFrames);
Right=zeros(HalfWidth,Height,NumberFrames);
Ratio=zeros(HalfWidth,Height,NumberFrames);


for k=1:NumberFrames

% the following works, but may not need to be done if the permute function above works.
% the permute should be faster
%Images(:,:,k)=TempHolder(:,:,k)';
LeftTemp=Images(1:HalfWidth,:,k);
Left(:,:,k)=LeftTemp;
RightTemp=Images(HalfWidth+1:Width,:,k);
Right(:,:,k)=RightTemp;
% the circular shift command is reversible.  If you negate the LeftShift and DownShift and
% repeat the command it will put the frame image back like it was.
RightTemp=circshift(RightTemp,Shifts);
Ratio(:,:,k)=LeftTemp./RightTemp;
end
disp('Image transpose Done');
clear TempHolder;

disp('Ratio calculation Done');

   

