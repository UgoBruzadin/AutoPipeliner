function [EEG] = pipe_epochbycompsbyvar3(EEG,components)
    
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
    
% --- make a copy of EEG
EEG1 = EEG;
%EEG1 = pop_subcomp(EEG1);
% --- remove a component
[EEG1] = pop_subcomp(EEG1, components);
%THIS STILL NEEDS WORK
%NEEDS TO REMOVE ONLY COMPONENTS THAT MET THREASHOLD!!!
for i=1:length(components)

    % --- identify the bad trials
    
    % --- collects the V variance for each trial of the component
    V = var(EEG.icaact(components(i),:,:));
    % --- gets the S sum of the variance (i.e. total variance)
    S = sum(V,2);
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
    % --- makes an array with absolute values
    compAbs = abs(componentData);
    
    % --- gets the maximum value seen in the trial
    maxT = max(compAbs(:,:));
    % --- gets the mean for that trial
    avgT = mean(compAbs(:,:));
    % --- gets the standard dev for the trial
    stdT = std(compAbs(:,:));
    % --- gets the threshold cut for this trial given std
    threshT = avgT + (5 * stdT);
    % --- makes a bol list if spike is bigger than the threshold
    FlagS = maxT > threshT;
    % --- gets the number of the components flagged
    FlagsS = find(FlagS);
    
    TotalFlags = FlagV + FlagS;
    
    Flags = find(TotalFlags);
    
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
