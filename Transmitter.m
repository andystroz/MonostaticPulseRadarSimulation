function [yout,TxOn] = Transmitter(LossFactor,PeakPower,wave)

Amplitude_Coeff = sqrt(PeakPower*db2pow(LossFactor));
yout = Amplitude_Coeff*wave;
TxOn = wave~=0; 
