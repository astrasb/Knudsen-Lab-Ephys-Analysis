rows=size(holder,1);
columns=size(holder,2);
output=zeros(10,5*rows);

for i=1:rows/5
    for j=1:5
    
    rsrc=(i-1)*5+j;
    csrc=(1:columns);
    rdst=i;
    cdst=(j-1)*columns+(1:columns);
    
    output(rdst,cdst)=holder(rsrc,csrc);
    end
end