channel = 1;
reach_num = [5,8,10,2];

emg = reshape(emgAnalyzed.RawAverage(channel,:,:),size(emgAnalyzed.RawAverage,2),size(emgAnalyzed.RawAverage,3));
figure
j = 1;
for i = reach_num
  subplot(length(reach_num),1,j)
  j = j +1;
  plot(emg(i,:)/mean(emg(i,:)))
  hold on
  %plot(reshape(emgAnalyzed.MovingAverage(3,1,:),1,1601)/mean(reshape(emgAnalyzed.MovingAverage(3,1,:),1,1601)),'r-');
  %plot(reshape(emgAnalyzed.Average(3,1,:),1,1601)/mean(reshape(emgAnalyzed.Average(3,1,:),1,1601)),'b-');
end