for i=1:19
    subplot(3,1,1)
    plot(1:1000,MZsm(i,:),1:1000,PMZsm(i,:));
    subplot(3,1,2)
    plot(1:1000,FLMZ(i,:),1:1000,pFLMZ(i,:));
    subplot(3,1,3)
    plot(1:1000,NormMZ(i,:),1:1000,NormPMZ(i,:));
    close all;
end

NormMZ_S=NormMZ;
NormPMZ_S=NormPMZ;
Sub_norm_S=Sub_norm;
PMZsm_S=PMZsm;
MZsm_S=MZsm;
Subtracted_S=Subtracted;
for i=1:4;
   
    gone=[18,14,12,11];
    
    NormMZ_S(gone(i),:)=[];
    NormPMZ_S(gone(i),:)=[];
    Sub_norm_S(gone(i),:)=[];
    PMZsm_S(gone(i),:)=[];
    MZsm_S(gone(i),:)=[];
    Subtracted_S(gone(i),:)=[];
    
end