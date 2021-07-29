function [EEG, acronym] = pipe_ica(EEG,IC) %works
% --- if IC is given, get IC and runs a PCA
try
if nargin > 1
    if iscell(IC)
        IC = cell2mat(IC);
    end
    try EEG = pop_par_runica(EEG,'icatype','binica', 'extended', 1, 'pca', IC, 'verbose','off');
    catch EEG = pop_par_runica(EEG,'icatype','binica','extended', 1, 'pca', IC, 'verbose','off');
    end
% --- otherwise, runs an ICA
else
    try EEG = pop_par_runica(EEG,'icatype','binica','extended', 1,'verbose','off');
    catch EEG = pop_par_runica(EEG,'icatype','cudaica','extended', 1,'verbose','off');
    end
    IC = size(EEG.icawinv,1);
%     A = rand(1)*2;
%      if A > 1.6
%         try EEG = pop_runica(EEG,'icatype','binica','extended', 1,'verbose','off');
%         catch EEG = pop_par_runica(EEG,'icatype','cudaica','extended', 1, 'verbose','off');
%         end
%         IC = size(EEG.icawinv,1);
%      else
%          try EEG = pop_par_runica(EEG,'icatype','cudaica','extended', 1, 'verbose','off');
%          catch EEG = pop_par_runica(EEG,'icatype','cudaica','extended', 1, 'verbose','off');
%          end
%          IC = size(EEG.icawinv,1);
%      end
end
    %EEG = eeg_checkset(EEG);
    EEG = pop_iclabel(EEG);
    pop_viewprops4( EEG, 0, [1:size(EEG.icawinv, 2)], {'freqrange', [2 80]}, {}, 2, 'ICLabel' )
    
    acronym = char(strcat('IC',num2str(IC)));
catch
    acronym = char(strcat('ERROR'));
end
