function [peakAmplitude, peakLocation] = emgGetPeaks(data, fs, varargin)
% [peakAmplitude, peakLocation] = emgGetPeaks(data, fs,
%            			                   'minPeakDistance', 100/1000,
%            			                   'rmsPctCutoff', 0.25);
% Wrapper around find_peaks.m

	p = readInput(varargin);
    [minPeakDistance, rmsPctCutoff] = parseInput(p.Results);

	if rmsPctCutoff == -Inf | isnan(rmsPctCutoff) | isempty(rmsPctCutoff)
        if length(data) < ceil(minPeakDistance*fs)*2
            [peakAmplitude, peakLocation] = findpeaks(data);
        else
		    [peakAmplitude, peakLocation] = findpeaks(data, 'MinPeakDistance', round(minPeakDistance*fs));
        end
	else
        data_rms = rms(data);
        if length(data) < ceil(minPeakDistance*fs)*2
            [peakAmplitude, peakLocation] = findpeaks(data, 'MinPeakHeight', rmsPctCutoff*data_rms);
        else
            [peakAmplitude, peakLocation] = findpeaks(data, 'MinPeakDistance', round(minPeakDistance*fs), 'MinPeakHeight', rmsPctCutoff*data_rms);
        end
	end
    return;

    %% Read input
    function p = readInput(input)
        %   - minPeakDistance     Default - 100/1000; % 100ms
        %   - rmsPctCutoff        Default - -Inf (skip this filter)
        p = inputParser;
        minPeakDistance = 100/1000;
        rmsPctCutoff = -Inf;

        addParameter(p,'minPeakDistance',minPeakDistance, @isnumeric);
        addParameter(p,'rmsPctCutoff',rmsPctCutoff, @isnumeric);
        parse(p, input{:});
    end

    function [minPeakDistance, rmsPctCutoff] = parseInput(p)
        minPeakDistance = p.minPeakDistance;
        rmsPctCutoff = p.rmsPctCutoff;
    end
end