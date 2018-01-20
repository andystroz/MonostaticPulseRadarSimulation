function y = Receiver(SampleRate,x,error_rx,rs)

error_rx = logical(error_rx);
x(~error_rx,:) = 0;
LossFactor = 20;
output_size = [size(x,1), size(x,2)];

B = physconst('Boltzmann');
NoiseSamplePower =  B * 290 * SampleRate;
noise = sqrt(NoiseSamplePower/2)*complex(randn(rs,output_size),randn(rs,output_size));

y = sqrt(db2pow(LossFactor))*x + noise; 