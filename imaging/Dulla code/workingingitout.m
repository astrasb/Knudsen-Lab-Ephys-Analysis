for i=1:5
    [fmin ptime(i) ]=min(squeeze(Sdata(1,i,:)));
    [val locs]=find(squeeze(Sdata(1,i,:))<(fmin/2));
    times(i)=val(size(val,1));
    
    
    
end