function [RedColorTable]=CreateRedColorTable;
        PaletteSize=2^12;
        %Table Goes R, G, B for the third dimension
        
        for i=1:PaletteSize
            RGBCustom(i,1)=i/PaletteSize;
            RGBCustom(i,2)=0;
            RGBCustom(i,3)=0;
        end
        RedColorTable=RGBCustom;
end