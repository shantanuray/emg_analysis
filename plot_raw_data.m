channel = 2;
reach_num = 1:8;

emgRaw = reshape(emgAnalyzed.RawData(channel,:,:),size(emgAnalyzed.RawData,2),size(emgAnalyzed.RawData,3));
emgAvg = reshape(emgAnalyzed.RawAverage(channel,:,:),size(emgAnalyzed.RawAverage,2),size(emgAnalyzed.RawAverage,3));
h=figure('Name',['FPS: 250; Channel: ',num2str(channel)]);
j = 1;
for i = reach_num
  subplot(length(reach_num),1,j)
  j = j +1;
  plot(emgRaw(i,:),'b-')
  hold on
  plot(emgAvg(i,:),'r-')
  %plot(reshape(emgAnalyzed.MovingAverage(3,1,:),1,1601)/mean(reshape(emgAnalyzed.MovingAverage(3,1,:),1,1601)),'r-');
  %plot(reshape(emgAnalyzed.Average(3,1,:),1,1601)/mean(reshape(emgAnalyzed.Average(3,1,:),1,1601)),'b-');
end