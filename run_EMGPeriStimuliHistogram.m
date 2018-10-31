load('/Users/chico/Downloads/emgfiles/18LLR_ONI_S_N_26_20180607T1515_AnalyzedEMG.mat');

emgSamplingFrequency = 2000; %Hz
videoSamplingFrequency = 250;%; %Hz
channels = 1:3;

binSize = 10/1000; 
timeBeforeReference = 0;
timeAfterReference  = 0.2;

refEvent = 'Reach';

[N1,edges1,numBins1,PSTH1] = emgPeriStimuliHistogram(emgAnalyzed, refEvent, timeBeforeReference, timeAfterReference, binSize, emgSamplingFrequency, channels);

refEvent = 'LaserLightOn';
[N2,edges2,numBins2,PSTH2] = emgPeriStimuliHistogram(emgAnalyzed, refEvent, timeBeforeReference, timeAfterReference, binSize, emgSamplingFrequency, channels);
