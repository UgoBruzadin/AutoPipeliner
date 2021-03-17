function [EEG, acronym] = pipe_nfilter(EEG, content)

    EEG = pop_par_eegfiltnew(EEG, 'locutoff',cell2mat(content(1)),'hicutoff',cell2mat(content(2)),'revfilt',1,'plotfreqz',1);
    acronym = 'NF60'

end

   
    