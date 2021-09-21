function peakDataFlat = flattenEMGPeakAnalysis(peakData, animal, condition, varargin)
	% peakData - see emgGetPeaksFolder
	% animal = Name of the animal
	% condition = 'CNO' or 'Control'
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
	for i = 1:length(peakData)
		fileID = peakData(i).fileID;
		tag = peakData(i).tag;
		for j = 1:length(channels)
			timePostCNO = peakData(i).(channels{j}).timePostCNO;
			pullingBout = peakData(i).(channels{j}).pullingBout;
			chan = channels(j);
			for k = 1:length(segments)
				counter = (i-1)*length(channels)*length(segments)+(j-1)*length(segments)+k;
				peakDataFlat{counter, 1} = animal;
				peakDataFlat{counter, 2} = fileID;
				peakDataFlat{counter, 3} = condition;
				peakDataFlat{counter, 4} = tag;
				peakDataFlat{counter, 5} = timePostCNO;
				peakDataFlat{counter, 6} = pullingBout;
				peakDataFlat{counter, 7} = chan;
				peakDataFlat{counter, 8} = segments{k};
				if isempty(strfind(peakData(i).(channels{j}).(segments{k}).tag, 'no-'))
					fs = peakData(i).(channels{j}).samplingFrequency;
					idx = peakData(i).(channels{j}).(segments{k}).peakLocation;
					peak_dist = (idx(2:end) - idx(1:end-1))/fs;
					peak_amp = peakData(i).(channels{j}).(segments{k}).peakAmplitude;
					peakDataFlat{counter, 9} = peakData(i).(channels{j}).(segments{k}).averageFrequency;
					peakDataFlat{counter, 10} = peakData(i).(channels{j}).(segments{k}).averagePeakDistance;
					peakDataFlat{counter, 11} = peakData(i).(channels{j}).(segments{k}).peakDistanceStdDev;
					peakDataFlat{counter, 12} = peakData(i).(channels{j}).(segments{k}).averagePeakAmplitude;
					peakDataFlat{counter, 13} = peakData(i).(channels{j}).(segments{k}).peakAmplitudeStdDev;
					peakDataFlat{counter, 14} = peak_dist';
					peakDataFlat{counter, 15} = peak_amp';
				end
			end
		end
	end
	
	% Write to table
	peakDistTable = cell2table(peakDataFlat(:, 1:14));
	peakAmplTable = cell2table(peakDataFlat(:, [1:13, 15]));
	% Standardize column names
	colnames_d = peakDistTable.Properties.VariableNames;
	colnames_a = peakAmplTable.Properties.VariableNames;
	actcolnames = {'Animal', 'FileID', 'Condition', 'Tag', 'Time Post CNO', 'Pulling Bout', 'Channel', 'Segment', 'Average Peak Frequency', 'Average Peak Distance', 'Std Dev Peak Distance', 'Average Peak Amplitude', 'Std Dev Peak Amplitude'};
	for c=1:13
		colnames_d{1,c} = actcolnames{c};
		colnames_a{1,c} = actcolnames{c};
	end
	colnames_d{1,14} = 'peak_dist';
	colnames_a{1,14} = 'peak_ampl';
	peakDistTable.Properties.VariableNames = colnames_d;
	peakAmplTable.Properties.VariableNames = colnames_a;
	% Write to file
	writetable(peakDistTable, [animal, '_', condition, '_peak_dist.csv'])
	writetable(peakAmplTable, [animal, '_', condition, '_peak_amp.csv'])

	function c = empty2nan(c)
	  c(cellfun(@isempty, c)) = {nan};
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