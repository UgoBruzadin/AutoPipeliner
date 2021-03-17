clc
clear

fileMatrix = dir('*.dat');

CurrentTable = {};
FinalTable = {};

for i = 1:length(fileMatrix) %runs this loop for as many .dat filels in the current folder
    CurrentTable = readtable(fileMatrix(i).name); % reads the table and adds it to the variable CurrentTable
    FinalTable = cat(1,FinalTable,CurrentTable); % cat adds (concat) the table to the FinalTable
end

save('FinalTable.mat','FinalTable'); %saves it in .mat format
%xlswrite('FinalTable.csv',FinalTable)