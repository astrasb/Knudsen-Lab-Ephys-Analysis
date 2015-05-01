 function [CellArrayImages, FrameTimes, TraceData,  FrameInterval, Inside_Mask, Outside_Mask]=RedShirtOpenSequences(filename,dfsubtract,MS_of_Data_to_Discard_Start, MS_of_Data_to_Discard_End, Masking_Factor, Mask_Counter, Inside_Mask, Outside_Mask )
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
    

ExposureNumber=1;                                                                   %%% RedShirt only has 1 exposure per file

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Clips the data using the %%%%%%%%%%%%%
%%%      Discard values       %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CellArrayImages{1}=Images(:,:,MS_of_Data_to_Discard_Start/FrameInterval:Frames-(MS_of_Data_to_Discard_End/FrameInterval));
FrameTimes=FrameTimes(MS_of_Data_to_Discard_Start/FrameInterval:Frames-(MS_of_Data_to_Discard_End/FrameInterval));
TraceData=TraceData(1,MS_of_Data_to_Discard_Start/FrameInterval:Frames-(MS_of_Data_to_Discard_End/FrameInterval));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Creating an image mask based on the location of the slice %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Mask_Counter==1
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%% Important Step #1
%  Look at the image and by eye estimate what the intensity of the mask
%  cutoff should be    


% Lets you draw a picture of the image    
%image(Sample_Image_for_Making_Mask,'CDataMapping','scaled')
% type the above line into the command window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Sample_Image_for_Making_Mask=Images(:,:,floor(MS_of_Data_to_Discard_Start/FrameInterval));                           %%% Grabs a frame at the end of the discarded time
Sample_Image_for_Making_Mask=Sample_Image_for_Making_Mask(1:(size(Sample_Image_for_Making_Mask, 1)/2),:);     %%% Takes the top half of the image
Sample_Image_for_Making_Mask_Unfolded=reshape(Sample_Image_for_Making_Mask,1,[]);
%%% Next line gives you a histogram of the pixel intensity
%%% plot (xout, a)

[a xout]=hist(Sample_Image_for_Making_Mask_Unfolded,100);

%%% plot (xout, aa)

aa=smooth(a,'moving');
daa=diff(aa);

%%% plot (xout(1:99), daa)
Crosspoint=find(daa<0);
dc=diff(Crosspoint);
dcPoint=find(dc>5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%% Important Step #2
%%% Mask_Threshold is the value that the program thinks you should mask
%%% with
%%% Confirm that Mask_Threshold is approximately the intensity value that
%%% you think it should be based on the image you just looked at

%%%  There are 2 ways to change the mask threshold
%%%  #1 - change X - xout(Crosspoint(dcPoint(X)))
%%%  #2 - manually adjust or set the value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Mask_Threshold =2600;
Mask_Threshold=xout(Crosspoint(dcPoint(2)));
%Mask_Threshold=mean(mean(Sample_Image_for_Making_Mask))-std(std(Sample_Image_for_Making_Mask))*Masking_Factor;
Inside_Mask=find(Sample_Image_for_Making_Mask>Mask_Threshold);
Outside_Mask=find(Sample_Image_for_Making_Mask<Mask_Threshold);
end
end