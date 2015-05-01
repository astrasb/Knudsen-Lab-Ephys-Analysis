function [RedColorTable]=CreatePureRedColorTable;
        PaletteSize=2^8;
        %Table Goes R, G, B for the third dimension
        
        for i=1:PaletteSize
            RGBCustom(i,1)=1;
            RGBCustom(i,2)=.5-(i/PaletteSize)/2;
            RGBCustom(i,3)=.5-(i/PaletteSize)/2;
        end
        
        RedColorTable=RGBCustom;
end