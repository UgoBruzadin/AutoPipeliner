clc
clear

% define in and out folder

PATHIN = pwd;
cd ..
PATHOUT = pwd;
mkdir(pwd,'/ERROR/');
PATHERROR = strcat(pwd,'/ERROR/');
cd (PATHIN);

% load all files, separate them into templates & non-templates.
%since we can't load " non-templates" if statement from line 23 does it

allsets = dir('*.set'); %contains all sets from the folder
templates = dir('000*.set'); % contains all templates from the folder
[ALLEEG, EEG] = pop_loadset('filename',{templates.name}); %loads all templates
tALLEEG = ALLEEG; %copies the templates to another variable
clear ALLEEG; %eliminates the templates from ALLEEG

numOfRejectionsPerTemplate = 2;
threshold = 0.90;

%Set the Minimum Variance Explained by Component needed for artifact threshold analysis
Minimum_Variance_To_Remove_Comp = 101; %If this is set to 101 it will allow all componet to be analyzed for threshold

%Set the maximum probability of brain allowed in removed component
Brain_Percent_Threshold = 101;  %If this is set to 101 it will allow all componet to be analyzed for threshold

%Set the minimum probability of each artifact needed to remove component
Muscle_Percent_Threshold = 0;
Eye_Percent_Threshold = 0;
Heart_Percent_Threshold = 0;
Line_Noise_Percent_Threshold = 0;
Channel_Noise_Percent_Threshold = 0;
Other_Percent_Threshold = 101;


%files = struct.empty(0,5);
eeglab;  %loads eeglab

