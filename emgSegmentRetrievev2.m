function emgData = emgSegmentRetrievev2(emgPathName,dataFname,refTags,varargin)
    % emgData = emgSegmentRetrievev2(emgPathName,dataFname,refTags,
    %            'channels',{'bi','tri','trap','ecu'});
    % Steps:
    % - Read MAT file with EMG data
    % - Read CSV with segment information
    % - Segment data
    % - Store data in structure 
    p = readInput(varargin);
    [channels] = parseInput(p.Results);
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
    emgData(1).condition = '';
    if ~isfield(emgRaw, [fileID1, '_', channels{1}])
      disp(['Required channels - bi, tri, ecu, trap not found for ' fileID1]);
      for chan = 1:length(channels)
        emgData(1).(channels{chan}) = struct();
      end
      return;
    end
    for chan = 1:length(channels)
      fs =  1/emgRaw.([fileID1, '_', channels{chan}]).interval;
      emgData(1).(channels{chan}).fileID =  fileID;
      emgData(1).(channels{chan}).samplingFrequency =  fs;
      emgData(1).(channels{chan}).offset =  emgRaw.([fileID1, '_', channels{chan}]).offset;
      emgData(1).(channels{chan}).raw =  emgRaw.([fileID1, '_', channels{chan}]).values;
    end
    % Compare to reference CFL tag file
    idx = find(~cellfun(@isempty, strfind(refTags{1,1}, fileID)));
    % TODO: If multiple matches, then what?
    if isempty(idx)
      disp(['No match found for, ' fileID])
      return;
    else
      idx = idx(1);
      disp(['Found match', refTags{1,1}{idx}])
      % Col 2 -> condition true - cno or false - control
      emgData(1).condition = refTags{1,2}(idx); 

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
        end
      else
        emgData(1).tag = 'no-discrete';
      end
      if (~(isnan(pos2Samp) | isnan(pos3Samp))) & (pos3Samp>pos2Samp)
        if pos2Samp > 0
          emgData(1).tag = [emgData(1).tag, '-', 'full-rhythmic'];
        else
          emgData(1).tag = [emgData(1).tag, '-', 'partial-rhythmic'];
        end
      else
        emgData(1).tag = [emgData(1).tag, '-', 'no-rhythmic'];
      end
      
      for chan = 1:length(channels)
        fs =  1/emgRaw.([fileID1, '_', channels{chan}]).interval;
        emgData(1).(channels{chan}).timePostCNO = refTags{1,3}(idx); % 3->time post CNO
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
          end
          emgData(1).(channels{chan}).discrete.raw = emgData(1).(channels{chan}).raw(1:min(totalSamp, pos2Samp));
        else
          emgData(1).(channels{chan}).discrete.tag = 'no-discrete';
          emgData(1).(channels{chan}).discrete.raw = [];
        end
        if (~(isnan(pos2Samp) | isnan(pos3Samp))) & (pos3Samp>pos2Samp)
          if pos2Samp > 0
            emgData(1).(channels{chan}).rhythmic.tag = 'full-rhythmic';
          else
            emgData(1).(channels{chan}).rhythmic.tag = 'partial-rhythmic';
          end
          emgData(1).(channels{chan}).rhythmic.raw = emgData(1).(channels{chan}).raw(pos2Samp:min(totalSamp, pos3Samp));
        else
          emgData(1).(channels{chan}).rhythmic.tag = 'no-rhythmic';
          emgData(1).(channels{chan}).rhythmic.raw = [];
        end
      end
    end

    %% Read input
    function p = readInput(input)
        %   - channels              Default - {'bi','tri','trap','ecu'}
        p = inputParser;
        channels = {'bi','tri','trap','ecu'};
        addParameter(p,'channels',channels, @iscell);
        parse(p, input{:});
    end

    function [channels] = parseInput(p)
        channels = p.channels;
    end
end