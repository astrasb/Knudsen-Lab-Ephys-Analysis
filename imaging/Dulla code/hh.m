X = rand(20,1);
jump = 5;
Cont = 1;
t = 1;
while(Cont)
    
if (X(t) > 0.5)
    
    [t , X(t)]
  if ( t < length(X) - jump)
    t = t+ jump -1;
  end
  
end


t = t+1
    
if (t >= length(X))
    Cont = 0;
end


end

