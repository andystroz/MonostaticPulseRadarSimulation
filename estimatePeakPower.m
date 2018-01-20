function PeakPower = estimatePeakPower(lambda,RNG,SNRdb,tau,RCS,Gain)

Loss = 0;      
Ts = 290;   
k   = physconst('Boltzmann'); 
PeakPower = ((4*pi)^3*k*Ts*RNG^2*RNG^2*db2pow(Loss)*db2pow(SNRdb))/(tau*db2pow(Gain)*RCS*db2pow(Gain)*lambda^2); % Watts
