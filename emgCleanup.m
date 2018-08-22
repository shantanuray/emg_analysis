function [emg_clean, emg_filtered] = emgCleanup(emg_signal)
% [emg_clean, emg_filtered] = emgCleanup(emg_signal);

load('bandpass_filter_butterworth_10-350Hz.mat');

emg_filtered = filter(d, emg_signal);

% rectifies bipolar emg signals
emg_clean = abs(emg_filtered);
