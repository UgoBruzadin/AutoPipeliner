function [EEG, acronym] = pipe_icheart(EEG, heart)
if nargin < 2
    heart = 0.8;
else
    heart = heart{:};
end

if isempty(EEG.icaact)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
end
%if isempty(EEG.etc.ic_classification.ICLabel.classifications)
EEG = pop_par_iclabel(EEG, 'default');
%end
IC = size(EEG.icaweights,1);

EEG = pop_par_icflag(EEG, [NaN NaN;NaN NaN;NaN NaN;heart 1;NaN NaN;NaN NaN;NaN NaN]);

%                          'Brain''Muscle''Eye''Heart''Line Noise''Channel Noise''Other' };
%EEG = pop_par_icflag(EEG, [NaN NaN;flag 1;flag 1;flag 1;flag 1;flag 1;NaN NaN]);
mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected

EEG = pop_par_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components

%EEG = pop_par_iclabel(EEG, 'default');
try
acronym = char(strcat('HRT',num2str(size(mybadcomps,1)))); %the acronym to be passed along to be added to the name of the file
catch acronym = 'PcEr';
end
end