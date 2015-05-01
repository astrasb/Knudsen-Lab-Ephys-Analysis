function [Inside_Mask,Outside_Mask]=AndorMask(CellImages)
Images=CellImages{1};
Sample_Image_for_Making_Mask=Images(:,:,10);                    %%% Grabs a frame at the end of the discarded time
Sample_Image_for_Making_Mask=Sample_Image_for_Making_Mask(1:(size(Sample_Image_for_Making_Mask, 1)),:);     %%% Takes the top half of the image
Sample_Image_for_Making_Mask_Unfolded=reshape(Sample_Image_for_Making_Mask,1,[]);
%%% Next line gives you a histogram of the pixel intensity
%%% plot (xout, a)

[a xout]=hist(Sample_Image_for_Making_Mask_Unfolded,100);

%%% plot (xout, aa)

aa=smooth(a,'moving');
daa=diff(aa);
[histmax histloc]=max(aa);
Mask_Threshold=xout(histloc);
Mask_STD=std(Sample_Image_for_Making_Mask_Unfolded);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%% Important Step #2
%%% Mask_Threshold is the value that the program thinks you should mask
%%% with
%%% Confirm that Mask_Threshold is approximately the intensity value that
%%% you think it should be based on the image you just looked at

%%%  There are 2 ways to change the mask threshold
%%%  #1 - change X - xout(Crosspoint(dcPoint(X)))
%%%  #2 - manually adjust or set the value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Inside_Mask=find((Sample_Image_for_Making_Mask>Mask_Threshold-2*Mask_STD)&(Sample_Image_for_Making_Mask<Mask_Threshold+2*Mask_STD));
Outside_Mask=find((Sample_Image_for_Making_Mask<Mask_Threshold-2*Mask_STD)|(Sample_Image_for_Making_Mask>Mask_Threshold+2*Mask_STD));
end