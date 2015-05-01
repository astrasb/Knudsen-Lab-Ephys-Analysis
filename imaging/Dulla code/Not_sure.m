for i=1:size(Int_Holder,2)
    
    output(1,i)=max(max(Int_Holder{1,i}.integrated_peak_rot));
    output(2,i)=min(min(Int_Holder{1,i}.integrated_peak_rot));
    output(3,i)=mean(mean(Int_Holder{1,i}.integrated_peak_rot));
   output(4,i)=std(std(Int_Holder{1,i}.integrated_peak_rot));
end
    
    
    