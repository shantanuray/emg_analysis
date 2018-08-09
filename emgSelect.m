function emgsamples = emgSelect(emgData, timestamp, intervalduration, samplingfrequency)
% emgsamples = emgSelect(emgData, timestamp, intervalduration, samplingfrequency);
samplenumber = round((timestamp) * (samplingfrequency), 0);
% computes the sample number in the emg channel data which corresponds to the time stamp from the annotations data file

intervalstart      = samplenumber(:,1) - round(intervalduration*samplingfrequency,0);
% subtracts thousand samples from annotation number
intervalend        = samplenumber(:,end) + round(intervalduration*samplingfrequency,0);
% adds thousand samples from the annotation number

numberintervals = size(timestamp,1);
% the number of intervals is equal to the number of annotations
emgsamples = [];
for i=1:numberintervals
    emgsamples = [emgsamples; emgData(intervalstart(i):intervalend(i))];
end