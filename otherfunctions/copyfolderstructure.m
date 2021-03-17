
function copyfolderstructure()

clc
clear

if nargin < 1 
    folder = pwd;
end

p = max(strfind(folder,'\'));
foldername = folder(p+1:end);
newfolderdir = strcat(folder, strcat('\CopyOf',foldername));

mkdir (newfolderdir);

FolderList = ReadJustNames(folder);
FullFolderList = ReadFileNames(folder);

for i=1:length(FullFolderList)
    p2 = max(strfind(FullFolderList{i},foldername));
    foldername2 = FullFolderList{i}(p2:end);
    mkdir (strcat(newfolderdir,'\',foldername2))
end


end

function [ FullFolderList ] = ReadJustNames(DataFolder)

DirContents = dir(DataFolder);
FullFolderList = [];

for i=1:numel(DirContents)
    if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
        if(DirContents(i).isdir)
            FullFolderList = cat(1,FullFolderList,{[DirContents(i).name]});
            getlist = ReadJustNames([DataFolder,'\',DirContents(i).name]);
            FullFolderList = cat(1,FullFolderList,getlist);
        end
    end
end

end

function [ FullFolderList ] = ReadFileNames(DataFolder)

DirContents = dir(DataFolder);
FullFolderList = [];

for i=1:numel(DirContents)
    if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
        if(DirContents(i).isdir)
            FullFolderList=cat(1,FullFolderList,{[DataFolder,'\',DirContents(i).name]});
            getlist=ReadFileNames([DataFolder,'\',DirContents(i).name]);
            FullFolderList=cat(1,FullFolderList,getlist);
        end
    end
end

end