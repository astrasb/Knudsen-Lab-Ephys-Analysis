%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Averaging Andor Movies
%%%% This code will perform the following secquence of functions
%%%%    -
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
VertAdjust=0;
HorizAdjust=0;
clipfactor=20;
ScaleFactor=9.5;
L_R_OffsetFactor=-360;
U_D_OffsetFactor=60;
%%  Open all SIF files in a directory as well as PCLAMP, Brightfield (ANDOR and COOKE), and
%%%  Darkfield fiels
directory = uigetdir('/mnt/m022a/')

fd=dir(directory);
numfiles=length(fd);
if numfiles<1
    disp('No files found');
end


for hh=1:numfiles
    
    clear dd;
    path1=sprintf('%s/*Image*',directory);
    d = dir (path1);
    numfiles_images=length(d);
    if numfiles_images<1
        disp('No files found');
    end
    
    for i = 1:numfiles_images
        t = length(getfield(d,{i},'name')) ;
        dd(i, 1:t) = getfield(d,{i},'name') ;
    end
    
    pathd=sprintf('%s/*dark*',directory);
    ddark = dir (pathd);
    numfiles=length(ddark);
    if numfiles<1
        disp('No files found');
    end
    
    for i = 1:numfiles
        t = length(getfield(ddark,{i},'name')) ;
        dddark(i, 1:t) = getfield(ddark,{i},'name') ;
    end
    pathb=sprintf('%s/*bright*',directory);
    dbright = dir (pathb);
    numfiles=length(dbright);
    if numfiles<1
        disp('No files found');
    end
    
    for i = 1:numfiles
        t = length(getfield(dbright,{i},'name')) ;
        ddbright(i, 1:t) = getfield(dbright,{i},'name') ;
    end
    
    pathc=sprintf('%s/*abf*',directory);
    dpclamp= dir (pathc);
    numfiles=length(dpclamp);
    if numfiles<1
        disp('No files found');
    end
    for i = 1:numfiles
        t = length(getfield(dpclamp,{i},'name')) ;
        ddpclamp(i, 1:t) = getfield(dpclamp,{i},'name') ;
    end
end
%% Read Brightfield and Darkfield Files
filenamedark=sprintf('%s/%s',directory,dddark(1,:));
[DarkImage,DarkInstaImage,DarkCalibImage,Darkvers]=andorread_chris_local_knownfilename(filenamedark);
brightfilename=sprintf('%s/%s',directory,ddbright(1,:));
[BrightImage,BrightInstaImage,BrightCalibImage,Brightvers]=andorread_chris_local_knownfilename(brightfilename);
brightandor=BrightImage.data;
brightandor=brightandor(1:size(brightandor,1)/2,:);
%%

