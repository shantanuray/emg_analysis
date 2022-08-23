function emgDataOut = emgSegmentRetrieve_ConsolidatedData(emgPathName,dataFname,fs,varargin)
    % emgDataOut = emgSegmentRetrieve_ConsolidatedData(emgPathName,dataFname,30000,
    %                                               'start_pos',15000, 'end_pos',55000,
    %                                               'channels',{'bi_R','tri_R','bi_L','tri_L'});
    % This is extraction for data from modified setup circa August 2022
    % Ask Ayesha for more details. Single MAT files has all of the data
    % Replaces emgRetrieveFolder
    % Steps:
    % - Read MAT file
    %       Struct with one field EMG_Struct
    %           Struct with two fields (data_raw, data_smooth) x number of trial rows
    %               - data_raw                      | data_smooth
    %                   Row Struct -> Trial 
    %                   **row 1==bi_R
    %                   **row 2==tri_R
    %                   **row 3==bi_L
    %                   **row 4==tri_L
    % - Segment data (input by user)
    % - Store data in structure
    p = readInput(varargin);
    [channels, dataType, start_pos, end_pos] = parseInput(p.Results);
    emgDataOut = [];

    % Read consolidated EMG file
    emgFile = fullfile(emgPathName,dataFname);
    [~, fileID, ~] =  fileparts(dataFname);
    emgConsolidated = load(emgFile);
    % Data is saved within a struct EMG_struct
    emgConsolidated = emgConsolidated.('EMG_struct');
    if ~isfield(emgConsolidated, dataType{1})
        disp(sprintf('Error: Check data format for %s. %s field missing.', fileID, dataType{1}));
        disp(fieldnames(emgConsolidated));
        return;
    end
    for row = 1:length(emgConsolidated)
        % Init output structure
        emgData = struct();
        emgData.fileID = sprintf('%s_%d',fileID, row);
        emgData.tag = NaN; % Backward compatibility
        emgData.condition = NaN; % Backward compatibility
        emgData.error = NaN;
        for dt = 1:length(dataType)
            if size(emgConsolidated(row).(dataType{dt}), 1) < length(channels)
                disp(['Error: Check data format for ' fileID '. Expected ' length(channels) ' - Got ' size(emgConsolidated.(dataType{dt}), 1)]);
                return;
            end
            for chan = 1:length(channels)
                emgData.(channels{chan}).fileID =  sprintf('%s_%d',fileID, row);
                emgData.(channels{chan}).samplingFrequency =  fs;
                emgData.(channels{chan}).offset =  NaN;
                if length(emgConsolidated(row).(dataType{dt})(chan,:)) < end_pos
                    emgData.(channels{chan}).(dataType{dt}).raw = nan;
                    emgData.error = sprintf('Data length than %s', end_pos);
                else
                    emgData.(channels{chan}).(dataType{dt}).raw = emgConsolidated(row).(dataType{dt})(chan, start_pos:end_pos);
                end
            end
        end
        emgDataOut = [emgDataOut emgData];
    end

    %% Read input
    function p = readInput(input)
        p = inputParser;
        start_pos = 15000;
        end_pos = 55000;
        channels = {'bi_R','tri_R','bi_L','tri_L'};
        dataType = {'data_raw', 'data_smooth'};
        validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
        addParameter(p,'channels',channels, @iscell);
        addParameter(p,'dataType',dataType, @iscell);
        addParameter(p,'start_pos',start_pos, validScalarPosNum);
        addParameter(p,'end_pos',end_pos, validScalarPosNum);
        parse(p, input{:});
    end

    function [channels,dataType,start_pos,end_pos] = parseInput(p)
        channels = p.channels;
        dataType = p.dataType;
        start_pos = p.start_pos;
        end_pos = p.end_pos;
    end
end