function [EEG, acronym] = pipe_icrej(EEG, rej)

if nargin < 2
    rej = 0.9;
else
    if iscell(rej)
        rej = rej{:};
    end
end

if isempty(EEG.icaact)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
end
% --- runs IClabel
if ~isfield(EEG,'etc.ic_classification.ICLabel.classifications')
    EEG = pop_par_iclabel(EEG, 'default');
end

% -- flags the components
EEG = pop_par_icflag(EEG, [NaN NaN; rej 1;rej 1;rej 1;rej 1;rej 1;NaN NaN]);

%print_RejComponents(EEG)
%                    'Brain''Muscle''Eye''Heart''Line Noise''Channel Noise''Other' };
%EEG = pop_par_icflag(EEG, [NaN NaN;flag 1;flag 1;flag 1;flag 1;flag 1;NaN NaN]);
mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected

if mybadcomps
% --- prints rejected components at pwd
print_RejComponents(EEG)

% --- rejects the components
EEG = pop_par_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
end

% --- saves the acronym for later
acronym = char(strcat('CJ',num2str(size(mybadcomps,1)))); %the acronym to be passed along to be added to the name of the file

end