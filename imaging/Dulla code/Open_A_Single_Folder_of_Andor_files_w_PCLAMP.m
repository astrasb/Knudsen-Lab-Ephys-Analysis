%%% Open a folder full of Andor Files
%%% Folder must include a PClamp File
%%% and all sif files must be the same binning, and image area (for masking
%%% purposes)

clear all
VertAdjust=0;
HorizAdjust=0;

%%%%%%%%%%%% Open Andor File
directoryname = uigetdir('/mnt/m022a');  % Open Top Level directory - each folder must contain a brightfield Tiff(Cooke), brightfield sif, PClamp file, and relevant sif files
searchparameter=sprintf('%s/*Untitled*.sif',directoryname);
this_folder_list = rdir(searchparameter); % Use dirr to create the directory sturcture variable
sifs=size(this_folder_list,1);
sweepstoday=[36 37 38 49 50 51 56 57 58 63 64 65 70 71 72];
for thissif=1:sifs
    if thissif==1
        parameters_present=0;
    else
        parameters_present=1;
    end
    fn=this_folder_list(thissif).name;
    [Image,InstaImage,CalibImage,vers]=andorread_chris_local_knownfilename(fn);
    temp=Image.data;
    exposuretime=InstaImage.exposure_time;
    
    %%%% Detect Shutter Opening and Closing
    shutter_scan=squeeze(mean(mean(temp)));
    shutter_deriv=diff(shutter_scan);
    [waste, shutter_open_frame]=max(shutter_deriv);
    [waste, shutter_close_frame]=min(shutter_deriv);
    dark=FrameAverage(temp,2,shutter_open_frame-2);
    
    %%%%%%%%%%  Darkfield subtraction
    for i=1:size(temp,3)
        tempframe=temp(:,:,i);
        tempframe=tempframe-dark;
        temp(:,:,i)=tempframe;
        
    end
    %%%%% Breaking up Ch1 and Ch2
    ch1=temp(1:size(temp,1)/2,:,shutter_open_frame+4:shutter_close_frame-3);
    ch2=temp(size(temp,1)/2+1:size(temp,1),:,shutter_open_frame+4:shutter_close_frame-3);
    ch1tofit=squeeze(mean(mean(ch1)));
    ch2tofit=squeeze(mean(mean(ch2)));
    Aligned='No';
    
    
    
    if thissif==1
    %%%% Plotting the means of Ch1 and Ch2 for Curve fitting
    subplot(2,1,1)
    plot(ch1tofit)
    subplot(2,1,2)
    plot(ch2tofit)
    
        x_cutoff=0;
        x_restart=100;
        prompt = {'Enter the last x-value pre-glutamate application to use for curve fitting                 '};
        dlg_title = 'Adjust Registration              ';
        num_lines = 1;
        def = {num2str(x_cutoff)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        x_cutoff=str2num(answer{1,1});
        
        prompt = {'Enter the first x-value post-glutamte application to use for curve fitting                 '};
        dlg_title = 'Adjust Registration              ';
        num_lines = 1;
        def = {num2str(x_restart)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        x_restart=str2num(answer{1,1});
    
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
    [coeffvalues1]=FourtDegreePolynomialFit(fit_time,fit_ch1)
    [coeffvalues2]=FourtDegreePolynomialFit(fit_time,fit_ch2)
    
    %%%%%%%%%%%  Curve fit subtraction
    
    for hh=1:size(ch1,3)
        Ch1_fit_results(hh)=coeffvalues1(1)*hh^3+coeffvalues1(2)*hh^2+coeffvalues1(3)*hh+coeffvalues1(4);
        Ch2_fit_results(hh)=coeffvalues2(1)*hh^3+coeffvalues2(2)*hh^2+coeffvalues2(3)*hh+coeffvalues2(4);
    end
    
    ch1sub=ch1tofit-Ch1_fit_results';
    ch2sub=ch2tofit-Ch2_fit_results';
    ch1sub=ch1sub+ch1tofit(1,1);
    ch2sub=ch2sub+ch2tofit(1,1);
    ratiosub=ch1sub./ch2sub;
    
    [Ch1_Normalized]=FrameNormalization_rising_signal(ch1, Ch1_fit_results);
    [Ch2_Normalized]=FrameNormalization_rising_signal(ch2, Ch2_fit_results);
    %[Ch1_Normalized]=FrameNormalization(ch1, Ch1_fit_results);
    %[Ch2_Normalized]=FrameNormalization(ch2, Ch2_fit_results);
    
    %%%%%%%%%%%%%%%%%%%%%%% Adjust alignment
   
    [ratio, ratio_raw,Aligned,VertAdjust,HorizAdjust]=realignDVimages(ch1, ch2, Ch1_Normalized, Ch2_Normalized,Aligned,parameters_present,VertAdjust,HorizAdjust);
   
       
    ext='abf';
    path1=sprintf('%s/*%s*',directoryname,ext);
    dddd = dir (path1);
    fn1= sprintf('%s/%s',directoryname, dddd.name);
    [d,si,sw,tags,et,cn,timestamp]=abfload(fn1);
    numsweeps=0;
    if 2>5
        prompt = {'Which Sweep Corresponds with this Image:'};
        dlg_title = 'Pick the Sweep';
        num_lines = 1;
        
        answer = inputdlg(prompt,dlg_title,num_lines);
        sweep_number=str2num(answer{1});
    else
        sweep_number=sweepstoday(1,thissif)
    end
    %this codes finds camera busy signals and creates subsampled pclamp data
    % traces based on the timing of these signals
    
    e_trace=d(:,1,sweep_number);
    camera_trigger=d(:,2,sweep_number);
    
    %%% Compute E_phystime
    
    for i=1:size(d,1)
        e_time(i)=si*i/1000000;
    end
    
    %%%  Compute times off camera trigger
    trigger=diff(camera_trigger);
    triggertimes_locs=find(trigger>1);
    for i=1:size(triggertimes_locs,1)
        triggertimes(i)=si*triggertimes_locs(i,1)/1000000;
    end
    
    
    
    %%% Compute times off of standard exp+delay time
    for i=1:Image.no_images
        estimated_time(i)=(i-1)*InstaImage.kinetic_cycle_time;
    end
    
    
    %%% Subsample e_phys at same frequency as imaging
    for i=1:size(triggertimes,2)-1
        e_trace_subsampled(i)=e_trace(triggertimes_locs(i));
    end
    
    %%% Subsample e_phys at 10X frequency as imaging
    suprasample=10;
    for i=1:size(triggertimes,2)
        for k=1:suprasample
            interval=InstaImage.kinetic_cycle_time*10000/suprasample;
            holder=round(triggertimes(1,i)*10000+interval*(k-1));
            e_trace_subsampled_supra((i-1)*suprasample+k)=e_trace(holder);
            time_subsampled_supra((i-1)*suprasample+k)=e_time(holder);
            
        end
    end
    
    
    e_trace_subsampled=e_trace_subsampled(:,shutter_open_frame+3:shutter_close_frame-3);
    time_subsampled=triggertimes(:,shutter_open_frame+3:shutter_close_frame-3);
    e_trace_subsampled_supra=e_trace_subsampled_supra(:,(shutter_open_frame+3)*suprasample:(shutter_close_frame-2)*suprasample-1);
    time_subsampled_supra=time_subsampled_supra(:,(shutter_open_frame+3)*suprasample:(shutter_close_frame-2)*suprasample-1);
    
    traceave=mean(e_trace_subsampled_supra);
    
   
    %%%%%  Mask the hippocampus in the ratioed image
    if thissif==1
    testimage=ratio_raw(:,:,20);
    image(testimage,'cdatamapping','scaled')
    axis image
    Happiness=questdlg('Draw the mask of hippocampus','GOULET INC');
    mask_r=roipoly;
    end
    inside=find(mask_r==1);
    outside=find(mask_r==0);
    close
    for i=1:size(ratio, 3)
        tframe=ratio(:,:,i);
        trframe=ratio_raw(:,:,i);
        tframe(outside)=0;
        trframe(outside)=0;
        ratio_raw(:,:,i)=trframe;
        ratio(:,:,i)=tframe;
        Slice_Ave(i)=mean(mean(tframe(inside)));
    end
    
    SinglePixel=squeeze(ratio(size(ratio,1)/2,size(ratio,2)/2,:));
    
    Slice_Ave_File=sprintf('%s/%s_SliceAve',directoryname,this_folder_list(thissif,1).name(size(this_folder_list(thissif,1).name,2)-11:size(this_folder_list(thissif,1).name,2)-4));
    Slice_Ave_SinglePixel_File=sprintf('%s/%s_SliceAveSinglePixel',directoryname,this_folder_list(thissif,1).name(size(this_folder_list(thissif,1).name,2)-11:size(this_folder_list(thissif,1).name,2)-4));
    
    save(Slice_Ave_File,'Slice_Ave');
    save(Slice_Ave_SinglePixel_File,'SinglePixel');
    
    MeanSTD(thissif)=std(Slice_Ave(1,300:400));
    SingleSTD(thissif)=std(SinglePixel(300:400,1));
    MeanSignal(thissif)=mean(Slice_Ave(1,300:400))-min(Slice_Ave);
    SingleSignal(thissif)=mean(SinglePixel(300:400,1))-min(SinglePixel);   
    SliceAve(thissif,:)=Slice_Ave;
    SlicePixel(thissif,:)=SinglePixel';
end





    


