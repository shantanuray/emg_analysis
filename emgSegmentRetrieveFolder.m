function [emgDataCNO, emgDataCtrl] = emgSegmentRetrieveFolder(emgPathName, refFile, varargin)
    % [emgDataCNO, emgDataCtrl] = emgSegmentRetrieveFolder(emgPathName, refFile, 'channels', {'bi','tri','trap','ecu'});
    % Steps:
    % - Read all MAT files in the folder with EMG data
    % - Read refFile - CSV with segment information
    % - Segment data
    % - Store data in structure

    p = readInput(varargin);
    [channels] = parseInput(p.Results);

	% Get EMG MAT file names
	emgFiles = dir(fullfile(emgPathName, '*.mat'));
	% Read reference tag CSV
	% Assumption: No header and replace by NaN
	fid = fopen(fullfile(emgPathName,refFile), 'r');
	refTags = textscan(fid, '%s%d%d%f%f%f%d', 'delimiter' , ',');
	fclose(fid);
	cno_count = 0;
	ctrl_count = 0;
	emgDataCNO = [];
	emgDataCtrl = [];
	for j = 1:length(emgFiles)
		dataFname = emgFiles(j).name;
		disp(['Processing ' emgPathName filesep dataFname])
		emgData = emgSegmentRetrievev2(emgPathName,dataFname,refTags, 'channels',channels);
		if emgData.condition == 1
			cno_count = cno_count + 1;
			emgDataCNO = [emgDataCNO emgData];
		elseif emgData.condition == 0
			ctrl_count = ctrl_count + 1;
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
	    parse(p, input{:});
	end

	function [channels] = parseInput(p)
	    channels = p.channels;
	end
end