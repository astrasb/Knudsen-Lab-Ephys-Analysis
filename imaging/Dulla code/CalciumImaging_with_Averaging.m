%%%%  Calcium Mouse Imaging
%%%%
clear all
ScaleFactor=10;
L_R_OffsetFactor=-410;
U_D_OffsetFactor=0;
VertAdjust=0;
HorizAdjust=0;
%%%%%%%%%%%% Open Andor File
directoryname = uigetdir('/mnt/m022a');  % Open Top Level directory - each folder must contain a brightfield Tiff(Cooke), brightfield sif, PClamp file, and relevant sif files
dir_tree = dirr(directoryname, 'Untitled'); % Use dirr to create the directory sturcture variable
folders=size(dir_tree,1); % determine the number of folder (approx equal to number of slices)
%%%%%%%%%%%% Open Files Common to all subfolders - ROIs, Parameters, abf
%%%%%%%%%%%% file, brightfield tiff

%%%%%%%%%%%% Open Parameter file
        ext='ameter';
        PathName=sprintf('%s/',directoryname);
        path1=sprintf('%s*%s*',PathName,ext);
        disp(PathName);
        d = dir (path1);
        numfiles=length(d);
        
        if numfiles<1
            disp('No files found');
            parameters_present=0;
        else
            
            
            for i = 1:numfiles
                t = length(getfield(d,{i},'name')) ;
                dd(i, 1:t) = getfield(d,{i},'name') ;
            end
            pmfn=sprintf('%s%s',PathName,dd(1,:));
            Parameters_in=open(pmfn);
            mask_r=Parameters_in.parameters{1};
            Adj_factors=Parameters_in.parameters{2};
            ScaleFactor=Adj_factors(1);
            L_R_OffsetFactor=Adj_factors(2);
            U_D_OffsetFactor=Adj_factors(3);
            AlignFactors=Parameters_in.parameters{3};
            VertAdjust=AlignFactors(1);
            HorizAdjust=AlignFactors(2);
            mask=Parameters_in.parameters{4};
            Roi_Stim=Parameters_in.parameters{5};
            Roi_CA1_O=Parameters_in.parameters{6};
            Roi_CA1_A=Parameters_in.parameters{7};
            Roi_CA3=Parameters_in.parameters{8};
            Roi_Dentate=Parameters_in.parameters{9};
            x_cutoff=Parameters_in.parameters{10};
            x_restart=Parameters_in.parameters{11};
            parameters_present=1;           
            
            
        end

%%%%%%%%%%%% Open Brightfield Andor file
        ext='righ';
        path1=sprintf('%s*%s*',PathName,ext);
        disp(PathName);
        d = dir (path1);
        numfiles=length(d);
        
        if numfiles<1
            disp('No Brightfield Andor files found');
        end
        
        
        for i = 1:numfiles
            t = length(getfield(d,{i},'name')) ;
            dd(i, 1:t) = getfield(d,{i},'name') ;
        end
        for thisfile = 1:numfiles
            %try/mnt/m022a
            
            fna=dd(thisfile,:);
            
            fna=strtok(fna,'.');
            %fna=fna(1:length(fna)-4);
            disp(fna);
            %fna='eeg3';
            fn= sprintf('%s%s.sif',PathName,fna);
        end
        
        [BrightImage, BrighInstaImage,BrightCalibImage,Brightvers]=andorread_chris_local_knownfilename(fn);
        
        Bright=BrightImage.data(1:size(BrightImage.data,1)/2,:,1);
        
