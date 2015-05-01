function [AveStartImages, AveEndImages]=CreateNormImages(ExposureNumber, CellArrayObject, FramesBlurred, FrameInterval);

% [AveStartImages, AveEndImages]=CreateNormImages(ExposureNumber, CellArrayObject, FramesBlurred, FrameInterval, exposure);
%
% Creates the normalized images used for the sliding normalization
%
%                    >>> INPUT VARIABLES >>>
%
% NAME                  TYPE, DEFAULT           DESCRIPTION
% ExposureNumber                                Cell within the cell array to use                               
% CellArrayObject                               Cell Array Containing the data
% FramesBlurred                                 ms of data to blur for each image
% FrameInterval                                 Time between samples
%
%
%                    <<< OUTPUT VARIABLES <<<
%
% NAME                 TYPE                    DESCRIPTION
% AveStartImages                               Single image of the first FramesBlurred ms of data averaged
% AveEndImages                                 Single image of the first FramesBlurred ms of data averaged
% 



    
    DoesThisCellArrayObjectContainData=1;                           %%%%%  Not IMPLEMENTED PROPERLY
    if DoesThisCellArrayObjectContainData>0
        
        %%%%%%%%%%%%%%%%%%%%  Grabs data and gets its properties
        
        tempStart=CellArrayObject{ExposureNumber};                        
        Frames=size(tempStart,3);
        Height=size(tempStart,2);
        Width=size(tempStart,1);
        
        %%%%%%%%%%%%% Start Frame Variable
        
        StartAveragedFrame=FrameAverage(tempStart, 1, FramesBlurred/FrameInterval);
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
       
        disp ('Start Frame Compiled');

        %%%%%%%%%%%%% End Frame Variable
        endstart=int16(Frames-FramesBlurred/FrameInterval);
        endstart=double(endstart);
        
        EndAveragedFrame=FrameAverage(tempStart, endstart, Frames);
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
        
            
        disp ('End Frame Compiled');

    else
        fprintf('Exposure %d Empty', ExposureNumber);
        fprintf('');
    end
    
    
    %%%%%%%%%% Construct the output CellArray
    if DoesThisCellArrayObjectContainData(ExposureNumber)>0       %%% NOT IMPLEMENTED
       
            AveStartImages = {StartAveragedFrame};
            AveEndImages = {EndAveragedFrame};
        
    else
        if ExposureNumber==1
            AveStartImages = {0};
            AveEndImages = {0};
        
    end
end

