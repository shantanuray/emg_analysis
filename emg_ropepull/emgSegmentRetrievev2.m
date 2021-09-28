function emgData = emgSegmentRetrievev2(emgPathName,dataFname,refTags,header,varargin)
    % emgData = emgSegmentRetrievev2(emgPathName,dataFname,refTags,
    %            'channels',{'bi','tri','trap','ecu'});
    % Steps:
    % - Read MAT file with EMG data
    % - Read CSV with segment information
    % - Segment data
    % - Store data in structure 
    p = readInput(varargin);
    [channels] = parseInput(p.Results);

    % Get location of data from column labels
    fname_idx = find(~cellfun(@isempty, strfind(header, 'file name')));
    cond_idx = find(~cellfun(@isempty, strfind(header, 'condition')));
    timeCNO_idx = find(~cellfun(@isempty, strfind(header, 'time post CNO')));
    pos1_idx = find(~cellfun(@isempty, strfind(header, '1')));
    pos2_idx = find(~cellfun(@isempty, strfind(header, '2')));
    pos3_idx = find(~cellfun(@isempty, strfind(header, '3')));
    pullbout_idx = find(~cellfun(@isempty, strfind(header, 'pulling bout')));

    % Init output structure
    emgData = struct();
    % Read EMG file
    emgFile = fullfile(emgPathName,dataFname);
    [~, fileID, ~] =  fileparts(dataFname);
    fileID1 = strrep(fileID, '-', '_');
    fileID1 = strrep(fileID1, '(', '_');
    fileID1 = strrep(fileID1, ')', '_');
    fileID1 = strrep(fileID1, ' ', '_');
    emgRaw = load(emgFile);
    emgData.fileID = fileID;
    emgData.tag = '';
    emgData.condition = NaN;
    if ~isfield(emgRaw, [fileID1, '_', channels{1}])
        disp(['Required channels - bi, tri, ecu, trap not found for ' fileID1]);
        for chan = 1:length(channels)
            emgData.(channels{chan}) = struct();
        end
        return;
    end
    for chan = 1:length(channels)
        fs =  1/emgRaw.([fileID1, '_', channels{chan}]).interval;
        emgData.(channels{chan}).fileID =  fileID;
        emgData.(channels{chan}).samplingFrequency =  fs;
        emgData.(channels{chan}).offset =  emgRaw.([fileID1, '_', channels{chan}]).offset;
        emgData.(channels{chan}).raw =  emgRaw.([fileID1, '_', channels{chan}]).values;
    end

    % Compare to reference CFL tag file
    idx = find(~cellfun(@isempty, strfind(refTags{1,1}, fileID)));
    % TODO: If multiple matches, then what?
    if isempty(idx)
        disp(['No match found for ' fileID])
        return;
    else
        idx = idx(1);
        disp(['Found match ', refTags{1,1}{idx}])
        emgData.condition = refTags{1,cond_idx}(idx,1);
        emgData.timePostCNO = refTags{1,timeCNO_idx}(idx,1);
        emgData.pos1 = refTags{1,pos1_idx}(idx,1);
        emgData.pos2 = refTags{1,pos2_idx}(idx,1);
        emgData.pos3 = refTags{1,pos3_idx}(idx,1);
        emgData.pullingBout = refTags{1,pullbout_idx}(idx,1);
        emgData.trialTime = length(emgData.(channels{1}).raw)*emgRaw.([fileID1, '_', channels{1}]).interval;

        % Time stamps may be slightly incorrect - round accordingly
        % & pos = 0 -> samp = 1
        pos1Samp = ceil(fs*emgData.pos1) + 1;
        pos2Samp = round(fs*emgData.pos2) + 1;
        pos3Samp = floor(fs*emgData.pos3) + 1;
        if (~(isnan(pos1Samp) | isnan(pos2Samp))) & (pos2Samp>pos1Samp)
            if emgData.pos1 > 0
                emgData.tag = 'full-discrete';
            else
                emgData.tag = 'partial-discrete';
            end
        else
            emgData.tag = 'no-discrete';
        end
        if (~(isnan(pos2Samp) | isnan(pos3Samp))) & (pos3Samp>pos2Samp)
            if emgData.pos2 > 0
                emgData.tag = [emgData.tag, '-', 'full-rhythmic'];
            else
                emgData.tag = [emgData.tag, '-', 'partial-rhythmic'];
            end
        else
            emgData.tag = [emgData.tag, '-', 'no-rhythmic'];
        end
      
        for chan = 1:length(channels)
            fs =  1/emgRaw.([fileID1, '_', channels{chan}]).interval;

            % emgData.pos1, emgData.pos2 and emgData.pos3 are wrt to the raw timeline
            totalSamp = length(emgData.(channels{chan}).raw);
            emgData.(channels{chan}).trialTime = totalSamp*emgRaw.([fileID1, '_', channels{chan}]).interval;
            % the emg data start = 0
            if (~(isnan(pos1Samp) | isnan(pos2Samp))) & (pos2Samp>pos1Samp)
                if emgData.pos1 > 0
                    emgData.(channels{chan}).discrete.tag = 'full-discrete';
                else
                    emgData.(channels{chan}).discrete.tag = 'partial-discrete';
                end
                emgData.(channels{chan}).discrete.raw = emgData.(channels{chan}).raw(pos1Samp:min(totalSamp, pos2Samp));
            else
                emgData.(channels{chan}).discrete.tag = 'no-discrete';
                emgData.(channels{chan}).discrete.raw = [];
            end
            if (~(isnan(pos2Samp) | isnan(pos3Samp))) & (pos3Samp>pos2Samp)
                if emgData.pos2 > 0
                    emgData.(channels{chan}).rhythmic.tag = 'full-rhythmic';
                else
                    emgData.(channels{chan}).rhythmic.tag = 'partial-rhythmic';
                end
                emgData.(channels{chan}).rhythmic.raw = emgData.(channels{chan}).raw(pos2Samp:min(totalSamp, pos3Samp));
            else
                emgData.(channels{chan}).rhythmic.tag = 'no-rhythmic';
                emgData.(channels{chan}).rhythmic.raw = [];
            end
        end % for channel
    end % if file match

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