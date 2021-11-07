function [EEG, acronym] = pipe_filterhigh(EEG,content) %should work
fprintf('filtering the data \r'); 
%store filter somewhere
    %content = cell2mat(content);
    EEG = pop_par_eegfiltnew(EEG, 'locutoff',cell2mat(content(1)),'plotfreqz', 0);
    %EEG = eeg_checkset( EEG );
    %EEG = pop_par_eegfiltnew(EEG, 'hicutoff',cell2mat(content(1)),'plotfreqz', 0);
    figure; pop_par_spectopo(EEG, 1, [EEG.xmin*10^3  EEG.xmax*10^3], 'EEG' , 'freq', [18 20 22 24 26 32 36 40 44 48 52], 'freqrange',[16 55], 'electrodes','off');
    saveas(gcf,strcat(EEG.filename(1:end-4),'_FFT.jpg'));
    
    acronym = char(strcat('H',mat2str(cell2mat(content(1)))));
    EEG.low = cell2mat(content(1));
end