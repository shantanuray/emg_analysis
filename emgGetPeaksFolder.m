function [peakData, peakMetrics, peakDistances] = emgGetPeaksFolder(emgData, varargin)
    % peakData = emgGetPeaksFolder(emgData, channels, segments);
    % [peakData, peakMetrics, peakDistances] = emgGetPeaksFolder(emgData);
    % Run get_peaks on filtered EMG signal for entire folder
    %			  for each channel, filtered and separated into segments
    % emgData	- EMG data with raw signal
    % peakData  - Replicates structure of EMG data sans the actual raw data
    % peakMetrics - double [# files in folder, # channels, # segments, # metrics]
    %			   Metrics	[averageFrequency, averagePeakDistance, averagePeakAmplitude,
    %						 peakDistanceStdDev, peakAmplitudeStdDev]
    % peakDistances - cell {# channels, # segments} with peak distances from all the files for (chan,seg)
    %
    % Parameters:
    % channels - {'bi', 'tri', 'ecu', 'trap'}
    % segments - {'discrete', 'rhythmic'}
    % minPeakDistance - for find_peaks: 100ms (0.1)
    % rmsPctCutoff - RMS cut off for min peak height: Default skip (NaN)

    p = readInput(varargin);
    [channels, segments, minPeakDistance, rmsPctCutoff] = parseInput(p.Results);
    peakMetrics = NaN(length(emgData), length(channels), length(segments), 5);
    peakDistances = cell(length(channels), length(segments));
    peakData = emgData;

	for i = 1:length(emgData)
		for j = 1:length(channels)
			peakData(i).(channels{j}) = rmfield(peakData(i).(channels{j}), 'raw');
			if ~isempty(emgData(i).(channels{j}))
				for k = 1:length(segments)
					if isfield(emgData(i).(channels{j}), segments{k})
						if isfield(emgData(i).(channels{j}).(segments{k}), 'mva')
							disp(sprintf('Get peaks for %s channel %s segment %s', emgData(i).fileID, channels{j}, segments{k}))
							fs = emgData(i).(channels{j}).samplingFrequency;
							data = emgData(i).(channels{j}).(segments{k}).raw;
							peakData(i).(channels{j}).(segments{k}) = rmfield(peakData(i).(channels{j}).(segments{k}), 'raw');
							% rectify bipolar emg signals
							data = abs(data);
							% Moving average filter
							data = movingAverage(data, moving_average_window, fs);
							L = length(data);
							[pks, idx] = getPeaks(data, fs, 'minPeakDistance', minPeakDistance, 'rmsPctCutoff', rmsPctCutoff);
							emgData(i).(channels{j}).(segments{k}).peakAmplitude = pks;
							emgData(i).(channels{j}).(segments{k}).peakLocation = idx;
							[pk_freq, pk_dist, pk_amp, pk_dist_std, pk_amp_std] = peakAnalysis(idx, pks, fs, L);
							emgData(i).(channels{j}).(segments{k}).averageFrequency = pk_freq;
							emgData(i).(channels{j}).(segments{k}).averagePeakDistance = pk_dist;
							emgData(i).(channels{j}).(segments{k}).averagePeakAmplitude = pk_amp;
							emgData(i).(channels{j}).(segments{k}).peakDistanceStdDev = pk_dist_std;
							emgData(i).(channels{j}).(segments{k}).peakAmplitudeStdDev = pk_amp_std;
							peakMetrics(i,j,k,:) = [pk_freq, pk_dist, pk_amp, pk_dist_std, pk_amp_std];
							peakDistances{j,k} = [peakDistances{j,k};(idx(2:end)-idx(1:end-1))/fs];
						end
					endif
				endfor
			endif
		endfor
	endfor

	 %% Read input
    function p = readInput(input)
        %   - segments 				Default - {'discrete', 'rhythmic'}
        %   - channels              Default - {'bi','tri','trap','ecu'}
        %   - minPeakDistance     	Default - 100/1000; % 100ms
        %   - rmsPctCutoff       	Default - nan
        p = inputParser;
        channels = {'bi','tri','trap','ecu'};
        segments = {'discrete', 'rhythmic'};
        minPeakDistance = 100/1000;
        rmsPctCutoff = NaN;
        
        addParameter(p,'channels',channels, @iscell);
        addParameter(p,'segments',segments, @iscell);
        addParameter(p,'minPeakDistance',minPeakDistance, @isnumeric);
        addParameter(p,'rmsPctCutoff',rmsPctCutoff, @isnumeric);
        parse(p, input{:});
    end

    function [channels, segments, minPeakDistance, rmsPctCutoff] = parseInput(p)
        channels = p.channels;
        segments = p.segments;
        minPeakDistance = p.minPeakDistance;
        rmsPctCutoff = p.rmsPctCutoff;
    end
end