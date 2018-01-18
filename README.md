# Monostatic Pulse Radar

This project outlines a basic monostatic pulse radar system to detect non-fluctuating targets with at least one square meter radar cross section (RCS) at a distance up to 5000 meters from the radar with a range resolution of 50 meters. The desired performance index is a probability of detection (Pd) of 0.9 and probability of false alarm (Pfa) below 1e-6. 

The code is also designed so that the objects and sensor are at a fixed range (0 velocity)

The project was designed following the guide under https://www.mathworks.com/help/phased/examples/designing-a-basic-monostatic-pulse-radar.html

# Instructions

To run the simulation clone the repository and add the folder to the Matlab path. Navigate to `MonostaticRadar_Example.m` and press run.

The following targets are currently being used:
```
tgtpos = [[1000;0;0],[1845.04;0;0],[2024.66;0;0],[3518.63;0;0],[3845.04;0;0]];
tgtrcs = [1 2 1.6 2.2 1.05];
```
More targets and their radar cross sections can be added or subtracted here.
