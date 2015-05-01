filename1=input('Open file: ', 's');

for seq=10:31
filename=sprintf('%s_00%d', filename1, seq);
[Done]=openHighSpeedRedShirtSequence(filename);
disp ('FILE DONE');
disp ('');
end
