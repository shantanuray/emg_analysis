annotationFile = '/Users/chico/Downloads/emg/18LLR_OFF_annotations.xlsx';
[emgPathName, annotationFilename] = fileparts(annotationFile);

annotations = readtable(annotationFile);
emgCounterReference = readtable('/Users/chico/Downloads/emg/annotations_18LLR_22UN_Master.txt');

emgSamplingFrequency = 2000; %Hz
videoSamplingFrequency = 25; %Hz
padding = 0.5; % 0.5s
movingAverageWindow = 25/1000; % 25ms
baselineEnd = 0.2; % 0.2s

[emgData,timestampEMG] = emgExtractFromAnnotations(annotations,emgCounterReference,emgPathName,emgSamplingFrequency,videoSamplingFrequency,padding);
save(fullfile(emgPathName,[annotationFilename,'_RawEMG_All.mat']),'emgData');

[emgDataPlot,timestampEMG,xPlot] = emgDataWindow(emgData,annotations,timestampEMG,emgSamplingFrequency);
save(fullfile(emgPathName,[annotationFilename,'_RawEMG_TimeWindow.mat']),'emgDataPlot');

emgAnalyzed = emgDataAnalysis(emgDataPlot,emgSamplingFrequency,baselineEnd,movingAverageWindow);
save(fullfile(emgPathName,[annotationFilename,'_AnalyzedEMG.mat']),'emgAnalyzed');

h=figure;
subplot(3,1,1)
plot(xPlot(201:end),emgAnalyzed.Average(201:end,1),'b-')
hold on
plot(xPlot(201:end),emgAnalyzed.MovingAverage(201:end,1),'r-')
subplot(3,1,2)
plot(xPlot(201:end),emgAnalyzed.Average(201:end,2),'b-')
hold on
plot(xPlot(201:end),emgAnalyzed.MovingAverage(201:end,2),'r-')
subplot(3,1,3)
plot(xPlot(201:end),emgAnalyzed.Average(201:end,3),'b-')
hold on
plot(xPlot(201:end),emgAnalyzed.MovingAverage(201:end,3),'r-')
hold on