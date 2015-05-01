


path = uigetdir('/mnt/m022a'); 
ext='ROI';
path1=sprintf('%s/*%s*',path,ext);
disp(path);
d = dir (path1);
numfiles=length(d);
directoryname=path;
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
  File_Names{i}=getfield(d,{i},'name') ;
  This_Tag=str2double(dd(i,t-10:t-8));
  
  if isnan(This_Tag)==1
      This_Tag=str2double(dd(i,t-9:t-8));
  end
  Tag_Sorter(i,1)=This_Tag;
 
  
end

[srt,imageorder]=sort(Tag_Sorter);

for i=1:numfiles

fn= sprintf('%s/%s',path,d(imageorder(i),1).name);
test=load('-mat', fn);
ROI_Data{i}=test;

end

Manipulation_Number=inputdlg('How many experimental treatments are in this file?');
Manipulation_Number=str2double(Manipulation_Number);

for i=1:numfiles
 
First_Slice=ROI_Data{1,i}.ROI_Composite_Data.ROI(1,1).FileName(1,:);
Last_Slice=ROI_Data{1,i}.ROI_Composite_Data.ROI(1,1).FileName(size(ROI_Data{1,i}.ROI_Composite_Data.ROI(1,1).FileName,1),:);

for Pick_Groups=1:Manipulation_Number

label=sprintf('This file contains experiment %s \n to experiment %s \n- how many experiments should be included in experimental group # %d ?', First_Slice, Last_Slice,Pick_Groups );
inputtemp=inputdlg(label);

inputtemp=str2double(inputtemp{1});

Exp_Group_Numbers(i,Pick_Groups)=inputtemp;

end


end
for trials=1:100

columnholder=0;
This_Group_Number=inputdlg('Which experimental treatment should be included?');
This_Group_Number=str2double(This_Group_Number);
This_ROI_Number=inputdlg('Which ROI should be included?');
This_ROI_Number=str2double(This_ROI_Number);

clear Output;

for i=1:numfiles

End_File_Value=sum(Exp_Group_Numbers(i,1:This_Group_Number)); 
if This_Group_Number==1
   Start_File_Value=1;
else
    Start_File_Value=sum(Exp_Group_Numbers(i,1:This_Group_Number-1));
end
Number_of_Exposures=End_File_Value-Start_File_Value+1;
if i==1
    frame_length=size(ROI_Data{1,i}.ROI_Composite_Data.ROI(1,This_ROI_Number).Exposure(Start_File_Value:End_File_Value,:),2);
end

temp=ROI_Data{1,i}.ROI_Composite_Data.ROI(1,This_ROI_Number).Exposure(Start_File_Value:End_File_Value,1:frame_length);
tempname= ROI_Data{1,i}.ROI_Composite_Data.ROI(1,This_ROI_Number).FileName(Start_File_Value:End_File_Value,:);
temptime= ROI_Data{1,i}.ROI_Composite_Data.ROI(1,This_ROI_Number).Times(1,1:frame_length);
columnholder=columnholder+Number_of_Exposures;


Output.Traces(columnholder-Number_of_Exposures+1:columnholder,:)=temp;
Output.Time=temptime;
Output.Names{i}=tempname;
end
end

    
    
    
    
    
