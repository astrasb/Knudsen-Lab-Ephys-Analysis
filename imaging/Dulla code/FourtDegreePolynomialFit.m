function [cf_]=FourtDegreePolynomialFit(fit_time,fit_ch1)
% --- Create fit "fit 2"
ok_ = isfinite(fit_time) & isfinite(fit_ch1);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
ft_ = fittype('poly3');
% Fit this model using new data
cf_ = fit(fit_time(ok_),fit_ch1(ok_),ft_);
% Or use coefficients from the original fit:


%%%%%%%%%%%  Curve fit subtraction
cf_=coeffvalues(cf_);
end