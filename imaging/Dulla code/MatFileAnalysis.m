function [ThresholdDone]=MatFileAnalysis(fullfilename,directoryname);
% **  function
% [ThresholdDone]=ThresholdSequences(filename);

% loads red shirt data file and outputs treshhold graphs, e-phsytraces,
% jpeg images, as well as a .mat file containing the e-phys trace and each
% threshold point time series


%                    >>> INPUT VARIABLES >>>
%
% NAME        TYPE, DEFAULT      DESCRIPTION
% filename          char array         redshirt data file name
% 
%
%                    <<< OUTPUT VARIABLES <<<
%
% NAME        TYPE            DESCRIPTION
% ThresholdDone      double            1= succesfully processed data
% 
% 

%%%%%%%%%%%%%%% Open the datafile
dfsubtract=1;
todaysdate=date;
fidout1=sprintf(('%s/%s.txt'), directoryname,todaysdate);
fidout=fopen(fidout1, 'a');% **  function
% [ThresholdDone]=ThresholdSequences(filename);

% loads red shirt data file and outputs treshhold graphs, e-phsytraces,
% jpeg images, as well as a .mat file containing the e-phys trace and each
% threshold point time series


%                    >>> INPUT VARIABLES >>>
%
% NAME        TYPE, DEFAULT      DESCRIPTION
% filename          char array         redshirt data file name
% 
%
%                    <<< OUTPUT VARIABLES <<<
%
% NAME        TYPE            DESCRIPTION
% ThresholdDone      double            1= succesfully processed data
% 
% 

%%%%%%%%%%%%%%% Open the datafile




load (fullfilename);

dfsubtract=1;
todaysdate=date;
fidout1=sprintf(('%s/%s_Hiro.txt'), directoryname,todaysdate);
fidout=fopen(fidout1, 'a');

FrameInterval=1;
ShutterOpenValues=1;
ShutterCloseValues=size (dataout,2);
ClippedParameters=1;
ClippedParameters=[ClippedParameters ; ShutterCloseValues(1)-ShutterOpenValues(1)];


IgnoreFirstXFrames=50/FrameInterval;

for thresholdcycle=1:(size(dataout,1)-2)
clear hold;
temp=dataout(thresholdcycle+2,:);
[maxpixels, maxframe]=max(temp);
    
    if maxframe<200
       
        baselinepixels=0;
        pixelchange=0;
        
    else    
        baselinepixels=mean(temp(1:250/FrameInterval));
        pixelchange=maxpixels-baselinepixels; 
    end
        
   
if thresholdcycle==1
    BaselinePixels=baselinepixels;
    PixelChange=pixelchange;
    hold=pixelchange/baselinepixels;
    activatedratio=hold;
else
    hold=pixelchange/baselinepixels;
    BaselinePixels=[BaselinePixels; baselinepixels];
    PixelChange=[PixelChange;pixelchange];
    activatedratio=[activatedratio; hold];
    
end
   
    
end
 




% Create Output Text File
for ThresholdCycle=1:(size(dataout,1)-2)
    outstring=sprintf(('%s\t%f\t%f\t%f\t%f\n\r'), fullfilename, ThresholdCycle, BaselinePixels(ThresholdCycle), PixelChange(ThresholdCycle),activatedratio(ThresholdCycle));
    outcout=fwrite(fidout, outstring);
end

status = fclose(fidout);
ThresholdDone=1;


end













