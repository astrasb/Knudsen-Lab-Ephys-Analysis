%test redshirtload
dfsubtract=1;
[Images,Width,Height,Frames,ts,td,df]=openredshirt('/mnt/striperaid/tempstorage/chris/2008_02_06_0030.da',dfsubtract);
figure (1)
plot(td(1,1:Frames), 'DisplayName', 'td(8,1:5000)', 'YDataSource', 'td(8,1:5000)'); figure(gcf)
figure(2)
image(Images(:,:,1),'CDataMapping','scaled');
figure(3)
image(Images(:,:,2),'CDataMapping','scaled');
figure(4)
image(Images(:,:,10),'CDataMapping','scaled');
LeftShift=1;
DownShift=1;
ReturnRatio=1;
[Ratio,Left,Right]=split(Images,LeftShift,DownShift,ReturnRatio);
figure(5)
image(Ratio(:,:,10),'CDataMapping','scaled');
figure(6)
image(Left(:,:,10),'CDataMapping','scaled');
figure(7)
image(Right(:,:,10),'CDataMapping','scaled');