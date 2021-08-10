emgPathName = 'C:\Users\shantanu.ray\Downloads';
cflRefFile = 'CFL_3_Ref.csv';
fid = fopen(fullfile(emgPathName,cflRefFile), 'r');
cflRef =  textscan(fid, '%s%u%f%f%f%f%d%f%d%s%s', 'delimiter',',', 'EndOfLine', '\n');
fclose(fid);

savePathName = 'C:/Users/shantanu.ray/Downloads/';
dataFname = {'CFL3-3_saline_pull_5.mat'};

movingAverageWindow = 30/1000; % 30ms
channels = {'bi','tri','trap','ecu'};
emgData = struct([]);
for f = 1:length(dataFname)
	emgFile = fullfile(emgPathName,dataFname{f});
	[~, fileID, ~] =  fileparts(dataFname{f});
	fileID1 = strrep(fileID, '-', '_');
	emgRaw = load(emgFile);
	emgData(f).fileID = fileID;
	% [~, ~, ~, ~, fileTokens] = regexp(fileID, '(\w+\d+-\d+)_.+_(\w+_\d+)');
	% % cflRef{1,1} points to the file name
	% % There are two tokens to locate appropriate file name
	% % token 1: CFL-3_3 (at the start)
	% % token 2: pull_5 (at the end)
	% idx1 = find(~cellfun(@isempty, strfind(cflRef{1,1}, [fileTokens{1,1}{1,1}])));
	% idx2 = find(~cellfun(@isempty, strfind(cflRef{1,1}(idx1, 1), [fileTokens{1,1}{1,2}])));
	idx = find(~cellfun(@isempty, strfind(cflRef{1,1}, fileID)));
	% TODO: If multiple matches, then what?
	if isempty(idx)
		error('Could not find tag in reference CSV');
	else
		idx = idx(1);
	endif
  for chan = 1:length(channels)
    fs =  1/emgRaw.([fileID1, '_', channels{chan}]).interval;
    emgData(f).(channels{chan}).fs =  fs;
    emgData(f).(channels{chan}).offset =  emgRaw.([fileID1, '_', channels{chan}]).offset;
    emgData(f).(channels{chan}).raw =  emgRaw.([fileID1, '_', channels{chan}]).values;
    emgData(f).(channels{chan}).control = cflRef{1,2}(idx); % Col 2 -> control true or false
    emgData(f).(channels{chan}).timePostCNO = cflRef{1,2}(idx); % 3->time post CNO
    emgData(f).(channels{chan}).pos1 = cflRef{1,4}(idx); % 4 -> pos1
    emgData(f).(channels{chan}).pos2 = cflRef{1,5}(idx); % 5 -> pos2
    emgData(f).(channels{chan}).pos3 = cflRef{1,6}(idx); % 6 -> pos3
    emgData(f).(channels{chan}).pullingBout = cflRef{1,7}(idx); % 7 -> pulling bout
    emgData(f).(channels{chan}).totalTime = cflRef{1,8}(idx); % 8 -> total time
    emgData(f).(channels{chan}).totalFrameNo = cflRef{1,9}(idx); % 9 -> totalFrameNo
    emgData(f).(channels{chan}).tag = cflRef{1,10}(idx); % 10 -> tag (discrete, rhythmic, both)
    emgData(f).(channels{chan}).notes = cflRef{1,11}(idx); % 11 -> extra notes
    channels{chan}
    % Time stamps may be slightly incorrect. Compensate for length of data
    pos1Samp = ceil(fs*emgData(f).(channels{chan}).pos1)
    pos2Samp = round(fs*emgData(f).(channels{chan}).pos2)
    pos3Samp = floor(fs*emgData(f).(channels{chan}).pos3)
    totalSamp = length(emgData(f).(channels{chan}).raw);
    % emgData(f).(channels{chan}).discrete = struct([]);
    % emgData(f).(channels{chan}).rhythmic = struct([]);
    % pos1, pos2 and pos3 are wrt to the raw timeline
    % the emg data has already been cropped such that pos1 = start
    % Subtracting pos1Samp from other time-stamps to get emg data
    if (~(isnan(pos1Samp) | isnan(pos2Samp))) & (pos2Samp>pos1Samp)
    	if pos1Samp > 0
    		emgData(f).(channels{chan}).discrete.tag = 'full-discrete';
    	else
    		emgData(f).(channels{chan}).discrete.tag = 'partial-discrete';
    	endif
      	emgData(f).(channels{chan}).discrete.raw = emgData(f).(channels{chan}).raw(1:min(totalSamp, pos2Samp-pos1Samp));
      	% rectify bipolar emg signals
		emgData(f).(channels{chan}).discrete.rectified = abs(emgData(f).(channels{chan}).discrete.raw);
		% Moving average filter
      	emgData(f).(channels{chan}).discrete.mva = movingAverage(emgData(f).(channels{chan}).discrete.rectified, movingAverageWindow, fs);
    else
    	emgData(f).(channels{chan}).discrete.tag = 'no-discrete';
      	emgData(f).(channels{chan}).discrete.raw = [];
    endif
    if (~(isnan(pos2Samp) | isnan(pos3Samp))) & (pos3Samp>pos2Samp)
    	if pos2Samp > 0
    		emgData(f).(channels{chan}).rhythmic.tag = 'full-rhythmic';
    	else
    		emgData(f).(channels{chan}).rhythmic.tag = 'partial-rhythmic';
    	endif
      	emgData(f).(channels{chan}).rhythmic.raw = emgData(f).(channels{chan}).raw(pos2Samp-pos1Samp:min(totalSamp, pos3Samp-pos1Samp));
      	% rectify bipolar emg signals
      	emgData(f).(channels{chan}).rhythmic.rectified = abs(emgData(f).(channels{chan}).rhythmic.raw);
      	% Moving average filter
      	emgData(f).(channels{chan}).rhythmic.mva = movingAverage(emgData(f).(channels{chan}).rhythmic.rectified, movingAverageWindow, fs);
    else
    	emgData(f).(channels{chan}).rhythmic.tag = 'no-rhythmic';
      	emgData(f).(channels{chan}).rhythmic.raw = [];
    endif
  endfor
