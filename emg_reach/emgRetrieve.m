function [record_clean, record_filtered, record_raw] = emgRetrieve(emgFile)
  %defines a variable for the path of the file to be opened 
  [hdr, record_raw] = edfread(emgFile);
  % the program expects two outputs the header(hdr) and the data(volts) which is in rows, each channel is recorded in one row
  for i = 1:size(record_raw,1)
    % Applies a digital filter, defined using the matlab filter app, bandpass 10-500hz, butterworth.
    % and rectifies bipolar emg signals
    [tmp_clean, tmp_filtered] = emgCleanup(record_raw(i,:));
    record_clean(i,:)     = tmp_clean;
    record_filtered(i,:)  = tmp_filtered;
  end;