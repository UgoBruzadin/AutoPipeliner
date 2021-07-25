% Author: Ugo Bruzadin Nunes
% SIUC
% email: ugobruzadin at gmail dot com
% Dec 2019/Jan2020

classdef autopipeliner_v2c
    methods(Static)
        
        %autopipeliner_v2c = dbstack;
        %autopipeliner_v2c = st.name;

        function [batchFolder, OGFolder] = batches(Batches,batchFolder,batchCounter,files) %store all batches to be done
            if nargin < 4
                % --- move to OG folder
                cd(batchFolder);
                % --- gets files in OG folder
                files = dir('*.set');
            
            end
            if nargin < 3
                batchCounter = 1;
            end
            % --- gets current folder
            OGFolder = batchFolder;
            % --- counter of how many bathes are being run
            %batchCounter = 1;
            %batches = batches{:};
            % --- for loop for each batch to be run
            for i=1:length(Batches)
                %cd(OGFolder);
                %files = dir('*.set');
                % --- names batch to "Batch"+number of the batch
                batchName = char(strcat('batch_',num2str(batchCounter))); 
                % --- creates batch folder (moves folders)
                [batchFolder] = autopipeliner_v2c.createBatchFolder(OGFolder,files,batchName); 
                %cd(OGFolder)
                % --- starts pipeline
                [batchFolder] = autopipeliner_v2c.pipeline(Batches(i),batchFolder); %start the pipeline
                % --- adds +1 to batch counter
                batchCounter = batchCounter+1; 
            end
        end
        
        
        function [batchFolder] = createBatchFolder(path,files,folderName) %works!!!
            %------ create the folders where the pipeline will run
            %------ filePRE = strcat(basefolder,'\', type, '\pre'); %copies files
            %------ one can I turn it off)
            
            basefolder = path;
            cd(path)
            if ~isfolder(strcat(pwd,foldername))
                mkdir (folderName)
            end
            % --- this huge 'if' creates a list of the files selected
            % -- I wish it was smaller but this does the trick.
            
            if ~isfolder(strcat(pwd,foldername,'/Pre/'))
                
            if ~isstruct(files) % if files aren't a directory
                allfiles = strcat(files{1:end}); % gets the files in one word
                endings = strfind(allfiles,'.set'); % finds the '.sets' positions
                filelist = strings(1,[length(endings)]); %creates an empty array of strings length 
                setfiles = dir('');
                fdtfiles = dir('');
                for j=1:length(endings)
                    if j == 1
                        filelist(j) = allfiles(1:endings(j)-1);
                        setfiles = dir(strcat(filelist(1),'.set'));
                        fdtfiles = dir(strcat(filelist(1),'.fdt'));
                    else
                        filelist(j) = allfiles(endings(j-1)+4:endings(j)-1);
                        setfiles(j) = dir(strcat(filelist(j),'.set'));
                        fdtfiles(j) = dir(strcat(filelist(j),'.fdt'));
                    end
                end
            else
                setfiles = files;
                fdtfiles = dir('*.fdt');
            end
            
            batchFolder = strcat(basefolder,'\', folderName);
            
            % --- add: compare files
            parfor i=1:length(setfiles)
                copyfile(setfiles(i).name, batchFolder)
                copyfile(fdtfiles(i).name, batchFolder);
            end
            end
        end
        
        function [filesFolder] = pipeline(Batch,batchFolder) %store the functions to be rolled in this batch
            % --- print
            fprintf('starting pipeline \r');
            % --- collects list of scripts to be performed in an array
            Scripts = Batch{:};
            % --- counter of scripts
            % --- need to add a function to identify num of scripts already run
            scriptCounter = 1; %start a counter of folders/commands to be run
            % --- goes to original folder
            % add: if counter = 0, fileFolders=ogfolder, end
            filesFolder = batchFolder; %begins with the files inside the main batch folder
            
            % --- for loop run for each script
            for i=scriptCounter:length(Scripts) %for loop, loops the number of commands
                
                % --- run Function for each script in a batch
                fprintf('running Function');
                [filesFolder] = autopipeliner_v2c.Function(batchFolder,Scripts(i),filesFolder,scriptCounter);
                scriptCounter = scriptCounter + 1;%adds one folder to the counter
            end
        end
        
        function [filePOST] = Function(batchFolder,Scripts,filesFolder,counter) %magic function, runs the code asked!
            if nargin < 4
                counter = 0;
            end
            if nargin < 3
                filesFolder = pwd;
                counter = 0;
            end
            % --- collects script instructions in an array
            Functions = Scripts{:};
            % --- gets date and time
            t = datetime('now','TimeZone','local','Format','dMMMy-HH.mm'); %gets the datetime
            % --- makes a name for the function
            fname = strcat(mfilename,'.'); %get the name of this function for future use, adds a dot to it
            % --- moves to the last path where files were
            cd(filesFolder); 
            % --- starts a timer; to be added to approximate time to finish
            %tic; 
            % --- creates folder name
            folderLetter = char(counter+64); %names the folder initial letter (A, B, etc)!
            folderNameDate = strcat(folderLetter,'-',char(Functions(1)),'-',char(t)); %makes folder full name
            folderName = strcat(folderLetter,'-',char(Functions(1))); %makes folder partial name
            
            [files, filePRE, filePOST] = autopipeliner_v2c.createfolders(batchFolder,filesFolder,folderNameDate,counter); %creates a folder for the pipeline
            % --- moves down to scripts new directory
            cd(filePOST);
            % --- gest the scripts that are not the name of the function
            Functions2 = Functions(2:end);
            % -- loops all files and run the function fo each one.
            parfor i=1:length(files)
                % --- load EEG
                EEG = pop_par_loadset(files(i).name, filePRE,  'all','all','all','all','auto');
                % --- call the function = can be susbtituted for a script in the future
                % -- functions are always named "pipe_" and contain the
                % -- name and instructions to be performed
                %try
                    % --- action is creates a function out of string in
                    % -- script(1) and runs it the script it refers to
                    action = str2func(strcat('pipe_',char(Functions(1)))); %this call a function inside this function with the name asked for!
                    if length(Functions) > 1
                        %;
                        [EEG, acronym] = action(EEG, Functions2); %this is where the function runs the asked code!
                    else
                        [EEG, acronym] = action(EEG); %this is where the function runs the asked code!
                    end
                    % --- makes a new name for the file, adding the acronym
                    % -- to the name
                    
                    newname = strcat(files(i).name(1:end-4), [acronym], '.set');
                    % --- saves file with new name on script's folder
                    EEG = pop_par_saveset(EEG, 'filename', [newname], 'filepath', filePOST);

                EEG = pop_delset(EEG,1); %fixed and added 2/3/2020
            end
        end
        
%         function [filePOST] = parFunction(batchFolder,scripts,filesFolder,counter) %magic function, runs the code asked!
%             if nargin < 4
%                 counter = 0;
%             end
%             if nargin < 3
%                 filesFolder = pwd;
%                 counter = 0;
%             end
%             % --- collects script instructions in an array
%             scripts = scripts{:};
%             % --- gets date and time
%             t = datetime('now','TimeZone','local','Format','dMMMy-HH.mm'); %gets the datetime
%             % --- makes a name for the function
%             fname = strcat(mfilename,'.'); %get the name of this function for future use, adds a dot to it
%             % --- moves to the last path where files were
%             cd(filesFolder); 
%             % --- starts a timer; to be added to approximate time to finish
%             %tic; 
%             % --- creates folder name
%             folderLetter = char(counter+64); %names the folder initial letter (A, B, etc)!
%             folderNameDate = strcat(folderLetter,'-',char(scripts(1)),'-',char(t)); %makes folder full name
%             folderName = strcat(folderLetter,'-',char(scripts(1))); %makes folder partial name
%             [files, filePRE, filePOST] = autopipeliner_v2c.createfolders(batchFolder,filesFolder,folderNameDate,counter); %creates a folder for the pipeline
%             % --- moves down to scripts new directory
%             cd(filePOST);
%             parfor i=1:length(files)
%                 % --- load EEG
%                 EEG = pop_par_loadset(files(i).name, filePRE,  'all','all','all','all','auto');
%                 scripts = scripts;
%                 % --- call the function = can be susbtituted for a script in the future
%                 % -- functions are always named "pipe_" and contain the
%                 % -- name and instructions to be performed
%                 %try
%                     % --- action is creates a function out of string in
%                     % -- script(1) and runs it the script it refers to
%                     action = str2func(strcat('pipe_',char(scripts(1)))); %this call a function inside this function with the name asked for!
%                     if length(scripts) > 1
%                         scripts = scripts(2:end);
%                         [EEG, acronym] = action(EEG, scripts); %this is where the function runs the asked code!
%                     else
%                         [EEG, acronym] = action(EEG); %this is where the function runs the asked code!
%                     end
%                     % --- makes a new name for the file, adding the acronym
%                     % -- to the name
%                     newname = strcat(files(i).name(1:end-4), [acronym], '.set');
%                     % --- saves file with new name on script's folder
%                     EEG = pop_par_saveset(EEG, 'filename', [newname], 'filepath', filePOST);
% 
%                 EEG = pop_delset(EEG,1); %fixed and added 2/3/2020
%             end
%         end
        
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
        
        function [setfiles, filesPRE, filesPOST] = createfolders(batchFolder,previousFolderPath,folderName,counter)
            %------ create the folders where the pipeline will run
            %------ filePRE = strcat(basefolder,'\', type, '\pre'); %copies files
            %------ one can I turn it off)
            cd(batchFolder) % - goes to last path's folder

            % --- add: is there already a folder? if not, make new folder
 
            % --- makes Script directory
            
            mkdir (folderName); % creates new folder
            cd (strcat(pwd, '/',folderName));
            filesPOST = pwd;
            mkdir ('Pre'); % creates new folder
            cd (strcat(pwd, '/Pre'));
            filesPRE = pwd;
            if counter == 0
                cd(batchFolder)
            else
                cd(previousFolderPath)
            end
            fdtfiles = dir('*.fdt'); %gets fdt files
            setfiles = dir('*.set'); %gets set files
            %filesPRE = strcat(filesPOST,'\pre');

            parfor j=1:length(setfiles)
                movefile(setfiles(j).name, filesPRE)
            end
            parfor i=1:length(fdtfiles)
                movefile(fdtfiles(i).name, filesPRE);
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
                        
            prenamesSet = cat(2,FileList1set.name);
            prenamesFdt = cat(2,FileList1fdt.name);

            %forloop
            % STOPPED HERE
            for j=1:length(FileList2set)
                if contains(prenamesSet,FileList2set(j).name(1:16))
                    clear FileList1set(j);
                end
            end
            for j=1:length(FileList2fdt)
                if contains(prenamesFdt,FileList2fdt(j).name(1:16))
                    clear FileList1set(j);
                end
            end
            setList = FileList1set;
            fdtList = FileList1fdt;
        end

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
            setfiles = dir('*.set');
            if size(subFolders,1) > 2
                if size(subFolders,1) > 3
                folder = strcat(subFolders(end).folder,'/',subFolders(end).name,'/');
                %folder = autopipeliner_v2c.getLastFolder(folder);
                end
            else
                folder = currentDirectory;
            end
        end
        
        function [yesOrNo,folderPath,folderName2] = alreadyHasFolder(currentDirectory,folderName)
            folderName2 = '';
            folderPath = currentDirectory;
            folders = dir(currentDirectory);
            % Get a logical vector that tells which is a directory.
            dirFlags = [folders.isdir];
            % Extract only those that are directories.
            subFolders = folders(dirFlags);
            % Print folder names to command window.
            %yesOrNo = bool(0);
            if length(subFolders) < 3
                    yesOrNo = false;
            else
            for k = 3 : length(subFolders)
                if length(subFolders(k).name) >= length(folderName) && strcmp(subFolders(k).name(1:length(folderName)), folderName)
                    yesOrNo = true;
                    folderPath = strcat(subFolders(k).folder,'/',subFolders(k).name);
                    folderName2 = subFolders(k).name;
                    break
                else
                    yesOrNo = false;
                    folderName2 = folderName;
                end
            end
            end
        end
        

%This works with the below code for loading files
%EEG =  pop_loadset(file1(i).name, FileInput1,  'all','all','all','all','auto');
        
        
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
            autopipeliner_v2c.clean(); %wipe the memory
            t = datetime('now','TimeZone','local','Format','dMMMy-HH.mm'); %gets the datetime
            fname = strcat(mfilename,'.'); %get the name of this function for future use, adds a dot to it
            cd(filePath); %moves the the last path where files were
            %tic; %start a timer
            for i=1:length(files)
                %load EEG
                EEG = pop_loadset(files(i).name, filePath,  'all','all','all','all','auto');
                EEG = eeg_checkset(EEG);
                %action = str2func(strcat(fname,char(commands(1)))); %this call a function inside this function with the name asked for!
                %[individualReport] = autopipeliner_v2c.tempReport(files(i).name,EEG);%changedneedsfixing
                
                %EEG = pop_saveset(EEG, 'filename', [newname], 'filepath',filePOST);
                [individualReport] = pipe_individualreport(files(i).name,EEG);
                writetable(cell2table(individualReport),strcat(files(i).name(1:end-4),'_report.txt')); %saves the table in .mat format
                autopipeliner_v2c.fft(files(i),EEG);
                if ~isempty(EEG.icaweights)
                    autopipeliner_v2c.componentFigures(files(i),EEG) %fixed and added 2/3/2020
                end
                EEG = pop_delset(EEG,1); %fixed and added 2/3/2020
            end
            %makes report
            autopipeliner_v2c.report(strcat('finalReport',t)); %fixed and added 2/3/2020
            autopipeliner_v2c.emptyTrash(); %deletes binica's leftover trash
            autopipeliner_v2c.txt(strcat('processing of ', folderNameDate,' is over')); %fixed and added 2/3/2020
        end
    end
end