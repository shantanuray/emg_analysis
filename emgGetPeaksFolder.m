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
    	for row = 1:length(emgData)
    		for chan = 1:length(channels)
    			fs = emgData(row).(channels{chan}).samplingFrequency;
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


	for row = 1:length(emgData)
		for chan = 1:length(channels)
			peakData(row).(channels{chan}) = rmfield(peakData(row).(channels{chan}), 'raw');
			if ~isempty(emgData(row).(channels{chan}))
				for seg = 1:length(segments)
					if isfield(emgData(row).(channels{chan}), segments{seg})
						if isfield(emgData(row).(channels{chan}).(segments{seg}), 'raw')
							disp(sprintf('Get peaks for %s channel %s segment %s', emgData(row).fileID, channels{chan}, segments{seg}))
							fs = emgData(row).(channels{chan}).samplingFrequency;
							data = emgData(row).(channels{chan}).(segments{seg}).raw;
							peakData(row).(channels{chan}).(segments{seg}) = rmfield(peakData(row).(channels{chan}).(segments{seg}), 'raw');
							if ~isempty(data)
								% if IIR filter, high pass 50hz before rectification
								if filterType=='iir'
									data = filter(hiFilt,data);
									peakData(row).(channels{chan}).(segments{seg}).HiPassBand = passbandFrequency(1);
								end
								% rectify bipolar emg signals
								data = abs(data);
								if filterType=='mva'
									% Moving average filter
									peakData(row).(channels{chan}).(segments{seg}).movingAverageWindow = movingAverageWindow;
									data = movingAverage(data, movingAverageWindow, fs);
								elseif filterType=='iir'
									% if IIR filter, low pass 30hz after rectification
									data = filter(loFilt,data);
									peakData(row).(channels{chan}).(segments{seg}).HiPassBand = passbandFrequency(2);
								end
								L = length(data);
								% Get peaks
								peakData(row).(channels{chan}).(segments{seg}).minPeakDistance = minPeakDistance;
								peakData(row).(channels{chan}).(segments{seg}).rmsPctCutoff = rmsPctCutoff;
								[pks, idx] = emgGetPeaks(data, fs, 'minPeakDistance', minPeakDistance, 'rmsPctCutoff', rmsPctCutoff);
								peakData(row).(channels{chan}).(segments{seg}).peakAmplitude = pks;
								peakData(row).(channels{chan}).(segments{seg}).peakLocation = idx;
								peakData(row).(channels{chan}).(segments{seg}).peakTime = idx/fs;
								[pk_freq, pk_dist, pk_amp, pk_dist_std, pk_amp_std] = peakAnalysis(idx, pks, fs, L);
								peakData(row).(channels{chan}).(segments{seg}).averageFrequency = pk_freq;
								peakData(row).(channels{chan}).(segments{seg}).averagePeakDistance = pk_dist;
								peakData(row).(channels{chan}).(segments{seg}).averagePeakAmplitude = pk_amp;
								peakData(row).(channels{chan}).(segments{seg}).peakDistanceStdDev = pk_dist_std;
								peakData(row).(channels{chan}).(segments{seg}).peakAmplitudeStdDev = pk_amp_std;
								peakMetrics(row,chan,seg,:) = [pk_freq, pk_dist, pk_amp, pk_dist_std, pk_amp_std];
								peakDistances{chan,seg} = [peakDistances{chan,seg};(idx(2:end)-idx(1:end-1))/fs];
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