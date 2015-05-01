%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Multiple 1-way ANOVAs Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ci=1:size(Contra,2)
Contra_adjust(:,ci)=Contra(:,ci)-mean(Contra(1:24,ci));
    
end

for fi=1:size(FL,2)
FL_adjust(:,fi)=FL(:,fi)-mean(FL(1:24,fi));
    
end

for si=1:size(Sham,2)
Sham_adjust(:,si)=Sham(:,si)-mean(Sham(1:24,si));
    
end

for i=1:size(Contra_Flipped,2)
   input(1,:)=Contra_Flipped(:,i);
   input(2,:)=Sham_Flipped(:,i);
   input(3,:)=FL_Flipped(:,i);
    
   
   
   input=input';
    [p, tbl, stats]=anova1(input);
    close
    sig(1,i)=i;
    sig(2,i)=tbl{2,6};
    sig(3,i)=0.05;
    
    tt=multcompare(stats, 'ctype','bonferroni')
    close
    if 1>2
    if tt(1,4)>0
        sig(4,i)=0;
    else
        sig(4,i)=1;
    end
    
    if tt(2,4)>0
        sig(5,i)=0;
    else
        sig(5,i)=1;
    end
        
    if tt(3,4)>0
        sig(6,i)=0;
    else
        sig(6,i)=1;
    end
    end


    
    
    if 1<2
    sig(4:5,i)=tt(1,4:5);
    sig(6:7,i)=tt(2,4:5);
    sig(8:9,i)=tt(3,4:5);
    sig(10,i)=0;
    end
    clear input;
end
