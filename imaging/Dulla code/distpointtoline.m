function [height]=distpointtoline(x1,y1,x2,y2,x3,y3)
%http://www.worsleyschool.net/science/files/linepoint/method3.html
area=(1/2)*abs(x1*y2 + x2*y3 + x3*y1 - x2*y1 - x3*y2 - x1*y3);
base=sqrt((x1-x2)^2+(y1-y2)^2);
height=area/(1/2*base);
end
