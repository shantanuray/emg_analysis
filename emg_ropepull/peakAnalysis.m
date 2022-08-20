function [averageFrequency, averagePeakDistance, averagePeakAmplitude, peakDistanceStdDev, peakAmplitudeStdDev] = peakAnalysis(peakLocation, peakAmplitude, fs, dataLength)

averageFrequency = length(peakLocation)*fs/dataLength;
peak_dist = peakLocation(2:end) - peakLocation(1:end-1);
averagePeakDistance = mean(peak_dist)/fs;
peakDistanceStdDev = std(peak_dist)/fs;
if isempty(averagePeakDistance)
	averagePeakDistance = 0;
end
if isempty(peakDistanceStdDev)
	peakDistanceStdDev = 0;
end
averagePeakAmplitude = mean(peakAmplitude);
peakAmplitudeStdDev = std(peakAmplitude);
if isempty(peakAmplitudeStdDev)
	peakAmplitudeStdDev = 0;
end