%%% Process Files 1 by 1
for i=1:numfiles_images
%% Open File    
    filename=sprintf('%s/%s',directory,dd(i,:));
    [Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(filename);
    temp=Image.data;
    exposuretime=InstaImage.exposure_time;
    
    ch1=temp(1:size(temp,1)/2,:,:);
    ch2=temp(size(temp,1)/2+1:size(temp,1),:,:);
    
    liveave=squeeze(mean(mean(ch1(size(ch1,1)/4:3*size(ch1,1)/4,size(ch1,2)/4:3*size(ch1,2)/4,:))));
    dliveave=diff(liveave);
    
%%  Get Shutter Open and close frames
    [trash, illumination_start]=max(dliveave);
    [trash, illumination_end]=min(dliveave);
    illumination_start=illumination_start+clipfactor;
    illumination_end=illumination_end-clipfactor;
    
%% Clip Dark Frames from front and end of Fluorescence exposure
    darkframe=FrameAverage(DarkImage.data,1,size(DarkImage.data,3));
    Fluorescence_dark_clipped=(temp(:,:,illumination_start:illumination_end));
    
%%  Subtract Darkfield from Fluorescent images
    subframe=zeros(size(Fluorescence_dark_clipped,1),size(Fluorescence_dark_clipped,2),size(Fluorescence_dark_clipped,3));
    
    for ii=1:size(Fluorescence_dark_clipped, 3)
        tframe=Fluorescence_dark_clipped(:,:,ii);
        subframe(:,:,ii)=tframe-darkframe;
    end
    
%%  Split Channels
    Ch1=subframe(1:size(subframe,1)/2,:,:);
    Ch2=subframe(size(subframe,1)/2+1:size(subframe,1),:,:);
    
%%  Align Channels due to DualView misalignment
    [Ch1,Ch2,VertAdjust,HorizAdjust]=Align_Andor(Ch1, Ch2, i, hh, VertAdjust, HorizAdjust);
    
%%  Create the ratio
    ratio=Ch1./Ch2;
    
%%  Mask Image
    if i==1;
        normsingle=FrameAverage(ratio, 2,10);
        basenorm=mean(mean(normsingle));
        figure(3)
        image(ch1(:,:,100),'cdatamapping','scaled');
        mask=roipoly;
        inside=find(mask==1);
        outside=find(mask==0);
    end
    
    normframe=zeros(size(ratio,1),size(ratio,2),size(ratio,3));
    for gg=1:size(ratio, 3)
        tframe=ratio(:,:,gg);
        normframetemp=tframe-normsingle;
        normframetemp=normframetemp+basenorm;
        normframetemp(outside)=0;
        normframe(:,:,gg)=normframetemp;
    end
    
%% Get PCLAMP Data
    filenamepclamp=sprintf('%s/%s',directory,ddpclamp(1,:));
    [d,si,sw,tags,et,cn,timestamp]=abfload(filenamepclamp);
    numsweeps=0;
    hz=1/(si*1e-6);
    numsweeps=0;
    
%% Pick the PCLAMP sweep that corresponds to this image
    prompt=sprintf('Which Sweep Corresponds to file %s',filename);
    dlg_title = 'Pick the Sweep';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);
    sweep_number=str2num(answer{1});
    e_trace=d(:,1,sweep_number);
    camera_trigger=d(:,2,sweep_number);
    
%% Compute E_phystime
    
    for df=1:size(d,1)
        e_time(df)=si*df/1000000;
    end
%%  Calculate Frame Times

    trigger=diff(camera_trigger);
    triggertimes_locs=find(trigger>0.5);
    skipped=0;
    
   %%% Compute times off of standard exp+delay time
    for isd=1:Image.no_images
        estimated_time(isd)=(isd-1)*InstaImage.kinetic_cycle_time+triggertimes_locs(1,1)/10000;
    end
    
  %%%%  Get time locations
    
    for qqq=1:Image.no_images
        thistimeloc=find(e_time>estimated_time(qqq));
        image_locations(qqq)=thistimeloc(1,1);
        
    end

    %% Clip E-phys data to shutter open and close
    e_trace_clipped=e_trace(image_locations(illumination_start):image_locations(illumination_end));
    e_time_clipped=e_time(image_locations(illumination_start):image_locations(illumination_end));
    image_locations_clipped=image_locations(illumination_start:illumination_end);
    image_locations_clipped=image_locations_clipped-image_locations(1,illumination_start)+1;
    %% Filtering - Currently Inactive
    
    if 2<1
        
        %this codes finds camera busy signals and creates subsampled pclamp data
        % traces based on the timing of these signals
        
        
        %MATLAB code to bandpass filter a data trace
        %%These two next variables will need to be played with to optimize the result
        % datasamples is a vector of points sampled at si intervals.
        
        lowpassfilter=1000; % this should cut down the fuzziness in the signal
        highpassfilter=1; %this should get rid of the slow drift
        filtering=1;
        
        % si is the sample interval in seconds.� Set up the filter params once at the beginning of the run
        if filtering>0
            [blpf,alpf]=butter(2,lowpassfilter/(hz/2),'low');
            [bhpf,ahpf]=butter(2,highpassfilter/(hz/2),'high');
        end
        
        %obtain date into data samples for each sweep.� You don't need to recalculate filter params each time
        if filtering>0
            % band pass filter, in two steps, first lp then high pass
            datasamples=filter(blpf,alpf,e_trace);
            datasamples=filter(bhpf,ahpf,datasamples);
        end
        
    end
    
    
    
    
    
    
