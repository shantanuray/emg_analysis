emgPathName = '/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/emg_data_files';
savePathName = '/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/emg_data_files/analysis/clean_working';
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
      animal=Animal{i};
      trialDate=Dates(j);
      emgFilename = fullfile(emgPathName,...
        ['export_',Animal{i},'_',num2str(Dates(j)),'.edf']);
      % load('/Users/chico/Downloads/emg/18LLR_OFF_20180606_RawEMG_All.mat')
      indx = find(strcmpi(annotations.Animal,Animal(i)) & annotations.Date==Dates(j));
      [ignore,trialName] = fileparts(annotations.Filename{indx(1)});

      % Retrieve emg data
      [emgClean, emgFiltered, emgRaw] = emgRetrieve(emgFilename);
      save(fullfile(savePathName,[trialName,'_RawEMGAll.mat']),'emgClean','emgFiltered','emgRaw')
      % Pick baseline
      emgBaseline = emgClean(:,1:round(baselineEnd*emgSamplingFrequency));
      % Select samples in the emg channel data that corresponds to the time stamp from the annotations data file
      % Samples are chosen paddingDuration  before and after time stamp 
      
      [emg, ts] = emgExtractFromReach(emgClean,annotations(indx,:),emgCounterReference,videoSamplingFrequency,emgSamplingFrequency,padding);
      emg_filtered = emgExtractFromReach(emgFiltered,annotations(indx,:),emgCounterReference,videoSamplingFrequency,emgSamplingFrequency,padding);
      emg_raw = emgExtractFromReach(emgRaw,annotations(indx,:),emgCounterReference,videoSamplingFrequency,emgSamplingFrequency,padding);

      out = emgDataAnalysis(emg(channels,:,:),annotations,emgBaseline(channels,:),emgSamplingFrequency,ts);
      if (i==1)&&(j==1)
        emgData=emg;
        emgFiltered=emg_filtered;
        emgRaw=emg_raw;
        timestampEMG=ts;
        emgAnalyzed=out;
      else
        emgData = cat(2,emgData,emg);emgFiltered = cat(2,emgFiltered,emg_filtered);emgRaw = cat(2,emgRaw,emg_raw);
        timestampEMG = cell2struct(cellfun(@vertcat,struct2cell(timestampEMG),struct2cell(ts),'uni',0),fieldnames(ts),1);
        fields = fieldnames(out);
        for k = 1:numel(fields)
          aField     = fields{k};
          emgAnalyzed = setfield(emgAnalyzed,aField,cat(2, getfield(emgAnalyzed, aField),getfield(out, aField)));
        end
      end
      save(fullfile(savePathName,[trialName,'_RawEMGWindow.mat']),'emgData','emgFiltered','emgRaw','trialName','animal','trialDate');
      save(fullfile(savePathName,[trialName,'_AnalyzedEMG.mat']),'emgAnalyzed','timestampEMG','animal','trialDate');
      datamat=[];
      metafields = {'TrialName','Animal','Date'};
      datafields = {'ReachNumber','InitializeTimestamp','ReachTimestamp','PeakValueRawAverage','ClosestPeakPosition','ClosestPeakTimestamp','TimeToPeak','CrossDoorwayTimeStamp','GraspTimestamp','RetrieveTimestamp','LaserLightOnTimestamp','LaserLightOffTimestamp','FoldChangeMean','FoldChangeMean1','AreaUnderCurveNormalized','AreaUnderCurveNormalized1'};
      metadata = {trialName;animal;trialDate};
      metaidx = repmat(1:size(metadata,1),[size(emgAnalyzed.ReachTimestamp,2) 1]);
      if size(emgAnalyzed.ReachTimestamp,2)==1
        % When only one row exists, indexed data (metadata(metaidx)) is returning column vector instead of row
        % Hence, hack - transposing it
        metatable = array2table(metadata(metaidx)','VariableNames',metafields); 
      else
        metatable = array2table(metadata(metaidx),'VariableNames',metafields);
      end
      for k=1:length(datafields)
        datamat = cat(3,datamat,emgAnalyzed.(datafields{k}));
      end
      for k = channels
        datamatx = reshape(datamat(k,:,:),[size(datamat,2),size(datamat,3)]);
        datatable = array2table(datamatx,'VariableNames',datafields);
        writetable([metatable,datatable],fullfile(savePathName,[trialName,'_EMGAnalysis.xlsx']),'Sheet',k)
      end
    end
  end
end
