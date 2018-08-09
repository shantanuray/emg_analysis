function emgData = emgRetrieve(emgFile, timestampStartStop,paddingDuration,windowDuration,samplingFrequency)
  %defines a variable for the path of the file to be opened 
  [hdr, record] = edfread(emgFile);
  % the program expects two outputs the header(hdr) and the data(volts) which is in rows, each channel is recorded in one row
  for i = 1:size(record,1)
    
    % y=fft(emg_recording_ch1);
    % m=abs(y);
    % p=angle(y);
    % f = (0:length(y)-1)*(1/samplingFrequency);
    % plot(f,m)
    % this code is written as an optional check using the Fast fourier transform, 
    %it is useful once the filter is applied to look at data before and after the butterworth filter


    % Applies a digital filter, defined using the matlab filter app, bandpass 10-500hz, butterworth.
    % and rectifies bipolar emg signals
    record(i,:) = emgCleanup(record(i,:));

    % Select samples in the emg channel data that corresponds to the time stamp from the annotations data file
    % Samples are chosen paddingDuration  before and after time stamp 

    emgData(i,:) = emgSelect(record(i,:), timestampStartStop, paddingDuration, samplingFrequency);
  end;