%% Alternative Timing Routine - INACTIVE
     if 2<1
    %%% Detect camera busy signals and match the treshold to the number
    %%% of images
    frame_number=size(temp,3);
    trigger=diff(camera_trigger);
    correct_frames='No';
    
    while (strcmp(correct_frames,'No')==1)
        counter=0;
        for scanning=1:600
            cutoff=scanning*0.01;
            edge_locations=find(trigger>cutoff);
            
            for skip_check=1:(size(edge_locations,1)-1)
                if edge_locations(skip_check)==edge_locations(skip_check+1)-1;
                    counter=counter+1;
                    for skip_replace=1:(size(edge_locations)-1-counter)
                        if skip_replace<skip_check
                            edge_out(skip_replace)=edge_locations(skip_replace);
                        end
                        if skip_replace>skip_check
                            edge_out(skip_replace-1)=edge_locations(skip_replace);
                        end
                    end
                    edge_location=edge_out;
                end
                
            end
            
            if size(edge_locations,1)==frame_number
                correct_frames='Yes';
                test_locations=edge_locations;
            else
                clear edge_locations;
            end
        end
    end
  end
    
    %% Subsampling Data
    %%% Subsample e_phys at same frequency as imaging
    for idd=1:size(image_locations_clipped,2)-1
        e_trace_subsampled(idd)=e_trace_clipped(image_locations_clipped(idd));
        time_subsampled(idd)=e_time_clipped(image_locations_clipped(idd));
    
    end
    
    %%% Subsample e_phys at 10X frequency as imaging
    suprasample=10;
    for h=1:size(image_locations_clipped,2)-1
        for hk=1:suprasample
            holder=image_locations_clipped(h)+hk;
            e_trace_subsampled_supra((h-1)*suprasample+hk)=e_trace_clipped(holder);
            time_subsampled_supra((h-1)*suprasample+hk)=e_time_clipped(holder);
            
        end
    end
    
    %%% Detect Stim time from ephys
    d_stim=diff(e_trace_clipped);
    stimframeplus=find(d_stim>0.1);
    stimframeminus=find(d_stim<-0.1);
    if stimframeplus(1)>stimframeminus(1)
        stimframe=stimframeminus(1);
    else
        stimframe=stimframeplus(1);
    end
    stimframe=find(image_locations_clipped>stimframe);
    stimframe=stimframe(1);
    
    
    %% Create and fill composite movie file
    if i==1
        composite_movie=zeros(numfiles_images,size(normframe,1),size(normframe,2),(stimframe+100)-(stimframe-50));
    end
    
    composite_movie(i,:,:,:)=normframe(:,:,stimframe-50:stimframe+99);
end

%%  Average movies and generate output MAT file tagged with stim location
%%% Baseline Subtract each image
for this_base=1:size(composite_movie,1)
   base_out(this_base,:,:)=FrameAverage(squeeze(composite_movie(this_base,:,:,:)),45,50);
   eachframe=1;
   for eachframe=1:size(composite_movie,4)
       composite_movie_adj(this_base,:,:,eachframe)=composite_movie(this_base,:,:,eachframe)-base_out(this_base,:,:);
   end
end

%%% Create Average Movie
ave_movie=squeeze(mean(composite_movie_adj));

%%% Integrate 200 ms of data
summed_movie=zeros(size(ave_movie,1),size(ave_movie,2));
for tt=50:150
    tempframe=ave_movie(:,:,tt);
    summed_movie=summed_movie+tempframe;
end

%%% Format the output image
summedsub=summed_movie-max(max(summed_movie));
edge=find(summedsub==-max(max(summed_movie)));
summedsub(edge)=mean(mean(summedsub(15:20,15:20)));
fillin=find(summedsub<-20);
summedsub(fillin)=mean(mean(summedsub(15:20,15:20)));
summedsub=-summedsub;

%%% Auto Detect the Hot Spot
test_mean=(mean(mean(summedsub)));
test_std=std(mean(summedsub));
hot_zone=find(summedsub>test_mean);
Erosion_Factor=2;
[Inside_Mask, Outside_Mask]=Erode_Mask_non_cellarray(summedsub, 1, hot_zone, Erosion_Factor,1, 1, 0, 0);

%%% Create Time Series using the hotspot ROI
for thismovie=1:size(composite_movie,1)
    for this_frame=1:size(composite_movie,4)
        temp_frame_holder=squeeze(composite_movie(thismovie,:,:,this_frame));
        ave_trace(thismovie,this_frame)=(mean(temp_frame_holder(Inside_Mask)));
    end
end

