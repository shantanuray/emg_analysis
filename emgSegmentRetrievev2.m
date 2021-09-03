function emgData = emgSegmentRetrievev2(emgPathName,dataFname,refTags,varargin)
    % emgData = emgSegmentRetrievev2(emgPathName,dataFname,refTags,
    %            'moving_average_window',100/1000,
    %            'channels',{'bi','tri','trap','ecu'});
    % Steps:
    % - Read MAT file with EMG data
    % - Read CSV with segment information
    % - Segment data
    % - Filter data (moving average)
    % - Store data in structure 
    p = readInput(varargin);
    [moving_average_window, channels, min_peak_distance, min_peak_height] = parseInput(p.Results);
    % Init output structure
    emgData = struct([]);
    % Read EMG file
    emgFile = fullfile(emgPathName,dataFname);
    [~, fileID, ~] =  fileparts(dataFname);
    fileID1 = strrep(fileID, '-', '_');
    fileID1 = strrep(fileID1, '(', '_');
    fileID1 = strrep(fileID1, ')', '_');
    fileID1 = strrep(fileID1, ' ', '_');
    emgRaw = load(emgFile);
    emgData(1).fileID = fileID;
    emgData(1).tag = '';
    if ~isfield(emgRaw, [fileID1, '_', channels{1}])
      disp(['Required channels - bi, tri, ecu, trap not found for ' fileID1]);
      for chan = 1:length(channels)
        emgData(1).(channels{chan}) = struct();
      endfor
      return;
    endif
    for chan = 1:length(channels)
      fs =  1/emgRaw.([fileID1, '_', channels{chan}]).interval;
      emgData(1).(channels{chan}).fileID =  fileID;
      emgData(1).(channels{chan}).movingAverageWindow =  NaN;
      emgData(1).(channels{chan}).channels =  channels;
      emgData(1).(channels{chan}).samplingFrequency =  fs;
      emgData(1).(channels{chan}).offset =  emgRaw.([fileID1, '_', channels{chan}]).offset;
      emgData(1).(channels{chan}).raw =  emgRaw.([fileID1, '_', channels{chan}]).values;
    endfor
    % Compare to reference CFL tag file
    idx = find(~cellfun(@isempty, strfind(refTags{1,1}, fileID)));
    % TODO: If multiple matches, then what?
    if isempty(idx)
      disp(['No match found for, ' fileID])
      return;
    else
      idx = idx(1);
      disp(['Found match', refTags{1,1}{idx}])
      % Extract rhythmic and discrete timestamps
      pos1 = refTags{1,4}(idx); % 4 -> pos1
      pos2 = refTags{1,5}(idx); % 5 -> pos2
      pos3 = refTags{1,6}(idx); % 6 -> pos3
      % Time stamps may be slightly incorrect - round accordingly
      % & pos = 0 -> samp = 1
      pos1Samp = ceil(fs*pos1) + 1;
      pos2Samp = round(fs*pos2) + 1;
      pos3Samp = floor(fs*pos3) + 1;
      if (~(isnan(pos1Samp) | isnan(pos2Samp))) & (pos2Samp>pos1Samp)
        if pos1Samp > 0
          emgData(1).tag = 'full-discrete';
        else
          emgData(1).tag = 'partial-discrete';
        endif
      else
        emgData(1).tag = 'no-discrete';
      endif
      if (~(isnan(pos2Samp) | isnan(pos3Samp))) & (pos3Samp>pos2Samp)
        if pos2Samp > 0
          emgData(1).tag = [emgData(1).tag, '-', 'full-rhythmic'];
        else
          emgData(1).tag = [emgData(1).tag, '-', 'partial-rhythmic'];
        endif
      else
        emgData(1).tag = [emgData(1).tag, '-', 'no-rhythmic'];
      endif
      
      for chan = 1:length(channels)
        fs =  1/emgRaw.([fileID1, '_', channels{chan}]).interval;
        emgData(1).(channels{chan}).movingAverageWindow = moving_average_window;
        emgData(1).(channels{chan}).channels = channels;
        emgData(1).(channels{chan}).control = refTags{1,2}(idx); % Col 2 -> control true - 1 or false - 0
        emgData(1).(channels{chan}).timePostCNO = refTags{1,2}(idx); % 3->time post CNO
        emgData(1).(channels{chan}).pos1 = pos1;
        emgData(1).(channels{chan}).pos2 = pos2;
        emgData(1).(channels{chan}).pos3 = pos3;
        emgData(1).(channels{chan}).pullingBout = refTags{1,7}(idx); % 7 -> pulling bout

        % pos1, pos2 and pos3 are wrt to the raw timeline
        totalSamp = length(emgData(1).(channels{chan}).raw);
        % the emg data start = 0
        if (~(isnan(pos1Samp) | isnan(pos2Samp))) & (pos2Samp>pos1Samp)
          if pos1Samp > 0
            emgData(1).(channels{chan}).discrete.tag = 'full-discrete';
          else
            emgData(1).(channels{chan}).discrete.tag = 'partial-discrete';
          endif
          emgData(1).(channels{chan}).discrete.raw = emgData(1).(channels{chan}).raw(1:min(totalSamp, pos2Samp));
          % rectify bipolar emg signals
          emgData(1).(channels{chan}).discrete.rectified = abs(emgData(1).(channels{chan}).discrete.raw);
          % Moving average filter
          emgData(1).(channels{chan}).discrete.mva = movingAverage(emgData(1).(channels{chan}).discrete.rectified, moving_average_window, fs);
        else
          emgData(1).(channels{chan}).discrete.tag = 'no-discrete';
          emgData(1).(channels{chan}).discrete.raw = [];
        endif
        if (~(isnan(pos2Samp) | isnan(pos3Samp))) & (pos3Samp>pos2Samp)
          if pos2Samp > 0
            emgData(1).(channels{chan}).rhythmic.tag = 'full-rhythmic';
          else
            emgData(1).(channels{chan}).rhythmic.tag = 'partial-rhythmic';
          endif
          emgData(1).(channels{chan}).rhythmic.raw = emgData(1).(channels{chan}).raw(pos2Samp:min(totalSamp, pos3Samp));
          % rectify bipolar emg signals
          emgData(1).(channels{chan}).rhythmic.rectified = abs(emgData(1).(channels{chan}).rhythmic.raw);
          % Moving average filter
          emgData(1).(channels{chan}).rhythmic.mva = movingAverage(emgData(1).(channels{chan}).rhythmic.rectified, moving_average_window, fs);
        else
          emgData(1).(channels{chan}).rhythmic.tag = 'no-rhythmic';
          emgData(1).(channels{chan}).rhythmic.raw = [];
        endif
      endfor
    endif

    %% Read input
    function p = readInput(input)
        %   - moving_average_window Default - 100/1000; % 100ms
        %   - channels              Default - {'bi','tri','trap','ecu'}
        %   - min_peak_distance     Default - 100/1000; % 100ms
        %   - min_peak_height       Default - 0%
        p = inputParser;
        moving_average_window = 100/1000;
        channels = {'bi','tri','trap','ecu'};
        min_peak_distance = 100/1000;
        min_peak_height = 0.0;
        
        addParameter(p,'moving_average_window',moving_average_window, @isnumeric);
        addParameter(p,'channels',channels, @iscell);
        addParameter(p,'min_peak_distance',min_peak_distance, @isnumeric);
        addParameter(p,'min_peak_height',min_peak_height, @isnumeric);
        parse(p, input{:});
    end

    function [moving_average_window, channels, min_peak_distance, min_peak_height] = parseInput(p)
        moving_average_window = p.moving_average_window;
        channels = p.channels;
        min_peak_distance = p.min_peak_distance;
        min_peak_height = p.min_peak_height;
    end
end