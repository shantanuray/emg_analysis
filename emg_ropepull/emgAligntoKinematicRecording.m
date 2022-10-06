function emgDataAligned = emgAligntoKinematicRecording(emgData, trialMetadata, varargin)
	% emgDataAligned = emgSegmentRetrieve(emgData(t), trialMetadata)
	%
	% emgData start time may not be aligned with kinematic data because signaling issues during data acquisition
	% We try to align the emg data start to kinematic data using encoder logs
	%
	% Inputs:
	% 	- emgData: Pre-processed emg data (see emgSegmentRetrieve_ConsolidatedData.m)
	%	- trialMetadata: encoder logs (see parseEncoderEMGKinematic.m)
	%	- 'channels' = {'bi_R','tri_R','bi_L','tri_L'}
	%	- 'dataType' = {'data_raw', 'data_smooth'}
	%	- 'emgInDataLabel' = 'raw'
	%	- 'emgOutDataLabel' = 'data'
	%
	% Assumption: trialMetadata & emgData are aligned row wise

	p = readInput(varargin);
	[channels, dataType, emgInDataLabel, emgOutDataLabel]  = parseInput(p.Results);
	emgDataAligned = [];

	for t = 1:min(length(trialMetadata), length(emgData))
		emgTrial = struct();
		emgTrial.fileID = emgData(t).fileID;
		emgTrial.tag = emgData(t).tag;
		emgTrial.condition = emgData(t).condition;
		emgTrial.error = emgData(t).error;
		for dt = 1:length(dataType)
	        for chan = 1:length(channels)
	            emgTrial.(channels{chan}).fileID = emgData(t).(channels{chan}).fileID;
	            emgTrial.(channels{chan}).samplingFrequency = emgData(t).(channels{chan}).samplingFrequency;
	            emgTrial.(channels{chan}).offset = emgData(t).(channels{chan}).offset;
	            if ~isnan(emgData(t).(channels{chan}).(dataType{dt}).(emgInDataLabel))
	                alignData = emgData(t).(channels{chan}).(dataType{dt}).(emgInDataLabel);
	                alignData = realignSignal(alignData,...
	                	trialMetadata(t).emgStartT, trialMetadata(t).emgEndT,...
	                	trialMetadata(t).kinStartT, trialMetadata(t).kinEndT,...
	                	emgData(t).(channels{chan}).samplingFrequency);
	                emgTrial.(channels{chan}).(dataType{dt}).(emgOutDataLabel) = alignData;
	            else
	            	emgTrial.(channels{chan}).(dataType{dt}).(emgOutDataLabel) = nan;
	            end
	        end
	    end
	    emgDataAligned = [emgDataAligned emgTrial];
	end

	%% Read input
	function p = readInput(input)
	    p = inputParser;
	    channels = {'bi_R','tri_R','bi_L','tri_L'};
	    dataType = {'data_raw', 'data_smooth'};
	    emgInDataLabel = 'raw';
	    emgOutDataLabel = 'data';
	    validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
	    addParameter(p,'channels',channels, @iscell);
	    addParameter(p,'dataType',dataType, @iscell);
	    addParameter(p,'emgInDataLabel',emgInDataLabel, @ischar);
	    addParameter(p,'emgOutDataLabel',emgOutDataLabel, @ischar);
	    parse(p, input{:});
	end

	function [channels, dataType, emgInDataLabel, emgOutDataLabel] = parseInput(p)
	    channels = p.channels;
	    dataType = p.dataType;
	    emgInDataLabel = p.emgInDataLabel;
	    emgOutDataLabel = p.emgOutDataLabel;
	end
end