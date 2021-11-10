function [EEG, acronym] = pipe_filterlow(EEG,content) %should work
fprintf('filtering the data \r'); 
%store filter somewhere
    %content = cell2mat(content);
    %EEG = pop_par_eegfiltnew(EEG, 'locutoff',cell2mat(content(1)),'plotfreqz', 0);
    %EEG = eeg_checkset( EEG );
    EEG = pop_par_eegfiltnew(EEG, 'hicutoff',cell2mat(content(1)),'plotfreqz', 0);
    acronym = char(strcat('L',mat2str(cell2mat(content(1)))));
    
    maxWindow = 2^floor(log2(EEG.pnts));
    if maxWindow > 2048
        maxWindow = 2048;
    end
    
    figure; pop_par_spectopo(EEG, 1, [EEG.xmin*10^3  EEG.xmax*10^3], 'EEG' , 'freq', [2 4 6 8 9 10 11 12 14 16 18 22], 'freqrange',[2 26],'winsize',maxWindow,'electrodes','off');
    saveas(gcf,strcat(EEG.filename(1:end-4),'_FFT.jpg'));
    
    EEG.high = cell2mat(content(1));
end