function EEG = pipe_epochbycomps(EEG,components,epochs)
    
for i=1:length(components)
    EEG1 = EEG;
    [EEG1] = pop_subcomp(EEG1, components(i));
    EEG.data(:,:,epochs) = EEG1.data(:,:,epochs(i));
end

end