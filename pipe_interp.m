function [EEG, acronym] = pipe_interp(EEG,content)

if nargin < 2
    minfreq = 2;
    maxfreq = 55;
    sdv = 3;
end

content = content{:};
minfreq = content(1);
maxfreq = content(2);
sdv = content(3);
    
ChansForInterp = outlierChannelsFrequency(EEG,minfreq,maxfreq,sdv);

EEG = pop_interp(EEG, [ChansForInterp], 'spherical');

acronym = strcat('Ch',num2str(ChansForInterp));

end
