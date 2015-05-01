function [BW_RGBCustom_inverted]=CreateBW_RGBColorTable_inverted;
        PaletteSize=256;
        Saturated=PaletteSize-1;
        BW_Size=PaletteSize/2;
        RGB_Size=PaletteSize/2;
        RGB_QuadrantSize=(RGB_Size)/4;
        BW_PaletteStepSize=1/BW_Size
        RGB_PaletteStepSize= 8;
        RGBCustom=zeros(PaletteSize, 3);
        %Table Goes R, G, B for the third dimension
        
        for i=1:BW_Size
            RGBCustom(i,1)=i*BW_PaletteStepSize;
            RGBCustom(i,2)=i*BW_PaletteStepSize;
            RGBCustom(i,3)=i*BW_PaletteStepSize;
        end
        
        
        for i=1:RGB_QuadrantSize
            RGBCustom(i+BW_Size,1)=0/255;
            RGBCustom(i+BW_Size,2)=((i-1)*RGB_PaletteStepSize)/255;
            RGBCustom(i+BW_Size,3)=Saturated/255;
        end
        
        for i=RGB_QuadrantSize+1:2*RGB_QuadrantSize
            RGBCustom(i+BW_Size,1)=0/255;
            RGBCustom(i+BW_Size,2)=Saturated/255;
            RGBCustom(i+BW_Size,3)=((RGB_QuadrantSize*2-i)*RGB_PaletteStepSize)/255;
        end
        
        for i=RGB_QuadrantSize*2+1:3*RGB_QuadrantSize
            RGBCustom(i+BW_Size,1)=((i-RGB_QuadrantSize*2)*RGB_PaletteStepSize-1)/255;
            RGBCustom(i+BW_Size,2)=Saturated/255;
            RGBCustom(i+BW_Size,3)=0/255;
        end
        
        
        for i=RGB_QuadrantSize*3+1:4*RGB_QuadrantSize
            RGBCustom(i+BW_Size,1)=Saturated/255;
            RGBCustom(i+BW_Size,2)=0/255;
            RGBCustom(i+BW_Size,3)=(RGB_QuadrantSize*4-i)*RGB_PaletteStepSize/255;
        end
        
        %%%% Underexposed ColorMap
        RGBCustom(1,1)=0;
        RGBCustom(1,2)=0;
        RGBCustom(1,3)=0;
        
        %%%% Overexposed ColorMap
        RGBCustom(Saturated+1,1)=Saturated/255;
        RGBCustom(Saturated+1,2)=Saturated/255;
        RGBCustom(Saturated+1,3)=Saturated/255;
        BW_RGBCustom_inverted=RGBCustom;
end
        