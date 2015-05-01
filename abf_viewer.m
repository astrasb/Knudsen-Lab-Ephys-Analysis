%[trace filename] = abf_viewer(filename)

if exist('filename') == 0;
% Open file
clear
    get_filename; 
    [trace dt] = abfload(filename);
    ch_no = length(trace(1, :));
swpl = length(trace(:, 1));
sfq = 1/(dt*1e-6); 

end


ch = 1;

%scrsz = [10 100 1200 920];
 %  figure, set(gcf, 'Position', scrsz, 'Name', filename, 'WindowStyle', 'docked');
figure,

for sbp = 1:4
    ax(sbp) = subplot(2, 2, sbp); plot((1:swpl)/sfq, trace(:, ch)); xlabel ('sec'); ylabel('uV')
end

set(gcf, 'WindowStyle', 'docked')
linkaxes(ax,'y')
zoom xon

sbp = 1;
set(subplot(2, 2, sbp), 'Color', [0.8 1 0.8])

x = 1;

disp(' ')
disp('Type Select plot,  Next, Before, In (y-axis), Out (y-axis),')
disp( '  Enter (time window, single), Enter All (time window, all panels), Play oscillation')
disp( ' ')


while x ~= 0
    
    
    x = input('Enter command -->   ', 's');
    
    if isempty(x)
       % disp('no command entered.')
        x = 'qqq';
     end
    subplot(2, 2, sbp)
    xlimits = get(gca, 'xlim');
    ylimits = get(gca, 'ylim');

     
    switch x
        
    case {'0'}
            x = 0;
            disp('.. boink! program terminated...')
        
    case {'ea'}  %Enter in the time window desired
        xdistance = (xlimits(2)-xlimits(1));
        new_xlimits = input('Enter time window desired [w1start w1end; w2start w2end; w3...] --> ');
        
        for sbpl = 1:length(new_xlimits(:, 1))
            set(subplot(2, 2, sbpl), 'xlim', [new_xlimits(sbpl, :)])
        end
                
    case {'e'}  %Enter in the time window desired
        new_xlimits = input('Enter time windows desired [windowstart windowend] --> ');
        if length(new_xlimits) > 1
          xlim([new_xlimits]) 
        else
            xlim([new_xlimits xlimits(2)])
        end
        
    case {'n'}
        xdistance = 0.95*(xlimits(2)-xlimits(1));
        xlimits = [xlimits(1)+xdistance xlimits(2)+xdistance];
        if xlimits(2) > swpl/dt
            xlimits = [swpl/dt-xdistance swpl/dt];
        end
         xlim([xlimits])   
         
     case {'j'}
        xdistance = 0.1*(xlimits(2)-xlimits(1));
        xlimits = [xlimits(1)+xdistance xlimits(2)+xdistance];
        if xlimits(2) > swpl/dt
            xlimits = [swpl/dt-xdistance swpl/dt];
        end
         xlim([xlimits])
   
    case {'b'}
        xdistance = 0.95*(xlimits(2)-xlimits(1));
        xlimits = [xlimits(1)-xdistance xlimits(2)-xdistance];
        if xlimits(1) < 1/dt
            xlimits = [1/dt 1/dt+xdistance];
        end
         xlim([xlimits]) 
         
     case {'g'}
        xdistance = 0.1*(xlimits(2)-xlimits(1));
        xlimits = [xlimits(1)-xdistance xlimits(2)-xdistance];
        if xlimits(1) < 1/dt
            xlimits = [1/dt 1/dt+xdistance];
        end
         xlim([xlimits]) 
        
    case {'c'}  %choose the Channel of the data
        ch = input(['Enter channel no desired of ', num2str(ch_no), ' -->  ']);
        while ch < 1 || ch > ch_no
            disp('improper channel selected. Please enter again')
            ch = input('Enter channel no desired -->  ');
        end
        
        for sbp = 1:4
            
            subplot(2, 2, sbp); 
            xlimits = get(gca, 'xlim');
            ylimits = get(gca, 'ylim');

            plot((1:swpl)/sfq, trace(:, ch))
            xlim(xlimits); ylim(ylimits)
        end
        sbp = 1;
         
        set(subplot(2, 2, sbp), 'Color', [0.8 1 0.8])
        

      
     case {'t'}  %Title graph
        titletext = input('Enter title text --> ', 's');
        subplot(2, 2, sbp); title(titletext)
        
        
        
     case {'s'}     %make one of the Subplots active
         sbp = input('Enter subplot number to make active --> ');
         for wps = find([1:4] ~= sbp);
            set(subplot(2, 2, wps), 'Color', [1 1 1])
         end
         set(subplot(2, 2, sbp), 'Color', [0.8 1 0.8])
       
     case {'m'}  %Match all the subplots on the same scale, based on the active plot
          xdistance = (xlimits(2)-xlimits(1));
            for wps = find([1:4] ~= sbp);
                tmp_xlm = get(subplot(2,2, wps), 'xlim');
                set(subplot(2, 2, wps), 'xlim', [tmp_xlm(1) tmp_xlm(1)+xdistance])
            end
     case {'i'}     %zoom y axis IN
         signalmean = mean(trace(:, ch));
         ylim([signalmean - abs(signalmean-ylimits(1))/2 ...
            signalmean + abs(ylimits(2)-signalmean)/2])
        
    case {'o'}      %zoom y axis IN
         signalmean = mean(trace(:, ch));
         ylim([signalmean - abs(signalmean-ylimits(1))*2 ...
            signalmean + abs(ylimits(2)-signalmean)*2])
         
    case {'p'}      %play audio od active trace
        tr = trace(sfq*xlimits(1):sfq*xlimits(2), ch); 
       
        tr = tr/(5*std(tr));
        clip = find(tr > 1);  
        tr(clip) = .99;
        clip = find( tr < -1);
        tr(clip) = -.99;
 
        
            sound(tr, sfq)

        
              
    case {'p2'}      %play audio od active trace
        xch = input('Enter channel(s). use brackets [] for separate channels. --> ');


        tr = trace(floor(sfq*xlimits(1)):ceil(sfq*xlimits(2)), xch); 

        for c = 1:2
            pstd = 5*std(tr(:,c));
            tr(:, c) = tr(:, c)/pstd;
            clip = find(tr(:,c) > 1);  
            tr(clip, c) = .99;
            clip = find( tr(:,c) < -1);
            tr(clip, c) = -.99;
        end

            sound(tr, sfq)
    
        otherwise
        disp('Unknown command entered. Try again')
             
    end
        

end
   