emgPathName = '/Users/chico/Downloads/emg/';
fname = {'18LLR_OFF_annotations.xlsx',...
	'18LLR_ONG_annotations.xlsx',...
	'18LLR_ONI_annotations.xlsx',...
	'22UN_OFF_annotations.xlsx',...
	'22UN_ONG_annotations.xlsx',...
	'22UN_ONI_annotations.xlsx'};

% fname = {'18LLR_OFF_20180606_annotations.xlsx'};

emgSamplingFrequency = 2000; %Hz
videoSamplingFrequency = 250; %Hz
padding = 0.5; % 0.5s
movingAverageWindow = 25/1000; % 25ms
baselineEnd = 0.2; % 0.2s


emgCounterReference = readtable('/Users/chico/Downloads/emg/annotations_18LLR_22UN_Master.txt');

for f = 1:length(fname)
	annotationFile = fullfile(emgPathName,fname{f});
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
	for i = 1:length(Animal)
		for j = 1:length(Dates)
			% Assumption emg filename is export_18LLR_20180622.edf
			emgFilename = fullfile(emgPathName,...
			  ['export_',Animal{i},'_',num2str(Dates(j)),'.edf']);
			emgDataAll = emgRetrieve(emgFilename);
			indx = find(strcmpi(annotations.Animal,Animal(i)) & annotations.Date==Dates(j));
			[ignore,trialName] = fileparts(annotations.Filename{indx(1)});


			% Select samples in the emg channel data that corresponds to the time stamp from the annotations data file
			% Samples are chosen paddingDuration  before and after time stamp 
			
			[emgData_,timestampEMG_] = emgExtractFromReach(emgDataAll,annotations(indx,:),emgCounterReference,videoSamplingFrequency,emgSamplingFrequency,padding);
			emgData = cat(2,emgData,emgData_);
			timestampEMG.Counter = [timestampEMG.Counter;timestampEMG_.Counter];
			timestampEMG.Reach = [timestampEMG.Reach;timestampEMG_.Reach];
			timestampEMG.StartStop = [timestampEMG.StartStop;timestampEMG_.StartStop];
			timestampEMG.StartStopNormalized = [timestampEMG.StartStopNormalized;timestampEMG_.StartStopNormalized];
			emgAnalyzed = emgDataAnalysisOld(emgData,emgSamplingFrequency,baselineEnd,movingAverageWindow);
			% save(fullfile(emgPathName,[annotationFilename,'_AnalyzedEMG.mat']),'emgAnalyzed');

			h=figure('Name',trialName);
			subplot(3,1,1)
			plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.Average(1,1,:),1,2001))
			hold on
			plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.MovingAverage(1,1,:),1,2001),'r')
			title('Channel1')
			subplot(3,1,2)
			plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.Average(2,1,:),1,2001))
			hold on
			plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.MovingAverage(2,1,:),1,2001),'r')
			title('Channel2')
			subplot(3,1,3)
			plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.Average(3,1,:),1,2001))
			hold on
			plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.MovingAverage(3,1,:),1,2001),'r')
			title('Channel3')
			hold off
		end
	end
			% save(fullfile(emgPathName,[Animal(i),'_',Dates(j),'_RawEMG_All.mat']),'emgDataAll','emgData');

	% [emgDataPlot,timestampEMG,xPlot] = emgDataWindow(emgData,annotations,timestampEMG,emgSamplingFrequency);
	% save(fullfile(emgPathName,[annotationFilename,'_RawEMG_TimeWindow.mat']),'emgDataPlot');

	% emgDataPlot = cell2mat(emgData);
end
