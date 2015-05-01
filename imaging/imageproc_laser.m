%This program will be used to load images into 

n= [];
filename = input('Enter the name of the image files (before the numbers): ','s');
number = input('Enter the number of image files to be processed: ');
firstframe = input('Enter the first frame of the laser pulse: ');
lastframe = input('Enter the last frame of the first laser pulse: ');
%ap = input('Enter the number of the first image to be processed (eg, if the image is 0706180137, enter 137): ');
ap=1;

w = cell(1,number);

if number > 999;
    for j = ap:(number);
        jj = num2str(j);
        if j <10;
            n = ['000' jj];
        elseif 9 < j && j < 100;
            n = ['00' jj];
        elseif 99 < j && j < 1000;
            n = ['0' jj];
        elseif j > 999;
            n = jj;
        end
        w{j-(ap-1)} = imread([filename n '.tif']);
    end
elseif 99 < number 
    for j = ap:(number);
        jj = num2str(j);
        if j <10;
            n = ['00' jj];
        elseif 9 < j && j < 100;
            n = ['0' jj];
        elseif j > 99;
            n = jj;
        end
        w{j-(ap-1)} = imread([filename n '.tif']);
    end
else
    for j = ap:(number);
        jj = num2str(j);
        if j <10;
            n = ['0' jj];
        elseif j > 9;
            n = jj;
        end
        w{j-(ap-1)} = imread([filename n '.tif']);
    end
end

for i = 1:firstframe-1;
    xa(:,:,i) = w{i};
end
for i = lastframe+1:number;
    yar(:,:,i-lastframe) = w{i};
end
x = cat(3,xa,yar);

%Added yy
sizeofmatrix=size(x);
%ab = input('Enter the number of seconds over which the movie was collected: ');
%srate = sizeofmatrix(3)/ab; %Gives sampling rate in images per second
for xvalue = 1:sizeofmatrix(1)
    for yvalue = 1:sizeofmatrix(2)
        y = x(xvalue,yvalue,:);
            for i = 1:length(y)
                yy(i) = y(i);         
            end
            % filter out quenching 
            %regcoeff=polyfit(xax,single(yy),3);
            %regfunction=polyval(regcoeff,xax);
            %newsignal=single(yy)-regfunction;
            
            % high-pass filter of data
             % [b,a] = buttfilt(5, 0.05/(srate/2), 'high');
%             highpassfilteredtimecourse = filtfilt_filt(b,a,single(yy));
%             
%             % Fourier analysis
%             powerofsignal=abs(fft(highpassfilteredtimecourse));
%             poweratstimfreq(xvalue,yvalue)=mean(powerofsignal(freqrangevector));
    end 
end

