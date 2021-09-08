function [peakAmplitude, peakLocation] = getPeaks(data, fs, varargin)
% [peakAmplitude, peakLocation] = getPeaks(data, fs,
%            			                   'minPeakDistance', 100/1000,
%            			                   'rmsPctCutoff', 0.25);
% Wrapper around find_peaks.m
	pkg load signal % Load signal processing library

	p = readInput(varargin);
    [minPeakDistance, rmsPctCutoff] = parseInput(p.Results);

	data_rms = rms(data);
	if isnan(rmsPctCutoff)
		[peakAmplitude, peakLocation] = findpeaks(data, 'MinPeakDistance', round(minPeakDistance*fs));
	else
		[peakAmplitude, peakLocation] = findpeaks(data, 'MinPeakDistance', round(minPeakDistance*fs), 'MinPeakHeight', rmsPctCutoff*data_rms);		
	end
    %% Read input
    function p = readInput(input)
        %   - minPeakDistance     Default - 100/1000; % 100ms
        %   - rmsPctCutoff        Default - NaN (skip this filter)
        p = inputParser;
        minPeakDistance = 100/1000;
        rmsPctCutoff = NaN;

        addParameter(p,'minPeakDistance',minPeakDistance, @isnumeric);
        addParameter(p,'rmsPctCutoff',rmsPctCutoff, @isnumeric);
        parse(p, input{:});
    end

    function [minPeakDistance, rmsPctCutoff] = parseInput(p)
        minPeakDistance = p.minPeakDistance;
        rmsPctCutoff = p.rmsPctCutoff;
    end
end