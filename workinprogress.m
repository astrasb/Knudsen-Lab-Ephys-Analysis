
n=1;
m=1;
b=diff(smooth_timecourse);
for p=5:length(smooth_timecourse)-6
    if b(p-5:p)>0 & b(p+1:p+6)<0 %figure out how to make this: b(p+1:p+6)<0 give a single logical value.
        descending(n)=p;
        n=n+1;
    elseif b(p)<0 & b(p+1)>0
        ascending(m)=p;
        m=m+1;
    end
end

for q=numel(times)
end

 smooth_timecourse(i,:)=smoothME(timecourse(i,:),10,0.1); %smooth the trace with a 2.3 ssecond window this may be overfitting to this data..
 for m=1:imgno
     if m<round(imgno/10)
         movingwindow=smooth_timecourse(i,moveingwindow
 sortedtc = sort(timecourse(i, :)); %sort the trace by ascending values
    sortedtc = sortedtc(find(sortedtc > 0));    %find all nonzero values
    stcl = ceil(length(sortedtc)/5);   %select the 20% (nonzero) percentile
    cutoff(i) = std(sortedtc(1:stcl))*5+mean(sortedtc(1:stcl));

for m=1:imgno
    if m<round(imgno/10)
        movingavg=
    
     sortedtc = sort(smoothc(i, :)); %sort the trace by ascending values
    sortedtc = sortedtc(find(sortedtc > 0));    %find all nonzero values
    stcl = ceil(length(sortedtc)/5);   %select the 20% (nonzero) percentile
    cutoff(i) = std(sortedtc(1:stcl))*5+mean(sortedtc(1:stcl));
t_crossing{i} = (find(smoothc(i, :) > cutoff(i)));
ev_st{i} = t_crossing{i}(diff([0 t_crossing{i}]) > 2);%used to be 5 - figure out what this means... I think it's only count something as an event if it didn't cross threshold after 2 (or 5) frames.
    

[bl,al] = butter(4, 60/(4.35/2), 'low');

tempfull=smooth_timecourse(i,:)';
[bh,ah] = butter(4, .001/(4.35/2), 'high'); %usually 25
tempfull=filter(bh,ah,tempfull(end:-1:1));
tempfull=tempfull(end:-1:1);
plot(tempfull,'g');