function strval=search_val(f,t,n)
ch=0;
i=1;
notfound=1;
firstfound=1;
ft=fopen(f);
qo='"';
%assume that you won't run out of file her
for frames=1:n
notfound=1;
firstfound=1;
clear ch_ar;
i=1;
while notfound; 
    while firstfound
        ch=fscanf(ft,'%c',1);
        firstfound=ch ~= t(1);
    end

    stl=length(t);
    fileloc=ftell(ft);
    ch2=fscanf(ft,'%c',stl-1);
    if strcmp(([ch ch2]),t)
        %grab the time value
        ch=0;
        chk=0;
        while ch ~= qo
            ch=fscanf(ft,'%c',1);
            %uint8(ch)
            if ch == qo
                while chk~=qo
                chk=fscanf(ft,'%c',1);
                    if chk ~= qo
                        ch_ar(i)=chk;
                        i=i+1;
                    end
                   
                end
            end
        end
        floatval(frames)=sscanf(char(ch_ar),'%f');
        notfound=0;
        clear ch_ar;
    else
        fseek(ft,fileloc+1,'bof');
        
    end
end
end
strval=floatval;
end
