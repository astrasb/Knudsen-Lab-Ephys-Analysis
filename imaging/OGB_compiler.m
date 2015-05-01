%function[out] = OGB(files)

i = 1;
for x = files
    swp{i} = load([num2str(x), '.tif delta F spots timecourse.mat']);
    i = i+1;
end    


tms = 0;
dF = zeros(1, size(swp{1}.dFspot, 2));
for x = 1:size(swp, 2)
   stims(x) = swp{x}.stimtime(1) + tms(end);
   tms = [tms; swp{x}.tms+tms(end)];
   dF = [dF; swp{x}.dFspot];
   dfm(x, :) = mean(swp{x}.dFspot');
   t = swp{x}.tms;
   leg{x} = ['file #', num2str(files(x))];
   ev_tms = find(swp{x}.tms > swp{x}.stimtime(1) & swp{x}.tms < swp{x}.stimtime(1)+.4);
   mn_dF(x) = mean(mean(swp{x}.dFspot(ev_tms, :)));
   
    
end
figure, hold on
plot(t, dfm'); 
legend(leg); xlabel('time (s)'); ylabel('dF/F');
line([stims(1) stims(1)], [-1 0], 'color', 'k')


figure, 
subplot(2, 2, 1:2); plot(tms, mean(dF')); hold on, 
for x = 1:size(swp, 2)
    line([stims(x) stims(x)], [0 .25*max(max(dF))], 'color', 'k');
end

subplot(2, 2, 3:4), plot(mn_dF); xlabel('sweep'); ylabel('evoked dF/F')
