 function [Images,Width,Height,Frames,Timeseries,TraceData,DarkFrame]=openredshirt(fn,dfsubtract)
% **  function
% [Images,Width,Height,Frames,Timeseries,TraceData,DarkFrame]=openredshirt(fn)

% loads red shirt data file and returns 3 dimensional array as a series of frames

%                    >>> INPUT VARIABLES >>>
%
% NAME        TYPE, DEFAULT      DESCRIPTION
% fn          char array         redshirt data file name
% dfsubtract    double  flag to indicate whether Image array should be
%                       DarkFrame corrected
%
%                    <<< OUTPUT VARIABLES <<<
%
% NAME        TYPE            DESCRIPTION
% Images      double                      the data read, in a x,y,t dataformat
% Width      double                     Width of frame in pixels
% Height      double                    Height of frame in pixels
% Frames      double                     Number of frames
% Timeseries  double                     an array of sample times [1..Frames]
% TraceData  double                     an array of electrophysiological samples  [1..Frames][1..numchannels]
% DarkFrame double   an array of pixels from camera representing  a dark frame
% 
fid=0;
while fid <1
    [fid, message] = fopen(fn, 'rb');
    if fid==-1;
        if fid==-1
            disp (message)
        end
    end
end
Header=fread(fid,2560,'short');
Height=Header(386,1);
Width=Header(385,1);
Frames=Header(5,1);
disp('Header read');
TempHolder=fread(fid,Width*Height*Frames, 'short');
TraceData=zeros(8,Frames);
TempTraceData=zeros(1,Frames,'int16');
for i=1:8
    TraceData(i,:)=fread(fid,Frames,'short');
end
DarkFrame=fread(fid,Width*Height, 'short');
DarkFrame=reshape(DarkFrame,Width,Height);
%DarkFrame=TempHolder;
%size(DarkFrame)
fclose(fid);
disp('File read');
Timeseries=[1:Frames]*(Header(389,1)/1000.); %check header structure to find frame interval (ms?)

% first reshape the array so that it is nframes tall and x*y wide
if 2<1
    Images=zeros(Width,Height,Frames);
for k=1:Height  
		exptracker=(k-1)*Width*Frames;
		kholder=(k-1)*Width;
		for l=1:Width
			frametracker=(l-1)*Frames;
			for i=1:Frames
				dataholder= exptracker + frametracker +i;
                memholder= i*Height*Width+kholder+l;
				Images(l,k,i)=TempHolder(dataholder);
			end
       end
end

end

   
if 1>0


TempHolder=reshape(TempHolder,Frames,[]);
disp('First Reshape Done');
%TempHolder2=TempHolder;
TempHolder=reshape(TempHolder',Height,Width,Frames);
% now have frames, but each one is xy transposed... getting closer?
disp('Second Reshape Done');
% the following seems to be a quick way to fix the fact that each frame is xy transposed
Images=permute(TempHolder,[2 1 3 ]);
disp('Final Reshape/permutation Done');
clear TempHolder;
for i=1,Frames
    Images(:,:,i)=Images(:,:,i)-DarkFrame;
end
disp('DarkFrame subtracted');
end