emgPathName = '/Users/chico/Downloads/emg_old/';
savePathName = '/Users/chico/Downloads/emg_old/analysis';
label = 'ON';
% fname = {'/Users/chico/Downloads/emg_old/annotations_OFF_S_CD.csv',...
% 	'/Users/chico/Downloads/emg_old/annotations_OFF_S_G.csv',...
% 	'/Users/chico/Downloads/emg_old/annotations_OFF_S_R.csv',...
% 	'/Users/chico/Downloads/emg_old/annotations_OFF_US_CD.csv',...
% 	'/Users/chico/Downloads/emg_old/annotations_OFF_US_G.csv',...
% 	'/Users/chico/Downloads/emg_old/annotations_OFF_US_R.csv'};

fname = {'/Users/chico/Downloads/emg_old/annotations_ON_US_CD.csv',...
  '/Users/chico/Downloads/emg_old/annotations_ON_US_G.csv',...
  '/Users/chico/Downloads/emg_old/annotations_ON_US_R.csv'};

% Assumption: Single emg filename is export_18LLR_20180406.edf
emgFilename = fullfile(emgPathName,'export_18LLR_20180406.edf');

emgSamplingFrequency = 2000; %Hz
videoSamplingFrequency = 250;%; %Hz
padding = 0.5; % 0.5s
movingAverageWindow = 25/1000; % 25ms
baselineEnd = 0.2; % 0.2s
channels = 1:3;

emgData = [];
timestampEMG = struct();
emgAnalyzed = struct();

for f = 1:length(fname)

  ledcounterFile = fname{f};
  [emgPathName, trialName] = fileparts(ledcounterFile);
  disp(['Reading led counter file ' ledcounterFile])
  emgCounterReference = readtable(ledcounterFile);
  
  % load('/Users/chico/Downloads/emg/18LLR_OFF_20180606_RawEMG_All.mat')

  % Retrieve emg data
  disp(['Reading entire EMG Data from ' emgFilename])
  emgDataAll = emgRetrieve(emgFilename);
  % Pick baseline
  emgBaseline = emgDataAll(:,1:round(baselineEnd*emgSamplingFrequency));
  % Select samples in the emg channel data that corresponds to the time stamp from the led counter data file
  % Samples are chosen padding duration before and after time stamp 
  disp(['Extracting window of ', sprintf('%0.2f',padding)  ,' around LED counter'])
  [emg, ts] = emgExtractFromLEDCounter(emgDataAll,emgCounterReference,videoSamplingFrequency,emgSamplingFrequency,padding);
  disp(['Analysis in progress'])
  out = emgDataAnalysisLEDCounter(emg(channels,:,:),emgBaseline(channels,:),emgSamplingFrequency,ts);
  if (f==1)
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
disp(['Saving output in ' savePathName])
save(fullfile(savePathName,[label,'_RawEMGAll.mat']),'emgDataAll')
save(fullfile(savePathName,[label,'_RawEMGWindow.mat']),'emgData');
save(fullfile(savePathName,[label,'_AnalyzedEMG.mat']),'emgAnalyzed','timestampEMG');
a=[];
fields = {'FoldChangeMean','AreaUnderCurveNormalized'};
for k=1:length(fields)
  a=cat(3,a,getfield(emgAnalyzed,fields{k}));
end
for k = channels
  c=reshape(a(k,:,:),[size(a,2),size(a,3)]);
  t = array2table(c,'VariableNames',fields);
  writetable(t,fullfile(savePathName,[label,'_EMGAnalysis.xlsx']),'Sheet',k)
end
