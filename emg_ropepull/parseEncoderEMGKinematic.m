function trialMetadata = parseEncoderEMGKinematic(filepath, varargin)
    % Reference time line:
    % Situation 1: Complete EMG and Kinematic data
    % |----3s-----BNC1------------5s-------------| => EMG data
    %                   |----3s----BNC2------------5s-------------| => Kinematic data
    % Situation 2: Complete EMG Then Abort (No Kinematic)
    % |----3s-----BNC1------------5s-------------| => EMG data
    %                   |ABORT|
    % Situation 2: ABORT
    % |ABORT|

    % Initialize inputs
    p = readInput(varargin);
    [timeScale,...
        timePreBNC, timePostBNC,...
        encoderLogColumns] = parseInput(p.Results);
    encoderLog = readmatrix(filepath);
    encoderLog = array2table(encoderLog, 'VariableNames', encoderLogColumns);
    for t  = 1:height(encoderLog)
        trialMetadata(t).('trialNum') = encoderLog.('trialNum')(t);
        trialMetadata(t).('bnc1') = encoderLog.('bnc1')(t);
        trialMetadata(t).('bnc2') = encoderLog.('bnc2')(t);
        trialMetadata(t).('abort') = encoderLog.('abort')(t);
        if ~isnan(encoderLog.('bnc1')(t))
            trialMetadata(t).('emgStartT') = encoderLog.('bnc1')(t)*timeScale - timePreBNC;
            if trialMetadata(t).('emgStartT')<0
                trialMetadata(t).('emgMissedT') = trialMetadata(t).('emgStartT');
                trialMetadata(t).('emgStartT') = 1;
            end
            trialMetadata(t).('emgEndT') = encoderLog.('bnc1')(t)*timeScale + timePostBNC;
        end
        if ~isnan(encoderLog.('bnc1')(t))
            trialMetadata(t).('kinStartT') = encoderLog.('bnc2')(t)*timeScale - timePreBNC;
            if trialMetadata(t).('kinStartT')<0
                trialMetadata(t).('kinMissedT') = trialMetadata(t).('kinStartT');
                trialMetadata(t).('kinStartT') = 1;
            end
            trialMetadata(t).('kinEndT') = encoderLog.('bnc2')(t)*timeScale + timePostBNC;
        end
    end


    %% Read input
    function p = readInput(input)
        p = inputParser;
        timeScale = 1/1000; % in ms
        timePreBNC = 3.0; % in s
        timePostBNC = 5.0; % in s
        encoderLogColumns = {'trialNum','time','bnc1','bnc2','abort'};

        addParameter(p,'TimeScale',timeScale, @isnumeric);
        addParameter(p,'TimePreBNC',timePreBNC, @isnumeric);
        addParameter(p,'TimePostBNC',timePostBNC, @isnumeric);
        addParameter(p,'EncoderLogColumns',encoderLogColumns, @iscell);
        parse(p, input{:});
    end

    function [timeScale,...
        timePreBNC, timePostBNC,...
        encoderLogColumns] = parseInput(p)
        timeScale = p.TimeScale;
        timePreBNC = p.TimePreBNC;
        timePostBNC = p.TimePostBNC;
        encoderLogColumns = p.EncoderLogColumns;
    end
end