for i=1:14
    
    
   this_map=squeeze(FL2C(i,:,:));
   %FL_locs=tboaLocs(1,i);
   [trash FL_locs]=min(mean(this_map));
   left_pad=zeros(64, 200-FL_locs);
   combined=[left_pad this_map] ;
   right_pad=zeros(64, 400-size(combined,2));
   combined=[combined right_pad];
   horizr(i,:)=mean(this_map);
   horizC(i,:)=mean(combined);
   vertC(i,:)=mean(combined(:,180:200)');
   all_map_C(i,:,:)=combined;
   %ave_map_C=ave_map_C+combined; 
end