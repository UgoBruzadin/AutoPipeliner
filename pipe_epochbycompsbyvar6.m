function [EEG] = pipe_channelbyepochbycompsbyvar6(EEG,components)
    
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
%[EEG1] = pop_subcomp(EEG1, components);
%THIS STILL NEEDS WORK
%NEEDS TO REMOVE ONLY COMPONENTS THAT MET THRESHOLD!!!
FinalFlags(size(components,1),EEG.trials) = zeros();

for i=1:length(components)

    % --- identify the bad trials
    
    % --- collects the V variance for each trial of the component
    V = var(EEG.icaact(components(i),:,:));
    V = reshape(V,1,size(V,3));
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
    
    % --- passes the flagged trials to upper variable
    FinalFlags(i,:) = TotalFlags;
end

TrialsforRj = find(sum(FinalFlags));
if TrialsforRj
    
for j=1:length(TrialsforRj)
    % --- find components rejected for every trial
    Flags = find(FinalFlags(:,TrialsforRj(j)))
    % --- reject the components
    EEG1 = EEG;
    EEG1 = pop_subcomp(EEG1,components(Flags));
    % --- basically interpolates epochs from component removals
    % --- if there are any trial flagged, imputes those trials!
    % --- substitutes the specified epochs from the copy
    
    if Flags
        fprintf(strcat(' Rejected trials _', strcat(num2str(Flags)), ' from component _', strcat(num2str(components(i)))), '/r');
        EEG.data(:,:,j) = EEG1.data(:,:,j); 
    else
        fprintf(strcat('No components rejected /r'));
    end



end
end
if Flags %NEEDS FIXING
    EEG = pop_saveset(EEG);
else
    fprintf(strcat('No changes occurred /r'));
end
end
