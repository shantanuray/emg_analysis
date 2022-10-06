function alignData = realignSignal(alignData, alignDataStartT, alignDataEndT, refDataStartT, refDataEndT, fs)
    % data = realignSignal(trialMeta, alignData, alignDataStartT, alignDataEndT, refDataStartT, refDataEndT, fs)
    %
    % Inputs:
    %   alignData - example emgData = peakData(5).bi_R.data_filtered.data;
    %   alignDataStartT, alignDataEndT - example: emgStart/End -> BNC2 time (s) from encoder => EMG trigger ['start', 'end']
    %   refDataStartT, refDataEndT - example: kinStart/End -> BNC1 time (s) from encoder => Kinematic trigger ['start', 'end']
    %   fs - alignData sampling frequency
    % Output:
    %   alignData truncated and aligned to common timescale
    %
    % Assumption: In reference to EMG & Kinematic data, signal is present from both BNCs
    if isempty(alignDataStartT)
        alignData = [];
    else
        if ~isempty(refDataStartT)
            start_t = max(refDataStartT, alignDataStartT);
            end_t = min(alignDataEndT, refDataEndT);
        else
            start_t = alignDataStartT;
            end_t = alignDataEndT;
        end
        % Get 0 timestamp wrt emgStartT
        start_t = start_t - alignDataStartT;
        end_t = end_t - alignDataStartT;
        start_ts = round(start_t*fs) + 1;
        end_ts = round(end_t*fs);
        if start_ts <= end_ts
            alignData = alignData(start_ts:end_ts);
        else
            alignData = [];
        end
    end
end