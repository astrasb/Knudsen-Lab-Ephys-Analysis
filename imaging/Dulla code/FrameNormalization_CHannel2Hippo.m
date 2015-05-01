function [Normalized]=FrameNormalization_Channel2Hippo_New(data, fit_results)
startimage=data(:,:,1);
endimage=data(:,:,size(data,3));
fitmax=max(fit_results);
[fitmin fitlot]=min(fit_results);
fit_results(1:fitlot)=fitmin;
diff=fitmax-fitmin;
Normalized=zeros(size(data,1),size(data,2),size(data,3));
for i=1:size(data,3)
    ThisFrame=data(:,:,i);
    %TimeRelativeToStart=(size(data,3)-i+1)/size(data,3); % Linear fitting
    %only - does not use 'fit_results' input
    TimeRelativeToStart=(fitmax-fit_results(i))/diff;
    TimeRelativeToEnd=1-TimeRelativeToStart;
    tempFrame=startimage*TimeRelativeToStart+endimage*TimeRelativeToEnd;
    NormFrame=ThisFrame-tempFrame+mean(mean(mean(startimage(size(data,1)/4:3*size(data,1)/4,size(data,2)/8:7*size(data,2)/8))));
    Normalized(:,:,i)=NormFrame;
   end
end