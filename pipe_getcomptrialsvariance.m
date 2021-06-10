function [listofFlags,listofS] = pipe_getcomptrialsvariance(EEG)
% --- choose a component
% --- empty list of variances of each epoch per component

listofVariances = zeros(EEG.trials,size(EEG.icawinv,2));
listofFlags = zeros(EEG.trials,size(EEG.icawinv,2));

for component = 1:size(EEG.icawinv,2)
    
    % --- gets all the data for the component
    componentData = EEG.icaact(component, :, :);
    [Cspectra,Cfreqs,Cspeccomp,Ccontrib,Cspecstd] = spectopo(componentData, EEG.pnts, EEG.srate);
    componentData = reshape(componentData,EEG.pnts,EEG.trials)
    % --- makes the descriptives for the component
    compMean = mean(componentData);
    compMaxp = max(componentData);
    compMinp = min(componentData);
    
    
    compVar = mean(var(componentData, [], 2));
    compStd = std(componentData);
    
    for trial = 1:EEG.trials
        
        % --- gets the data for the trial for the component
        thisTrialData = EEG.icaact(component, :, trial);
        %[Tspectra,Tfreqs,Tspeccomp,Tcontrib,Tspecstd] = spectopo(thisTrialData, EEG.pnts, EEG.srate);
        %[jp rej] = jointprob( EEG.icaact(component, :, :),probability,[],1)
        %[kurtosis rej] = rejkurt( EEG.icaact(component, :, :), 4, [], 1);
        
        trialVar = mean(var(thisTrialData, [], 2));
        trialMean = mean(thisTrialData);
        trialMaxp = max(thisTrialData);
        trialMinp = min(thisTrialData);
        
        trialVar = mean(var(componentData, [], 2));
        trialStd = std(componentData);
        % --- gets the variance of the component without that trial
        
        % --- something isn't right in this portion
%         difData = componentData;
%         difData(:,:,trial) = [];
%         projVar = mean(var(difData, [], 2));
%         
%         pvafval = 100 *(1 - trialVar/ compVar);
        %pvaf = num2str(pvafval, '%3.1f');
        listofVariances(trial,component) = trialStd(trial);
    end
end