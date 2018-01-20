function y = RectangularWave(pulse_width,fs,pulse_repetition_frequency)

% Creates the array of the pulse length size at the sampling rate
pulse_length = round(fs/pulse_repetition_frequency);
% Gets the width of the pulse in terms of the array being sampled at fs
index = (pulse_width)/(1/fs);
for n = 1:numel(index)
    if abs(index(n)-round(index(n))) <= 10*eps(index(n))
        index(n) = round(index(n));
    end
end
nonZeroLength  =  ceil(index) + 1;
                
y = complex(zeros(pulse_length,1)); 
for i = 1:nonZeroLength
    y(i) = 1;
end

