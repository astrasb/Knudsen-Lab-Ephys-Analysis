%This program will be used to load images into 

n= [];
filename = input('Enter the name of the image files (before the numbers): ','s');
number = input('Enter the number of image files to be processed: ');
% ap = input('Enter the number of the first image to be processed (eg, if the image is 0706180137, enter 137)');
ap = 1;

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
elseif number < 999 && number > 99;
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
elseif number < 100;
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

for i = 1:length(w)
    x(:,:,i) = w{i};
end



