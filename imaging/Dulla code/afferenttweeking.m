for i=1:size(unnamed,2)
    clear maxpts;
    Flip=unnamed1(i,1)-unnamed1(i,2);
    
    
    out(:,i)=smooth(unnamed(:,i));   
    out(:,i)=smooth(out(:,i));
    out(:,i)=out(:,i)-out(1,i);
    [maxout(i,1) maxloc]=min(out(:,i));
    
    [maxpts maxval]=find(out(:,i)<(maxout(i,1)/2));
    if size(maxpts)<2
        skew(i,1)=0;
    else
    if Flip>0
        skew(i,1)=(maxpts(1)-maxloc)+(maxpts(size(maxpts,1))-maxloc);
    else
        skew(i,1)=-((maxpts(1)-maxloc)+(maxpts(size(maxpts,1))-maxloc));
    end
end
end


