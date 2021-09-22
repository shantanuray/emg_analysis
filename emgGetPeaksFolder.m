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
    % movingAverageWindow - for filtering: 100 ms (0.1)
    % minPeakDistance - for find_peaks: 100ms (0.1)
    % rmsPctCutoff - RMS cut off for min peak height: Default skip (NaN)

    p = readInput(varargin);
    [channels, segments, filterType, passbandFrequency, filterOrder, passbandRipple, movingAverageWindow, minPeakDistance, rmsPctCutoff] = parseInput(p.Results);
    peakMetrics = NaN(length(emgData), length(channels), length(segments), 5);
    peakDistances = cell(length(channels), length(segments));
    peakData = emgData;
    fs = NaN;
    while isnan(fs) | isempty(fs)
    	for i = 1:length(emgData)
    		for j = 1:length(channels)
    			fs = emgData(i).(channels{j}).samplingFrequency;
    		end
    	end
    end
    if filterType=='iir'
    	loFilt = designfilt('lowpassiir','FilterOrder',filterOrder, ...
    	         			'PassbandFrequency',passbandFrequency(1), 'PassbandRipple',passbandRipple, ...
    	         			'SampleRate',fs);
    	hiFilt = designfilt('highpassiir','FilterOrder',filterOrder, ...
    	         			'PassbandFrequency',passbandFrequency(2), 'PassbandRipple',passbandRipple, ...
    	         			'SampleRate',fs);
    end


	for i = 1:length(emgData)
		for j = 1:length(channels)
			peakData(i).(channels{j}) = rmfield(peakData(i).(channels{j}), 'raw');
			if ~isempty(emgData(i).(channels{j}))
				for k = 1:length(segments)
					if isfield(emgData(i).(channels{j}), segments{k})
						if isfield(emgData(i).(channels{j}).(segments{k}), 'raw')
							disp(sprintf('Get peaks for %s channel %s segment %s', emgData(i).fileID, channels{j}, segments{k}))
							fs = emgData(i).(channels{j}).samplingFrequency;
							data = emgData(i).(channels{j}).(segments{k}).raw;
							peakData(i).(channels{j}).(segments{k}) = rmfield(peakData(i).(channels{j}).(segments{k}), 'raw');
							if ~isempty(data)
								% if IIR filter, high pass 50hz before rectification
								if filterType=='iir'
									data = filter(hiFilt,data);
									peakData(i).(channels{j}).(segments{k}).HiPassBand = passbandFrequency(1);
								end
								% rectify bipolar emg signals
								data = abs(data);
								if filterType=='mva'
									% Moving average filter
									peakData(i).(channels{j}).(segments{k}).movingAverageWindow = movingAverageWindow;
									data = movingAverage(data, movingAverageWindow, fs);
								elseif filterType=='iir'
									% if IIR filter, low pass 30hz after rectification
									data = filter(loFilt,data);
									peakData(i).(channels{j}).(segments{k}).HiPassBand = passbandFrequency(2);
								end
								L = length(data);
								% Get peaks
								peakData(i).(channels{j}).(segments{k}).minPeakDistance = minPeakDistance;
								peakData(i).(channels{j}).(segments{k}).rmsPctCutoff = rmsPctCutoff;
								[pks, idx] = emgGetPeaks(data, fs, 'minPeakDistance', minPeakDistance, 'rmsPctCutoff', rmsPctCutoff);
								peakData(i).(channels{j}).(segments{k}).peakAmplitude = pks;
								peakData(i).(channels{j}).(segments{k}).peakLocation = idx;
								[pk_freq, pk_dist, pk_amp, pk_dist_std, pk_amp_std] = peakAnalysis(idx, pks, fs, L);
								peakData(i).(channels{j}).(segments{k}).averageFrequency = pk_freq;
								peakData(i).(channels{j}).(segments{k}).averagePeakDistance = pk_dist;
								peakData(i).(channels{j}).(segments{k}).averagePeakAmplitude = pk_amp;
								peakData(i).(channels{j}).(segments{k}).peakDistanceStdDev = pk_dist_std;
								peakData(i).(channels{j}).(segments{k}).peakAmplitudeStdDev = pk_amp_std;
								peakMetrics(i,j,k,:) = [pk_freq, pk_dist, pk_amp, pk_dist_std, pk_amp_std];
								peakDistances{j,k} = [peakDistances{j,k};(idx(2:end)-idx(1:end-1))/fs];
							end
						end
					end
				end
			end
		end
	end

	%% Read input
    function p = readInput(input)
        %   - segments 				Default - {'discrete', 'rhythmic'}
        %   - channels              Default - {'bi','tri','trap','ecu'}
        %	- movingAverageWindow 	Default - 100/1000; % 100ms
        %   - minPeakDistance     	Default - 100/1000; % 100ms
        %   - rmsPctCutoff       	Default - nan
        p = inputParser;
        channels = {'bi','tri','trap','ecu'};
        segments = {'discrete', 'rhythmic'};
        filterType = 'iir';
        validFilters = {'mva','iir'};
        checkFilter = @(x) any(validatestring(x,validFilters));
        passbandFrequency = [30, 50];
        filterOrder = 4;
        passbandRipple = 0.2;
        movingAverageWindow = 100/1000;
        minPeakDistance = 150/1000;
        rmsPctCutoff = 1;
        
        addParameter(p,'channels',channels, @iscell);
        addParameter(p,'segments',segments, @iscell);
        addParameter(p,'filterType',filterType, checkFilter);
        addParameter(p,'passbandFrequency',passbandFrequency);
        addParameter(p,'filterOrder',filterOrder, @isnumeric);
        addParameter(p,'passbandRipple',passbandRipple, @isnumeric);
        addParameter(p,'movingAverageWindow',movingAverageWindow, @isnumeric);
        addParameter(p,'minPeakDistance',minPeakDistance, @isnumeric);
        addParameter(p,'rmsPctCutoff',rmsPctCutoff, @isnumeric);
        parse(p, input{:});
    end

    function [channels, segments, filterType, passbandFrequency, filterOrder, passbandRipple, movingAverageWindow, minPeakDistance, rmsPctCutoff] = parseInput(p)
        channels = p.channels;
        segments = p.segments;
        filterType = p.filterType;
		passbandFrequency = p.passbandFrequency;
		filterOrder = p.filterOrder;
		passbandRipple = p.passbandRipple;
        movingAverageWindow = p.movingAverageWindow;
        minPeakDistance = p.minPeakDistance;
        rmsPctCutoff = p.rmsPctCutoff;
    end

end