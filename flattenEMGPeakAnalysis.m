function [peakDistTable, peakAmplTable] = flattenEMGPeakAnalysis(peakData, animal, conditions, varargin)
	% peakData - see emgGetPeaksFolder
	% animal = Name of the animal
	% condition = {'Control', 'CNO'} => (0,1)
	% channels = {'bi','tri','trap','ecu'};
	% segments = {'discrete', 'rhythmic'};
	%
	% peakDataFlat contains
	% - Name of the animal
	% - Name of the file
	% - Condition {'CNO', 'Control'}
	% - Segment Tag
	% - Time Post CNO
	% - Pulling Bout
	% - Channel Name {'bi','tri','trap','ecu'}
	% - Segment Name {'discrete', 'rhythmic'}
	% - Average Frequency (Hz)
	% - Average Peak Distance (seconds)
	% - Standard Deviation - Peak Distance (seconds)
	% - Average Peak Amplitude
	% - Standard Deviation - Peak Amplitude
	% - [Peak Distances]

	p = readInput(varargin);
	[channels, segments] = parseInput(p.Results);

	peakDataFlat = cell(length(peakData)*length(channels)*length(segments), 14);
	for row = 1:length(peakData)
		fileID = peakData(row).fileID;
		tag = peakData(row).tag;
		condition = conditions(peakData(row).condition+1);
		timePostCNO = peakData(row).timePostCNO;
		pos1 = peakData(row).pos1;
		pos1 = peakData(row).pos2;
		pos1 = peakData(row).pos3;
		pullingBout = peakData(row).pullingBout;
		trialTime = peakData(row).trialTime;
		for chan = 1:length(channels)
			for seg = 1:length(segments)
				counter = (row-1)*length(channels)*length(segments)+(chan-1)*length(segments)+seg;
				peakDataFlat{counter, 1} = animal;
				peakDataFlat{counter, 2} = fileID;
				peakDataFlat{counter, 3} = condition;
				peakDataFlat{counter, 4} = trialTime;
				peakDataFlat{counter, 5} = tag;
				peakDataFlat{counter, 6} = timePostCNO;
				peakDataFlat{counter, 7} = pullingBout;
				peakDataFlat{counter, 8} = channels{chan};
				peakDataFlat{counter, 9} = segments{seg};
				if isempty(strfind(peakData(row).(channels{chan}).(segments{seg}).tag, 'no-'))
					fs = peakData(row).(channels{chan}).samplingFrequency;
					idx = peakData(row).(channels{chan}).(segments{seg}).peakLocation;
					peak_dist = (idx(2:end) - idx(1:end-1))/fs;
					peak_amp = peakData(row).(channels{chan}).(segments{seg}).peakAmplitude;
					peakDataFlat{counter, 10} = peakData(row).(channels{chan}).(segments{seg}).averageFrequency;
					peakDataFlat{counter, 11} = peakData(row).(channels{chan}).(segments{seg}).averagePeakDistance;
					peakDataFlat{counter, 12} = peakData(row).(channels{chan}).(segments{seg}).peakDistanceStdDev;
					peakDataFlat{counter, 13} = peakData(row).(channels{chan}).(segments{seg}).averagePeakAmplitude;
					peakDataFlat{counter, 14} = peakData(row).(channels{chan}).(segments{seg}).peakAmplitudeStdDev;
					peakDataFlat{counter, 15} = peak_dist';
					peakDataFlat{counter, 16} = peak_amp';
				end
			end
		end
	end
	
	% Write to table
	peakDistTable = cell2table(peakDataFlat(:, 1:15));
	peakAmplTable = cell2table(peakDataFlat(:, [1:14, 16]));
	% Standardize column names
	colnames_d = peakDistTable.Properties.VariableNames;
	colnames_a = peakAmplTable.Properties.VariableNames;
	actcolnames = {'Animal', 'FileID', 'Condition', 'Trail Time(s)', 'Tag', 'Time Post CNO', 'Pulling Bout', 'Channel', 'Segment', 'Average Peak Frequency', 'Average Peak Distance', 'Std Dev Peak Distance', 'Average Peak Amplitude', 'Std Dev Peak Amplitude'};
	for c=1:14
		colnames_d{1,c} = actcolnames{c};
		colnames_a{1,c} = actcolnames{c};
	end
	colnames_d{1,15} = 'peak_dist';
	colnames_a{1,15} = 'peak_ampl';
	peakDistTable.Properties.VariableNames = colnames_d;
	peakAmplTable.Properties.VariableNames = colnames_a;

	function c = empty2nan(c)
		c(cellfun(@isempty, c)) = {NaN};
	end

	%% Read input
    function p = readInput(input)
        %   - segments 				Default - {'discrete', 'rhythmic'}
        %   - channels              Default - {'bi','tri','trap','ecu'}
        p = inputParser;
        channels = {'bi','tri','trap','ecu'};
        segments = {'discrete', 'rhythmic'};
        
        addParameter(p,'channels',channels, @iscell);
        addParameter(p,'segments',segments, @iscell);
        parse(p, input{:});
    end

    function [channels, segments] = parseInput(p)
        channels = p.channels;
        segments = p.segments;
    end
end