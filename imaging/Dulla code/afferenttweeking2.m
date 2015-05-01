for i=1:size(unnamed,1)
   unnamed(i,8)=unnamed(i,1)-unnamed(i,2);
   
   if unnamed(i,8)>0
       unnamed(i,9)=unnamed(i,2)-unnamed(i,3);
       unnamed(i,10)=unnamed(i,2)-unnamed(i,5);
   else
       unnamed(i,9)=-(unnamed(i,2)-unnamed(i,3));
       unnamed(i,10)=-(unnamed(i,2)-unnamed(i,5));
   end
   
   unnamed(i,11)=unnamed(i,9)*unnamed(i,4);
   unnamed(i,12)=unnamed(i,10)*unnamed(i,6);
    
    
    
end