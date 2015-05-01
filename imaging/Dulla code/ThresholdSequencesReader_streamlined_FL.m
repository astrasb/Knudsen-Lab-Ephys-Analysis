%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This code opens all Redshirt Files within a selected folder, and creates
%  ratioed, normalized images of every frame from every file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
tracker=0;
ROI_ON=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Create File List    %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opening top most directory
directoryname = uigetdir('/mnt/m022a');                                 %%%% Opens files from my shared drive
%directoryname = uigetdir('/mnt/newhome/mirror/home/c;/hris/MATLAB/');    %%%%% Opens files from MATLAB directory

path1dir=sprintf('%s/',directoryname);
ddir = dir (path1dir);
numfilesdir=length(ddir)-2;
if numfilesdir<1
    disp('No files found');
end

for i = 1:numfilesdir
    t = length(getfield(ddir,{i+2},'name')) ;
    dddir(i, 1:t) = getfield(ddir,{i+2},'name') ;
end

% Opening each day's folder
for number_of_directories=1:numfilesdir
    subdirectoryname=sprintf('%s/%s',directoryname,ddir(number_of_directories+2,:).name);
    path1slice=sprintf('%s/%s',directoryname,ddir(number_of_directories+2,:).name);
    dslice = dir (path1slice);
    numfilesslice=length(dslice)-2;
    if numfilesslice<1
        disp('No files found');
    end
    
    for i = 1:numfilesslice
        t = length(getfield(dslice,{i+2},'name')) ;
        ddslice(i, 1:t) = getfield(dslice,{i+2},'name') ;
    end
    clear dadir;
    
    for number_of_slices=1:numfilesslice
        
        slicesubdirectoryname=sprintf('%s/%s/%s',directoryname,dddir(number_of_directories,:),ddslice(number_of_slices,:));
        path1dafile=sprintf('%s/%s/*.da*',subdirectoryname,ddslice(number_of_slices,:));
        dadir = dir (path1dafile);
        numfiles=length(dadir);
        if numfiles<1
            disp('No files found');
        end
        clear daddir;
        clear dd2;
        clear d2;
        clear dd212;
        clear dd21;
        for i = 1:numfiles
            t = length(getfield(dadir,{i},'name')) ;
            daddir(i, 1:t) = getfield(dadir,{i},'name') ;
        end
        %%%  Look for a Parameter file
        path2=sprintf('%s/%s/*param*',subdirectoryname,ddslice(number_of_slices,:));
        d2 = dir (path2);
        numfiles2=length(d2);
        if numfiles2<1
            disp('No files found');
            paramfound=0;
        else
            paramfound=1;
        end
        
        if paramfound==1
            clear dd2;
            for i = 1:numfiles2
                t = length(getfield(d2,{i},'name')) ;
                dd2(i, 1:t) = getfield(d2,{i},'name') ;
            end
            params_in=open(sprintf('%s/%s',slicesubdirectoryname,dd2));
            Outside_Mask=params_in.params.mask;
            Rot=params_in.params.rot;
            stim_loc_data=params_in.params.stim_loc;
        end
        
        
        %%%  Look for a Stim_FL Parameter file
        path21=sprintf('%s/%s/*FL_stim_loc*',subdirectoryname,ddslice(number_of_slices,:));
        d21 = dir (path21);
        numfiles21=length(d21);
        if numfiles21<1
            disp('No files found');
            paramfound1=0;
        else
            paramfound1=1;
        end
        
        if paramfound1==1
            
            for i = 1:numfiles21
                t = length(getfield(d21,{i},'name')) ;
                dd21(i, 1:t) = getfield(d21,{i},'name') ;
            end
            params_in1=open(sprintf('%s/%s',slicesubdirectoryname,dd21));
            stim_loc_data=params_in1.geometery.stim;
            FL_loc_data=params_in1.geometery.freeze;
        end
        
          %%%  Look for a Mask file
        path212=sprintf('%s/%s/*MZ_mask*',subdirectoryname,ddslice(number_of_slices,:));
        d212 = dir (path212);
        numfiles212=length(d212);
        if numfiles212<1
            disp('No files found');
            paramfound12=0;
        else
            paramfound12=1;
        end
        
        if paramfound12==1
            
            for i = 1:numfiles212
                t = length(getfield(d212,{i},'name')) ;
                dd212(i, 1:t) = getfield(d212,{i},'name') ;
            end
            params_in12=open(sprintf('%s/%s',slicesubdirectoryname,dd212));
            MZ=params_in12.masks.MZ;
  
        end
        
        
        
        
        %%%%%%%%%%%%%%%% Sets Constants
        MS_of_Data_to_Discard_Start=250;                    % Amount of time to be excluded from analysis - Front End
        MS_of_Data_to_Discard_End=3000;                      % Amount of time to be excluded from analysis - Front End
        Offsetfactor=250;                                  % Adjusts the color scaling
        MSforNormBaselineEnd=250;                          % Amount of time to use for Normalizing Purposes
        MSforNormBaselineStart=50;                         % Amount of time to use for Normalizing Purposes
        NumberofThresholds=5;                              % Number of threshold points for threshold analysis
        GaussianValue=0.5;                                 % Value of Gaussian blur parameter
        MatrixSize=3;                                      % Value of Gaussian blur parameter
        Erosion_Factor=1;                                  % Size of Erosion Structure used
        Masking_Factor=4;                                 % Masking Adjustment parameter - bigger number = more points farther from the mean will be included in the mask
        Max_Time_Cutoff=5;                                 % Size of each time bin in ms for timing analysis
        IterationNumber=200;                               % Number of time bins for timing analysis
        %StimTime=500;                                      % Time of Stimulation in ms10
        dfsubtract=1;                                      % Variable indication that dark frame subtraction is ON
        clip=2;                                            % Number of pixels to clip off the mask
        %2008_02_08_slice#1 clip=5
        FramesBlurred=5;
        NormalizationImageBlur=50;                         % ms of data to blur for start and end frames of sliding normalization
        Starting_Fret_Ratio_for_Thresholds=1.8;
        Clip_Bottom_Extra=3;
        camerafileextension='.da';
        Additional_Points=[1,1]
        
        
        if size(Additional_Points,2)>1
            Additional_Mask_Points=size(Additional_Points,2)/2;
        else
            Additional_Mask_Points=0;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      %%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      THIS IS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      THE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      MAIN
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      PART OF
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      THE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      CODE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% Start analyzing files %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Mask_Counter=0;
        
        tracker=tracker+1;
        if tracker==12
            pause=1;
        end
        
        
        for thisfile =1:5%numfiles % changed to only open the first file in each folder TEMPORARY    %%%%%  Controls which files are being analyzed
            
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%% Opens each RedShirt File %%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            filename=daddir(thisfile,:)
            clear fullfilename;
            fullfilename=sprintf('%s/%s',slicesubdirectoryname,filename);
            [Images, FrameTimes,TraceData, FrameInterval ]=RedShirtOpenSequences_streamlined(fullfilename);
            
            %%% Clip Start and Finish of file
            
            Image_c=Images(:,:,MS_of_Data_to_Discard_Start/FrameInterval:size(Images,3)-MS_of_Data_to_Discard_End/FrameInterval);
            clear Images;
            Images=Image_c;
            clear Image_c;
            
            Trace_c=TraceData(:,MS_of_Data_to_Discard_Start/FrameInterval:size(TraceData,2)-MS_of_Data_to_Discard_End/FrameInterval);
            clear TraceData;
            TraceData=Trace_c;
            clear Trace_c;
            
            FT_c=FrameTimes(1,MS_of_Data_to_Discard_Start/FrameInterval:size(FrameTimes,2)-MS_of_Data_to_Discard_End/FrameInterval);
            clear FrameTimes;
            FrameTimes=FT_c;
            clear FT_c;
            
            
            %%% Draw Mask of the Slice
            if paramfound~=1
                if thisfile==1
                    testimage=Images(1:40,:,500);
                    image(testimage,'CDataMapping','scaled');
                    Inside_Mask=roipoly;
                    Outside_Mask=find(Inside_Mask==0);
                end
                opposite_mask=Outside_Mask;
            else
                maskfill=zeros(size(Images,1)/2,size(Images,2));
                maskfill(Outside_Mask)=1;
                Inside_Mask=find(maskfill==0);
                opposite_mask=Outside_Mask;
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% Finding the stimulation time %%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            d_stim=diff(TraceData(1,:));
            stimframeplus=find(d_stim>0.2);
            stimframeminus=find(d_stim<-0.2);
            t=size(stimframeminus,2);
            tt=size(stimframeplus,2);
            if (tt>0)&&(t>0)
                
                if stimframeplus(1)>stimframeminus(1)
                    stimframe=stimframeminus(1);
                else
                    stimframe=stimframeplus(1);
                end
            else
                
                if 2<5 %%^ Contralateral conditinoal
                if number_of_directories<=5  % Fl and sham
                    stimframe=370;
                else
                    stimframe=870; %% For slices on 1/28/09
                end
                
                else
                    stimframe=870;
                end
            end
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%% Creates the RGB and RGB Inverted Color table %%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [RGBCustomInverted]=CreateRGBColorTableInverted;
            [RGBCustom]=CreateRGBColorTable;
            disp ('ColorMap Created');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Goes through individual exposures and %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% performs all analysis         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Takes the Ratio of CH1 and CH2 %%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ch1=Images(1:(size(Images,1)/2),:,:);
            ch2=Images((size(Images,1)/2)+1:size(Images,1),:,:);
            
            
            %Curve Fitting
            ch1tofit=squeeze(mean(mean(ch1)));
            ch2tofit=squeeze(mean(mean(ch2)));
            
            %%%% Plotting the means of Ch1 and Ch2 for Curve fitting
            subplot(2,1,1)
            plot(ch1tofit)
            subplot(2,1,2)
            plot(ch2tofit)
            if number_of_directories<=5
                x_cutoff=200;
                x_restart=1000;
            else
                x_cutoff=450;
                x_restart=2000;
            end
            
            
            
            
            if 2<1
                if thisfile==1
                    prompt = {'Enter the last x-value pre-glutamate application to use for curve fitting                 '};
                    dlg_title = 'Adjust Registration              ';
                    num_lines = 1;
                    def = {num2str(x_cutoff)};
                    answer = inputdlg(prompt,dlg_title,num_lines,def);
                    x_cutoff=str2num(answer{1,1});
                end
                
                
                if thisfile==1
                    prompt = {'Enter the first x-value post-glutamte application to use for curve fitting                 '};
                    dlg_title = 'Adjust Registration              ';
                    num_lines = 1;
                    def = {num2str(x_restart)};
                    answer = inputdlg(prompt,dlg_title,num_lines,def);
                    x_restart=str2num(answer{1,1});
                end
            end
            fit_ch1=ch1tofit(1:x_cutoff);
            fit_ch2=ch2tofit(1:x_cutoff);
            fit_ch1=[fit_ch1;ch1tofit(x_restart:size(ch1,3))];
            fit_ch2=[fit_ch2;ch2tofit(x_restart:size(ch1,3))];
            close
            
            for hh=1:size(ch1,3)
                time(hh)=hh;
            end
            fit_time=[time(1:x_cutoff),time(x_restart:size(ch1,3))];
            if x_restart==size(ch1,2)
                fit_ch1=fit_ch1(1:size(fit_ch1,2)-1);
                fit_ch2=fit_ch2(1:size(fit_ch2,2)-1);
                fit_time=fit_time(1:size(fit_ch1,2));
            end
            fit_ch1=double(fit_ch1);
            fit_ch2=double(fit_ch2);
            fit_time=fit_time';
            
            %%%% Fitting Ch1 and Ch2 independently
            % --- Create fit "fit 1"
            fo_ = fitoptions('method','NonlinearLeastSquares');%,'Robust','On','Algorithm','Levenberg-Marquardt');
            ok_ = isfinite(fit_time) & isfinite(fit_ch1);
            if ~all( ok_ )
                warning( 'GenerateMFile:IgnoringNansAndInfs', ...
                    'Ignoring NaNs and Infs in data' );
            end
            st_ = [12.157435039177022063 -0.047832406644661290551 1080.5679694878069768 -0.0011811405752495413718 ];
            set(fo_,'Startpoint',st_);
            ft_ = fittype('exp2');
            
            % Fit this model using new data
            cf_ = fit(fit_time(ok_),fit_ch1(ok_),ft_,fo_);
            
            % Or use coefficients from the original fit:
            if 0
                cv_ = { 52.697750977965384322, -0.57107350967034153921, 1082.9534326239570419, -0.0012917054854730896599};
                cf_ = cfit(ft_,cv_{:});
            end
            
            
            % --- Create fit "fit 2"
            fo2_ = fitoptions('method','NonlinearLeastSquares');%,'Robust','On','Algorithm','Levenberg-Marquardt');
            ok2_ = isfinite(fit_time) & isfinite(fit_ch2);
            if ~all( ok2_ )
                warning( 'GenerateMFile:IgnoringNansAndInfs', ...
                    'Ignoring NaNs and Infs in data' );
            end
            st2_ = [12.157435039177022063 -0.047832406644661290551 1080.5679694878069768 -0.0011811405752495413718 ];
            set(fo2_,'Startpoint',st2_);
            ft2_ = fittype('exp2');
            
            % Fit this model using new data
            cf2_ = fit(fit_time(ok2_),fit_ch2(ok2_),ft2_,fo2_);
            
            % Or use coefficients from the original fit:
            if 0
                cv2_ = { 52.697750977965384322, -0.57107350967034153921, 1082.9534326239570419, -0.0012917054854730896599};
                cf2_ = cfit(ft2_,cv2_{:});
            end
            
            %%%%%%%%%%%  Curve fit subtraction
            coeffvalues1=coeffvalues(cf_);
            coeffvalues2=coeffvalues(cf2_);
            for hh=1:size(ch1,3)
                Ch1_fit_results(hh)=coeffvalues1(1)*exp(coeffvalues1(2)*hh)+coeffvalues1(3)*exp(coeffvalues1(4)*hh);
                Ch2_fit_results(hh)=coeffvalues2(1)*exp(coeffvalues2(2)*hh)+coeffvalues2(3)*exp(coeffvalues2(4)*hh);
            end
            
            ch1sub=ch1tofit-Ch1_fit_results';
            ch2sub=ch2tofit-Ch2_fit_results';
            ch1sub=ch1sub+ch1tofit(1,1);
            ch2sub=ch2sub+ch2tofit(1,1);
            ratiosub=ch1sub./ch2sub;
            
            ch1start=ch1(:,:,1);
            ch2start=ch2(:,:,1);
            
            ch1end=ch1(:,:,size(ch1,3));
            ch2end=ch2(:,:,size(ch2,3));
            
            
            %%% Subtractive normalization based on curve fit
            ch1fitmax=max(Ch1_fit_results);
            ch2fitmax=max(Ch2_fit_results);
            ch1fitmin=min(Ch1_fit_results);
            ch2fitmin=min(Ch2_fit_results);
            ch1diff=ch1fitmax-ch1fitmin;
            ch2diff=ch2fitmax-ch2fitmin;
            Ch1_Normalized=zeros(size(ch1,1),size(ch1,2),size(ch1,3));
            Ch2_Normalized=zeros(size(ch1,1),size(ch1,2),size(ch1,3));
            for i=1:size(ch1,3)
                
                ThisFrame1=ch1(:,:,i);
                ThisFrame2=ch2(:,:,i);
                TimeRelativeToStart1=(Ch1_fit_results(i)-ch1fitmin)/ch1diff;
                TimeRelativeToStart2=(Ch2_fit_results(i)-ch2fitmin)/ch2diff;
                TimeRelativeToEnd1=1-TimeRelativeToStart1;
                TimeRelativeToEnd2=1-TimeRelativeToStart2;
                tempFrame1=ch1start*TimeRelativeToStart1+ch1end*TimeRelativeToEnd1;
                tempFrame2=ch2start*TimeRelativeToStart2+ch2end*TimeRelativeToEnd2;
                NormFrame1=ThisFrame1-tempFrame1+mean(mean(mean(ch1start(size(ch1,1)/4:3*size(ch1,1)/4,size(ch1,2)/8:7*size(ch1,2)/8))));
                NormFrame2=ThisFrame2-tempFrame2+mean(mean(mean(ch2start(size(ch1,1)/4:3*size(ch1,1)/4,size(ch1,2)/8:7*size(ch1,2)/8))));
                Ch1_Normalized(:,:,i)=NormFrame1;
                Ch2_Normalized(:,:,i)=NormFrame2;
            end
            Ratio=Ch1_Normalized./Ch2_Normalized;
            disp ('Ratio Completed');
            
            for maskframe=1:size(Ratio,3)
                tempframe=Ratio(:,:,maskframe);
                tempframe(Outside_Mask)=0;
                Ratio(:,:,maskframe)=tempframe;
            end
            
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Apply a Prefilter Mask = area outside of
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% the mask is filled with the average
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% intensity within the mask
            [Ratio]=Apply_Mask_PreFilter_streamlined(Ratio, Inside_Mask, Outside_Mask);
            %masks area outside of the slice mask with the average intensity inside the mask
            %
            %                    >>> INPUT VARIABLES >>>
            %
            % NAME                  TYPE, DEFAULT           DESCRIPTION
            % Images                                        Cell Array Containing the data
            % ThisExposure                                  Cell within the cell array to get the data from
            % Inside_Mask                                   Mask are area inside of the slice
            % Outside_Mask                                  Mask are area outside of the slice
            % DoesThisCellArrayObjectContainData            Flag for empty dataset
            %
            %                    <<< OUTPUT VARIABLES <<<
            %
            % NAME                 TYPE                    DESCRIPTION
            % CellArrayImages                              Cell Array Containing the filtered data
            %
            %
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%% Filter Images %%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            [Ratio]=Gaussian_Filter_streamlined(Ratio, MatrixSize, GaussianValue);
            [Ratio]=Gaussian_Filter_streamlined(Ratio, MatrixSize, GaussianValue);
            for maskframe=1:size(Ratio,3)
                tempframe=Ratio(:,:,maskframe);
                tempframe(Outside_Mask)=0;
                Ratio(:,:,maskframe)=tempframe;
            end
            
            
            
            %Applies a Gaussian filter to an image array
            %
            %                    >>> INPUT VARIABLES >>>
            %
            % NAME                  TYPE, DEFAULT           DESCRIPTION
            % CellArrayImages                               Cell Array Containing the data
            % Matrix Size                                   Size of the structure element used in filtering
            % exposure                                      Cell within the Cell Array to get data from
            % GaussianValue                                 Parameter of gaussian filter
            %
            %                    <<< OUTPUT VARIABLES <<<
            %
            % NAME                 TYPE                    DESCRIPTION
            % CellArrayImages                              Cell Array Containing the filtered data
            %
            %
            if ROI_ON==1
                image(Ratio(:,:,500),'cdatamapping','scaled')
                colormap
                thisroi=roipoly;
            
                for thisroiframe=1:size(Ratio,3)
                    roitempframe=(Ratio(:,:,thisroiframe));
                    roioutputfile(thisroiframe)=mean(roitempframe(thisroi));
                end
            end
                    
            disp ('Gaussian Filter Applied');
            if paramfound~=1
                if thisfile==1
                    RotAlign='No';
                    Rot=0;
                    this_image_file=ch1(:,:,500);
                    while (strcmp(RotAlign,'No')==1)
                        if (strcmp(RotAlign,'No')==1)
                            prompt = {'Enter the degrees of Rotation                 '};
                            dlg_title = 'Rotate Rotons             ';
                            num_lines = 1;
                            def = {num2str(Rot)};
                            answer = inputdlg(prompt,dlg_title,num_lines,def);
                            Rot=str2num(answer{1,1});
                            Peak_Rot_Tx=imrotate(this_image_file,Rot,'bilinear');
                            image(Peak_Rot_Tx,'cdatamapping','scaled')
                            colormap jet
                            axis image;
                            RotAlign=questdlg('Are you happy with the Rotational alignment','Registration Checkpoint');
                        end
                    end
                end
            end
            
                if thisfile==1
                    if paramfound1==0
                    labelimage=ch1(:,:,500);
                    rotated=imrotate(labelimage,Rot,'bilinear');
                    Happiness=questdlg('Label Stimulation site','GOULET INC');
                    image(rotated,'cdatamapping','scaled')
                    point=roipoly;
                    [stimrow, stimcol]=find(point==1);
                    stim_loc_data=[mean(stimrow),mean(stimcol)];
                    Happiness=questdlg('Label FL','GOULET INC');
                    point2=roipoly;
                    [FLrow, FLcol]=find(point2==1);
                    FL_loc_data=[mean(FLrow),mean(FLcol)];
                    end
                end
            
            
            rotated_profiling=imrotate(Ratio(:,:,stimframe-10:stimframe+49),Rot,'bilinear');
            blanktemp=FrameAverage(rotated_profiling,1,9);
            
            %%% Make mean baseline for column and layer profiling
            for i=1:size(blanktemp,2)
                blankvals=find(blanktemp(:,i)>0);
                if size(blankvals,1)>0
                    blank(i)=mean(blanktemp(blankvals,i));
                else
                    blank(i)=0;
                end
            end
            for i=1:size(blanktemp,1)
                blankvals=find(blanktemp(i,:)>0);
                if size(blankvals,2)>0
                    vertblank(i)=mean(blanktemp(i,blankvals));
                else
                    vertblank(i)=0;
                end
            end
            
            if thisfile==1
                profile=zeros(numfiles, 60,size(blank,2));
                profilevert=zeros(numfiles,60,size(vertblank,2));
                Column_skew_instant_write=zeros(numfiles, 60);
                Layer_skew_instant_write=zeros(numfiles, 60);
                Column_kurt_instant_write=zeros(numfiles, 60);
                Layer_kurt_instant_write=zeros(numfiles, 60);
                
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% THIS IS TURNED OFF TO DO FINAL ANALYSIS FOR PAPER 12_10_09
            %%%%%%%%%%%%%%%%%%%%%%%%%%% Treshhold analysis
            %% OFF MODE
            if 2<1
            avifilenameave=sprintf('%s/%s_timebinned.avi',slicesubdirectoryname,filename(1:size(filename,2)-3));
            FPS=15;  
            cmap=CreateRGBColorTable;
            for timewindows=1:60
                %%% Create baseline subtracted images
                [out_Images, Subtracted_Image]=Make_Composite_Image_RedShirt_Modifiable_non_cellarray(Ratio, TraceData, FrameTimes,FrameInterval,-100+((timewindows-1)*10),-100+((timewindows)*10),stimframe );
                
                % Mask and Filter the subtraced image
                temp3=Subtracted_Image;
                temp3(opposite_mask)=0;
                mask_size=size(find(Inside_Mask==1),1);
                H=fspecial('Gaussian', [2 2], 0.5);
                temp3=imfilter(temp3, H);
                temp5=-temp3;
                scalefactor=.12/256;
                temp5=temp5/scalefactor;
                baseline_lift=find(temp5<2);
                temp5(baseline_lift)=2.1;
                temp5(opposite_mask)=1;
                temp5=imrotate(temp5,Rot,'bilinear');
                h=figure;
                image(temp5,'cdatamapping','direct')
                colormap(cmap);
                F(timewindows)=getframe(h);
                close
                % Find Max FRET change
                FL_max=min(temp3(Inside_Mask));
                
                % Find Ave Max Fret Change, Skewness, Kurtosis for 4 different thresholds
                % of actice areas
                
                % threshold 1 = <0.01
                Active_Area_01=find(temp3(Inside_Mask)<-0.01);
                A_test=find(temp3<-0.01);
                % Skewness and Kurtosis
                if size(Active_Area_01,1)>1
                    kurt_image=temp3;
                    rotated=imrotate(kurt_image,Rot,'bilinear');
                    Active_Area=find( rotated<-0.01);
                    In_Active_Area=find( rotated>-0.01);
                    rotated(In_Active_Area)=0;
                    
                    
                    for i=1:size(rotated,2)
                        blankvals=find(blanktemp(:,i)>0);
                        if size(blankvals,1)>0
                            Column_skew_01(i)=mean(rotated(blankvals,i));
                        else
                            Column_skew_01(i)=0;
                        end
                    end
                    for i=1:size(rotated,1)
                        blankvals=find(blanktemp(i,:)>0);
                        if size(blankvals,2)>0
                            Layer_skew_01(i)=mean(rotated(i,blankvals));
                        else
                            Layer_skew_01(i)=0;
                        end
                    end
                    
                    Column_skew_01_out=Clip_Front_and_Back_Zeros_From_A_Line(Column_skew_01);
                    Layer_skew_01_out=Clip_Front_and_Back_Zeros_From_A_Line(Layer_skew_01);
                    Column_skew_01_write=skewness(Column_skew_01_out);
                    Layer_skew_01_write=skewness(Layer_skew_01_out);
                    Column_kurt_01_write=kurtosis(Column_skew_01_out);
                    Layer_kurt_01_write=kurtosis(Layer_skew_01_out);
                else
                    Column_skew_01_write=0;
                    Layer_skew_01_write=0;
                    Column_kurt_01_write=0;
                    Layer_kurt_01_write=0;
                end
                hist_peak=sort(temp3(A_test));
                if size(hist_peak,1)>25
                    mean_peak_01=squeeze(mean(hist_peak(1:25)));
                else
                    mean_peak_01=0;
                end
                
                % threshold 2<0.05
                Active_Area_05=find(temp3(Inside_Mask)<-0.05);
                % Skewness and Kurtosis
                if size(Active_Area_05,1)>1
                    kurt_image=temp3;
                    rotated=imrotate(kurt_image,Rot,'bilinear');
                    Active_Area=find( rotated<-0.05);
                    In_Active_Area=find( rotated>-0.05);
                    rotated(In_Active_Area)=0;
                    for i=1:size(rotated,2)
                        blankvals=find(blanktemp(:,i)>0);
                        if size(blankvals,1)>0
                            Column_skew_05(i)=mean(rotated(blankvals,i));
                        else
                            Column_skew_05(i)=0;
                        end
                    end
                    for i=1:size(rotated,1)
                        blankvals=find(blanktemp(i,:)>0);
                        if size(blankvals,2)>0
                            Layer_skew_05(i)=mean(rotated(i,blankvals));
                        else
                            Layer_skew_05(i)=0;
                        end
                    end
                    Column_skew_05_out=Clip_Front_and_Back_Zeros_From_A_Line(Column_skew_05);
                    Layer_skew_05_out=Clip_Front_and_Back_Zeros_From_A_Line(Layer_skew_05);
                    Column_skew_05_write=skewness(Column_skew_05_out);
                    Layer_skew_05_write=skewness(Layer_skew_05_out);
                    Column_kurt_05_write=kurtosis(Column_skew_05_out);
                    Layer_kurt_05_write=kurtosis(Layer_skew_05_out);
                else
                    Column_skew_05_write=0;
                    Layer_skew_05_write=0;
                    Column_kurt_05_write=0;
                    Layer_kurt_05_write=0;
                end
                
                % Ave Delta FRET
                A_test_5=find(temp3<-0.05);
                hist_peak_5=sort(temp3(A_test_5));
                if size(hist_peak_5,1)>25
                    mean_peak_05=squeeze(mean(hist_peak_5(1:25)));
                else
                    mean_peak_05=0;
                end
                
                % threshold 2<0.10
                Active_Area_10=find(temp3(Inside_Mask)<-0.10);
                if size(Active_Area_10,1)>1
                    kurt_image_2=temp3;
                    rotated=imrotate(kurt_image_2,Rot,'bilinear');
                    Active_Area=find( rotated<-0.10);
                    In_Active_Area=find( rotated>-0.10);
                    rotated(In_Active_Area)=0;
                    for i=1:size(rotated,2)
                        blankvals=find(blanktemp(:,i)>0);
                        if size(blankvals,1)>0
                            Column_skew_10(i)=mean(rotated(blankvals,i));
                        else
                            Column_skew_10(i)=0;
                        end
                    end
                    for i=1:size(rotated,1)
                        blankvals=find(blanktemp(i,:)>0);
                        if size(blankvals,2)>0
                            Layer_skew_10(i)=mean(rotated(i,blankvals));
                        else
                            Layer_skew_10(i)=0;
                        end
                    end
                    Column_skew_10_out=Clip_Front_and_Back_Zeros_From_A_Line(Column_skew_10);
                    Layer_skew_10_out=Clip_Front_and_Back_Zeros_From_A_Line(Layer_skew_10);
                    Column_skew_10_write=skewness(Column_skew_10_out);
                    Layer_skew_10_write=skewness(Layer_skew_10_out);
                    Column_kurt_10_write=kurtosis(Column_skew_10_out);
                    Layer_kurt_10_write=kurtosis(Layer_skew_10_out);
                else
                    Column_skew_10_write=0;
                    Layer_skew_10_write=0;
                    Column_kurt_10_write=0;
                    Layer_kurt_10_write=0;
                end
                
                
                A_test_10=find(temp3<-0.1);
                hist_peak_10=sort(temp3(A_test_10));
                if size(hist_peak_10,1)>25
                    mean_peak_10=squeeze(mean(hist_peak_10(1:25)));
                else
                    mean_peak_10=0;
                end
                
                % threshold 3<0.15
                Active_Area_15=find(temp3(Inside_Mask)<-0.15);
                if size(Active_Area_15,1)>1
                    kurt_image_15=temp3;
                    rotated=imrotate(kurt_image_15,Rot,'bilinear');
                    Active_Area=find( rotated<-0.15);
                    In_Active_Area=find( rotated>-0.15);
                    rotated(In_Active_Area)=0;
                    for i=1:size(rotated,2)
                        blankvals=find(blanktemp(:,i)>0);
                        if size(blankvals,1)>0
                            Column_skew_15(i)=mean(rotated(blankvals,i));
                        else
                            Column_skew_15(i)=0;
                        end
                    end
                    for i=1:size(rotated,1)
                        blankvals=find(blanktemp(i,:)>0);
                        if size(blankvals,2)>0
                            Layer_skew_15(i)=mean(rotated(i,blankvals));
                        else
                            Layer_skew_15(i)=0;
                        end
                    end
                    Column_skew_15_out=Clip_Front_and_Back_Zeros_From_A_Line(Column_skew_15);
                    Layer_skew_15_out=Clip_Front_and_Back_Zeros_From_A_Line(Layer_skew_15);
                    Column_skew_15_write=skewness(Column_skew_15_out);
                    Layer_skew_15_write=skewness(Layer_skew_15_out);
                    Column_kurt_15_write=kurtosis(Column_skew_15_out);
                    Layer_kurt_15_write=kurtosis(Layer_skew_15_out);
                else
                    Column_skew_15_write=0;
                    Layer_skew_15_write=0;
                    Column_kurt_15_write=0;
                    Layer_kurt_15_write=0;
                end
                
                
                A_test_15=find(temp3<-0.15);
                hist_peak_15=sort(temp3(A_test_15));
                if size(hist_peak_15,1)>25
                    mean_peak_15=squeeze(mean(hist_peak_15(1:25)));
                else
                    mean_peak_15=0;
                end
                
                AA1=size(Active_Area_01,1)/mask_size;
                AA5=size(Active_Area_05,1)/mask_size;
                AA10=size(Active_Area_10,1)/mask_size;
                AA15=size(Active_Area_15,1)/mask_size;
                Data_output(thisfile,1,(timewindows))=-100+((timewindows-1)*10);
                Data_output(thisfile,2,(timewindows))=FL_max;
                Data_output(thisfile,3,(timewindows))=mean_peak_01;
                Data_output(thisfile,4,(timewindows))=mean_peak_05;
                Data_output(thisfile,5,(timewindows))=mean_peak_10;
                Data_output(thisfile,6,(timewindows))=mean_peak_15;
                Data_output(thisfile,7,(timewindows))=AA1;
                Data_output(thisfile,8,(timewindows))=AA5;
                Data_output(thisfile,9,(timewindows))=AA10;
                Data_output(thisfile,10,(timewindows))=AA15;
                Data_output(thisfile,11,(timewindows))=Column_skew_01_write;
                Data_output(thisfile,12,(timewindows))=Layer_skew_01_write;
                Data_output(thisfile,13,(timewindows))=Column_kurt_01_write;
                Data_output(thisfile,14,(timewindows))=Layer_kurt_01_write;
                Data_output(thisfile,15,(timewindows))=Column_skew_05_write;
                Data_output(thisfile,16,(timewindows))=Layer_skew_05_write;
                Data_output(thisfile,17,(timewindows))=Column_kurt_05_write;
                Data_output(thisfile,18,(timewindows))=Layer_kurt_05_write;
                Data_output(thisfile,19,(timewindows))=Column_skew_10_write;
                Data_output(thisfile,20,(timewindows))=Layer_skew_10_write;
                Data_output(thisfile,21,(timewindows))=Column_kurt_10_write;
                Data_output(thisfile,22,(timewindows))=Layer_kurt_10_write;
                Data_output(thisfile,23,(timewindows))=Column_skew_15_write;
                Data_output(thisfile,24,(timewindows))=Layer_skew_15_write;
                Data_output(thisfile,25,(timewindows))=Column_kurt_15_write;
                Data_output(thisfile,26,(timewindows))=Layer_kurt_15_write;
            end
            
            
            
            
            
            
            
            movie2avi(F,avifilenameave, 'fps', FPS);
            for k=1:60
                thisimage=rotated_profiling(:,:,k);
                
                for i=1:size(thisimage,2)
                    blankvals=find(blanktemp(:,i)>0);
                    if size(blankvals,1)>0
                        line_prof(i)=mean(thisimage(blankvals,i));
                    else
                        line_prof(i)=0;
                    end
                end
                for i=1:size(thisimage,1)
                    blankvals=find(blanktemp(i,:)>0);
                    if size(blankvals,2)>0
                        vert_prof(i)=mean(thisimage(i,blankvals));
                    else
                        vert_prof(i)=0;
                    end
                end
                
                
                
                profile(thisfile,k,:)=line_prof-blank;
                profilevert(thisfile,k,:)=vert_prof-vertblank;
                pro=line_prof-blank;
                prov=vert_prof-vertblank;
                Column_skew_instant_out=Clip_Front_and_Back_Zeros_From_A_Line(pro);
                Layer_skew_instant_out=Clip_Front_and_Back_Zeros_From_A_Line(prov);
                [minval minloc]=min(pro);
                skew_window=pro(1,round(stim_loc_data(1,2)-20:round(stim_loc_data(1,2)+20)));
                Column_skew_instant_write_window(thisfile,k)=skewness(skew_window);
                Column_skew_instant_write_align(thisfile,k)=minloc-round(stim_loc_data(1,2));
                Column_skew_instant_write(thisfile,k)=skewness(Column_skew_instant_out);
                Layer_skew_instant_write(thisfile,k)=skewness(Layer_skew_instant_out);
                Column_kurt_instant_write(thisfile,k)=kurtosis(Column_skew_instant_out);
                Layer_kurt_instant_write(thisfile,k)=kurtosis(Layer_skew_instant_out);
            end
            end
            
            %%
            %%%% Non-binned time analysis
            [out_Images_summed, Subtracted_Image_summed]=Make_Composite_Image_RedShirt_Modifiable_non_cellarray(Ratio, TraceData, FrameTimes,FrameInterval,1,100,stimframe );
            Subtracted_Image_NTB_SUB=FrameAverage(Ratio,stimframe-50,stimframe-5);
            
            samples=Subtracted_Image_summed(Inside_Mask);
            roi_cutoff=mean(samples)-(std(samples));
            activated_roi=find(Subtracted_Image_summed<roi_cutoff);
            testimage_ROI=zeros(40,80);
            testimage_ROI(activated_roi)=1;            
            if thisfile==1
                if paramfound12==0
                image(Subtracted_Image_summed,'cdatamapping','scaled')
                Happiness=questdlg('Label MZ','GOULET INC');
                MZ=roipoly;
                end
                testimage=zeros(40,80);
                testimage(MZ)=2;
                test_combined=testimage_ROI+testimage;
                MZ_Active=find(test_combined==3);
                PMZ_Active=find(test_combined==1);                
                
            end
            
            for timepoints=1:1000
           testimage=zeros(40,80);
           NTB_Framed=Ratio(:,:,stimframe-250+timepoints)-Subtracted_Image_NTB_SUB;
           H=fspecial('Gaussian', [2 2], 0.5);
           unfiltered=NTB_Framed;
           if timepoints==300
               pause=1;
           end
           NTB_Framed=imfilter(NTB_Framed, H);
           NTB_Framed=imfilter(NTB_Framed, H);
           NTB_Framed=imfilter(NTB_Framed, H);
           testimage(activated_roi)=NTB_Framed(activated_roi);
           Activated_Area(thisfile,timepoints)=mean(NTB_Framed(activated_roi));
           Unfiltered(thisfile,timepoints)=mean(unfiltered(activated_roi));
           Activated_Area_MZ(thisfile,timepoints)=mean(NTB_Framed(MZ_Active));
           Activated_Area_PMZ(thisfile,timepoints)=mean(NTB_Framed(PMZ_Active));
           NTB_Activated_Area_05(thisfile,timepoints)=size(find(NTB_Framed<-0.05),1)/size(Inside_Mask,1);
           NTB_Activated_Area_10(thisfile,timepoints)=size(find(NTB_Framed<-0.1),1)/size(Inside_Mask,1);
           NTB_Activated_Area_05_subregion(thisfile,timepoints)=size(find(testimage<-0.05),1)/size(Inside_Mask,1);
           NTB_Activated_Area_10_subregion(thisfile,timepoints)=size(find(testimage<-0.1),1)/size(Inside_Mask,1);
           
            
            
            end
            pause=1;
            
        end
        params.mask=Outside_Mask;
        params.rot=Rot;
        params.stim_loc=stim_loc_data;
        masks.MZ=MZ;
        masks.MZ_Active=MZ_Active;
        masks.PMZ_Active=PMZ_Active;
        masks.Active=activated_roi;
        masks.ActiveImage=Subtracted_Image_summed;
        geometery.stim=stim_loc_data;
        geometery.freeze=FL_loc_data;
        
        NTB_ROI_DATA.Activated_Area=Activated_Area;
        NTB_ROI_DATA.Activated_Area_MZ=Activated_Area_MZ;
        NTB_ROI_DATA.Activated_Area_PMZ=Activated_Area_PMZ;
        NTB_ROI_DATA.NTB_Activated_Area_05=NTB_Activated_Area_05;
        NTB_ROI_DATA.NTB_Activated_Area_10=NTB_Activated_Area_10;
        NTB_ROI_DATA.NTB_Activated_Area_05_sub=NTB_Activated_Area_05_subregion;
        NTB_ROI_DATA.NTB_Activated_Area_10_sub=NTB_Activated_Area_10_subregion;
        NTB_ROI_DATA.NTB_Activated_allcortex=Activated_Area;
        if 2>1
        dataouput_filename1=sprintf('%s/%s_profilevert.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        dataouput_filename2=sprintf('%s/%s_profile',slicesubdirectoryname,filename(1:size(filename,2)-3));
        dataouput_filename3=sprintf('%s/%s_col_skew.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        dataouput_filename4=sprintf('%s/%s_lay_skew.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        dataouput_filename5=sprintf('%s/%s_col_kurt.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        dataouput_filename6=sprintf('%s/%s_lay_kurt.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        dataouput_filename7=sprintf('%s/%s_params.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        dataouput_filename8=sprintf('%s/%s_col_skew_window.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        dataouput_filename9=sprintf('%s/%s_col_skew_align.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        dataouput_filename10=sprintf('%s/%s_FL_stim_loc.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        end
        dataouput_filename11=sprintf('%s/%s_MZ_masks.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        dataouput_filename12=sprintf('%s/%s_NTB_ROI_DATA.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        if 2<1
        dataouput_filename=sprintf('%s/%s_streamlinedoutput.mat',slicesubdirectoryname,filename(1:size(filename,2)-3));
        save(dataouput_filename,'Data_output');
        end
        if 2<1
        save (dataouput_filename2, 'profile');
        save (dataouput_filename1, 'profilevert');
        save (dataouput_filename3, 'Column_skew_instant_write');
        save (dataouput_filename4, 'Layer_skew_instant_write');
        save (dataouput_filename5, 'Column_kurt_instant_write');
        save (dataouput_filename6, 'Layer_kurt_instant_write');
        save (dataouput_filename7, 'params');
        save (dataouput_filename8, 'Column_skew_instant_write_window');
        save (dataouput_filename9, 'Column_skew_instant_write_align');
        save (dataouput_filename10, 'geometery');
        end
        save (dataouput_filename11, 'masks');
        save (dataouput_filename12, 'NTB_ROI_DATA');
    end
end

  