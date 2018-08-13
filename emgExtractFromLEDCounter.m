function [emgData,timestampEMG] = emgExtractFromLEDCounter(record,emgCounterReference,videoSamplingFrequency,emgSamplingFrequency,padding)

  timestampEMG = struct();

  coounterannotations = fieldnames(emgCounterReference);

  if sum(strcmpi(fieldnames(emgCounterReference),'TimeFromStart'))>0
    timestampEMG.Counter = emgCounterReference.TimeFromStart;
  elseif sum(strcmpi(fieldnames(emgCounterReference),'x___time_stamp'))>0
    timestampEMG.Counter = emgCounterReference.x___time_stamp;
  elseif sum(strcmpi(fieldnames(emgCounterReference),'time_stamp'))>0
    timestampEMG.Counter = emgCounterReference.x___time_stamp;
  else
    disp('Error log:')
    disp('EMG annotations file field names:')
    disp(fieldnames(emgCounterReference))
    error('Could not find field for counter time stamp. Exiting')
  end
  
  timestampEMG.Reach = timestampEMG.Counter;
  timestampEMG.StartStop = timestampEMG.Counter;
  
  for i=1:size(record,1)
    emgData(i,:,:) = emgSelect(record(i,:), timestampEMG.StartStop, padding, emgSamplingFrequency);
  end