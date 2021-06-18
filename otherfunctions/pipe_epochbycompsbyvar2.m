function [EEG,EEG1] = pipe_epochbycompsbyvar2(EEG,components)
    
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
    V = var(EEG1.icaact(components(i),:,:));
    % --- gets the S sum of the variance (i.e. total variance)
    S = sum(V);
    % --- calculates C contributing variance for each trial
    C = (S - V)/S;
    % --- reshapes it in an array of lenght C
    C = reshape(C,1,length(C));
    % --- calculates the Z score for that array
    Z = zscore(C);
    % --- makes an array bols of the trials which fair above absolute 3 SDVs
    Flag = abs(Z) > 3;
    % --- finds the trial numbers flagged above
    Flags = find(Flag);
    
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
