function 4thDegPolynomialFit(tc,ch2c)
%4THDEGPOLYNOMIALFIT    Create plot of datasets and fits
%   4THDEGPOLYNOMIALFIT(TC,CH2C)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1

 
% Data from dataset "ch2c vs. tc":
%    X = tc:
%    Y = ch2c:
%    Unweighted
%
% This function was automatically generated on 10-Jun-2009 16:29:08

% Set up figure to receive datasets and fits
f_ = clf;
figure(f_);
set(f_,'Units','Pixels','Position',[1383 201 682 476]);
legh_ = []; legt_ = {};   % handles and text for legend
xlim_ = [Inf -Inf];       % limits of x axis
ax_ = axes;
set(ax_,'Units','normalized','OuterPosition',[0 0 1 1]);
set(ax_,'Box','on');
axes(ax_); hold on;

 
% --- Plot data originally in dataset "ch2c vs. tc"
tc = tc(:);
ch2c = ch2c(:);
h_ = line(tc,ch2c,'Parent',ax_,'Color',[0.333333 0.666667 0],...
     'LineStyle','none', 'LineWidth',1,...
     'Marker','.', 'MarkerSize',12);
xlim_(1) = min(xlim_(1),min(tc));
xlim_(2) = max(xlim_(2),max(tc));
legh_(end+1) = h_;
legt_{end+1} = 'ch2c vs. tc';

% Nudge axis limits beyond data limits
if all(isfinite(xlim_))
   xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
   set(ax_,'XLim',xlim_)
else
    set(ax_, 'XLim',[-1.4900000000000002132, 252.49000000000000909]);
end


% --- Create fit "fit 2"
ok_ = isfinite(tc) & isfinite(ch2c);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
ft_ = fittype('poly4');

% Fit this model using new data
cf_ = fit(tc(ok_),ch2c(ok_),ft_);

% Or use coefficients from the original fit:
if 0
   cv_ = { 2.3144090326105146956e-10, 3.1104183683390897728e-06, -0.0016362342370089329614, 0.40081345298555087764, 515.72380652729395933};
   cf_ = cfit(ft_,cv_{:});
end

% Plot this fit
h_ = plot(cf_,'fit',0.95);
legend off;  % turn off legend from plot method call
set(h_(1),'Color',[1 0 0],...
     'LineStyle','-', 'LineWidth',2,...
     'Marker','none', 'MarkerSize',6);
legh_(end+1) = h_(1);
legt_{end+1} = 'fit 2';

% Done plotting data and fits.  Now finish up loose ends.
hold off;
leginfo_ = {'Orientation', 'vertical'}; 
h_ = legend(ax_,legh_,legt_,leginfo_{:}); % create and reposition legend
set(h_,'Units','normalized');
t_ = get(h_,'Position');
t_(1:2) = [0.600073,0.264968];
set(h_,'Interpreter','none','Position',t_);
xlabel(ax_,'');               % remove x label
ylabel(ax_,'');               % remove y label
