function[Fit_to_Subtract]= 10XHippocampalCh1CurveFitting(time,testch1)
%10XHIPPOCAMPALCH1CURVEFITTING    Create plot of datasets and fits
%   10XHIPPOCAMPALCH1CURVEFITTING(TIME,TESTCH1)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1

 
% Data from dataset "testch1 vs. time":
%    X = time:
%    Y = testch1:
%    Unweighted
%
% This function was automatically generated on 19-Mar-2010 11:17:37


% --- Create fit "fit 1"

% Apply exclusion rule "PostStim2"
if length(time)~=159
   error('Exclusion rule ''%s'' is incompatible with ''%s''.','PostStim2','time');
end
ex_ = false(length(time),1);
ex_([(63:138)]) = 1;
ok_ = isfinite(time) & isfinite(testch1);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [16.918316860160086179 -0.038273153426251614595 1200.5450079503089 -8.0078469243087069349e-05 ];
ft_ = fittype('exp2');

% Fit this model using new data
if sum(~ex_(ok_))<2  %% too many points excluded
   error('Not enough data left to fit ''%s'' after applying exclusion rule ''%s''.','fit 1','PostStim2')
else
   cf_ = fit(time(ok_),testch1(ok_),ft_,'Startpoint',st_,'Exclude',ex_(ok_));
end

% Or use coefficients from the original fit:
if 0
   cv_ = { 25.255901386006538445, -0.020735847319642241454, 1191.0504281222906684, -2.9905424173387477258e-05};
   cf_ = cfit(ft_,cv_{:});
end

