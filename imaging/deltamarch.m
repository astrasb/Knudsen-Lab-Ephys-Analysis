% This program generates a deltaf over f by depicting the difference between
% the baseline pixel value and mean pixel value for a time window defined by the user for
% all pixels in the pictures. This program depends on imageproc_streampix
% to run.

%ab = input('Enter the number of seconds over which the movie was collected: ');
%c = input('Enter the number of frames you want between the two running averages');
%srate = length(yy)/ab; %Gives sampling rate in images per second
%xax = 0:1/srate:ab-1/srate; %defines the x axis
n = 3 %This is the number of frames the program averages.
numd5 = floor(number/n);

% timepointspercycle=floor(srate*stimperiod);
%numberofcycles=1

xsize=size(x);

i=1;
    for z = 1:n;
        framesbefore(:,:,i)=x(:,:,z);
        i = i+1;
    end

    beforeave = double(framesbefore);
%     beforeave =double(beforeave);
    sumbefore = sum(beforeave,3);
    sumbefore = sumbefore./n;
    beforeaverage = sumbefore;
    
for jj = (n+1):number-n; %For the total number of images minus n
    i=1;
    for z = jj:jj+(n-1); %Puts n frames in order
        framesafter(:,:,i)=x(:,:,z);
        i = i+1;
    end

    afterave = double(framesafter);
%     afterave =double(afterave);
    sumafter = sum(afterave,3);
    sumafter = sumafter./n;
    afteraverage = sumafter;
    
    divfactor = 6000; %Was 6000 3-24-09
    delta = afteraverage-beforeaverage;
    overf = divfactor*(delta./beforeaverage);
    overf = uint8(overf);
    ir = jj;
    ir = num2str(ir);
    if jj < 10;
        ir = ['00' ir];
    elseif 9 < jj && jj < 100;
        ir = ['0' ir];
    end
    frame = num2str(ir);
    titler = ['movie',filename,frame,'.tif'];
    imwrite(overf,titler,'tif','Compression','none');
end


