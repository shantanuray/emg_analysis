function [emgDataCNO, emgDataCtrl, header] = emgSegmentRetrieveFolder(emgPathName, refFile, varargin)
    % [emgDataCNO, emgDataCtrl] = emgSegmentRetrieveFolder(emgPathName, refFile, 'channels', {'bi','tri','trap','ecu'});
    % Steps:
    % - Read all MAT files in the folder with EMG data
    % - Read refFile - CSV with segment information
    % - Segment data
    % - Store data in structure

    p = readInput(varargin);
    [channels,refFileHeader] = parseInput(p.Results);

	% Get EMG MAT file names
	emgFiles = dir(fullfile(emgPathName, '*.mat'));
	% Read reference tag CSV
	% Assumption: No header and replace by NaN
	fid = fopen(fullfile(emgPathName,refFile), 'r');
	if refFileHeader
        header = fgetl(fid);
        header = strsplit(header, ',');
    else
        header = {'file name', 'condition', 'time post CNO', '1', '2', '3', 'pulling bout'};
    end
    refTags = textscan(fid, '%s%d%d%f%f%f%d', 'delimiter' , ',');
    fclose(fid);
	emgDataCNO = [];
	emgDataCtrl = [];
	for j = 1:length(emgFiles)
		dataFname = emgFiles(j).name;
		disp(['Processing ' emgPathName filesep dataFname])
		emgData = emgSegmentRetrieve(emgPathName,dataFname,refTags,header,'channels',channels);
		if emgData.condition == 1
			emgDataCNO = [emgDataCNO emgData];
		elseif emgData.condition == 0
			emgDataCtrl = [emgDataCtrl emgData];
		end
	end
	return;

	%% Read input
	function p = readInput(input)
	    %   - channels              Default - {'bi','tri','trap','ecu'}
	    p = inputParser;
	    channels = {'bi','tri','trap','ecu'};
	    addParameter(p,'channels',channels, @iscell);
	    refFileHeader = false;
	    addParameter(p,'refFileHeader',refFileHeader, @iscell);
	    parse(p, input{:});
	end

	function [channels,refFileHeader] = parseInput(p)
	    channels = p.channels;
	    refFileHeader = p.refFileHeader;
	end
end