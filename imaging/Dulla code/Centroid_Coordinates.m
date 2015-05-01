function[Centroid_Coordinates]=Centroid_Coordinates(CellArrayImages, exposure,directoryname,filename, ThisThreshold );
tempimage=CellArrayImages{exposure};
Frames=size(tempimage,3);
Height=size(tempimage,2);
Width=size(tempimage,1);
Centroid_Coordinates=zeros(2,Frames);


    for thisframe=1:Frames
   
        counter=0;
        W_value=0;
        H_value=0;
        intensitycounter=0;
        for w_coord=1:Width
            for h_coord=1:Height
                intensity=tempimage(w_coord,h_coord,thisframe);
                if intensity==0
                test=0;
                else
                signal=2-intensity;
                intensitycounter=intensitycounter+signal;
                W_value=W_value+w_coord*signal;
                H_value=H_value+h_coord*signal;
                end
                
                end
        end
       
        if W_value==0
        Centroid_Coordinates(2,thisframe)=0;
        Centroid_Coordinates(1,thisframe)=0; 
        else
        Centroid_Coordinates(1,thisframe)=W_value/intensitycounter;
        Centroid_Coordinates(2,thisframe)=H_value/intensitycounter; 
        end
    end
    replacedmat='.mat';  %works if the file is in the current directory 
    replacedda='.da';
    filenumber=filename(size(filename,2)-4:size(filename,2)-3);
    filedirectory=sprintf('%s/%s', directoryname, filenumber);
   %filenamemat=sprintf('%s/centroid_%d/%s', filedirectory, ThisThreshold, filename);
   filenamemat=sprintf('%s/Centroid_%d_%s', directoryname,ThisThreshold, filename);
   %filenamemat1=sprintf('%s/centroid_%d/%s', filedirectory, ThisThreshold);
   %mkdir(filenamemat1);
   filenamemat=strrep(filenamemat,replacedda,replacedmat);
   filenamemat1=strrep(filenamemat,replacedda,replacedmat);
   
   save (filenamemat, 'Centroid_Coordinates');
    
    end
