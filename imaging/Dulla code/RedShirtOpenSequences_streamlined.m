 function [Images, FrameTimes, TraceData,  FrameInterval]=RedShirtOpenSequences_streamlined(filename)
% **  function
% [Images,Width,Height,Frames,Timeseries,TraceData,DarkFrame]=openredshirt(fn)

% loads red shirt data file and returns 3 dimensional array as a series of
% frames inside of a cell array 

%                    >>> INPUT VARIABLES >>>
%
% NAME                        TYPE, DEFAULT                   DESCRIPTION
% filename                    char array                      redshirt data file name
% dfsubtract                  double                          flag to indicate whether Image array should be DarkFrame corrected
% MS_of_Data_to_Discard_Start                                 ms of data to ignore on the front end of an expose - to adjust for shutter lag time
% MS_of_Data_to_Discard_End                                   ms of data to ignore on the back end of an expose - to adjust for shutter lag time
% Masking_Factor                                              Adjusts the masking threshold - a bigger number = threshold is farther from the mean
%                    <<< OUTPUT VARIABLES <<<
%
% NAME                      TYPE                        DESCRIPTION
% CellArrayImages           double                      the data read, in a x,y,t dataformat
% FrameTimes                double                      an array of sample times [1..Frames]
% TraceData                 double                      an array of electrophysiological samples  [1..Frames]- ONLY CH1 is output in this script
% FrameInterval             double                      sampling interval in ms
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Does the file exist? %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%  Put a stop codon/point at the masking code approx line 122


fid=0;
    [fid, message] = fopen(filename, 'rb');
    
    if fid==-1;
        if fid==-1
            disp (message)
        end
    end
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  Reading the header %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Header=fread(fid,2560,'short');
Height=Header(386,1);
Width=Header(385,1);
Frames=Header(5,1);
FrameInterval=Header(389,1)/1000;
disp('Header read');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Allocating Memory %%%%%%%%%%%%%
%%%%%%%%%% & Reading         %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TempHolder=zeros(Width,Height,Frames, 'single');
Images=zeros(Width,Height,Frames, 'single');
TraceData=zeros(8,Frames);
TempTraceData=zeros(1,Frames,'single');
Images=reshape(Images, Width,Height,Frames);
TempHolder=fread(fid,Width*Height*Frames, 'int16');             %%%%%%%%%%%%%%%%%% Reads the image data
TempHolder=reshape(TempHolder, Frames, []);

for i=1:8                                                       %%%%%%%%%%%%%%%%%% Reads in BNC inputs
    TraceData(i,:)=fread(fid,Frames,'int16');
end
TraceData=(TraceData*10/2^15)-5;                                %%%%%%%%%%%%%%%%%% Scales the BNC data into mV
DarkFrame=fread(fid,Width*Height, 'int16');                     %%%%%%%%%%%%%%%%%% Reads the Dark Frame
DarkFrame=reshape(DarkFrame,Width,Height);
DarkFrame=rot90(DarkFrame);
fclose(fid);
disp('File read');


FrameTimes=[1:Frames]*(Header(389,1)/1000.);                    %%%%%%%%%%%%%%%%%%% check header structure to find frame interval (ms?)


for thisFrame=1:Frames                                          %%%%%%%%%%%%%%%%%%% Reshapes each frame into X and Y dimensions
        datapoint=TempHolder(thisFrame,:);
        tempframe=reshape(datapoint,Width,Height);
        Images(:,:,thisFrame)=tempframe-DarkFrame;
        
end
i=Images<0;
Images(i)=0;
clear TempHolder;
disp('DarkFrame subtracted');




end
