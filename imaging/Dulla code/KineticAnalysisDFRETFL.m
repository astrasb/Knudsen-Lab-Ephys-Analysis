for i=1:size(unnamed,2)
[maximum(i) peaktime(i)]=max(unnamed(:,i));


time=1:size(unnamed,1)-peaktime+1;
data=unnamed(peaktime:size(unnamed,1),i);
list=find(data<(maximum(i)*.33));
halfwidth(i)=list(1)+peaktime(i)-250;

ft_ = fittype('exp2');

% Fit this model using new data
cf_ = fit(time',data,ft_);

b(i)=cf_.b;
d(i)=cf_.d;

   
end
