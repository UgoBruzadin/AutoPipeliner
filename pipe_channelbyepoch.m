function [EEG,acronym] = pipe_channelbyepoch(EEG,commands)
%interpolation of channel data in individual epochs

%get all epochs and all channels
%find surrounding channels
%find bizarre problems
%make sure they aren't brain
%interpolate

EEGIntrip = EEG;
EEGIntrip = pop_par_interp(EEGIntrip, Channel, 'spherical');
EEG.data(Channel,:,Epoch) = EEGIntrip.data(Channel,:,Epoch);

acronym = 'ChEpIn';

end