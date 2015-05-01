function dd(fit_time,fit_ch2)
%DD    Create plot of datasets and fits
%   DD(FIT_TIME,FIT_CH2)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1

 
% Data from dataset "fit_ch2 vs. fit_time":
%    X = fit_time:
%    Y = fit_ch2:
%    Unweighted
%
% This function was automatically generated on 20-Apr-2010 13:26:24

% Set up figure to receive datasets and fits
f_ = clf;
figure(f_);
set(f_,'Units','Pixels','Position',[1293 241 682 476]);
legh_ = []; legt_ = {};   % handles and text for legend
xlim_ = [Inf -Inf];       % limits of x axis
ax_ = axes;
set(ax_,'Units','normalized','OuterPosition',[0 0 1 1]);
set(ax_,'Box','on');
axes(ax_); hold on;

 
% --- Plot data originally in dataset "fit_ch2 vs. fit_time"
fit_time = fit_time(:);
fit_ch2 = fit_ch2(:);
h_ = line(fit_time,fit_ch2,'Parent',ax_,'Color',[0.333333 0 0.666667],...
     'LineStyle','none', 'LineWidth',1,...
     'Marker','.', 'MarkerSize',12);
xlim_(1) = min(xlim_(1),min(fit_time));
xlim_(2) = max(xlim_(2),max(fit_time));
legh_(end+1) = h_;
legt_{end+1} = 'fit_ch2 vs. fit_time';

% Nudge axis limits beyond data limits
if all(isfinite(xlim_))
   xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
   set(ax_,'XLim',xlim_)
else
    set(ax_, 'XLim',[-0.72999999999999998224, 175.72999999999998977]);
end


% --- Create fit "fit 1"
ok_ = isfinite(fit_time) & isfinite(fit_ch2);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [675.29354667360928488 0.00011337877799586843679 -13.798412877211511329 -0.016468195829250610596 ];
ft_ = fittype('exp2');

% Fit this model using new data
cf_ = fit(fit_time(ok_),fit_ch2(ok_),ft_,'Startpoint',st_);

% Or use coefficients from the original fit:
if 0
   cv_ = { -8543102.5545637402683, -0.0010203401702043137563, 8543764.8161352593452, -0.0010202332298861675579};
   cf_ = cfit(ft_,cv_{:});
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
leginfo_ = {'Orientation', 'vertical'}; 
h_ = legend(ax_,legh_,legt_,leginfo_{:}); % create and reposition legend
set(h_,'Units','normalized');
t_ = get(h_,'Position');
t_(1:2) = [0.623534,0.378414];
set(h_,'Interpreter','none','Position',t_);
xlabel(ax_,'');               % remove x label
ylabel(ax_,'');               % remove y label
