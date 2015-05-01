%%%% FL Slice/Pharamcology averaging
clear all
[FileName,PathName] = uigetfile('/mnt/m022a/'); 
path1=sprintf('%s/%s',PathName,FileName);
data=load(path1);
data=data(:,2:size(data,2));

%Image number/pharm correspondance
%2007_12_12
SliceLabels=[1,3,4,11,12,18,26,31,32,37,38,43,49,52,53,58,59,62,67,71,72,75,76,80];
%2008_02_06
%SliceLabels=[1,5,6,10,11,20,21,25,26,43,44,49,50,54,55,68,69,76,77,80,81,96,97,106,107,111,112,121,122,126,127,131,132,141,142,150];
%2008_02_08
%SliceLabels=[1,5,6,15,16,25,26,30,31,40,41,50,51,55,56,65,66,75,76,80,81,90,91,99];
%2008_02_04
%SliceLabels=[1,5,6,10,11,15,16,20,21,26,27,33,34,38,39,43,50,53,54,58,59,63,64,68,69,73,74,79,80,84];
%2008_01_28
%SliceLabels=[1,4,5,9,10,14,15,18,19,24,25,30,31,35,36,40];
%2008_01_15
%SliceLabels=[1,4,5,9,10,19,20,25,26,35,36,45,46,50,51,60,61,70,71,76,77,86,87,96];
%2007_12_10
%SliceLabels=[1,3,4,8,9,13,21,25,26,30,31,35,40,44,45,49,50,54,62,67,68,72,73,77];

Number_of_Treatments=size(SliceLabels,2)/2;
output=zeros(Number_of_Treatments,size(data,2));
for i=1:Number_of_Treatments
    output(i,:)=mean (data ( SliceLabels ((i-1)*2+1) : SliceLabels ((i-1)*2+2),:));
end

holder=output(:,2:size(output,2));
holder=holder';
rows=size(holder,1);
columns=size(holder,2);
output=zeros(10,5*rows);

for i=1:rows/5
    for j=1:5
    
    rsrc=(i-1)*5+j;
    csrc=(1:columns);
    rdst=i;
    cdst=(j-1)*columns+(1:columns);
    
    finaloutput(rdst,cdst)=holder(rsrc,csrc);
    end
end