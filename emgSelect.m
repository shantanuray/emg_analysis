function emg_samples = emgSelect(emg_clean, time_stamp, interval_duration, sampling_frequency)
% emg_samples = emgSelect(emg_clean, time_stamp, interval_duration, sampling_frequency);
sample_number = round((time_stamp) * (sampling_frequency), 0);
% computes the sample number in the emg channel data which corresponds to the time stamp from the annotations data file

interval_start      = sample_number - round(interval_duration*sampling_frequency,0);
% subtracts thousand samples from annotation number
interval_end        = sample_number + round(interval_duration*sampling_frequency,0);
% adds thousand samples from the annotation number

number_intervals = length(time_stamp);
% the number of intervals is equal to the number of annotations
emg_samples = [];
for i=1:number_intervals
    emg_samples = [emg_samples; emg_clean(interval_start(i):interval_end(i))];
end
% emg_ch1_filtered_rectified(interval_start(1):interval_end(1);interval_start(2):interval_end(2))
% creats a matrix(number of intervalsx2000(data points)) of all the reaches within one data file