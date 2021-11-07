

function filelist = structtolist(files)

allfiles = strcat(files{1:end}); % gets the files in one word
endings = strfind(allfiles,'.set'); % finds the '.sets' positions
filelist = strings(1,[length(endings)]); %creates an empty array of strings length
setfiles = dir('');
for j=1:length(endings)
    if j == 1
        filelist(j) = allfiles(1:endings(j)-1);
        setfiles = dir(strcat(filelist(1),'.set'));
    else
        filelist(j) = allfiles(endings(j-1)+4:endings(j)-1);
        setfiles(j) = dir(strcat(filelist(j),'.set'));
    end
end