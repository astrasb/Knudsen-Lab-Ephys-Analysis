function [cf_, rsquare]=Single_of_Gaussiancs(x,testplotdata)
%SUM_OF_GAUSSIANCS    Create plot of datasets and fits
%   SUM_OF_GAUSSIANCS(X,TESTPLOTDATA)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1

 
% Data from dataset "testplotdata vs. x":
%    X = x:
%    Y = testplotdata:
%    Unweighted
%
% This function was automatically generated on 22-Sep-2009 14:50:33

% --- Create fit "fit 1"
fo_ = fitoptions('method','NonlinearLeastSquares','Lower',[-Inf -Inf    0 -Inf -Inf    0]);
ok_ = isfinite(x) & isfinite(testplotdata);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [0.06293845481444443335 44 3.5675704318830323558 0.0460204066279081489 51 5.4083178902254021025 ];
set(fo_,'Startpoint',st_);
ft_ = fittype('gauss1');

% Fit this model using new data
[cf_,  gof]= fit(x(ok_),testplotdata(ok_),ft_,fo_);
rsquare=gof.rsquare;
% Or use coefficients from the original fit:
if 0
   cv_ = { 0.03407240715233707945, 41.445035536733286108, 7.2184183192811852692, 0.042280681292056733478, 51.36057356681990882, 13.730059715269250731};
   cf_ = cfit(ft_,cv_{:});
end

