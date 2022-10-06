function [peakData, peakMetrics, peakDistances, peakAmplitudes] = emgGetPeaksFolder(emgData, varargin)
    % peakData = emgGetPeaksFolder(emgData, channels, segments);
    % [peakData, peakMetrics, peakDistances] = emgGetPeaksFolder(emgData);
    % [peakData, peakMetrics, peakDistances, peakAmplitudes] = emgGetPeaksFolder(emgData, 'channels', {'bi_R','tri_R','bi_L','tri_L'}, 'segments', {'data_raw', 'data_smooth'}, 'filterType', 'na');
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
    % Parameters:
    % channels - {'bi', 'tri', 'trap', 'ecu'}
    % segments - {'discrete', 'rhythmic'}
    % movingAverageWindow - for filtering: 100 ms (0.1)
    % minPeakDistance - for find_peaks: 150ms (0.15)
    % rmsPctCutoff - RMS cut off for min peak height: Default 1
    % filterType - 'iir' (lo - 30Hz, hi - 50Hz)
    % emgDataLabel - 'raw' or 'data'

    p = readInput(varargin);
    [channels, segments, filterConfig, minPeakDistance, rmsPctCutoff, widthReference, emgDataLabel] = parseInput(p.Results);

    %% Init output

    % peak metrics consist of [averageFrequency, averagePeakDistance, averagePeakAmplitude,
    %						   peakDistanceStdDev, peakAmplitudeStdDev]
    % 4-D matrix [length(emgData), length(channels), length(segments), # of metrics(5)]
    peakMetrics = NaN(length(emgData), length(channels), length(segments), 5);

    % peakDistances/Amplitude consolidates all peak distance/ amplitude values from all pulls and all files
    % segmented by channels (rows), segments (cols), i.e.
    % 			discrete    			rhythmic
    % bi  		[all peaks] 			[all peaks]
    % tri 	    [all peaks] 			[all peaks]
    % ...
    peakDistances = cell(length(channels), length(segments));
    peakAmplitudes = cell(length(channels), length(segments));

    % peakData is same as emgData but with peakmetrics, peakDistances, peakAmplitudes and sans raw EMG
    peakData = emgData;

    % Get sampling frequency from first available data
    fs = NaN;
    while isnan(fs) | isempty(fs)
    	for row = 1:length(emgData)
    		for chan = 1:length(channels)
    			fs = emgData(row).(channels{chan}).samplingFrequency;
    		end
    	end
    end
    if strcmpi(filterConfig.filterType,'iir')
    	passbandloFilt = designfilt('lowpassiir','FilterOrder',filterConfig.filterOrder, ...
    	         			'PassbandFrequency',filterConfig.passbandFrequency(1), 'PassbandRipple', filterConfig.passbandRipple, ...
    	         			'SampleRate',fs);
    	passbandhiFilt = designfilt('highpassiir','FilterOrder',filterConfig.filterOrder, ...
    	         			'PassbandFrequency',filterConfig.passbandFrequency(2), 'PassbandRipple',filterConfig.passbandRipple, ...
    	         			'SampleRate',fs);
        loFilt = designfilt('lowpassiir','FilterOrder',filterConfig.filterOrder, ...
                            'PassbandFrequency',filterConfig.loFrequency, 'PassbandRipple',filterConfig.passbandRipple, ...
                            'SampleRate',fs);
    end


	for row = 1:length(emgData)
		for chan = 1:length(channels)
			% Do not save raw
            if isfield(peakData(row).(channels{chan}), emgDataLabel)
                peakData(row).(channels{chan}) = rmfield(peakData(row).(channels{chan}), emgDataLabel);
            end
			if ~isempty(emgData(row).(channels{chan}))
				for seg = 1:length(segments)
					if isfield(emgData(row).(channels{chan}), segments{seg})
						if isfield(emgData(row).(channels{chan}).(segments{seg}), emgDataLabel)
							fs = emgData(row).(channels{chan}).samplingFrequency;
							data = emgData(row).(channels{chan}).(segments{seg}).raw;
							peakData(row).(channels{chan}).(segments{seg}) = rmfield(peakData(row).(channels{chan}).(segments{seg}), emgDataLabel);
							segmentName = segments{seg};
                            if ~(isempty(data)|isnan(data))
                                % Save original data in original segment name
                                peakData(row).(channels{chan}).(segmentName).data = data;
								% if IIR filter, high pass 50hz before rectification
								if strcmpi(filterConfig.filterType,'iir') & find(contains(filterConfig.segments, segments{seg}))
                                    % Save filtered data as filterConfig.filterSegmentName
                                    segmentName = filterConfig.filterSegmentName;
									data = filter(passbandhiFilt,data);
									peakData(row).(channels{chan}).(segmentName).HiPassBand = filterConfig.passbandFrequency(1);
								    % if IIR filter, low pass 30hz after rectification
                                    data = filter(passbandloFilt,data);
                                    peakData(row).(channels{chan}).(segmentName).LowPassBand = filterConfig.passbandFrequency(2);
                                end
								% rectify bipolar emg signals
								data = abs(data);
								% if strcmpi(filterType,'mva')
								% 	% Moving average filter
								% 	peakData(row).(channels{chan}).(segments{seg}).movingAverageWindow = movingAverageWindow;
								% 	data = movingAverage(data, movingAverageWindow, fs);
								% end
                                if strcmpi(filterConfig.filterType,'iir') & find(contains(filterConfig.segments, segments{seg}))
                                    % if IIR filter, low pass 50hz after rectification
                                    data = filter(loFilt,data);
                                    peakData(row).(channels{chan}).(segmentName).LowFilter = filterConfig.loFrequency;
                                end
                                if ~strcmpi(filterConfig.filterType,'na') & find(contains(filterConfig.segments, segments{seg}))
                                    peakData(row).(channels{chan}).(segmentName).data = data;
                                end
								L = length(data);
								% Get peaks
								peakData(row).(channels{chan}).(segmentName).minPeakDistance = minPeakDistance;
								peakData(row).(channels{chan}).(segmentName).rmsPctCutoff = rmsPctCutoff;
                                peakData(row).(channels{chan}).(segmentName).widthReference = widthReference;
								[pks, idx, w] = emgGetPeaks(data, fs,...
                                                         'minPeakDistance', minPeakDistance,...
                                                         'rmsPctCutoff', rmsPctCutoff,...
                                                         'widthReference', widthReference);
								peakData(row).(channels{chan}).(segmentName).peakAmplitude = pks;
								peakData(row).(channels{chan}).(segmentName).peakLocation = idx;
                                peakData(row).(channels{chan}).(segmentName).peakWidth = w;
								peakData(row).(channels{chan}).(segmentName).peakTime = idx/fs;
								[pk_freq, pk_dist, pk_amp, pk_dist_std, pk_amp_std] = peakAnalysis(idx, pks, fs, L);
								peakData(row).(channels{chan}).(segmentName).averageFrequency = pk_freq;
								peakData(row).(channels{chan}).(segmentName).averagePeakDistance = pk_dist;
								peakData(row).(channels{chan}).(segmentName).averagePeakAmplitude = pk_amp;
								peakData(row).(channels{chan}).(segmentName).peakDistanceStdDev = pk_dist_std;
								peakData(row).(channels{chan}).(segmentName).peakAmplitudeStdDev = pk_amp_std;
								peakMetrics(row,chan,seg,:) = [pk_freq, pk_dist, pk_amp, pk_dist_std, pk_amp_std];
								peakDistances{chan,seg} = [peakDistances{chan,seg}, (idx(2:end)-idx(1:end-1))/fs];
								peakAmplitudes{chan,seg} = [peakAmplitudes{chan,seg}, pks];
							end
						end
					end
				end
			end
		end
	end

	%% Read input
    function p = readInput(input)
        p = inputParser;
        channels = {'bi','tri','trap','ecu'};
        segments = {'discrete', 'rhythmic'};
        filterConfig = struct('filterType', 'na');
        minPeakDistance = 150/1000;
        rmsPctCutoff = 1;
        validWidthReferenceTypes = {'halfprom','halfheight'}; % (see help findpeaks - WidthReference)
        checkWidthReference = @(x) any(validatestring(x,validWidthReferenceTypes));
        widthReference = 'halfprom';
        emgDataLabel = 'data';
        
        addParameter(p,'channels',channels, @iscell);
        addParameter(p,'segments',segments, @iscell);
        addParameter(p,'filterConfig', filterConfig);
        addParameter(p,'minPeakDistance',minPeakDistance, @isnumeric);
        addParameter(p,'rmsPctCutoff',rmsPctCutoff, @isnumeric);
        addParameter(p,'widthReference',widthReference, checkWidthReference);
        addParameter(p,'emgDataLabel',emgDataLabel, @ischar);
        parse(p, input{:});
    end

    function [channels, segments, filterConfig, minPeakDistance, rmsPctCutoff, widthReference] = parseInput(p)
        channels = p.channels;
        segments = p.segments;
        filterConfig = p.filterConfig;
        minPeakDistance = p.minPeakDistance;
        rmsPctCutoff = p.rmsPctCutoff;
        widthReference = p.widthReference;
        emgDataLabel = p.emgDataLabel;
    end

end