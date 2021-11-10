function [EEG, acronym] = pipe_epochrej(EEG,content) %content must be 1.array of names of epochs, 2. first cut and 3. second cut, both in seconds
    %EEG = pop_epoch( EEG, {content(1)},'limits', [content(2) content(3)], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    
    %varargin 'prob',
    content2 = [];
    if size(content,2) > 2
        for i=1:size(content,2)
            content2 = [content2,cell2mat(content(i))];
        end
    else
        content2 = cell2mat(content(1));
        content2 = [content2,content2];
    end
    fprintf('rejecting improbable epochs');

    nbtrials = 1;
    if EEG.trials > 1
        nbtrials = EEG.trials;
        EEG = pop_par_jointprob(EEG,1,[1:EEG.nbchan], content2(1), content2(2), 1 , 1 , 0 , []);
        newnbtrials = EEG.trials;
    end
    
    nbtrialsdiff = nbtrials - newnbtrials;
    
    %EEG = pop_epoch( EEG, { 'DIN' }, [0.400 2.448], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
    acronym = strcat('EJ',num2str(nbtrialsdiff));%make for variable epoc name!
end