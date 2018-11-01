function [N,edges,numBins,PSTH] = emgPeriStimuliHistogram(emgAnalyzed, refEvent, timeBeforeReference, timeAfterReference, binSize, emgSamplingFrequency,channels)
% [N,edges,numBins,PSTH] = emgPeriStimuliHistogram(emgAnalyzed, refEvent, timeBeforeReference, timeAfterReference, binSize, emgSamplingFrequency, channels)
% Plots the Peri-Stimuli Histogram of EMG signal around a reference event such as 
% Reach, LaserLightOn. It depends on previously done EMG analysis.
% See - emgDataAnalysis.m
%  
% Returns [N,edges,numBins,PSTH] histogram (PSTH) of numBins bins with "edges"
%
% Input:
% emgAnalyzed - Output from emgDataAnalysis
% refEvent    - Event name to extract EMG signal for histogram (LaserLightOn, Reach)
% timeBeforeReference, timeAfterReference - Time in seconds before and after refEvent
% binSize     - Size of each bin (0.01s)
% emgSamplingFrequency  - Sampling frequency of EMG signal (2000 Hz)
% channels    - EMG channel (1:3)

binSamples = round(binSize*emgSamplingFrequency,0);

% Note that emgDataAnalysis.m saves Timestamps for all channels
% But in essence, they are the same across the channels
% So here we choose the channel = 1
if isfield(emgAnalyzed, [refEvent,'Timestamp'])
  refEventTimestamp = getfield(emgAnalyzed, [refEvent,'Timestamp']);
else
  disp('-------- WARNING --------')
  disp(['Recording does not have ', refEvent,' Timestamp. Choosing center of recording.'])
  refEventTimestamp = size(emgAnalyzed.Average,3)/emgSamplingFrequency/2;
end;

% Reference event timestamps could vary from one recording to another
% So we take standard deviation around the mean to include all values

% Get the average of the reference event timestamps (in seconds) 
% for channel = 1 across dim = 2
refEventMean = mean(refEventTimestamp(1,:), 2);
% Get the standard deviation of the reference event timestamps (in seconds) 
% for channel = 1 across dim = 2 and W = 0
refEventSTD = std(refEventTimestamp(1,:), 0, 2);

% Sampling range is simply the mean - std_dev - timeBeforeReference : 
%                              mean + std_dev + timeAfterReference
refEventRange = refEventMean + [-1 1]*refEventSTD + [-timeBeforeReference timeAfterReference];

% Convert the sampling range to number of samples
% To get equal bins of size binSamples, we divide and then multiply by binSamples
refEventSamples = round(refEventRange*emgSamplingFrequency/binSamples,0)*binSamples;

numBins = [refEventSamples(2) - refEventSamples(1)]/binSamples;

emg = emgAnalyzed.Average(:,:,refEventSamples(1)+1:refEventSamples(2));

for i = channels
  % [N(i,:),edges(i,:)] = histcounts(emg_lighton(i,1,:),num_bins);
  % r = N(i,:)/bin_size; % Frequency? Not sure if this is a good idea
  % figure;
  % ph=bar(edges(i,1:end-1),r(1:end)); % Same as histogram plot
  figure;
  PSTH(i) = histogram(emg(i,1,:), numBins);
  N(i,:) = get(PSTH(i),'Values');
  edges(i,:) = get(PSTH(i),'BinEdges');
end