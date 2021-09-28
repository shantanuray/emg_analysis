% Plot Filtered Data

% Initalize plot limits
emgSamplingFrequency = 2000; %Hz
plot_start 	= round(emgSamplingFrequency*0)+1;
plot_end	= plot_start+round(emgSamplingFrequency*1)-1;


fname = '/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/emg_data_files/analysis/clean_working/18LLR_OFF_S_R_170_20180606T1700_RawEMGWindow.mat';
[pathname,trialname] = fileparts(fname);
load(fname)


%% Plot all channels and some random reaches
% good for day 4 data
channel = 1;
reach_num = 1:size(emgFilteredWindow,2); % Pick 5 random reaches  %round(rand(1,5)*size(emgFilteredWindow,2)); % Pick 5 random reaches

j = 1;
h=figure('Name',trialname);
for i = reach_num
	for k = 3
		emgRaw = reshape(emgFilteredWindow(k,:,plot_start:plot_end),size(emgFilteredWindow,2),plot_end-plot_start+1);
	
	  subplot(length(reach_num)+1,channel,j)
	  plot(emgRaw(i,:),'k-')
	  ylim([-300 300]);
    title(['Reach # ' num2str(i)])
	  j = j +1;
	end
end


fname = '/Users/ayesha/Documents/Ayesha_phd_local storage/EMG data analysis/emg_data_files/analysis/clean_working/18LLR_OFF_S_R_170_20180606T1700_AnalyzedEMG.mat';
[pathname,trialname] = fileparts(fname);
load(fname)


% Plot Filtered & Rectified data with average across reaches
j = 1;
h=figure('Name',trialname);
for i = reach_num
	for k = 3
		emgRaw = reshape(emgAnalyzed.RawData(k,:,:),size(emgAnalyzed.RawData,2),size(emgAnalyzed.RawData,3));
		emgAvg = reshape(emgAnalyzed.RawAverage(k,:,:),size(emgAnalyzed.RawAverage,2),size(emgAnalyzed.RawAverage,3));
	
	  subplot(length(reach_num)+1,channel,j)
	  plot(emgRaw(i,:),'k-')
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
	plot(reshape(emgAnalyzed.Average(k,1,:),1,size(emgAnalyzed.Average,3)),'k-');
	j = j +1;
end