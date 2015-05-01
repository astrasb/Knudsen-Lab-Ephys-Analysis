function [data_out]=ProjectSecondGaussianFromDoubleGaussianCoeefs(x_range,coeff)
a=coeff.a2;
b=coeff.b2;
c=coeff.c2;

for i=1:x_range
    
    data_out(i)=a*exp(-((i-b)/c)^2);

end
end