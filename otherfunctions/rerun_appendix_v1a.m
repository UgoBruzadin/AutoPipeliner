clc
clear all

file1 = [];

prefiles = dir('*.set');
fileINPUT = pwd;
cd ..
postfiles = dir('*.set');
postnames = cat(2,postfiles.name);
fileOUTPUT = pwd;
cd (fileINPUT);
%forloop
for j=1:length(prefiles)
    if ~contains(postnames,prefiles(j).name(1:6))
        file1 = cat(1,file1,prefiles(j).name);
    end
end

%it creates an array named *file1* that contains the names of the files
%that are not present in the upper folder yet.