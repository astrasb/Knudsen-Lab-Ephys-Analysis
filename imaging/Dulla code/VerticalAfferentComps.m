for i=1:size(Profile_otherDir_I,1)
out(i,:)=smooth(smooth(Profile_otherDir_I(i,:)));


end
[val loc]=min(out');
