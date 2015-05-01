function [GreenColorTable]=CreateGreenColorTable;
        PaletteSize=2^12;
        %Table Goes R, G, B for the third dimension
        
        for i=1:PaletteSize
            RGBCustom(i,1)=0;
            RGBCustom(i,2)=i/PaletteSize;
            RGBCustom(i,3)=0;
        end
        GreenColorTable=RGBCustom;
end