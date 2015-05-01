function [PureBlueColorTable]=CreatePureBlueColorTable_0;
        PaletteSize=2^8;
        %Table Goes R, G, B for the third dimension
        
        for i=1:PaletteSize
            RGBCustom(i,1)=0;
            RGBCustom(i,2)=1-i/PaletteSize;
            RGBCustom(i,3)=1;
        end
        RGBCustom(1,1:3)=1;
        PureBlueColorTable=RGBCustom;
end