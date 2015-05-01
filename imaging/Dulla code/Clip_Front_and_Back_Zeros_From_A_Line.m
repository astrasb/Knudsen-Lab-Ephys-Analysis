function [outline]=Clip_Front_and_Back_Zeros_From_A_Line(line);
exit=0;  
  startclip=1;
  for i=1:size(line,2)
      if exit==0  
      if line(1,i)==0
          startclip=startclip+1;
      else
          exit=1;
      end
      end
  end
  
  endclip=1;
  exit=0;
    for i=1:size(line,2)
      if exit==0  
      if line(1,size(line,2)-i+1)==0
          endclip=endclip+1;
      else
          exit=1;
      end
      end
  outline=line(startclip:size(line,2)-endclip-1);
    end