function [emg_clean, emg_filtered] = emgFilterRectify(emg_signal, fs, cutoff_freq, type)
% [emg_clean, emg_filtered] = emgFilterRectify(emg_signal, fs, cutoff_freq, type);
% cutoff_freq = in degrees; for bandpass, [lo, hi]; else only one value
% type = "low", "high", "bandpass", or "stop"

% Create a butterworth filter
if nargin<3
	cutoff_freq = [35, 100];
endif
cutoff_freq = cutoff_freq/fs/2;
if nargin<4
	if length(cutoff_freq) == 2
		type = 'bandpass';
	else
		type = 'high';
	endif
endif
[b, a] = butter (1, cutoff_freq, type);
emg_filtered = filter(b, a, emg_signal);
% rectifies bipolar emg signals
emg_clean = abs(emg_filtered);
