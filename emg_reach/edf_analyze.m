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

%computes baseline for each row
baseline_start = 0;
baseline_end = 0.2;

emg_ch1_filtered_rectified_samples_baseline = emg_ch1_filtered_rectified_samples(:, baseline_start*sampling_frequency+1:baseline_end*sampling_frequency);
emg_ch2_filtered_rectified_samples_baseline = emg_ch2_filtered_rectified_samples(:, baseline_start*sampling_frequency+1:baseline_end*sampling_frequency);
emg_ch3_filtered_rectified_samples_baseline = emg_ch3_filtered_rectified_samples(:, baseline_start*sampling_frequency+1:baseline_end*sampling_frequency);

emg_ch1_Average_baseline = mean(emg_ch1_filtered_rectified_samples_baseline,2);
emg_ch2_Average_baseline = mean(emg_ch2_filtered_rectified_samples_baseline,2);
emg_ch3_Average_baseline = mean(emg_ch3_filtered_rectified_samples_baseline,2);

%computes mvolt activity within the reach
Emg_activity_start = 0.21;
Emg_activity_end = 0.8;

emg_ch1_filtered_rectified_samples_activity = emg_ch1_filtered_rectified_samples(:, Emg_activity_start*sampling_frequency+1:Emg_activity_end*sampling_frequency);
emg_ch2_filtered_rectified_samples_activity = emg_ch2_filtered_rectified_samples(:, Emg_activity_start*sampling_frequency+1:Emg_activity_end*sampling_frequency);
emg_ch3_filtered_rectified_samples_activity = emg_ch3_filtered_rectified_samples(:, Emg_activity_start*sampling_frequency+1:Emg_activity_end*sampling_frequency);
 
emg_ch1_activity = mean(emg_ch1_filtered_rectified_samples_activity,2);
emg_ch2_activity = mean(emg_ch2_filtered_rectified_samples_activity,2);
emg_ch3_activity = mean(emg_ch3_filtered_rectified_samples_activity,2);
 

%computes %fold change
emg_ch1_foldchange = ((emg_ch1_activity-emg_ch1_Average_baseline)/emg_ch1_Average_baseline)*100;
emg_ch2_foldchange = ((emg_ch2_activity-emg_ch2_Average_baseline)/emg_ch2_Average_baseline)*100;
emg_ch3_foldchange = ((emg_ch3_activity-emg_ch3_Average_baseline)/emg_ch3_Average_baseline)*100;

%computes the average voltage at each time point in reference to the annotation data point
emg_ch1_filtered_rectified_avg = sum(emg_ch1_filtered_rectified_samples, 1)./number_intervals;
emg_ch2_filtered_rectified_avg = sum(emg_ch2_filtered_rectified_samples, 1)./number_intervals;
emg_ch3_filtered_rectified_avg = sum(emg_ch3_filtered_rectified_samples, 1)./number_intervals;

%computes the moving average for a window of 25 ms or 0.025s, useful to find gradual trends in data
window_duration = 25/1000;
emg_ch1_filtered_rectified_moving_avg = movingAverage(emg_ch1_filtered_rectified_avg, window_duration, sampling_frequency);
emg_ch2_filtered_rectified_moving_avg = movingAverage(emg_ch2_filtered_rectified_avg, window_duration, sampling_frequency);
emg_ch3_filtered_rectified_moving_avg = movingAverage(emg_ch3_filtered_rectified_avg, window_duration, sampling_frequency);

%computes area under curve for each sample
emg_ch1_filtered_rectified_Area_under_curve=trapz((0:length(emg_ch1_filtered_rectified_samples)-1)/sampling_frequency,emg_ch1_filtered_rectified_samples, 2);
emg_ch2_filtered_rectified_Area_under_curve=trapz((0:length(emg_ch2_filtered_rectified_samples)-1)/sampling_frequency,emg_ch2_filtered_rectified_samples, 2);
emg_ch3_filtered_rectified_Area_under_curve=trapz((0:length(emg_ch3_filtered_rectified_samples)-1)/sampling_frequency,emg_ch3_filtered_rectified_samples, 2);

% computes average AUC
emg_ch1_averag_Area_under_curve = mean(emg_ch1_filtered_rectified_Area_under_curve);
emg_ch2_averag_Area_under_curve = mean(emg_ch2_filtered_rectified_Area_under_curve);
emg_ch3_averag_Area_under_curve = mean(emg_ch3_filtered_rectified_Area_under_curve);


figure
subplot(3,1,1)
plot((0:length(emg_ch1_filtered_rectified_avg)-1)/sampling_frequency, ...
    emg_ch1_filtered_rectified_avg)
hold on
plot((0:length(emg_ch1_filtered_rectified_avg)-1)/sampling_frequency, ...
    emg_ch1_filtered_rectified_moving_avg, 'r')
hold off

subplot(3,1,2)
plot((0:length(emg_ch1_filtered_rectified_avg)-1)/sampling_frequency, ...
    emg_ch2_filtered_rectified_avg)
hold on
plot((0:length(emg_ch1_filtered_rectified_avg)-1)/sampling_frequency, ...
    emg_ch2_filtered_rectified_moving_avg, 'r')
hold off

subplot(3,1,3)
plot((0:length(emg_ch1_filtered_rectified_avg)-1)/sampling_frequency, ...
    emg_ch3_filtered_rectified_avg)
hold on
plot((0:length(emg_ch1_filtered_rectified_avg)-1)/sampling_frequency, ...
    emg_ch3_filtered_rectified_moving_avg, 'r')
hold off