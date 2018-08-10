function emg_clean = emgCleanup(emg_signal)
% emg_clean = emgCleanup(emg_signal);
% load('bandpass_filter_butterworth_10-350Hz.mat');

% emg_ch1_filtered = filter(d, emg_signal);
% Applies a digital filter, defined using the matlab filter app, bandpass 10-500hz, butterworth.
% y1=fft(emg_recording_ch1_filtered);
% m1=abs(y1);
% p1=angle(y1);
% f1 = (0:length(y1)-1)*(1/sampling_frequency);
% plot(f1,m1)
% this code is written as an optional check using the Fast fourier transform, 
% it is useful once the filter is applied to look at data before and after the butterworth filter

% rectifies bipolar emg signals
emg_clean = abs(emg_signal);