endfor


figure
subplot(2,1,1)
ts1 = emgData(1).bi.pos1:1/emgData(1).bi.fs:emgData(1).bi.pos3;
ts1 = ts1(1:totalSamp);
plot(ts1, emgData(1).bi.raw)
hold on

subplot(2,2,3)
ts2 = emgData(1).bi.pos1:1/emgData(1).bi.fs:emgData(1).bi.pos2;
ts2 = ts2(1:length(emgData(1).bi.discrete.raw));
plot(ts2, emgData(1).bi.discrete.raw)

subplot(2,2,4);
ts3 = emgData(1).bi.pos2:1/emgData(1).bi.fs:emgData(1).bi.pos3;
ts3 = ts3(1:length(emgData(1).bi.rhythmic.raw));
plot(ts3, emgData(1).bi.rhythmic.raw)


figure
hold on
for plotNum = 1:2:length(channels)*2
	chan = (plotNum - 1)/2 + 1
	% plot discrete
	subplot(4, 2, plotNum)
	data_d = emgData(1).(channels{chan}).discrete.mva;
	ts1 = emgData(f).(channels{chan}).pos1:1/emgData(f).(channels{chan}).fs:emgData(1).(channels{chan}).pos2;
	ts1 = ts1(1:length(data_d));
	[pks1, idx1] = findpeaks(data_d, 'MinPeakDistance', round(movingAverageWindow*fs));
	plot(ts1, data_d, ts1(idx1), data_d(idx1), 'xm')
	% plot rhythmic
	subplot(4, 2, plotNum+1)
	data_r = emgData(1).(channels{chan}).rhythmic.mva;
	ts2 = emgData(f).(channels{chan}).pos2:1/emgData(f).(channels{chan}).fs:emgData(1).(channels{chan}).pos3;
	ts2 = ts2(1:length(data_r));
	[pks2, idx2] = findpeaks(data_r, 'MinPeakDistance', round(movingAverageWindow*fs));
	plot(ts2, data_r, ts2(idx2), data_r(idx2), 'xm')
endfor


figure
hold on
for plotNum = 1 %:2:length(channels)*2
	chan = (plotNum - 1)/2 + 1
	% plot discrete
	subplot(1, 2, plotNum)
	data_d = emgData(1).(channels{chan}).discrete.mva;
	ts1 = emgData(f).(channels{chan}).pos1:1/emgData(f).(channels{chan}).fs:emgData(1).(channels{chan}).pos2;
	ts1 = ts1(1:length(data_d));
	[pks1, idx1] = findpeaks(data_d, 'MinPeakDistance', round(movingAverageWindow*fs));
	plot(ts1, data_d, ts1(idx1), data_d(idx1), 'xm')
	% plot rhythmic
	subplot(1, 2, plotNum+1)
	data_r = emgData(1).(channels{chan}).rhythmic.mva;
	ts2 = emgData(f).(channels{chan}).pos2:1/emgData(f).(channels{chan}).fs:emgData(1).(channels{chan}).pos3;
	ts2 = ts2(1:length(data_r));
	[pks2, idx2] = findpeaks(data_r, 'MinPeakDistance', round(movingAverageWindow*fs));
	plot(ts2, data_r, ts2(idx2), data_r(idx2), 'xm')
endfor
