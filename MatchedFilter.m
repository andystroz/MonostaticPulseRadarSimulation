function [output_signal,g] = MatchedFilter(input_signals,fft_coeff)
fft_length = size(input_signals,1)+1;
pSignalIdx = [1 fft_length];

coefficient_fft = dsp.FFT('FFTLengthSource','Property','FFTLength',fft_length);

fft_window_coeff = ones(fft_length,1);


coeff_freq = step(coefficient_fft,fft_coeff) .* fft_window_coeff;
coefficient_fft.release();

signal_fft = step(coefficient_fft,complex(input_signals));

% Multiple the two ffts together
fft_multiple = zeros(size(signal_fft,1),size(signal_fft,2));
for i = 1:size(signal_fft,2)
    for j = 1:size(signal_fft,1)
        fft_multiple(j,i) = signal_fft(j, i) * coeff_freq(j,1);
    end
end

% Perform the inverse FFT to get the output signal
inverse_fft_output = step(dsp.IFFT,fft_multiple);

output_signal = inverse_fft_output(pSignalIdx(1):pSignalIdx(2),:);

windowProcessingLoss  = -pow2db(abs(sum(fft_window_coeff))^2/(fft_length*(fft_window_coeff'*fft_window_coeff)));

gain = pow2db(real(fft_coeff'*fft_coeff));

output_signal = output_signal(1:size(input_signals,1),1:size(input_signals,2));
g = gain - windowProcessingLoss;

% Shifts values into correct position after FFT and IFFT
output_signal = buffer(output_signal(size(fft_coeff,1):end),size(output_signal,1));

