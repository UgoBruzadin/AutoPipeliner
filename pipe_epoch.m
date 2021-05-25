function [EEG, acronym] = pipe_epoch(EEG,content) %content must be 1.array of names of epochs, 2. first cut and 3. second cut, both in seconds
    %content = table2array(content);
    %EEG = pop_epoch( EEG, {content(1)},'limits', [content(2) content(3)], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    fprintf('epoching the data \r');
    %if lenght(content) > 2
    try EEG = pop_par_epoch( EEG, { content(1) }, [table2array(content(2)) table2array(content(3))], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    catch EEG = pop_par_epoch( EEG, { EEG.event(1).type }, [table2array(content(2)) table2array(content(3))], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    end
    %EEG = pop_epoch( EEG, { EEG.event(1).type }, [table2array(content(2)) table2array(content(3))], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    
    %EEG = pop_epoch( EEG, { 'DIN' }, [0.400 2.448], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    %EEG = eeg_regepochs(EEG,content,4.094,'limits',[0 4.094]); %this is will give you 2.044 epoch lenghts as matlab lose the 1st point like n-scan
    acronym = strcat('EP');%make for variable epoc name!
end