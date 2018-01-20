function helperRadarPulsePlot(ReceivePulse,threshold,t,tp,pulseplotnum)
% This function helperRadarPulsePlot is only in support of
% RadarRangeEstimationExample. It may be removed in a future release.

%   Copyright 2007-2012 The MathWorks, Inc.

thresh = sqrt(threshold).*ones(numel(t),1);
for m = 1:pulseplotnum
    subplot(pulseplotnum,1,m);
    tnow = t+tp(m);
    rpulse = abs(ReceivePulse(:,m));
    rpulse(rpulse == 0) = eps;   % avoid log of 0
    plot(tnow,pow2db(rpulse.^2),tnow,pow2db(thresh.^2),'r--');

    xlabel('Time (s)');
    ylabel('Power (dBw)');
    axis tight;
    ax = axis;
    ax(4) = ax(4)+0.05*abs(ax(4));
    axis(ax);
    grid on;
    if pulseplotnum > 1
        title(sprintf('Pulse %d',m));
    end
end


% [EOF]
