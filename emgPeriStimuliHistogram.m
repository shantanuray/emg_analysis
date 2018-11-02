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
  refEventTimestamp = (((size(emgAnalyzed.Average,3)-1)/2)+1)/emgSamplingFrequency;
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

%numBins = [refEventSamples(2) - refEventSamples(1)]/binSamples;
edges = 0:binSamples:refEventSamples(2) - refEventSamples(1);

% Get the EMG data for all channels (1st DIM) and all annotations files (2nd DIM)
% for the sampling range (3rd DIM)
emgAll = emgAnalyzed.Average(:,:,refEventSamples(1)+1:refEventSamples(2));

for i = channels            % Channels (1st DIM)
  for j = 1:size(emgAll,2)  % Annotations files (2nd DIM)
    % [N(i,:),edges(i,:)] = histcounts(emg_lighton(i,1,:),num_bins);
    % r = N(i,:)/bin_size; % Frequency? Not sure if this is a good idea
    % figure;
    % ph=bar(edges(i,1:end-1),r(1:end)); % Same as histogram plot
    emg = reshape(emgAll(i,j,:), size(emgAll,1), size(emgAll,3)); % Just for simplicity
    % Mark timestamp where EMG is greater than threshold
    threshold = mean(emg); %0.2*max(emg(i,:));
    [pks,locs] = findpeaks(emg);    % Find the peaks and peak location of the EMG
    X = locs(find(pks>threshold));  % Get the peak location > threshold (=> sample number => timestamp)
    h=figure('Name',['Channel: ' num2str(i) '; File: ' num2str(j)]);
    axes1 = axes('Parent',h);
    hold(axes1,'on');
    % Histogram will then count timestamps in the given bin where EMG>threshold
    % i.e. Frequency of spikes
    PSTH(i,j) = histogram(X, edges);
    xtickValue = 0:0.05*emgSamplingFrequency:refEventSamples(2) - refEventSamples(1);
    xtickLabel = cellstr(num2str((-timeBeforeReference:0.05:timeAfterReference)'*1000));
    ytickValue = get(axes1,'YTick')/binSize; % Convert to frequency - observation/binSize
    ytickLabel = cellstr(num2str(ytickValue));
    set(axes1,'XTick',xtickValue,'XTickLabel',xtickLabel,'YTick',ytickValue,'YTickLabel',ytickLabel);
    N(i,j,:) = get(PSTH(i,j),'Values')/binSize;
  end
end
numBins = get(PSTH(i,j),'NumBins');