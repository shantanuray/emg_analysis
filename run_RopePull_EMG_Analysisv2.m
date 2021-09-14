% Run EMG Analysis on selected folders
% emgPaths = {'D:\U19\CFL5', 'D:\U19\CFL4', 'D:\U19\JFL2'};

[CFL5_CNO, CFL5_Ctrl] = emgSegmentRetrieveFolder('D:\U19\CFL5', 'CFL5_metadata.csv');
[CFL4_CNO, CFL4_Ctrl] = emgSegmentRetrieveFolder('D:\U19\CFL4', 'CFL4_metadata.csv');
[JFL2_CNO, JFL2_Ctrl] = emgSegmentRetrieveFolder('D:\U19\JFL2', 'JFL2_metadata.csv');
save CFL5.mat CFL5_CNO CFL5_Ctrl
save CFL4.mat CFL4_CNO CFL4_Ctrl
save JFL2.mat JFL2_CNO JFL2_Ctrl

[CFL4_CNO_Peaks, CFL4_CNO_m, CFL4_CNO_peak_dist] = emgGetPeaksFolder(CFL4_CNO);
[CFL4_Ctrl_Peaks, CFL4_Ctrl_m, CFL4_Ctrl_peak_dist] = emgGetPeaksFolder(CFL4_Ctrl);

[CFL5_CNO_Peaks, CFL5_CNO_m, CFL5_CNO_peak_dist] = emgGetPeaksFolder(CFL5_CNO);
[CFL5_Ctrl_Peaks, CFL5_Ctrl_m, CFL5_Ctrl_peak_dist] = emgGetPeaksFolder(CFL5_Ctrl);

[JFL2_CNO_Peaks, JFL2_CNO_m, JFL2_CNO_peak_dist] = emgGetPeaksFolder(JFL2_CNO);
[JFL2_Ctrl_Peaks, JFL2_Ctrl_m, JFL2_Ctrl_peak_dist] = emgGetPeaksFolder(JFL2_Ctrl);

save PeakDistanceAnalysis_CFL4_CFL5_JFL.mat CFL4_CNO_Peaks CFL4_CNO_m CFL4_CNO_peak_dist CFL4_Ctrl_Peaks CFL4_Ctrl_m CFL4_Ctrl_peak_dist CFL5_CNO_Peaks CFL5_CNO_m CFL5_CNO_peak_dist CFL5_Ctrl_Peaks CFL5_Ctrl_m CFL5_Ctrl_peak_dist JFL2_CNO_Peaks JFL2_CNO_m JFL2_CNO_peak_dist JFL2_Ctrl_Peaks JFL2_Ctrl_m JFL2_Ctrl_peak_dist;

flattenEMGPeakAnalysis(CFL4_CNO_Peaks, 'CFL4', 'CNO');
flattenEMGPeakAnalysis(CFL4_Ctrl_Peaks, 'CFL4', 'Control');
flattenEMGPeakAnalysis(CFL5_CNO_Peaks, 'CFL5', 'CNO');
flattenEMGPeakAnalysis(CFL5_Ctrl_Peaks, 'CFL5', 'Control');
flattenEMGPeakAnalysis(JFL2_CNO_Peaks, 'JFL2', 'CNO');
flattenEMGPeakAnalysis(JFL2_Ctrl_Peaks, 'JFL2', 'Control');

plotPeakDistHistogram('CFL4', {CFL4_Ctrl_peak_dist, CFL4_CNO_peak_dist}, 'rhythmic', 0:0.025:0.9);
plotPeakDistHistogram('CFL5', {CFL5_Ctrl_peak_dist, CFL5_CNO_peak_dist}, 'rhythmic', 0:0.025:0.9);
plotPeakDistHistogram('JFL2', {JFL2_Ctrl_peak_dist, JFL2_CNO_peak_dist}, 'rhythmic', 0:0.025:0.9);
