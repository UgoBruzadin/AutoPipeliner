function EEG = pipe_epochbycompsbyvar(EEG,components,epochs)
    
for i=1:length(components)
    % --- make a copy of EEG
    EEG1 = EEG;
    % --- remove a component
    [EEG1] = pop_subcomp(EEG1, components(i));
    
    
% --- starts a loop for each
for component = 1:size(EEG.icawinv,2)
    
    % --- gets all the data for the component
    componentData = EEG.icaact(component, :, :);
    % -- reshape de data in a 2D matrix
    componentData = reshape(componentData,EEG.pnts,EEG.trials);
    % --- makes an array with absolute values
    compAbs = abs(componentData);
    
    % --- loops for every trial
    for trial = 1:EEG.trials
        % --- gets the maximum value seen in the trial
        maxT = max(compAbs(:,trial));
        % --- gets the mean for that trial
        avgT = mean(compAbs(:,trial));
        % --- gets the standard dev for the trial
        stdT = std(compAbs(:,trial));
        % --- gets the threshold cut for this trial given std
        threshT = avgT + cut * stdT;
        % --- add to the list if the spike is bigger than the threshold
        listofFlags(trial,component) = maxT > threshT;
    end
    
end
    
    
    % --- substitutes the specified epochs from the copy
    % --- basically interpolates epochs from component removals
    EEG.data(:,:,epochs) = EEG1.data(:,:,epochs(i));
end




    end
end
