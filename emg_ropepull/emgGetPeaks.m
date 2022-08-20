function [peakAmplitude, peakLocation, peakWidth] = emgGetPeaks(data, fs, varargin)
% [peakAmplitude, peakLocation] = emgGetPeaks(data, fs,...
%            			                   'minPeakDistance', 100/1000,...
%                                          'WidthReference', 'halfheight',...
%            			                   'rmsPctCutoff', 0.25);
% Wrapper around find_peaks.m

	p = readInput(varargin);
    [minPeakDistance, rmsPctCutoff, widthReference] = parseInput(p.Results);

	if rmsPctCutoff == -Inf | isnan(rmsPctCutoff) | isempty(rmsPctCutoff)
        if length(data) < ceil(minPeakDistance*fs)*2
            [peakAmplitude, peakLocation, peakWidth] = findpeaks(data, 'WidthReference', widthReference);
        else
		    [peakAmplitude, peakLocation, peakWidth] = findpeaks(data,...
                                                                 'MinPeakDistance', round(minPeakDistance*fs),...
                                                                 'WidthReference', widthReference);
        end
	else
        data_rms = rms(data);
        if length(data) < ceil(minPeakDistance*fs)*2
            [peakAmplitude, peakLocation, peakWidth] = findpeaks(data,...
                                                                 'MinPeakHeight', rmsPctCutoff*data_rms,...
                                                                 'WidthReference', widthReference);
        else
            [peakAmplitude, peakLocation, peakWidth] = findpeaks(data,...
                                                                'MinPeakDistance', round(minPeakDistance*fs),...
                                                                'MinPeakHeight', rmsPctCutoff*data_rms,...
                                                                'WidthReference', widthReference);
        end
	end
    return;

    %% Read input
    function p = readInput(input)
        p = inputParser;
        minPeakDistance = 100/1000;
        rmsPctCutoff = -Inf;
        validWidthReferenceTypes = {'halfprom','halfheight'}; % (see help findpeaks - WidthReference)
        checkWidthReference = @(x) any(validatestring(x,validWidthReferenceTypes));
        widthReference = 'halfprom'; 

        addParameter(p,'minPeakDistance',minPeakDistance, @isnumeric);
        addParameter(p,'rmsPctCutoff',rmsPctCutoff, @isnumeric);
        addParameter(p,'widthReference',widthReference, checkWidthReference);
        parse(p, input{:});
    end

    function [minPeakDistance, rmsPctCutoff, widthReference] = parseInput(p)
        minPeakDistance = p.minPeakDistance;
        rmsPctCutoff = p.rmsPctCutoff;
        widthReference = p.widthReference;
    end
end