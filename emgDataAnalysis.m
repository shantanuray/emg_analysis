function emgAnalyzed = emgDataAnalysis(emgCleanData,annotations,emgBaseline,emgSamplingFrequency,timestampEMG)

  activityStart=0.2;
  activityEnd=0.6;
  movingAverageWindow=25/1000;
  removewindow=0.1;
  % Remove window of 0.1
  removewindow = round(removewindow*emgSamplingFrequency);

  emgAnalyzed.RawData = emgCleanData(:,:,removewindow+1:size(emgCleanData,3)-removewindow);

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

  % Reference (reach position is center of the window)
  reachpos = ceil(size(emgAnalyzed.RawData,3)/2);
  % Compute peak and peak time in the raw signal
  for i = 1:size(emgAnalyzed.RawAverage,1)
    for j = 1:size(emgAnalyzed.RawAverage,2)
      emgAnalyzed.ReachNumber(i,j) = annotations.Index(j);
      initpos = reachpos+round((timestampEMG.Initialize(j)-timestampEMG.Reach(j))*emgSamplingFrequency);
      emgAnalyzed.ReachTimestamp(i,j) = reachpos/emgSamplingFrequency;
      emgAnalyzed.InitializeTimestamp(i,j) = initpos/emgSamplingFrequency;
      emgAnalyzed.CrossDoorwayTimeStamp(i,j) = timestampEMG.Initialize(j)-timestampEMG.Reach(j)+emgAnalyzed.ReachTimestamp(i,j);
      emgAnalyzed.GraspTimestamp(i,j) = timestampEMG.Grasp(j)-timestampEMG.Reach(j)+emgAnalyzed.ReachTimestamp(i,j);
      emgAnalyzed.RetrieveTimestamp(i,j) = timestampEMG.Retrieve(j)-timestampEMG.Reach(j)+emgAnalyzed.ReachTimestamp(i,j);
      emgAnalyzed.LaserLightOnTimestamp(i,j) = timestampEMG.LaserLightOn(j)-timestampEMG.Reach(j)+emgAnalyzed.ReachTimestamp(i,j);
      emgAnalyzed.LaserLightOffTimestamp(i,j) = timestampEMG.LaserLightOff(j)-timestampEMG.Reach(j)+emgAnalyzed.ReachTimestamp(i,j);
      emgAnalyzed.TimeToPeakms(i,j) = (emgAnalyzed.ReachTimestamp(i,j)-emgAnalyzed.InitializeTimestamp(i,j))*1000;
      emgAnalyzed.PeakValueRawAverage(i,j) = max(emgAnalyzed.RawAverage(i,j,initpos:end),[],3);
      closestpeak = find(emgAnalyzed.RawAverage(i,j,initpos:end)==emgAnalyzed.PeakValueRawAverage(i,j),1);
      emgAnalyzed.ClosestPeakPosition(i,j) = closestpeak+initpos;
      emgAnalyzed.ClosestPeakTimestamp(i,j) = (closestpeak+initpos)/emgSamplingFrequency;
      emgAnalyzed.TimeToPeak(i,j) = closestpeak/emgSamplingFrequency;
    end
  end

  % Computes area under curve for each annotation using normalized raw data
  emgAnalyzed.AreaUnderCurveNormalized=trapz((0:size(emgAnalyzed.RawData,3)-1)/emgSamplingFrequency,...
    (emgAnalyzed.RawData./emgAnalyzed.Baseline),3);
  emgAnalyzed.AreaUnderCurveNormalized1=trapz((0:size(emgAnalyzed.RawData,3)-1)/emgSamplingFrequency,...
    (emgAnalyzed.RawData./emgAnalyzed.Baseline1),3);

  % Compute the average voltage at each time point for all annotations
  emgAnalyzed.Average = sum(emgAnalyzed.RawData, 2)/size(emgAnalyzed.RawData,2);

  % Computes the moving average for a fixed window eg. 25 ms. Useful to find gradual trends in data
  emgAnalyzed.MovingAverage = movingAverage(emgAnalyzed.Average,movingAverageWindow,emgSamplingFrequency,3);