clc
clear 
file1 = dir('*.set');
%You Need this to move up one folder level to save /Start
fileINPUT = pwd;
cd ..
fileOUTPUT2 = pwd;
%You Need this to move up one folder level to save /End

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

for i=1:length(file1)    
   EEG = pop_loadset(file1(i).name, fileINPUT,  'all','all','all','all','auto');
   EEG = pop_select( EEG,'nochannel',[38]); 
   for a=1:EEG.nbchan
        EEG.chanlocs(1,a).labels = strcat(EEG.chanlocs(1,a).labels,32,'N',num2str(a));
   end
   EEG = pop_saveset( EEG, [file1(i).name(1:end-4),'_Chan100.set'],fileOUTPUT2);

   
end