%%%%  get start and end times for curvefitting if not present
         if parameters_present==0;
            
           
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
for thisfolder=1:folders;  %%%%%  Begin crawling through the folders 
   
    searchparameter=sprintf('%s/%s/*Untitled*.sif',directoryname,dir_tree(thisfolder,1).name);
    this_folder_list = rdir(searchparameter); % Use dirr to create the directory sturcture variable
    sifs=size(this_folder_list,1);
    sweepstoday=[36 37 38 38 40]; %% Sweeps for 5/19 Slice 1 control
    %sweepstoday=[161 162 169 170 171 172 173 233 234 235 236 237];
    for thissif=1:sifs
        
        fn=this_folder_list(thissif).name;
        %Happiness=questdlg('Please Select your Calcium Imaging Andor File','GOULET INC');
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
        ch1=temp(1:64,:,shutter_open_frame+4:shutter_close_frame-3);
        ch2=temp(65:128,:,shutter_open_frame+4:shutter_close_frame-3);
        ch1tofit=squeeze(mean(mean(ch1)));
        ch2tofit=squeeze(mean(mean(ch2)));
        Aligned='No';
        
        
        
        
        
        %%%% Plotting the means of Ch1 and Ch2 for Curve fitting
        subplot(2,1,1)
        plot(ch1tofit)
        subplot(2,1,2)
        plot(ch2tofit)
   
                        
                
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
            
            if 2>1
            [coeffvalues1]=DoubleExponentialFit(fit_time,fit_ch1);
            [coeffvalues2]=DoubleExponentialFit(fit_time,fit_ch2);
            for hh=1:size(ch1,3)
                Ch1_fit_results(hh)=coeffvalues1.a*exp(coeffvalues1.b*hh)+coeffvalues1.c*exp(coeffvalues1.d*hh);
                Ch2_fit_results(hh)=coeffvalues2.a*exp(coeffvalues2.b*hh)+coeffvalues2.c*exp(coeffvalues2.d*hh);
            end
              
           
            [Ch1_Normalized, trs,trn]=FrameNormalization_Double_Exponential(ch1, coeffvalues1);
            [Ch2_Normalized]=FrameNormalization_CHannel2Hippo(ch2, Ch2_fit_results);
                   
            
            else      
            %%%%%%%%%%%  Curve fit subtraction
          
            [coeffvalues1]=FourtDegreePolynomialFit(fit_time,fit_ch1)
            [coeffvalues2]=FourtDegreePolynomialFit(fit_time,fit_ch2)
            for hh=1:size(ch1,3)
                Ch1_fit_results(hh)=coeffvalues1.a*hh^3+coeffvalues1.b*hh^2+coeffvalues1.c*hh+coeffvalues1.d;
                Ch2_fit_results(hh)=coeffvalues2.a*hh^3+coeffvalues2.b*hh^2+coeffvalues2.c*hh+coeffvalues2.d;
            end
            [Ch1_Normalized]=FrameNormalization_4th_DegreePolynomial(ch1, coeffvalues1);
            [Ch2_Normalized]=FrameNormalization_4th_DegreePolynomial(ch2, coeffvalues2);
            end
            ch1sub=ch1tofit-Ch1_fit_results';
            ch2sub=ch2tofit-Ch2_fit_results';
            ch1sub=ch1sub+ch1tofit(1,1);
            ch2sub=ch2sub+ch2tofit(1,1);
            ratiosub=ch1sub./ch2sub;
            
    storage1(thissif,:,:,:)=Ch1_Normalized;      
    storage2(thissif,:,:,:)=Ch2_Normalized;
    end
    c1=squeeze(mean(storage1));
    c2=squeeze(mean(storage2));
    rt=c1./c2;
 
    
    
            %%%%%%%%%%%%%%%%%%%%%%% Adjust alignment
