function [EEG,acronym] = pipe_insertheadmodel(EEG,hmlocation)

    EEG = pop_par_select( EEG,'nochannel',{'EEG VREF'});
    %EEG = pop_select( EEG,'nochannel',{'VREF'});
    EEG = pop_par_chanedit(EEG, 'lookup',hmlocation,'load',{hmlocation 'filetype' 'autodetect'});
    EEG = pop_par_chanedit(EEG, 'insert',129,'changefield',{129 'labels' 'Cz'});
    EEG = pop_par_chanedit(EEG, 'setref',{'1:132' 'Cz'});
    % EEG = pop_reref( EEG, [57 100] ,'refloc',struct('labels',{'Cz'},'Y',{[]},'X',{[]},'Z',{[]},'sph_theta',{[]},'sph_phi',{[]},'sph_radius',{[]},'theta',{[]},'radius',{[]},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}),'keepref','on');
    EEG = pop_par_chanedit(EEG, 'changefield',{129 'theta' '0'},'changefield',{129 'radius' '0'},'changefield',{129 'X' '0'},'changefield',{129 'Y' '0'},'changefield',{129 'Z' '8.7919'},'changefield',{129 'sph_theta' '0'},'changefield',{129 'sph_theta' ''},'changefield',{129 'sph_theta' '0'},'changefield',{129 'sph_phi' '0'},'changefield',{129 'sph_radius' '0'});

end

