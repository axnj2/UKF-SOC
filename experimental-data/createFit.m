function [fitresult, gof] = createFit(SOC, parameter)

[xData, yData] = prepareCurveData( SOC, parameter );

ft = 'linearinterp'; %linear interpolation
opts = fitoptions( 'Method', 'LinearInterpolant' );
opts.ExtrapolationMethod = 'linear';



% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft,opts);

end

