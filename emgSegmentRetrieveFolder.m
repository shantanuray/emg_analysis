function emgData = emgSegmentRetrieveFolder(emgPathName)
    % emgData = emgSegmentRetrieveFolder(emgPathName);
    % Steps:
    % - Read all MAT files in the folder with EMG data
    % - Read CSV with segment information
    % - Segment data
    % - Filter data (moving average)
    % - Store data in structure 
	emgPaths = {'D:\U19\CFL5', 'D:\U19\CFL4', 'D:\U19\JFL2'};

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
	for j = 1:length(emgFiles)
		dataFname = emgFiles(j).name;
		disp(['Processing ' emgPathName filesep dataFname])
		emgData(j) = emgSegmentRetrievev2(emgPathName,dataFname,refTags,
											 'moving_average_window',100/1000,
											 'channels',{'bi','tri','trap','ecu'},
											 'min_peak_distance', 100/1000,
											 'min_peak_height', 0.25);
	endfor
end