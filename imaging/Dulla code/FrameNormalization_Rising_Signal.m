function [Normalized, fit_results]=FrameNormalization_rising_signal(data, coeffvalues1)

for hh=1:size(data,3)
    fit_results(hh)=coeffvalues1(1)*exp(coeffvalues1(2)*hh)+coeffvalues1(3)*exp(coeffvalues1(4)*hh);
end
startimage=data(:,:,1);
endimage=data(:,:,size(data,3));
fitmax=max(fit_results);
fitmin=min(fit_results);
diff=fitmax-fitmin;
Normalized=zeros(size(data,1),size(data,2),size(data,3));
for i=1:size(data,3)
    ThisFrame=data(:,:,i);
    %TimeRelativeToStart=(size(data,3)-i+1)/size(data,3); % Linear fitting
    %only - does not use 'fit_results' input
     TimeRelativeToEnd=(fit_results(i)-fitmin)/diff;
     TimeRelativeToStart=1-TimeRelativeToEnd;
   
    tempFrame=startimage*TimeRelativeToStart+endimage*TimeRelativeToEnd;
    NormFrame=ThisFrame-tempFrame+mean(mean(mean(startimage(size(data,1)/4:3*size(data,1)/4,size(data,2)/8:7*size(data,2)/8))));
    Normalized(:,:,i)=NormFrame;
   end
end