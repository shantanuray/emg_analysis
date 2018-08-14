function [emgData,timestampEMG] = emgExtractFromReach(record,annotations,emgCounterReference,videoSamplingFrequency,emgSamplingFrequency,padding)

  timestampEMG = struct();
  for i = 1:length(annotations.Reach)
    emgrefpos_ = find(strcmpi(emgCounterReference.Animal,annotations.Animal(i))&...
        emgCounterReference.Date==annotations.Date(i) & ...
        emgCounterReference.CounterStartPoint==annotations.LEDCounter(i));
    if length(emgrefpos_)~=1
      error(['Issue with annotations in row ', i, '. ', length(emgrefpos), 'matches found in emg reference. Skipping row'])
    end
    emgrefpos(i) = emgrefpos_;
  end
  
  timestampEMG.Counter = emgCounterReference.TimeFromStart(emgrefpos);
  timestampEMG.Initialize = (annotations.Initialize-annotations.LEDCounterFrame)/videoSamplingFrequency+timestampEMG.Counter;
  timestampEMG.CrossDoorway = (annotations.CrossDoorway-annotations.LEDCounterFrame)/videoSamplingFrequency+timestampEMG.Counter;
  timestampEMG.Reach = (annotations.Reach-annotations.LEDCounterFrame)/videoSamplingFrequency+timestampEMG.Counter;
  timestampEMG.Grasp = (annotations.Grasp-annotations.LEDCounterFrame)/videoSamplingFrequency+timestampEMG.Counter;
  timestampEMG.Retrieve = (annotations.Retrieve-annotations.LEDCounterFrame)/videoSamplingFrequency+timestampEMG.Counter;
  timestampEMG.LaserLightOn = (annotations.LaserLightOn-annotations.LEDCounterFrame)/videoSamplingFrequency+timestampEMG.Counter;
  timestampEMG.LaserLightOff = (annotations.LaserLightOff-annotations.LEDCounterFrame)/videoSamplingFrequency+timestampEMG.Counter;
  timestampEMG.StartStop = timestampEMG.Reach;
  
  for i=1:size(record,1)
    emgData(i,:,:) = emgSelect(record(i,:), timestampEMG.StartStop, padding, emgSamplingFrequency);
  end