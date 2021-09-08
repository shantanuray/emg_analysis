% Run EMG Analysis on selected folders
% emgPaths = {'D:\U19\CFL5', 'D:\U19\CFL4', 'D:\U19\JFL2'};

[CFL5_CNO, CFL5_Ctrl] = emgSegmentRetrieveFolder('D:\U19\CFL5', 'CFL5_metadata.csv');
[CFL4_CNO, CFL4_Ctrl] = emgSegmentRetrieveFolder('D:\U19\CFL4', 'CFL4_metadata.csv');
[JFL2_CNO, JFL2_Ctrl] = emgSegmentRetrieveFolder('D:\U19\JFL2', 'JFL2_metadata.csv');
save CFL5.mat CFL5_CNO CFL5_Ctrl
save CFL4.mat CFL4_CNO CFL4_Ctrl
save JFL2.mat JFL2_CNO JFL2_Ctrl

[CFL4_CNO, CFL4_CNO_m, CFL4_CNO_peak_dist] = emgGetPeaksFolder(CFL4_CNO);
[CFL4_Ctrl, CFL4_Ctrl_m, CFL4_Ctrl_peak_dist] = emgGetPeaksFolder(CFL4_Ctrl);

[CFL5_CNO, CFL5_CNO_m, CFL5_CNO_peak_dist] = emgGetPeaksFolder(CFL5_CNO);
[CFL5_Ctrl, CFL5_Ctrl_m, CFL5_Ctrl_peak_dist] = emgGetPeaksFolder(CFL5_Ctrl);

[JFL2_CNO, JFL2_CNO_m, JFL2_CNO_peak_dist] = emgGetPeaksFolder(JFL2_CNO);
[JFL2_Ctrl, JFL2_Ctrl_m, JFL2_Ctrl_peak_dist] = emgGetPeaksFolder(JFL2_Ctrl);
