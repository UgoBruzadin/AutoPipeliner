function [EEG, acronym] = pipe_ica(EEG,IC) %works
% --- if IC is given, get IC and runs a PCA
if nargin > 1
    if iscell(IC)
        IC = cell2mat(IC);
    end
    try EEG = pop_par_runica(EEG,'extended', 1, 'pca', IC, 'verbose','off');
    catch EEG = pop_par_runica(EEG,'extended', 1, 'pca', IC, 'verbose','off');
    end
% --- otherwise, runs an ICA
elseif nargin > 0 
    %EEG = IC; %THIS IS A STUPID FIX< REARRENGE THE EEG!
    try EEG = pop_par_runica(EEG,'extended', 1, 'verbose','off');
    catch EEG = pop_par_runica(EEG,'extended', 1, 'verbose','off');
    end
    IC = size(EEG.icawinv,1);
end
    %EEG = eeg_checkset(EEG);
    EEG = pop_par_iclabel(EEG,'default');
    acronym = char(strcat('IC',num2str(IC)));
end
