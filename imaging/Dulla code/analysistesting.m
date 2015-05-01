function analysistesting(fit_time,fit_ch1,fit_ch2)
%ANALYSISTESTING    Create plot of datasets and fits
%   ANALYSISTESTING(FIT_TIME,FIT_CH1,FIT_CH2)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  2
%   Number of fits:  1

 
% Data from dataset "fit_ch1 vs. fit_time":
%    X = fit_time:
%    Y = fit_ch1:
%    Unweighted
 
% Data from dataset "fit_ch2 vs. fit_time":
%    X = fit_time:
%    Y = fit_ch2:
%    Unweighted
%
% This function was automatically generated on 23-Feb-2009 13:29:01

% Set up figure to receive datasets and fits
f_ = clf;
figure(f_);
set(f_,'Units','Pixels','Position',[1196 185 682 476]);
legh_ = []; legt_ = {};   % handles and text for legend
xlim_ = [Inf -Inf];       % limits of x axis
ax_ = axes;
set(ax_,'Units','normalized','OuterPosition',[0 0 1 1]);
set(ax_,'Box','on');
axes(ax_); hold on;

 
% --- Plot data originally in dataset "fit_ch1 vs. fit_time"
fit_time = fit_time(:);
fit_ch1 = fit_ch1(:);
h_ = line(fit_time,fit_ch1,'Parent',ax_,'Color',[0.333333 0 0.666667],...
     'LineStyle','none', 'LineWidth',1,...
     'Marker','.', 'MarkerSize',12);
xlim_(1) = min(xlim_(1),min(fit_time));
xlim_(2) = max(xlim_(2),max(fit_time));
legh_(end+1) = h_;
legt_{end+1} = 'fit_ch1 vs. fit_time';
 
% --- Plot data originally in dataset "fit_ch2 vs. fit_time"
fit_ch2 = fit_ch2(:);
h_ = line(fit_time,fit_ch2,'Parent',ax_,'Color',[0.333333 0.666667 0],...
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
    set(ax_, 'XLim',[0.010000000000000008882, 100.98999999999999488]);
end


% --- Create fit "fit 1"
fo_ = fitoptions('method','NonlinearLeastSquares','Robust','On','Algorithm','Levenberg-Marquardt');
ok_ = isfinite(fit_time) & isfinite(fit_ch1);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [12.157435039177022063 -0.047832406644661290551 1080.5679694878069768 -0.0011811405752495413718 ];
set(fo_,'Startpoint',st_);
ft_ = fittype('exp2');

% Fit this model using new data
cf_ = fit(fit_time(ok_),fit_ch1(ok_),ft_,fo_);

% Or use coefficients from the original fit:
if 0
   cv_ = { 52.697750977965384322, -0.57107350967034153921, 1082.9534326239570419, -0.0012917054854730896599};
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
t_(1:2) = [0.55022,0.454832];
set(h_,'Interpreter','none','Position',t_);
xlabel(ax_,'');               % remove x label
ylabel(ax_,'');               % remove y label
