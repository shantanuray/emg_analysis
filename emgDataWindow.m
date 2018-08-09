function [emgDataPlot,timestampEMG,xPlot] = emgDataWindow(emgData,annotations,timestampEMG,emgSamplingFrequency)

% Calculate a consistent time-window wrt reach that all reach emg data will have
% This has to be done because frameCountStartStop is different for each reach
% Since reach is the reference and padding has been added to the frameCountStartStop,
% the smallest possible time-window will always be [reach-0.5:reach+0.5]
timestampEMG.Window = [max(timestampEMG.StartStopNormalized(:,1)), max(timestampEMG.StartStopNormalized(:,2))];
numsamplesPlot=((timestampEMG.Window(2)-timestampEMG.Window(1))*emgSamplingFrequency);
xPlot=timestampEMG.Window(1):(timestampEMG.Window(2)-(timestampEMG.Window(1)))/(numsamplesPlot):(timestampEMG.Window(2));

emgDataPlot = [];
for i = 1:length(annotations.Reach)
  % Get actual number of samples
  numbersamples = size(emgData{i},2);
  % Pick out the samples that correspond to the consistent time-window calculated above
  yRange = [1 numbersamples]+((timestampEMG.Window-timestampEMG.StartStopNormalized(i,:))*emgSamplingFrequency);
  yPlot = emgData{i}(:,int16(yRange(1):yRange(2)));
  yPlot = yPlot(:,1:length(xPlot)); % Hack: Just to make x and y dim the same
  % Concatenate each row - we are adding data in 3-D to accommodate the channels
  % i.e. [time-window x channel x reach]
  emgDataPlot = cat(3, emgDataPlot, yPlot');
end