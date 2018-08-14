emgPathName = '/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/emg_data_files';
savePathName = '/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/emg_data_files/analysis/baselinechange';
fname = {'18LLR_OFF_20180606_annotations.xlsx',...
	'18LLR_OFF_20180607_annotations.xlsx',...
	'18LLR_OFF_20180608_annotations.xlsx',...
	'18LLR_ONG_20180406_annotations.xlsx',...
	'18LLR_ONG_20180606_annotations.xlsx',...
	'18LLR_ONG_20180608_annotations.xlsx',...
	'18LLR_ONI_20180406_annotations.xlsx',...
	'18LLR_ONI_20180606_annotations.xlsx',...
	'18LLR_ONI_20180607_annotations.xlsx',...
	'18LLR_ONI_20180608_annotations.xlsx',...
	'22UN_OFF_20180606_annotations.xlsx',...
	'22UN_OFF_20180607_annotations.xlsx',...
	'22UN_OFF_20180608_annotations.xlsx',...
	'22UN_ONG_20180607_annotations.xlsx',...
	'22UN_ONG_20180608_annotations.xlsx',...
	'22UN_ONI_20180606_annotations.xlsx',...
	'22UN_ONI_20180607_annotations.xlsx',...
	'22UN_ONI_20180608_annotations.xlsx'};

% fname = {'18LLR_ONG_annotations.xlsx'};

% fname = {'18LLR_OFF_20180606_annotations.xlsx'};

emgSamplingFrequency = 2000; %Hz
videoSamplingFrequency = 250;%; %Hz
padding = 0.5; % 0.5s
movingAverageWindow = 25/1000; % 25ms
baselineEnd = 0.2; % 0.2s
channels = 1:3;


emgCounterReference = readtable('/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/emg_data_files/annotations_18LLR_22UN_Master.txt');

for f = 1:length(fname)
	annotationFile = fullfile(emgPathName,fname{f});
	[emgPathName, annotationFilename] = fileparts(annotationFile);
	annotations = readtable(annotationFile);

	Dates = unique(annotations.Date);
	Animal = unique(annotations.Animal);
	emgData = [];
	timestampEMG = struct();
	emgAnalyzed = struct();
	for i = 1:length(Animal)
		for j = 1:length(Dates)
			% Assumption emg filename is export_18LLR_20180622.edf
			emgFilename = fullfile(emgPathName,...
			  ['export_',Animal{i},'_',num2str(Dates(j)),'.edf']);
			% load('/Users/chico/Downloads/emg/18LLR_OFF_20180606_RawEMG_All.mat')
			indx = find(strcmpi(annotations.Animal,Animal(i)) & annotations.Date==Dates(j));
			[ignore,trialName] = fileparts(annotations.Filename{indx(1)});

			% Retrieve emg data
			emgDataAll = emgRetrieve(emgFilename);
			save(fullfile(savePathName,[trialName,'_RawEMGAll.mat']),'emgDataAll')
			% Pick baseline
			emgBaseline = emgDataAll(:,1:round(baselineEnd*emgSamplingFrequency));
			% Select samples in the emg channel data that corresponds to the time stamp from the annotations data file
			% Samples are chosen paddingDuration  before and after time stamp 
			
			[emg, ts] = emgExtractFromReach(emgDataAll,annotations(indx,:),emgCounterReference,videoSamplingFrequency,emgSamplingFrequency,padding);
			out = emgDataAnalysis(emg(channels,:,:),emgBaseline(channels,:),emgSamplingFrequency,ts);
			if (i==1)&&(j==1)
				emgData=emg;
				timestampEMG=ts;
				emgAnalyzed=out;
			else
				emgData = cat(2,emgData,emg);
				timestampEMG = cell2struct(cellfun(@vertcat,struct2cell(timestampEMG),struct2cell(ts),'uni',0),fieldnames(ts),1);
				fields = fieldnames(out);
				for k = 1:numel(fields)
				  aField     = fields{k};
				  emgAnalyzed = setfield(emgAnalyzed,aField,cat(2, getfield(emgAnalyzed, aField),getfield(out, aField)));
				end
			end
			save(fullfile(savePathName,[trialName,'_RawEMGWindow.mat']),'emgData');
			save(fullfile(savePathName,[trialName,'_AnalyzedEMG.mat']),'emgAnalyzed','timestampEMG');
			a=[];
	    fields = {'InitializeTimestamp','ReachTimestamp','PeakValueRawAverage','ClosestPeakPosition','ClosestPeakTimestamp','TimeToPeak','FoldChangeMean','FoldChangeMean1','AreaUnderCurveNormalized','AreaUnderCurveNormalized1'};
	    for k=1:length(fields)
	    	a=cat(3,a,getfield(emgAnalyzed,fields{k}));
	    end
	    for k = channels
	    	c=reshape(a(k,:,:),[size(a,2),size(a,3)]);
	    	t = array2table(c,'VariableNames',fields);
	    	writetable(t,fullfile(savePathName,[trialName,'_EMGAnalysis.xlsx']),'Sheet',k)
	    end

			% h=figure('Name',trialName);
			% subplot(3,1,1)
			% plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.Average(1,1,:),1,1601))
			% hold on
			% plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.MovingAverage(1,1,:),1,1601),'r')
			% title('Channel1')
			% subplot(3,1,2)
			% plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.Average(2,1,:),1,1601))
			% hold on
			% plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.MovingAverage(2,1,:),1,1601),'r')
			% title('Channel2')
			% subplot(3,1,3)
			% plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.Average(3,1,:),1,1601))
			% hold on
			% plot((0:size(emgAnalyzed.Average,3)-1)/emgSamplingFrequency,reshape(emgAnalyzed.MovingAverage(3,1,:),1,1601),'r')
			% title('Channel3')
			% hold off
		end
	end
end
