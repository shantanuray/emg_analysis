edf_filename = '/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/export.edf';
%defines a variable for the path of the file to be opened 
[hdr, record] = edfread(edf_filename);
% the program expects two outputs the header(hdr) and the data(volts) which is in rows, each channel is recorded in one row
emg_ch1 	= record(1,:);
emg_ch2 	= record(2,:);
emg_ch3 	= record(3,:);
%defines a variable for data in each channel
sampling_frequency		= 2000; 
%defines the smapling frequency at which the recording is taken

% y=fft(emg_recording_ch1);
% m=abs(y);
% p=angle(y);
% f = (0:length(y)-1)*(1/sampling_frequency);
% plot(f,m)
% this code is written as an optional check using the Fast fourier transform, 
%it is useful once the filter is applied to look at data before and after the butterworth filter


% Applies a digital filter, defined using the matlab filter app, bandpass 10-500hz, butterworth.
% and ectifies bipolar emg signals
emg_ch1_filtered_rectified = emgCleanup(emg_ch1);
emg_ch2_filtered_rectified = emgCleanup(emg_ch2);
emg_ch3_filtered_rectified = emgCleanup(emg_ch3);

% Select samples in the emg channel data that corresponds to the time stamp from the annotations data file
% Samples are chosen interval_duration  before and after time stamp 
annotations = readtable('/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/18UN_19-2-18/annotations1_US.csv');
time_stamp 	= annotations.x___time_stamp;
number_intervals = length(time_stamp);
interval_duration   = 0.5; % refers to 0.5 seconds(500ms) before and after time stamp

emg_ch1_filtered_rectified_samples = emgSelect(emg_ch1_filtered_rectified, time_stamp, interval_duration, sampling_frequency);
emg_ch2_filtered_rectified_samples = emgSelect(emg_ch2_filtered_rectified, time_stamp, interval_duration, sampling_frequency);
emg_ch3_filtered_rectified_samples = emgSelect(emg_ch3_filtered_rectified, time_stamp, interval_duration, sampling_frequency);

%computes the average voltage at each time point in reference to the annotation data point
emg_ch1_filtered_rectified_avg = sum(emg_ch1_filtered_rectified_samples, 1)./number_intervals;
emg_ch2_filtered_rectified_avg = sum(emg_ch2_filtered_rectified_samples, 1)./number_intervals;
emg_ch3_filtered_rectified_avg = sum(emg_ch3_filtered_rectified_samples, 1)./number_intervals;

%computes the moving average for a window of 25 ms or 0.025s, useful to find gradual trends in data
window_duration = 25/1000;
emg_ch1_filtered_rectified_moving_avg = movingAverage(emg_ch1_filtered_rectified_avg, window_duration, sampling_frequency);
emg_ch2_filtered_rectified_moving_avg = movingAverage(emg_ch2_filtered_rectified_avg, window_duration, sampling_frequency);
emg_ch3_filtered_rectified_moving_avg = movingAverage(emg_ch3_filtered_rectified_avg, window_duration, sampling_frequency);


