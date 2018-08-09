function [emgData,timestampEMG] = emgExtractFromAnnotations(annotations,emgCounterReference,emgPathName,emgSamplingFrequency,videoSamplingFrequency,padding)

frameCountStartStop = [min([annotations.Initialize, annotations.LaserLightOn, annotations.LaserLightOff], [],2),...
  max([annotations.Reach, annotations.LaserLightOn, annotations.LaserLightOff], [],2)];

frameCountReference = [annotations.LEDCounter, annotations.LEDCounterFrame];

timestampEMG = struct();
for i = 1:length(annotations.Reach)
  refpos = find(strcmpi(emgCounterReference.Animal,annotations.Animal{i})&annotations.Date(i)==emgCounterReference.Date&annotations.LEDCounter(i)==emgCounterReference.CounterStartPoint);
  if length(refpos)~=1
    warning(['Issue with annotations in row ', i, '. ', length(refpos), 'matches found in emg reference. Skipping row'])
    continue
  end
  timestampEMG.Ref(i) = emgCounterReference.TimeFromStart(refpos);
  timestampEMG.Reach(i) = (annotations.Reach(i)-annotations.LEDCounterFrame(i))/videoSamplingFrequency+timestampEMG.Ref(i);
  timestampEMG.StartStop = (frameCountStartStop(i,:)-annotations.LEDCounterFrame(i))/videoSamplingFrequency+timestampEMG.Ref(i);
  timestampEMG.StartStopNormalized(i,:) = timestampEMG.StartStop+[-1,1].*padding-timestampEMG.Reach(i);

  % Assumption emg filename is export_18LLR_20180622.edf
  emgFilename = fullfile(emgPathName,...
    ['export_',annotations.Animal{i},'_',num2str(annotations.Date(i)),'.edf']);
  emgData{i} = emgRetrieve(emgFilename, timestampEMG.StartStop,padding,0.025,emgSamplingFrequency);
end