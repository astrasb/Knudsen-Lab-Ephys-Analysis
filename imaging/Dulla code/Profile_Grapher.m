%%%% Open a profile file, average the trials together and out put a graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
clear all;

dirnamesearch = dir('/mnt/m022a/All_FL_DA_Files/*');
dirnamesearch(1:2,:)=[];
totalfiles=1;
        path3=('/mnt/m022a/FL_north*');
        d3 = dir (path3);
        numfiles3=length(d3);
        if numfiles3<1
            disp('No files found');
            northorsouthfound=0;
        else
            northorsouthfound=1;
            tempfileloc=open(sprintf('/mnt/m022a/%s',d3.name));
            FL_North_or_South=tempfileloc.FL_North_or_South;
        end
        path4=('/mnt/m022a/FL_yes*');
        d4 = dir (path4);
        numfiles4=length(d4);
        if numfiles4<1
            disp('No files found');
            yesornofound=0;
        else
            yesornofound=1;
            tempfileloc=open(sprintf('/mnt/m022a/%s',d4.name));
            FL_yes_or_no=tempfileloc.FL_yes_or_no;
        end

        path5=('/mnt/m022a/included_trials*');
        d5 = dir (path5);
        numfiles5=length(d5);
        if numfiles5<1
            disp('No files found');
            includedfound=0;
        else
            includedfound=1;
            tempfileloc=open(sprintf('/mnt/m022a/%s',d5.name));
            included_trials=tempfileloc.included_trials;
        end
for folder=1:size(dirnamesearch,1);
    subfolder=dir(sprintf('/mnt/m022a/All_FL_DA_Files//%s', dirnamesearch(folder,:).name));
    subfolder(1:2,:)=[];
    for thissubfolder=1:size(subfolder,1)
        
        
        
        dirname=sprintf('/mnt/m022a/All_FL_DA_Files/%s/%s', dirnamesearch(folder,:).name,subfolder(thissubfolder,:).name);
        path1=sprintf('%s/*profile.mat',dirname);
        d = dir (path1);
        numfiles=length(d);
        if numfiles<1
            disp('No files found');
        end
        path2=sprintf('%s/*params.mat',dirname);
        d2 = dir (path2);
        numfiles2=length(d2);
        if numfiles2<1
            disp('No files found');
        end
        
        if yesornofound==0
            FLtest=questdlg(sprintf('Is %s %s a FL',dirnamesearch(folder).name,subfolder(thissubfolder,:).name));
            FLyep=strcmp('Yes',FLtest);
            if FLyep==1
                FL_yes_or_no(totalfiles)=1;
            else
                FL_yes_or_no(totalfiles)=0;
            end
        end
        
        if northorsouthfound==0
            FLDirection=questdlg(sprintf('Is the FL above the stimulator?'));
            FLDir=strcmp('Yes',FLDirection);
            if FLyep==1
                FL_North_or_South(totalfiles)=1;
            else
                FL_North_or_South(totalfiles)=0;
            end
        end
        profile=open(sprintf('%s/%s', dirname,d.name));
        filenameoutput{totalfiles}=sprintf('%s/%s', dirname,d.name);
        profile=profile.profile;
        stim=open(sprintf('%s/%s', dirname,d2.name));
        stimulation_site=stim.params.stim_loc;
        
        if includedfound==1
            Chris='rad';
        else
        selected='Yes';
        count=0;
        for testing=1:5
            if strcmp(selected,'Yes')
                
                count=count+1;
                plot(squeeze(profile(testing,:,:))');
                selected=questdlg('Should this be included as a NON-GBZ trial?');
            else
                testing=5;
               
            end
        end
        close
        included_trials(totalfiles)=count-1;
        end
        averaged_data=-squeeze(mean(profile(1:included_trials(totalfiles),:,:)))';
        averaged_data(:,1:5)=[];
        
        testdataforzeros=mean(averaged_data');
        zeroindex=find(testdataforzeros==0);
        [datasplit splitindex]=max(diff(zeroindex));
        
        for i=1:size(zeroindex,2)
            averaged_data(zeroindex(size(zeroindex,2)-i+1),:)=[];
        end
        for i=1:size(averaged_data,2);
            testsmooth(:,i)=squeeze(smooth(averaged_data(:,i)));
        end
        if 2<1
        ColorIteration(averaged_data(:,1:100));
        box off;
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        set(gca,'xlim',[1,size(averaged_data,1)]);
        set(gca,'Position',[,0,.01,.99,1]);
        set(gca,'ylim',[-.02, .2]);
        adj_stim=(stimulation_site(2)-splitindex)*.99;
        xsite=adj_stim/size(averaged_data,1);
        ylims=get(gca,'ylim');
        xlims=get(gca,'xlim');
        yspan=abs(ylims(1)-ylims(2));
        annotation('arrow',[xsite,xsite],[0.01,.1],'linewidth',3,'headstyle','plain')
        microns250=(10/diff(xlims))*.99;
        FRETUnits05=(0.05/yspan)*.99;
        annotation('line',[.995-microns250,.995],[0.01,.01],'linewidth',3);
        annotation('line',[.995,.995],[.01,FRETUnits05+.01],'linewidth',3);
        printfilename=sprintf('%s/profile.tif',dirname);
       % print ('-dtiff','-r400', printfilename)
        close
        end
        [peaks(totalfiles,:,:),g1p(totalfiles,:,:),g1w(totalfiles,:,:),g2p(totalfiles,:,:),g2w(totalfiles,:,:),peaks_summed(totalfiles,:,:),peaks_g1(totalfiles,:,:), peaks_g2(totalfiles,:,:),centroid(totalfiles,:),SGhalfwidth(totalfiles,:), SummedG{totalfiles},sumR2(totalfiles,:,:),singleR2(totalfiles,:,:), STheshwidth(totalfiles,:), SQuarterwidth(totalfiles,:), Area(totalfiles,:),SHalfwidthDirInd(totalfiles,:),SHalfwidthDirInd2(totalfiles,:), SQwidthDirInd(totalfiles,:), SQwidthDirInd2(totalfiles,:),STwidthDirInd(totalfiles,:),STwidthDirInd2(totalfiles,:),FirstPeak(totalfiles,:), FirstIndex(totalfiles,:), SecondPeak(totalfiles,:), SecondIndex(totalfiles,:), Area1(totalfiles,:), Area2(totalfiles,:) ]=ColorIteration(testsmooth(:,1:55));
        box off;
        
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        set(gca,'xlim',[1,size(averaged_data,1)]);
        set(gca,'Position',[,0,.01,.99,1]);
        set(gca,'ylim',[-.02, .2]);
        adj_stim=(stimulation_site(2)-splitindex)*.99;
        stims(totalfiles)=stimulation_site(2)-splitindex;
        xsite=adj_stim/size(averaged_data,1);
        ylims=get(gca,'ylim');
        xlims=get(gca,'xlim');
        yspan=abs(ylims(1)-ylims(2));
        annotation('arrow',[xsite,xsite],[0.01,.1],'linewidth',3,'headstyle','plain')
        microns250=(10/diff(xlims))*.99;
        FRETUnits05=(0.05/yspan)*.99;
        annotation('line',[.995-microns250,.995],[0.01,.01],'linewidth',3);
        annotation('line',[.995,.995],[.01,FRETUnits05+.01],'linewidth',3);
        printfilenamesm=sprintf('%s/prof_smoothed.tif',dirname);
        %print ('-dtiff','-r400', printfilenamesm)
        totalfiles=totalfiles+1;
        close all;
        clear averaged_data;
        clear testsmooth;
        clear profile;
    end
end
