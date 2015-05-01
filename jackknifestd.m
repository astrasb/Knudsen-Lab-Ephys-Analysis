function [R] = jackknifestd (R)

for q=1:size(R.swpctrl,2)
    tmp=R.swpctrl;
    tmp(:,q)=[];
    tmp=mean(tmp,2);
    ctrlstar(:,q)=R.drug./(tmp);
end
clear tmp
for q=1:size(R.swpdrug,2)
    tmp=R.swpdrug;
    tmp(:,q)=[];
    tmp=mean(tmp,2);
    drugstar(:,q)=tmp./R.ctrl;
end
star=horzcat(ctrlstar, drugstar);
R.jackstd=std(star,[],2)*sqrt(size(star,2));

end