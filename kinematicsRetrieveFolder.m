function [kmDataCNO, kmDataCtrl, keypoints] = kinematicsRetrieveFolder(kmPath,refFile,fps,varargin)
    % [kmDataCNO, kmDataCtrl] = kinematicsRetrieveFolder(kmFname,refFile,fps, ...
    %                                           'kmFileType','csv', ...
    %                                           'keypoints',{'nose','ihindlimb','chindlimb','iindex', ...
    %                                                        'ilittlefinger', 'ihand', 'kpd'}, ...
    %                                           'metafields',{'x', 'y', 'likelihood'},...
    %                                           'refFileHeader', 1);
    % Steps:
    % - Read CSV with kinematics information (kmFname)
    % - Read reference file with segment info (refFile)
    %   fps = Video frame per second
    % - kinematics filetype (csv | h5)
    %     - Assumption:
    %       * if csv output of DLC, ignore first 3 rows and first column = index
    %       * if h5, no header and no index column; data arranged in transpose
    % - For all kinematics data
    %       - Save as raw
    %       - Separate wrt segment
    % - Store data in structure 
    p = readInput(varargin);
    [kmFileType, keypoints, metafields, refFileHeader, h5DataSet] = parseInput(p.Results);
    % Init output structure
    kmDataCNO = [];
    kmDataCtrl = [];
    % Init kinematics input data
    kmFiles = dir(fullfile(kmPath, ['*.',kmFileType] ));
    [km_fnames{1:length(kmFiles)}] = deal(kmFiles.name);
    % Concat into single columnar cell array
    km_fnames = cat(2, km_fnames');
    % Read reference tag CSV
    fid = fopen(refFile, 'r');
    if refFileHeader
        header = fgetl(fid);
        header = strsplit(header, ',');
    else
        header = {'file name', 'condition', 'time post CNO', 'pos1', 'pos2', 'pos3', 'pulling bout'};
    end
    refTags = textscan(fid, '%s%d%d%f%f%f%d', 'delimiter' , ',');
    fclose(fid);
    fname_idx = find(~cellfun(@isempty, strfind(header, 'file name')));
    for row = 1:length(refTags{1,fname_idx})
        % Get reference file ID
        [~, fileID, ~] =  fileparts(refTags{1,fname_idx}{row,1});

        % Find reference file name in kinematic file list
        idx = find(~cellfun(@isempty, strfind(km_fnames, fileID)));
        if isempty(idx)
            disp(['No match found for, ' fileID])
        else
            % Choose first if multiple
            % These happens because of use of starts with match
            % Example: filename_1 and filename_10 will both match filename_1
            % So it's okay to choose first since `dir` returns in alpha asc order
            idx = idx(1); 
            disp(['Found match ', km_fnames{idx}])
            kmFname = fullfile(kmPath,km_fnames{idx});
            [kmData, keypoints] = kinematicsRetrieve(kmFname, refTags, row, header, fps, ...
                                        'kmFileType', kmFileType, ...
                                        'keypoints', keypoints, ...
                                        'metafields', metafields,...
                                        'refFileHeader', refFileHeader);
            if kmData.condition == 1
                kmDataCNO = [kmDataCNO; kmData];
            elseif kmData.condition == 0
                kmDataCtrl = [kmDataCtrl; kmData];
            end % if control or CNO
        end % if match found of kinematic and reference tag file
    end % for row of reference tag file


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