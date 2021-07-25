function [EEG, acronym] = pipe_epoch(EEG,content) %content must be 1.array of names of epochs, 2. first cut and 3. second cut, both in seconds
    %content = table2array(content);
    %EEG = pop_epoch( EEG, {content(1)},'limits', [content(2) content(3)], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    fprintf('epoching the data \r');
    %if lenght(content) > 2
    % if exist(EEG.event)
    EventName = content(1);
    EventName = EventName{:};
    Epochs = content(2);
    Epochs = Epochs{:};
    
    if isempty(EEG.event)
        EEG.event = EEG.urevent;
    end
    if contains(EEG.event(1).type,EventName)
        EEG = pop_par_epoch( EEG, { EventName }, [Epochs(1) Epochs(2)], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
        acronym = strcat('EP',num2str(EEG.trials));
    else
        try EEG = pop_par_epoch( EEG, { EEG.event(1).type }, [Epochs(1) Epochs(2)], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
            acronym = strcat('EP',num2str(EEG.trials));
        catch acronym = strcat('XP',num2str(EEG.trials));
        end
    end
    
    %EEG = pop_epoch( EEG, { EEG.event(1).type }, [table2array(content(2)) table2array(content(3))], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');

    %EEG = pop_epoch( EEG, { 'DIN' }, [0.400 2.448], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    %EEG = eeg_regepochs(EEG,content,4.094,'limits',[0 4.094]); %this is will give you 2.044 epoch lenghts as matlab lose the 1st point like n-scan
    %acronym = strcat('EP');%make for variable epoc name!
end