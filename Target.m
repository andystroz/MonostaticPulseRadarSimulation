function y = Target(MeanRCS,OperatingFrequency,x)

PropSpeed = physconst('LightSpeed');
lambda = PropSpeed/OperatingFrequency;
gain = 4*pi*MeanRCS./(lambda^2);
gain = pow2db(gain);
gain = sqrt(db2pow(gain));
y = zeros(size(x,1),size(x,2));
for i = 1:size(x,2)
    for j = 1:size(x,1)
        y(j,i) = x(j, i) * gain(1,i);
    end
end
