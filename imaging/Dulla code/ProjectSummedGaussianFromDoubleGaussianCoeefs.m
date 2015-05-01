function [data_out]=ProjectSummedGaussianFromDoubleGaussianCoeefs(x_range,coeff)
a=coeff.a1;
b=coeff.b1;
c=coeff.c1;
a2=coeff.a2;
b2=coeff.b2;
c2=coeff.c2;

for i=1:x_range
    
    data_out(i)=a*exp(-((i-b)/c)^2)+a2*exp(-((i-b2)/c2)^2);

end
end