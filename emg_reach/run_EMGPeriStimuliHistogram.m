% load('/Users/chico/Downloads/emgfiles/18LLR_ONI_S_N_26_20180607T1515_AnalyzedEMG.mat');
load('/Users/chico/Downloads/day4files/18LLR_Day4_OFF_AnalyzedEMG.mat')

emgSamplingFrequency = 2000; %Hz
videoSamplingFrequency = 250;%; %Hz
channels = 1:3; % 1, 2, 2:3, [1,3]

binSize = 10/1000; % 10 ms
timeBeforeReference = 0; % 0 s
timeAfterReference  = 0.2; % 200 ms

refEvent = 'Reach';

[N1,edges1,numBins1,PSTH1] = emgPeriStimuliHistogram(emgAnalyzed, refEvent, timeBeforeReference, timeAfterReference, binSize, emgSamplingFrequency, channels);

% refEvent = 'LaserLightOn';
% timeBeforeReference = 0; % 0 s
% timeAfterReference  = 0; % 0 s

% [N2,edges2,numBins2,PSTH2] = emgPeriStimuliHistogram(emgAnalyzed, refEvent, timeBeforeReference, timeAfterReference, binSize, emgSamplingFrequency, channels);
