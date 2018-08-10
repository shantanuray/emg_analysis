fname = {'18LLR_OFF_annotations.xlsx',...
	'22UN_OFF_annotations.xlsx',...
	'18LLR_ONG_annotations.xlsx',...
	'18LLR_ONI_annotations.xlsx',...
	'22UN_ONG_annotations.xlsx',...
	'22UN_ONI_annotations.xlsx'};

fname = {'18LLR_OFF_20180606_annotations.xlsx'};

emgSamplingFrequency = 2000; %Hz
videoSamplingFrequency = 25; %Hz
padding = 0.5; % 0.5s
movingAverageWindow = 25/1000; % 25ms
baselineEnd = 0.2; % 0.2s


emgCounterReference = readtable('/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/emg_data_files/annotations_18LLR_22UN_Master.txt');

for f = 1:length(fname)
	annotationFile = fullfile('/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/emg_data_files/',fname{f});
	[emgPathName, annotationFilename] = fileparts(annotationFile);
	annotations = readtable(annotationFile);
	% [emgData,timestampEMG] = emgExtractFromAnnotations(annotations,emgCounterReference,emgPathName,emgSamplingFrequency,videoSamplingFrequency,padding);

	Dates = unique(annotations.Date);
	Animal = unique(annotations.Animal);
	emgData = [];
	timestampEMG.Counter = [];
	timestampEMG.Reach = [];
	timestampEMG.StartStop = [];
	timestampEMG.StartStopNormalized = [];
	for i = 1:length(Animals)
		for j = 1:length(uniqueDates)
			% Assumption emg filename is export_18LLR_20180622.edf
			emgFilename = fullfile(emgPathName,...
			  ['export_',Animals{j},'_',num2str(Dates(i)),'.edf']);
			emgDataAll = emgRetrieve(emgFilename);
			indx = find(strcmpi(annotations.Animal,Animals(i)) & annotations.Date==Dates(j));


			% Select samples in the emg channel data that corresponds to the time stamp from the annotations data file
			% Samples are chosen paddingDuration  before and after time stamp 
			[emgData_,timestampEMG_] = emgExtractFromReach(emgDataAll,annotations(indx,:),emgCounterReference,videoSamplingFrequency,emgSamplingFrequency,padding);
			emgData = cat(2,emgData,emgData_);
			timestampEMG.Counter = [timestampEMG.Counter,timestampEMG_.Counter];
			timestampEMG.Reach = [timestampEMG.Reach,timestampEMG_.Reach];
			timestampEMG.StartStop = [timestampEMG.StartStop,timestampEMG_.StartStop];
			timestampEMG.StartStopNormalized = [timestampEMG.StartStopNormalized;timestampEMG_.StartStopNormalized];
			save(fullfile(emgPathName,[animal(i),'_',uniqueDates(j),'_RawEMG_All.mat']),'emgDataAll','emgData');

	% [emgDataPlot,timestampEMG,xPlot] = emgDataWindow(emgData,annotations,timestampEMG,emgSamplingFrequency);
	% save(fullfile(emgPathName,[annotationFilename,'_RawEMG_TimeWindow.mat']),'emgDataPlot');

	% emgDataPlot = cell2mat(emgData);
	emgAnalyzed = emgDataAnalysisOld(emgData,emgSamplingFrequency,baselineEnd,movingAverageWindow);
	save(fullfile(emgPathName,[annotationFilename,'_AnalyzedEMG.mat']),'emgAnalyzed');

	h=figure;
	subplot(3,1,1)
	plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.Average(1,1,:),1,2001))
	hold on
	plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.MovingAverage(1,1,:),1,2001),'r')
	subplot(3,1,2)
	plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.Average(2,1,:),1,2001))
	hold on
	plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.MovingAverage(2,1,:),1,2001),'r')
	subplot(3,1,3)
	plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.Average(3,1,:),1,2001))
	hold on
	plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.MovingAverage(3,1,:),1,2001),'r')
	hold off
end
