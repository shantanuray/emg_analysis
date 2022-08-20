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

    p = readInput(varargin);
    [channels, segments, filterType, passbandFrequency, filterOrder, passbandRipple, movingAverageWindow, minPeakDistance, rmsPctCutoff, widthReference] = parseInput(p.Results);

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
    if strcmpi(filterType,'iir')
    	loFilt = designfilt('lowpassiir','FilterOrder',filterOrder, ...
    	         			'PassbandFrequency',passbandFrequency(1), 'PassbandRipple',passbandRipple, ...
    	         			'SampleRate',fs);
    	hiFilt = designfilt('highpassiir','FilterOrder',filterOrder, ...
    	         			'PassbandFrequency',passbandFrequency(2), 'PassbandRipple',passbandRipple, ...
    	         			'SampleRate',fs);
    end


	for row = 1:length(emgData)
		for chan = 1:length(channels)
			% Do not save raw
            if isfield(peakData(row).(channels{chan}), 'raw')
                peakData(row).(channels{chan}) = rmfield(peakData(row).(channels{chan}), 'raw');
            end
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
								if strcmpi(filterType,'iir')
									data = filter(hiFilt,data);
									peakData(row).(channels{chan}).(segments{seg}).HiPassBand = passbandFrequency(1);
								end
								% rectify bipolar emg signals
								data = abs(data);
								if strcmpi(filterType,'mva')
									% Moving average filter
									peakData(row).(channels{chan}).(segments{seg}).movingAverageWindow = movingAverageWindow;
									data = movingAverage(data, movingAverageWindow, fs);
								elseif strcmpi(filterType,'iir')
									% if IIR filter, low pass 30hz after rectification
									data = filter(loFilt,data);
									peakData(row).(channels{chan}).(segments{seg}).HiPassBand = passbandFrequency(2);
								end
								L = length(data);
								% Get peaks
								peakData(row).(channels{chan}).(segments{seg}).minPeakDistance = minPeakDistance;
								peakData(row).(channels{chan}).(segments{seg}).rmsPctCutoff = rmsPctCutoff;
                                peakData(row).(channels{chan}).(segments{seg}).widthReference = widthReference;
								[pks, idx, w] = emgGetPeaks(data, fs,...
                                                         'minPeakDistance', minPeakDistance,...
                                                         'rmsPctCutoff', rmsPctCutoff,...
                                                         'widthReference', widthReference);
								peakData(row).(channels{chan}).(segments{seg}).peakAmplitude = pks;
								peakData(row).(channels{chan}).(segments{seg}).peakLocation = idx;
                                peakData(row).(channels{chan}).(segments{seg}).peakWidth = w;
								peakData(row).(channels{chan}).(segments{seg}).peakTime = idx/fs;
								[pk_freq, pk_dist, pk_amp, pk_dist_std, pk_amp_std] = peakAnalysis(idx, pks, fs, L);
								peakData(row).(channels{chan}).(segments{seg}).averageFrequency = pk_freq;
								peakData(row).(channels{chan}).(segments{seg}).averagePeakDistance = pk_dist;
								peakData(row).(channels{chan}).(segments{seg}).averagePeakAmplitude = pk_amp;
								peakData(row).(channels{chan}).(segments{seg}).peakDistanceStdDev = pk_dist_std;
								peakData(row).(channels{chan}).(segments{seg}).peakAmplitudeStdDev = pk_amp_std;
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
        %   - segments 				Default - {'discrete', 'rhythmic'}
        %   - channels              Default - {'bi','tri','trap','ecu'}
        %	- movingAverageWindow 	Default - 100/1000; % 100ms
        %   - minPeakDistance     	Default - 100/1000; % 100ms
        %   - rmsPctCutoff       	Default - nan
        p = inputParser;
        channels = {'bi','tri','trap','ecu'};
        segments = {'discrete', 'rhythmic'};
        filterType = 'iir';
        validFilters = {'na','mva','iir'};
        checkFilter = @(x) any(validatestring(x,validFilters));
        passbandFrequency = [30, 50];
        filterOrder = 4;
        passbandRipple = 0.2;
        movingAverageWindow = 100/1000;
        minPeakDistance = 150/1000;
        rmsPctCutoff = 1;
        validWidthReferenceTypes = {'halfprom','halfheight'}; % (see help findpeaks - WidthReference)
        checkWidthReference = @(x) any(validatestring(x,validWidthReferenceTypes));
        widthReference = 'halfprom';
        
        addParameter(p,'channels',channels, @iscell);
        addParameter(p,'segments',segments, @iscell);
        addParameter(p,'filterType',filterType, checkFilter);
        addParameter(p,'passbandFrequency',passbandFrequency);
        addParameter(p,'filterOrder',filterOrder, @isnumeric);
        addParameter(p,'passbandRipple',passbandRipple, @isnumeric);
        addParameter(p,'movingAverageWindow',movingAverageWindow, @isnumeric);
        addParameter(p,'minPeakDistance',minPeakDistance, @isnumeric);
        addParameter(p,'rmsPctCutoff',rmsPctCutoff, @isnumeric);
        addParameter(p,'widthReference',widthReference, checkWidthReference);
        parse(p, input{:});
    end

    function [channels, segments, filterType, passbandFrequency, filterOrder, passbandRipple, movingAverageWindow, minPeakDistance, rmsPctCutoff, widthReference] = parseInput(p)
        channels = p.channels;
        segments = p.segments;
        filterType = p.filterType;
		passbandFrequency = p.passbandFrequency;
		filterOrder = p.filterOrder;
		passbandRipple = p.passbandRipple;
        movingAverageWindow = p.movingAverageWindow;
        minPeakDistance = p.minPeakDistance;
        rmsPctCutoff = p.rmsPctCutoff;
        widthReference = p.widthReference;
    end

end