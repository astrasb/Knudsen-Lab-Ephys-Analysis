function [RGBCustom]=CreateRGBColorTable;
        PaletteSize=256;
        Saturated=PaletteSize-1;
        QuadrantSize=(PaletteSize)/4;
        PaletteStepSize=PaletteSize/QuadrantSize;
        RGBCustom=zeros(QuadrantSize, 3);
        %Table Goes R, G, B for the third dimension
        
        for i=1:QuadrantSize
            RGBCustom(i,1)=0/255;
            RGBCustom(i,2)=((i-1)*PaletteStepSize)/255;
            RGBCustom(i,3)=Saturated/255;
        end
        
        for i=QuadrantSize+1:2*QuadrantSize
            RGBCustom(i,1)=0/255;
            RGBCustom(i,2)=Saturated/255;
            RGBCustom(i,3)=((QuadrantSize*2-i)*PaletteStepSize)/255;
        end
        
        for i=QuadrantSize*2+1:3*QuadrantSize
            RGBCustom(i,1)=((i-QuadrantSize*2)*PaletteStepSize-1)/255;
            RGBCustom(i,2)=Saturated/255;
            RGBCustom(i,3)=0/255;
        end
        
        
        for i=QuadrantSize*3+1:4*QuadrantSize
            RGBCustom(i,1)=Saturated/255;
            RGBCustom(i,2)=(QuadrantSize*4-i)*PaletteStepSize/255;
            RGBCustom(i,3)=0/255;
        end
        
        %%%% Underexposed ColorMap
        RGBCustom(1,1)=0;
        RGBCustom(1,2)=0;
        RGBCustom(1,3)=0;
        
        %%%% Overexposed ColorMap
        RGBCustom(Saturated+1,1)=Saturated/255;
        RGBCustom(Saturated+1,2)=Saturated/255;
        RGBCustom(Saturated+1,3)=Saturated/255;
end
        