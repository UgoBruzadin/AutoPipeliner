function [EEG, acronym] = pipe_fft(EEG,low,high) %works; by ugo 2/3/2020 7:15pm
    if nargin < 2
        if isfield(EEG,'low')
            low = EEG.low;
        else
            low = 2;
        end
    end
    if nargin < 3
        if isfield(EEG,'high')
            high = EEG.high;
        else
            high = 55;
        end
    end
    if low ~= 2
        ffts = [18 20 22 24 26 32 36 40 44 48 52];
    else
        ffts = [2 4 6 8 9 10 11 12 14 16 18 22];
    end
       
    figure; pop_par_spectopo(EEG, 1, [EEG.xmin*10^3  EEG.xmax*10^3], 'EEG' , 'freq', ffts, 'freqrange',[low high], 'electrodes','off');
    saveas(gcf,strcat(EEG.filename(1:end-4),'_FFT.jpg'));
    close all;
    fprintf('saving FFTs')
    acronym = '';
end