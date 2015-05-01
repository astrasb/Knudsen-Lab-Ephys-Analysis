%%%% Object Recognition
clear all
close all
process_group=0;
DataFound=0;
ROIFound=0;
% Choose File to Open

if process_group ==0
[Path directoryname] = uigetfile('/mnt/m022a/SR101_FL');


else

superstructure=dirr('/mnt/m022a/SR101_FL/');
end
basedir='/mnt/m022a/SR101_FL';
filecounter=0;
fnall={1,1}
if process_group==1
    
    for shell_1=12:size(superstructure,1)
        if size(superstructure(shell_1,1).isdir,1)>1
            
            for shell_2=1:size(superstructure(shell_1,1).isdir,1)
                
                filecounter=filecounter+1;
                gettingthere=sprintf('%s/%s/%s/*compiled*', basedir,superstructure(shell_1,1).name,superstructure(shell_1,1).isdir(shell_2,1).name);
                checking_for_file=dir(gettingthere);
                if size(checking_for_file,1)==1
                    fnall{1,filecounter}=sprintf('%s/%s/%s/', basedir,superstructure(shell_1,1).name,superstructure(shell_1,1).isdir(shell_2,1).name);
                    fnall{2,filecounter}=sprintf('%s', checking_for_file(1,1).name);
              
                else
                    filecounter=filecounter-1;
                end
            end
        end
    end
    
end

if process_group==1
    for going=1:filecounter
        directoryname=fnall{1,going};
        Path=fnall{2,going};
        sprintf('%s/%s',directoryname, Path)
        [glia_counts, combinedmap,labeledImageR,blobMeasurementsR,map]=glial_detection(directoryname, Path);
    end
else
    
    [glia_counts, combinedmap,labeledImageR,blobMeasurementsR,map]=glial_detection(directoryname, Path);

end