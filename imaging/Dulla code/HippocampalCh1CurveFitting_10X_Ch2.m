function [Fit_to_Subtract]=HippocampalCh1CurveFitting_10X_Ch2(time,ch2tofit)


% Apply exclusion rule "these"
if length(time)~=159
   error('Exclusion rule ''%s'' is incompatible with ''%s''.','these','time');
end
ex_ = false(length(time),1);
ex_([(65:134)]) = 1;
ok_ = isfinite(time) & isfinite(ch2tofit);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [5.6112607309819484414 -0.025086511102717968386 373.6285575644221808 0.00013660660487300603874 ];
ft_ = fittype('exp2');

% Fit this model using new data
if sum(~ex_(ok_))<2  %% too many points excluded
   error('Not enough data left to fit ''%s'' after applying exclusion rule ''%s''.','fit 1','these')
else
   cf_ = fit(time(ok_),ch2tofit(ok_),ft_,'Startpoint',st_,'Exclude',ex_(ok_));
end

% Or use coefficients from the original fit:
if 0
   cv_ = { 7.4562581462908115171, -0.01896291418738393561, 371.73364478706952241, 0.00016784443937336904185};
   cf_ = cfit(ft_,cv_{:});
   
end
Fit_to_Subtract=feval(cf_,time);
end


