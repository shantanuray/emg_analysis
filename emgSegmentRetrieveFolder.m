function [emgDataCNO, emgDataCtrl] = emgSegmentRetrieveFolder(emgPathName)
    % [emgDataCNO, emgDataCtrl] = emgSegmentRetrieveFolder(emgPathName);
    % Steps:
    % - Read all MAT files in the folder with EMG data
    % - Read CSV with segment information
    % - Segment data
    % - Filter data (moving average)
    % - Store data in structure

	% Get EMG MAT file names
	emgFiles = dir(fullfile(emgPathName, '*.mat'));
	% Get reference tag files
	refFiles = dir(fullfile(emgPathName, '*.csv'));
	% There should be only one csv; Pick top
	refFile = refFiles(1).name;
	% Read reference tag CSV
	% Assumption: No header and replace by NaN
	[fileid, condition, time_post_cno, pos1, pos2, pos3, pulling_bout] = textread(fullfile(emgPathName,refFile), '%s %d %d %f %f %f %d', 'delimiter' , ',');
	refTags = {fileid, condition, time_post_cno, pos1, pos2, pos3, pulling_bout};
	cno_count = 0;
	ctrl_count = 0;
	emgDataCNO = [];
	emgDataCtrl = [];
	for j = 1:length(emgFiles)
		dataFname = emgFiles(j).name;
		disp(['Processing ' emgPathName filesep dataFname])
		emgData = emgSegmentRetrievev2(emgPathName,dataFname,refTags, 'channels',{'bi','tri','trap','ecu'});
		if emgData.condition == 1
			cno_count = cno_count + 1;
			emgDataCNO = [emgDataCNO emgData];
		else
			ctrl_count = ctrl_count + 1;
			emgDataCtrl = [emgDataCtrl emgData];
		end
	end
	return;
end