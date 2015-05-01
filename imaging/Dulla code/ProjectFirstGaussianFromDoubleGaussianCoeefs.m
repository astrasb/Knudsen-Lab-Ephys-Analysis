function [data_out]=ProjectFirstGaussianFromDoubleGaussianCoeefs(x_range,coeff)
a=coeff.a1;
b=coeff.b1;
c=coeff.c1;

for i=1:x_range
    
    data_out(i)=a*exp(-((i-b)/c)^2);

end