% Author: Ugo Bruzadin Nunes
% SIUC
% email: ugobruzadin at gmail dot com
% Dec 2019/Jan2020

classdef pop_autopipelinerEZ
    methods(Static)
        
        function folder = getLastFolder(currentDirectory)
            
            folders = dir(currentDirectory);
            % Get a logical vector that tells which is a directory.
            dirFlags = [folders.isdir];
            % Extract only those that are directories.
            subFolders = folders(dirFlags);
            % Print folder names to command window.
                %for k = 1 : length(subFolders)
                  %fprintf('Sub folder #%d = %s\n', k, subFolders(k).name);
                %end
            if size(subFolders,1) > 2
                folder = strcat(subFolders(end).folder,'/',subFolders(end).name,'/');
                folder = pop_autopipelinerEZ.getLastFolder(folder);
            else
                folder = currentDirectory;
            end
        end
        
        function [yerOrNo,folderNameDateold] = alreadyHasFolder(currentDirectory,folderName)
            
            folders = dir(currentDirectory);
            % Get a logical vector that tells which is a directory.
            dirFlags = [folders.isdir];
            % Extract only those that are directories.
            subFolders = folders(dirFlags);
            % Print folder names to command window.
            for k = 1 : length(subFolders)
                if subFolders(k).name(1:length(folderName)) == folderName
                    yerOrNo = 1;
                    folderNameDateold = subFolders(k).name;
                else
                    yerOrNo = 0;
                    folderNameDateold = '';
                end
            end
        end
        
        function batches(batches,batchFolder) %store all batches to be done
            commandCounter = 0;
            %fileFolder = batchFolder;
            WorkingFolder = batchFolder;
            batchCounter = 0;
            for i=1:length(batches)
                cd(WorkingFolder);
                WorkingFolder = pop_autopipelinerEZ.getLastFolder(WorkingFolder);
                cd(WorkingFolder);
                files = dir('*.set');
                %folderCounter = folderCounter + 1;
                %if midway through pipeline, otherwise start new batch
                if contains(WorkingFolder,'batch') %if the batch has already started
                    %make sure that first batch has started
                    hasBatch = strfind(WorkingFolder,'batch_')
                    batchCounter = str2double(WorkingFolder(hasBatch(end)+6))
                    %I AM EDITING THIS TO MAKE SURE BATCH FOLDER GETS right
                    %number.
                    %batchCounter = str2num(WorkingFolder(1:hasBatch(end)+6));
                    %has the folder has been done yet
                    %get the folder name if so
                    %batchFolder = WorkingFolder(1:hasBatch(end)-1);
                    if char(WorkingFolder(hasBatch(end)+8)) > char(66)
                        commandCounter = double(char(WorkingFolder(hasBatch(end)+8))) - 64;
                    else 
                        commandCounter = 0;
                    end
                    %batchName = char(strcat('Batch_',num2str(folderCounter))); %names batch to "Batch"+number of the batch
                    %[batchFolder] = pop_autopipelinerEZ.createBatchFolder(OGfolder,files,batchName); %created batch folder
                else
                    batchName = char(strcat('batch_',num2str(batchCounter))); %names batch to "Batch"+number of the batch
                    [batchFolder] = pop_autopipelinerEZ.createBatchFolder(WorkingFolder,files,batchName); %created batch folder
                
                end
                fprintf('generating batch folders'); %prints this sentence
                %nextbatch = table2array(batches(i));
                [batchFolder, commandCounter] = pop_autopipelinerEZ.pipeIn(batches(i),batchFolder,commandCounter); %start the pipeline
                batchCounter = batchCounter+1;
            end
        end
        
        function [fileFolder, folderCounter] = pipeIn(commands,batchFolder,folderCounter) %store the functions to be rolled in this batch
            if nargin < 3
                folderCounter = 0;
            end
            
            commands = table2array(commands);
            %commands = table2array(commands); %gets the array of commands to be pipelined
            %folderCounter = 0; %start a counter of folders/commands to be run
            
            fileFolder = batchFolder; %begins with the files inside the main batch folder
            for i=folderCounter:length(commands) %for loop, loops the number of commands
                folderCounter = folderCounter + 1;%adds one folder to the counter
                if folderCounter > 1
                    [fileFolder] = pop_autopipelinerEZ.Function(batchFolder,commands(i),fileFolder,folderCounter);
                else
                    [fileFolder] = pop_autopipelinerEZ.Function(batchFolder,commands(i),fileFolder,folderCounter);
                end
                %starts the pipeline
                
            end
        end
        
        function [filePOST] = Function(batchPath,commands,filePath,counter) %magic function, runs the code asked!
            if nargin < 4
                counter = 0;
            end
            if nargin < 3
                filePath = pwd;
                counter = 0;
            end
            
            commands = table2array(commands);
            pop_autopipelinerEZ.clean(); %wipe the memory
            t = datetime('now','TimeZone','local','Format','dMMMy-HH.mm'); %gets the datetime
            fname = strcat(mfilename,'.'); %get the name of this function for future use, adds a dot to it
            
            cd(filePath); %moves to the last path where files were
            %tic; %start a timer
            % --- organizing folders
            folderLetter = char(counter+64); %names the folder initial letter (A, B, etc)!
            folderNameDate = strcat(folderLetter,'-',char(commands(1)),'-',char(t)); %makes folder full name
            folderName = strcat(folderLetter,'-',char(commands(1))); %makes folder partial name
            [yesOrNo, folderNameDateOld] = alreadyHasFolder(currentDirectory,folderName);  %checks if a folder with name already exist
            if ~yesOrNo
                [files, filePRE, filePOST] = pop_autopipelinerEZ.createfolders(filePath,batchPath,folderNameDate,yesOrNo); %creates a folder for the pipeline
            else
                [files, filePRE, filePOST] = pop_autopipelinerEZ.createfolders(filePath,batchPath,folderNameDateOld,yesOrNo); %creates a folder for the pipeline
            end
                cd(filePRE);
            parfor i=1:length(files)
                
                %------ load EEG
                EEG = pop_loadset(files(i).name, filePRE,  'all','all','all','all','auto');
                if counter == 0
                    %------ pop_autopipelinerEZ.fft(files(i),EEG);
                end
                EEG = eeg_checkset(EEG);
                %call the function = can be susbtituted for a script in the future
                try
                %action = str2func(strcat('pipe_',char(commands(1)))); %this call a function inside this function with the name asked for!
                
                if length(commands) > 1
                    [EEG, acronym] = action(EEG, commands(2:end)); %this is where the function runs the asked code!
                else
                    [EEG, acronym] = action(EEG); %this is where the function runs the asked code!
                end
                newname = strcat(files(i).name(1:end-4), [acronym], '.set');
                EEG = pop_saveset(EEG, 'filename', [newname], 'filepath',filePOST);
                
                catch
                    acronym = strcat('ERROR_',char(commands(1)));
                    newname = strcat(files(i).name(1:end-4), [acronym], '.set');
                    EEG = pop_saveset(EEG, 'filename', [newname], 'filepath',strcat(filePOST,'/ERROR/'));
                end
                EEG = pop_delset(EEG,1); %fixed and added 2/3/2020
            end

            %cleaning the folder from binica trash
            pop_autopipelinerEZ.emptyTrash(); %deletes binica's leftover trash
            %sends text to me
            %pop_autopipelinerEZ.txt(strcat('processing of ', folderNameDate,' is over')); %fixed and added 2/3/2020
        %fixed and added 2/3/2020
        end
        
        function Report(filePath) %magic function, runs the code asked!
            batchPath = filePath;
            counter = 1;
            if nargin < 4
                counter = 0;
            end
            if nargin < 3
                filePath = pwd;
                counter = 0;
            end
            files = dir('*.set');
            pop_autopipelinerEZ.clean(); %wipe the memory
            t = datetime('now','TimeZone','local','Format','dMMMy-HH.mm'); %gets the datetime
            fname = strcat(mfilename,'.'); %get the name of this function for future use, adds a dot to it
            cd(filePath); %moves the the last path where files were
            %tic; %start a timer
            for i=1:length(files)
                %load EEG
                EEG = pop_loadset(files(i).name, filePath,  'all','all','all','all','auto');
                EEG = eeg_checkset(EEG);
                %action = str2func(strcat(fname,char(commands(1)))); %this call a function inside this function with the name asked for!
                %[individualReport] = pop_autopipelinerEZ.tempReport(files(i).name,EEG);%changedneedsfixing
                
                %EEG = pop_saveset(EEG, 'filename', [newname], 'filepath',filePOST);
                [individualReport] = pipe_individualreport(files(i).name,EEG);
                writetable(cell2table(individualReport),strcat(files(i).name(1:end-4),'_report.txt')); %saves the table in .mat format
                pop_autopipelinerEZ.fft(files(i),EEG);
                if ~isempty(EEG.icaweights)
                    pop_autopipelinerEZ.componentFigures(files(i),EEG) %fixed and added 2/3/2020
                end
                EEG = pop_delset(EEG,1); %fixed and added 2/3/2020
            end
            %makes report
            pop_autopipelinerEZ.report(strcat('finalReport',t)); %fixed and added 2/3/2020
            pop_autopipelinerEZ.emptyTrash(); %deletes binica's leftover trash
            pop_autopipelinerEZ.txt(strcat('processing of ', folderNameDate,' is over')); %fixed and added 2/3/2020
        end
                
        function emptyTrash()
            trashBin = dir('bin*');
            trashMat = dir('*.mat');
            parfor i=1:length(trashBin)
                delete (trashBin(i).name)
            end
            parfor i=1:length(trashMat)
                delete (trashMat(i).name)
            end
        end %%%works
        
        function clean() %works
            clc;         % clear command window
            clear all;
            evalin('base','clear all');  % clear base workspace as well
            close all;   % close all figures
        end
        
        function [files, filePRE, filePOST] = createfolders(filePath,batchPath,folderName,yesOrNo) %works!!!
            %------ create the folders where the pipeline will run
            %------ filePRE = strcat(basefolder,'\', type, '\pre'); %copies files
            %------ one can I turn it off)
            cd(batchPath) % - goes to batches's folder
            % --- is there already a folder? if not, make new folder
            if ~yesOrNo                
                mkdir (folderName); % creates new folder
            end
            % --- is there already a 'pre' folder? if not, make new pre folder
            [yerOrNo2,folderNameold] = alreadyHasFolder(folderName,'pre');
            if ~yesOrNo2
                mkdir (folderName,  'pre');; % creates new folder
            end
            
            cd(filePath); %goes to last file location
            fdtfiles = dir('*.fdt'); %gets fdt files
            files = dir('*.set'); %gets set files
            %------
            filePRE = strcat(batchPath,'\', folderName, '\pre');
            filePOST = strcat(batchPath,'\',folderName);
            %------
            % compares if there are already files in that folder
            [setList,fdtList] = pop_autopipelinerEZ.comparefiles(filePRE,filePOST);
            
            parfor i=1:length(setList)
                movefile(setList(i).name, filePRE)
            end
            parfor i=1:length(fdtList)
                movefile(fdtList(i).name, filePRE);
            end
        end
        
        function [setList,fdtList] = comparefiles(pre,post)
            % ---- UNDER CONSTRUCTION ----
            cd(pre)
            FileList1set = dir('*.set');
            FileList1fdt = dir('*.fdt');
            cd(post)
            FileList2set = dir('*.set');
            FileList2fdt = dir('*.fdt');
                        
            setList = struct;
            fdtList = struct;
            postnamesSet = cat(2,FileList2set.name);
            postnamesFdt = cat(2,FileList2fdt.name);
            counterSet = 0;
            counterFdt = 0;
            %forloop
            % STOPPED HERE
            for j=1:length(FileList1set)
                if ~contains(postnamesSet,FileList1set(j).name)
                    counterSet = counterSet+1;
                    setList(counterSet).name = FileList1set(j).name;
                end
            end
            for j=1:length(FileList1fdt)
                if ~contains(postnamesFdt,FileList1fdt(j).name)
                    counterFdt = counterFdt+1;
                    fdtList(counterFdt).name = FileList1fdt(j).name;
                end
            end
        end


%This works with the below code for loading files
%EEG =  pop_loadset(file1(i).name, FileInput1,  'all','all','all','all','auto');
        
        function [batchFolder] = createBatchFolder(path,files,folderName) %works!!!
            %------ create the folders where the pipeline will run
            %------ filePRE = strcat(basefolder,'\', type, '\pre'); %copies files
            %------ one can I turn it off)
            
            basefolder = path;
            if path(end-2:end) ~= 'pre'
                mkdir (folderName)
                fdtfiles = dir('*.fdt');
                batchFolder = strcat(basefolder,'\', folderName);
                %if savecopy
                parfor i=1:length(files)
                    copyfile(files(i).name, batchFolder)
                    copyfile(fdtfiles(i).name, batchFolder);
                end
            else
                cd ..
                cd ..
                batchFolder = pwd;
                cd(basefolder);
            end
            %end
        end
        
        function txt(content) %doesnt work anymore 
            number = '6183034686@vtext.com';
            
            %who = {number, email};
            who = {number};
            mail = 'ugoslab@gmail.com'; %Your GMail email address
            setpref('Internet','SMTP_Server','smtp.gmail.com');
            setpref('Internet','E_mail',mail); %sending email = mail
            setpref('Internet','SMTP_Username',mail); %username = mail
            setpref('Internet','SMTP_Password','1cabininthewoods2'); %password
            props = java.lang.System.getProperties;
            props.setProperty('mail.smtp.auth','true');
            props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
            props.setProperty('mail.smtp.socketFactory.port','465');
            
            % Send the email.  Note that the first input is the address you are sending the email to
            sendmail(who,'Automatic Matlab Report',content);
            %fprintf('text successfully sent to %s and %s\n', email, number);
            fprintf('text successfully sent to %s \n', number);
        end
        
        %Functions that do EEG
        
        %making the report table!!!
        
        function [tempTable] = tempReport(filename,EEG)
            [tempTable] = pipe_individualreport(filename,EEG);
        end
                
        function [EEG, acronym] = headmodel(EEG) %untested
            %ADD: autodetect which headmodels data needs
            %ADD: select headmodel file
            EEG = pop_chanedit(EEG, 'load',{'G:\\Matlab_Batch_v6.0a-129Chan-N5_DL\\C-00-InsertHeadModel\\Pre\\HCGSN128Renamed.sfp' 'filetype' 'autodetect'});
            EEG = eeg_checkset( EEG );
            EEG = pop_chanedit(EEG, 'append',131,'changefield',{132 'labels' 'Cz'},'changefield',{132 'theta' '0'},'changefield',{132 'radius' '0'},'changefield',{132 'X' '0'},'changefield',{132 'Y' '0'},'changefield',{132 'sph_theta' '0'},'changefield',{132 'sph_phi' '0'},'changefield',{132 'sph_radius' '0'},'changefield',{132 'Z' '8.7919'});
            EEG = eeg_checkset( EEG );
            EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{''},'urchan',{[]},'datachan',{0}));
            acronym = 'HM';
        end
        
        function [EEG, acronym] = trim(content, EEG) %not started yet
            % trims the data at upper seconds lower seconds
        end
        
        function [EEG, acronym] = cleanline(commands,EEG) %can do 50hz, 60hz, 70, and so on! %should work
            for i=1:length(commands)
                EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan(1,1)] ,'computepower',1,'linefreqs',commands(i),'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',4,'winstep',1);
            end
            acronym = 'CL';
        end
        
        function [EEG, acronym] = interpolate(EEG) %should works
            %if ref is not cz, rereference
            if EEG.chanlocs(1).ref ~= 'Cz'
                EEG = pop_reref( EEG, Cz); %will need to be modified to other headmodels
            end
            EEG = eeg_checkset(EEG);
            originalEEG = EEG; % copy EEG before clean_raw
            EEG = clean_artifacts(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
            EEG.Channels_Removed = setdiff({originalEEG.chanlocs.labels},{EEG.chanlocs.labels}, 'stable');  % Make a
            EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
            %EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}));
            acronym = 'IN';%gotta add the interpolated channels
        end
                        
        function [EEG, acronym] = baseline(commands, EEG) %baseline asks for two numbers %untested
            EEG = pop_rmbase( EEG, [commands(1) commands(2)]);
            acronym = 'BL'; %make for variable baseline later
        end
        
        %figuregenerators!
        
    end
end