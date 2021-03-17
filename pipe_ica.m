function [EEG, acronym] = pipe_ica(EEG,IC) %works
if nargin > 1
    if iscell(IC)
        IC = cell2mat(IC);
    end
    try EEG = pop_par_runica(EEG,'extended', 1, 'pca', IC, 'verbose','off');
    catch EEG = pop_par_runica(EEG,'extended', 1, 'pca', IC, 'verbose','off');
    end
elseif nargin > 0 
    %EEG = IC; %THIS IS A STUPID FIX< REARRENGE THE EEG!
    try EEG = pop_par_runica(EEG,'extended', 1, 'verbose','off');
    catch EEG = pop_par_runica(EEG,'extended', 1, 'verbose','off');
    end
end
    %EEG = eeg_checkset(EEG);
    EEG = pop_par_iclabel(EEG,'default');
    acronym = char(strcat('IC',num2str(IC)));
end
