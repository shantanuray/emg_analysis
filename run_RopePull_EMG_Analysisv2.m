% Run EMG Analysis on selected folders
% emgPaths = {'D:\U19\CFL5', 'D:\U19\CFL4', 'D:\U19\JFL2'};

[CFL5_CNO, CFL5_Ctrl] = emgSegmentRetrieveFolder('D:\U19\CFL5', 'CFL5_metadata.csv');
[CFL4_CNO, CFL4_Ctrl] = emgSegmentRetrieveFolder('D:\U19\CFL4', 'CFL4_metadata.csv');
[JFL2_CNO, JFL2_Ctrl] = emgSegmentRetrieveFolder('D:\U19\JFL2', 'JFL2_metadata.csv');
save CFL5.mat CFL5_CNO CFL5_Ctrl
save CFL4.mat CFL4_CNO CFL4_Ctrl
save JFL2.mat JFL2_CNO JFL2_Ctrl

d_dr = "D:\U19\mat";
load('CFL5.mat')
load('CFL4.mat')
load('JFL2.mat')

[CFL4_CNO_Peaks, CFL4_CNO_m, CFL4_CNO_peak_dist] = emgGetPeaksFolder(CFL4_CNO);
[CFL4_Ctrl_Peaks, CFL4_Ctrl_m, CFL4_Ctrl_peak_dist] = emgGetPeaksFolder(CFL4_Ctrl);

[CFL5_CNO_Peaks, CFL5_CNO_m, CFL5_CNO_peak_dist] = emgGetPeaksFolder(CFL5_CNO);
[CFL5_Ctrl_Peaks, CFL5_Ctrl_m, CFL5_Ctrl_peak_dist] = emgGetPeaksFolder(CFL5_Ctrl);

[JFL2_CNO_Peaks, JFL2_CNO_m, JFL2_CNO_peak_dist] = emgGetPeaksFolder(JFL2_CNO);
[JFL2_Ctrl_Peaks, JFL2_Ctrl_m, JFL2_Ctrl_peak_dist] = emgGetPeaksFolder(JFL2_Ctrl);

save PeakDistanceAnalysis_CFL4_CFL5_JFL.mat CFL4_CNO_Peaks CFL4_CNO_m CFL4_CNO_peak_dist CFL4_Ctrl_Peaks CFL4_Ctrl_m CFL4_Ctrl_peak_dist CFL5_CNO_Peaks CFL5_CNO_m CFL5_CNO_peak_dist CFL5_Ctrl_Peaks CFL5_Ctrl_m CFL5_Ctrl_peak_dist JFL2_CNO_Peaks JFL2_CNO_m JFL2_CNO_peak_dist JFL2_Ctrl_Peaks JFL2_Ctrl_m JFL2_Ctrl_peak_dist;
conditions = {'Control', 'CNO'};

[peakDistTable, peakAmplTable] = flattenEMGPeakAnalysis(CFL4_CNO_Peaks, 'CFL4', conditions);
writetable(peakDistTable, 'CFL4_CNO_peak_dist.csv');
writetable(peakAmplTable, 'CFL4_CNO_peak_amp.csv');
[peakDistTable, peakAmplTable] = flattenEMGPeakAnalysis(CFL4_Ctrl_Peaks, 'CFL4', conditions);
writetable(peakDistTable, 'CFL4_Ctrl_peak_dist.csv');
writetable(peakAmplTable, 'CFL4_Ctrl_peak_amp.csv');

[peakDistTable, peakAmplTable] = flattenEMGPeakAnalysis(JFL2_CNO_Peaks, 'JFL2', conditions);
writetable(peakDistTable, 'JFL2_CNO_peak_dist.csv');
writetable(peakAmplTable, 'JFL2_CNO_peak_amp.csv');
[peakDistTable, peakAmplTable] = flattenEMGPeakAnalysis(JFL2_Ctrl_Peaks, 'JFL2', conditions);
writetable(peakDistTable, 'JFL2_Ctrl_peak_dist.csv');
writetable(peakAmplTable, 'JFL2_Ctrl_peak_amp.csv');

[peakDistTable, peakAmplTable] = flattenEMGPeakAnalysis(CFL5_CNO_Peaks, 'CFL5', conditions);
writetable(peakDistTable, 'CFL5_CNO_peak_dist.csv');
writetable(peakAmplTable, 'CFL5_CNO_peak_amp.csv');
[peakDistTable, peakAmplTable] = flattenEMGPeakAnalysis(CFL5_Ctrl_Peaks, 'CFL5', conditions);
writetable(peakDistTable, 'CFL5_Ctrl_peak_dist.csv');
writetable(peakAmplTable, 'CFL5_Ctrl_peak_amp.csv');


plotPeakDistHistogram('CFL4', {CFL4_Ctrl_peak_dist, CFL4_CNO_peak_dist}, 'rhythmic', 0:0.025:0.9);
plotPeakDistHistogram('CFL5', {CFL5_Ctrl_peak_dist, CFL5_CNO_peak_dist}, 'rhythmic', 0:0.025:0.9);
plotPeakDistHistogram('JFL2', {JFL2_Ctrl_peak_dist, JFL2_CNO_peak_dist}, 'rhythmic', 0:0.025:0.9);

km_dir = 'C:\Users\shantanu.ray\Downloads\ffmpeg_ts_200fps\ffmpeg_ts_200fps';
ref_file = 'C:\Users\shantanu.ray\Downloads\CFL_data_4.csv';
fps = 200;
[CFL4_KM_CNO, CFL4_KM_Ctrl, keypoints] = kinematicsRetrieveFolder(km_dir, ...
													   		   	  ref_file, ...
													   		   	  fps);

for d = 1:length(CFL4_KM_CNO)
	CFL4_KM_CNO(d) = kinematicsProcessor(CFL4_KM_CNO(d), ...
										 keypoints, fps);
end;
for d = 1:length(CFL4_KM_Ctrl)
	CFL4_KM_Ctrl(d) = kinematicsProcessor(CFL4_KM_Ctrl(d), ...
										 keypoints, fps);
end;

save CFL4_KM_Data.mat CFL4_KM_CNO CFL4_KM_Ctrl;

conditions = {'Control', 'CNO'};
segments = {'discrete', 'rhythmic'};
animal = 'CFL4';
CFL4_KM_Flat = [flattenKMData(CFL4_KM_CNO, keypoints, conditions, segments); ...
				flattenKMData(CFL4_KM_Ctrl, keypoints, conditions, segments)];
writetable(struct2table(CFL4_KM_Flat), [animal, '_kinematic.csv']);
