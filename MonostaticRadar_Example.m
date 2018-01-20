% Monstatic Pulse Radar System Example
% Referenced from:
% https://www.mathworks.com/help/phased/examples/designing-a-basic-monostatic-pulse-radar.html
% Possible Expansion
% https://www.mathworks.com/help/phased/examples/waveform-design-to-improve-performance-of-an-existing-radar-system.html
% Design Specifications
clc

pd = 0.9;            % Probability of detection
pfa = 1e-6;          % Probability of false alarm
max_range = 5000;    % Maximum unambiguous range
range_res = 50;      % Required range resolution
tgt_rcs = 1;         % Required target radar cross section

% Monostatic Radar System Design
% Waveform

prop_speed = physconst('LightSpeed');   % Propagation speed
pulse_bw = prop_speed/(2*range_res);    % Pulse bandwidth
pulse_width = 1/pulse_bw;               % Pulse width
prf = prop_speed/(2*max_range);         % Pulse repetition frequency
fs = 2*pulse_bw;                        % Sampling rate

% A number of pulses are sent out to increase the signal to noise ratio and
% decrease the total amount of power needed to send the signal
num_pulse_integrations = 10;
noise_bw = pulse_bw;

% Calculating the minimum signal to noise ratio using the Albersheim
% Method using the probability of detection and the probability of false
% alarm
snr_min_a = log(0.62/pfa);
snr_min_b = log(pd/(1-pd));
snr_min = (1/sqrt(num_pulse_integrations))*(snr_min_a + 0.12*snr_min_a*snr_min_b + 1.7*snr_min_b)^((6.2+4.54/sqrt(num_pulse_integrations+0.44))/10);
snr_min = pow2db(snr_min);

tx_gain = 20;
fc = 10e9;
lambda = prop_speed/fc;

% Example targets. Velocities not included due to everything in this
% example having 0 constant velocity
% tgtpos = [[2024.66;0;0],[3518.63;0;0],[3845.04;0;0]];
% tgtrcs = [1.6 2.2 1.05];

% Test Target Being Used
tgtpos = [[1000;0;0],[1845.04;0;0],[2024.66;0;0],[3518.63;0;0],[3845.04;0;0]];
tgtrcs = [1 2 1.6 2.2 1.05];

PeakPower = estimatePeakPower(lambda,max_range,snr_min,pulse_width,tgt_rcs,tx_gain);

segments = (1/prf)/(1/fs);
fast_time_grid = zeros(1,segments);
for i = 1:segments
    fast_time_grid(1,i) = (i-1)*(1/fs);
end
slow_time_grid = (0:num_pulse_integrations-1)/prf;

rs = RandStream('mt19937ar','Seed',1000);
% Pre-allocate array for improved processing speed
receivedPulses = zeros(numel(fast_time_grid),num_pulse_integrations);

% Update sensor and target positions
% NOTE: In this demonstration both the target and the sensor are static
% Calculate the target angles as seen by the sensor
% NOTE: In this demonstration the target angles and ranges are constant
% becuase the sensor and target positions are constant and the velocity is
% 0. If there was a velocity this operaton would be done inside the loop 
for j = 0:size(tgtpos,2)-1
    tgtrng(1,1+j) = tgtpos(1,1+j);
end

for m = 1:num_pulse_integrations
    % Generate Wave
    wave = RectangularWave(pulse_width,fs,prf);
    % Generate Output of Transmitter using the Rectangular Wave (gives the
    % initial transmit signal and status as it leaves the transmitted
    [txsig,txstatus] = Transmitter(tx_gain,PeakPower,wave);
    % Generate Output of Radiator using the Transmit Sigature and the Target
    % Angle
    % In this case the txsig var is copied accross x number of channels
    % where x is the number of targets
    for j = 1:size(tgtrng,2)-1
        txsig(:,j+1) = txsig(:,1);
    end
    % Generate Output of the Channel (Free Space) between the radiator and 
    % the target object using the transmit signature, sensor position, target
    % position, sensor velocity and target velocity
    % In this case the sensor position, target
    % position are all both constant because the sensor velocity and target
    % velocity are 0
    txsig = FreeSpace(fs,fc,txsig,tgtpos);
    % Generate Output of the wave reflecting off of the target using the
    % transmit signature
    tgtsig = Target(tgtrcs,fc,txsig);
    % Generate Output of the Collector using the target signature (Pushes
    % the induvidual reflections together
    g = ones(size(tgtsig,2),1);
    rxsig = tgtsig*g;
    % Generate the output from the Receiver using the transmit status and the
    % receiver signature and store it in an array for the number of pulses
    
    receivedPulses(:,m) = Receiver(fs,rxsig,~(txstatus>0),rs);
end

% Range Detection Section 
% Using the received pulses, the number of which defined by num_pulse_integrations
% Several signal processing techniques are used to increase the power of
% the components of the signal received through reflection vs. noise

% Detection Threshold
% The detection threshold is found through a function of the noise power
% the probablilty of false alarm and the number of pulse integrations

snr_min_b = physconst('Boltzmann');
% Calculate the noise power B * Temp * noise_bw
npower =  snr_min_b * 290 * noise_bw;
threshold = npower * db2pow(mag2db(abs(sqrt(gammaincinv(1-pfa,num_pulse_integrations)))));

% Matched Filter
% Convolves the received signal with a time-reversed
% conjugated copy of transmitted waveform.
% This improves the detection threshold 
% Uses the transmitted waveform as ref

% In this case the coefficients match the ones at the start of the waveform
[receivedPulses, mfgain] = MatchedFilter(receivedPulses,[1;1]);
% Update Threshold
threshold = threshold * db2pow(mfgain);

% Time Varying Gain
% Increases gain over time (signals received quickly will have higher gain
% than the signals recived later on)

range_bins = prop_speed*fast_time_grid/2;
fspl_range_bins = 20*log10(max((4*pi*range_bins/lambda),1));
fspl_max_range = 20*log10(max((4*pi*max_range/lambda),1));
receivedPulses = TimeVaryingGain(2*fspl_range_bins,2*fspl_max_range,receivedPulses);

% Noncoherent Integration
% Integrating the received pulses together showing one final signal
% Takes the sum of the square of the received pulses (rows)

sigout = sum(abs(receivedPulses).^2,2);
receivedPulses = sqrt(sigout);

% Result Plotting
figure
thresh = sqrt(threshold).*ones(numel(fast_time_grid),1);
rpulse = abs(receivedPulses(:,1));
plot(fast_time_grid,pow2db(rpulse.^2),fast_time_grid,pow2db(thresh.^2),'r--');
ylabel("Power (dBw)");
xlabel("Time (s)");
title("Processed Radar Pulses");
grid on;
axis tight;

% Peak / Range Detection
% Finds signal peaks above the detection threshold

[~,range_detect] = findpeaks(receivedPulses,'MinPeakHeight',sqrt(threshold));

true_range = round(tgtrng)
range_estimates = round(range_bins(range_detect))
