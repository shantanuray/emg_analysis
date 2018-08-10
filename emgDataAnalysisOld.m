function emgAnalyzed = emgDataAnalysisOld(emgRawData,samplingFrequency,baselineEnd,movingAverageWindow)

  % Compute baseline for each row from 0th to 0.2 of the time window
  baselineStartSamples = 0*samplingFrequency+1;
  baselineEndSamples = baselineEnd*samplingFrequency;

  emgAnalyzed.Baseline = emgRawData(:,:,int16(baselineStartSamples:baselineEndSamples));
  emgAnalyzed.Baseline = mean(emgAnalyzed.Baseline,3);

  % Compute mVolt activity within the reach
  activityStart = baselineEndSamples+1;

  emgAnalyzed.Active = emgRawData(:,:,int16(activityStart:end));
  emgAnalyzed.Active = mean(emgAnalyzed.Active,3);

  % Compute %fold change
  emgAnalyzed.FoldChange = ((emgAnalyzed.Active-emgAnalyzed.Baseline)./emgAnalyzed.Baseline)*100;

  % Compute the average voltage at each time point for all annotations
  emgAnalyzed.Average = mean(emgRawData, 2);

  % Computes the moving average for a fixed window eg. 25 ms. Useful to find gradual trends in data
  emgAnalyzed.MovingAverage = movingAverage(emgAnalyzed.Average,movingAverageWindow,samplingFrequency,3);

  % Computes area under curve for each annotation
  emgAnalyzed.AreaUnderCurve=reshape(trapz((0:size(emgRawData,3)-1)/samplingFrequency,emgRawData,3),size(emgRawData,1),size(emgRawData,2));