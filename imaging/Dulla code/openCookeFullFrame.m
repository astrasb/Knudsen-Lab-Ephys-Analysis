function [Images, Width,Height,Frames,NumberExposures, filename, FrameTimes]=opencookefullframe(filename); %[Images,Width,Height,Frames]
% **  function
%function [Images,Width,Height,Frames]=opencookefullframe(filename)

% loads Cooke Camera fullframe (non-line scan) data file subtracts camers dark noise and returns 3 dimensional array as a series of frames

%                    >>> INPUT VARIABLES >>>
%
% NAME        TYPE, DEFAULT      DESCRIPTION
% fn          char array         cooke data file name
% 
%                    <<< OUTPUT VARIABLES <<<
%
% NAME        TYPE            DESCRIPTION
% Images      double                      the data read, in a x,y,t dataformat
% Width      double                     Width of frame in pixels
% Height      double                    Height of frame in pixels
% Frames      double                     Number of frames
% DarkFrame double   an array of pixels from camera representing  a dark frame
% 



fid=0;  %Data file location
hid=0;  %Header file location

datafilename='file/file.out';  %works if the file is in the current directory in a folder named identically to the file
headerfilename='file/file.t';
replaced='file';

datafilename=strrep(datafilename,replaced,filename);
headerfilename=strrep(headerfilename,replaced,filename);
    
    [fid, message] = fopen(datafilename, 'rb');
    [hid, message] = fopen(headerfilename, 'rb');
    if fid==-1;
        if fid==-1
            disp (message)
        end
    end
    if hid==-1;
        if hid==-1
            disp (message)
        end
    end
Header=fread(hid,10,'int');             %Read Header File
                                        %%% Header file Structure from SenDemo C code
                                        %struct myfileheader  {
                                        %int x;
                                        %int y; 
                                        %int ntrials;
                                        %int nexposures;
                                        %int binnum;
                                        %int exportfact;
                                        %int rangeint;
                                        %int normh;
                                        %int norml;
                                        %int stdevi;
Width=Header(1,1);
Height=Header(2,1);
NumberFrames=Header(3,1);
Frames=Header(3,1);
NumberExposures=Header(4,1);
Times=fread(hid,NumberFrames*NumberExposures, 'short');
disp ('Header read');

%%%%%%%%%%%%%%%%%%%%%%%%%% Setting Memory to the correct format

Images=zeros(Width,Height,NumberFrames,NumberExposures, 'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%% Reading Data

Images=fread(fid,Width*Height*NumberFrames*NumberExposures,'int16');
FrameTimes=reshape(Times,Frames, []);
disp('File read');

fclose(fid);
fclose(hid);

end
