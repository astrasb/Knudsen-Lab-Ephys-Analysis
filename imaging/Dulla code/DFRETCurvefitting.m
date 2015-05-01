function DFRETCurvefitting(time,data)
%DFRETCURVEFITTING    Create plot of datasets and fits
%   DFRETCURVEFITTING(TIME,DATA)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1

 
% Data from dataset "data vs. time":
%    X = time:
%    Y = data:
%    Unweighted
%
% This function was automatically generated on 31-Mar-2010 10:51:09

% Set up figure to receive datasets and fits
f_ = clf;
figure(f_);
set(f_,'Units','Pixels','Position',[574 256 680 484]);
legh_ = []; legt_ = {};   % handles and text for legend
xlim_ = [Inf -Inf];       % limits of x axis
ax_ = axes;
set(ax_,'Units','normalized','OuterPosition',[0 0 1 1]);
set(ax_,'Box','on');
axes(ax_); hold on;

 
% --- Plot data originally in dataset "data vs. time"
time = time(:);
data = data(:);
h_ = line(time,data,'Parent',ax_,'Color',[0.333333 0 0.666667],...
     'LineStyle','none', 'LineWidth',1,...
     'Marker','.', 'MarkerSize',12);
xlim_(1) = min(xlim_(1),min(time));
xlim_(2) = max(xlim_(2),max(time));
legh_(end+1) = h_;
legt_{end+1} = 'data vs. time';

% Nudge axis limits beyond data limits
if all(isfinite(xlim_))
   xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
   set(ax_,'XLim',xlim_)
else
    set(ax_, 'XLim',[-6.3399999999999999, 742.34000000000003]);
end


% --- Create fit "fit 1"
ok_ = isfinite(time) & isfinite(data);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [0.040385321857025806 -0.0079177279879568963 0.0062255346816788041 0.0002354299421232714 ];
ft_ = fittype('exp2');

% Fit this model using new data
cf_ = fit(time(ok_),data(ok_),ft_,'Startpoint',st_);

% Or use coefficients from the original fit:
if 0
   cv_ = { 0.040563138362111908, -0.0075619174052084541, 0.0055735276956598899, 0.00038696792129999262};
   cf_ = fit(ft_,cv_{:});
end

% Plot this fit
h_ = plot(cf_,'fit',0.95);
legend off;  % turn off legend from plot method call
set(h_(1),'Color',[1 0 0],...
     'LineStyle','-', 'LineWidth',2,...
     'Marker','none', 'MarkerSize',6);
legh_(end+1) = h_(1);
legt_{end+1} = 'fit 1';

% Done plotting data and fits.  Now finish up loose ends.
hold off;
leginfo_ = {'Orientation', 'vertical', 'Location', 'NorthEast'}; 
h_ = legend(ax_,legh_,legt_,leginfo_{:});  % create legend
set(h_,'Interpreter','none');
xlabel(ax_,'');               % remove x label
ylabel(ax_,'');               % remove y label
