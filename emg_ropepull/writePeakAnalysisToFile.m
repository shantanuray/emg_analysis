function writePeakAnalysisToFile(peakData, fileID, fileDelim, channels, segments, saveloc)
	if nargin < 5
		saveloc = pwd;
	end
	fileIDParts = strsplit(fileID, fileDelim);
	[peakDistTable, peakAmplTable] = flattenEMGPeakAnalysis(peakData, fileIDParts{1}, [],...
															'channels', channels,...
															'segments', segments);
	writetable(peakDistTable, fullfile(saveloc, sprintf('%s_peak_dist.csv', fileID)));
	writetable(peakAmplTable, fullfile(saveloc, sprintf('%s_peak_amp.csv', fileID)));
end