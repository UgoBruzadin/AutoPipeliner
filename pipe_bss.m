
function [EEG, acronym] = pipe_bss(EEG)
    
%window = (EEG.pnts/EEG.srate)*2;
window = (EEG.pnts/EEG.srate)*EEG.trials;

EEG = pop_autobssemg( EEG, [window], [window], 'bsscca', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [10],'fs', EEG.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  floor(EEG.nbchan/2)]});

[EEGOUT,com] = pop_autobssemg( EEGIN, [window], [windowshift], 'bsscca', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [10],'fs', EEGIN.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  floor(EEGIN.nbchan/2)]});

acronym = 'BSS';

end