function [EEG, acronym] = pipe_filter(EEG,content) %should work
fprintf('filtering');    
%store filter somewhere
    %content = cell2mat(content);
    EEG = pop_par_eegfiltnew(EEG, 'locutoff',cell2mat(content(1)),'plotfreqz', 0);
    %EEG = eeg_checkset( EEG );
    EEG = pop_par_eegfiltnew(EEG, 'hicutoff',cell2mat(content(2)),'plotfreqz', 0);
    acronym = char(strcat('H',mat2str(cell2mat(content(1))),'L',mat2str(cell2mat(content(2)))));
end