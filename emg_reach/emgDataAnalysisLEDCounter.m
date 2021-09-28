function emgAnalyzed = emgDataAnalysisLEDCounter(emgRawData,emgBaseline,emgSamplingFrequency,timestampEMG)

  activityStart=0.2;
  activityEnd=0.6;
  movingAverageWindow=25/1000;
  removewindow=0.1;
  % Remove window of 0.1
  removewindow = round(removewindow*emgSamplingFrequency);

  emgAnalyzed.RawData = emgRawData(:,:,removewindow+1:size(emgRawData,3)-removewindow);
  % Compute mVolt activity within the reach
  
  activityStart = round(activityStart*emgSamplingFrequency)+1;
  % Compute baseline for each row from 0th to 0.2 of the time window
  emgAnalyzed.Baseline = mean(emgBaseline,2);
  emgAnalyzed.Baseline1 = emgAnalyzed.RawData(:,:,1:activityStart-1);
  emgAnalyzed.Baseline1 = mean(emgAnalyzed.Baseline1,3);

  emgAnalyzed.Active = emgAnalyzed.RawData(:,:,int16(activityStart:end));
  emgAnalyzed.Active = mean(emgAnalyzed.Active,3);

  % Compute %fold change
  emgAnalyzed.FoldChangeMean = (emgAnalyzed.Active./emgAnalyzed.Baseline);
  emgAnalyzed.FoldChangeMean1 = (emgAnalyzed.Active./emgAnalyzed.Baseline1);

  % Compute the moving average of the raw data
  emgAnalyzed.RawAverage = movingAverage(emgAnalyzed.RawData,movingAverageWindow,emgSamplingFrequency,3);

  % Computes area under curve for each annotation using normalized raw data
  emgAnalyzed.AreaUnderCurveNormalized=trapz((0:size(emgAnalyzed.RawData,3)-1)/emgSamplingFrequency,...
    (emgAnalyzed.RawData./emgAnalyzed.Baseline),3);
  emgAnalyzed.AreaUnderCurveNormalized1=trapz((0:size(emgAnalyzed.RawData,3)-1)/emgSamplingFrequency,...
    (emgAnalyzed.RawData./emgAnalyzed.Baseline1),3);

  % Compute the average voltage at each time point for all annotations
  emgAnalyzed.Average = mean(emgAnalyzed.RawData, 2);

  % Computes the moving average for a fixed window eg. 25 ms. Useful to find gradual trends in data
  emgAnalyzed.MovingAverage = movingAverage(emgAnalyzed.Average,movingAverageWindow,emgSamplingFrequency,3);