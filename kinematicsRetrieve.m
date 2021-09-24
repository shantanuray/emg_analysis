function [kmData, keypoints] = kinematicsRetrieve(kmFname,refTags,row,header,fps,varargin)
    % kinematicsData = kinematicsRetrieve(kmFname, refTags, row, header, fps, ...
    %                                           'kmFileType','csv', ...
    %                                           'keypoints',{'nose','ihindlimb','chindlimb','iindex', ...
    %                                                        'ilittlefinger', 'ihand', 'kpd'}, ...
    %                                           'metafields',{'x', 'y', 'likelihood'},...
    %                                           'refFileHeader', 1);
    % Steps:
    % - Read kinematic data kmFname
    % - Read reference tags indexed by row
    % - header - column labels in reference tags
    % - fps = Video frame per second
    % - kinematics filetype (csv | h5)
    %     - Assumption:
    %       * if csv output of DLC, ignore first 3 1s and first column = index
    %       * if h5, no header and no index column; data arranged in transpose
    % - For all kinematics data
    %       - Save as raw
    %       - Separate wrt segment
    % - Store data in structure

    p = readInput(varargin);
    [kmFileType, keypoints, metafields, refFileHeader, h5DataSet] = parseInput(p.Results);
    % Get position of data columns from reference header
    fname_idx = find(~cellfun(@isempty, strfind(header, 'file name')));
    cond_idx = find(~cellfun(@isempty, strfind(header, 'condition')));
    timeCNO_idx = find(~cellfun(@isempty, strfind(header, 'time post CNO')));
    pos1_idx = find(~cellfun(@isempty, strfind(header, '1')));
    pos2_idx = find(~cellfun(@isempty, strfind(header, '2')));
    pos3_idx = find(~cellfun(@isempty, strfind(header, '3')));
    pullbout_idx = find(~cellfun(@isempty, strfind(header, 'pulling bout')));

    % Init output structure
    kmData = struct();

    % Get reference file ID
    [~, fileID, ~] =  fileparts(refTags{1,fname_idx}{row,1});
    kmData.fileID = fileID;
    kmData.tag = '';
    kmData.condition = refTags{1,cond_idx}(row,1);
    kmData.timePostCNO = refTags{1,timeCNO_idx}(row,1);
    kmData.pos1 = refTags{1,pos1_idx}(row,1);
    kmData.pos2 = refTags{1,pos2_idx}(row,1);
    kmData.pos3 = refTags{1,pos3_idx}(row,1);
    kmData.pullingBout = refTags{1,pullbout_idx}(row,1);
    kmData.trialTime = NaN;
    kmData.fps = fps;

    % Init segment time stamps
    % Time stamps may be slightly incorrect - round accordingly
    % & pos = 0 -> samp = 1
    pos1Samp = ceil(fps*kmData.pos1) + 1;
    pos2Samp = round(fps*kmData.pos2) + 1;
    pos3Samp = floor(fps*kmData.pos3) + 1;
    if (~(isnan(pos1Samp) | isnan(pos2Samp))) & (pos2Samp>pos1Samp)
        if kmData.pos1 > 0
            kmData.tag = 'full-discrete';
        else
            kmData.tag = 'partial-discrete';
        end
    else
        kmData.tag = 'no-discrete';
    end
    if (~(isnan(pos2Samp) | isnan(pos3Samp))) & (pos3Samp>pos2Samp)
        if kmData.pos2 > 0
            kmData.tag = [kmData.tag, '-', 'full-rhythmic'];
        else
            kmData.tag = [kmData.tag, '-', 'partial-rhythmic'];
        end
    else
        kmData.tag = [kmData.tag, '-', 'no-rhythmic'];
    end

    
    if strcmpi(kmFileType, 'h5')
        h5_data = h5read(kmFname, h5DataSet);
        if isfield(h5_data, 'values_block_0')
            kmData.raw = h5_data.values_block_0'; % Transpose the data to match csv format
            for kp = 1:length(keypoints)
                for mt = 1:length(metafields)
                    kmData.(keypoints{kp}).(metafields{mt}) = kmData.raw(:,(kp-1)*length(metafields)+mt);
                end
            end
        else
            kmData.raw = [];
        end
    elseif strcmpi(kmFileType, 'csv')
        fid = fopen(kmFname, 'r');
        fgetl(fid); % Ignore first line
        keypoints = strsplit(fgetl(fid), ','); % Read keypoints from second line
        % Example: 'bodyparts'  'nose'  'nose'  'nose'  'ihindlimb' 'ihindlimb' 'ihindlimb'
        %          'chindlimb'  'chindlimb' 'chindlimb' 'iindex'    'iindex'    'iindex'
        %          'ilittlefinger'  'ilittlefinger' 'ilittlefinger' 'ihand' 'ihand' 'ihand'
        %          'chand'  'chand' 'chand'

        fgetl(fid); % Ignore third line
        keypoint_fmt = repmat('%f',1,length(keypoints));
        keypoint_data = textscan(fid, keypoint_fmt, 'delimiter' , ',');
        fclose(fid);
        % Extract unique keypoints
        % Ignore first column label 'bodyparts'
        % keypoint label is repeated x length(metafields) times
        keypoints = keypoints(2:length(metafields):end);
        kmData.raw = [keypoint_data{2:end}];
        for kp = 1:length(keypoints)
            for mt = 1:length(metafields)
                data = kmData.raw(:,(kp-1)*length(metafields)+mt);
                data = returnNonZero(data);
                kmData.(keypoints{kp}).(metafields{mt}) = data;
            end
        end
    end
    if ~isempty(kmData.raw)
        kmData.trialTime = length(kmData.raw)/fps;
        for kp = 1:length(keypoints)
            % pos1, pos2 and pos3 are wrt  the raw timeline
            % data start = 0 samp
            if (~(isnan(pos1Samp) | isnan(pos2Samp))) & (pos2Samp>pos1Samp)
                if kmData.pos1 > 0
                    kmData.(keypoints{kp}).discrete.tag = 'full-discrete';
                else
                    kmData.(keypoints{kp}).discrete.tag = 'partial-discrete';
                end
                for mt = 1:length(metafields)
                    totalSamp = length(kmData.(keypoints{kp}).(metafields{mt}));
                    kmData.(keypoints{kp}).discrete.(metafields{mt}) = kmData.(keypoints{kp}).(metafields{mt})(pos1Samp:min(totalSamp, pos2Samp));
                end
            else
                kmData.(keypoints{kp}).discrete.tag = 'no-discrete';
                for mt = 1:length(metafields)
                    kmData.(keypoints{kp}).discrete.(metafields{mt}) = [];
                end
            end
            if (~(isnan(pos2Samp) | isnan(pos3Samp))) & (pos3Samp>pos2Samp)
                if kmData.pos2 > 0
                    kmData.(keypoints{kp}).rhythmic.tag = 'full-rhythmic';
                else
                    kmData.(keypoints{kp}).rhythmic.tag = 'partial-rhythmic';
                end
                for mt = 1:length(metafields)
                    totalSamp = length(kmData.(keypoints{kp}).(metafields{mt}));
                    kmData.(keypoints{kp}).rhythmic.(metafields{mt}) = kmData.(keypoints{kp}).(metafields{mt})(pos2Samp:min(totalSamp, pos3Samp));
                end
            else
                kmData.(keypoints{kp}).rhythmic.tag = 'no-rhythmic';
                for mt = 1:length(metafields)
                    kmData.(keypoints{kp}).rhythmic.(metafields{mt}) = [];
                end
            end
        end % if kinematic data exists
    end % for keypoint


    %% Read input
    function p = readInput(input)
        p = inputParser;
        keypoints = {'nose','ihindlimb','chindlimb','iindex', 'ilittlefinger', 'ihand', 'chand'};
        metafields = {'x', 'y', 'likelihood'};
        kmFileType = 'csv';
        validFileType = {'csv','h5'};
        checkFileType = @(x) any(validatestring(x,validFileType));
        refFileHeader = true; % ref file contains header
        h5DataSet = '/df_with_missing/table';  % H5 file dataset label with Kinematic data
        addParameter(p,'kmFileType',kmFileType, checkFileType);
        addParameter(p,'keypoints',keypoints, @iscell);
        addParameter(p,'metafields',metafields, @iscell);
        addParameter(p,'refFileHeader',refFileHeader,@islogical);
        addParameter(p,'h5DataSet',h5DataSet,@isstring);
        parse(p, input{:});
    end

    function [kmFileType, keypoints, metafields, refFileHeader, h5DataSet] = parseInput(p)
        kmFileType = p.kmFileType;
        keypoints = p.keypoints;
        metafields = p.metafields;
        refFileHeader = p.refFileHeader;
        h5DataSet = p.h5DataSet;
    end
end