fname = '/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/emg_data_files/analysis/18LLR_OFF_20180606_annotations_AnalyzedEMG.mat';
[pathname,trialname] = fileparts(fname);
load(fname)
channel = 1;
reach_num = 1:size(emgAnalyzed.RawData,2);

emgRaw = reshape(emgAnalyzed.RawData(channel,:,:),size(emgAnalyzed.RawData,2),size(emgAnalyzed.RawData,3));
emgAvg = reshape(emgAnalyzed.RawAverage(channel,:,:),size(emgAnalyzed.RawAverage,2),size(emgAnalyzed.RawAverage,3));
h=figure('Name',[trialname, '; Channel: ',num2str(channel)]);
j = 1;
for i = reach_num
  subplot(length(reach_num),1,j)
  j = j +1;
  plot(emgRaw(i,:),'b-')
  hold on
  plot(emgAvg(i,:),'r-')
  %plot(reshape(emgAnalyzed.MovingAverage(3,1,:),1,1601)/mean(reshape(emgAnalyzed.MovingAverage(3,1,:),1,1601)),'r-');
  %plot(reshape(emgAnalyzed.Average(3,1,:),1,1601)/mean(reshape(emgAnalyzed.Average(3,1,:),1,1601)),'b-');
end

fname = '/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/18LLR/Day4/analysis/baselinechange/18LLR_Day4_OFF_AnalyzedEMG.mat';
[pathname,trialname] = fileparts(fname);
load(fname)


%% Plot all channels and some random reaches
% good for day 4 data
channel = size(emgAnalyzed.RawData,1);
reach_num = round(rand(1,5)*size(emgAnalyzed.RawData,2)); % Pick 5 random reaches
j = 1;
h=figure('Name',trialname);
for i = reach_num
	for k = 1:channel
		emgRaw = reshape(emgAnalyzed.RawData(k,:,:),size(emgAnalyzed.RawData,2),size(emgAnalyzed.RawData,3));
		emgAvg = reshape(emgAnalyzed.RawAverage(k,:,:),size(emgAnalyzed.RawAverage,2),size(emgAnalyzed.RawAverage,3));
	
	  subplot(length(reach_num)+1,channel,j)
	  plot(emgRaw(i,:),'b-')
      title(['Reach # ' num2str(i)])
	  hold on
	  plot(emgAvg(i,:),'r-')
	  j = j +1;
	end
end
for k = 1:channel
	emgRaw = reshape(emgAnalyzed.RawData(k,:,:),size(emgAnalyzed.RawData,2),size(emgAnalyzed.RawData,3));
	emgAvg = reshape(emgAnalyzed.RawAverage(k,:,:),size(emgAnalyzed.RawAverage,2),size(emgAnalyzed.RawAverage,3));	
	subplot(length(reach_num)+1,channel,j)
	plot(reshape(emgAnalyzed.MovingAverage(k,1,:),1,size(emgAnalyzed.MovingAverage,3)),'r-');
	title(['Average '])
	hold on
	plot(reshape(emgAnalyzed.Average(k,1,:),1,size(emgAnalyzed.Average,3)),'b-');
	j = j +1;
end