parfor i=1:size(allsets,1) %condition A: given all .set files from the folder
    if ~startsWith('000_',allsets(i).name(1:4)) %if and only if they are not templates
        cd (PATHIN)
        EEG = pop_loadset('filename',{allsets(i).name}); %loads non-template number i
        
        %  creates empty arrays to store correlations
        %  -- stores all correlations in big array
        EEG.mycorrelations = zeros(length(tALLEEG),size(EEG.icawinv,2));
        % -- stores all bad components by number and position
        EEG.mybadcomps = zeros(length(tALLEEG),size(EEG.icawinv,2)); %store components above threshold
        % -- stores all bad components' correlations by number and position
        EEG.mybadcompscorr = zeros(length(tALLEEG),size(EEG.icawinv,2)); % store how much the component above passes correlation
        % -- stores all highest components number, specified by number numOfRejectionsPerTemplate and position
        EEG.compstoberejected = [];
        % -- stores all unique components to be rejected, above threshold and number per template
        EEG.uniquecompstobereject = [];
        try
            for k=1:length(tALLEEG) % loops for all k templates
                IC = str2num(tALLEEG(k).filename(11:12)); % stores the template's component number
                for j=1:size(EEG.icaweights,1) %loops all j components
                    %if size(tALLEEG(k).icawinv(:,IC)) ~= EEG.icawinv(:,j)
                    EEG.mycorrelations(k,j) = abs(corr(tALLEEG(k).icawinv(:,IC),EEG.icawinv(:,j))); %runs the correlation
                    % for example: corr(EEG(6).icawinv(:,1),tALLEEG(24).icawinv(:,1)) %this works
                    
                    if EEG.mycorrelations(k,j) >= threshold
                        EEG.mybadcomps(k,j) = j;
                        EEG.mybadcompscorr(k,j) = EEG.mycorrelations(k,j);
                    end
                end
                
                %gets how many components were rejected
                numberOfRejected = nnz(EEG.mybadcomps(k,:));
                
                if numberOfRejected >= 1 % if there 1 or more comps to be rejected
                    % -- sorting the components according to the highest correlations
                    % -- creating variables of the components and correlations
                    SortCorr = EEG.mybadcompscorr(k,:);
                    SortComp = EEG.mybadcomps(k,:);
                    % -- removes the zeros from the arrays
                    SortCorr = transpose(nonzeros(SortCorr));
                    SortComp = transpose(nonzeros(SortComp));
                    
                    % -- sorts the correlations in descending order
                    [SortCorrs, CorOrder] = sort(SortCorr, 'descend');
                    
                    % -- resorts the components according to the new sorting of the correlations
                    % --  makes a new variable called newSortedComps containing
                    % -- the components in a sorted fashion
                    newSortedComps = [];
                    for n=1:length(SortComp)
                        newSortedComps(n) = SortComp(CorOrder(n));
                    end
                    
                    % if there are more than X rejected components, rejects
                    % only X
                    if numberOfRejected >= numOfRejectionsPerTemplate
                        for m = 1:numOfRejectionsPerTemplate
                            EEG.compstoberejected(end+1) = newSortedComps(m);
                        end
                        % if there are only 1 component to be rejected, rejects
                        % that one
                    elseif numberOfRejected ~= 0 && numberOfRejected < numOfRejectionsPerTemplate
                        for m = 1:numberOfRejected
                            EEG.compstoberejected(end+1) = newSortedComps(m);
                        end
                        EEG.compstoberejected(end+1) = newSortedComps(1);
                    end
                end
            end
            
            % IClabeler to check probility of Components Idenitfied as Bad -
            if nnz(EEG.compstoberejected) > 0
                EEG.CompThatFailedArtifactThreshold = cell(size(unique(EEG.compstoberejected),2));
                EEG.CompThatAccountedForTooMuchBrain = cell(size(unique(EEG.compstoberejected),2));
                EEG.CompThatFailedMinimumVarianceExplained = cell(size(unique(EEG.compstoberejected),2));
                EEG = iclabel(EEG, 'default');
                
                % Percent of variance accounted for by Component
                temporaryList = {};
                finalList = [];
                StoreForCompDisplay = EEG.icaact;
                EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
                chanorcomp = size(EEG.icaweights,1);
                for j=1:chanorcomp
                    icaacttmp = EEG.icaact(j, :, :);
                    maxsamp = 1e6;
                    n_samp = min(maxsamp, EEG.pnts*EEG.trials);
                    try
                        samp_ind = randperm(EEG.pnts*EEG.trials, n_samp);
                    catch
                        samp_ind = randperm(EEG.pnts*EEG.trials);
                        samp_ind = samp_ind(1:n_samp);
                    end
                    if ~isempty(EEG.icachansind)
                        icachansind = EEG.icachansind;
                    else
                        icachansind = 1:EEG.nbchan;
                    end
                    datavar = mean(var(EEG.data(icachansind, samp_ind), [], 2));
                    projvar = mean(var(EEG.data(icachansind, samp_ind) - ...
                        EEG.icawinv(:, j) * icaacttmp(1, samp_ind), [], 2));
                    pvafval = 100 *(1 - projvar/ datavar);
                    pvaf = num2str(pvafval, '%3.1f');
                    temporaryList = {pvaf};
                    finalList = cat(1, finalList, temporaryList);
                end
                
                %Threshold check
                brainIdxPrecent  = EEG.etc.ic_classification.ICLabel.classifications*100;
                TotalCompSize = size(unique(EEG.compstoberejected),2);
                UniqueComps = unique(EEG.compstoberejected);
                for BadCompReview=1:TotalCompSize
                    CurrentCompIndex = UniqueComps(1,BadCompReview);
                    CurrentCompProbility = brainIdxPrecent(CurrentCompIndex,:);
                    CompRejectionList = unique(EEG.compstoberejected);
                    if   Minimum_Variance_To_Remove_Comp >= str2double(finalList(CurrentCompIndex,1))
                        if CurrentCompProbility(1,1) < Brain_Percent_Threshold ...
                                if CurrentCompProbility(1,2) >= Muscle_Percent_Threshold ...
                                    || CurrentCompProbility(1,3) >= Eye_Percent_Threshold ...
                                    || CurrentCompProbility(1,4) >= Heart_Percent_Threshold ...
                                    || CurrentCompProbility(1,5) >= Line_Noise_Percent_Threshold ...
                                    || CurrentCompProbility(1,6) >= Channel_Noise_Percent_Threshold ...
                                    || CurrentCompProbility(1,7) >= Other_Percent_Threshold
                                else
                                    EEG.CompThatFailedArtifactThreshold{1}(end+1) = CurrentCompIndex(1,1);
                                    CompRejectionList=CompRejectionList(CompRejectionList~=CurrentCompIndex);
                                end
                        else
                            EEG.CompThatAccountedForTooMuchBrain{1}(end+1) = CurrentCompIndex(1,1);
                            CompRejectionList=CompRejectionList(CompRejectionList~=CurrentCompIndex);
                        end
                    else
                        EEG.CompThatFailedMinimumVarianceExplained{1}(end+1) = CurrentCompIndex(1,1);
                        CompRejectionList=CompRejectionList(CompRejectionList~=CurrentCompIndex);
                    end
                end
            end
            
            
            % Now, we looped all templated, how many unique components were
            % rejected?
            % reject all unique components selected
            %if nnz(EEG.compstoberejected) > 0
            %    EEG.uniquecomptoberejected = unique(EEG.compstoberejected);
            %    EEG = pop_subcomp(EEG, EEG.uniquecomptoberejected, 0);
            %end
            if nnz(EEG.compstoberejected) > 0
                if nnz(CompRejectionList) > 0
                    for CompPrint=1:size(CompRejectionList,2)
                        %EEG = iclabel(EEG, 'default');
                        EEG.icaact = StoreForCompDisplay;
                        pop_prop_extended( EEG, 0, CompRejectionList(1,CompPrint), NaN, {'freqrange' [2 80] }, {}, 1, 'ICLabel')
                        savefig(gcf,[strcat(allsets(i).name(1:end-4), '_CompRemoved_', num2str(CompRejectionList(1,CompPrint))) ,'.fig'])
                        close(gcf)
                    end
                end
            end
            if nnz(EEG.compstoberejected) > 0
                EEG.uniquecomptoberejected = unique(EEG.compstoberejected);
                EEG = pop_subcomp(EEG, CompRejectionList, 0);
                IC2 = size(EEG.icaweights,1)
                EEG = pop_runica(EEG,'pca', IC2,'extended', 1);
            else
                IC2 = size(EEG.icaweights,1)
                IC2 = IC2 - 1;
                EEG = pop_runica(EEG,'pca', IC2,'extended', 1);
            end
            
            %stores the # of ICs left in the data
            
            totalICS = num2str(size(EEG.icaweights,1));
            EEG = pop_saveset(EEG, 'filename', [allsets(i).name(1:end-4), strcat('Pc',totalICS,'CORR.set')], 'filepath',  PATHOUT ); %save set - all artifacts corrected
            EEG = pop_delset(EEG,1);
        catch
            EEG = pop_saveset(EEG, 'filename', [allsets(i).name(1:end-4), strcat('errorCORR.set')], 'filepath',  PATHERROR ); %save set - all artifacts corrected
            EEG = pop_delset(EEG,1);
        end
    end
end

cd (PATHIN);
clc
clear
file1 = dir('bin*');
parfor i=1:length(file1)
    delete (file1(i).name)
end

clc
clear
file1 = dir('*.fig');
for i=1:length(file1)
    open(file1(i).name)
    saveas(gcf,[file1(i).name(1:end-4) '.jpg'])
    close(gcf)
    close(gcf)
    close(gcf)
    close(gcf)
end

clc
clear
file1 = dir('*.fig');
parfor i=1:length(file1)
    delete (file1(i).name)
end

clc
clear
PathCurrent = pwd;
cd ..
PathParent = pwd;
cd(PathCurrent)
file1 = dir('*.jpg');
parfor i=1:length(file1)
    movefile(file1(i).name, PathParent )
end

