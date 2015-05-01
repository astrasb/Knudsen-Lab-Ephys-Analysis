% This program generates a deltaf over f by depicting the difference between
% the baseline pixel value and mean pixel value for a time window defined by the user for
% all pixels in the pictures. This program depends on imageproc_streampix
% to run.

%ab = input('Enter the number of seconds over which the movie was collected: ');
%c = input('Enter the number of frames you want between the two running averages');
%srate = length(yy)/ab; %Gives sampling rate in images per second
%xax = 0:1/srate:ab-1/srate; %defines the x axis
n = 3
numd5 = floor(number/n);
% timepointspercycle=floor(srate*stimperiod);
%numberofcycles=1

xsize=size(x);

for jj = 1:number-15;

    i=1;
    for z = jj:jj+4;
        framesbefore(:,:,i)=x(:,:,z);
        i = i+1;
    end

    beforeave = double(framesbefore);
    beforeave =double(beforeave);
    sumbefore = sum(beforeave,3);
    sumbefore = sumbefore./5;
    beforeaverage = sumbefore;%round(sumbefore) removed

    i=1;
    for z = jj+10:jj+14;
        framesafter(:,:,i)=x(:,:,z);
        i = i+1;
    end

    afterave = double(framesafter);
    afterave =double(afterave);
    sumafter = sum(afterave,3);
    sumafter = sumafter./5;
    afteraverage = sumafter; %round(sumafter) removed
    multfactor = 5000; %was 5000
    delta = afteraverage-beforeaverage;
    overfb4 = multfactor*(delta./beforeaverage);
    overf = uint8(overfb4);
    ir = jj;
    ir = num2str(ir);
    if jj < 10;
        ir = ['00' ir];
    elseif 9 < jj && jj < 100;
        ir = ['0' ir];
    end
    frame = num2str(ir);
    titler = ['movie',filename,frame,'.jpg'];
    imwrite(overf,titler,'jpg');
    % moviemat(:,:,jj)=uint8(overf);

    % i = figure;
    % image(overf);
end
