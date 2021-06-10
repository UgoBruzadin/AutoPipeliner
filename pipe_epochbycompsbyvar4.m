function [EEG] = pipe_epochbycompsbyvar4(EEG,components)
    
if nargin < 2
    if find(EEG.reject.gcompreject)
        components = find(EEG.reject.gcompreject);
    else
        fprintf('No components rejected /r');
        return;
    end
end

% if components == 'all'
%     components = [1:size(EEG.icawinv,2)];
% end
    
for i=1:length(components)
    % --- make a copy of EEG
    EEG1 = EEG;
    %EEG1 = pop_subcomp(EEG1);
    % --- remove a component
    [EEG1] = pop_subcomp(EEG1, components(i));
    % --- identify the bad trials
    
    % --- collects the V variance for each trial of the component
    V = var(EEG.icaact(components(i),:,:));
    % --- gets the S sum of the variance (i.e. total variance)
    S = sum(V);
    % --- calculates C contributing variance for each trial
    C = (S - V)/S;
    % --- reshapes it in an array of lenght C
    C = reshape(C,1,length(C));
    % --- calculates the Z score for that array
    Z = zscore(C);
    % --- makes an array bols of the trials which fair above absolute 3 SDVs
    FlagV = abs(Z) > 3;
    % --- finds the trial numbers flagged above
    FlagsV = find(FlagV);
    
    % --- this method finds abnormal trials by peaks above 5 SDV
    
    componentData = EEG.icaact(components(i), :, :);
    
    componentData = reshape(componentData,EEG.pnts,EEG.trials);
    
    % --- makes an array of difference for each datapoint
    
    newColumn = zeros(size(componentData,1),1)
    shiftedData = componentData;
    shiftedData(:,end) = [];
    shiftedData2 = [newColumn,shiftedData];
    compDiff = componentData - shiftedData2;
    
    % --- makes an array with absolute values
    compAbs = abs(componentData);
    
    % --- gets the maximum value seen all trials
    maxT = max(compAbs(:,:));
    % --- gets the mean for all trials
    avgT = mean(compAbs(:,:));
    % --- gets the standard dev for all trials
    stdT = std(compAbs(:,:));
    % --- gets the threshold cut each trial given its std
    threshT = avgT + (5 * stdT);
    % --- makes a bol list if spike is bigger than the threshold
    FlagS = maxT > threshT;
    % --- gets the number of the components flagged
    FlagsS = find(FlagS);
    
    Flags = find(FlagS);
    
    % --- basically interpolates epochs from component removals
    % --- if there are any trial flagged, imputes those trials!
    % --- substitutes the specified epochs from the copy
    
    if Flags
        fprintf(strcat(' Rejected trials _', strcat(num2str(Flags)), ' from component _', strcat(num2str(components(i)))), '/r');
        EEG.data(:,:,Flags) = EEG1.data(:,:,Flags); 
    else
        fprintf(strcat('No trials rejected /r'));
    end
    
end

if Flags
    EEG = pop_saveset(EEG);
else
    fprintf(strcat('No changes occurred /r'));
end


end
