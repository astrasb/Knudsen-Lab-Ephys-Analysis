%%% Half width finder

for i=2:size(unnamed,2)
    offset=mean(unnamed(1:10,i));
    unnamed(:,i)=unnamed(:,i)-offset;
    [maxa maxtime]=min(unnamed(:,i));
    maxtimes(i-1)=unnamed(maxtime,1);
    maxval(i-1)=maxa;
    hwt=find(unnamed(maxtime:size(unnamed,1),i)>maxa*.50);
   
    if size(hwt)==1
        hw(i-1)=500;
    else
        if size(hwt)>0
            hw(i-1)=unnamed(hwt(1)+maxtime,1);
        else

        hw(i-1)=500;
        end
    end
end