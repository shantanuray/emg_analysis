function run_RopePull_EMG_RetrievalConsolidated_PeakAnalysis(emgPathName, start_pos, end_pos)
	% run_RopePull_EMG_RetrievalConsolidated_PeakAnalysis(emgPathName, 15000, 55000)
	% This is extraction for data from modified setup circa August 2022
	% Ask Ayesha for more details. Single MAT files has all of the data
	if nargin < 2
		start_pos = 15000;
	end
	if nargin < 3
		end_pos = 55000;
	end
	channels = {'bi_R','tri_R','bi_L','tri_L'};
	segments = {'data_raw', 'data_smooth'};
	filterType = 'na';
	emg_fs = 10000;
	minPeakDistance = 120/1000;
	widthReference = 'halfheight';

	emgFiles = dir(fullfile(emgPathName, '*_processed.mat'));

	for emg_file_indx = 1:length(emgFiles)
		dataFname = emgFiles.name;
		[~, fileID, ~] =  fileparts(dataFname);
		disp(sprintf('Retrieving data from %s', fullfile(emgPathName,dataFname)));
		emgData = emgSegmentRetrieve_ConsolidatedData(emgPathName,dataFname, emg_fs);
		disp('Running peak analysis');
		[peakData, peakMetrics, peakDistances, peakAmplitudes] = emgGetPeaksFolder(emgData,...
																				   'channels', channels,...
																				   'segments', segments,...
																				   'filterType', filterType,...
																				   'minPeakDistance', minPeakDistance,...
																				   'widthReference', widthReference);
		outFile = fullfile(emgPathName, [fileID, '_analysis.mat']);
		disp(sprintf('Saving analysis to %s', outFile));
		save(outFile, 'emgData', 'peakData', 'peakMetrics', 'peakDistances', 'peakAmplitudes');
	end