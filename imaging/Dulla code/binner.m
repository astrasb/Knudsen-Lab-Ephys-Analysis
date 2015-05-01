 low=0;
    mid=0;
    high=0;
for i=1:18
   
    if unnamed(i,1)<16
        low=low+1;
        skewlow(low)=unnamed(i,2);
        peaklow(low)=unnamed(i,4);
        xlow(low)=unnamed(i,1);
        
    end
    
    if (unnamed(i,1)>=16)&&(unnamed(i,1)<25)
        mid=mid+1;
        skewmid(mid)=unnamed(i,2);
        peakmid(mid)=unnamed(i,4);
        xmid(mid)=unnamed(i,1);
    end
    
    if unnamed(i,1)>=25
        high=high+1;
        skewhigh(high)=unnamed(i,2);
        peakhigh(high)=unnamed(i,4);
        xhigh(high)=unnamed(i,1);
    end
end
meanskew_high=mean(skewhigh);
steskew_high=std(skewhigh)/sqrt(size(skewhigh,1));

meanpean_low=mean(peaklow);
stepeak_low=std(peaklow)/sqrt(size(peaklow,1));

meanskew_low=mean(skewlow);
steskew_low=std(skewlow)/sqrt(size(skewlow,1));

meanpean_mid=mean(peakmid);
stepeak_mid=std(peakmid)/sqrt(size(peakmid,1));

meanskew_mid=mean(skewmid);
steskew_mid=std(skewmid)/sqrt(size(skewmid,1));

meanpean_high=mean(peakhigh);
stepeak_high=std(peakhigh)/sqrt(size(peakhigh,1));

meanx_mid=mean(xmid);
stex_mid=std(xmid)/sqrt(size(xmid,1));

meanx_low=mean(xlow);
stex_low=std(xlow)/sqrt(size(xlow,1));

meanx_high=mean(xhigh);
stexk_high=std(xhigh)/sqrt(size(xhigh,1));