[ratio, ratio_raw,Aligned,VertAdjust,HorizAdjust]=realignDVimages(ch1, ch2, Ch1_Normalized, Ch2_Normalized,Aligned,parameters_present,VertAdjust,HorizAdjust);  
            
        
        over=find(ratio>6);
        ratio(over)=6;
        under=find(ratio<3);
        ratio(under)=3;
        
        over_R=find(ratio_raw>6);
        ratio_raw(over_R)=6;
        under_raw=find(ratio_raw<3);
        ratio_raw(under_raw)=3;
        figure (1)
        image(Bright, 'cdatamapping','scaled');
        colormap(gray)
        figure (2)
        image(ratio_raw(:,:,100),'cdatamapping','scaled');
       
        if (parameters_present==0)
            Happiness=questdlg('Trace Stimulation site','GOULET INC');
            Roi_Stim=roipoly;
        end
                
        if (parameters_present==0)
            Happiness=questdlg('Trace Orthodromic CA1','GOULET INC');
            Roi_CA1_O=roipoly;
        end
        if (parameters_present==0)
            Happiness=questdlg('Trace Antidromic CA1','GOULET INC');
            Roi_CA1_A=roipoly;
        end
        if (parameters_present==0)
            Happiness=questdlg('Trace  CA3','GOULET INC');
            Roi_CA3=roipoly;
        end
        if (parameters_present==0)
            Happiness=questdlg('Trace Dentate','GOULET INC');
            Roi_Dentate=roipoly;
        end
        for i=1:size(ratio,3)
            tempimage=ratio(:,:,i);
            Roi_out(i,2)=mean(tempimage(Roi_Stim));
            Roi_out(i,3)=mean(tempimage(Roi_CA1_O));
            Roi_out(i,4)=mean(tempimage(Roi_CA1_A));
            Roi_out(i,5)=mean(tempimage(Roi_CA3));
            Roi_out(i,6)=mean(tempimage(Roi_Dentate));
        end
        for i=1:size(ratio,3)
            tempimage=rt(:,:,i);
            Roi_out_(i,2)=mean(tempimage(Roi_Stim));
            Roi_out_(i,3)=mean(tempimage(Roi_CA1_O));
            Roi_out_(i,4)=mean(tempimage(Roi_CA1_A));
            Roi_out_(i,5)=mean(tempimage(Roi_CA3));
            Roi_out_(i,6)=mean(tempimage(Roi_Dentate));
        end
        do_you_want_to_deal_with_an_ABF_file=0;
        if do_you_want_to_deal_with_an_ABF_file==1
        ext='abf';
        path1=sprintf('%s/*%s*',PathName,ext);
        disp(PathName);
        dddd = dir (path1);
        fn1= sprintf('%s%s',PathName, dddd.name);
        [d,si,sw,tags,et,cn,timestamp]=abfload(fn1);
        timestamps(thisfile)=timestamp;
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
        
        andormin=min(Roi_out(:,4))-.1;
        andormax=max(Roi_out(:,4))+.1;
        %%%%%  Mask the hippocampus in the ratioed image
        end
        do_you_want_to_make_a_movie=0;
        if do_you_want_to_make_a_movie==1;
        
        testimage=ratio_raw(:,:,20);
        image(testimage,'cdatamapping','scaled')
        axis image
        if (parameters_present==0)
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
        end
        
        %%%%%  Mask the hippocampus in the Andor Brightfield
        
        testimage_bright=Bright;
        image(testimage_bright,'cdatamapping','scaled')
        axis image
        colormap gray
        if (parameters_present==0)
            Happiness=questdlg('Draw the mask of hippocampus','GOULET INC');
            mask=roipoly;
        end
        inside=find(mask==1);
        outside=find(mask==0);
        close
        testimage_bright(outside)=0;
        
        
        
        %%% Trial Rescaling and Alignment to get paramaeters
        
        
        Happiness='No';
        while (strcmp(Happiness,'No')==1)
            [andorscaled, cookscaled, L_R_OffsetFactor, U_D_OffsetFactor]=registration_test_calcium(testimage_bright, PathName, ScaleFactor, L_R_OffsetFactor, U_D_OffsetFactor, andormin, andormax) ;
            if (parameters_present==0)
                
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
            else
                Happiness='Yes';
            end
        end
        [combined, andorscaled, cookscaled_128, L_R_OffsetFactor, U_D_OffsetFactor]=registration_full_calcium(ratio, PathName, ScaleFactor, L_R_OffsetFactor, U_D_OffsetFactor, andormin, andormax) ;
        
        [BW_RGBCustom]=CreateBW_RGBColorTable_inverted;
        tail_end_clip=100;
        h=figure;
        avifilenameave=sprintf('%s%s-%s',PathName,InstaImage.filename(52:61),InstaImage.filename(71:82));
        FPS=15;
        
        for i=1:size(combined, 3)-tail_end_clip+FPS*2
            if i==1
                for t=1:+FPS*2
                    SliceImage=subplot(3,1,1);
                    tempimage2=cookscaled_128(1:2*size(cookscaled_128,1)/3,:);
                    image (tempimage2,'CDataMapping', 'direct');
                    colormap(BW_RGBCustom);
                    set(gca,'xtick',[],'ytick',[]);
                    hold(SliceImage,'on');
                    TraceImage=subplot(3,1,2);
                    plot(time_subsampled_supra(1,1:i*suprasample),e_trace_subsampled_supra(1,1:i*suprasample));
                    xlim([triggertimes(shutter_open_frame+3) triggertimes(shutter_close_frame-3-tail_end_clip)]);
                    ylim([traceave-1 traceave+1]);
                    box off;
                    ROIImage=subplot(3,1,3);
                    plot(time_subsampled(1,1:i),Roi_out(1,1:i));
                    xlim([triggertimes(shutter_open_frame+3) triggertimes(shutter_close_frame-3-tail_end_clip)]);
                    ylim([3.8 4.8]);
                    box off;
                    
                    set(SliceImage, 'OuterPosition', [0,.3,1,.7])
                    set(TraceImage, 'OuterPosition', [0,.15,1,.15])
                    set(ROIImage, 'OuterPosition', [0,0,1,.15])
                    F(t)=getframe(h);
                end
            end
            
            SliceImage=subplot(3,1,1);
            tempimage2=combined(1:2*size(combined,1)/3,:,i);
            image (tempimage2,'CDataMapping', 'direct');
            colormap(BW_RGBCustom);
            am=roundoff(andormax,3);
            ami=roundoff(andormin,3);
            graphcolor=colorbar('ytick',[1 256],'Yticklabel',{ami, am});
            hs=findall(gcf,'type','image');
            xf=get(hs(1),'cdata');
            for cfill=1:2:255
                xf(cfill)=cfill/2+128;
                xf(cfill+1)=cfill/2+128;
            end
            set(hs(1),'cdata',xf);
            set(gca,'xtick',[],'ytick',[]);
            hold(SliceImage,'on');
            TraceImage=subplot(3,1,2);
            plot(time_subsampled_supra(1,1:i*suprasample),e_trace_subsampled_supra(1,1:i*suprasample));
            xlim([triggertimes(shutter_open_frame+3) triggertimes(shutter_close_frame-3-tail_end_clip)]);
            ylim([traceave-1 traceave+1]);
            set(gca,'xtick',[]);
            box off;
            ROIImage=subplot(3,1,3);
            plot(time_subsampled(1,1:i),Roi_out(1:i,4));
            xlim([triggertimes(shutter_open_frame+3) triggertimes(shutter_close_frame-3-tail_end_clip)]);
            ylim([andormin andormax]);
            box off;
            
            set(SliceImage, 'OuterPosition', [0,.31,1,.7])
            set(TraceImage, 'OuterPosition', [0,.2,1,.15])
            set(ROIImage, 'OuterPosition', [0,0,1,.2])
            set(graphcolor, 'OuterPosition', [.8,.8,.1,.15])
            F(i+FPS*2)=getframe(h);
            
        end
        
        
        movie2avi(F,avifilenameave, 'fps', FPS);
        
        end
        if do_you_want_to_make_a_movie==0
            
            mask_r=1;
            mask=1;
        end
        parameters{1}=mask_r;
        parameters{2}=[ScaleFactor; L_R_OffsetFactor; U_D_OffsetFactor];
        parameters{3}=[VertAdjust; HorizAdjust];
        parameters{4}=mask;
        parameters{5}= Roi_Stim;
        parameters{6}= Roi_CA1_O;
        parameters{7}= Roi_CA1_A;
        parameters{8}= Roi_CA3;
        parameters{9}= Roi_Dentate;  
        parameters{10}=x_cutoff;
        parameters{11}= x_restart;
        parameters{12}=Roi_out;
        parameters{13}=Roi_out_;
        parameterfile=sprintf('%sParameters',PathName);
        save (parameterfile,'parameters');
        text_f=sprintf('%s/%s%s-%s_ROI',PathName,dir_tree(thisfolder,1).name,InstaImage.filename(52:61),InstaImage.filename(71:size(InstaImage.filename,2)-5));
        save (text_f, 'Roi_out', '-ascii','-tabs');
        text_f=sprintf('%s/%s%s-%s_ROI_newway',PathName,dir_tree(thisfolder,1).name,InstaImage.filename(52:61),InstaImage.filename(71:size(InstaImage.filename,2)-5));
        save (text_f, 'Roi_out_', '-ascii','-tabs');
        
        figure(1)
        subplot(3,2,1)
        plot(Roi_out_(:,2));
        title('Stim Tip')
        subplot(3,2,2)
        plot(Roi_out_(:,3));
        title('CA1 Orth')
        subplot(3,2,3)
        plot(Roi_out_(:,4));
        title('CA1 Anti')
        subplot(3,2,4)
        plot(Roi_out_(:,5));
        title('CA3')
        subplot(3,2,5)
        plot(Roi_out_(:,6));
        title('Dentate')
        ROI_Picture_Filename=sprintf('%s/%s/GroupAverage.jpg',directoryname, dir_tree(thisfolder,1).name);  
        %saveas(gcf, ROI_Picture_Filename);
        print ('-dtiff','-r400',  ROI_Picture_Filename)
        
         figure(2)
        subplot(3,2,1)
        plot(Roi_out(:,2));
        title('Stim Tip')
        subplot(3,2,2)
        plot(Roi_out(:,3));
        title('CA1 Orth')
        subplot(3,2,3)
        plot(Roi_out(:,4));
        title('CA1 Anti')
        subplot(3,2,4)
        plot(Roi_out(:,5));
        title('CA3')
        subplot(3,2,5)
        plot(Roi_out(:,6));
        title('Dentate')
          ROI_Picture_Filename=sprintf('%s/%s/Single Example.jpg',directoryname, dir_tree(thisfolder,1).name);  
        %saveas(gcf, ROI_Picture_Filename);
        print ('-dtiff','-r400',  ROI_Picture_Filename)
    clear F;
    clear ratio;
    clear combined;
    clear andorscaled_out;
    clear andorscaled;
    clear ch1;
    clear ch2;
    clear Ch1_Normalized;
    clear Ch2_Normalized;
    clear d;
    clear e_time;
    clear e_trace;
    clear over_R;
    clear ratio_raw;
    clear temp;
    clear trigger;
    clear underraw;
    clear e_trace;
    clear e_trace_subsampled;
    clear e_trace_subsampled_supra;
    clear trigger;
    clear triggertimes;
    clear triggertimes_locs;
    
end


