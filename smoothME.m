function rslt = smoothME(X, w, f)
    % Smoothing the data by applying a lowpass filter (from the Signal
    % Processing Toolkit). This will work in the presence of multiple
    % high frequencies of noise, or no noise at all, but requires tuning to
    % the data by adjusting the width (w) and frequency range(f) of the
    % filter (f is relative to the Nyquist frequency, [0, 1]).
    
   
    N = size(X,2);
    
    %disp( ['w: ' num2str(w) ', f: ' num2str(f) ', N: ' num2str(N)] );
    
    % Run a lowpass filter
    % --- Requires Signal Processing Toolkit ---
    Z = conv(X,fir1(2*w,f));
    
    % Remove points where filter has gone outside the scope of the data
    Z = Z(w : N-w);
    
    rslt = Z';
    
end
