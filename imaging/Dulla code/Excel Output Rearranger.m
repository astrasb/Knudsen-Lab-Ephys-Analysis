rows=size(holder,1);
columns=size(holder,2);
output=zeros(10,5*rows);

for i=1:rows
    
    rsrc=i;
    csrc=(1:5);
    rdst=floor(i/10)+1;
    cdst=(floor(i/10)+1)*columns+(1:columns);
end