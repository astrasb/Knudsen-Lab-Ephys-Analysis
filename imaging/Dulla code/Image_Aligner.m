%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                    Image Aligner                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all


%%%%%%%%%%%%%%%% Selceting the first two images to register
begin = questdlg('Please select the first two images you would like to align', ...
    'Its time to align',...
    'Sure I would love to!','Sure I would love to!');

% Opening top most directory
[file1, path1] = uigetfile('/mnt/m022a/test_images/*.*','Pick your first file');
[file2, path2] = uigetfile(sprintf('%s*.*',path1),'Pick your second file');

%%%  Base is the starting image, unregistered is the new image
base=imread(sprintf('%s%s',path1,file1));
if size(base,3)>1
    base(:,:,2:3)=[];
end
unregistered=imread(sprintf('%s%s',path2,file2));
if size(unregistered,3)>1
    unregistered(:,:,2:3)=[];
end
%%% happy variable lets you redo the alignment if you don't like it
happy = 0;
counter=1;
while happy==0
    
    %%% Plot the image
    top=subplot(2,1,1)
    imshow(base)
    bottom=subplot(2,1,2)
    imshow(unregistered)
    
    %%% Select the features
    begin = questdlg('Please select the feature in the top image that you can use for alignment', ...
        'Picking a feature in the top image ',...
        'Fantastic!','Fantastic!');
    tophandle=impoint(top);
    top_coords=getPosition(tophandle);
    begin = questdlg('Now find that same feature in image 2', ...
        'Picking a feature in the bottom image ',...
        'Lets see if I can find it','Lets see if I can find it');
    bottomhandle=impoint(bottom);
    
    %%% Coordinates of the chosen features
    
    bot_coords=getPosition(bottomhandle);
    
    %%% Get the offset factors
    
    L_R_OffsetFactor=floor(top_coords(1,1)-bot_coords(1,1));
    L_R_Cut=size(base,2)-abs(L_R_OffsetFactor);
    U_D_OffsetFactor=floor(top_coords(1,2)-bot_coords(1,2));
    U_D_Cut=size(base,1)-(abs(U_D_OffsetFactor));
    
    % Create buffer padz for cook image translocation
    L_R_Pad=zeros(size(base,1),abs(L_R_OffsetFactor));
    
    % Make the adjustments
    
    %%% Adjust Left Right orientation
    
        %%%  Case 1 for LR
        if L_R_OffsetFactor>0
            %%% Case 1 for UD
            if U_D_OffsetFactor>0
                %%% Placing I1 on top
                I1=[base L_R_Pad ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1=[I1;U_D_Pad];
                
                Itemp=unregistered;
                Itemp(1:U_D_Cut, 1:L_R_Cut)=0;
                
                I2=[L_R_Pad Itemp ];
                I2=[U_D_Pad; I2];
                out = I1+I2;
                %%% Placing I2 on top
                I1P=[base L_R_Pad];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1P,2));
                I1P=[I1P;U_D_Pad];
                
                ItempP=unregistered;
                I2P=[L_R_Pad ItempP];
                I2P=[U_D_Pad; I2P];
                I1P(U_D_OffsetFactor:size(I1P,1), L_R_OffsetFactor+1:size(I1P,2))=0;
                
                
                outP=I1P+I2P;
            else
                %%% Case 2 for UD
                %%% Placing I1 on top
                I1=[base L_R_Pad ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1=[U_D_Pad; I1];
                Itemp=unregistered;
                Itemp(U_D_Cut:size(Itemp,1),1:L_R_Cut)=0;
                
                I2=[L_R_Pad Itemp ];
                I2=[I2; U_D_Pad ];
                out=I1+I2;
                
                %%% Placing I2 on top                
                I1P=[base L_R_Pad];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1P=[U_D_Pad; I1P];
                ItempP=unregistered;
                I1P(abs(U_D_OffsetFactor):2*abs(U_D_OffsetFactor), L_R_OffsetFactor+1:size(I1P,2))=0;
                I2P=[L_R_Pad ItempP];
                I2P=[I2P; U_D_Pad ];
                outP=I1P+I2P;
            end
            
            
            %%% Case 2 for LR
        else
            %%% Case 1 for UD
            if U_D_OffsetFactor>0
                %%% Placing I1 on top
                I1=[L_R_Pad base ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1=[I1;U_D_Pad];
                
                Itemp=unregistered;
                Itemp(1:U_D_Cut, L_R_Cut:size(Itemp,2))=0;
                
                I2=[Itemp L_R_Pad  ];
                I2=[U_D_Pad; I2];
                out = I1+I2;
                %%% Placing I2 on top
                I1P=[ L_R_Pad base];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1P,2));
                I1P=[I1P;U_D_Pad];
                
                ItempP=unregistered;
                I2P=[ItempP L_R_Pad];
                I2P=[U_D_Pad; I2P];
                I1P(U_D_OffsetFactor:size(I1P,1),abs(L_R_OffsetFactor):2*abs(L_R_OffsetFactor))=0;
               
                
                outP=I1P+I2P;
            else
                %%% Case 2 for UD
                %%% Placing I1 on top
                I1=[L_R_Pad base ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1=[U_D_Pad; I1];
                Itemp=unregistered;
                Itemp(abs(U_D_OffsetFactor):size(Itemp,1),L_R_Cut:size(Itemp,2))=0;
                I2=[Itemp L_R_Pad  ];
                I2=[I2; U_D_Pad ];
                out=I1+I2;
                
                %%% Placing I2 on top                
                I1P=[L_R_Pad base ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1P=[U_D_Pad; I1P];
                ItempP=unregistered;
                I1P(abs(U_D_OffsetFactor):2*abs(U_D_OffsetFactor), abs(L_R_OffsetFactor):2*abs(L_R_OffsetFactor))=0;
                I2P=[ItempP L_R_Pad ];
                I2P=[I2P; U_D_Pad ];
                outP=I1P+I2P;
            end 
            
            
        end
    
    

    top=subplot(2,1,1)
    imshow(out)
    bottom=subplot(2,1,2)
    imshow(outP)
    % Construct a questdlg to ask if your happ with the alignment
    choice = questdlg('Are you happy with the alignment?', ...
        'Good Enough for You?', ...
        'Yes','No, lets do that over again','');
    % Handle response
    switch choice
        case 'Yes'
            happy = 1;
            
        case 'No, lets do that over again'
            damn = 1;
            
    end
    
    
    %%% end happy loop
end
% Pick the best looking overlay
choice = questdlg('Which image do you like better?', ...
    'Pick the best image', ...
    'Top is better','Bottom is better','');
% Handle response
switch choice
    case 'Top is better'
        compiled = out;
        
    case 'Bottom is better'
        compiled = outP;
        
end

image_transformations(counter,1)=L_R_OffsetFactor;
image_transformations(counter,2)=L_R_Cut;
image_transformations(counter,3)=U_D_OffsetFactor;
image_transformations(counter,4)=U_D_Cut;
% Choose to add another image if you want to
choice = questdlg('Would you like to add another image?', ...
    'Care to add another image?', ...
    'Yes please','No thank you','Yes please');
% Handle response
switch choice
    case 'Yes please'
        again = 1;
        
    case 'No thank you'
        again = 0;
        
end

happy = 0;

%%% Again lets you add more images
while again==1
    happy = 0;
    %%% Happy lets you redo the alignment
    while happy==0
        [filen, pathn] = uigetfile(sprintf('%s*.*',path1),'Pick your next file');
        
        
        unregistered=imread(sprintf('%s%s',pathn,filen));
        if size(unregistered,3)>1
            unregistered(:,:,2:3)=[];
        end
        
        top=subplot(2,1,1)
        imshow(compiled)
        bottom=subplot(2,1,2)
        imshow(unregistered)
        
        begin = questdlg('Please select the feature in the top image that you can use for alignment', ...
            'Picking a feature in the top image ',...
            'Fantastic!','Fantastic!');
        tophandle=impoint(top);
        top_coords=getPosition(tophandle);
        begin = questdlg('Now find that same feature in image 2', ...
            'Picking a feature in the bottom image ',...
            'Lets see if I can find it','Lets see if I can find it');
        bottomhandle=impoint(bottom);
        bot_coords=getPosition(bottomhandle);
        
        L_R_OffsetFactor=abs(floor(top_coords(1,1)-bot_coords(1,1)));
        L_R_Cut=abs(size(compiled,2)-L_R_OffsetFactor);
        U_D_OffsetFactor=abs(floor(top_coords(1,2)-bot_coords(1,2)));
        U_D_Cut=abs(size(compiled,1)-(abs(U_D_OffsetFactor)));
    
    % Create buffer padz for cook image translocation
    L_R_Pad=zeros(size(compiled,1),abs(L_R_OffsetFactor));
        
        
        
        % Make the adjustments
    
    %%% Adjust Left Right orientation
    
        %%%  Case 1 for LR
        if L_R_OffsetFactor>0
            %%% Case 1 for UD
            if U_D_OffsetFactor>0
                %%% Placing I1 on top
                I1=[L_R_Pad compiled  ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1=[I1;U_D_Pad];
                
                Itemp=unregistered;
                Itemp(1:size(Itemp,1)-L_R_OffsetFactor, floor(bot_coords(1,1)):size(Itemp,2) )=0;
                
                side_pad=zeros(size(Itemp,1), size(I1,2)-size(Itemp,2));
                
                I2=[ Itemp side_pad];
                is_odd=mod(size(I1,1)-size(I2,1),2)~=0;
                
             
                top_pad= zeros(floor((size(I1,1)-size(I2,1))/2),size(I2,2));
                bottom_pad= zeros(ceil((size(I1,1)-size(I2,1))/2),size(I2,2));
                I2=[top_pad; I2; bottom_pad];
                    
              
                out = I1+I2;
                %%% Placing I2 on top
                I1P=[L_R_Pad compiled  ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1P=[I1P;U_D_Pad];
                
                ItempP=unregistered;
                I1P(size(top_pad,1):size(top_pad,1)+size(ItempP,2),1:size(ItempP,1) )=0;
                
                side_pad=zeros(size(ItempP,1), size(I1,2)-size(ItempP,2));
                
                I2P=[ ItempP side_pad];
                is_odd=mod(size(I1,1)-size(I2,1),2)~=0;
                
              
                top_pad= zeros(floor((size(I1P,1)-size(I2P,1))/2),size(I2P,2));
                bottom_pad= zeros(ceil((size(I1P,1)-size(I2P,1))/2),size(I2P,2));
                I2P=[top_pad; I2P; bottom_pad];
                    
                
                outP = I1P+I2P;
            else
                %%% Case 2 for UD
                %%% Placing I1 on top
                I1=[compiled L_R_Pad ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1=[U_D_Pad; I1];
                Itemp=unregistered;
                Itemp(U_D_Cut:size(Itemp,1),1:L_R_Cut)=0;
                
                I2=[L_R_Pad Itemp ];
                I2=[I2; U_D_Pad ];
                out=I1+I2;
                
                %%% Placing I2 on top                
                I1P=[compiled L_R_Pad];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1P=[U_D_Pad; I1P];
                ItempP=unregistered;
                I1P(abs(U_D_OffsetFactor):2*abs(U_D_OffsetFactor), L_R_OffsetFactor+1:size(I1P,2))=0;
                I2P=[L_R_Pad ItempP];
                I2P=[I2P; U_D_Pad ];
                outP=I1P+I2P;
            end
            
            
            %%% Case 2 for LR
        else
            %%% Case 1 for UD
            if U_D_OffsetFactor>0
                %%% Placing I1 on top
                I1=[L_R_Pad compiled ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1=[I1;U_D_Pad];
                
                Itemp=unregistered;
                Itemp(1:U_D_Cut, L_R_Cut:size(Itemp,2))=0;
                
                I2=[Itemp L_R_Pad  ];
                I2=[U_D_Pad; I2];
                out = I1+I2;
                %%% Placing I2 on top
                I1P=[ L_R_Pad compiled];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1P,2));
                I1P=[I1P;U_D_Pad];
                
                ItempP=unregistered;
                I2P=[ItempP L_R_Pad];
                I2P=[U_D_Pad; I2P];
                I1P(U_D_OffsetFactor:size(I1P,1),abs(L_R_OffsetFactor):2*abs(L_R_OffsetFactor))=0;
               
                
                outP=I1P+I2P;
            else
                %%% Case 2 for UD
                %%% Placing I1 on top
                I1=[L_R_Pad compiled ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1=[U_D_Pad; I1];
                Itemp=unregistered;
                Itemp(abs(U_D_OffsetFactor):size(Itemp,1),L_R_Cut:size(Itemp,2))=0;
                I2=[Itemp L_R_Pad  ];
                I2=[I2; U_D_Pad ];
                out=I1+I2;
                
                %%% Placing I2 on top                
                I1P=[L_R_Pad compiled ];
                U_D_Pad=zeros(abs(U_D_OffsetFactor),size(I1,2));
                I1P=[U_D_Pad; I1P];
                ItempP=unregistered;
                I1P(abs(U_D_OffsetFactor):2*abs(U_D_OffsetFactor), abs(L_R_OffsetFactor):2*abs(L_R_OffsetFactor))=0;
                I2P=[ItempP L_R_Pad ];
                I2P=[I2P; U_D_Pad ];
                outP=I1P+I2P;
            end 
            
            
        end
    
    

    top=subplot(2,1,1)
    imshow(out)
    bottom=subplot(2,1,2)
    imshow(outP)
    % Construct a questdlg to ask if your happ with the alignment
    choice = questdlg('Are you happy with the alignment?', ...
        'Good Enough for You?', ...
        'Yes','No, lets do that over again','');
    % Handle response
    switch choice
        case 'Yes'
            happy = 1;
            
        case 'No, lets do that over again'
            damn = 1;
            
    end
    
    
    %%% end happy loop
end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        if 2>10
        % Create buffer padz for cook image translocation
        L_R_Pad_compiled=zeros(size(compiled,1),size(unregistered,2)-L_R_Cut);
        L_R_Pad_new=zeros(size(compiled,1),size(compiled,2)-L_R_Cut);
        if L_R_OffsetFactor~=0
            if L_R_OffsetFactor>0
                I1=[compiled L_R_Pad_compiled ];
                Itemp=unregistered;
                Itemp(:, 1:L_R_Cut)=0;
                I2=[L_R_Pad_new Itemp ];
                out=I1+I2;
                
                I1P=[compiled L_R_Pad_compiled];
                ItempP=unregistered;
                I1P(:, L_R_OffsetFactor+1:size(I1P,2))=0;
                I2P=[L_R_Pad_new ItempP];
                outP=I1P+I2P;
                
            else
                I1=[unregistered L_R_Pad_compiled ];
                Itemp=compiled;
                Itemp(:, 1:L_R_Cut)=0;
                I2=[L_R_Pad_new Itemp ];
                out=I1+I2;
                
                I1P=[unregistered L_R_Pad_compiled];
                ItempP=compiled;
                I1P(:, L_R_OffsetFactor+1:size(I1P,2))=0;
                I2P=[L_R_Pad_new ItempP];
                outP=I1P+I2P;
                
                
            end
        end
        
        if 2>3
            if U_D_OffsetFactor~=0
                if U_D_OffsetFactor>0
                    U_D_Pad=zeros(abs(U_D_OffsetFactor),size(cookcam_scaled,2));
                    cookcam_scaled=[U_D_Pad; cookcam_scaled];
                else
                    U_D_Pad=zeros(abs(U_D_OffsetFactor),size(Andor,2), size(Andor,3));
                    Andor=[U_D_Pad; Andor];
                end
            end
        end
        
        top=subplot(2,1,1)
        imshow(out)
        bottom=subplot(2,1,2)
        imshow(outP)
        
        % Construct a questdlg to ask if your happ with the alignment
        choice = questdlg('Are you happy with the alignment?', ...
            'Good Enough for You?', ...
            'Yes','No, lets do that over again','');
        % Handle response
        switch choice
            case 'Yes'
                happy = 1;
                counter=counter+1;
                image_transformations(counter,1)=L_R_OffsetFactor;
                image_transformations(counter,2)=L_R_Cut;
                image_transformations(counter,2)=U_D_OffsetFactor;
            case 'No, lets do that over again'
                damn = 1;
                
        end
        %%%% End Happy Loop
    end
    % Construct a questdlg with three options
    choice = questdlg('Which image do you like better?', ...
        'Pick the best image', ...
        'Top is better','Bottom is better','');
    % Handle response
    switch choice
        case 'Top is better'
            compiled = out;
            
        case 'Bottom is better'
            compiled = outP;
            
    end
    
    % Construct a questdlg with three options
    choice = questdlg('Would you like to add another image?', ...
        'Care to add another image?', ...
        'Yes please','No thank you','Yes please');
    % Handle response
    switch choice
        case 'Yes please'
            again = 1;
            
        case 'No thank you'
            again = 0;
            
    end


    %%% End again loop
end
 