%%%  Draw an image and label the site of the stimulator
image(summedsub,'cdatamapping','scaled')
point=roipoly;
[stimrow, stimcol]=find(point==1);
stim_loc_data=[mean(stimrow),mean(stimcol)];
summedfile=sprintf('%s/%s_summed_sub.mat',directory,directory(12:21));
save (summedfile,'summedsub');
stim_loc_file=sprintf('%s/%s_stim_location.mat',directory,directory(12:21));
save (stim_loc_file,'stim_loc_data');
roi_trace_file=sprintf('%s/%s_ROI_Trace.mat',directory,directory(12:21));
save (roi_trace_file,'ave_trace');
%% Trial Rescaling and Alignment to get paramaeters
Happiness='No';
while (strcmp(Happiness,'No')==1)
    
    [andorscaled, cookscaled, L_R_OffsetFactor, U_D_OffsetFactor]=registration_test_calcium(summedsub, directory, ScaleFactor, L_R_OffsetFactor, U_D_OffsetFactor) ;
    
    
    Happiness=questdlg('Are you happy with the alignment','Registration Checkpoint');
    if (strcmp(Happiness,'No')==1)
        prompt = {'Enter Scale Factor                 ','Enter Left/Right Factor                  ','Enter Up/Down Factor                  '};
        dlg_title = 'Adjust Registration              ';
        num_lines = 1;
        def = {num2str(ScaleFactor),num2str(L_R_OffsetFactor),num2str(U_D_OffsetFactor)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        ScaleFactor=str2num(answer{1,1});
        L_R_OffsetFactor=str2num(answer{2,1});
        U_D_OffsetFactor=str2num(answer{3,1});
        
    end
    
end


scalematrix=[ScaleFactor 0 0
    0 ScaleFactor 0
    0 0 1];

txmatrix=[1 0 0
    0 1 0
    L_R_OffsetFactor U_D_OffsetFactor 1];
scform=maketform('affine',scalematrix);
txform=maketform('affine',txmatrix);

andorscaled=imresize(summedsub, ScaleFactor);
andorscaled=imtransform(andorscaled, txform, 'Xdata',[1 (size(andorscaled,2)+txmatrix(3,1))],'Ydata', [1 (size(andorscaled,1)+txmatrix(3,2))],'FillValues', 0);
imageROIave=mean(mean(andorscaled(size(andorscaled,1)/3:2*size(andorscaled,1)/3,size(andorscaled,2)/3:2*size(andorscaled,2)/3)));

cookhist=reshape(cookscaled,1,[]);
cook_sd=std(cookhist);
cook_mean=mean(cookhist);

cookhist=reshape(cookscaled,1,[]);
cook_sd=std(cookhist);
cook_mean=mean(cookhist);

cookmax=cook_mean+2*cook_sd;
cookscaled_128=cookscaled*128/cookmax;
cook_saturated=find(cookscaled_128>128);
cookscaled_128(cook_saturated)=128;

andormin=imageROIave-3;%3.8;
andormax=imageROIave+3;%4.8;
x_adjust=size(cookscaled_128,2)-size(andorscaled,2);
if x_adjust>0
    x_pad=zeros(size(andorscaled,1),x_adjust,size(andorscaled,3));
    andor_adj_padded=[andorscaled x_pad];
else
    x_adjust=-x_adjust;
    x_pad=zeros(size(cookscaled_128,1),x_adjust);
    cookscaled_128=[cookscaled_128 x_pad];
    andor_adj_padded=andorscaled;
end

y_adjust=size(cookscaled_128,1)-size(andor_adj_padded,1);
y_pad=zeros(y_adjust, size(cookscaled_128,2),size(andor_adj_padded,3));
andor_adj_padded=[andor_adj_padded; y_pad];

andorscaled_out=((andor_adj_padded-andormin)*128/(andormax-andormin))+128;

threshold=find(andorscaled_out>180);


combined=zeros(size(andor_adj_padded));

for i=1:size(combined,3)
    combined(:,:,i)=cookscaled_128;
end

combined(threshold)=andorscaled_out(threshold);
[BW_RGBCustom]=CreateBW_RGBColorTable_inverted;
image(combined,'cdatamapping','direct')
colormap(BW_RGBCustom)
box off
axis off
tiffilename=sprintf('%s/Composite_compiled.tif',directory);

saveas(gcf,tiffilename)