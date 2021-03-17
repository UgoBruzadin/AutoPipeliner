clc
clear
FileInput1 = pwd;
FileList1 = dir('*.set');
cd ..
FileInput2 = pwd;
FileList2 = dir('*.set');
List1 = [];
List2 = [];


for StartHereProcessingHere=1:size(FileList1,1)
    File1 = FileList1(StartHereProcessingHere).name(1:10);
    File2 = FileList2(StartHereProcessingHere).name(1:10);    
    IsfileInthePOSTfolder = isequal(File1,File2);
    if IsfileInthePOSTfolder == 0
           break
    end
end

file1 = FileList1(StartHereProcessingHere:end);
%This works with the below code for loading files
%EEG =  pop_loadset(file1(i).name, FileInput1,  'all','all','all','all','auto');
