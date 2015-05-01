%%%% Open a profile file, average the trials together and out put a graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
clear all;

dirnamesearch = dir('/mnt/m022a/All Afferent Mapping SIF take 2/*');
dirnamesearch(1:2,:)=[];
totalfiles=0;

for folder=1:size(dirnamesearch,1);
    subfolder=dir(sprintf('/mnt/m022a/All Afferent Mapping SIF take 2/%s/*lice*', dirnamesearch(folder,:).name));
    
    Profile=open(sprintf('/mnt/m022a/All Afferent Mapping SIF take 2/%s/AfferentProfiling_I.mat',dirnamesearch(folder,:).name));
    Profile_Names=open(sprintf('/mnt/m022a/All Afferent Mapping SIF take 2/%s/AfferentProfiling_FileNames.mat',dirnamesearch(folder,:).name));
    Profile_Other_D=open(sprintf('/mnt/m022a/All Afferent Mapping SIF take 2/%s/AfferentProfiling_otherDirection.mat',dirnamesearch(folder,:).name));
    Profile_Names=Profile_Names.ddir3;
    Profile=Profile.Profile_I;
    All_Profiles{folder}=Profile;
    Profile_Other_D=Profile_Other_D.Profile_otherDir_I;
    for thissubfolder=1:size(subfolder,1)
        totalfiles=totalfiles+1;
        
        
        dirname=sprintf('/mnt/m022a/All Afferent Mapping SIF files/%s/%s', dirnamesearch(folder,:).name,subfolder(thissubfolder,:).name);
        path3=sprintf('%s/*stim_location*',dirname);
        d3 = dir (path3);
        numfiles3=length(d3);
        if numfiles3<1
            disp('No files found');
        end
        
        FLMask=open(sprintf('%s/FLMask.mat',dirname));
        FLMask=FLMask.FL;
        StimSite=open(sprintf('%s/StimSite.mat',dirname));
        StimSite=StimSite.StimSite;
        [Waste stimulation_site(totalfiles,:)]=max(mean(StimSite));
        
        
        [Waste FL_Location(totalfiles,:)]=max(mean(FLMask));
        %FL_Location=64-FL_Location;
        if FL_Location<5
            FL_yes_or_no(totalfiles,:)=0;
        else
            FL_yes_or_no(totalfiles,:)=1;
        end
        
        if (FL_Location(totalfiles,:)-stimulation_site(totalfiles,:))>0
            FL_North_or_South(totalfiles)=1;
        else
            FL_North_or_South(totalfiles)=0;
        end
        stims(totalfiles,:)=stimulation_site(totalfiles,:);
        profile(totalfiles,:)=-Profile(thissubfolder,:);
        
        [p_max(totalfiles,:) max_loc(totalfiles,:)]=max(profile(totalfiles,:));
        
        if FL_North_or_South(totalfiles)==0;
            p_offset(totalfiles,:)=max_loc(totalfiles,:)-stims(totalfiles,:)
        else
            p_offset(totalfiles,:)=-(max_loc(totalfiles,:)-stims(totalfiles,:));
        end
        
        weighted_offset(totalfiles,:)=p_offset(totalfiles,:)*p_max(totalfiles,:);
        FL_Stim_dist(totalfiles,:)=FL_Location(totalfiles,:)-stimulation_site(totalfiles,:);
        
        
        
        
        
    %%%%% Dead Analysis for now
        if 2<1
        profile_o(totalfiles,:)=-Profile_Other_D(thissubfolder,:);
        filenameoutput{totalfiles}=sprintf('%s/%s',dirname,Profile_Names(thissubfolder,1).name);
        profile(totalfiles,:)=smooth(profile(totalfiles,:))';
        profile_o(totalfiles,:)=smooth(profile_o(totalfiles,:))';
        [peaks(totalfiles,:,:),g1p(totalfiles,:),g1w(totalfiles,:),g2p(totalfiles,:),g2w(totalfiles,:),peaks_summed(totalfiles,:),peaks_g1(totalfiles,:), peaks_g2(totalfiles,:),centroid(totalfiles,:),SGhalfwidth(totalfiles,:), SummedG{totalfiles},sumR2(totalfiles,:),singleR2(totalfiles,:), STheshwidth(totalfiles,:), SQuarterwidth(totalfiles,:), Area(totalfiles,:),SHalfwidthDirInd(totalfiles,:),SHalfwidthDirInd2(totalfiles,:), SQwidthDirInd(totalfiles,:), SQwidthDirInd2(totalfiles,:),STwidthDirInd(totalfiles,:),STwidthDirInd2(totalfiles,:),FirstPeak(totalfiles,:), FirstIndex(totalfiles,:), SecondPeak(totalfiles,:), SecondIndex(totalfiles,:), Area1(totalfiles,:), Area2(totalfiles,:) ]=ColorIteration_for_Afferent_Mapping(profile(totalfiles,:));
        box off;
        
        
        
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        set(gca,'xlim',[1,size(profile,2)]);
        set(gca,'Position',[,0,.01,.99,1]);
        set(gca,'ylim',[-.005, .05]);
        adj_stim=(stimulation_site)*.99;
        adj_FL=FL_Location*.99;
        stims(totalfiles)=stimulation_site;
        FLsite(totalfiles)=FL_Location;
        xsite=adj_stim/size(profile,2);
        xsite_FL=adj_FL/size(profile,2);
        ylims=get(gca,'ylim');
        xlims=get(gca,'xlim');
        yspan=abs(ylims(1)-ylims(2));
        annotation('arrow',[xsite,xsite],[0.01,.1],'linewidth',3,'headstyle','plain')
        annotation('line',[xsite_FL,xsite_FL],[0, 1],'linewidth',3,'color','red')
        microns250=(10/diff(xlims))*.99;
        FRETUnits05=(0.05/yspan)*.99;
        annotation('line',[.995-microns250,.995],[0.01,.01],'linewidth',3);
        annotation('line',[.995,.995],[.01,FRETUnits05+.01],'linewidth',3);
        printfilenamesm=sprintf('%s/prof_smoothed.tif',dirname);
        %print ('-dtiff','-r400', printfilenamesm)
        
        close all;
        end
    end
end
