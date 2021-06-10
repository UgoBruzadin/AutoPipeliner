function EEG = pipe_epochbycomp(EEG,component,epochs)

    EEG1 = EEG;
    [EEG1] = pop_subcomp(EEG1, component);
    EEG.data(:,:,epochs) = EEG1.data(:,:,epochs);

end