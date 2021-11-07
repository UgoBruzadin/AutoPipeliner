
function [EEG, acronym] = pipe_bss(EEG)
    
window = EEG.trials*EEG.pnts/EEG.srate;

[EEG] = pop_autobssemg( EEG, [window], [window], 'bsscca', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [10],'fs', [250],'femg', [15],'estimator',spectrum.welch,'range', [0  49]});

acronym = 'BSS';

end