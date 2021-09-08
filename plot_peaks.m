
rms_pct = [0.25, 0.35, 0.45];
figure
hold on
for plotNum = 0:length(rms_pct) %:2:length(channels)*2
	chan = 1;
	if plotNum == 0
		% plot discrete
		subplot(length(rms_pct)+1, 2, (plotNum)*2 + 1)
		data_d = emgData(1).(channels{chan}).discrete.mva;
		ts1 = emgData(f).(channels{chan}).pos1:1/emgData(f).(channels{chan}).fs:emgData(1).(channels{chan}).pos2;
		ts1 = ts1(1:length(data_d));
		[pks1, idx1] = findpeaks(data_d, 'MinPeakDistance', round(minPeakDistance*fs));
		plot(ts1, data_d, ts1(idx1), data_d(idx1), 'xm')
		title(sprintf('discrete MinPeakDistance %dms', round(minPeakDistance*1000)))
		% plot rhythmic
		subplot(length(rms_pct)+1, 2, (plotNum)*2 + 2)
		data_r = emgData(1).(channels{chan}).rhythmic.mva;
		ts2 = emgData(f).(channels{chan}).pos2:1/emgData(f).(channels{chan}).fs:emgData(1).(channels{chan}).pos3;
		ts2 = ts2(1:length(data_r));
		[pks2, idx2] = findpeaks(data_r, 'MinPeakDistance', round(minPeakDistance*fs));
		plot(ts2, data_r, ts2(idx2), data_r(idx2), 'xm')
		title(sprintf('rhythmic MinPeakDistance %dms', round(minPeakDistance*1000)))
	else
		% plot discrete
		subplot(length(rms_pct)+1, 2, (plotNum)*2 + 1)
		data_d = emgData(1).(channels{chan}).discrete.mva;
		data_d_rms = rms(data_d(round(movingAverageWindow*fs):end));
		ts1 = emgData(f).(channels{chan}).pos1:1/emgData(f).(channels{chan}).fs:emgData(1).(channels{chan}).pos2;
		ts1 = ts1(1:length(data_d));
		[pks1, idx1] = findpeaks(data_d, 'MinPeakDistance', round(minPeakDistance*fs), 'MinPeakHeight', rms_pct(plotNum)*data_d_rms);
		plot(ts1, data_d, ts1(idx1), data_d(idx1), 'xm')
		title(sprintf('discrete MinPeakDistance %dms MinPeakHeight %3.2f', round(minPeakDistance*1000), rms_pct(plotNum)*data_d_rms))
		% plot rhythmic
		subplot(length(rms_pct)+1, 2, (plotNum)*2 + 2)
		data_r = emgData(1).(channels{chan}).rhythmic.mva;
		data_r_rms = rms(data_r(round(movingAverageWindow*fs):end));
		ts2 = emgData(f).(channels{chan}).pos2:1/emgData(f).(channels{chan}).fs:emgData(1).(channels{chan}).pos3;
		ts2 = ts2(1:length(data_r));
		[pks2, idx2] = findpeaks(data_r, 'MinPeakDistance', round(minPeakDistance*fs), 'MinPeakHeight', rms_pct(plotNum)*data_r_rms);
		plot(ts2, data_r, ts2(idx2), data_r(idx2), 'xm')
		title(sprintf('rhythmic MinPeakDistance %dms MinPeakHeight %3.2f', round(minPeakDistance*1000), rms_pct(plotNum)*data_r_rms))
	end
end
hold off
