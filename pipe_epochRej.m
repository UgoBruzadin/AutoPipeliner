function [EEG, acronym] = pipe_epochrej(EEG,content) %content must be 1.array of names of epochs, 2. first cut and 3. second cut, both in seconds
    %EEG = pop_epoch( EEG, {content(1)},'limits', [content(2) content(3)], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    fprintf('rejecting improbable epochs');
    if length(EEG.trials) > 1
        EEG = pop_par_jointprob(EEG,1,[1:129] , table2array(content(1)) , table2array(content(2)) , 1 , 1 , 0 , []);
    end
    close all
    
    %EEG = pop_epoch( EEG, { 'DIN' }, [0.400 2.448], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    acronym = 'RJ';%make for variable epoc name!
end