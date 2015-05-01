function [BlueColorTable]=CreateBlueColorTable;
        PaletteSize=2^8;
        %Table Goes R, G, B for the third dimension
        
        for i=1:PaletteSize
            RGBCustom(i,1)=0;
            RGBCustom(i,2)=0;
            RGBCustom(i,3)=i/PaletteSize;
        end
        BlueColorTable=RGBCustom;
end