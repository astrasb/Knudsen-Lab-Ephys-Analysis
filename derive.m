% Helper function -- Take a numerical derivative
% Used instead of matlab's diff function, because it preserves the length of the original vector.
function rslt = derive( vals, dt )
    len = length( vals );
    scale = 2 * dt;
    rslt = [0 ; ( vals(3:len,:) - vals(1:len-2,:) ) / scale ; 0];
end
            