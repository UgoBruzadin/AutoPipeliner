clc 
clear
file1 = dir('*.set');
Parent = pwd;
% while size(file1,1) > 0
    cd(Parent);
    file1 = dir('*.set');
    try
        clc
        clearvars -except Parent
        fileINPUT = pwd;
        mkdir Done
        cd ..
        fileOUTPUT2 = pwd;
        cd(fileINPUT)
        file1 = dir('*.set');
        cd(fileOUTPUT2)
        %addpath(genpath('eeglab-eeglab2019'))
        if isunix == 1
        parpool('slurm',20);
        end
        % CorrThershold1 = .4; CorrThershold2 = .5;
        CorrThershold3 = .4;
        mkdir TooFewEpoch
        mkdir TooMuchIntep
        M5_RatioLoopEnd = 1;
        EpochFailPathway = strcat(fileOUTPUT2,'/TooFewEpoch');
        fileOUTPUT20 =strcat(fileOUTPUT2,'/TooMuchIntep');
        fileOUTPUTMove =strcat(fileINPUT,'/Done');
        [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
        ExcelSheetStart = [];
        
        for i=1:length(file1)
            tic
            Method_5_Starting_Ratio = 1.75;
            TriggerTooFewEpoch = 0;
            EEG = pop_loadset(file1(i).name, fileINPUT,  'all','all','all','all','auto');
            %EEG = pop_eegfiltnew(EEG, 'hicutoff',55,'plotfreqz', 0);
            for M5_RatioLoop=1:M5_RatioLoopEnd
                EEG = pop_loadset(file1(i).name, fileINPUT,  'all','all','all','all','auto');
                TotalCount = 0;
               %EEG = pop_eegfiltnew(EEG, 'hicutoff',55,'plotfreqz', 0);              
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %                                START OF CHANNEL CHECK
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %            Grabs the channel location information to find the
                %            local channels
                
                ExcelSheetStart{i,1} = file1(i).name(1:16);
                AllChansLocation = EEG.chanlocs;
                xelec = [ AllChansLocation.X ];
                yelec = [ AllChansLocation.Y ];
                zelec = [ AllChansLocation.Z ];
                DataMarktoCell =1;
                FindUniqueChan = 1;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                                   ExtractEpoch
                Method1_Triggered = 0;
                Method2_Triggered = 0;
                Method3_Triggered = 0;
                Method4_Triggered = 0;
                Method5_Triggered = 0;
                Method6_Triggered = 0;
                %a =
                %mat2cell(repmat(zeros(366,28),1,size(EEG.data,3)),366,repmat(28,1,size(EEG.data,3)));
                EpochbyChannelIndex = mat2cell(repmat(zeros(1,size(EEG.data,1)),1,size(EEG.data,3)),1,repmat(size(EEG.data,1),1,size(EEG.data,3)))';
                %pop_eegplotMG( EEG, 1, 1, 1);
                for Epoch=1:size(EEG.data,3)
                    CurrentEpoch = (EEG.data(:,:,Epoch));
                    for Channel=1:size(CurrentEpoch,1)
                        %CompareChannel
                        RadiusMulitper = 1;
                        localAvgList = zeros(0,0);
                        while size(localAvgList,1) < 5 || size(localAvgList,1) > 6
                            ListOfChanERP = [];
                            localAvgListTrigger = 1;
                            CenterOfChannelClusterX = xelec(1,Channel);
                            CenterOfChannelClusterY = yelec(1,Channel);
                            CenterOfChannelClusterZ = zelec(1,Channel);
                            RadiusOfCluster = (sqrt(sqrt(CenterOfChannelClusterX^2+CenterOfChannelClusterY^2+CenterOfChannelClusterZ^2)))*RadiusMulitper;
                            
                            RadiusOfInterestXRange1 = CenterOfChannelClusterX(1,1) - RadiusOfCluster;
                            RadiusOfInterestXRange2 = CenterOfChannelClusterX(1,1) + RadiusOfCluster;
                            RadiusOfInterestYRange1 = CenterOfChannelClusterY(1,1) - RadiusOfCluster;
                            RadiusOfInterestYRange2 = CenterOfChannelClusterY(1,1) + RadiusOfCluster;
                            RadiusOfInterestZRange1 = CenterOfChannelClusterZ(1,1) - RadiusOfCluster;
                            RadiusOfInterestZRange2 = CenterOfChannelClusterZ(1,1) + RadiusOfCluster;
                            
                            if RadiusOfInterestXRange1 > RadiusOfInterestXRange2
                                XmaxRadius = RadiusOfInterestXRange1;
                                XminRadius = RadiusOfInterestXRange2;
                            else
                                XmaxRadius = RadiusOfInterestXRange2;
                                XminRadius = RadiusOfInterestXRange1;
                            end
                            if RadiusOfInterestYRange1 > RadiusOfInterestYRange2
                                YmaxRadius = RadiusOfInterestYRange1;
                                YminRadius = RadiusOfInterestYRange2;
                            else
                                YmaxRadius = RadiusOfInterestYRange2;
                                YminRadius = RadiusOfInterestYRange1;
                            end
                            if RadiusOfInterestZRange1 > RadiusOfInterestZRange2
                                ZmaxRadius = RadiusOfInterestZRange1;
                                ZminRadius = RadiusOfInterestZRange2;
                            else
                                ZmaxRadius = RadiusOfInterestZRange2;
                                ZminRadius = RadiusOfInterestZRange1;
                            end
                            Extra = .025;
                            ExtraX = .03;
                            for CheckChanList=1:size(xelec,2)
                                if xelec(1,CheckChanList) < XmaxRadius+(XmaxRadius*ExtraX) && xelec(1,CheckChanList) > XminRadius+(XminRadius*ExtraX) && ...
                                        yelec(1,CheckChanList) < YmaxRadius+(YmaxRadius*Extra) && yelec(1,CheckChanList) > YminRadius+(YminRadius*Extra) && ...
                                        zelec(1,CheckChanList) < ZmaxRadius+(ZmaxRadius*Extra) && zelec(1,CheckChanList) > ZminRadius+(ZminRadius*Extra)
                                    
                                    if localAvgListTrigger ==1
                                        localAvgList = (EEG.data(CheckChanList,:,Epoch));
                                        ListOfChanERP = CheckChanList;
                                        localAvgListTrigger =0;
                                    else
                                        CurrentlocalAvgList = (EEG.data(CheckChanList,:,Epoch));
                                        localAvgList = [localAvgList ; CurrentlocalAvgList];
                                        CurrentChannelIndex = CheckChanList;
                                        ListOfChanERP = [ListOfChanERP CurrentChannelIndex];
                                    end
                                end
                            end
                            if size(localAvgList,1) < 5
                                RadiusMulitper=RadiusMulitper+.05;
                            end
                            if size(localAvgList,1) > 6
                                RadiusMulitper=RadiusMulitper-.05;
                            end
                            if size(localAvgList,1) > 5 && size(localAvgList,1) < 8
                                % figure;topoplot( ListOfChanERP, EEG.chanlocs,
                                % 'chaninfo', EEG.chaninfo, 'electrodes','labels',
                                % 'style', 'blank', 'emarkersize1chan', 2);
                                break
                            end
                        end
                        
                        %This section Removes the Current from the average
                        %electrodes and removes them from the average
                        RemoveChannelFromCorrlocalAvgList = localAvgList;
                        RemoveChannelFromCorrlocalAvgList0 =RemoveChannelFromCorrlocalAvgList;
                        for RemoveChannelFromCorr=1:size(RemoveChannelFromCorrlocalAvgList,1)
                            Data1Corr =corrcoef((EEG.data(Channel,:,Epoch)),RemoveChannelFromCorrlocalAvgList(RemoveChannelFromCorr,:));
                            R = EEG.data(Channel,:,Epoch);
                            CMatlabSuckSomeTimes = round(Data1Corr(1,2),2)-1;
                            if Data1Corr(1,2) == 1
                                RemoveChannelFromCorrlocalAvgList(RemoveChannelFromCorr,:) = [];
                                Nothing =1;
                                break
                            elseif CMatlabSuckSomeTimes == 0
                                RemoveChannelFromCorrlocalAvgList(RemoveChannelFromCorr,:) = [];
                                Nothing =1;
                                break
                            end
                        end
                        
                        %This section looks for outlies in the surrounding
                        %electrodes and removes them from the average
                        InterCorrList = zeros(size(RemoveChannelFromCorrlocalAvgList,1),size(RemoveChannelFromCorrlocalAvgList,1));
                        for IsSurroudingDataVaild0=1:size(RemoveChannelFromCorrlocalAvgList,1)
                            CorrelateSurroundTrigger =1;
                            for Data1Compare=1:size(RemoveChannelFromCorrlocalAvgList,1)
                                TempInterCorrList=corrcoef(RemoveChannelFromCorrlocalAvgList(IsSurroudingDataVaild0,:),RemoveChannelFromCorrlocalAvgList(Data1Compare,:));
                                InterCorrList(IsSurroudingDataVaild0,Data1Compare) = TempInterCorrList(1,2);
                            end
                        end
                        InterCorrListMean = mean(InterCorrList,2);
                        [WorseCorr, WorseCorrIndex] = min(InterCorrListMean);
                        RemoveChannelFromCorrlocalAvgList(WorseCorrIndex,:) = [];
                        
                        AvgERPforCORR = mean(RemoveChannelFromCorrlocalAvgList,1);
                        IsChanBadEntireEpoch = corrcoef((EEG.data(Channel,:,Epoch)),AvgERPforCORR);
                        HowManySectiontodividEpoch = 6;
                        CorrSecLoopChunk = floor(EEG.pnts/HowManySectiontodividEpoch);
                        ListofCorrSec = zeros(HowManySectiontodividEpoch,1);
                        for CorrSecLoop =1:HowManySectiontodividEpoch
                            TempCorrValue= corrcoef(EEG.data(Channel,(CorrSecLoopChunk*(CorrSecLoop)-(CorrSecLoopChunk-1)):(CorrSecLoopChunk*(CorrSecLoop)),Epoch), ...
                                AvgERPforCORR(1,(CorrSecLoopChunk*(CorrSecLoop)-(CorrSecLoopChunk-1)):(CorrSecLoopChunk*(CorrSecLoop))));
                            ListofCorrSec(CorrSecLoop,1) = (TempCorrValue(1,2));
                        end
                        IsChanBadEpochSection = min(ListofCorrSec);
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %                                START OF Interpolation
                        %                                Methods
                        % Method 1:
                        IntripTiggered = 0;
                        if IntripTiggered == 0
                            MinMaxAvgChannel = min((AvgERPforCORR(1,:)+1000)) -max((AvgERPforCORR(1,:)+1000));
                            MinMaxLocalChannel = min((EEG.data(Channel,:,Epoch)+1000)) -max((EEG.data(Channel,:,Epoch)+1000));
                            MMACvsMMLC = abs(MinMaxAvgChannel)- abs(MinMaxLocalChannel);
                            mmmmm = abs(MinMaxLocalChannel/MinMaxAvgChannel);
                            if mmmmm > 1.7 %2 %1.33
                                IntripTiggered = 1;
                                Method1_Triggered = Method1_Triggered +1;
                            elseif mmmmm < .2
                                IntripTiggered = 1;
                                Method1_Triggered = Method1_Triggered +1;
                            end
                        end
                        % Method 2:
                        if IntripTiggered == 0
                            if IsChanBadEntireEpoch(1,2) < CorrThershold3 %This just looks at the correlation
                                IntripTiggered = 1;
                                Method2_Triggered = Method2_Triggered +1;
                            end
                        end
                        % Method 3:
                        if IntripTiggered == 0
                            if IsChanBadEpochSection < CorrThershold3 %This just looks at the correlation
                                IntripTiggered = 1;
                                Method3_Triggered = Method3_Triggered +1;
                            end
                        end
%                         % Method 4:
%                         if IntripTiggered == 0
%                             %This just looks at 60ms chunks comparing the Avg ERP
%                             %of local electrodes to the current channel
%                             %Chunk = floor(60/(((abs(EEG.xmin)+abs(EEG.xmax))*1000)/EEG.pnts));
%                             MsPerPnt = ceil((((abs(EEG.xmin)+abs(EEG.xmax))*1000)/EEG.pnts));
%                             MsToAnalysis = (60/MsPerPnt);
%                             MsPerPntEndPnt = EEG.pnts-MsToAnalysis;
%                             %TotalChunks =floor(EEG.pnts/Chunk);
%                             FristChunkRun = 1;
%                             %MsPerPntEndPnt = MsPerPnt
%                             for RunningWindow60 = 1: MsPerPntEndPnt
%                                 RatioData1 = EEG.data(Channel,RunningWindow60:(RunningWindow60+MsToAnalysis-1),Epoch);
%                                 RatioData2 = AvgERPforCORR(1,RunningWindow60:(RunningWindow60+MsToAnalysis-1));
%                                 Ratio = abs((RatioData1)/(RatioData2));
%                                 if Ratio >Method_5_Starting_Ratio %1.4 .22 1.75
%                                     IntripTiggered = 1;
%                                     Method4_Triggered = Method4_Triggered +1;
%                                     (Channel);
%                                     (Epoch);
%                                     ListOfChanERP;
%                                     break
%                                 end
%                             end
%                         end
                        % Method 5:
                        if IntripTiggered == 0 %This scan 60ms chunks to find large difference
                            MsPerPnt = ceil((((abs(EEG.xmin)+abs(EEG.xmax))*1000)/EEG.pnts));
                            MsToAnalysis = (60/MsPerPnt);
                            MsPerPntEndPnt = EEG.pnts-MsToAnalysis;
                            for RunningWindow60 = 1: MsPerPntEndPnt
                                Data1 = EEG.data(Channel,RunningWindow60:(RunningWindow60+MsToAnalysis-1),Epoch);
                                LargeDiffercnce = abs(min(Data1+500)-(max(Data1+500)));
                                if round(LargeDiffercnce) > 60
                                    IntripTiggered = 1;
                                    Method5_Triggered = Method5_Triggered +1;
                                    (Channel);
                                    (Epoch);
                                    ListOfChanERP;
                                    break
                                end
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %                               Start Interpolation if
                        %                               tiggered
                        if IntripTiggered == 1
                            TotalCount = TotalCount+1;
                            EpochbyChannelIndex{Epoch,1}(1,Channel) = Channel;
                            EEGIntrip = EEG;
                            EEGIntrip = pop_interpMG(EEGIntrip, Channel, 'spherical');
                            EEG.data(Channel,:,Epoch) = EEGIntrip.data(Channel,:,Epoch);
                            IntripTiggered = 0;
                        else
                            IntripTiggered = 0;
                        end
                    end
                end
                TotalTriggered = Method1_Triggered+Method2_Triggered+Method3_Triggered+Method4_Triggered+Method5_Triggered;
                PercentData3rd = (TotalTriggered/(EEG.nbchan*EEG.trials))*100;
                PercentData3rda = (TotalCount/(EEG.nbchan*EEG.trials))*100;
                %pop_eegplotMG( EEG, 1, 1, 1);
                
                %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %         %                               Last Attempt to Fix channels
                ChannelCount = 0;
                DoubleCount = 0;
                EEG.FinalPercent = round(PercentData3rd);
                if EEG.FinalPercent > 26
                    Method_5_Starting_Ratio = Method_5_Starting_Ratio + .1;
                else
                    break
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if TriggerTooFewEpoch == 0
                %EEG = pop_reref( EEG, 129);
                %EEG = pop_eegfiltnew(EEG, 'hicutoff',55,'plotfreqz', 0);
                %EEG = pop_runica(EEG,'icatype','runica','pca',12,'extended',1,'interrupt','off');
                %EEG = pop_runica(EEG, 'extended',1,'interupt','on','pca',12);
                
                if EEG.FinalPercent < 26
                    %  EEG = pop_saveset(EEG, 'filename', [file1(i).name(1:end-4),
                    %  '_Incorrect_Numeric.set'], 'filepath',Inc_Num);
                    %file1(i).name%(1:65)
                    EEG = pop_saveset(EEG, 'filename', [file1(i).name(1:end-4),'_',num2str(EEG.FinalPercent),'_FC.set'], 'filepath',fileOUTPUT2);
                    
                    fdtfile = strcat(file1(i).name(1:end-4),'.fdt');
                    cd(fileINPUT)
                    movefile(file1(i).name, fileOUTPUTMove)
                    movefile(fdtfile, fileOUTPUTMove)
                    %fileOUTPUTMove cd(fileOUTPUT2)
                    
                else
                    EEG = pop_saveset(EEG, 'filename', [file1(i).name(1:end-4),'_',num2str(EEG.FinalPercent),'_FCFail.set'], 'filepath',fileOUTPUT20);
                    fdtfile = strcat(file1(i).name(1:end-4),'.fdt');
                    cd(fileINPUT)
                    movefile(file1(i).name, fileOUTPUTMove)
                    movefile(fdtfile, fileOUTPUTMove)
                    %fileOUTPUTMove cd(fileOUTPUT2)
                end
                %   pop_eegplotMG( EEG, 1, 1, 1);
                %close all
                toc
            end
        end
        
        %
        % t = datestr(now, 'mm_dd_yyyy-HHMM'); t = string(t); Report_Name =
        % strcat('Test_', t(1,1), '.xlsx'); xlswrite(Report_Name,ExcelSheetStart);
    catch ME
        cd(fileINPUT)
        failure = {};
        failure{1,1} = string(getReport(ME));
        % xlswrite('Error.xlsx',failure);
        g =cell2table(failure);
        t = datestr(now, 'mm_dd_yyyy-HHMM');
        t = string(t);
        Report_Name = strcat('Error_',t(1,1),'.txt');
        writetable(g,Report_Name,'WriteVariableNames',false);
        % %open file
        %    fid = fopen('logFile','a+'); % write the error to file % first line:
        %    message fprintf(fid,'%s\n',err.message); % following lines: stack for
        %    e=1:length(err.stack)
        %       fprintf(fid,'%sin %s at
        %       %i\n',txt,err.stack(e).name,err.stack(e).line);
        %    end
        %
        %    % close file fclose(fid)
        if isunix == 1
            delete(gcp('nocreate'))
        end
    end
% end
if isunix == 1
    delete(gcp('nocreate'))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%% STOP DO NOT TOUCH ANYTHING BELOW HERE UNLESS YOU KNOW
%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function com = pop_eegplotMG( EEG, icacomp, superpose, reject, topcommand, varargin)

com = '';
if nargin < 1
    help pop_eegplotMG;
    return;
end;
if nargin < 2
    icacomp = 1;
end;
if nargin < 3
    superpose = 0;
end
if nargin < 4
    reject = 1;
end
if icacomp == 0
    if isempty( EEG.icasphere )
        disp('Error: you must run ICA first'); return;
    end
end

if nargin < 3 && EEG.trials > 1
    
    % which set to save -----------------
    uilist       = { { 'style' 'text' 'string' 'Add to previously marked rejections? (checked=yes)'} , ...
        { 'style' 'checkbox' 'string' '' 'value' 1 } , ...
        { 'style' 'text' 'string' 'Reject marked trials? (checked=yes)'} , ...
        { 'style' 'checkbox' 'string' '' 'value' 0 } };
    result = inputgui( { [ 2 0.2] [ 2 0.2]} , uilist, 'pophelp(''pop_eegplotMG'');', ...
        fastif(icacomp==0, 'Manual component rejection -- pop_eegplotMG()', ...
        'Reject epochs by visual inspection -- pop_eegplotMG()'));
    size_result  = size( result );
    if size_result(1) == 0 return; end
    
    if result{1}, superpose=1; end
    if ~result{2}, reject=0; end
    
end

if EEG.trials > 1 && ~isempty(EEG.reject)
    if icacomp == 1 macrorej  = 'EEG.reject.rejmanual';
        macrorejE = 'EEG.reject.rejmanualE';
    else			macrorej  = 'EEG.reject.icarejmanual';
        macrorejE = 'EEG.reject.icarejmanualE';
    end
    if icacomp == 1
        elecrange = [1:EEG.nbchan];
    else elecrange = [1:size(EEG.icaweights,1)];
    end
    colrej = EEG.reject.rejmanualcol;
    rej  = eval(macrorej);
    rejE = eval(macrorejE);
    
    eeg_rejmacro; % script macro for generating command and old rejection arrays
    
else % case of a single trial (continuous data)
    %if icacomp,
    %    	command = ['if isempty(EEG.event) EEG.event =
    %    	[eegplot2event(TMPREJ, -1)];' ...
    %         'else EEG.event = [EEG.event(find(EEG.event(:,1) ~= -1),:);
    %         eegplot2event(TMPREJ, -1, [], [0.8 1 0.8])];' ... 'end;'];
    %else, command = ['if isempty(EEG.event) EEG.event =
    %[eegplot2event(TMPREJ, -1)];' ...
    %         'else EEG.event = [EEG.event(find(EEG.event(:,1) ~= -2),:);
    %         eegplot2event(TMPREJ, -1, [], [0.8 1 0.8])];' ... 'end;'];
    %end if reject
    %   command = ... [  command ...
    %      '[EEG.data EEG.xmax] = eegrej(EEG.data,
    %      EEG.event(find(EEG.event(:,1) < 0),3:end), EEG.xmax-EEG.xmin);'
    %      ... 'EEG.xmax = EEG.xmax+EEG.xmin;' ...
    %   	'EEG.event = EEG.event(find(EEG.event(:,1) >= 0),:);' ...
    %      'EEG.icaact = [];' ... 'EEG = eeg_checkset(EEG);' ];
    eeglab_options; % changed from eeglaboptions 3/30/02 -sm
    if reject == 0, command = [];
    else
        command = ...
            [  '[EEGTMP LASTCOM] = eeg_eegrej(EEG,eegplot2event(TMPREJ, -1));' ...
            'if ~isempty(LASTCOM),' ...
            '  [ALLEEG EEG CURRENTSET tmpcom] = pop_newset(ALLEEG, EEGTMP, CURRENTSET);' ...
            '  if ~isempty(tmpcom),' ...
            '     EEG = eegh(LASTCOM, EEG);' ...
            '     eegh(tmpcom);' ...
            '     eeglab(''redraw'');' ...
            '  end;' ...
            'end;' ...
            'clear EEGTMP tmpcom;' ];
        if nargin < 4
            res = questdlg2( strvcat('Mark stretches of continuous data for rejection', ...
                'by dragging the left mouse button. Click on marked', ...
                'stretches to unmark. When done,press "REJECT" to', ...
                'excise marked stretches (Note: Leaves rejection', ...
                'boundary markers in the event table).'), 'Warning', 'Cancel', 'Continue', 'Continue');
            if strcmpi(res, 'Cancel'), return; end
        end
    end
    eegplotoptions = { 'events', EEG.event };
    if ~isempty(EEG.chanlocs) && icacomp
        eegplotoptions = { eegplotoptions{:}  'eloc_file', EEG.chanlocs };
    end
end

if EEG.nbchan > 100
    disp('pop_eegplotMG() note: Baseline subtraction disabled to speed up display');
    eegplotoptions = { eegplotoptions{:} 'submean' 'off' };
end

if icacomp == 1
    eegplotMG( EEG.data, 'srate', EEG.srate, 'title', 'Scroll channel activities -- eegplot()','limits', [EEG.xmin EEG.xmax]*1000 , 'command', command, eegplotoptions{:}, varargin{:});
else
    tmpdata = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
    eegplotMG( tmpdata, 'srate', EEG.srate, 'title', 'Scroll component activities -- eegplot()', ...
        'limits', [EEG.xmin EEG.xmax]*1000 , 'command', command, eegplotoptions{:}, varargin{:});
end
com = [ com sprintf('pop_eegplotMG( EEG, %d, %d, %d);', icacomp, superpose, reject) ];
return;
end
function [outvar1] = eegplotMG(data, varargin) % p1,p2,p3,p4,p5,p6,p7,p8,p9)

% Defaults (can be re-defined):

DEFAULT_PLOT_COLOR = { [0 0 1], [0.7 0.7 0.7]};         % EEG line color
try, icadefs;
    DEFAULT_FIG_COLOR = BACKCOLOR;
    BUTTON_COLOR = GUIBUTTONCOLOR;
catch
    DEFAULT_FIG_COLOR = [1 1 1];
    BUTTON_COLOR =[0.8 0.8 0.8];
end
DEFAULT_AXIS_COLOR = 'k';         % X-axis, Y-axis Color, text Color
DEFAULT_GRID_SPACING = 1;         % Grid lines every n seconds
DEFAULT_GRID_STYLE = '-';         % Grid line style
YAXIS_NEG = 'off';                % 'off' = positive up
DEFAULT_NOUI_PLOT_COLOR = 'k';    % EEG line color for noui option
%   0 - 1st color in AxesColorOrder
SPACING_EYE = 'on';               % g.spacingI on/off
SPACING_UNITS_STRING = '';        % '\muV' for microvolt optional units for g.spacingI Ex. uV
%MAXEVENTSTRING = 10; DEFAULT_AXES_POSITION = [0.0964286 0.15 0.842
%0.75-(MAXEVENTSTRING-5)/100];
% dimensions of main EEG axes
ORIGINAL_POSITION = [50 50 800 500];
matVers = version;
%matVers = str2double(matVers(1:3));

if nargin < 1
    help eegplot
    return
end

% %%%%%%%%%%%%%%%%%%%%%%%% Setup inputs %%%%%%%%%%%%%%%%%%%%%%%%

if ~ischar(data) % If NOT a 'noui' call or a callback from uicontrols
    
    try
        options = varargin;
        if ~isempty( varargin ),
            for i = 1:2:numel(options)
                g.(options{i}) = options{i+1};
            end
        else g= []; end
    catch
        disp('eegplot() error: calling convention {''key'', value, ... } error'); return;
    end;
    
    % Selection of data range If spectrum plot
    if isfield(g,'freqlimits') || isfield(g,'freqs')
        %        % Check  consistency of freqlimits % Check  consistency of
        %        freqs
        
        % Selecting data and freqs
        [temp, fBeg] = min(abs(g.freqs-g.freqlimits(1)));
        [temp, fEnd] = min(abs(g.freqs-g.freqlimits(2)));
        data = data(:,fBeg:fEnd,:);
        g.freqs     = g.freqs(fBeg:fEnd);
        
        % Updating settings
        if ndims(data) == 2, g.winlength = g.freqs(end) - g.freqs(1); end
        g.srate     = length(g.freqs)/(g.freqs(end)-g.freqs(1));
        g.isfreq    = 1;
    end
    
    % push button: create/remove window ---------------------------------
    defdowncom   = 'eegplot(''defdowncom'',   gcbf);'; % push button: create/remove window
    defmotioncom = 'eegplot(''defmotioncom'', gcbf);'; % motion button: move windows or display current position
    defupcom     = 'eegplot(''defupcom'',     gcbf);';
    defctrldowncom = 'eegplot(''topoplot'',   gcbf);'; % CTRL press and motion -> do nothing by default
    defctrlmotioncom = ''; % CTRL press and motion -> do nothing by default
    defctrlupcom = ''; % CTRL press and up -> do nothing by default
    
    try, g.srate; 		    catch, g.srate		= 256; 	end
    try, g.spacing; 			catch, g.spacing	= 0; 	end
    try, g.eloc_file; 		catch, g.eloc_file	= 0; 	end; % 0 mean numbered
    %try, g.winlength; 		catch, g.winlength	= 5; 	end; % Number of
    %seconds of EEG displayed
    g.winlength	= 1;
    try, g.position; 	    catch, g.position	= ORIGINAL_POSITION; 	end
    try, g.title; 		    catch, g.title		= ['Scroll activity -- eegplot()']; 	end
    try, g.plottitle; 		catch, g.plottitle	= ''; 	end
    try, g.trialstag; 		catch, g.trialstag	= -1; 	end
    try, g.winrej; 			catch, g.winrej		= []; 	end
    try, g.command; 			catch, g.command	= ''; 	end
    try, g.tag; 				catch, g.tag		= 'EEGPLOT'; end
    try, g.xgrid;		    catch, g.xgrid		= 'off'; end
    try, g.ygrid;		    catch, g.ygrid		= 'off'; end
    try, g.color;		    catch, g.color		= 'off'; end
    try, g.submean;			catch, g.submean	= 'off'; end
    try, g.children;			catch, g.children	= 0; end
    try, g.limits;		    catch, g.limits	    = [0 1000*(size(data,2)-1)/g.srate]; end
    try, g.freqs;            catch, g.freqs	    = []; end;  % Ramon
    try, g.freqlimits;	    catch, g.freqlimits	= []; end
    try, g.dispchans; 		catch, g.dispchans  = size(data,1); end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     if size(data,1) > 30
    %         g.dispchans = 30;
    %     else
    g.dispchans = 20; size(data,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %    g.dispchans  = 30;
    try, g.wincolor; 		catch, g.wincolor   = [ 0.7 1 0.9]; end
    try, g.butlabel; 		catch, g.butlabel   = 'Accecpt'; end
    try, g.colmodif; 		catch, g.colmodif   = { g.wincolor }; end
    try, g.scale; 		    catch, g.scale      = 'on'; end
    try, g.events; 		    catch, g.events      = []; end
    try, g.ploteventdur;     catch, g.ploteventdur = 'off'; end
    try, g.data2;            catch, g.data2      = []; end
    try, g.plotdata2;        catch, g.plotdata2 = 'off'; end
    try, g.mocap;		    catch, g.mocap		= 'off'; end; % nima
    try, g.selectcommand;     catch, g.selectcommand     = { defdowncom defmotioncom defupcom }; end
    try, g.ctrlselectcommand; catch, g.ctrlselectcommand = { defctrldowncom defctrlmotioncom defctrlupcom }; end
    try, g.datastd;          catch, g.datastd = []; end; %ozgur
    try, g.normed;            catch, g.normed = 0; end; %ozgur
    try, g.envelope;          catch, g.envelope = 0; end;%ozgur
    try, g.maxeventstring;    catch, g.maxeventstring = 10; end; % JavierLC
    try, g.isfreq;            catch, g.isfreq = 0;    end; % Ramon
    
    if strcmpi(g.ploteventdur, 'on'), g.ploteventdur = 1; else g.ploteventdur = 0; end
    if ndims(data) > 2
        g.trialstag = size(	data, 2);
    end;
    
    gfields = fieldnames(g);
    for index=1:length(gfields)
        switch gfields{index}
            case {'spacing', 'srate' 'eloc_file' 'winlength' 'position' 'title' 'plottitle' ...
                    'trialstag'  'winrej' 'command' 'tag' 'xgrid' 'ygrid' 'color' 'colmodif'...
                    'freqs' 'freqlimits' 'submean' 'children' 'limits' 'dispchans' 'wincolor' ...
                    'maxeventstring' 'ploteventdur' 'butlabel' 'scale' 'events' 'data2' 'plotdata2' 'mocap' 'selectcommand' 'ctrlselectcommand' 'datastd' 'normed' 'envelope' 'isfreq'},;
            otherwise, error(['eegplot: unrecognized option: ''' gfields{index} '''' ]);
        end
    end
    
    % g.data=data; % never used and slows down display dramatically - Ozgur
    % 2010
    
    if length(g.srate) > 1
        disp('Error: srate must be a single number'); return;
    end;
    if length(g.spacing) > 1
        disp('Error: ''spacing'' must be a single number'); return;
    end;
    if length(g.winlength) > 1
        disp('Error: winlength must be a single number'); return;
    end;
    if ischar(g.title) > 1
        disp('Error: title must be is a string'); return;
    end;
    if ischar(g.command) > 1
        disp('Error: command must be is a string'); return;
    end;
    if ischar(g.tag) > 1
        disp('Error: tag must be is a string'); return;
    end;
    if length(g.position) ~= 4
        disp('Error: position must be is a 4 elements array'); return;
    end;
    switch lower(g.xgrid)
        case { 'on', 'off' },;
        otherwise disp('Error: xgrid must be either ''on'' or ''off'''); return;
    end;
    switch lower(g.ygrid)
        case { 'on', 'off' },;
        otherwise disp('Error: ygrid must be either ''on'' or ''off'''); return;
    end;
    switch lower(g.submean)
        case { 'on' 'off' };
        otherwise disp('Error: submean must be either ''on'' or ''off'''); return;
    end;
    switch lower(g.scale)
        case { 'on' 'off' };
        otherwise disp('Error: scale must be either ''on'' or ''off'''); return;
    end;
    
    if ~iscell(g.color)
        switch lower(g.color)
            case 'on', g.color = { 'k', 'm', 'c', 'b', 'g' };
            case 'off', g.color = { [ 0 0 0.4] };
            otherwise
                disp('Error: color must be either ''on'' or ''off'' or a cell array');
                return;
        end;
    end
    if length(g.dispchans) > size(data,1)
        g.dispchans = size(data,1);
    end
    if ~iscell(g.colmodif)
        g.colmodif = { g.colmodif };
    end
    if g.maxeventstring>20 % JavierLC
        disp('Error: maxeventstring must be equal or lesser than 20'); return;
    end
    
    % max event string;  JavierLC ---------------------------------
    MAXEVENTSTRING = g.maxeventstring;
    DEFAULT_AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
    
    % convert color to modify into array of float
    % -------------------------------------------
    for index = 1:length(g.colmodif)
        if iscell(g.colmodif{index})
            tmpcolmodif{index} = g.colmodif{index}{1} ...
                + g.colmodif{index}{2}*10 ...
                + g.colmodif{index}{3}*100;
        else
            tmpcolmodif{index} = g.colmodif{index}(1) ...
                + g.colmodif{index}(2)*10 ...
                + g.colmodif{index}(3)*100;
        end
    end
    g.colmodif = tmpcolmodif;
    
    [g.chans,g.frames, tmpnb] = size(data);
    g.frames = g.frames*tmpnb;
    
    if g.spacing == 0
        maxindex = min(1000, g.frames);
        stds = std(data(:,1:maxindex),[],2);
        g.datastd = stds;
        stds = sort(stds);
        if length(stds) > 2
            stds = mean(stds(2:end-1));
        else
            stds = mean(stds);
        end;
        g.spacing = stds*3;
        if g.spacing > 10
            g.spacing = round(g.spacing);
        end
        if g.spacing  == 0 || isnan(g.spacing)
            g.spacing = 1; % default
        end
    end
    
    % set defaults ------------
    g.incallback = 0;
    g.winstatus = 1;
    g.setelectrode  = 0;
    [g.chans,g.frames,tmpnb] = size(data);
    g.frames = g.frames*tmpnb;
    g.nbdat = 1; % deprecated
    g.time  = 0;
    g.elecoffset = 0;
    if g.spacing < 11
        g.spacing = ((g.spacing)*5);
    else
        g.spacing = ((g.spacing)*2.5);
    end
    % %%%%%%%%%%%%%%%%%%%%%%%% Prepare figure and axes
    % %%%%%%%%%%%%%%%%%%%%%%%%
    
    figh = figure('UserData', g,... % store the settings here
        'Color',DEFAULT_FIG_COLOR, 'name', g.title,...
        'MenuBar','none','tag', g.tag ,'Position',g.position, ...
        'numbertitle', 'off', 'visible', 'off', 'Units', 'Normalized');
    
    pos = get(figh,'position'); % plot relative to current axes
    q = [pos(1) pos(2) 0 0];
    s = [pos(3) pos(4) pos(3) pos(4)]./100;
    clf;
    
    % Plot title if provided
    if ~isempty(g.plottitle)
        h = findobj('tag', 'eegplottitle');
        if ~isempty(h)
            set(h, 'string',g.plottitle);
        else
            h = textsc(g.plottitle, 'title');
            set(h, 'tag', 'eegplottitle');
        end
    end
    
    % Background axis ---------------
    ax0 = axes('tag','backeeg','parent',figh,...
        'Position',DEFAULT_AXES_POSITION,...
        'Box','off','xgrid','off', 'xaxislocation', 'top', 'Units', 'Normalized');
    
    % Drawing axis ---------------
    YLabels = num2str((1:g.chans)');  % Use numbers as default
    YLabels = flipud(char(YLabels,' '));
    ax1 = axes('Position',DEFAULT_AXES_POSITION,...
        'userdata', data, ...% store the data here
        'tag','eegaxis','parent',figh,...%(when in g, slow down display)
        'Box','on','xgrid', g.xgrid,'ygrid', g.ygrid,...
        'gridlinestyle',DEFAULT_GRID_STYLE,...
        'Ylim',[0 (g.chans+1)*g.spacing],...
        'YTick',[0:g.spacing:g.chans*g.spacing],...
        'YTickLabel', YLabels,...
        'TickLength',[.005 .005],...
        'Color','none',...
        'XColor',DEFAULT_AXIS_COLOR,...
        'YColor',DEFAULT_AXIS_COLOR);
    
    if ischar(g.eloc_file) || isstruct(g.eloc_file)  % Read in electrode name
        if isstruct(g.eloc_file) && length(g.eloc_file) > size(data,1)
            g.eloc_file(end) = []; % common reference channel location
        end
        eegplot('setelect', g.eloc_file, ax1);
    end
    
    % %%%%%%%%%%%%%%%%%%%%%%%%% Set up uicontrols %%%%%%%%%%%%%%%%%%%%%%%%%
    
    % positions of buttons
    posbut(1,:) = [ 0.0464    0.0254    0.0385    0.0339 ]; % <<
    posbut(2,:) = [ 0.0924    0.0254    0.0288    0.0339 ]; % <
    posbut(3,:) = [ 0.1924    0.0254    0.0299    0.0339 ]; % >
    posbut(4,:) = [ 0.2297    0.0254    0.0385    0.0339 ]; % >>
    posbut(5,:) = [ 0.1287    0.0203    0.0561    0.0390 ]; % Eposition
    posbut(6,:) = [ 0.4744    0.0236    0.0582    0.0390 ]; % Espacing
    posbut(7,:) = [ 0.2762    0.01    0.0582    0.0390 ]; % elec
    posbut(8,:) = [ 0.3256    0.01    0.0707    0.0390 ]; % g.time
    posbut(9,:) = [ 0.4006    0.01    0.0582    0.0390 ]; % value
    posbut(14,:) = [ 0.2762    0.05    0.0582    0.0390 ]; % elec tag
    posbut(15,:) = [ 0.3256    0.05    0.0707    0.0390 ]; % g.time tag
    posbut(16,:) = [ 0.4006    0.05    0.0582    0.0390 ]; % value tag
    posbut(10,:) = [ 0.5437    0.0458    0.0275    0.0270 ]; % +
    posbut(11,:) = [ 0.5437    0.0134    0.0275    0.0270 ]; % -
    posbut(12,:) = [ 0.6    0.02    0.14    0.05 ]; % cancel
    posbut(13,:) = [-0.15   0.02    0.07    0.05 ]; % cancel
    posbut(17,:) = [-0.06    0.02    0.09    0.05 ]; % events types
    posbut(20,:) = [-0.17   0.15     0.015    0.8 ]; % slider
    posbut(21,:) = [0.738    0.87    0.06      0.048];%normalize
    posbut(22,:) = [0.738    0.93    0.06      0.048];%stack channels(same offset)
    posbut(:,1) = posbut(:,1)+0.2;
    
    % Five move buttons: << < text > >>
    
    u(1) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position', posbut(1,:), ...
        'Tag','Pushbutton1',...
        'string','<<',...
        'Callback',['global in_callback;', ...
        'if isempty(in_callback);in_callback=1;', ...
        '    try eegplot(''drawp'',1);', ...
        '        clear global in_callback;', ...
        '    catch error_struct;', ...
        '        clear global in_callback;', ...
        '        throw(error_struct);', ...
        '    end;', ...
        'else;return;end;']);%James Desjardins 2013/Jan/22
    u(2) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position', posbut(2,:), ...
        'Tag','Pushbutton2',...
        'string','<',...
        'Callback',['global in_callback;', ...
        'if isempty(in_callback);in_callback=1;', ...
        '    try eegplot(''drawp'',2);', ...
        '        clear global in_callback;', ...
        '    catch error_struct;', ...
        '        clear global in_callback;', ...
        '        throw(error_struct);', ...
        '    end;', ...
        'else;return;end;']);%James Desjardins 2013/Jan/22
    u(5) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', posbut(5,:), ...
        'Style','edit', ...
        'Tag','EPosition',...
        'string', fastif(g.trialstag(1) == -1, '0', '1'),...
        'Callback', 'eegplot(''drawp'',0);' );
    u(3) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position',posbut(3,:), ...
        'Tag','Pushbutton3',...
        'string','>',...
        'Callback',['global in_callback;', ...
        'if isempty(in_callback);in_callback=1;', ...
        '    try eegplot(''drawp'',3);', ...
        '        clear global in_callback;', ...
        '    catch error_struct;', ...
        '        clear global in_callback;', ...
        '        throw(error_struct);', ...
        '    end;', ...
        'else;return;end;']);%James Desjardins 2013/Jan/22
    u(4) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position',posbut(4,:), ...
        'Tag','Pushbutton4',...
        'string','>>',...
        'Callback',['global in_callback;', ...
        'if isempty(in_callback);in_callback=1;', ...
        '    try eegplot(''drawp'',4);', ...
        '        clear global in_callback;', ...
        '    catch error_struct;', ...
        '        clear global in_callback;', ...
        '        error(error_struct);', ...
        '    end;', ...
        'else;return;end;']);%James Desjardins 2013/Jan/22
    
    % Text edit fields: ESpacing
    u(6) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', posbut(6,:), ...
        'Style','edit', ...
        'Tag','ESpacing',...
        'string',num2str(g.spacing),...
        'Callback', 'eegplot(''draws'',0);' );
    
    % Slider for vertical motion
    u(20) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position', posbut(20,:), ...
        'Style','slider', ...
        'visible', 'off', ...
        'sliderstep', [0.9 1], ...
        'Tag','eegslider', ...
        'callback', [ 'tmpg = get(gcbf, ''userdata'');' ...
        'tmpg.elecoffset = get(gcbo, ''value'')*(tmpg.chans-tmpg.dispchans);' ...
        'set(gcbf, ''userdata'', tmpg);' ...
        'eegplot(''drawp'',0);' ...
        'clear tmpg;' ], ...
        'value', 0);
    
    % Channels, position, value and tag
    
    u(9) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'BackgroundColor',DEFAULT_FIG_COLOR, ...
        'Position', posbut(7,:), ...
        'Style','text', ...
        'Tag','Eelec',...
        'string',' ');
    u(10) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'BackgroundColor',DEFAULT_FIG_COLOR, ...
        'Position', posbut(8,:), ...
        'Style','text', ...
        'Tag','Etime',...
        'string','0.00');
    u(11) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'BackgroundColor',DEFAULT_FIG_COLOR, ...
        'Position',posbut(9,:), ...
        'Style','text', ...
        'Tag','Evalue',...
        'string','0.00');
    
    u(14)= uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'BackgroundColor',DEFAULT_FIG_COLOR, ...
        'Position', posbut(14,:), ...
        'Style','text', ...
        'Tag','Eelecname',...
        'string','Chan.');
    
    % Values of time/value and freq/power in GUI
    if g.isfreq
        u15_string =  'Freq';
        u16_string  = 'Power';
    else
        u15_string =  'Time';
        u16_string  = 'Value';
    end
    
    u(15) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'BackgroundColor',DEFAULT_FIG_COLOR, ...
        'Position', posbut(15,:), ...
        'Style','text', ...
        'Tag','Etimename',...
        'string',u15_string);
    
    u(16) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'BackgroundColor',DEFAULT_FIG_COLOR, ...
        'Position',posbut(16,:), ...
        'Style','text', ...
        'Tag','Evaluename',...
        'string',u16_string);
    
    % ESpacing buttons: + -
    u(7) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position',posbut(10,:), ...
        'Tag','Pushbutton5',...
        'string','+',...
        'FontSize',8,...
        'Callback','eegplot(''draws'',1)');
    u(8) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position',posbut(11,:), ...
        'Tag','Pushbutton6',...
        'string','-',...
        'FontSize',8,...
        'Callback','eegplot(''draws'',2)');
    
    cb_normalize = ['g = get(gcbf,''userdata'');if g.normed, disp(''Denormalizing...''); else, disp(''Normalizing...''); end;'...
        'hmenu = findobj(gcf, ''Tag'', ''Normalize_menu'');' ...
        'ax1 = findobj(''tag'',''eegaxis'',''parent'',gcbf);' ...
        'data = get(ax1,''UserData'');' ...
        'if isempty(g.datastd), g.datastd = std(data(:,1:min(1000,g.frames),[],2)); end;'...
        'if g.normed, '...
        'for i = 1:size(data,1), '...
        'data(i,:,:) = data(i,:,:)*g.datastd(i);'...
        'if ~isempty(g.data2), g.data2(i,:,:) = g.data2(i,:,:)*g.datastd(i);end;'...
        'end;'...
        'set(gcbo,''string'', ''Norm'');set(findobj(''tag'',''ESpacing'',''parent'',gcbf),''string'',num2str(g.oldspacing));' ...
        'else, for i = 1:size(data,1),'...
        'data(i,:,:) = data(i,:,:)/g.datastd(i);'...
        'if ~isempty(g.data2), g.data2(i,:,:) = g.data2(i,:,:)/g.datastd(i);end;'...
        'end;'...
        'set(gcbo,''string'', ''Denorm'');g.oldspacing = g.spacing;set(findobj(''tag'',''ESpacing'',''parent'',gcbf),''string'',''5'');end;' ...
        'g.normed = 1 - g.normed;' ...
        'eegplot(''draws'',0);'...
        'set(hmenu, ''Label'', fastif(g.normed,''Denormalize channels'',''Normalize channels''));' ...
        'set(gcbf,''userdata'',g);set(ax1,''UserData'',data);clear ax1 g data;' ...
        'eegplot(''drawp'',0);' ...
        'disp(''Done.'')'];
    % Button for Normalizing data
    u(21) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position',posbut(21,:), ...
        'Tag','Norm',...
        'string','Norm', 'callback', cb_normalize);
    
    cb_envelope = ['g = get(gcbf,''userdata'');'...
        'hmenu = findobj(gcf, ''Tag'', ''Envelope_menu'');' ...
        'g.envelope = ~g.envelope;' ...
        'set(gcbf,''userdata'',g);'...
        'set(gcbo,''string'',fastif(g.envelope,''Spread'',''Stack''));' ...
        'set(hmenu, ''Label'', fastif(g.envelope,''Spread channels'',''Stack channels''));' ...
        'eegplot(''drawp'',0);clear g;'];
    
    % Button to plot envelope of data
    u(22) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position',posbut(22,:), ...
        'Tag','Envelope',...
        'string','Stack', 'callback', cb_envelope);
    
    
    if isempty(g.command) tmpcom = 'fprintf(''Rejections saved in variable TMPREJ\n'');';
    else tmpcom = g.command;
    end
    acceptcommand = [ 'g = get(gcbf, ''userdata'');' ...
        'TMPREJ = g.winrej;' ...
        'if g.children, delete(g.children); end;' ...
        'delete(gcbf);' ...
        tmpcom ...
        '; clear g;']; % quitting expression
    if ~isempty(g.command)
        u(12) = uicontrol('Parent',figh, ...
            'Units', 'normalized', ...
            'Position',posbut(12,:), ...
            'Tag','Accept',...
            'string',g.butlabel, 'callback', acceptcommand);
    end
    u(13) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position',posbut(13,:), ...
        'string',fastif(isempty(g.command),'CLOSE', 'CANCEL'), 'callback', ...
        [	'g = get(gcbf, ''userdata'');' ...
        'if g.children, delete(g.children); end;' ...
        'close(gcbf);'] );
    
    if ~isempty(g.events)
        u(17) = uicontrol('Parent',figh, ...
            'Units', 'normalized', ...
            'Position',posbut(17,:), ...
            'string', 'Event types', 'callback', 'eegplot(''drawlegend'', gcbf)');
    end
    
    for i = 1: length(u) % Matlab 2014b compatibility
        if isprop(eval(['u(' num2str(i) ')']),'Style')
            set(u(i),'Units','Normalized');
        end
    end
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%% Set up uimenus
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Figure Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    m(7) = uimenu('Parent',figh,'Label','Figure');
    m(8) = uimenu('Parent',m(7),'Label','Print');
    uimenu('Parent',m(7),'Label','Edit figure', 'Callback', 'eegplot(''noui'');');
    uimenu('Parent',m(7),'Label','Accept and close', 'Callback', acceptcommand );
    uimenu('Parent',m(7),'Label','Cancel and close', 'Callback','delete(gcbf)')
    
    % Portrait %%%%%%%%
    
    timestring = ['[OBJ1,FIG1] = gcbo;',...
        'PANT1 = get(OBJ1,''parent'');',...
        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
        'set(OBJ2,''checked'',''off'');',...
        'set(OBJ1,''checked'',''on'');',...
        'set(FIG1,''PaperOrientation'',''portrait'');',...
        'clear OBJ1 FIG1 OBJ2 PANT1;'];
    
    uimenu('Parent',m(8),'Label','Portrait','checked',...
        'on','tag','orient','callback',timestring)
    
    % Landscape %%%%%%%
    timestring = ['[OBJ1,FIG1] = gcbo;',...
        'PANT1 = get(OBJ1,''parent'');',...
        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
        'set(OBJ2,''checked'',''off'');',...
        'set(OBJ1,''checked'',''on'');',...
        'set(FIG1,''PaperOrientation'',''landscape'');',...
        'clear OBJ1 FIG1 OBJ2 PANT1;'];
    
    uimenu('Parent',m(8),'Label','Landscape','checked',...
        'off','tag','orient','callback',timestring)
    
    % Print command %%%%%%%
    uimenu('Parent',m(8),'Label','Print','tag','printcommand','callback',...
        ['RESULT = inputdlg2( { ''Command:'' }, ''Print'', 1,  { ''print -r72'' });' ...
        'if size( RESULT,1 ) ~= 0' ...
        '  eval ( RESULT{1} );' ...
        'end;' ...
        'clear RESULT;' ]);
    
    % Display Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    m(1) = uimenu('Parent',figh,...
        'Label','Display', 'tag', 'displaymenu');
    
    % window grid %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % userdata = 4 cells : display yes/no, color, electrode yes/no,
    %                      trial boundary adapt yes/no (1/0)
    m(11) = uimenu('Parent',m(1),'Label','Data select/mark', 'tag', 'displaywin', ...
        'userdata', { 1, [0.8 1 0.8], 0, fastif( g.trialstag(1) == -1, 0, 1)});
    
    uimenu('Parent',m(11),'Label','Hide marks','Callback', ...
        ['g = get(gcbf, ''userdata'');' ...
        'if ~g.winstatus' ...
        '  set(gcbo, ''label'', ''Hide marks'');' ...
        'else' ...
        '  set(gcbo, ''label'', ''Show marks'');' ...
        'end;' ...
        'g.winstatus = ~g.winstatus;' ...
        'set(gcbf, ''userdata'', g);' ...
        'eegplot(''drawb''); clear g;'] )
    
    % color %%%%%%%%%%%%%%%%%%%%%%%%%%
    if isunix % for some reasons, does not work under Windows
        uimenu('Parent',m(11),'Label','Choose color', 'Callback', ...
            [ 'g = get(gcbf, ''userdata'');' ...
            'g.wincolor = uisetcolor(g.wincolor);' ...
            'set(gcbf, ''userdata'', g ); ' ...
            'clear g;'] )
    end
    
    % set channels
    %uimenu('Parent',m(11),'Label','Mark channels', 'enable', 'off', ...
    %'checked', 'off', 'Callback', ... ['g = get(gcbf, ''userdata'');' ...
    % 'g.setelectrode = ~g.setelectrode;' ... 'set(gcbf, ''userdata'', g);
    % ' ... 'if ~g.setelectrode setgcbo, ''checked'', ''on''); ... else
    % set(gcbo, ''checked'', ''off''); end;'... ' clear g;'] )
    
    % trials boundaries
    %uimenu('Parent',m(11),'Label','Trial boundaries', 'checked', fastif(
    %g.trialstag(1) == -1, 'off', 'on'), 'Callback', ... ['hh =
    %findobj(''tag'',''displaywin'',''parent'',
    %findobj(''tag'',''displaymenu'',''parent'', gcbf ));' ...
    % 'hhdat = get(hh, ''userdata'');' ... 'set(hh, ''userdata'', {
    % hhdat{1},  hhdat{2}, hhdat{3}, ~hhdat{4}} ); ' ...
    %'if ~hhdat{4} set(gcbo, ''checked'', ''on''); else set(gcbo,
    %''checked'', ''off''); end;' ... ' clear hh hhdat;'] )
    
    % plot durations --------------
    if g.ploteventdur && isfield(g.events, 'duration')
        disp(['Use menu "Display > Hide event duration" to hide colored regions ' ...
            'representing event duration']);
    end
    if isfield(g.events, 'duration')
        uimenu('Parent',m(1),'Label',fastif(g.ploteventdur, 'Hide event duration', 'Plot event duration'),'Callback', ...
            ['g = get(gcbf, ''userdata'');' ...
            'if ~g.ploteventdur' ...
            '  set(gcbo, ''label'', ''Hide event duration'');' ...
            'else' ...
            '  set(gcbo, ''label'', ''Show event duration'');' ...
            'end;' ...
            'g.ploteventdur = ~g.ploteventdur;' ...
            'set(gcbf, ''userdata'', g);' ...
            'eegplot(''drawb''); clear g;'] )
    end
    
    % X grid %%%%%%%%%%%%
    m(3) = uimenu('Parent',m(1),'Label','Grid');
    timestring = ['FIGH = gcbf;',...
        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
        'if size(get(AXESH,''xgrid''),2) == 2' ... %on
        '  set(AXESH,''xgrid'',''off'');',...
        '  set(gcbo,''label'',''X grid on'');',...
        'else' ...
        '  set(AXESH,''xgrid'',''on'');',...
        '  set(gcbo,''label'',''X grid off'');',...
        'end;' ...
        'clear FIGH AXESH;' ];
    uimenu('Parent',m(3),'Label',fastif(strcmp(g.xgrid, 'off'), ...
        'X grid on','X grid off'), 'Callback',timestring)
    
    % Y grid %%%%%%%%%%%%%
    timestring = ['FIGH = gcbf;',...
        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
        'if size(get(AXESH,''ygrid''),2) == 2' ... %on
        '  set(AXESH,''ygrid'',''off'');',...
        '  set(gcbo,''label'',''Y grid on'');',...
        'else' ...
        '  set(AXESH,''ygrid'',''on'');',...
        '  set(gcbo,''label'',''Y grid off'');',...
        'end;' ...
        'clear FIGH AXESH;' ];
    uimenu('Parent',m(3),'Label',fastif(strcmp(g.ygrid, 'off'), ...
        'Y grid on','Y grid off'), 'Callback',timestring)
    
    % Grid Style %%%%%%%%%
    m(5) = uimenu('Parent',m(3),'Label','Grid Style');
    timestring = ['FIGH = gcbf;',...
        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
        'set(AXESH,''gridlinestyle'',''--'');',...
        'clear FIGH AXESH;'];
    uimenu('Parent',m(5),'Label','- -','Callback',timestring)
    timestring = ['FIGH = gcbf;',...
        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
        'set(AXESH,''gridlinestyle'',''-.'');',...
        'clear FIGH AXESH;'];
    uimenu('Parent',m(5),'Label','_ .','Callback',timestring)
    timestring = ['FIGH = gcbf;',...
        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
        'set(AXESH,''gridlinestyle'','':'');',...
        'clear FIGH AXESH;'];
    uimenu('Parent',m(5),'Label','. .','Callback',timestring)
    timestring = ['FIGH = gcbf;',...
        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
        'set(AXESH,''gridlinestyle'',''-'');',...
        'clear FIGH AXESH;'];
    uimenu('Parent',m(5),'Label','__','Callback',timestring)
    
    % Submean menu %%%%%%%%%%%%%
    cb =       ['g = get(gcbf, ''userdata'');' ...
        'if strcmpi(g.submean, ''on''),' ...
        '  set(gcbo, ''label'', ''Remove DC offset'');' ...
        '  g.submean =''off'';' ...
        'else' ...
        '  set(gcbo, ''label'', ''Do not remove DC offset'');' ...
        '  g.submean =''on'';' ...
        'end;' ...
        'set(gcbf, ''userdata'', g);' ...
        'eegplot(''drawp'', 0); clear g;'];
    uimenu('Parent',m(1),'Label',fastif(strcmp(g.submean, 'on'), ...
        'Do not remove DC offset','Remove DC offset'), 'Callback',cb)
    
    % Scale Eye %%%%%%%%%
    timestring = ['[OBJ1,FIG1] = gcbo;',...
        'eegplot(''scaleeye'',OBJ1,FIG1);',...
        'clear OBJ1 FIG1;'];
    m(7) = uimenu('Parent',m(1),'Label','Show scale','Callback',timestring);
    
    % Title %%%%%%%%%%%%
    uimenu('Parent',m(1),'Label','Title','Callback','eegplot(''title'')')
    
    % Stack/Spread %%%%%%%%%%%%%%%
    cb =       ['g = get(gcbf, ''userdata'');' ...
        'hbutton = findobj(gcf, ''Tag'', ''Envelope'');' ...  % find button
        'if g.envelope == 0,' ...
        '  set(gcbo, ''label'', ''Spread channels'');' ...
        '  g.envelope = 1;' ...
        '  set(hbutton, ''String'', ''Spread'');' ...
        'else' ...
        '  set(gcbo, ''label'', ''Stack channels'');' ...
        '  g.envelope = 0;' ...
        '  set(hbutton, ''String'', ''Stack'');' ...
        'end;' ...
        'set(gcbf, ''userdata'', g);' ...
        'eegplot(''drawp'', 0); clear g;'];
    uimenu('Parent',m(1),'Label',fastif(g.envelope == 0, ...
        'Stack channels','Spread channels'), 'Callback',cb, 'Tag', 'Envelope_menu')
    
    % Normalize/denormalize %%%%%%%%%%%%%%%
    cb_normalize = ['g = get(gcbf,''userdata'');if g.normed, disp(''Denormalizing...''); else, disp(''Normalizing...''); end;'...
        'hbutton = findobj(gcf, ''Tag'', ''Norm'');' ...  % find button
        'ax1 = findobj(''tag'',''eegaxis'',''parent'',gcbf);' ...
        'data = get(ax1,''UserData'');' ...
        'if isempty(g.datastd), g.datastd = std(data(:,1:min(1000,g.frames),[],2)); end;'...
        'if g.normed, '...
        '  for i = 1:size(data,1), '...
        '    data(i,:,:) = data(i,:,:)*g.datastd(i);'...
        '    if ~isempty(g.data2), g.data2(i,:,:) = g.data2(i,:,:)*g.datastd(i);end;'...
        '  end;'...
        '  set(hbutton,''string'', ''Norm'');set(findobj(''tag'',''ESpacing'',''parent'',gcbf),''string'',num2str(g.oldspacing));' ...
        '  set(gcbo, ''label'', ''Normalize channels'');' ...
        'else, for i = 1:size(data,1),'...
        '    data(i,:,:) = data(i,:,:)/g.datastd(i);'...
        '    if ~isempty(g.data2), g.data2(i,:,:) = g.data2(i,:,:)/g.datastd(i);end;'...
        '  end;'...
        '  set(hbutton,''string'', ''Denorm'');'...
        '  set(gcbo, ''label'', ''Denormalize channels'');' ...
        '  g.oldspacing = g.spacing;set(findobj(''tag'',''ESpacing'',''parent'',gcbf),''string'',''5'');end;' ...
        'g.normed = 1 - g.normed;' ...
        'eegplot(''draws'',0);'...
        'set(gcbf,''userdata'',g);set(ax1,''UserData'',data);clear ax1 g data;' ...
        'eegplot(''drawp'',0);' ...
        'disp(''Done.'')'];
    uimenu('Parent',m(1),'Label',fastif(g.envelope == 0, ...
        'Normalize channels','Denormalize channels'), 'Callback',cb_normalize, 'Tag', 'Normalize_menu')
    
    
    % Settings Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m(2) = uimenu('Parent',figh,...
        'Label','Settings');
    
    % Window %%%%%%%%%%%%
    uimenu('Parent',m(2),'Label','Time range to display',...
        'Callback','eegplot(''window'')')
    
    % Electrode window %%%%%%%%
    uimenu('Parent',m(2),'Label','Number of channels to display',...
        'Callback','eegplot(''winelec'')')
    
    % Electrodes %%%%%%%%
    m(6) = uimenu('Parent',m(2),'Label','Channel labels');
    
    timestring = ['FIGH = gcbf;',...
        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
        'YTICK = get(AXESH,''YTick'');',...
        'YTICK = length(YTICK);',...
        'set(AXESH,''YTickLabel'',flipud(char(num2str((1:YTICK-1)''),'' '')));',...
        'clear FIGH AXESH YTICK;'];
    uimenu('Parent',m(6),'Label','Show number','Callback',timestring)
    uimenu('Parent',m(6),'Label','Load .loc(s) file',...
        'Callback','eegplot(''loadelect'');')
    
    % Zooms %%%%%%%%
    zm = uimenu('Parent',m(2),'Label','Zoom off/on');
    if matVers < 8.4
        commandzoom = [ 'set(gcbf, ''WindowButtonDownFcn'', [ ''zoom(gcbf,''''down''''); eegplot(''''zoom'''', gcbf, 1);'' ]);' ...
            'tmpg = get(gcbf, ''userdata'');' ...
            'clear tmpg tmpstr;'];
    else
        % Temporary fix to avoid warning when setting a callback and the
        % mode is active This is failing for us
        % http://undocumentedmatlab.com/blog/enabling-user-callbacks-during-zoom-pan
        commandzoom = [ 'wtemp = warning; warning off;set(gcbf, ''WindowButtonDownFcn'', [ ''zoom(gcbf); eegplot(''''zoom'''', gcbf, 1);'' ]);' ...
            'tmpg = get(gcbf, ''userdata'');' ...
            'warning(wtemp);'...
            'clear wtemp tmpg tmpstr; '];
    end
    
    %uimenu('Parent',zm,'Label','Zoom time', 'callback', ...
    %             [ 'zoom(gcbf, ''xon'');' commandzoom ]);
    %uimenu('Parent',zm,'Label','Zoom channels', 'callback', ...
    %             [ 'zoom(gcbf, ''yon'');' commandzoom ]);
    uimenu('Parent',zm,'Label','Zoom on', 'callback', commandzoom);
    uimenu('Parent',zm,'Label','Zoom off', 'separator', 'on', 'callback', ...
        ['zoom(gcbf, ''off''); tmpg = get(gcbf, ''userdata'');' ...
        'set(gcbf, ''windowbuttondownfcn'', tmpg.commandselect{1});' ...
        'set(gcbf, ''windowbuttonupfcn'', tmpg.commandselect{3});' ...
        'clear tmpg;' ]);
    
    uimenu('Parent',figh,'Label', 'Help', 'callback', 'pophelp(''eegplot'');');
    
    % Events %%%%%%%%
    zm = uimenu('Parent',m(2),'Label','Events');
    complotevent = [ 'tmpg = get(gcbf, ''userdata'');' ...
        'tmpg.plotevent = ''on'';' ...
        'set(gcbf, ''userdata'', tmpg); clear tmpg; eegplot(''drawp'', 0);'];
    comnoevent   = [ 'tmpg = get(gcbf, ''userdata'');' ...
        'tmpg.plotevent = ''off'';' ...
        'set(gcbf, ''userdata'', tmpg); clear tmpg; eegplot(''drawp'', 0);'];
    comeventmaxstring   = [ 'tmpg = get(gcbf, ''userdata'');' ...
        'tmpg.plotevent = ''on'';' ...
        'set(gcbf, ''userdata'', tmpg); clear tmpg; eegplot(''emaxstring'');']; % JavierLC
    comeventleg  = [ 'eegplot(''drawlegend'', gcbf);'];
    
    uimenu('Parent',zm,'Label','Events on'    , 'callback', complotevent, 'enable', fastif(isempty(g.events), 'off', 'on'));
    uimenu('Parent',zm,'Label','Events off'   , 'callback', comnoevent  , 'enable', fastif(isempty(g.events), 'off', 'on'));
    uimenu('Parent',zm,'Label','Events'' string length'   , 'callback', comeventmaxstring, 'enable', fastif(isempty(g.events), 'off', 'on')); % JavierLC
    uimenu('Parent',zm,'Label','Events'' legend', 'callback', comeventleg , 'enable', fastif(isempty(g.events), 'off', 'on'));
    
    
    % %%%%%%%%%%%%%%%%% Set up autoselect NOTE: commandselect{2} option has
    % been moved to a
    %       subfunction to improve speed
    %%%%%%%%%%%%%%%%%%%
    g.commandselect{1} = [ 'if strcmp(get(gcbf, ''SelectionType''),''alt''),' g.ctrlselectcommand{1} ...
        'else '                                            g.selectcommand{1} 'end;' ];
    g.commandselect{3} = [ 'if strcmp(get(gcbf, ''SelectionType''),''alt''),' g.ctrlselectcommand{3} ...
        'else '                                            g.selectcommand{3} 'end;' ];
    
    set(figh, 'windowbuttondownfcn',   g.commandselect{1});
    set(figh, 'windowbuttonmotionfcn', {@defmotion,figh,ax0,ax1,u(10),u(11),u(9)});
    set(figh, 'windowbuttonupfcn',     g.commandselect{3});
    set(figh, 'WindowKeyPressFcn',     @eegplot_readkey);
    set(figh, 'interruptible', 'off');
    set(figh, 'busyaction', 'cancel');
    %  set(figh, 'windowbuttondownfcn', commandpush); set(figh,
    %  'windowbuttonmotionfcn', commandmove); set(figh,
    %  'windowbuttonupfcn', commandrelease); set(figh, 'interruptible',
    %  'off'); set(figh, 'busyaction', 'cancel');
    
    % prepare event array if any --------------------------
    if ~isempty(g.events)
        if ~isfield(g.events, 'type') || ~isfield(g.events, 'latency'), g.events = []; end
    end
    
    if ~isempty(g.events)
        if ischar(g.events(1).type)
            [g.eventtypes tmpind indexcolor] = unique_bc({g.events.type}); % indexcolor countinas the event type
        else [g.eventtypes tmpind indexcolor] = unique_bc([ g.events.type ]);
        end
        g.eventcolors     = { 'r', [0 0.8 0], 'm', 'c', 'k', 'b', [0 0.8 0] };
        g.eventstyle      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'};
        g.eventwidths     = [ 2.5 1 ];
        g.eventtypecolors = g.eventcolors(mod([1:length(g.eventtypes)]-1 ,length(g.eventcolors))+1);
        g.eventcolors     = g.eventcolors(mod(indexcolor-1               ,length(g.eventcolors))+1);
        g.eventtypestyle  = g.eventstyle (mod([1:length(g.eventtypes)]-1 ,length(g.eventstyle))+1);
        g.eventstyle      = g.eventstyle (mod(indexcolor-1               ,length(g.eventstyle))+1);
        
        % for width, only boundary events have width 2 (for the line)
        % -----------------------------------------------------------
        indexwidth = ones(1,length(g.eventtypes))*2;
        if iscell(g.eventtypes)
            for index = 1:length(g.eventtypes)
                if strcmpi(g.eventtypes{index}, 'boundary'), indexwidth(index) = 1; end
            end
        end
        g.eventtypewidths = g.eventwidths (mod(indexwidth([1:length(g.eventtypes)])-1 ,length(g.eventwidths))+1);
        g.eventwidths     = g.eventwidths (mod(indexwidth(indexcolor)-1               ,length(g.eventwidths))+1);
        
        % latency and duration of events ------------------------------
        g.eventlatencies  = [ g.events.latency ]+1;
        if isfield(g.events, 'duration')
            durations = { g.events.duration };
            durations(cellfun(@isempty, durations)) = { NaN };
            g.eventlatencyend   = g.eventlatencies + [durations{:}]+1;
        else g.eventlatencyend   = [];
        end
        g.plotevent       = 'on';
    end
    if isempty(g.events)
        g.plotevent      = 'off';
    end
    
    set(figh, 'userdata', g);
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%% Plot EEG Data %%%%%%%%%%%%%%%%%%%%%%%%%%
    axes(ax1)
    hold on
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%% Plot Spacing I %%%%%%%%%%%%%%%%%%%%%%%%%%
    YLim = get(ax1,'Ylim');
    A = DEFAULT_AXES_POSITION;
    axes('Position',[A(1)+A(3) A(2) 1-A(1)-A(3) A(4)],'Visible','off','Ylim',YLim,'tag','eyeaxes')
    axis manual
    if strcmp(SPACING_EYE,'on'),  set(m(7),'checked','on')
    else set(m(7),'checked','off');
    end
    eegplot('scaleeye', [], gcf);
    if strcmp(lower(g.scale), 'off')
        eegplot('scaleeye', 'off', gcf);
    end
    
    eegplot('drawp', 0);
    eegplot('drawp', 0);
    if g.dispchans ~= g.chans
        eegplot('zoom', gcf);
    end;
    eegplot('scaleeye', [], gcf);
    
    h = findobj(gcf, 'style', 'pushbutton');
    set(h, 'backgroundcolor', BUTTON_COLOR);
    h = findobj(gcf, 'tag', 'eegslider');
    set(h, 'backgroundcolor', BUTTON_COLOR);
    set(figh, 'visible', 'on');
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End Main
    % Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
else
    try, p1 = varargin{1}; p2 = varargin{2}; p3 = varargin{3}; catch, end
    switch data
        case 'drawp' % Redraw EEG and change position
            
            % this test help to couple eegplot windows
            if exist('p3', 'var')
                figh = p3;
                figure(p3);
            else
                figh = gcf;                          % figure handle
            end
            
            if strcmp(get(figh,'tag'),'dialog')
                figh = get(figh,'UserData');
            end
            ax0 = findobj('tag','backeeg','parent',figh); % axes handle
            ax1 = findobj('tag','eegaxis','parent',figh); % axes handle
            g = get(figh,'UserData');
            data = get(ax1,'UserData');
            ESpacing = findobj('tag','ESpacing','parent',figh);   % ui handle
            EPosition = findobj('tag','EPosition','parent',figh); % ui handle
            if ~isempty(EPosition) && ~isempty(ESpacing)
                if g.trialstag(1) == -1
                    g.time    = str2num(get(EPosition,'string'));
                else
                    g.time    = str2num(get(EPosition,'string'));
                    g.time    = g.time - 1;
                end
                g.spacing = str2num(get(ESpacing,'string'));
            end
            
            if p1 == 1
                g.time = g.time-g.winlength;     % << subtract one window length
            elseif p1 == 2
                g.time = g.time-fastif(g.winlength>=1, 1, g.winlength/5);             % < subtract one second
            elseif p1 == 3
                g.time = g.time+fastif(g.winlength>=1, 1, g.winlength/5);             % > add one second
            elseif p1 == 4
                g.time = g.time+g.winlength;     % >> add one window length
            end
            
            if g.trialstag ~= -1 % time in second or in trials
                multiplier = g.trialstag;
            else
                multiplier = g.srate;
            end
            
            % Update edit box ---------------
            g.time = max(0,min(g.time,ceil((g.frames-1)/multiplier)-g.winlength));
            if g.trialstag(1) == -1
                set(EPosition,'string',num2str(g.time));
            else
                set(EPosition,'string',num2str(g.time+1));
            end
            set(figh, 'userdata', g);
            
            lowlim = round(g.time*multiplier+1);
            highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
            
            % Plot data and update axes -------------------------
            if ~isempty(g.data2)
                switch lower(g.submean) % subtract the mean ?
                    case 'on'
                        meandata = mean(g.data2(:,lowlim:highlim)');
                        if any(isnan(meandata))
                            meandata = nan_mean(g.data2(:,lowlim:highlim)');
                        end
                    otherwise, meandata = zeros(1,g.chans);
                end
            else
                switch lower(g.submean) % subtract the mean ?
                    case 'on'
                        meandata = mean(data(:,lowlim:highlim)');
                        if any(isnan(meandata))
                            meandata = nan_mean(data(:,lowlim:highlim)');
                        end
                    otherwise, meandata = zeros(1,g.chans);
                end
            end
            if strcmpi(g.plotdata2, 'off')
                axes(ax1)
                cla
            end
            
            oldspacing = g.spacing;
            if g.envelope
                g.spacing = 0;
            end
            % plot data ---------
            axes(ax1)
            hold on
            
            % plot channels whose "badchan" field is set to 1. Bad channels
            % are plotted first so that they appear behind the good
            % channels in the eegplot figure window.
            for i = 1:g.chans
                if strcmpi(g.plotdata2, 'on')
                    tmpcolor = [ 1 0 0 ];
                else tmpcolor = g.color{mod(i-1,length(g.color))+1};
                end
                
                if isfield(g, 'eloc_file') && isfield(g.eloc_file, 'badchan') && g.eloc_file(g.chans-i+1).badchan
                    tmpcolor = [ .85 .85 .85 ];
                    plot(data(g.chans-i+1,lowlim:highlim) -meandata(g.chans-i+1)+i*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing), ...
                        'color', tmpcolor, 'clipping','on')
                    plot(1,mean(data(g.chans-i+1,lowlim:highlim) -meandata(g.chans-i+1)+i*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing),2),'<r','MarkerFaceColor','r','MarkerSize',6);
                end
                
            end
            
            % plot good channels on top of bad channels (if
            % g.eloc_file(i).badchan = 0... or there is no bad channel
            % information)
            for i = 1:g.chans
                if strcmpi(g.plotdata2, 'on')
                    tmpcolor = [ 1 0 0 ];
                else tmpcolor = g.color{mod(g.chans-i,length(g.color))+1};
                end
                
                %        keyboard;
                if (isfield(g, 'eloc_file') && isfield(g.eloc_file, 'badchan') && ~g.eloc_file(g.chans-i+1).badchan) || ...
                        (~isfield(g, 'eloc_file')) || (~isfield(g.eloc_file, 'badchan'))
                    plot(data(g.chans-i+1,lowlim:highlim) -meandata(g.chans-i+1)+i*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing), ...
                        'color', tmpcolor, 'clipping','on')
                end
                
            end
            
            % draw selected channels ------------------------
            if ~isempty(g.winrej) && size(g.winrej,2) > 2
                for tpmi = 1:size(g.winrej,1) % scan rows
                    if (g.winrej(tpmi,1) >= lowlim && g.winrej(tpmi,1) <= highlim) || ...
                            (g.winrej(tpmi,2) >= lowlim & g.winrej(tpmi,2) <= highlim)
                        abscmin = max(1,round(g.winrej(tpmi,1)-lowlim));
                        abscmax = round(g.winrej(tpmi,2)-lowlim);
                        maxXlim = get(gca, 'xlim');
                        abscmax = min(abscmax, round(maxXlim(2)-1));
                        for i = 1:g.chans
                            if g.winrej(tpmi,g.chans-i+1+5)
                                plot(abscmin+1:abscmax+1,data(g.chans-i+1,abscmin+lowlim:abscmax+lowlim) ...
                                    -meandata(g.chans-i+1)+i*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing), 'color','r','clipping','on')
                            end
                        end
                    end
                end
            end
            g.spacing = oldspacing;
            set(ax1, 'Xlim',[1 g.winlength*multiplier],...
                'XTick',[1:multiplier*DEFAULT_GRID_SPACING:g.winlength*multiplier+1]);
            %          if g.isfreq % Ramon
            %              set(ax1, 'XTickLabel',
            %              num2str((g.freqs(1):DEFAULT_GRID_SPACING:g.freqs(end))'));
            %          else
            set(ax1, 'XTickLabel', num2str((g.time:DEFAULT_GRID_SPACING:g.time+g.winlength)'));
            %          end
            
            % ordinates: even if all elec are plotted, some may be hidden
            set(ax1, 'ylim',[g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] );
            
            if g.children ~= 0
                if ~exist('p2', 'var')
                    p2 =[];
                end
                eegplot( 'drawp', p1, p2, g.children);
                figure(figh);
            end
            
            % draw second data if necessary
            if ~isempty(g.data2)
                tmpdata = data;
                set(ax1, 'userdata', g.data2);
                g.data2 = [];
                g.plotdata2 = 'on';
                set(figh, 'userdata', g);
                eegplot('drawp', 0);
                g.plotdata2 = 'off';
                g.data2 = get(ax1, 'userdata');
                set(ax1, 'userdata', tmpdata);
                set(figh, 'userdata', g);
            else
                eegplot('drawb');
            end
            
        case 'drawb' % Draw background ******************************************************
            % Redraw EEG and change position
            
            ax0 = findobj('tag','backeeg','parent',gcf); % axes handle
            ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
            
            g = get(gcf,'UserData');  % Data (Note: this could also be global)
            
            % Plot data and update axes
            axes(ax0);
            cla;
            hold on;
            % plot rejected windows
            if g.trialstag ~= -1
                multiplier = g.trialstag;
            else
                multiplier = g.srate;
            end
            
            % draw rejection windows ----------------------
            lowlim = round(g.time*multiplier+1);
            highlim = round(min((g.time+g.winlength)*multiplier+1));
            displaymenu = findobj('tag','displaymenu','parent',gcf);
            if ~isempty(g.winrej) && g.winstatus
                if g.trialstag ~= -1 % epoched data
                    indices = find((g.winrej(:,1)' >= lowlim & g.winrej(:,1)' <= highlim) | ...
                        (g.winrej(:,2)' >= lowlim & g.winrej(:,2)' <= highlim));
                    if ~isempty(indices)
                        tmpwins1 = g.winrej(indices,1)';
                        tmpwins2 = g.winrej(indices,2)';
                        if size(g.winrej,2) > 2
                            tmpcols  = g.winrej(indices,3:5);
                        else tmpcols  = g.wincolor;
                        end
                        try, eval('[cumul indicescount] = histc(tmpwins1, (min(tmpwins1)-1):g.trialstag:max(tmpwins2));');
                        catch, [cumul indicescount] = myhistc(tmpwins1, (min(tmpwins1)-1):g.trialstag:max(tmpwins2));
                        end
                        count = zeros(size(cumul));
                        %if ~isempty(find(cumul > 1)), find(cumul > 1), end
                        for tmpi = 1:length(tmpwins1)
                            poscumul = indicescount(tmpi);
                            heightbeg = count(poscumul)/cumul(poscumul);
                            heightend = heightbeg + 1/cumul(poscumul);
                            count(poscumul) = count(poscumul)+1;
                            h = patch([tmpwins1(tmpi)-lowlim tmpwins2(tmpi)-lowlim ...
                                tmpwins2(tmpi)-lowlim tmpwins1(tmpi)-lowlim], ...
                                [heightbeg heightbeg heightend heightend], ...
                                tmpcols(tmpi,:));  % this argument is color
                            set(h, 'EdgeColor', get(h, 'facecolor'))
                        end
                    end
                else
                    event2plot1 = find ( g.winrej(:,1) >= lowlim & g.winrej(:,1) <= highlim );
                    event2plot2 = find ( g.winrej(:,2) >= lowlim & g.winrej(:,2) <= highlim );
                    event2plot3 = find ( g.winrej(:,1) <  lowlim & g.winrej(:,2) >  highlim );
                    event2plot  = union_bc(union(event2plot1, event2plot2), event2plot3);
                    
                    for tpmi = event2plot(:)'
                        if size(g.winrej,2) > 2
                            tmpcols  = g.winrej(tpmi,3:5);
                        else tmpcols  = g.wincolor;
                        end
                        h = patch([g.winrej(tpmi,1)-lowlim g.winrej(tpmi,2)-lowlim ...
                            g.winrej(tpmi,2)-lowlim g.winrej(tpmi,1)-lowlim], ...
                            [0 0 1 1], tmpcols);
                        set(h, 'EdgeColor', get(h, 'facecolor'))
                    end
                end
            end
            
            % plot tags ---------
            %if trialtag(1) ~= -1 & displaystatus % put tags at arbitrary
            %places
            % 	for tmptag = trialtag
            %		if tmptag >= lowlim & tmptag <= highlim
            %			plot([tmptag-lowlim tmptag-lowlim], [0 1], 'b--');
            %		end;
            %	end
            %end
            
            % draw events if any ------------------
            if strcmpi(g.plotevent, 'on')
                
                % JavierLC ###############################
                MAXEVENTSTRING = g.maxeventstring;
                if MAXEVENTSTRING<0
                    MAXEVENTSTRING = 0;
                elseif MAXEVENTSTRING>75
                    MAXEVENTSTRING=75;
                end
                AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
                % JavierLC ###############################
                
                % find event to plot ------------------
                event2plot    = find ( g.eventlatencies >=lowlim & g.eventlatencies <= highlim );
                if ~isempty(g.eventlatencyend)
                    event2plot2 = find ( g.eventlatencyend >= lowlim & g.eventlatencyend <= highlim );
                    event2plot3 = find ( g.eventlatencies  <  lowlim & g.eventlatencyend >  highlim );
                    event2plot  = union_bc(union(event2plot, event2plot2), event2plot3);
                end
                for index = 1:length(event2plot)
                    %Just repeat for the first one
                    if index == 1
                        EVENTFONT = ' \fontsize{10} ';
                        ylims=ylim;
                    end
                    
                    % draw latency line -----------------
                    tmplat = g.eventlatencies(event2plot(index))-lowlim-1;
                    tmph   = plot([ tmplat tmplat ], ylims, 'color', g.eventcolors{ event2plot(index) }, ...
                        'linestyle', g.eventstyle { event2plot(index) }, ...
                        'linewidth', g.eventwidths( event2plot(index) ) );
                    
                    % schtefan: add Event types text above event latency
                    % line
                    % -------------------------------------------------------
                    %             EVENTFONT = ' \fontsize{10} ';
                    %             ylims=ylim;
                    evntxt = strrep(num2str(g.events(event2plot(index)).type),'_','-');
                    if length(evntxt)>MAXEVENTSTRING, evntxt = [ evntxt(1:MAXEVENTSTRING-1) '...' ]; end; % truncate
                    try,
                        tmph2 = text([tmplat], ylims(2)-0.005, [EVENTFONT evntxt], ...
                            'color', g.eventcolors{ event2plot(index) }, ...
                            'horizontalalignment', 'left',...
                            'rotation',90);
                    catch, end
                    
                    % draw duration is not 0 ----------------------
                    if g.ploteventdur && ~isempty(g.eventlatencyend) ...
                            && g.eventwidths( event2plot(index) ) ~= 2.5 % do not plot length of boundary events
                        tmplatend = g.eventlatencyend(event2plot(index))-lowlim-1;
                        if tmplatend ~= 0
                            tmplim = ylims;
                            tmpcol = g.eventcolors{ event2plot(index) };
                            h = patch([ tmplat tmplatend tmplatend tmplat ], ...
                                [ tmplim(1) tmplim(1) tmplim(2) tmplim(2) ], ...
                                tmpcol );  % this argument is color
                            set(h, 'EdgeColor', 'none')
                        end
                    end
                end
            else % JavierLC
                MAXEVENTSTRING = 10; % default
                AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
            end
            
            if g.trialstag(1) ~= -1
                
                % plot trial limits -----------------
                tmptag = [lowlim:highlim];
                tmpind = find(mod(tmptag-1, g.trialstag) == 0);
                for index = tmpind
                    plot([tmptag(index)-lowlim tmptag(index)-lowlim], [0 1], 'b--');
                end
                alltag = tmptag(tmpind);
                
                % compute Xticks --------------
                tagnum = (alltag-1)/g.trialstag+1;
                set(ax0,'XTickLabel', tagnum,'YTickLabel', [],...
                    'Xlim',[0 g.winlength*multiplier-1],...
                    'XTick',alltag-lowlim+g.trialstag/2, 'YTick',[], 'tag','backeeg');
                
                axes(ax1);
                tagpos  = [];
                tagtext = [];
                if ~isempty(alltag)
                    alltag = [alltag(1)-g.trialstag alltag alltag(end)+g.trialstag]; % add border trial limits
                else
                    alltag = [ floor(lowlim/g.trialstag)*g.trialstag ceil(highlim/g.trialstag)*g.trialstag ]+1;
                end
                
                nbdiv = 20/g.winlength; % approximative number of divisions
                divpossible = [ 100000./[1 2 4 5] 10000./[1 2 4 5] 1000./[1 2 4 5] 100./[1 2 4 5 10 20]]; % possible increments
                [tmp indexdiv] = min(abs(nbdiv*divpossible-(g.limits(2)-g.limits(1)))); % closest possible increment
                incrementpoint = divpossible(indexdiv)/1000*g.srate;
                
                % tag zero below is an offset used to be sure that 0 is
                % included in the absicia of the data epochs
                if g.limits(2) < 0, tagzerooffset  = (g.limits(2)-g.limits(1))/1000*g.srate+1;
                else                tagzerooffset  = -g.limits(1)/1000*g.srate;
                end
                if tagzerooffset < 0, tagzerooffset = 0; end
                
                for i=1:length(alltag)-1
                    if ~isempty(tagpos) && tagpos(end)-alltag(i)<2*incrementpoint/3
                        tagpos  = tagpos(1:end-1);
                    end
                    if ~isempty(g.freqlimits)
                        tagpos  = [ tagpos linspace(alltag(i),alltag(i+1)-1, nbdiv) ];
                    else
                        if tagzerooffset ~= 0
                            tmptagpos = [alltag(i)+tagzerooffset:-incrementpoint:alltag(i)];
                        else
                            tmptagpos = [];
                        end
                        tagpos  = [ tagpos [tmptagpos(end:-1:2) alltag(i)+tagzerooffset:incrementpoint:(alltag(i+1)-1)]];
                    end
                end
                
                % find corresponding epochs -------------------------
                if ~g.isfreq
                    tmplimit = g.limits;
                    tpmorder = 1E-3;
                else
                    tmplimit = g.freqlimits;
                    tpmorder = 1;
                end
                tagtext = eeg_point2lat(tagpos, floor((tagpos)/g.trialstag)+1, g.srate, tmplimit,tpmorder);
                set(ax1,'XTickLabel', tagtext,'XTick', tagpos-lowlim+1 );
            else
                set(ax0,'XTickLabel', [],'YTickLabel', [],...
                    'Xlim',[0 g.winlength*multiplier],...
                    'XTick',[], 'YTick',[], 'tag','backeeg');
                
                axes(ax1);
                if g.isfreq
                    set(ax1, 'XTickLabel', num2str((g.freqs(1):DEFAULT_GRID_SPACING:g.freqs(end))'),...
                        'XTick',[1:multiplier*DEFAULT_GRID_SPACING:g.winlength*multiplier+1]);
                else
                    set(ax1,'XTickLabel', num2str((g.time:DEFAULT_GRID_SPACING:g.time+g.winlength)'),...
                        'XTick',[1:multiplier*DEFAULT_GRID_SPACING:g.winlength*multiplier+1]);
                end
                
                set(ax1, 'Position', AXES_POSITION) % JavierLC
                set(ax0, 'Position', AXES_POSITION) % JavierLC
            end
            
            % ordinates: even if all elec are plotted, some may be hidden
            set(ax1, 'ylim',[g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] );
            
            axes(ax1)
            
        case 'draws'
            % Redraw EEG and change scale
            
            ax1 = findobj('tag','eegaxis','parent',gcf);         % axes handle
            g = get(gcf,'UserData');
            data = get(ax1, 'userdata');
            ESpacing = findobj('tag','ESpacing','parent',gcf);   % ui handle
            EPosition = findobj('tag','EPosition','parent',gcf); % ui handle
            if g.trialstag(1) == -1
                g.time    = str2num(get(EPosition,'string'));
            else
                g.time    = str2num(get(EPosition,'string'))-1;
            end;
            g.spacing = str2num(get(ESpacing,'string'));
            
            orgspacing= g.spacing;
            if p1 == 1
                g.spacing= g.spacing+ 0.1*orgspacing; % increase g.spacing(5%)
            elseif p1 == 2
                g.spacing= max(0,g.spacing-0.1*orgspacing); % decrease g.spacing(5%)
            end
            if round(g.spacing*100) == 0
                maxindex = min(10000, g.frames);
                g.spacing = 0.01*max(max(data(:,1:maxindex),[],2),[],1)-min(min(data(:,1:maxindex),[],2),[],1);  % Set g.spacingto max/min data
            end
            
            % update edit box ---------------
            set(ESpacing,'string',num2str(g.spacing,4))
            set(gcf, 'userdata', g);
            eegplot('drawp', 0);
            set(ax1,'YLim',[0 (g.chans+1)*g.spacing],'YTick',[0:g.spacing:g.chans*g.spacing])
            set(ax1, 'ylim',[g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] );
            
            % update scaling eye (I) if it exists
            % -----------------------------------
            eyeaxes = findobj('tag','eyeaxes','parent',gcf);
            if ~isempty(eyeaxes)
                eyetext = findobj('type','text','parent',eyeaxes,'tag','thescalenum');
                set(eyetext,'string',num2str(g.spacing,4))
            end
            
            return;
            
        case 'window'  % change window size
            % get new window length with dialog box
            % -------------------------------------
            g = get(gcf,'UserData');
            result       = inputdlg2( { fastif(g.trialstag==-1,'New window length (s):', 'Number of epoch(s):') }, 'Change window length', 1,  { num2str(g.winlength) });
            if size(result,1) == 0 return; end
            
            g.winlength = eval(result{1});
            set(gcf, 'UserData', g);
            eegplot('drawp',0);
            return;
            
        case 'winelec'  % change channel window size
            % get new window length with dialog box
            % -------------------------------------
            fig = gcf;
            g = get(gcf,'UserData');
            result = inputdlg2( ...
                { 'Number of channels to display:' } , 'Change number of channels to display', 1,  { num2str(g.dispchans) });
            if size(result,1) == 0 return; end
            
            g.dispchans = eval(result{1});
            if g.dispchans<0 || g.dispchans>g.chans
                g.dispchans =g.chans;
            end
            set(gcf, 'UserData', g);
            eegplot('updateslider', fig);
            eegplot('drawp',0);
            eegplot('scaleeye', [], fig);
            return;
            
        case 'emaxstring'  % change events' string length  ;  JavierLC
            % get dialog box -------------------------------------
            g = get(gcf,'UserData');
            result = inputdlg2({ 'Max events'' string length:' } , 'Change events'' string length to display', 1,  { num2str(g.maxeventstring) });
            if size(result,1) == 0 return; end;
            g.maxeventstring = eval(result{1});
            set(gcf, 'UserData', g);
            eegplot('drawb');
            return;
            
        case 'loadelect' % load channels
            [inputname,inputpath] = uigetfile('*','Channel locations file');
            if inputname == 0 return; end
            if ~exist([ inputpath inputname ])
                error('no such file');
            end
            
            AXH0 = findobj('tag','eegaxis','parent',gcf);
            eegplot('setelect',[ inputpath inputname ],AXH0);
            return;
            
        case 'setelect'
            % Set channels
            eloc_file = p1;
            axeshand = p2;
            outvar1 = 1;
            if isempty(eloc_file)
                outvar1 = 0;
                return
            end
            
            tmplocs = readlocs(eloc_file);
            YLabels = { tmplocs.labels };
            YLabels = strvcat(YLabels);
            
            YLabels = flipud(char(YLabels,' '));
            set(axeshand,'YTickLabel',YLabels)
            
        case 'title'
            % Get new title
            h = findobj('tag', 'eegplottitle');
            
            if ~isempty(h)
                result       = inputdlg2( { 'New title:' }, 'Change title', 1,  { get(h(1), 'string') });
                if ~isempty(result), set(h, 'string', result{1}); end
            else
                result       = inputdlg2( { 'New title:' }, 'Change title', 1,  { '' });
                if ~isempty(result), h = textsc(result{1}, 'title'); set(h, 'tag', 'eegplottitle');end
            end
            
            return;
            
        case 'scaleeye'
            % Turn scale I on/off
            obj = p1;
            figh = p2;
            g = get(figh,'UserData');
            % figh = get(obj,'Parent');
            
            if ~isempty(obj)
                eyeaxes = findobj('tag','eyeaxes','parent',figh);
                children = get(eyeaxes,'children');
                if ischar(obj)
                    if strcmp(obj, 'off')
                        set(children, 'visible', 'off');
                        set(eyeaxes, 'visible', 'off');
                        return;
                    else
                        set(children, 'visible', 'on');
                        set(eyeaxes, 'visible', 'on');
                    end
                else
                    toggle = get(obj,'checked');
                    if strcmp(toggle,'on')
                        set(children, 'visible', 'off');
                        set(eyeaxes, 'visible', 'off');
                        set(obj,'checked','off');
                        return;
                    else
                        set(children, 'visible', 'on');
                        set(eyeaxes, 'visible', 'on');
                        set(obj,'checked','on');
                    end
                end
            end
            
            eyeaxes = findobj('tag','eyeaxes','parent',figh);
            ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
            YLim = double(get(ax1, 'ylim'));
            
            ESpacing = findobj('tag','ESpacing','parent',figh);
            g.spacing= str2num(get(ESpacing,'string'));
            
            axes(eyeaxes); cla; axis off;
            set(eyeaxes, 'ylim', YLim);
            
            Xl = double([.35 .65; .5 .5; .35 .65]);
            Yl = double([ g.spacing g.spacing; g.spacing 0; 0 0] + YLim(1));
            plot(Xl(1,:),Yl(1,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline'); hold on;
            plot(Xl(2,:),Yl(2,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline');
            plot(Xl(3,:),Yl(3,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline');
            text(.5,(YLim(2)-YLim(1))/23+Yl(1),num2str(g.spacing,4),...
                'HorizontalAlignment','center','FontSize',10,...
                'tag','thescalenum')
            text(Xl(2)+.1,Yl(1),'+','HorizontalAlignment','left',...
                'verticalalignment','middle', 'tag', 'thescale')
            text(Xl(2)+.1,Yl(4),'-','HorizontalAlignment','left',...
                'verticalalignment','middle', 'tag', 'thescale')
            if ~isempty(SPACING_UNITS_STRING)
                text(.5,-YLim(2)/23+Yl(4),SPACING_UNITS_STRING,...
                    'HorizontalAlignment','center','FontSize',10, 'tag', 'thescale')
            end
            text(.5,(YLim(2)-YLim(1))/10+Yl(1),'Scale',...
                'HorizontalAlignment','center','FontSize',10, 'tag', 'thescale')
            set(eyeaxes, 'tag', 'eyeaxes');
            
        case 'noui'
            if ~isempty(varargin)
                eegplot( varargin{:} ); fig = gcf;
            else
                fig = findobj('tag', 'EEGPLOT');
            end
            set(fig, 'menubar', 'figure');
            
            % find button and text
            obj = findobj(fig, 'style', 'pushbutton'); delete(obj);
            obj = findobj(fig, 'style', 'edit'); delete(obj);
            obj = findobj(fig, 'style', 'text');
            %objscale = findobj(obj, 'tag', 'thescale');
            %delete(setdiff(obj, objscale));
            obj = findobj(fig, 'tag', 'Eelec');delete(obj);
            obj = findobj(fig, 'tag', 'Etime');delete(obj);
            obj = findobj(fig, 'tag', 'Evalue');delete(obj);
            obj = findobj(fig, 'tag', 'Eelecname');delete(obj);
            obj = findobj(fig, 'tag', 'Etimename');delete(obj);
            obj = findobj(fig, 'tag', 'Evaluename');delete(obj);
            obj = findobj(fig, 'type', 'uimenu');delete(obj);
            
        case 'zoom' % if zoom
            fig = varargin{1};
            ax1 = findobj('tag','eegaxis','parent',fig);
            ax2 = findobj('tag','backeeg','parent',fig);
            tmpxlim  = get(ax1, 'xlim');
            tmpylim  = get(ax1, 'ylim');
            tmpxlim2 = get(ax2, 'xlim');
            set(ax2, 'xlim', get(ax1, 'xlim'));
            g = get(fig,'UserData');
            
            % deal with abscissa ------------------
            if g.trialstag ~= -1
                Eposition = str2num(get(findobj('tag','EPosition','parent',fig), 'string'));
                g.winlength = (tmpxlim(2) - tmpxlim(1))/g.trialstag;
                Eposition = Eposition + (tmpxlim(1) - tmpxlim2(1)-1)/g.trialstag;
                Eposition = round(Eposition*1000)/1000;
                set(findobj('tag','EPosition','parent',fig), 'string', num2str(Eposition));
            else
                Eposition = str2num(get(findobj('tag','EPosition','parent',fig), 'string'))-1;
                g.winlength = (tmpxlim(2) - tmpxlim(1))/g.srate;
                Eposition = Eposition + (tmpxlim(1) - tmpxlim2(1)-1)/g.srate;
                Eposition = round(Eposition*1000)/1000;
                set(findobj('tag','EPosition','parent',fig), 'string', num2str(Eposition+1));
            end;
            
            % deal with ordinate ------------------
            g.elecoffset = tmpylim(1)/g.spacing;
            g.dispchans  = round(1000*(tmpylim(2)-tmpylim(1))/g.spacing)/1000;
            
            set(fig,'UserData', g);
            eegplot('updateslider', fig);
            eegplot('drawp', 0);
            eegplot('scaleeye', [], fig);
            
            % reactivate zoom if 3 arguments ------------------------------
            if exist('p2', 'var') == 1
                if matVers < 8.4
                    set(gcbf, 'windowbuttondownfcn', [ 'zoom(gcbf,''down''); eegplot(''zoom'', gcbf, 1);' ]);
                else
                    % This is failing for us:
                    % http://undocumentedmatlab.com/blog/enabling-user-callbacks-during-zoom-pan
                    %               hManager = uigetmodemanager(gcbf);
                    %               [hManager.WindowListenerHandles.Enabled]
                    %               = deal(false);
                    
                    % Temporary fix
                    wtemp = warning; warning off;
                    set(gcbf, 'WindowButtonDownFcn', [ 'zoom(gcbf); eegplot(''zoom'', gcbf, 1);' ]);
                    warning(wtemp);
                end
            end
            
        case 'updateslider' % if zoom
            fig = varargin{1};
            g = get(fig,'UserData');
            sliider = findobj('tag','eegslider','parent',fig);
            if g.elecoffset < 0
                g.elecoffset = 0;
            end
            if g.dispchans >= g.chans
                g.dispchans = g.chans;
                g.elecoffset = 0;
                set(sliider, 'visible', 'off');
            else
                set(sliider, 'visible', 'on');
                set(sliider, 'value', g.elecoffset/g.chans, ...
                    'sliderstep', [1/(g.chans-g.dispchans) g.dispchans/(g.chans-g.dispchans)]);
                %'sliderstep', [1/(g.chans-1) g.dispchans/(g.chans-1)]);
            end
            if g.elecoffset < 0
                g.elecoffset = 0;
            end
            if g.elecoffset > g.chans-g.dispchans
                g.elecoffset = g.chans-g.dispchans;
            end
            set(fig,'UserData', g);
            eegplot('scaleeye', [], fig);
            
        case 'drawlegend'
            fig = varargin{1};
            g = get(fig,'UserData');
            
            if ~isempty(g.events) % draw vertical colored lines for events, add event name text above
                nleg = length(g.eventtypes);
                fig2 = figure('numbertitle', 'off', 'name', '', 'visible', 'off', 'menubar', 'none', 'color', DEFAULT_FIG_COLOR);
                pos = get(fig2, 'position');
                set(fig2, 'position', [ pos(1) pos(2) 130 14*nleg+20]);
                
                for index = 1:nleg
                    plot([10 30], [(index-0.5) * 10 (index-0.5) * 10], 'color', g.eventtypecolors{index}, 'linestyle', ...
                        g.eventtypestyle{ index }, 'linewidth', g.eventtypewidths( index )); hold on;
                    if iscell(g.eventtypes)
                        th=text(35, (index-0.5)*10, g.eventtypes{index}, ...
                            'color', g.eventtypecolors{index});
                    else
                        th=text(35, (index-0.5)*10, num2str(g.eventtypes(index)), ...
                            'color', g.eventtypecolors{index});
                    end
                end
                xlim([0 130]);
                ylim([0 nleg*10]);
                axis off;
                set(fig2, 'visible', 'on');
            end
            
            
            % motion button: move windows or display current position
            % (channel, g.time and activation)
            % ----------------------------------------------------------------------------------------
            % case moved as subfunction add topoplot ------------
        case 'topoplot'
            fig = varargin{1};
            g = get(fig,'UserData');
            if ~isstruct(g.eloc_file) || ~isfield(g.eloc_file, 'theta') || isempty( [ g.eloc_file.theta ])
                return;
            end
            ax1 = findobj('tag','backeeg','parent',fig);
            tmppos = get(ax1, 'currentpoint');
            ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
            % plot vertical line
            yl = ylim;
            plot([ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
            
            if g.trialstag ~= -1,
                lowlim = round(g.time*g.trialstag+1);
            else, lowlim = round(g.time*g.srate+1);
            end
            data = get(ax1,'UserData');
            datapos = max(1, round(tmppos(1)+lowlim));
            datapos = min(datapos, g.frames);
            
            figure; topoplot(data(:,datapos), g.eloc_file);
            if g.trialstag == -1,
                latsec = (datapos-1)/g.srate;
                title(sprintf('Latency of %d seconds and %d milliseconds', floor(latsec), round(1000*(latsec-floor(latsec)))));
            else
                trial = ceil((datapos-1)/g.trialstag);
                
                latintrial = eeg_point2lat(datapos, trial, g.srate, g.limits, 0.001);
                title(sprintf('Latency of %d ms in trial %d', round(latintrial), trial));
            end
            return;
            
            % release button: check window consistency, add to trial
            % boundaries
            % -------------------------------------------------------------------
        case 'defupcom'
            fig = varargin{1};
            g = get(fig,'UserData');
            ax1 = findobj('tag','backeeg','parent',fig);
            g.incallback = 0;
            set(fig,'UserData', g);  % early save in case of bug in the following
            if strcmp(g.mocap,'on'), g.winrej = g.winrej(end,:);end; % nima
            if ~isempty(g.winrej)', ...
                    if g.winrej(end,1) == g.winrej(end,2) % remove unitary windows
                    g.winrej = g.winrej(1:end-1,:);
                    else
                        if g.winrej(end,1) > g.winrej(end,2) % reverse values if necessary
                            g.winrej(end, 1:2) = [g.winrej(end,2) g.winrej(end,1)];
                        end
                        g.winrej(end,1) = max(1, g.winrej(end,1));
                        g.winrej(end,2) = min(g.frames, g.winrej(end,2));
                        if g.trialstag == -1 % find nearest trials boundaries if necessary
                            I1 = find((g.winrej(end,1) >= g.winrej(1:end-1,1)) & (g.winrej(end,1) <= g.winrej(1:end-1,2)) );
                            if ~isempty(I1)
                                g.winrej(I1,2) = max(g.winrej(I1,2), g.winrej(end,2)); % extend epoch
                                g.winrej = g.winrej(1:end-1,:); % remove if empty match
                            else,
                                I2 = find((g.winrej(end,2) >= g.winrej(1:end-1,1)) & (g.winrej(end,2) <= g.winrej(1:end-1,2)) );
                                if ~isempty(I2)
                                    g.winrej(I2,1) = min(g.winrej(I2,1), g.winrej(end,1)); % extend epoch
                                    g.winrej = g.winrej(1:end-1,:); % remove if empty match
                                else,
                                    I2 = find((g.winrej(end,1) <= g.winrej(1:end-1,1)) & (g.winrej(end,2) >= g.winrej(1:end-1,1)) );
                                    if ~isempty(I2)
                                        g.winrej(I2,:) = []; % remove if empty match
                                    end
                                end
                            end
                        end
                    end
            end
            set(fig,'UserData', g);
            eegplot('drawp', 0);
            if strcmp(g.mocap,'on'), show_mocap_for_eegplot(g.winrej); g.winrej = g.winrej(end,:); end; % nima
            
            % push button: create/remove window
            % ---------------------------------
        case 'defdowncom'
            show_mocap_timer = timerfind('tag','mocapDisplayTimer'); if ~isempty(show_mocap_timer),  end; % nima
            fig = varargin{1};
            g = get(fig,'UserData');
            
            ax1 = findobj('tag','backeeg','parent',fig);
            tmppos = get(ax1, 'currentpoint');
            if strcmp(get(fig, 'SelectionType'),'normal')
                
                fig = varargin{1};
                g = get(fig,'UserData');
                ax1 = findobj('tag','backeeg','parent',fig);
                tmppos = get(ax1, 'currentpoint');
                g = get(fig,'UserData'); % get data of backgroung image {g.trialstag g.winrej incallback}
                if g.incallback ~= 1 % interception of nestest calls
                    if g.trialstag ~= -1
                        lowlim = round(g.time*g.trialstag+1);
                        highlim = round(g.winlength*g.trialstag);
                    else
                        lowlim  = round(g.time*g.srate+1);
                        highlim = round(g.winlength*g.srate); % THIS IS NOT TRUE WHEN ZOOMING
                        
                    end
                    if (tmppos(1) >= 0) && (tmppos(1) <= highlim)
                        if isempty(g.winrej) Allwin=0;
                        else Allwin = (g.winrej(:,1) < lowlim+tmppos(1)) & (g.winrej(:,2) > lowlim+tmppos(1));
                        end
                        if any(Allwin) % remove the mark or select electrode if necessary
                            lowlim = find(Allwin==1);
                            if g.setelectrode  % select electrode
                                ax2 = findobj('tag','eegaxis','parent',fig);
                                tmppos = get(ax2, 'currentpoint');
                                tmpelec = g.chans + 1 - round(tmppos(1,2) / g.spacing);
                                tmpelec = min(max(tmpelec, 1), g.chans);
                                g.winrej(lowlim,tmpelec+5) = ~g.winrej(lowlim,tmpelec+5); % set the electrode
                            else  % remove mark
                                g.winrej(lowlim,:) = [];
                            end
                        else
                            if g.trialstag ~= -1 % find nearest trials boundaries if epoched data
                                alltrialtag = [0:g.trialstag:g.frames];
                                I1 = find(alltrialtag < (tmppos(1)+lowlim) );
                                if ~isempty(I1) && I1(end) ~= length(alltrialtag),
                                    g.winrej = [g.winrej' [alltrialtag(I1(end)) alltrialtag(I1(end)+1) g.wincolor zeros(1,g.chans)]']';
                                end
                            else,
                                g.incallback = 1;  % set this variable for callback for continuous data
                                if size(g.winrej,2) < 5
                                    g.winrej(:,3:5) = repmat(g.wincolor, [size(g.winrej,1) 1]);
                                end
                                if size(g.winrej,2) < 5+g.chans
                                    g.winrej(:,6:(5+g.chans)) = zeros(size(g.winrej,1),g.chans);
                                end
                                g.winrej = [g.winrej' [tmppos(1)+lowlim tmppos(1)+lowlim g.wincolor zeros(1,g.chans)]']';
                            end
                        end
                        set(fig,'UserData', g);
                        eegplot('drawp', 0);  % redraw background
                    end
                end
            elseif strcmp(get(fig, 'SelectionType'),'normal');
                
                
            end
        otherwise
            error(['Error - invalid eegplot() parameter: ',data])
    end
end
% Function to show the value and electrode at mouse position
end
function defmotion(varargin)
fig = varargin{3};
ax1 = varargin{5};
tmppos = get(ax1, 'currentpoint');

if  all([tmppos(1,1) >= 0,tmppos(1,2)>= 0])
    g = get(fig,'UserData');
    if g.trialstag ~= -1
        lowlim = round(g.time*g.trialstag+1);
    else, lowlim = round(g.time*g.srate+1);
    end
    if g.incallback
        g.winrej = [g.winrej(1:end-1,:)' [g.winrej(end,1) tmppos(1)+lowlim g.winrej(end,3:end)]']';
        set(fig,'UserData', g);
        eegplot('drawb');
    else
        hh = varargin{6}; % h = findobj('tag','Etime','parent',fig);
        if g.trialstag ~= -1
            tmpval = mod(tmppos(1)+lowlim-1,g.trialstag)/g.trialstag*(g.limits(2)-g.limits(1)+1000/g.srate) + g.limits(1);
            if g.isfreq, tmpval = tmpval/1000 + g.freqs(1); end
            set(hh, 'string', num2str(tmpval));
        else
            tmpval = (tmppos(1)+lowlim-1)/g.srate;
            if g.isfreq, tmpval = tmpval+g.freqs(1); end
            set(hh, 'string', num2str(tmpval)); % put g.time in the box
        end
        ax1 = varargin{5};% ax1 = findobj('tag','eegaxis','parent',fig);
        tmppos = get(ax1, 'currentpoint');
        tmpelec = round(tmppos(1,2) / g.spacing);
        tmpelec = min(max(double(tmpelec), 1),g.chans);
        labls = get(ax1, 'YtickLabel');
        hh = varargin{8}; % hh = findobj('tag','Eelec','parent',fig);  % put electrode in the box
        if ~g.envelope
            set(hh, 'string', labls(tmpelec+1,:));
        else
            set(hh, 'string', ' ');
        end
        hh = varargin{7}; % hh = findobj('tag','Evalue','parent',fig);
        if ~g.envelope
            eegplotdata = get(ax1, 'userdata');
            set(hh, 'string', num2str(eegplotdata(g.chans+1-tmpelec, min(g.frames,max(1,double(round(tmppos(1)+lowlim)))))));  % put value in the box
        else
            set(hh,'string',' ');
        end
    end
end
end
function [reshist, allbin] = myhistc(vals, intervals)

reshist = zeros(1, length(intervals));
allbin = zeros(1, length(vals));

for index=1:length(vals)
    minvals = vals(index)-intervals;
    bintmp  = find(minvals >= 0);
    [mintmp indextmp] = min(minvals(bintmp));
    bintmp = bintmp(indextmp);
    
    allbin(index) = bintmp;
    reshist(bintmp) = reshist(bintmp)+1;
end
end
function [EEG, com] = pop_rejepoch( EEG, tmprej, confirm)

com = '';
if nargin < 1
    help pop_rejepoch;
    return;
end
if nargin < 2
    tmprej =  find(EEG.reject.rejglobal);
end
if nargin < 3
    confirm = 1;
end
if islogical(tmprej), tmprej = tmprej+0; end

uniquerej = double(sort(unique(tmprej)));
if length(tmprej) > 0 && length(uniquerej) <= 2 && ...
        ismember(uniquerej(1), [0 1]) && ismember(uniquerej(end), [0 1]) && any(~tmprej)
    format0_1 = 1;
    fprintf('%d/%d trials rejected\n', sum(tmprej), EEG.trials);
else
    format0_1 = 0;
    fprintf('%d/%d trials rejected\n', length(tmprej), EEG.trials);
end

if confirm ~= 0
    ButtonName=questdlg2('Are you sure, you want to reject the labeled trials ?', ...
        'Reject pre-labelled epochs -- pop_rejepoch()', 'NO', 'YES', 'YES');
    switch ButtonName,
        case 'NO',
            disp('Operation cancelled');
            return;
        case 'YES',
            disp('Compute new dataset');
    end % switch
    
end

% create a new set if set_out is non nul
% --------------------------------------
if format0_1
    tmprej = find(tmprej > 0);
end
EEG = pop_select( EEG, 'notrial', tmprej);

com = sprintf( 'EEG = pop_rejepoch( EEG, %s);', vararg2str({ tmprej 0 }));
return;
end
function imageData = screencapture(varargin)
% screencapture - get a screen-capture of a figure frame, component handle,
% or screen area rectangle
%
% ScreenCapture gets a screen-capture of any Matlab GUI handle (including
% desktop, figure, axes, image or uicontrol), or a specified area rectangle
% located relative to the specified handle. Screen area capture is possible
% by specifying the root (desktop) handle (=0). The output can be either to
% an image file or to a Matlab matrix (useful for displaying via imshow()
% or for further processing) or to the system clipboard. This utility also
% enables adding a toolbar button for easy interactive screen-capture.
%
% Syntax:
%    imageData = screencapture(handle, position, target,
%    'PropName',PropValue, ...)
%
% Input Parameters:
%    handle   - optional handle to be used for screen-capture origin.
%                 If empty/unsupplied then current figure (gcf) will be
%                 used.
%    position - optional position array in pixels: [x,y,width,height].
%                 If empty/unsupplied then the handle's position vector
%                 will be used. If both handle and position are
%                 empty/unsupplied then the position
%                   will be retrieved via interactive mouse-selection.
%                 If handle is an image, then position is in data (not
%                 pixel) units, so the
%                   captured region remains the same after figure/axes
%                   resize (like imcrop)
%    target   - optional filename for storing the screen-capture, or the
%               'clipboard'/'printer' strings.
%                 If empty/unsupplied then no output to file will be done.
%                 The file format will be determined from the extension
%                 (JPG/PNG/...). Supported formats are those supported by
%                 the imwrite function.
%    'PropName',PropValue -
%               optional list of property pairs (e.g.,
%               'target','myImage.png','pos',[10,20,30,40],'handle',gca)
%               PropNames may be abbreviated and are case-insensitive.
%               PropNames may also be given in whichever order. Supported
%               PropNames are:
%                 - 'handle'    (default: gcf handle) - 'position'
%                 (default: gcf position array) - 'target'    (default: '')
%                 - 'toolbar'   (figure handle; default: gcf)
%                      this adds a screen-capture button to the figure's
%                      toolbar If this parameter is specified, then no
%                      screen-capture
%                        will take place and the returned imageData will be
%                        [].
%
% Output parameters:
%    imageData - image data in a format acceptable by the imshow function
%                  If neither target nor imageData were specified, the user
%                  will be
%                    asked to interactively specify the output file.
%
% Examples:
%    imageData = screencapture;  % interactively select screen-capture
%    rectangle imageData = screencapture(hListbox);  % capture image of a
%    uicontrol imageData = screencapture(0,  [20,30,40,50]);  % capture a
%    small desktop region imageData = screencapture(gcf,[20,30,40,50]);  %
%    capture a small figure region imageData =
%    screencapture(gca,[10,20,30,40]);  % capture a small axes region
%      imshow(imageData);  % display the captured image in a matlab figure
%      imwrite(imageData,'myImage.png');  % save the captured image to file
%    img = imread('cameraman.tif');
%      hImg = imshow(img); screencapture(hImg,[60,35,140,80]);  % capture a
%      region of an image
%    screencapture(gcf,[],'myFigure.jpg');  % capture the entire figure
%    into file screencapture(gcf,[],'clipboard');     % capture the entire
%    figure into clipboard screencapture(gcf,[],'printer');       % print
%    the entire figure screencapture('handle',gcf,'target','myFigure.jpg');
%    % same as previous, save to file
%    screencapture('handle',gcf,'target','clipboard');    % same as
%    previous, copy to clipboard
%    screencapture('handle',gcf,'target','printer');      % same as
%    previous, send to printer screencapture('toolbar',gcf);  % adds a
%    screen-capture button to gcf's toolbar
%    screencapture('toolbar',[],'target','sc.bmp'); % same with default
%    output filename
%
% Technical description:
%    http://UndocumentedMatlab.com/blog/screencapture-utility/
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% See also:
%    imshow, imwrite, print
%
% Release history:
%    1.17 2016-05-16: Fix annoying warning about JavaFrame property
%    becoming obsolete someday (yes, we know...) 1.16 2016-04-19: Fix for
%    deployed application suggested by Dwight Bartholomew 1.10 2014-11-25:
%    Added the 'print' target 1.9  2014-11-25: Fix for saving GIF files 1.8
%    2014-11-16: Fixes for R2014b 1.7  2014-04-28: Fixed bug when capturing
%    interactive selection 1.6  2014-04-22: Only enable image formats when
%    saving to an unspecified file via uiputfile 1.5  2013-04-18: Fixed bug
%    in capture of non-square image; fixes for Win64 1.4  2013-01-27: Fixed
%    capture of Desktop (root); enabled rbbox anywhere on desktop (not
%    necesarily in a Matlab figure); enabled output to clipboard (based on
%    Jiro Doke's imclipboard utility); edge-case fixes; added Java
%    compatibility check 1.3  2012-07-23: Capture current object
%    (uicontrol/axes/figure) if w=h=0 (e.g., by clicking a single point);
%    extra input args sanity checks; fix for docked windows and image axes;
%    include axes labels & ticks by default when capturing axes; use
%    data-units position vector when capturing images; many edge-case fixes
%    1.2  2011-01-16: another performance boost (thanks to Jan Simon); some
%    compatibility fixes for Matlab 6.5 (untested) 1.1  2009-06-03: Handle
%    missing output format; performance boost (thanks to Urs); fix minor
%    root-handle bug; added toolbar button option 1.0  2009-06-02: First
%    version posted on <a
%    href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks
%    File Exchange</a>
% License to use and modify this code is granted freely to all interested,
% as long as the original author is referenced and attributed as such. The
% original author maintains the right to be solely associated with this
% work. Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.17 $  $Date: 2016/05/16 17:59:36 $ Ensure that java awt is
% enabled...
if ~usejava('awt')
    error('YMA:screencapture:NeedAwt','ScreenCapture requires Java to run.');
end
% Ensure that our Java version supports the Robot class (requires JVM 1.3+)
try
    robot = java.awt.Robot; %#ok<NASGU>
catch
    uiwait(msgbox({['Your Matlab installation is so old that its Java engine (' version('-java') ...
        ') does not have a java.awt.Robot class. '], ' ', ...
        'Without this class, taking a screen-capture is impossible.', ' ', ...
        'So, either install JVM 1.3 or higher, or use a newer Matlab release.'}, ...
        'ScreenCapture', 'warn'));
    if nargout, imageData = [];  end
    return;
end
% Process optional arguments
paramsStruct = processArgs(varargin{:});

% If toolbar button requested, add it and exit
if ~isempty(paramsStruct.toolbar)
    
    % Add the toolbar button
    addToolbarButton(paramsStruct);
    
    % Return the figure to its pre-undocked state (when relevant)
    redockFigureIfRelevant(paramsStruct);
    
    % Exit immediately (do NOT take a screen-capture)
    if nargout,  imageData = [];  end
    return;
end

% Convert position from handle-relative to desktop Java-based pixels
[paramsStruct, msgStr] = convertPos(paramsStruct);

% Capture the requested screen rectangle using java.awt.Robot
imgData = getScreenCaptureImageData(paramsStruct.position);

% Return the figure to its pre-undocked state (when relevant)
redockFigureIfRelevant(paramsStruct);

% Save image data in file or clipboard, if specified
if ~isempty(paramsStruct.target)
    if strcmpi(paramsStruct.target,'clipboard')
        if ~isempty(imgData)
            imclipboard(imgData);
        else
            msgbox('No image area selected - not copying image to clipboard','ScreenCapture','warn');
        end
    elseif strncmpi(paramsStruct.target,'print',5)  % 'print' or 'printer'
        if ~isempty(imgData)
            hNewFig = figure('visible','off');
            imshow(imgData);
            print(hNewFig);
            delete(hNewFig);
        else
            msgbox('No image area selected - not printing screenshot','ScreenCapture','warn');
        end
    else  % real filename
        if ~isempty(imgData)
            imwrite(imgData,paramsStruct.target);
        else
            msgbox(['No image area selected - not saving image file ' paramsStruct.target],'ScreenCapture','warn');
        end
    end
end
% Return image raster data to user, if requested
if nargout
    imageData = imgData;
    
    % If neither output formats was specified (neither target nor output
    % data)
elseif isempty(paramsStruct.target) & ~isempty(imgData)  %#ok ML6
    % Ask the user to specify a file
    %error('YMA:screencapture:noOutput','No output specified for
    %ScreenCapture: specify the output filename and/or output data');
    %format = '*.*';
    formats = imformats;
    for idx = 1 : numel(formats)
        ext = sprintf('*.%s;',formats(idx).ext{:});
        format(idx,1:2) = {ext(1:end-1), formats(idx).description}; %#ok<AGROW>
    end
    [filename,pathname] = uiputfile(format,'Save screen capture as');
    if ~isequal(filename,0) & ~isequal(pathname,0)  %#ok Matlab6 compatibility
        try
            filename = fullfile(pathname,filename);
            imwrite(imgData,filename);
        catch  % possibly a GIF file that requires indexed colors
            [imgData,map] = rgb2ind(imgData,256);
            imwrite(imgData,map,filename);
        end
    else
        % TODO - copy to clipboard
    end
end
% Display msgStr, if relevant
if ~isempty(msgStr)
    uiwait(msgbox(msgStr,'ScreenCapture'));
    drawnow; pause(0.05);  % time for the msgbox to disappear
end
return;  % debug breakpoint
end
function paramsStruct = processArgs(varargin)
% Get the properties in either direct or P-V format
[regParams, pvPairs] = parseparams(varargin);
% Now process the optional P-V params
try
    % Initialize
    paramName = [];
    paramsStruct = [];
    paramsStruct.handle = [];
    paramsStruct.position = [];
    paramsStruct.target = '';
    paramsStruct.toolbar = [];
    paramsStruct.wasDocked = 0;       % no false available in ML6
    paramsStruct.wasInteractive = 0;  % no false available in ML6
    % Parse the regular (non-named) params in recption order
    if ~isempty(regParams) & (isempty(regParams{1}) | ishandle(regParams{1}(1)))  %#ok ML6
        paramsStruct.handle = regParams{1};
        regParams(1) = [];
    end
    if ~isempty(regParams) & isnumeric(regParams{1}) & (length(regParams{1}) == 4)  %#ok ML6
        paramsStruct.position = regParams{1};
        regParams(1) = [];
    end
    if ~isempty(regParams) & ischar(regParams{1})  %#ok ML6
        paramsStruct.target = regParams{1};
    end
    % Parse the optional param PV pairs
    supportedArgs = {'handle','position','target','toolbar'};
    while ~isempty(pvPairs)
        % Disregard empty propNames (may be due to users mis-interpretting
        % the syntax help)
        while ~isempty(pvPairs) & isempty(pvPairs{1})  %#ok ML6
            pvPairs(1) = [];
        end
        if isempty(pvPairs)
            break;
        end
        % Ensure basic format is valid
        paramName = '';
        if ~ischar(pvPairs{1})
            error('YMA:screencapture:invalidProperty','Invalid property passed to ScreenCapture');
        elseif length(pvPairs) == 1
            if isempty(paramsStruct.target)
                paramsStruct.target = pvPairs{1};
                break;
            else
                error('YMA:screencapture:noPropertyValue',['No value specified for property ''' pvPairs{1} '''']);
            end
        end
        % Process parameter values
        paramName  = pvPairs{1};
        if strcmpi(paramName,'filename')  % backward compatibility
            paramName = 'target';
        end
        paramValue = pvPairs{2};
        pvPairs(1:2) = [];
        idx = find(strncmpi(paramName,supportedArgs,length(paramName)));
        if ~isempty(idx)
            %paramsStruct.(lower(supportedArgs{idx(1)})) = paramValue;  %
            %incompatible with ML6
            paramsStruct = setfield(paramsStruct, lower(supportedArgs{idx(1)}), paramValue);  %#ok ML6
            % If 'toolbar' param specified, then it cannot be left empty -
            % use gcf
            if strncmpi(paramName,'toolbar',length(paramName)) & isempty(paramsStruct.toolbar)  %#ok ML6
                paramsStruct.toolbar = getCurrentFig;
            end
        elseif isempty(paramsStruct.target)
            paramsStruct.target = paramName;
            pvPairs = {paramValue, pvPairs{:}};  %#ok (more readable this way, although a bit less efficient...)
        else
            supportedArgsStr = sprintf('''%s'',',supportedArgs{:});
            error('YMA:screencapture:invalidProperty','%s \n%s', ...
                'Invalid property passed to ScreenCapture', ...
                ['Supported property names are: ' supportedArgsStr(1:end-1)]);
        end
    end  % loop pvPairs
catch
    if ~isempty(paramName),  paramName = [' ''' paramName ''''];  end
    error('YMA:screencapture:invalidProperty','Error setting ScreenCapture property %s:\n%s',paramName,lasterr); %#ok<LERR>
end
end  % processArgs
function [paramsStruct, msgStr] = convertPos(paramsStruct)
msgStr = '';
try
    % Get the screen-size for later use
    screenSize = get(0,'ScreenSize');
    % Get the containing figure's handle
    hParent = paramsStruct.handle;
    if isempty(paramsStruct.handle)
        paramsStruct.hFigure = getCurrentFig;
        hParent = paramsStruct.hFigure;
    else
        paramsStruct.hFigure = ancestor(paramsStruct.handle,'figure');
    end
    % To get the acurate pixel position, the figure window must be undocked
    try
        if strcmpi(get(paramsStruct.hFigure,'WindowStyle'),'docked')
            set(paramsStruct.hFigure,'WindowStyle','normal');
            drawnow; pause(0.25);
            paramsStruct.wasDocked = 1;  % no true available in ML6
        end
    catch
        % never mind - ignore...
    end
    % The figure (if specified) must be in focus
    if ~isempty(paramsStruct.hFigure) & ishandle(paramsStruct.hFigure)  %#ok ML6
        isFigureValid = 1;  % no true available in ML6
        figure(paramsStruct.hFigure);
    else
        isFigureValid = 0;  % no false available in ML6
    end
    % Flush all graphic events to ensure correct rendering
    drawnow; pause(0.01);
    % No handle specified
    wasPositionGiven = 1;  % no true available in ML6
    if isempty(paramsStruct.handle)
        
        % Set default handle, if not supplied
        paramsStruct.handle = paramsStruct.hFigure;
        
        % If position was not specified, get it interactively using RBBOX
        if isempty(paramsStruct.position)
            [paramsStruct.position, jFrameUsed, msgStr] = getInteractivePosition(paramsStruct.hFigure); %#ok<ASGLU> jFrameUsed is unused
            paramsStruct.wasInteractive = 1;  % no true available in ML6
            wasPositionGiven = 0;  % no false available in ML6
        end
        
    elseif ~ishandle(paramsStruct.handle)
        % Handle was supplied - ensure it is a valid handle
        error('YMA:screencapture:invalidHandle','Invalid handle passed to ScreenCapture');
        
    elseif isempty(paramsStruct.position)
        % Handle was supplied but position was not, so use the handle's
        % position
        paramsStruct.position = getPixelPos(paramsStruct.handle);
        paramsStruct.position(1:2) = 0;
        wasPositionGiven = 0;  % no false available in ML6
        
    elseif ~isnumeric(paramsStruct.position) | (length(paramsStruct.position) ~= 4)  %#ok ML6
        % Both handle & position were supplied - ensure a valid pixel
        % position vector
        error('YMA:screencapture:invalidPosition','Invalid position vector passed to ScreenCapture: \nMust be a [x,y,w,h] numeric pixel array');
    end
    
    % Capture current object (uicontrol/axes/figure) if w=h=0 (single-click
    % in interactive mode)
    if paramsStruct.position(3)<=0 | paramsStruct.position(4)<=0  %#ok ML6
        %TODO - find a way to single-click another Matlab figure (the
        %following does not work) paramsStruct.position =
        %getPixelPos(ancestor(hittest,'figure'));
        paramsStruct.position = getPixelPos(paramsStruct.handle);
        paramsStruct.position(1:2) = 0;
        paramsStruct.wasInteractive = 0;  % no false available in ML6
        wasPositionGiven = 0;  % no false available in ML6
    end
    % First get the parent handle's desktop-based Matlab pixel position
    parentPos = [0,0,0,0];
    dX = 0;
    dY = 0;
    dW = 0;
    dH = 0;
    if ~isFigure(hParent)
        % Get the reguested component's pixel position
        parentPos = getPixelPos(hParent, 1);  % no true available in ML6
        % Axes position inaccuracy estimation
        deltaX = 3;
        deltaY = -1;
        
        % Fix for images
        if isImage(hParent)  % | (isAxes(hParent) & strcmpi(get(hParent,'YDir'),'reverse'))  %#ok ML6
            % Compensate for resized image axes
            hAxes = get(hParent,'Parent');
            if all(get(hAxes,'DataAspectRatio')==1)  % sanity check: this is the normal behavior
                % Note 18/4/2013: the following fails for non-square images
                %actualImgSize = min(parentPos(3:4)); dX = (parentPos(3) -
                %actualImgSize) / 2; dY = (parentPos(4) - actualImgSize) /
                %2; parentPos(3:4) = actualImgSize;
                % The following should work for all types of images
                actualImgSize = size(get(hParent,'CData'));
                dX = (parentPos(3) - min(parentPos(3),actualImgSize(2))) / 2;
                dY = (parentPos(4) - min(parentPos(4),actualImgSize(1))) / 2;
                parentPos(3:4) = actualImgSize([2,1]);
                %parentPos(3) = max(parentPos(3),actualImgSize(2));
                %parentPos(4) = max(parentPos(4),actualImgSize(1));
            end
            % Fix user-specified img positions (but not auto-inferred ones)
            if wasPositionGiven
                % In images, use data units rather than pixel units Reverse
                % the YDir
                ymax = max(get(hParent,'YData'));
                paramsStruct.position(2) = ymax - paramsStruct.position(2) - paramsStruct.position(4);
                % Note: it would be best to use hgconvertunits, but: ^^^^
                % (1) it fails on Matlab 6, and (2) it doesn't accept Data
                % units
                %paramsStruct.position = hgconvertunits(hFig,
                %paramsStruct.position, 'Data', 'pixel', hParent);  %
                %fails!
                xLims = get(hParent,'XData');
                yLims = get(hParent,'YData');
                xPixelsPerData = parentPos(3) / (diff(xLims) + 1);
                yPixelsPerData = parentPos(4) / (diff(yLims) + 1);
                paramsStruct.position(1) = round((paramsStruct.position(1)-xLims(1)) * xPixelsPerData);
                paramsStruct.position(2) = round((paramsStruct.position(2)-yLims(1)) * yPixelsPerData + 2*dY);
                paramsStruct.position(3) = round( paramsStruct.position(3) * xPixelsPerData);
                paramsStruct.position(4) = round( paramsStruct.position(4) * yPixelsPerData);
                % Axes position inaccuracy estimation
                if strcmpi(computer('arch'),'win64')
                    deltaX = 7;
                    deltaY = -7;
                else
                    deltaX = 3;
                    deltaY = -3;
                end
                
            else  % axes/image position was auto-infered (entire image)
                % Axes position inaccuracy estimation
                if strcmpi(computer('arch'),'win64')
                    deltaX = 6;
                    deltaY = -6;
                else
                    deltaX = 2;
                    deltaY = -2;
                end
                dW = -2*dX;
                dH = -2*dY;
            end
        end
        %hFig = ancestor(hParent,'figure');
        hParent = paramsStruct.hFigure;
    elseif paramsStruct.wasInteractive  % interactive figure rectangle
        % Compensate for 1px rbbox inaccuracies
        deltaX = 2;
        deltaY = -2;
    else  % non-interactive figure
        % Compensate 4px figure boundaries = difference betweeen
        % OuterPosition and Position
        deltaX = -1;
        deltaY = 1;
    end
    %disp(paramsStruct.position)  % for debugging
    
    % Now get the pixel position relative to the monitor
    figurePos = getPixelPos(hParent);
    desktopPos = figurePos + parentPos;
    % Now convert to Java-based pixels based on screen size Note: multiple
    % monitors are automatically handled correctly, since all ^^^^  Java
    % positions are relative to the main monitor's top-left corner
    javaX  = desktopPos(1) + paramsStruct.position(1) + deltaX + dX;
    javaY  = screenSize(4) - desktopPos(2) - paramsStruct.position(2) - paramsStruct.position(4) + deltaY + dY;
    width  = paramsStruct.position(3) + dW;
    height = paramsStruct.position(4) + dH;
    paramsStruct.position = round([javaX, javaY, width, height]);
    %paramsStruct.position
    % Ensure the figure is at the front so it can be screen-captured
    if isFigureValid
        figure(hParent);
        drawnow;
        pause(0.02);
    end
catch
    % Maybe root/desktop handle (root does not have a 'Position' prop so
    % getPixelPos croaks
    if isequal(double(hParent),0)  % =root/desktop handle;  handles case of hParent=[]
        javaX = paramsStruct.position(1) - 1;
        javaY = screenSize(4) - paramsStruct.position(2) - paramsStruct.position(4) - 1;
        paramsStruct.position = [javaX, javaY, paramsStruct.position(3:4)];
    end
end
end  % convertPos
function [positionRect, jFrameUsed, msgStr] = getInteractivePosition(hFig)
msgStr = '';
try
    % First try the invisible-figure approach, in order to enable rbbox
    % outside any existing figure boundaries
    f = figure('units','pixel','pos',[-100,-100,10,10],'HitTest','off');
    drawnow; pause(0.01);
    oldWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    jf = get(handle(f),'JavaFrame');
    warning(oldWarn);
    try
        jWindow = jf.fFigureClient.getWindow;
    catch
        try
            jWindow = jf.fHG1Client.getWindow;
        catch
            jWindow = jf.getFigurePanelContainer.getParent.getTopLevelAncestor;
        end
    end
    com.sun.awt.AWTUtilities.setWindowOpacity(jWindow,0.05);  %=nearly transparent (not fully so that mouse clicks are captured)
    jWindow.setMaximized(1);  % no true available in ML6
    jFrameUsed = 1;  % no true available in ML6
    msg = {'Mouse-click and drag a bounding rectangle for screen-capture ' ...
        ... %'or single-click any Matlab figure to capture the entire figure.' ...
        };
catch
    % Something failed, so revert to a simple rbbox on a visible figure
    try delete(f); drawnow; catch, end  %Cleanup...
    jFrameUsed = 0;  % no false available in ML6
    msg = {'Mouse-click within any Matlab figure and then', ...
        'drag a bounding rectangle for screen-capture,', ...
        'or single-click to capture the entire figure'};
end
uiwait(msgbox(msg,'ScreenCapture'));

k = waitforbuttonpress;  %#ok k is unused
%hFig = getCurrentFig; p1 = get(hFig,'CurrentPoint');
positionRect = rbbox;
%p2 = get(hFig,'CurrentPoint');
if jFrameUsed
    jFrameOrigin = getPixelPos(f);
    delete(f); drawnow;
    try
        figOrigin = getPixelPos(hFig);
    catch  % empty/invalid hFig handle
        figOrigin = [0,0,0,0];
    end
else
    if isempty(hFig)
        jFrameOrigin = getPixelPos(gcf);
    else
        jFrameOrigin = [0,0,0,0];
    end
    figOrigin = [0,0,0,0];
end
positionRect(1:2) = positionRect(1:2) + jFrameOrigin(1:2) - figOrigin(1:2);
if prod(positionRect(3:4)) > 0
    msgStr = sprintf('%dx%d area captured',positionRect(3),positionRect(4));
end
end  % getInteractivePosition
function hFig = getCurrentFig
oldState = get(0,'showHiddenHandles');
set(0,'showHiddenHandles','on');
hFig = get(0,'CurrentFigure');
set(0,'showHiddenHandles',oldState);
end  % getCurrentFig
function hObj = ancestor(hObj,type)
if ~isempty(hObj) & ishandle(hObj)  %#ok for Matlab 6 compatibility
    try
        hObj = get(hObj,'Ancestor');
    catch
        % never mind...
    end
    try
        %if ~isa(handle(hObj),type)  % this is best but always returns 0 in
        %Matlab 6! if ~isprop(hObj,'type') |
        %~strcmpi(get(hObj,'type'),type)  % no isprop() in ML6!
        try
            objType = get(hObj,'type');
        catch
            objType = '';
        end
        if ~strcmpi(objType,type)
            try
                parent = get(handle(hObj),'parent');
            catch
                parent = hObj.getParent;  % some objs have no 'Parent' prop, just this method...
            end
            if ~isempty(parent)  % empty parent means root ancestor, so exit
                hObj = ancestor(parent,type);
            end
        end
    catch
        % never mind...
    end
end
end  % ancestor
function pos = getPos(hObj,field,units)
% Matlab 6 did not have hgconvertunits so use the old way...
oldUnits = get(hObj,'units');
if strcmpi(oldUnits,units)  % don't modify units unless we must!
    pos = get(hObj,field);
else
    set(hObj,'units',units);
    pos = get(hObj,field);
    set(hObj,'units',oldUnits);
end
end  % getPos
function pos = getPixelPos(hObj,varargin)
persistent originalObj
try
    stk = dbstack;
    if ~strcmp(stk(2).name,'getPixelPos')
        originalObj = hObj;
    end
    if isFigure(hObj) %| isAxes(hObj)
        %try
        pos = getPos(hObj,'OuterPosition','pixels');
    else  %catch
        % getpixelposition is unvectorized unfortunately!
        pos = getpixelposition(hObj,varargin{:});
        % add the axes labels/ticks if relevant (plus a tiny margin to fix
        % 2px label/title inconsistencies)
        if isAxes(hObj) & ~isImage(originalObj)  %#ok ML6
            tightInsets = getPos(hObj,'TightInset','pixel');
            pos = pos + tightInsets.*[-1,-1,1,1] + [-1,1,1+tightInsets(1:2)];
        end
    end
catch
    try
        % Matlab 6 did not have getpixelposition nor hgconvertunits so use
        % the old way...
        pos = getPos(hObj,'Position','pixels');
    catch
        % Maybe the handle does not have a 'Position' prop (e.g.,
        % text/line/plot) - use its parent
        pos = getPixelPos(get(hObj,'parent'),varargin{:});
    end
end
% Handle the case of missing/invalid/empty HG handle
if isempty(pos)
    pos = [0,0,0,0];
end
end  % getPixelPos
function addToolbarButton(paramsStruct)
% Ensure we have a valid toolbar handle
hFig = ancestor(paramsStruct.toolbar,'figure');
if isempty(hFig)
    error('YMA:screencapture:badToolbar','the ''Toolbar'' parameter must contain a valid GUI handle');
end
set(hFig,'ToolBar','figure');
hToolbar = findall(hFig,'type','uitoolbar');
if isempty(hToolbar)
    error('YMA:screencapture:noToolbar','the ''Toolbar'' parameter must contain a figure handle possessing a valid toolbar');
end
hToolbar = hToolbar(1);  % just in case there are several toolbars... - use only the first
% Prepare the camera icon
icon = ['3333333333333333'; ...
    '3333333333333333'; ...
    '3333300000333333'; ...
    '3333065556033333'; ...
    '3000000000000033'; ...
    '3022222222222033'; ...
    '3022220002222033'; ...
    '3022203110222033'; ...
    '3022201110222033'; ...
    '3022204440222033'; ...
    '3022220002222033'; ...
    '3022222222222033'; ...
    '3000000000000033'; ...
    '3333333333333333'; ...
    '3333333333333333'; ...
    '3333333333333333'];
cm = [   0      0      0; ...  % black
    0   0.60      1; ...  % light blue
    0.53   0.53   0.53; ...  % light gray
    NaN    NaN    NaN; ...  % transparent
    0   0.73      0; ...  % light green
    0.27   0.27   0.27; ...  % gray
    0.13   0.13   0.13];     % dark gray
cdata = ind2rgb(uint8(icon-'0'),cm);
% If the button does not already exit
hButton = findall(hToolbar,'Tag','ScreenCaptureButton');
tooltip = 'Screen capture';
if ~isempty(paramsStruct.target)
    tooltip = [tooltip ' to ' paramsStruct.target];
end
if isempty(hButton)
    % Add the button with the icon to the figure's toolbar
    hButton = uipushtool(hToolbar, 'CData',cdata, 'Tag','ScreenCaptureButton', 'TooltipString',tooltip, 'ClickedCallback',['screencapture(''' paramsStruct.target ''')']);  %#ok unused
else
    % Otherwise, simply update the existing button
    set(hButton, 'CData',cdata, 'Tag','ScreenCaptureButton', 'TooltipString',tooltip, 'ClickedCallback',['screencapture(''' paramsStruct.target ''')']);
end
end  % addToolbarButton
function imgData = getScreenCaptureImageData(positionRect)
if isempty(positionRect) | all(positionRect==0) | positionRect(3)<=0 | positionRect(4)<=0  %#ok ML6
    imgData = [];
else
    % Use java.awt.Robot to take a screen-capture of the specified screen
    % area
    rect = java.awt.Rectangle(positionRect(1), positionRect(2), positionRect(3), positionRect(4));
    robot = java.awt.Robot;
    jImage = robot.createScreenCapture(rect);
    % Convert the resulting Java image to a Matlab image Adapted for a
    % much-improved performance from:
    % http://www.mathworks.com/support/solutions/data/1-2WPAYR.html
    h = jImage.getHeight;
    w = jImage.getWidth;
    %imgData = zeros([h,w,3],'uint8'); pixelsData =
    %uint8(jImage.getData.getPixels(0,0,w,h,[])); for i = 1 : h
    %    base = (i-1)*w*3+1; imgData(i,1:w,:) =
    %    deal(reshape(pixelsData(base:(base+3*w-1)),3,w)');
    %end
    % Performance further improved based on feedback from Urs Schwartz:
    %pixelsData =
    %reshape(typecast(jImage.getData.getDataStorage,'uint32'),w,h).';
    %imgData(:,:,3) = bitshift(bitand(pixelsData,256^1-1),-8*0);
    %imgData(:,:,2) = bitshift(bitand(pixelsData,256^2-1),-8*1);
    %imgData(:,:,1) = bitshift(bitand(pixelsData,256^3-1),-8*2);
    % Performance even further improved based on feedback from Jan Simon:
    pixelsData = reshape(typecast(jImage.getData.getDataStorage, 'uint8'), 4, w, h);
    imgData = cat(3, ...
        transpose(reshape(pixelsData(3, :, :), w, h)), ...
        transpose(reshape(pixelsData(2, :, :), w, h)), ...
        transpose(reshape(pixelsData(1, :, :), w, h)));
end
end  % getInteractivePosition
function redockFigureIfRelevant(paramsStruct)
if paramsStruct.wasDocked
    try
        set(paramsStruct.hFigure,'WindowStyle','docked');
        %drawnow;
    catch
        % never mind - ignore...
    end
end
end  % redockFigureIfRelevant
function imclipboard(imgData)
% Import necessary Java classes
import java.awt.Toolkit.*
import java.awt.image.BufferedImage
import java.awt.datatransfer.DataFlavor
% Add the necessary Java class (ImageSelection) to the Java classpath
if ~exist('ImageSelection', 'class')
    % Obtain the directory of the executable (or of the M-file if not
    % deployed)
    %javaaddpath(fileparts(which(mfilename)), '-end');
    if isdeployed % Stand-alone mode.
        [status, result] = system('path');  %#ok<ASGLU>
        MatLabFilePath = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    else % MATLAB mode.
        MatLabFilePath = fileparts(mfilename('fullpath'));
    end
    javaaddpath(MatLabFilePath, '-end');
end

% Get System Clipboard object (java.awt.Toolkit)
cb = getDefaultToolkit.getSystemClipboard;  % can't use () in ML6!

% Get image size
ht = size(imgData, 1);
wd = size(imgData, 2);

% Convert to Blue-Green-Red format
imgData = imgData(:, :, [3 2 1]);

% Convert to 3xWxH format
imgData = permute(imgData, [3, 2, 1]);

% Append Alpha data (not used)
imgData = cat(1, imgData, 255*ones(1, wd, ht, 'uint8'));

% Create image buffer
imBuffer = BufferedImage(wd, ht, BufferedImage.TYPE_INT_RGB);
imBuffer.setRGB(0, 0, wd, ht, typecast(imgData(:), 'int32'), 0, wd);

% Create ImageSelection object
%    % custom java class
imSelection = ImageSelection(imBuffer);

% Set clipboard content to the image
cb.setContents(imSelection, []);
end  %imclipboard
function flag = isFigure(hObj)
flag = isa(handle(hObj),'figure') | isa(hObj,'matlab.ui.Figure');
end  %isFigure
function flag = isAxes(hObj)
flag = isa(handle(hObj),'axes') | isa(hObj,'matlab.graphics.axis.Axes');
end  %isFigure
function flag = isImage(hObj)
flag = isa(handle(hObj),'image') | isa(hObj,'matlab.graphics.primitive.Image');
end  %isFigure









% pop_interp() - interpolate data channels
%
% Usage: EEGOUT = pop_interp(EEG, badchans, method);
%
% Inputs:
%     EEG      - EEGLAB dataset badchans - [integer array] indices of
%     channels to interpolate.
%                For instance, these channels might be bad. [chanlocs
%                structure] channel location structure containing either
%                locations of channels to interpolate or a full channel
%                structure (missing channels in the current dataset are
%                interpolated).
%     method   - [string] method used for interpolation (default is
%     'spherical').
%                'invdist'/'v4' uses inverse distance on the scalp
%                'spherical' uses superfast spherical interpolation.
%                'spacetime' uses griddata3 to interpolate both in space
%                and time (very slow and cannot be interrupted).
% Output:
%     EEGOUT   - data set with bad electrode data replaced by
%                interpolated data
%
% Author: Arnaud Delorme, CERCO, CNRS, 2009-

% Copyright (C) Arnaud Delorme, CERCO, 2009, arno@salk.edu
%
% This file is part of EEGLAB, see http://www.eeglab.org for the
% documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function [EEG com] = pop_interpMG(EEG, bad_elec, method)

com = '';
if nargin < 1
    help pop_interp;
    return;
end

if nargin < 2
    disp('Warning: interpolation can be done on the fly in studies');
    disp('         this function will actually create channels in the dataset');
    disp('Warning: do not interpolate channels before running ICA');
    disp('You may define channel location to interpolate in the channel');
    disp('editor and declare such channels as non-data channels');
    
    enablenondat = 'off';
    if isfield(EEG.chaninfo, 'nodatchans')
        if ~isempty(EEG.chaninfo.nodatchans)
            enablenondat = 'on';
        end
    end
    
    uilist = { { 'Style' 'text' 'string' 'What channel(s) do you want to interpolate' 'fontweight' 'bold' } ...
        { 'style' 'text' 'string' 'none selected' 'tag' 'chanlist' } ...
        { 'style' 'pushbutton' 'string' 'Select from removed channels' 'callback' 'pop_interp(''nondatchan'',gcbf);' 'enable' enablenondat } ...
        { 'style' 'pushbutton' 'string' 'Select from data channels'    'callback' 'pop_interp(''datchan'',gcbf);' } ...
        { 'style' 'pushbutton' 'string' 'Use specific channels of other dataset' 'callback' 'pop_interp(''selectchan'',gcbf);'} ...
        { 'style' 'pushbutton' 'string' 'Use all channels from other dataset' 'callback' 'pop_interp(''uselist'',gcbf);'} ...
        { } ...
        { 'style' 'text'  'string' 'Interpolation method'} ...
        { 'style' 'popupmenu'  'string' 'Spherical|Planar (slow)'  'tag' 'method' } ...
        };
    
    geom = { 1 1 1 1 1 1 1 [1.1 1] };
    [res userdata tmp restag ] = inputgui( 'uilist', uilist, 'title', 'Interpolate channel(s) -- pop_interp()', 'geometry', geom, 'helpcom', 'pophelp(''pop_interp'')');
    if isempty(res) || isempty(userdata), return; end
    
    if restag.method == 1
        method = 'spherical';
    else method = 'invdist';
    end
    bad_elec = userdata.chans;
    
    com = sprintf('EEG = pop_interp(EEG, %s, ''%s'');', userdata.chanstr, method);
    if ~isempty(findstr('nodatchans', userdata.chanstr))
        eval( [ userdata.chanstr '=[];' ] );
    end
    
elseif ischar(EEG)
    command = EEG;
    clear EEG;
    fig = bad_elec;
    userdata = get(fig, 'userdata');
    
    if strcmpi(command, 'nondatchan')
        global EEG;
        tmpchaninfo = EEG.chaninfo;
        [chanlisttmp chanliststr] = pop_chansel( { tmpchaninfo.nodatchans.labels } );
        if ~isempty(chanlisttmp),
            userdata.chans   = EEG.chaninfo.nodatchans(chanlisttmp);
            userdata.chanstr = [ 'EEG.chaninfo.nodatchans([' num2str(chanlisttmp) '])' ];
            set(fig, 'userdata', userdata);
            set(findobj(fig, 'tag', 'chanlist'), 'string', chanliststr);
        end
    elseif strcmpi(command, 'datchan')
        global EEG;
        tmpchaninfo = EEG.chanlocs;
        [chanlisttmp chanliststr] = pop_chansel( { tmpchaninfo.labels } );
        if ~isempty(chanlisttmp),
            userdata.chans   = chanlisttmp;
            userdata.chanstr = [ '[' num2str(chanlisttmp) ']' ];
            set(fig, 'userdata', userdata);
            set(findobj(fig, 'tag', 'chanlist'), 'string', chanliststr);
        end
    else
        global ALLEEG EEG;
        tmpanswer = inputdlg2({ 'Dataset index' }, 'Choose dataset', 1, { '' });
        if ~isempty(tmpanswer),
            tmpanswernum = round(str2num(tmpanswer{1}));
            if ~isempty(tmpanswernum),
                if tmpanswernum > 0 && tmpanswernum <= length(ALLEEG),
                    TMPEEG = ALLEEG(tmpanswernum);
                    
                    tmpchans1 = TMPEEG.chanlocs;
                    if strcmpi(command, 'selectchan')
                        chanlist = pop_chansel( { tmpchans1.labels } );
                    else
                        chanlist = 1:length(TMPEEG.chanlocs); % use all channels
                    end
                    
                    % look at what new channels are selected
                    tmpchans2 = EEG.chanlocs;
                    [tmpchanlist chaninds] = setdiff_bc( { tmpchans1(chanlist).labels }, { tmpchans2.labels } );
                    if ~isempty(tmpchanlist),
                        if length(chanlist) == length(TMPEEG.chanlocs)
                            userdata.chans   = TMPEEG.chanlocs;
                            userdata.chanstr = [ 'ALLEEG(' tmpanswer{1} ').chanlocs' ];
                        else
                            userdata.chans   = TMPEEG.chanlocs(chanlist(sort(chaninds)));
                            userdata.chanstr = [ 'ALLEEG(' tmpanswer{1} ').chanlocs([' num2str(chanlist(sort(chaninds))) '])' ];
                        end
                        set(fig, 'userdata', userdata);
                        tmpchanlist(2,:) = { ' ' };
                        set(findobj(gcbf, 'tag', 'chanlist'), 'string', [ tmpchanlist{:} ]);
                    else
                        warndlg2('No new channels selected');
                    end
                else
                    warndlg2('Wrong index');
                end
            end
        end
    end
    return;
end

EEG = eeg_interpMG(EEG, bad_elec, method);
end


% eeg_interp() - interpolate data channels
%
% Usage: EEGOUT = eeg_interp(EEG, badchans, method);
%
% Inputs:
%     EEG      - EEGLAB dataset badchans - [integer array] indices of
%     channels to interpolate.
%                For instance, these channels might be bad. [chanlocs
%                structure] channel location structure containing either
%                locations of channels to interpolate or a full channel
%                structure (missing channels in the current dataset are
%                interpolated).
%     method   - [string] method used for interpolation (default is
%     'spherical').
%                'invdist'/'v4' uses inverse distance on the scalp
%                'spherical' uses superfast spherical interpolation.
%                'spacetime' uses griddata3 to interpolate both in space
%                and time (very slow and cannot be interrupted).
% Output:
%     EEGOUT   - data set with bad electrode data replaced by
%                interpolated data
%
% Author: Arnaud Delorme, CERCO, CNRS, Mai 2006-

% Copyright (C) Arnaud Delorme, CERCO, 2006, arno@salk.edu
%
% This file is part of EEGLAB, see http://www.eeglab.org for the
% documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function EEG = eeg_interpMG(ORIEEG, bad_elec, method)

if nargin < 2
    help eeg_interp;
    return;
end
EEG = ORIEEG;

if nargin < 3
    disp('Using spherical interpolation');
    method = 'spherical';
end

% check channel structure
tmplocs = ORIEEG.chanlocs;
if isempty(tmplocs) || isempty([tmplocs.X])
    error('Interpolation require channel location');
end

if isstruct(bad_elec)
    
    % add missing channels in interpolation structure
    % -----------------------------------------------
    lab1 = { bad_elec.labels };
    tmpchanlocs = EEG.chanlocs;
    lab2 = { tmpchanlocs.labels };
    [tmp tmpchan] = setdiff_bc( lab2, lab1);
    tmpchan = sort(tmpchan);
    
    % From 'bad_elec' using only fields present on EEG.chanlocs
    fields = fieldnames(bad_elec);
    [tmp, indx1] = setxor(fields,fieldnames(EEG.chanlocs)); clear tmp;
    if ~isempty(indx1)
        bad_elec = rmfield(bad_elec,fields(indx1));
        fields = fieldnames(bad_elec);
    end
    
    if ~isempty(tmpchan)
        newchanlocs = [];
        for index = 1:length(fields)
            if isfield(bad_elec, fields{index})
                for cind = 1:length(tmpchan)
                    fieldval = getfield( EEG.chanlocs, { tmpchan(cind) },  fields{index});
                    newchanlocs = setfield(newchanlocs, { cind }, fields{index}, fieldval);
                end
            end
        end
        newchanlocs(end+1:end+length(bad_elec)) = bad_elec;
        bad_elec = newchanlocs;
    end
    if length(EEG.chanlocs) == length(bad_elec), return; end
    
    lab1 = { bad_elec.labels };
    tmpchanlocs = EEG.chanlocs;
    lab2 = { tmpchanlocs.labels };
    [tmp badchans] = setdiff_bc( lab1, lab2);
    %fprintf('Interpolating %d channels...\n', length(badchans));
    if length(badchans) == 0, return; end
    goodchans      = sort(setdiff(1:length(bad_elec), badchans));
    
    % re-order good channels ----------------------
    [tmp1 tmp2 neworder] = intersect_bc( lab1, lab2 );
    [tmp1 ordertmp2] = sort(tmp2);
    neworder = neworder(ordertmp2);
    EEG.data = EEG.data(neworder, :, :);
    
    % looking at channels for ICA ---------------------------
    %[tmp sorti] = sort(neworder);
    %{ EEG.chanlocs(EEG.icachansind).labels; bad_elec(goodchans(sorti(EEG.icachansind))).labels }
    
    % update EEG dataset (add blank channels)
    % ---------------------------------------
    if ~isempty(EEG.icasphere)
        
        [tmp sorti] = sort(neworder);
        EEG.icachansind = sorti(EEG.icachansind);
        EEG.icachansind = goodchans(EEG.icachansind);
        EEG.chaninfo.icachansind = EEG.icachansind;
        
        % TESTING SORTING
        %icachansind = [ 3 4 5 7 8] data = round(rand(8,10)*10) neworder =
        %shuffle(1:8) data2 = data(neworder,:) icachansind2 =
        %sorti(icachansind) data(icachansind,:) data2(icachansind2,:)
    end
    % { EEG.chanlocs(neworder).labels; bad_elec(sort(goodchans)).labels }
    %tmpdata                  = zeros(length(bad_elec), size(EEG.data,2),
    %size(EEG.data,3)); tmpdata(goodchans, :, :) = EEG.data;
    
    % looking at the data -------------------
    %tmp1 = mattocell(EEG.data(sorti,1)); tmp2 =
    %mattocell(tmpdata(goodchans,1));
    %{ EEG.chanlocs.labels; bad_elec(goodchans).labels; tmp1{:}; tmp2{:} }
    %EEG.data      = tmpdata;
    
    EEG.chanlocs  = bad_elec;
    
else
    badchans  = bad_elec;
    goodchans = setdiff_bc(1:EEG.nbchan, badchans);
    oldelocs  = EEG.chanlocs;
    EEG       = pop_selectMG(EEG, 'nochannel', badchans);
    EEG.chanlocs = oldelocs;
    %    disp('Interpolating missing channels...');
end

% find non-empty good channels ----------------------------
origoodchans = goodchans;
chanlocs     = EEG.chanlocs;
nonemptychans = find(~cellfun('isempty', { chanlocs.theta }));
[tmp indgood ] = intersect_bc(goodchans, nonemptychans);
goodchans = goodchans( sort(indgood) );
datachans = getdatachans(goodchans,badchans);
badchans  = intersect_bc(badchans, nonemptychans);
if isempty(badchans), return; end

% scan data points ----------------
if strcmpi(method, 'spherical')
    % get theta, rad of electrodes ----------------------------
    tmpgoodlocs = EEG.chanlocs(goodchans);
    xelec = [ tmpgoodlocs.X ];
    yelec = [ tmpgoodlocs.Y ];
    zelec = [ tmpgoodlocs.Z ];
    rad = sqrt(xelec.^2+yelec.^2+zelec.^2); %MG: Finds raduis (Sphere) of all channels
    xelec = xelec./rad;
    yelec = yelec./rad;
    zelec = zelec./rad;
    tmpbadlocs = EEG.chanlocs(badchans);
    xbad = [ tmpbadlocs.X ];
    ybad = [ tmpbadlocs.Y ];
    zbad = [ tmpbadlocs.Z ];
    rad = sqrt(xbad.^2+ybad.^2+zbad.^2); %MG: Finds raduis (Sphere) of specfic channels
    %MG: So you back here. Hi :) -2016
    xbad = xbad./rad;
    ybad = ybad./rad;
    zbad = zbad./rad;
    
    EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts*EEG.trials);
    %[tmp1 tmp2 tmp3 tmpchans] = spheric_spline_old( xelec, yelec, zelec,
    %EEG.data(goodchans,1)); max(tmpchans(:,1)), std(tmpchans(:,1)), [tmp1
    %tmp2 tmp3 EEG.data(badchans,:)] = spheric_spline( xelec, yelec, zelec,
    %xbad, ybad, zbad, EEG.data(goodchans,:));
    [tmp1 tmp2 tmp3 badchansdata] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, EEG.data(datachans,:));
    %max(EEG.data(goodchans,1)), std(EEG.data(goodchans,1))
    %max(EEG.data(badchans,1)), std(EEG.data(badchans,1))
    EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, EEG.trials);
elseif strcmpi(method, 'spacetime') % 3D interpolation, works but x10 times slower
    disp('Warning: if processing epoch data, epoch boundary are ignored...');
    disp('3-D interpolation, this can take a long (long) time...');
    tmpgoodlocs = EEG.chanlocs(goodchans);
    tmpbadlocs = EEG.chanlocs(badchans);
    [xbad ,ybad]  = pol2cart([tmpbadlocs.theta],[tmpbadlocs.radius]);
    [xgood,ygood] = pol2cart([tmpgoodlocs.theta],[tmpgoodlocs.radius]);
    pnts = size(EEG.data,2)*size(EEG.data,3);
    zgood = [1:pnts];
    zgood = repmat(zgood, [length(xgood) 1]);
    zgood = reshape(zgood,prod(size(zgood)),1);
    xgood = repmat(xgood, [1 pnts]); xgood = reshape(xgood,prod(size(xgood)),1);
    ygood = repmat(ygood, [1 pnts]); ygood = reshape(ygood,prod(size(ygood)),1);
    tmpdata = reshape(EEG.data, prod(size(EEG.data)),1);
    zbad = 1:pnts;
    zbad = repmat(zbad, [length(xbad) 1]);
    zbad = reshape(zbad,prod(size(zbad)),1);
    xbad = repmat(xbad, [1 pnts]); xbad = reshape(xbad,prod(size(xbad)),1);
    ybad = repmat(ybad, [1 pnts]); ybad = reshape(ybad,prod(size(ybad)),1);
    badchansdata = griddata3(ygood, xgood, zgood, tmpdata,...
        ybad, xbad, zbad, 'nearest'); % interpolate data
else
    % get theta, rad of electrodes ----------------------------
    tmpchanlocs = EEG.chanlocs;
    [xbad ,ybad]  = pol2cart([tmpchanlocs( badchans).theta],[tmpchanlocs( badchans).radius]);
    [xgood,ygood] = pol2cart([tmpchanlocs(goodchans).theta],[tmpchanlocs(goodchans).radius]);
    
    fprintf('Points (/%d):', size(EEG.data,2)*size(EEG.data,3));
    badchansdata = zeros(length(badchans), size(EEG.data,2)*size(EEG.data,3));
    
    for t=1:(size(EEG.data,2)*size(EEG.data,3)) % scan data points
        if mod(t,100) == 0, fprintf('%d ', t); end
        if mod(t,1000) == 0, fprintf('\n'); end;
        
        %for c = 1:length(badchans)
        %   [h EEG.data(badchans(c),t)]=
        %   topoplot(EEG.data(goodchans,t),EEG.chanlocs(goodchans),'noplot',
        %   ...
        %        [EEG.chanlocs( badchans(c)).radius EEG.chanlocs(
        %        badchans(c)).theta]);
        %end
        tmpdata = reshape(EEG.data, size(EEG.data,1), size(EEG.data,2)*size(EEG.data,3) );
        if strcmpi(method, 'invdist'), method = 'v4'; end
        [Xi,Yi,badchansdata(:,t)] = griddata(ygood, xgood , double(tmpdata(datachans,t)'),...
            ybad, xbad, method); % interpolate data
    end
    fprintf('\n');
end

tmpdata               = zeros(length(bad_elec), EEG.pnts, EEG.trials);
tmpdata(origoodchans, :,:) = EEG.data;
%if input data are epoched reshape badchansdata for Octave compatibility...
if length(size(tmpdata))==3
    badchansdata = reshape(badchansdata,length(badchans),size(tmpdata,2),size(tmpdata,3));
end
tmpdata(badchans,:,:) = badchansdata;
EEG.data = tmpdata;
EEG.nbchan = size(EEG.data,1);
EEG = eeg_checksetMG(EEG);
end
% get data channels -----------------
function datachans = getdatachans(goodchans, badchans);
datachans = goodchans;
badchans  = sort(badchans);
for index = length(badchans):-1:1
    datachans(find(datachans > badchans(index))) = datachans(find(datachans > badchans(index)))-1;
end
end
% ----------------- spherical splines -----------------
function [x, y, z, Res] = spheric_spline_old( xelec, yelec, zelec, values);

SPHERERES = 20;
[x,y,z] = sphere(SPHERERES);
x(1:(length(x)-1)/2,:) = []; x = [ x(:)' ];
y(1:(length(y)-1)/2,:) = []; y = [ y(:)' ];
z(1:(length(z)-1)/2,:) = []; z = [ z(:)' ];

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(x,y,z,xelec,yelec,zelec);

% equations are Gelec*C + C0  = Potential (C unknow) Sum(c_i) = 0 so
%             [c_1]
%      *      [c_2]
%             [c_ ]
%    xelec    [c_n]
% [x x x x x]         [potential_1] [x x x x x]         [potential_ ] [x x
% x x x]       = [potential_ ] [x x x x x]         [potential_4] [1 1 1 1
% 1]         [0]

% compute solution for parameters C ---------------------------------
meanvalues = mean(values);
values = values - meanvalues; % make mean zero
C = pinv([Gelec;ones(1,length(Gelec))]) * [values(:);0];

% apply results -------------
Res = zeros(1,size(Gsph,1));
for j = 1:size(Gsph,1)
    Res(j) = sum(C .* Gsph(j,:)');
end
Res = Res + meanvalues;
Res = reshape(Res, length(x(:)),1);
end


function [xbad, ybad, zbad, allres] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, values);

newchans = length(xbad);
numpoints = size(values,2);

%SPHERERES = 20; [x,y,z] = sphere(SPHERERES); x(1:(length(x)-1)/2,:) = [];
%xbad = [ x(:)']; y(1:(length(x)-1)/2,:) = []; ybad = [ y(:)'];
%z(1:(length(x)-1)/2,:) = []; zbad = [ z(:)'];

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(xbad,ybad,zbad,xelec,yelec,zelec);

% compute solution for parameters C ---------------------------------
meanvalues = mean(values);
values = values - repmat(meanvalues, [size(values,1) 1]); % make mean zero

values = [values;zeros(1,numpoints)];
C = pinv([Gelec;ones(1,length(Gelec))]) * values;
clear values;
allres = zeros(newchans, numpoints);

% apply results -------------
for j = 1:size(Gsph,1)
    allres(j,:) = sum(C .* repmat(Gsph(j,:)', [1 size(C,2)]));
end
allres = allres + repmat(meanvalues, [size(allres,1) 1]);
end


% compute G function ------------------
function g = computeg(x,y,z,xelec,yelec,zelec)

unitmat = ones(length(x(:)),length(xelec));
EI = unitmat - sqrt((repmat(x(:),1,length(xelec)) - repmat(xelec,length(x(:)),1)).^2 +...
    (repmat(y(:),1,length(xelec)) - repmat(yelec,length(x(:)),1)).^2 +...
    (repmat(z(:),1,length(xelec)) - repmat(zelec,length(x(:)),1)).^2);

g = zeros(length(x(:)),length(xelec));
%dsafds
m = 4; % 3 is linear, 4 is best according to Perrin's curve
for n = 1:7
    if ismatlab
        L = legendre(n,EI);
    else % Octave legendre function cannot process 2-D matrices
        for icol = 1:size(EI,2)
            tmpL = legendre(n,EI(:,icol));
            if icol == 1, L = zeros([ size(tmpL) size(EI,2)]); end
            L(:,:,icol) = tmpL;
        end
    end
    g = g + ((2*n+1)/(n^m*(n+1)^m))*squeeze(L(1,:,:));
end
g = g/(4*pi);
end












% pop_select() - given an input EEG dataset structure, output a new EEG
% data structure
%                retaining and/or excluding specified time/latency, data
%                point, channel, and/or epoch range(s).
% Usage:
%   >> OUTEEG = pop_select(INEEG, 'key1', value1, 'key2', value2 ...);
%
% Graphic interface:
%   "Time range" - [edit box] RETAIN only the indicated epoch latency or
%   continuous data
%                  time range: [low high] in ms, inclusive. For continuous
%                  data, several time ranges may be specified, separated by
%                  semicolons. Example: "5 10; 12 EEG.xmax" will retain the
%                  indicated stretches of continuous data, and remove data
%                  portions outside the indicated ranges, e.g. from 0 s to
%                  5 s and from 10 s to 12 s. Command line equivalent:
%                  'time' (or 'notime' - see below)
%   "Time range" - [checkbox] EXCLUDE the indicated latency range(s) from
%   the data.
%                  For epoched data, it is not possible to remove a range
%                  of latencies from the middle of the epoch, so either the
%                  low and/or the high values in the specified latency
%                  range (see above) must be at an epoch boundary
%                  (EEG.xmin, EEGxmax).  Command line equivalent: [if
%                  checked] 'notime'
%   "Point range" - [edit box] RETAIN the indicated data point range(s).
%                  Same options as for the "Time range" features (above).
%                  Command line equivalent: 'point' (or 'nopoint' - see
%                  below).
%   "Point range" - [checkbox] EXCLUDE the indicated point range(s).
%                  Command line equivalent: [if checked] 'nopoint'
%   "Epoch range" - [edit box] RETAIN the indicated data epoch indices in
%   the dataset.
%                  This checkbox is only visible for epoched datasets.
%                  Command line equivalent: 'trial' (or 'notrial' - see
%                  below)
%   "Epoch range" - [checkbox] EXCLUDE the specified data epochs.
%                   Command line equivalent: [if checked] 'notrial'
%   "Channel range" - [edit box] RETAIN the indicated vector of data
%   channels
%                  Command line equivalent: 'channel' (or 'nochannel' - see
%                  below)
%   "Channel range" - [checkbox] EXCLUDE the indicated channels.
%                  Command line equivalent: [if checked] 'nochannel'
%   "..." - [button] select channels by name. "Scroll dataset" - [button]
%   call the eegplot() function to scroll the
%                  channel activities in a new window for visual
%                  inspection. Commandline equivalent: eegplot() - see its
%                  help for details.
% Inputs:
%   INEEG         - input EEG dataset structure
%
% Optional inputs
%   'time'        - [min max] in seconds. Epoch latency or continuous data
%   time range
%                   to retain in the new dataset, (Note: not ms, as in the
%                   GUI text entry above). For continuous data (only),
%                   several time ranges can be specified, separated by
%                   semicolons. Example: "5 10; 12 EEG.xmax" will retain
%                   the indicated times ranges, removing data  outside the
%                   indicated ranges e.g. here from 0 to 5 s and from 10 s
%                   to 12 s. (See also, 'notime')
%   'notime'      - [min max] in seconds. Epoch latency or continuous
%   dataset time range
%                   to exclude from the new dataset. For continuous data,
%                   may be [min1 max1; min2 max2; ...] to exclude several
%                   time ranges. For epoched data, the latency range must
%                   include an epoch boundary, as latency ranges in the
%                   middle of epochs cannot be removed from epoched data.
%   'point'       - [min max] epoch or continuous data point range to
%   retain in the new
%                   dataset. For continuous datasets, this may be [min1
%                   max1; min2 max2; ...] to retain several point ranges.
%                   (Notes: If both 'point'/'nopoint' and 'time' | 'notime'
%                   are specified, the 'point' limit values take
%                   precedence. The 'point' argument was originally a point
%                   vector, now deprecated).
%   'nopoint'     - [min max] epoch or continuous data point range to
%   exclude in the new dataset.
%                   For epoched data, the point range must include either
%                   the first (0) or the last point (EEG.pnts), as a
%                   central point range cannot be removed.
%   'trial'       - array of trial indices to retain in the new dataset
%   'notrial'     - array of trial indices to exclude from the new dataset
%   'sorttrial'   - ['on'|'off'] sort trial indices before extracting them
%   (default: 'on'). 'channel'     - vector of channel indices to retain in
%   the new
%                   dataset. Can also be a cell array of channel names.
%   'nochannel'   - vector of channel indices to exclude from the new
%                   dataset. Can also be a cell array of channel names.
%
% Outputs:
%   OUTEEG        - new EEG dataset structure
%
% Note: This function performs a conjunction (AND) of all its optional
% inputs.
%       Using negative counterparts of all options, any logical combination
%       is possible.
%
% Author: Arnaud Delorme, CNL/Salk Institute, 2001; SCCN/INC/UCSD, 2002-
%
% see also: eeglab()

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This file is part of EEGLAB, see http://www.eeglab.org for the
% documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% 01-25-02 reformated help & license -ad 01-26-02 changed the format for
% events and trial conditions -ad 02-04-02 changed display format and allow
% for negation of inputs -ad 02-17-02 removed the event removal -ad
% 03-17-02 added channel info subsets selection -ad 03-21-02 added event
% latency recalculation -ad

function [EEG, com] = pop_selectMG( EEG, varargin);

com = '';
if nargin < 1
    help pop_select;
    return;
end
if isempty(EEG(1).data)
    disp('Pop_select error: cannot process empty dataset'); return;
end;

if nargin < 2
    geometry = { [1 1 1] [1 1 0.25 0.23 0.51] [1 1 0.25 0.23 0.51] [1 1 0.25 0.23 0.51] ...
        [1 1 0.25 0.23 0.51] [1] [1 1 1]};
    uilist = { ...
        { 'Style', 'text', 'string', 'Select data in:', 'fontweight', 'bold'  }, ...
        { 'Style', 'text', 'string', 'Input desired range', 'fontweight', 'bold'  }, ...
        { 'Style', 'text', 'string', 'on->remove these', 'fontweight', 'bold'  }, ...
        { 'Style', 'text', 'string', 'Time range [min max] (s)', 'fontangle', fastif(length(EEG)>1, 'italic', 'normal') }, ...
        { 'Style', 'edit', 'string', '', 'enable', fastif(length(EEG)>1, 'off', 'on') }, ...
        { }, { 'Style', 'checkbox', 'string', '    ', 'enable', fastif(length(EEG)>1, 'off', 'on') },{ }, ...
        ...
        { 'Style', 'text', 'string', 'Point range (ex: [1 10])', 'fontangle', fastif(length(EEG)>1, 'italic', 'normal') }, ...
        { 'Style', 'edit', 'string', '', 'enable', fastif(length(EEG)>1, 'off', 'on') }, ...
        { }, { 'Style', 'checkbox', 'string', '    ', 'enable', fastif(length(EEG)>1, 'off', 'on') },{ }, ...
        ...
        { 'Style', 'text', 'string', 'Epoch range (ex: 3:2:10)', 'fontangle', fastif(length(EEG)>1, 'italic', 'normal') }, ...
        { 'Style', 'edit', 'string', '', 'enable', fastif(length(EEG)>1, 'off', 'on') }, ...
        { }, { 'Style', 'checkbox', 'string', '    ', 'enable', fastif(length(EEG)>1, 'off', 'on') },{ }, ...
        ...
        { 'Style', 'text', 'string', 'Channel range' }, ...
        { 'Style', 'edit', 'string', '', 'tag', 'chans' }, ...
        { }, { 'Style', 'checkbox', 'string', '    ' }, ...
        { 'style' 'pushbutton' 'string'  '...', 'enable' fastif(isempty(EEG.chanlocs), 'off', 'on') ...
        'callback' 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on''); set(findobj(gcbf, ''tag'', ''chans''), ''string'',tmpval); clear tmp tmpchanlocs tmpval' }, ...
        { }, { }, { 'Style', 'pushbutton', 'string', 'Scroll dataset', 'enable', fastif(length(EEG)>1, 'off', 'on'), 'callback', ...
        'eegplot(EEG.data, ''srate'', EEG.srate, ''winlength'', 5, ''limits'', [EEG.xmin EEG.xmax]*1000, ''position'', [100 300 800 500], ''xgrid'', ''off'', ''eloc_file'', EEG.chanlocs);' } {}};
    results = inputgui( geometry, uilist, 'pophelp(''pop_select'');', 'Select data -- pop_select()' );
    if length(results) == 0, return; end
    
    
    % decode inputs -------------
    args = {};
    if ~isempty( results{1} )
        if ~results{2}, args = { args{:}, 'time', eval( [ '[' results{1} ']' ] ) };
        else            args = { args{:}, 'notime', eval( [ '[' results{1} ']' ] ) }; end
    end
    
    if ~isempty( results{3} )
        if ~results{4}, args = { args{:}, 'point', eval( [ '[' results{3} ']' ] ) };
        else            args = { args{:}, 'nopoint', eval( [ '[' results{3} ']' ] ) }; end
    end
    
    if ~isempty( results{5} )
        if ~results{6}, args = { args{:}, 'trial', eval( [ '[' results{5} ']' ] ) };
        else            args = { args{:}, 'notrial', eval( [ '[' results{5} ']' ] ) }; end
    end
    
    if ~isempty( results{7} )
        [ chaninds chanlist ] = eeg_decodechan(EEG.chanlocs, results{7});
        if isempty(chanlist), chanlist = chaninds; end
        if ~results{8}, args = { args{:}, 'channel'  , chanlist };
        else            args = { args{:}, 'nochannel', chanlist }; end
    end
    
else
    args = varargin;
end

%----------------------------AMICA---------------------------------
if isfield(EEG.etc,'amica') && isfield(EEG.etc.amica,'prob_added')
    for index = 1:2:length(args)
        if strcmpi(args{index}, 'channel')
            args{index+1} = [ args{index+1} EEG.nbchan-(0:2*EEG.etc.amica.num_models-1)];
            
        end
        
        
    end
end
%--------------------------------------------------------------------

% process multiple datasets -------------------------
if length(EEG) > 1
    [ EEG com ] = eeg_eval( 'pop_select', EEG, 'warning', 'on', 'params', args);
    return;
end

if isempty(EEG.chanlocs), chanlist = [1:EEG.nbchan];
else                      chanlocs = EEG.chanlocs; chanlist = { chanlocs.labels };
end
g = finputcheck(args, { 'time'    'real'      []         []; ...
    'notime'  'real'      []         []; ...
    'trial'   'integer'   []         [1:EEG.trials]; ...
    'notrial' 'integer'   []         []; ...
    'point'   'integer'   []         []; ...
    'nopoint' 'integer'   []         []; ...
    'channel'   { 'integer','cell' }  []  chanlist;
    'nochannel' { 'integer','cell' }   []  [];
    'trialcond'   'integer'   []         []; ...
    'notrialcond' 'integer'   []         []; ...
    'sort'        'integer'   []         []; ...
    'sorttrial'   'string'    { 'on','off' } 'on' }, 'pop_select');
if ischar(g), error(g); end
if ~isempty(g.sort)
    if g.sort, g.sorttrial = 'on';
    else       g.sorttrial = 'off';
    end
end
if strcmpi(g.sorttrial, 'on')
    g.trial = sort(setdiff( g.trial, g.notrial ));
    if isempty(g.trial), error('Error: dataset is empty'); end
else
    g.trial(ismember(g.trial,g.notrial)) = [];
    % still warn about & remove duplicate trials (may be removed in the
    % future)
    [p,q] = unique_bc(g.trial);
    if length(p) ~= length(g.trial)
        disp('Warning: trial selection contained duplicated elements, which were removed.');
    end
    g.trial = g.trial(sort(q));
end

if isempty(g.channel) && ~iscell(g.nochannel) && ~iscell(chanlist)
    g.channel = [1:EEG.nbchan];
end

if iscell(g.channel) && ~iscell(g.nochannel) && ~isempty(EEG.chanlocs)
    noChannelAsCell = {};
    for nochanId = 1:length(g.nochannel)
        noChannelAsCell{nochanId} = EEG.chanlocs(g.nochannel(nochanId)).labels;
    end
    g.nochannel =   noChannelAsCell;
end

if strcmpi(g.sorttrial, 'on')
    if iscell(g.channel)
        g.channel = sort(setdiff( lower(g.channel), lower(g.nochannel) ));
    else g.channel = sort(setdiff( g.channel, g.nochannel ));
    end
else
    g.channel(ismember(lower(g.channel),lower(g.nochannel))) = [];
    % still warn about & remove duplicate channels (may be removed in the
    % future)
    [p,q] = unique_bc(g.channel);
    if length(p) ~= length(g.channel)
        disp('Warning: channel selection contained duplicated elements, which were removed.');
    end
    g.channel = g.channel(sort(q));
end

if ~isempty(EEG.chanlocs)
    if strcmpi(g.sorttrial, 'on')
        g.channel = eeg_decodechan(EEG.chanlocs, g.channel);
    else
        % we have to protect the channel order against changes by
        % eeg_decodechan
        if iscell(g.channel)
            % translate channel names into indices
            [inds,names] = eeg_decodechan(EEG.chanlocs, g.channel);
            % and sort the indices back into the original order of channel
            % names
            [tmp,I] = ismember_bc(lower(g.channel),lower(names));
            g.channel = inds(I);
        end
    end
end

if ~isempty(g.time) && (g.time(1) < EEG.xmin*1000) && (g.time(2) > EEG.xmax*1000)
    error('Wrong time range');
end
if min(g.trial) < 1 || max( g.trial ) > EEG.trials
    error('Wrong trial range');
end
if ~isempty(g.channel)
    if min(double(g.channel)) < 1 || max(double(g.channel)) > EEG.nbchan
        error('Wrong channel range');
    end
end

if size(g.point,2) > 2,
    g.point = [g.point(1) g.point(end)];
    disp('Warning: vector format for point range is deprecated');
end
if size(g.nopoint,2) > 2,
    g.nopoint = [g.nopoint(1) g.nopoint(end)];
    disp('Warning: vector format for point range is deprecated');
end
if ~isempty( g.point )
    g.time = zeros(size(g.point));
    for index = 1:length(g.point(:))
        g.time(index) = eeg_point2lat(g.point(index), 1, EEG.srate, [EEG.xmin EEG.xmax]);
    end
    g.notime = [];
end
if ~isempty( g.nopoint )
    g.notime = zeros(size(g.nopoint));
    for index = 1:length(g.nopoint(:))
        g.notime(index) = eeg_point2lat(g.nopoint(index), 1, EEG.srate, [EEG.xmin EEG.xmax]);
    end
    g.time = [];
end
if ~isempty( g.notime )
    if size(g.notime,2) ~= 2
        error('Time/point range must contain 2 columns exactly');
    end
    if g.notime(2) == EEG.xmax
        g.time = [EEG.xmin g.notime(1)];
    else
        if g.notime(1) == EEG.xmin
            g.time = [g.notime(2) EEG.xmax];
        elseif EEG.trials > 1
            error('Wrong notime range. Remember that it is not possible to remove a slice of time for data epochs.');
        end
    end
    if g.notime(end) > EEG.xmax, g.notime(end) = EEG.xmax; end
    if g.notime(1)   < EEG.xmin, g.notime(1)   = EEG.xmin; end
    if floor(max(g.notime(:))) > EEG.xmax
        error('Time/point range exceed upper data limits');
    end
    if min(g.notime(:)) < EEG.xmin
        error('Time/point range exceed lower data limits');
    end
end
if ~isempty(g.time)
    if size(g.time,2) ~= 2
        error('Time/point range must contain 2 columns exactly');
    end
    for index = 1:length(g.time)
        if g.time(index) > EEG.xmax
            g.time(index) = EEG.xmax;
            disp('Upper time limits exceed data, corrected');
        elseif g.time(index) < EEG.xmin
            g.time(index) = EEG.xmin;
            disp('Lower time limits exceed data, corrected');
        end
    end
end

% select trial values
%--------------------
if ~isempty(g.trialcond)
    try, tt = struct( g.trialcond{:} ); catch
        error('Trial conditions format error');
    end
    ttfields = fieldnames (tt);
    for index = 1:length(ttfields)
        if ~isfield( EEG.epoch, ttfields{index} )
            error([ ttfields{index} 'is not a field of EEG.epoch' ]);
        end;
        tmpepoch = EEG.epoch;
        eval( [ 'Itriallow  = find( [ tmpepoch(:).' ttfields{index} ' ] >= tt.' ttfields{index} '(1) );' ] );
        eval( [ 'Itrialhigh = find( [ tmpepoch(:).' ttfields{index} ' ] <= tt.' ttfields{index} '(end) );' ] );
        Itrialtmp = intersect_bc(Itriallow, Itrialhigh);
        g.trial = intersect_bc( g.trial(:)', Itrialtmp(:)');
    end;
end

if isempty(g.trial)
    error('Empty dataset, no trial');
end
if length(g.trial) ~= EEG.trials
    fprintf('Removing %d trial(s)...\n', EEG.trials - length(g.trial));
end
if length(g.channel) ~= EEG.nbchan
    %   fprintf('Removing %d channel(s)...\n', EEG.nbchan -
    %   length(g.channel));
end

try
    % For AMICA probabilities...
    %-----------------------------------------------------
    if isfield(EEG.etc, 'amica') && ~isempty(EEG.etc.amica) && isfield(EEG.etc.amica, 'v_smooth') && ~isempty(EEG.etc.amica.v_smooth) && ~isfield(EEG.etc.amica,'prob_added')
        if isfield(EEG.etc.amica, 'num_models') && ~isempty(EEG.etc.amica.num_models)
            if size(EEG.data,2) == size(EEG.etc.amica.v_smooth,2) && size(EEG.data,3) == size(EEG.etc.amica.v_smooth,3) && size(EEG.etc.amica.v_smooth,1) == EEG.etc.amica.num_models
                
                EEG = eeg_formatamica(EEG);
                
                %-------------------------------------------
                
                [EEG com] = pop_select(EEG,args{:});
                
                %-------------------------------------------
                
                EEG = eeg_reformatamica(EEG);
                EEG = eeg_checkamica(EEG);
                return;
            else
                disp('AMICA probabilities not compatible with size of data, probabilities cannot be rejected')
                
                disp('Resuming rejection...')
            end
        end
        
    end
    % ------------------------------------------------------
catch
    warnmsg = strcat('your dataset contains amica information, but the amica plugin is not installed.  Continuing and ignoring amica information.');
    warning(warnmsg)
end


% recompute latency and epoch number for events
% ---------------------------------------------
if length(g.trial) ~= EEG.trials && ~isempty(EEG.event)
    if ~isfield(EEG.event, 'epoch')
        disp('Pop_epoch warning: bad event format with epoch dataset, removing events');
        EEG.event = [];
    else
        if isfield(EEG.event, 'epoch')
            keepevent = [];
            for indexevent = 1:length(EEG.event)
                newindex = find( EEG.event(indexevent).epoch == g.trial );% For AMICA probabilities...
                %-----------------------------------------------------
                try
                    if isfield(EEG.etc, 'amica') && ~isempty(EEG.etc.amica) && isfield(EEG.etc.amica, 'v_smooth') && ~isempty(EEG.etc.amica.v_smooth) && ~isfield(EEG.etc.amica,'prob_added')
                        if isfield(EEG.etc.amica, 'num_models') && ~isempty(EEG.etc.amica.num_models)
                            if size(EEG.data,2) == size(EEG.etc.amica.v_smooth,2) && size(EEG.data,3) == size(EEG.etc.amica.v_smooth,3) && size(EEG.etc.amica.v_smooth,1) == EEG.etc.amica.num_models
                                
                                EEG = eeg_formatamica(EEG);
                                
                                %-------------------------------------------
                                
                                [EEG com] = pop_select(EEG,args{:});
                                
                                %-------------------------------------------
                                
                                EEG = eeg_reformatamica(EEG);
                                EEG = eeg_checkamica(EEG);
                                return;
                            else
                                disp('AMICA probabilities not compatible with size of data, probabilities cannot be rejected')
                                
                                disp('Resuming rejection...')
                            end
                        end
                        
                    end
                catch
                    warnmsg = strcat('your dataset contains amica information, but the amica plugin is not installed.  Continuing and ignoring amica information.');
                    warning(warnmsg)
                end;
                % ------------------------------------------------------
                
                if ~isempty(newindex)
                    keepevent = [keepevent indexevent];
                    if isfield(EEG.event, 'latency')
                        EEG.event(indexevent).latency = EEG.event(indexevent).latency - (EEG.event(indexevent).epoch-1)*EEG.pnts + (newindex-1)*EEG.pnts;
                    end
                    EEG.event(indexevent).epoch = newindex;
                end
            end
            diffevent = setdiff_bc([1:length(EEG.event)], keepevent);
            if ~isempty(diffevent)
                disp(['Pop_select: removing ' int2str(length(diffevent)) ' unreferenced events']);
                EEG.event(diffevent) = [];
            end
        end
    end
end


% performing removal ------------------
if ~isempty(g.time) || ~isempty(g.notime)
    if EEG.trials > 1
        % select new time window ----------------------
        try,   tmpevent = EEG.event;
            tmpeventlatency = [ tmpevent.latency ];
        catch, tmpeventlatency = [];
        end
        alllatencies = 1-(EEG.xmin*EEG.srate); % time 0 point
        alllatencies = linspace( alllatencies, EEG.pnts*(EEG.trials-1)+alllatencies, EEG.trials);
        [EEG.data tmptime indices epochevent]= epoch(EEG.data, alllatencies, ...
            [g.time(1) g.time(2)]*EEG.srate, 'allevents', tmpeventlatency);
        tmptime = tmptime/EEG.srate;
        if g.time(1) ~= tmptime(1) && g.time(2)-1/EEG.srate ~= tmptime(2)
            fprintf('pop_select(): time limits have been adjusted to [%3.3f %3.3f] to fit data points limits\n', tmptime(1), tmptime(2)+1/EEG.srate);
        end
        EEG.xmin = tmptime(1);
        EEG.xmax = tmptime(2);
        EEG.pnts = size(EEG.data,2);
        alllatencies = alllatencies(indices);
        
        % modify the event structure accordingly (latencies and add epoch
        % field)
        % ----------------------------------------------------------------------
        allevents = [];
        newevent = [];
        count = 1;
        if ~isempty(epochevent)
            newevent = EEG.event(1);
            for index=1:EEG.trials
                for indexevent = epochevent{index}
                    newevent(count)         = EEG.event(indexevent);
                    newevent(count).epoch   = index;
                    newevent(count).latency = newevent(count).latency - alllatencies(index) - tmptime(1)*EEG.srate + 1 + EEG.pnts*(index-1);
                    count = count + 1;
                end
            end
        end
        EEG.event = newevent;
        
        % erase event-related fields from the epochs
        % ------------------------------------------
        if ~isempty(EEG.epoch)
            fn = fieldnames(EEG.epoch);
            EEG.epoch = rmfield(EEG.epoch,{fn{strmatch('event',fn)}});
        end
    else
        if isempty(g.notime)
            if length(g.time) == 2 && EEG.xmin < 0
                disp('Warning: negative minimum time; unchanged to ensure correct latency of initial boundary event');
            end
            g.notime = g.time';
            g.notime = g.notime(:);
            if g.notime(1) ~= 0, g.notime = [EEG.xmin g.notime(:)'];
            else                 g.notime = [g.notime(2:end)'];
            end
            if g.time(end) == EEG.xmax, g.notime(end) = [];
            else                        g.notime(end+1) = EEG.xmax;
            end
            
            for index = 1:length(g.notime)
                if g.notime(index) ~= 0  && g.notime(index) ~= EEG.xmax
                    if mod(index,2), g.notime(index) = g.notime(index) + 1/EEG.srate;
                    else             g.notime(index) = g.notime(index) - 1/EEG.srate;
                    end
                end
            end;
            g.notime = reshape(g.notime, 2, length(g.notime)/2)';
        end;
        
        nbtimes = length(g.notime(:));
        [points,flag] = eeg_lat2point(g.notime(:)', ones(1,nbtimes), EEG.srate, [EEG.xmin EEG.xmax]);
        points = reshape(points, size(g.notime));
        
        % fixing if last region is the same
        if flag
            if ~isempty(find((points(end,1)-points(end,2))== 0)), points(end,:) = []; end
        end
        
        EEG = eeg_eegrej(EEG, points);
    end
end

% performing removal ------------------
if ~isequal(g.channel,1:size(EEG.data,1)) || ~isequal(g.trial,1:size(EEG.data,3))
    %EEG.data  = EEG.data(g.channel, :, g.trial);
    % this code belows is prefered for memory mapped files
    diff1 = setdiff_bc([1:size(EEG.data,1)], g.channel);
    diff2 = setdiff_bc([1:size(EEG.data,3)], g.trial);
    if ~isempty(diff1)
        EEG.data(diff1, :, :) = [];
    end
    if ~isempty(diff2)
        EEG.data(:, :, diff2) = [];
    end
end
if ~isempty(EEG.icaact), EEG.icaact = EEG.icaact(:,:,g.trial); end
EEG.trials    = length(g.trial);
EEG.pnts      = size(EEG.data,2);
EEG.nbchan    = length(g.channel);
if ~isempty(EEG.chanlocs)
    EEG.chanlocs = EEG.chanlocs(g.channel);
end;
if ~isempty(EEG.epoch)
    EEG.epoch = EEG.epoch( g.trial );
end
if ~isempty(EEG.specdata)
    if length(g.point) == EEG.pnts
        EEG.specdata = EEG.specdata(g.channel, :, g.trial);
    else
        EEG.specdata = [];
        %  fprintf('Warning: spectral data were removed because of the
        %  change in the numner of points\n');
    end;
end

% ica specific ------------
if ~isempty(EEG.icachansind)
    
    rmchans = setdiff_bc( EEG.icachansind, g.channel ); % channels to remove
    
    % channel sub-indices -------------------
    icachans = 1:length(EEG.icachansind);
    for index = length(rmchans):-1:1
        chanind           = find(EEG.icachansind == rmchans(index));
        icachans(chanind) = [];
    end
    
    % new channels indices --------------------
    count   = 1;
    newinds = [];
    for index = 1:length(g.channel)
        if any(EEG.icachansind == g.channel(index))
            newinds(count) = index;
            count          = count+1;
        end
    end
    EEG.icachansind = newinds;
    
else
    icachans = 1:size(EEG.icasphere,2);
end

if ~isempty(EEG.icawinv)
    flag_rmchan = (length(icachans) ~= size(EEG.icawinv,1));
    if  isempty(EEG.icaweights) || flag_rmchan
        EEG.icawinv    = EEG.icawinv(icachans,:);
        EEG.icaweights = pinv(EEG.icawinv);
        EEG.icasphere  = eye(size(EEG.icaweights,2));
    end
end
if ~isempty(EEG.specicaact)
    if length(g.point) == EEG.pnts
        EEG.specicaact = EEG.specicaact(icachans, :, g.trial);
    else
        EEG.specicaact = [];
        fprintf('Warning: spectral ICA data were removed because of the change in the numner of points\n');
    end
end

% check if only one epoch -----------------------
if EEG.trials == 1
    if isfield(EEG.event, 'epoch')
        EEG.event = rmfield(EEG.event, 'epoch');
    end
    EEG.epoch = [];
end
if isfield(EEG.reject, 'gcompreject') && isequal(g.channel,1:size(EEG.data,1))
    tmpgcompreject = EEG.reject.gcompreject;
    EEG.reject = [];
    EEG.reject.gcompreject = tmpgcompreject;
else
    EEG.reject = [];
end
EEG.stats  = [];
EEG.reject.rejmanual = [];
% for stats, can adapt remove the selected trials and electrodes in the
% future to gain time -----------------------------------
EEG.stats.jp = [];
EEG = eeg_checksetMG(EEG, 'eventconsistency');

% generate command ----------------
if nargout > 1
    com = sprintf('EEG = pop_select( EEG, %s);', vararg2str(args));
end

return;

% ********* OLD, do not remove any event any more ********* in the future
% maybe do a pack event to remove events not in the time range of any epoch

if ~isempty(EEG.event)
    % go to array format if necessary
    if isstruct(EEG.event), format = 'struct';
    else                     format = 'array';
    end
    switch format, case 'struct', EEG = eventsformat(EEG, 'array'); end
    
    % keep only events related to the selected trials
    Indexes = [];
    Ievent  = [];
    for index = 1:length( g.trial )
        currentevents = find( EEG.event(:,2) == g.trial(index));
        Indexes = [ Indexes ones(1, length(currentevents))*index ];
        Ievent  = union_bc( Ievent, currentevents );
    end
    EEG.event = EEG.event( Ievent,: );
    EEG.event(:,2) = Indexes(:);
    
    switch format, case 'struct', EEG = eventsformat(EEG, 'struct'); end
end

end







% eeg_checkset()   - check the consistency of the fields of an EEG dataset
%                    Also: See EEG dataset structure field descriptions
%                    below.
%
% Usage: >> [EEGOUT,changes] = eeg_checkset(EEG); % perform all checks
%                                                  except 'makeur'
%        >> [EEGOUT,changes] = eeg_checkset(EEG, 'keyword'); % perform
%        'keyword' check(s)
%
% Inputs:
%       EEG        - EEGLAB dataset structure or (ALLEEG) array of EEG
%       structures
%
% Optional keywords:
%   'icaconsist'   - if EEG contains several datasets, check whether they
%   have
%                    the same ICA decomposition
%   'epochconsist' - if EEG contains several datasets, check whether they
%   have
%                    identical epoch lengths and time limits.
%   'chanconsist'  - if EEG contains several datasets, check whether they
%   have
%                    the same number of channels and channel labels.
%   'data'         - check whether EEG contains data (EEG.data) 'loaddata'
%   - load data array (if necessary) 'savedata'     - save data array (if
%   necessary - see EEG.saved below) 'contdata'     - check whether EEG
%   contains continuous data 'epoch'        - check whether EEG contains
%   epoched or continuous data 'ica'          - check whether EEG contains
%   an ICA decomposition 'besa'         - check whether EEG contains
%   component dipole locations 'event'        - check whether EEG contains
%   an event array 'makeur'       - remake the EEG.urevent structure
%   'checkur'      - check whether the EEG.urevent structure is consistent
%                    with the EEG.event structure
%   'chanlocsize'  - check the EEG.chanlocs structure length; show warning
%   if
%                    necessary.
%   'chanlocs_homogeneous' - check whether EEG contains consistent channel
%                            information; if not, correct it.This option
%                            calls eeg_checkchanlocs.
%   'eventconsistency'     - check whether EEG.event information are
%   consistent;
%                            rebuild event* subfields of the 'EEG.epoch'
%                            structure (can be time consuming).
% Outputs:
%       EEGOUT     - output EEGLAB dataset or dataset array changes    -
%       change code: 'no' = no changes; 'yes' = the EEG
%                    structure was modified
%
% =========================================================== The structure
% of an EEG dataset under EEGLAB (as of v5.03):
%
% Basic dataset information:
%   EEG.setname      - descriptive name|title for the dataset EEG.filename
%   - filename of the dataset file on disk EEG.filepath     - filepath
%   (directory/folder) of the dataset file(s) EEG.trials       - number of
%   epochs (or trials) in the dataset.
%                      If data are continuous, this number is 1.
%   EEG.pnts         - number of time points (or data frames) per trial
%   (epoch).
%                      If data are continuous (trials=1), the total number
%                      of time points (frames) in the dataset
%   EEG.nbchan       - number of channels EEG.srate        - data sampling
%   rate (in Hz) EEG.xmin         - epoch start latency|time (in sec.
%   relative to the
%                      time-locking event at time 0)
%   EEG.xmax         - epoch end latency|time (in seconds) EEG.times
%   - vector of latencies|times in miliseconds (one per time point) EEG.ref
%   - ['common'|'averef'|integer] reference channel type or number
%   EEG.history      - cell array of ascii pop-window commands that created
%                      or modified the dataset
%   EEG.comments     - comments about the nature of the dataset (edit this
%   via
%                      menu selection Edit > About this dataset)
%   EEG.etc          - miscellaneous (technical or temporary) dataset
%   information EEG.saved        - ['yes'|'no'] 'no' flags need to save
%   dataset changes before exit
%
% The data:
%   EEG.data         - two-dimensional continuous data array (chans,
%   frames)
%                      ELSE, three-dim. epoched data array (chans, frames,
%                      epochs)
%
% The channel locations sub-structures:
%   EEG.chanlocs     - structure array containing names and locations
%                      of the channels on the scalp
%   EEG.urchanlocs   - original (ur) dataset chanlocs structure containing
%                      all channels originally collected with these data
%                      (before channel rejection)
%   EEG.chaninfo     - structure containing additional channel info EEG.ref
%   - type of channel reference ('common'|'averef'|+/-int] EEG.splinefile
%   - location of the spline file used by headplot() to plot
%                      data scalp maps in 3-D
%
% The event and epoch sub-structures:
%   EEG.event        - event structure containing times and nature of
%   experimental
%                      events recorded as occurring at data time points
%   EEG.urevent      - original (ur) event structure containing all
%   experimental
%                      events recorded as occurring at the original data
%                      time points (before data rejection)
%   EEG.epoch        - epoch event information and epoch-associated data
%   structure array (one per epoch) EEG.eventdescription - cell array of
%   strings describing event fields. EEG.epochdescription - cell array of
%   strings describing epoch fields. --> See the
%   http://sccn.ucsd.edu/eeglab/maintut/eeglabscript.html for details
%
% ICA (or other linear) data components:
%   EEG.icasphere   - sphering array returned by linear (ICA) decomposition
%   EEG.icaweights  - unmixing weights array returned by linear (ICA)
%   decomposition EEG.icawinv     - inverse (ICA) weight matrix. Columns
%   gives the projected
%                     topographies of the components to the electrodes.
%   EEG.icaact      - ICA activations matrix (components, frames, epochs)
%                     Note: [] here means that 'compute_ica' option has bee
%                     set to 0 under 'File > Memory options' In this case,
%                     component activations are computed only as needed.
%   EEG.icasplinefile - location of the spline file used by headplot() to
%   plot
%                     component scalp maps in 3-D
%   EEG.chaninfo.icachansind  - indices of channels used in the ICA
%   decomposition EEG.dipfit      - array of structures containing
%   component map dipole models
%
% Variables indicating membership of the dataset in a studyset:
%   EEG.subject     - studyset subject code EEG.group       - studyset
%   group code EEG.condition   - studyset experimental condition code
%   EEG.session     - studyset session number
%
% Variables used for manual and semi-automatic data rejection:
%   EEG.specdata           - data spectrum for every single trial
%   EEG.specica            - data spectrum for every single trial EEG.stats
%   - statistics used for data rejection
%       EEG.stats.kurtc    - component kurtosis values EEG.stats.kurtg    -
%       global kurtosis of components EEG.stats.kurta    - kurtosis of
%       accepted epochs EEG.stats.kurtr    - kurtosis of rejected epochs
%       EEG.stats.kurtd    - kurtosis of spatial distribution
%   EEG.reject            - statistics used for data rejection
%       EEG.reject.entropy - entropy of epochs EEG.reject.entropyc  -
%       entropy of components EEG.reject.threshold - rejection thresholds
%       EEG.reject.icareject - epochs rejected by ICA criteria
%       EEG.reject.gcompreject - rejected ICA components
%       EEG.reject.sigreject  - epochs rejected by single-channel criteria
%       EEG.reject.elecreject - epochs rejected by raw data criteria
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: eeglab()

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This file is part of EEGLAB, see http://www.eeglab.org for the
% documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% 01-25-02 reformated help & license -ad 01-26-02 chandeg events and trial
% condition format -ad 01-27-02 debug when trial condition is empty -ad
% 02-15-02 remove icawinv recompute for pop_epoch -ad & ja 02-16-02 remove
% last modification and test icawinv separatelly -ad 02-16-02 empty event
% and epoch check -ad 03-07-02 add the eeglab options -ad 03-07-02
% corrected typos and rate/point calculation -ad & ja 03-15-02 add channel
% location reading & checking -ad 03-15-02 add checking of ICA and epochs
% with pop_up windows -ad 03-27-02 recorrected rate/point calculation -ad &
% sm

function [EEG, res] = eeg_checksetMG( EEG, varargin );
msg = '';
res = 'no';
com = sprintf('EEG = eeg_checkset( EEG );');

if nargin < 1
    help eeg_checkset;
    return;
end

if isempty(EEG), return; end
if ~isfield(EEG, 'data'), return; end

% checking multiple datasets --------------------------
if length(EEG) > 1
    
    if nargin > 1
        switch varargin{1}
            case 'epochconsist', % test epoch consistency
                % ----------------------
                res = 'no';
                datasettype = unique_bc( [ EEG.trials ] );
                if datasettype(1) == 1 && length(datasettype) == 1, return; % continuous data
                elseif datasettype(1) == 1,                        return; % continuous and epoch data
                end
                
                allpnts = unique_bc( [ EEG.pnts ] );
                allxmin = unique_bc( [ EEG.xmin ] );
                if length(allpnts) == 1 && length(allxmin) == 1, res = 'yes'; end
                return;
                
            case 'chanconsist'  % test channel number and name consistency
                % ----------------------------------------
                res = 'yes';
                chanlen    = unique_bc( [ EEG.nbchan ] );
                anyempty    = unique_bc( cellfun( 'isempty', { EEG.chanlocs }) );
                if length(chanlen) == 1 && all(anyempty == 0)
                    tmpchanlocs = EEG(1).chanlocs;
                    channame1 = { tmpchanlocs.labels };
                    for i = 2:length(EEG)
                        tmpchanlocs = EEG(i).chanlocs;
                        channame2 = { tmpchanlocs.labels };
                        if length(intersect(channame1, channame2)) ~= length(channame1), res = 'no'; end
                    end
                else res = 'no';
                end
                
                % Field 'datachan in 'urchanlocs' is removed, if exist
                if isfield(EEG, 'urchanlocs') && ~all(cellfun(@isempty,{EEG.urchanlocs})) && isfield([EEG.urchanlocs], 'datachan')
                    [EEG.urchanlocs] = deal(rmfield([EEG.urchanlocs], 'datachan'));
                end
                return;
                
            case 'icaconsist'  % test ICA decomposition consistency
                % ----------------------------------
                res = 'yes';
                anyempty    = unique_bc( cellfun( 'isempty', { EEG.icaweights }) );
                if length(anyempty) == 1 && anyempty(1) == 0
                    ica1 = EEG(1).icawinv;
                    for i = 2:length(EEG)
                        if ~isequal(EEG(1).icawinv, EEG(i).icawinv)
                            res = 'no';
                        end
                    end
                else res = 'no';
                end
                return;
                
        end
    end
    
end

% reading these option take time because of disk access --------------
eeglab_options;

% standard checking -----------------
ALLEEG = EEG;
for inddataset = 1:length(ALLEEG)
    
    EEG = ALLEEG(inddataset);
    
    % additional checks -----------------
    res = -1; % error code
    if ~isempty( varargin)
        for index = 1:length( varargin )
            switch varargin{ index }
                case 'data',; % already done at the top
                case 'contdata',;
                    if EEG.trials > 1
                        errordlg2(strvcat('Error: function only works on continuous data'), 'Error');
                        return;
                    end
                case 'ica',
                    if isempty(EEG.icaweights)
                        errordlg2(strvcat('Error: no ICA decomposition. use menu "Tools > Run ICA" first.'), 'Error');
                        return;
                    end
                case 'epoch',
                    if EEG.trials == 1
                        errordlg2(strvcat('Extract epochs before running that function', 'Use Tools > Extract epochs'), 'Error');
                        return
                    end
                case 'besa',
                    if ~isfield(EEG, 'sources')
                        errordlg2(strvcat('No dipole information', '1) Export component maps: Tools > Localize ... BESA > Export ...' ...
                            , '2) Run BESA to localize the equivalent dipoles', ...
                            '3) Import the BESA dipoles: Tools > Localize ... BESA > Import ...'), 'Error');
                        return
                    end
                case 'event',
                    if isempty(EEG.event)
                        errordlg2(strvcat('Requires events. You need to add events first.', ...
                            'Use "File > Import event info" or "File > Import epoch info"'), 'Error');
                        return;
                    end
                case 'chanloc',
                    tmplocs = EEG.chanlocs;
                    if isempty(tmplocs) || ~isfield(tmplocs, 'theta') || all(cellfun('isempty', { tmplocs.theta }))
                        errordlg2( strvcat('This functionality requires channel location information.', ...
                            'Enter the channel file name via "Edit > Edit dataset info".', ...
                            'For channel file format, see ''>> help readlocs'' from the command line.'), 'Error');
                        return;
                    end
                case 'chanlocs_homogeneous',
                    tmplocs = EEG.chanlocs;
                    if isempty(tmplocs) || ~isfield(tmplocs, 'theta') || all(cellfun('isempty', { tmplocs.theta }))
                        errordlg2( strvcat('This functionality requires channel location information.', ...
                            'Enter the channel file name via "Edit > Edit dataset info".', ...
                            'For channel file format, see ''>> help readlocs'' from the command line.'), 'Error');
                        return;
                    end
                    if ~isfield(EEG.chanlocs, 'X') || isempty(EEG.chanlocs(1).X)
                        EEG = eeg_checkchanlocs(EEG);
                        % EEG.chanlocs = convertlocs(EEG.chanlocs,
                        % 'topo2all');
                        res = ['EEG = eeg_checkset(EEG, ''chanlocs_homogeneous''); ' ];
                    end
                case 'chanlocsize',
                    if ~isempty(EEG.chanlocs)
                        if length(EEG.chanlocs) > EEG.nbchan
                            questdlg2(strvcat('Warning: there is one more electrode location than', ...
                                'data channels. EEGLAB will consider the last electrode to be the', ...
                                'common reference channel. If this is not the case, remove the', ...
                                'extra channel'), 'Warning', 'Ok', 'Ok');
                        end
                    end
                case 'makeur',
                    if ~isempty(EEG.event)
                        if isfield(EEG.event, 'urevent'),
                            EEG.event = rmfield(EEG.event, 'urevent');
                            disp('eeg_checkset note: re-creating the original event table (EEG.urevent)');
                        else
                            disp('eeg_checkset note: creating the original event table (EEG.urevent)');
                        end
                        EEG.urevent = EEG.event;
                        for index = 1:length(EEG.event)
                            EEG.event(index).urevent = index;
                        end
                    end
                case 'checkur',
                    if ~isempty(EEG.event)
                        if isfield(EEG.event, 'urevent') && ~isempty(EEG.urevent)
                            urlatencies = [ EEG.urevent.latency ];
                            [newlat tmpind] = sort(urlatencies);
                            if ~isequal(newlat, urlatencies)
                                EEG.urevent   = EEG.urevent(tmpind);
                                [tmp tmpind2] = sort(tmpind);
                                for index = 1:length(EEG.event)
                                    EEG.event(index).urevent = tmpind2(EEG.event(index).urevent);
                                end
                            end
                        end
                    end
                case 'eventconsistency',
                    [EEG res] = eeg_checksetMG(EEG);
                    if isempty(EEG.event), return; end
                    
                    % check events (slow) ------------
                    if isfield(EEG.event, 'type')
                        eventInds = arrayfun(@(x)isempty(x.type), EEG.event);
                        if any(eventInds)
                            if all(arrayfun(@(x)isnumeric(x.type), EEG.event))
                                for ind = find(eventInds), EEG.event(ind).type = NaN; end
                            else for ind = find(eventInds), EEG.event(ind).type = 'empty'; end
                            end
                        end
                        if ~all(arrayfun(@(x)ischar(x.type), EEG.event)) && ~all(arrayfun(@(x)isnumeric(x.type), EEG.event))
                            disp('Warning: converting all event types to strings');
                            for ind = 1:length(EEG.event)
                                EEG.event(ind).type = num2str(EEG.event(ind).type);
                            end
                            EEG = eeg_checksetMG(EEG, 'eventconsistency');
                        end
                        
                    end
                    
                    % Removing events with NaN latency
                    % --------------------------------
                    if isfield(EEG.event, 'latency')
                        nanindex = find(isnan([ EEG.event.latency ]));
                        if ~isempty(nanindex)
                            EEG.event(nanindex) = [];
                            trialtext = '';
                            for inan = 1:length(nanindex)
                                trialstext = [trialtext ' ' num2str(nanindex(inan))];
                            end
                            disp(sprintf(['eeg_checkset: Event(s) with NaN latency were deleted \nDeleted event index(es):[' trialstext ']']));
                        end
                    end
                    
                    % remove the events which latency are out of boundary
                    % ---------------------------------------------------
                    if isfield(EEG.event, 'latency')
                        if isfield(EEG.event, 'type') && ischar(EEG.event(1).type)
                            if strcmpi(EEG.event(1).type, 'boundary') && isfield(EEG.event, 'duration')
                                if EEG.event(1).duration < 1
                                    EEG.event(1) = [];
                                elseif EEG.event(1).latency > 0 && EEG.event(1).latency < 1
                                    EEG.event(1).latency = 0.5;
                                end
                            end
                        end
                        
                        try, tmpevent = EEG.event; alllatencies = [ tmpevent.latency ];
                        catch, error('Checkset: error empty latency entry for new events added by user');
                        end
                        I1 = find(alllatencies < 0.5);
                        I2 = find(alllatencies > EEG.pnts*EEG.trials+1); % The addition of 1 was included
                        % because, if data epochs are extracted from -1 to
                        % time 0, this allow to include the last event in
                        % the last epoch (otherwise all epochs have an
                        % event except the last one
                        if (length(I1) + length(I2)) > 0
                            fprintf('eeg_checkset warning: %d/%d events had out-of-bounds latencies and were removed\n', ...
                                length(I1) + length(I2), length(EEG.event));
                            EEG.event(union(I1, I2)) = [];
                        end
                    end
                    if isempty(EEG.event), return; end
                    
                    % save information for non latency fields updates
                    % -----------------------------------------------
                    difffield = [];
                    if ~isempty(EEG.event) && isfield(EEG.event, 'epoch')
                        % remove fields with empty epochs
                        % -------------------------------
                        removeevent = [];
                        try, tmpevent = EEG.event; allepochs = [ tmpevent.epoch ];
                            removeevent = find( allepochs < 1 || allepochs > EEG.trials);
                            if ~isempty(removeevent)
                                disp([ 'eeg_checkset warning: ' int2str(length(removeevent)) ' event had invalid epoch numbers and were removed']);
                            end
                        catch,
                            for indexevent = 1:length(EEG.event)
                                if isempty( EEG.event(indexevent).epoch ) || ~isnumeric(EEG.event(indexevent).epoch) ...
                                        || EEG.event(indexevent).epoch < 1 || EEG.event(indexevent).epoch > EEG.trials
                                    removeevent = [removeevent indexevent];
                                    disp([ 'eeg_checkset warning: event ' int2str(indexevent) ' has an invalid epoch number: removed']);
                                end
                            end
                        end
                        EEG.event(removeevent) = [];
                        tmpevent  = EEG.event;
                        allepochs = [ tmpevent.epoch ];
                        
                        % uniformize fields content for the different
                        % epochs
                        % --------------------------------------------------
                        % THIS WAS REMOVED SINCE SOME FIELDS ARE ASSOCIATED
                        % WITH THE EVENT AND NOT WITH THE EPOCH I PUT IT
                        % BACK, BUT IT DOES NOT ERASE NON-EMPTY VALUES
                        difffield = fieldnames(EEG.event);
                        difffield = difffield(~(strcmp(difffield,'latency')|strcmp(difffield,'epoch')|strcmp(difffield,'type')|strcmp(difffield,'mffkeys')|strcmp(difffield,'mffkeysbackup')|strcmp(difffield,'begintime')));
                        for index = 1:length(difffield)
                            tmpevent  = EEG.event;
                            allvalues = { tmpevent.(difffield{index}) };
                            try
                                valempt = cellfun('isempty', allvalues);
                            catch
                                valempt = mycellfun('isempty', allvalues);
                            end
                            arraytmpinfo = cell(1,EEG.trials);
                            
                            % spetial case of duration
                            % ------------------------
                            if strcmp( difffield{index}, 'duration')
                                if any(valempt)
                                    fprintf(['eeg_checkset: found empty values for field ''' difffield{index} ...
                                        ''' (filling with 0)\n']);
                                end
                                for indexevent = find(valempt)
                                    EEG.event(indexevent).duration = 0;
                                end
                            else
                                
                                % get the field content
                                % ---------------------
                                indexevent = find(~valempt);
                                arraytmpinfo(allepochs(indexevent)) = allvalues(indexevent);
                                
                                % uniformize content for all epochs
                                % ---------------------------------
                                indexevent = find(valempt);
                                tmpevent   = EEG.event;
                                [tmpevent(indexevent).(difffield{index})] = arraytmpinfo{allepochs(indexevent)};
                                EEG.event  = tmpevent;
                                if any(valempt)
                                    fprintf(['eeg_checkset: found empty values for field ''' difffield{index} '''\n']);
                                    fprintf(['              filling with values of other events in the same epochs\n']);
                                end
                            end
                        end
                    end
                    if isempty(EEG.event), return; end
                    
                    % uniformize fields (str or int) if necessary
                    % -------------------------------------------
                    fnames = fieldnames(EEG.event);
                    for fidx = 1:length(fnames)
                        fname = fnames{fidx};
                        if ~strcmpi(fname, 'mffkeys') && ~strcmpi(fname, 'mffkeysbackup')
                            tmpevent  = EEG.event;
                            allvalues = { tmpevent.(fname) };
                            try
                                % find indices of numeric values among
                                % values of this event property
                                valreal = ~cellfun('isclass', allvalues, 'char');
                            catch
                                valreal = mycellfun('isclass', allvalues, 'double');
                            end
                            
                            format = 'ok';
                            if ~all(valreal) % all valreal ok
                                format = 'str';
                                if all(valreal == 0) % all valreal=0 ok
                                    format = 'ok';
                                end
                            end
                            if strcmp(format, 'str')
                                fprintf('eeg_checkset note: event field format ''%s'' made uniform\n', fname);
                                allvalues = cellfun(@num2str, allvalues, 'uniformoutput', false);
                                [EEG.event(valreal).(fname)] = deal(allvalues{find(valreal)});
                            end
                        end
                    end
                    
                    % check boundary events ---------------------
                    tmpevent = EEG.event;
                    if isfield(tmpevent, 'type') && ~isnumeric(tmpevent(1).type)
                        allEventTypes = { tmpevent.type };
                        boundsInd = strmatch('boundary', allEventTypes);
                        if ~isempty(boundsInd),
                            bounds = [ tmpevent(boundsInd).latency ];
                            % remove last event if necessary
                            if EEG.trials==1;%this if block added by James Desjardins (Jan 13th, 2014)
                                if round(bounds(end)-0.5+1) >= size(EEG.data,2), EEG.event(boundsInd(end)) = []; bounds(end) = []; end; % remove final boundary if any
                            end
                            % The first boundary below need to be kept for
                            % urevent latency calculation if bounds(1) < 0,
                            % EEG.event(bounds(1))   = []; end; % remove
                            % initial boundary if any
                            indDoublet = find(bounds(2:end)-bounds(1:end-1)==0);
                            if ~isempty(indDoublet)
                                disp('Warning: duplicate boundary event removed');
                                if isfield(EEG.event, 'duration')
                                    for indBound = 1:length(indDoublet)
                                        EEG.event(boundsInd(indDoublet(indBound)+1)).duration = EEG.event(boundsInd(indDoublet(indBound)+1)).duration+EEG.event(boundsInd(indDoublet(indBound))).duration;
                                    end
                                end
                                EEG.event(boundsInd(indDoublet)) = [];
                            end
                        end
                    end
                    if isempty(EEG.event), return; end
                    
                    % check that numeric format is double (Matlab 7)
                    % -----------------------------------
                    allfields = fieldnames(EEG.event);
                    if ~isempty(EEG.event)
                        for index = 1:length(allfields)
                            tmpval = EEG.event(1).(allfields{index});
                            if isnumeric(tmpval) && ~isa(tmpval, 'double')
                                for indexevent = 1:length(EEG.event)
                                    tmpval  =   getfield(EEG.event, { indexevent }, allfields{index} );
                                    EEG.event = setfield(EEG.event, { indexevent }, allfields{index}, double(tmpval));
                                end
                            end
                        end
                    end
                    
                    % check duration field, replace empty by 0
                    % ----------------------------------------
                    if isfield(EEG.event, 'duration')
                        tmpevent = EEG.event;
                        try,   valempt = cellfun('isempty'  , { tmpevent.duration });
                        catch, valempt = mycellfun('isempty', { tmpevent.duration });
                        end
                        if any(valempt),
                            for index = find(valempt)
                                EEG.event(index).duration = 0;
                            end
                        end
                    end
                    
                    % resort events -------------
                    if isfield(EEG.event, 'latency')
                        try,
                            if isfield(EEG.event, 'epoch')
                                TMPEEG = pop_editeventvals(EEG, 'sort', { 'epoch' 0 'latency' 0 });
                            else
                                TMPEEG = pop_editeventvals(EEG, 'sort', { 'latency' 0 });
                            end
                            if ~isequal(TMPEEG.event, EEG.event)
                                EEG = TMPEEG;
                                disp('Event resorted by increasing latencies.');
                            end
                        catch,
                            disp('eeg_checkset: problem when attempting to resort event latencies.');
                        end
                    end
                    
                    % check latency of first event
                    % ----------------------------
                    if ~isempty(EEG.event)
                        if isfield(EEG.event, 'latency')
                            if EEG.event(1).latency < 0.5
                                EEG.event(1).latency = 0.5;
                            end
                        end
                    end
                    
                    % build epoch structure ---------------------
                    try,
                        if EEG.trials > 1 && ~isempty(EEG.event)
                            % erase existing event-related fields
                            % ------------------------------
                            if ~isfield(EEG,'epoch')
                                EEG.epoch = [];
                            end
                            if ~isempty(EEG.epoch)
                                if length(EEG.epoch) ~= EEG.trials
                                    disp('Warning: number of epoch entries does not match number of dataset trials;');
                                    disp('         user-defined epoch entries will be erased.');
                                    EEG.epoch = [];
                                else
                                    fn = fieldnames(EEG.epoch);
                                    EEG.epoch = rmfield(EEG.epoch,fn(strncmp('event',fn,5)));
                                end
                            end
                            
                            % set event field ---------------
                            tmpevent   = EEG.event;
                            eventepoch = [tmpevent.epoch];
                            epochevent = cell(1,EEG.trials);
                            destdata = epochevent;
                            EEG.epoch(length(epochevent)).event = [];
                            for k=1:length(epochevent)
                                epochevent{k} = find(eventepoch==k);
                            end
                            tmpepoch = EEG.epoch;
                            [tmpepoch.event] = epochevent{:};
                            EEG.epoch = tmpepoch;
                            maxlen = max(cellfun(@length,epochevent));
                            
                            % copy event information into the epoch array
                            % -------------------------------------------
                            eventfields = fieldnames(EEG.event)';
                            eventfields = eventfields(~strcmp(eventfields,'epoch'));
                            tmpevent    = EEG.event;
                            for k = 1:length(eventfields)
                                fname = eventfields{k};
                                switch fname
                                    case 'latency'
                                        sourcedata = round(eeg_point2lat([tmpevent.(fname)],[tmpevent.epoch],EEG.srate, [EEG.xmin EEG.xmax]*1000, 1E-3) * 10^8 )/10^8;
                                        sourcedata = num2cell(sourcedata);
                                    case 'duration'
                                        sourcedata = num2cell([tmpevent.(fname)]/EEG.srate*1000);
                                    otherwise
                                        sourcedata = {tmpevent.(fname)};
                                end
                                if maxlen == 1
                                    destdata = cell(1,length(epochevent));
                                    destdata(~cellfun('isempty',epochevent)) = sourcedata([epochevent{:}]);
                                else
                                    for l=1:length(epochevent)
                                        destdata{l} = sourcedata(epochevent{l});
                                    end
                                end
                                tmpepoch = EEG.epoch;
                                [tmpepoch.(['event' fname])] = destdata{:};
                                EEG.epoch = tmpepoch;
                            end
                        end
                    catch,
                        errordlg2(['Warning: minor problem encountered when generating' 10 ...
                            'the EEG.epoch structure (used only in user scripts)']); return;
                    end
                case { 'loaddata' 'savedata' 'chanconsist' 'icaconsist' 'epochconsist' }, res = '';
                otherwise, error('eeg_checkset: unknown option');
            end
        end
    end
    
    res = [];
    
    % check name consistency ----------------------
    if ~isempty(EEG.setname)
        if ~ischar(EEG.setname)
            EEG.setname = '';
        else
            if size(EEG.setname,1) > 1
                disp('eeg_checkset warning: invalid dataset name, removed');
                EEG.setname = '';
            end
        end
    else
        EEG.setname = '';
    end
    
    % checking history and convert if necessary
    % -----------------------------------------
    if isfield(EEG, 'history') && size(EEG.history,1) > 1
        allcoms = cellstr(EEG.history);
        EEG.history = deblank(allcoms{1});
        for index = 2:length(allcoms)
            EEG.history = [ EEG.history 10 deblank(allcoms{index}) ];
        end
    end
    
    % read data if necessary ----------------------
    if ischar(EEG.data) && nargin > 1
        if strcmpi(varargin{1}, 'loaddata')
            
            EEG.data = eeg_getdatact(EEG);
            
        end
    end
    
    % save data if necessary ----------------------
    if nargin > 1
        
        % datfile available? ------------------
        datfile = 0;
        if isfield(EEG, 'datfile')
            if ~isempty(EEG.datfile)
                datfile = 1;
            end
        end
        
        % save data ---------
        if strcmpi(varargin{1}, 'savedata') && option_storedisk
            error('eeg_checkset: cannot call savedata any more');
            
            % the code below is deprecated
            if ~ischar(EEG.data) % not already saved
                disp('Writing previous dataset to disk...');
                
                if datfile
                    tmpdata = reshape(EEG.data, EEG.nbchan,  EEG.pnts*EEG.trials);
                    floatwrite( tmpdata', fullfile(EEG.filepath, EEG.datfile), 'ieee-le');
                    EEG.data   = EEG.datfile;
                end
                EEG.icaact = [];
                
                % saving dataset --------------
                filename = fullfile(EEG(1).filepath, EEG(1).filename);
                if ~ischar(EEG.data) && option_single, EEG.data = single(EEG.data); end
                v = version;
                if str2num(v(1)) >= 7, save( filename, '-v6', '-mat', 'EEG'); % Matlab 7
                else                   save( filename, '-mat', 'EEG');
                end
                if ~ischar(EEG.data), EEG.data = 'in set file'; end
                
                % res = sprintf('%s = eeg_checkset( %s, ''savedata'');',
                % inputname(1), inputname(1));
                res = ['EEG = eeg_checkset( EEG, ''savedata'');'];
            end
        end
    end
    
    % numerical format ----------------
    if isnumeric(EEG.data)
        v = version;
        EEG.icawinv    = double(EEG.icawinv); % required for dipole fitting, otherwise it crashes
        EEG.icaweights = double(EEG.icaweights);
        EEG.icasphere  = double(EEG.icasphere);
        if ~isempty(findstr(v, 'R11')) || ~isempty(findstr(v, 'R12')) || ~isempty(findstr(v, 'R13'))
            EEG.data       = double(EEG.data);
            EEG.icaact     = double(EEG.icaact);
        else
            try,
                if isa(EEG.data, 'double') && option_single
                    EEG.data       = single(EEG.data);
                    EEG.icaact     = single(EEG.icaact);
                end
            catch,
                disp('WARNING: EEGLAB ran out of memory while converting dataset to single precision.');
                disp('         Save dataset (preferably saving data to a separate file; see File > Memory options).');
                disp('         Then reload it.');
            end
        end
    end
    
    % verify the type of the variables --------------------------------
    % data dimensions -------------------------
    if isnumeric(EEG.data) && ~isempty(EEG.data)
        if ~isequal(size(EEG.data,1), EEG.nbchan)
            disp( [ 'eeg_checkset warning: number of columns in data (' int2str(size(EEG.data,1)) ...
                ') does not match the number of channels (' int2str(EEG.nbchan) '): corrected' ]);
            res = com;
            EEG.nbchan = size(EEG.data,1);
        end
        
        if (ndims(EEG.data)) < 3 && (EEG.pnts > 1)
            if mod(size(EEG.data,2), EEG.pnts) ~= 0
                if popask( [ 'eeg_checkset error: the number of frames does not divide the number of columns in the data.'  10 ...
                        'Should EEGLAB attempt to abort operation ?' 10 '(press Cancel to fix the problem from the command line)'])
                    error('eeg_checkset error: user abort');
                    %res = com; EEG.pnts = size(EEG.data,2); EEG =
                    %eeg_checkset(EEG); return;
                else
                    res = com;
                    return;
                    %error( 'eeg_checkset error: number of points does not
                    %divide the number of columns in data');
                end
            else
                if EEG.trials > 1
                    disp( 'eeg_checkset note: data array made 3-D');
                    res = com;
                end
                if size(EEG.data,2) ~= EEG.pnts
                    EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, size(EEG.data,2)/EEG.pnts);
                end
            end
        end
        
        % size of data -----------
        if size(EEG.data,3) ~= EEG.trials
            disp( ['eeg_checkset warning: 3rd dimension size of data (' int2str(size(EEG.data,3)) ...
                ') does not match the number of epochs (' int2str(EEG.trials) '), corrected' ]);
            res = com;
            EEG.trials = size(EEG.data,3);
        end
        if size(EEG.data,2) ~= EEG.pnts
            disp( [ 'eeg_checkset warning: number of columns in data (' int2str(size(EEG.data,2)) ...
                ') does not match the number of points (' int2str(EEG.pnts) '): corrected' ]);
            res = com;
            EEG.pnts = size(EEG.data,2);
        end
    end
    
    % parameters consistency -------------------------
    if round(EEG.srate*(EEG.xmax-EEG.xmin)+1) ~= EEG.pnts
        fprintf( 'eeg_checkset note: upper time limit (xmax) adjusted so (xmax-xmin)*srate+1 = number of frames\n');
        if EEG.srate == 0
            EEG.srate = 1;
        end
        EEG.xmax = (EEG.pnts-1)/EEG.srate+EEG.xmin;
        res = com;
    end
    
    % deal with event arrays ----------------------
    if ~isfield(EEG, 'event'), EEG.event = []; res = com; end
    if ~isempty(EEG.event)
        if EEG.trials > 1 && ~isfield(EEG.event, 'epoch')
            if popask( [ 'eeg_checkset error: the event info structure does not contain an ''epoch'' field.'  ...
                    'Should EEGLAB attempt to abort operation ?' 10 '(press Cancel to fix the problem from the commandline)'])
                error('eeg_checkset error(): user abort');
                %res = com; EEG.event = []; EEG = eeg_checkset(EEG);
                %return;
            else
                res = com;
                return;
                %error('eeg_checkset error: no epoch field in event
                %structure');
            end
        end
    else
        EEG.event = [];
    end
    if isempty(EEG.event)
        EEG.eventdescription = {};
    end
    if ~isfield(EEG, 'eventdescription') || ~iscell(EEG.eventdescription)
        EEG.eventdescription = cell(1, length(fieldnames(EEG.event)));
        res = com;
    else
        if ~isempty(EEG.event)
            if length(EEG.eventdescription) > length( fieldnames(EEG.event))
                EEG.eventdescription = EEG.eventdescription(1:length( fieldnames(EEG.event)));
            elseif length(EEG.eventdescription) < length( fieldnames(EEG.event))
                EEG.eventdescription(end+1:length( fieldnames(EEG.event))) = {''};
            end
        end
    end
    % create urevent if continuous data ---------------------------------
    %if ~isempty(EEG.event) && ~isfield(EEG, 'urevent')
    %    EEG.urevent = EEG.event;
    %   disp('eeg_checkset note: creating the original event table
    %   (EEG.urevent)');
    %    for index = 1:length(EEG.event)
    %        EEG.event(index).urevent = index;
    %    end
    %end
    if isfield(EEG, 'urevent') && isfield(EEG.urevent, 'urevent')
        EEG.urevent = rmfield(EEG.urevent, 'urevent');
    end
    
    % deal with epoch arrays ----------------------
    if ~isfield(EEG, 'epoch'), EEG.epoch = []; res = com; end
    
    % check if only one epoch -----------------------
    if EEG.trials == 1
        if isfield(EEG.event, 'epoch')
            EEG.event = rmfield(EEG.event, 'epoch'); res = com;
        end
        if ~isempty(EEG.epoch)
            EEG.epoch = []; res = com;
        end
    end
    
    if ~isfield(EEG, 'epochdescription'), EEG.epochdescription = {}; res = com; end
    if ~isempty(EEG.epoch)
        if isstruct(EEG.epoch),  l = length( EEG.epoch);
        else                     l = size( EEG.epoch, 2);
        end
        if l ~= EEG.trials
            if popask( [ 'eeg_checkset error: the number of epoch indices in the epoch array/struct (' ...
                    int2str(l) ') is different from the number of epochs in the data (' int2str(EEG.trials) ').' 10 ...
                    'Should EEGLAB attempt to abort operation ?' 10 '(press Cancel to fix the problem from the commandline)'])
                error('eeg_checkset error: user abort');
                %res = com; EEG.epoch = []; EEG = eeg_checkset(EEG);
                %return;
            else
                res = com;
                return;
                %error('eeg_checkset error: epoch structure size invalid');
            end
        end
    else
        EEG.epoch = [];
    end
    
    % check ica ---------
    if ~isfield(EEG, 'icachansind')
        if isempty(EEG.icaweights)
            EEG.icachansind = []; res = com;
        else
            EEG.icachansind = [1:EEG.nbchan]; res = com;
        end
    elseif isempty(EEG.icachansind)
        if isempty(EEG.icaweights)
            EEG.icachansind = []; res = com;
        else
            EEG.icachansind = [1:EEG.nbchan]; res = com;
        end
    end
    if ~isempty(EEG.icasphere)
        if ~isempty(EEG.icaweights)
            if size(EEG.icaweights,2) ~= size(EEG.icasphere,1)
                if popask( [ 'eeg_checkset error: number of columns in weights array (' int2str(size(EEG.icaweights,2)) ')' 10 ...
                        'does not match the number of rows in the sphere array (' int2str(size(EEG.icasphere,1)) ')' 10 ...
                        'Should EEGLAB remove ICA information ?' 10 '(press Cancel to fix the problem from the commandline)'])
                    res = com;
                    EEG.icasphere = [];
                    EEG.icaweights = [];
                    EEG = eeg_checksetMG(EEG);
                    return;
                else
                    error('eeg_checkset error: user abort');
                    res = com;
                    return;
                    %error('eeg_checkset error: invalid weight and sphere
                    %array sizes');
                end
            end
            if isnumeric(EEG.data)
                if length(EEG.icachansind) ~= size(EEG.icasphere,2)
                    if popask( [ 'eeg_checkset error: number of elements in ''icachansind'' (' int2str(length(EEG.icachansind)) ')' 10 ...
                            'does not match the number of columns in the sphere array (' int2str(size(EEG.icasphere,2)) ')' 10 ...
                            'Should EEGLAB remove ICA information ?' 10 '(press Cancel to fix the problem from the commandline)'])
                        res = com;
                        EEG.icasphere = [];
                        EEG.icaweights = [];
                        EEG = eeg_checksetMG(EEG);
                        return;
                    else
                        error('eeg_checkset error: user abort');
                        res = com;
                        return;
                        %error('eeg_checkset error: invalid weight and
                        %sphere array sizes');
                    end
                end
                if isempty(EEG.icaact) || (size(EEG.icaact,1) ~= size(EEG.icaweights,1)) || (size(EEG.icaact,2) ~= size(EEG.data,2))
                    EEG.icaweights = double(EEG.icaweights);
                    EEG.icawinv = double(EEG.icawinv);
                    
                    % scale ICA components to RMS microvolt
                    if option_scaleicarms
                        if ~isempty(EEG.icawinv)
                            if mean(mean(abs(pinv(EEG.icaweights * EEG.icasphere)-EEG.icawinv))) < 0.0001
                                %disp('Scaling components to RMS
                                %microvolt');
                                scaling = repmat(sqrt(mean(EEG(1).icawinv(:,:).^2))', [1 size(EEG.icaweights,2)]);
                                EEG.etc.icaweights_beforerms = EEG.icaweights;
                                EEG.etc.icasphere_beforerms = EEG.icasphere;
                                
                                EEG.icaweights = EEG.icaweights .* scaling;
                                EEG.icawinv = pinv(EEG.icaweights * EEG.icasphere);
                            end
                        end
                    end
                    
                    if ~isempty(EEG.data) && option_computeica
                        fprintf('eeg_checkset: recomputing the ICA activation matrix ...\n');
                        res = com;
                        % Make compatible with Matlab 7
                        if any(isnan(EEG.data(:)))
                            tmpdata = EEG.data(EEG.icachansind,:);
                            fprintf('eeg_checkset: recomputing ICA ignoring NaN indices ...\n');
                            tmpindices = find(~sum(isnan(tmpdata))); % was: tmpindices = find(~isnan(EEG.data(1,:)));
                            EEG.icaact = zeros(size(EEG.icaweights,1), size(tmpdata,2)); EEG.icaact(:) = NaN;
                            EEG.icaact(:,tmpindices) = (EEG.icaweights*EEG.icasphere)*tmpdata(:,tmpindices);
                        else
                            EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:); % automatically does single or double
                        end
                        EEG.icaact    = reshape( EEG.icaact, size(EEG.icaact,1), EEG.pnts, EEG.trials);
                    end
                end
            end
            if isempty(EEG.icawinv)
                EEG.icawinv = pinv(EEG.icaweights*EEG.icasphere); % a priori same result as inv
                res         = com;
            end
        else
            disp( [ 'eeg_checkset warning: weights matrix cannot be empty if sphere matrix is not, correcting ...' ]);
            res = com;
            EEG.icasphere = [];
        end
        if option_computeica
            if ~isempty(EEG.icaact) && ndims(EEG.icaact) < 3 && (EEG.trials > 1)
                disp( [ 'eeg_checkset note: independent component made 3-D' ]);
                res = com;
                EEG.icaact = reshape(EEG.icaact, size(EEG.icaact,1), EEG.pnts, EEG.trials);
            end
        else
            if ~isempty(EEG.icaact)
                fprintf('eeg_checkset: removing ICA activation matrix (as per edit options) ...\n');
            end
            EEG.icaact     = [];
        end
    else
        if ~isempty( EEG.icaweights ), EEG.icaweights = []; res = com; end
        if ~isempty( EEG.icawinv ),    EEG.icawinv = []; res = com; end
        if ~isempty( EEG.icaact ),     EEG.icaact = []; res = com; end
    end
    if isempty(EEG.icaact)
        EEG.icaact = [];
    end
    
    % ------------- check chanlocs -------------
    if ~isfield(EEG, 'chaninfo')
        EEG.chaninfo = [];
    end
    if ~isempty( EEG.chanlocs )
        
        % reference (use EEG structure) ---------
        if ~isfield(EEG, 'ref'), EEG.ref = ''; end
        if strcmpi(EEG.ref, 'averef')
            ref = 'average';
        else ref = '';
        end
        if ~isfield( EEG.chanlocs, 'ref')
            EEG.chanlocs(1).ref = ref;
        end
        charrefs = cellfun('isclass',{EEG.chanlocs.ref},'char');
        if any(charrefs) ref = ''; end
        for tmpind = find(~charrefs)
            EEG.chanlocs(tmpind).ref = ref;
        end
        if ~isstruct( EEG.chanlocs)
            if exist( EEG.chanlocs ) ~= 2
                disp( [ 'eeg_checkset warning: channel file does not exist or is not in Matlab path: filename removed from EEG struct' ]);
                EEG.chanlocs = [];
                res = com;
            else
                res = com;
                try, EEG.chanlocs = readlocs( EEG.chanlocs );
                    disp( [ 'eeg_checkset: channel file read' ]);
                catch, EEG.chanlocs = []; end
            end
        else
            if ~isfield(EEG.chanlocs,'labels')
                disp('eeg_checkset warning: no field label in channel location structure, removing it');
                EEG.chanlocs = [];
                res = com;
            end
        end
        if isstruct( EEG.chanlocs)
            if length( EEG.chanlocs) ~= EEG.nbchan && length( EEG.chanlocs) ~= EEG.nbchan+1 && ~isempty(EEG.data)
                disp( [ 'eeg_checkset warning: number of channels different in data and channel file/struct: channel file/struct removed' ]);
                EEG.chanlocs = [];
                res = com;
            end
        end
        
        % force Nosedir to +X (done here because of DIPFIT)
        % -------------------
        if isfield(EEG.chaninfo, 'nosedir')
            if ~strcmpi(EEG.chaninfo.nosedir, '+x') && all(isfield(EEG.chanlocs,{'X','Y','theta','sph_theta'}))
                disp(['Note for expert users: Nose direction is now set from ''' upper(EEG.chaninfo.nosedir)  ''' to default +X in EEG.chanlocs']);
                [tmp chaninfo chans] = eeg_checkchanlocs(EEG.chanlocs, EEG.chaninfo); % Merge all channels for rotation (FID and data channels)
                if strcmpi(chaninfo.nosedir, '+y')
                    rotate = 270;
                elseif strcmpi(chaninfo.nosedir, '-x')
                    rotate = 180;
                else
                    rotate = 90;
                end
                for index = 1:length(chans)
                    rotategrad = rotate/180*pi;
                    coord = (chans(index).Y + chans(index).X*sqrt(-1))*exp(sqrt(-1)*-rotategrad);
                    chans(index).Y = real(coord);
                    chans(index).X = imag(coord);
                    
                    if ~isempty(chans(index).theta)
                        chans(index).theta     = chans(index).theta    -rotate;
                        chans(index).sph_theta = chans(index).sph_theta+rotate;
                        if chans(index).theta    <-180, chans(index).theta    =chans(index).theta    +360; end
                        if chans(index).sph_theta>180 , chans(index).sph_theta=chans(index).sph_theta-360; end
                    end
                end
                
                if isfield(EEG, 'dipfit')
                    if isfield(EEG.dipfit, 'coord_transform')
                        if isempty(EEG.dipfit.coord_transform)
                            EEG.dipfit.coord_transform = [0 0 0 0 0 0 1 1 1];
                        end
                        EEG.dipfit.coord_transform(6) = EEG.dipfit.coord_transform(6)+rotategrad;
                    end
                end
                
                chaninfo.nosedir = '+X';
                [EEG.chanlocs EEG.chaninfo] = eeg_checkchanlocs(chans, chaninfo); % Update FID in chaninfo and remove them from chanlocs
            end;
        end
        
        % general checking of channels ----------------------------
        EEG = eeg_checkchanlocs(EEG);
        if EEG.nbchan ~= length(EEG.chanlocs)
            EEG.chanlocs = [];
            EEG.chaninfo = [];
            disp('Warning: the size of the channel location structure does not match with');
            disp('         number of channels. Channel information have been removed.');
        end
    end
    EEG.chaninfo.icachansind = EEG.icachansind; % just a copy for programming convinience
    
    %if ~isfield(EEG, 'urchanlocs')
    %    EEG.urchanlocs = EEG.chanlocs; for index = 1:length(EEG.chanlocs)
    %        EEG.chanlocs(index).urchan = index;
    %    end disp('eeg_checkset note: creating backup chanlocs structure
    %    (urchanlocs)');
    %end
    
    % Field 'datachan in 'urchanlocs' is removed, if exist
    if isfield(EEG, 'urchanlocs') && ~isempty(EEG.urchanlocs) && isfield(EEG.urchanlocs, 'datachan')
        EEG.urchanlocs = rmfield(EEG.urchanlocs, 'datachan');
    end
    
    % check reference ---------------
    if ~isfield(EEG, 'ref')
        EEG.ref = 'common';
    end
    if ischar(EEG.ref) && strcmpi(EEG.ref, 'common')
        if length(EEG.chanlocs) > EEG.nbchan
            disp('Extra common reference electrode location detected');
            EEG.ref = EEG.nbchan+1;
        end
    end
    
    % DIPFIT structure ----------------
    if ~isfield(EEG,'dipfit') || isempty(EEG.dipfit)
        EEG.dipfit = []; res = com;
    else
        try
            % check if dipfitdefs is present
            dipfitdefs;
            if isfield(EEG.dipfit, 'vol') && ~isfield(EEG.dipfit, 'hdmfile')
                if exist('pop_dipfit_settings')
                    disp('Old DIPFIT structure detected: converting to DIPFIT 2 format');
                    EEG.dipfit.hdmfile     = template_models(1).hdmfile;
                    EEG.dipfit.coordformat = template_models(1).coordformat;
                    EEG.dipfit.mrifile     = template_models(1).mrifile;
                    EEG.dipfit.chanfile    = template_models(1).chanfile;
                    EEG.dipfit.coord_transform = [];
                    EEG.saved = 'no';
                    res = com;
                end
            end
            if isfield(EEG.dipfit, 'hdmfile')
                if length(EEG.dipfit.hdmfile) > 8
                    if strcmpi(EEG.dipfit.hdmfile(end-8), template_models(1).hdmfile(end-8)), EEG.dipfit.hdmfile = template_models(1).hdmfile; end
                    if strcmpi(EEG.dipfit.hdmfile(end-8), template_models(2).hdmfile(end-8)), EEG.dipfit.hdmfile = template_models(2).hdmfile; end
                end
                if length(EEG.dipfit.mrifile) > 8
                    if strcmpi(EEG.dipfit.mrifile(end-8), template_models(1).mrifile(end-8)), EEG.dipfit.mrifile = template_models(1).mrifile; end
                    if strcmpi(EEG.dipfit.mrifile(end-8), template_models(2).mrifile(end-8)), EEG.dipfit.mrifile = template_models(2).mrifile; end
                end
                if length(EEG.dipfit.chanfile) > 8
                    if strcmpi(EEG.dipfit.chanfile(end-8), template_models(1).chanfile(end-8)), EEG.dipfit.chanfile = template_models(1).chanfile; end
                    if strcmpi(EEG.dipfit.chanfile(end-8), template_models(2).chanfile(end-8)), EEG.dipfit.chanfile = template_models(2).chanfile; end
                end
            end
            
            if isfield(EEG.dipfit, 'coord_transform')
                if isempty(EEG.dipfit.coord_transform)
                    EEG.dipfit.coord_transform = [0 0 0 0 0 0 1 1 1];
                end
            elseif ~isempty(EEG.dipfit)
                EEG.dipfit.coord_transform = [0 0 0 0 0 0 1 1 1];
            end
        catch
            e = lasterror;
            if ~strcmp(e.identifier,'MATLAB:UndefinedFunction')
                % if we got some error aside from dipfitdefs not being
                % present, rethrow it
                rethrow(e);
            end
        end
    end
    
    % check events (fast) ------------
    if isfield(EEG.event, 'type')
        tmpevent = EEG.event(1:min(length(EEG.event), 100));
        if ~all(cellfun(@ischar, { tmpevent.type })) && ~all(cellfun(@isnumeric, { tmpevent.type }))
            disp('Warning: converting all event types to strings');
            for ind = 1:length(EEG.event)
                EEG.event(ind).type = num2str(EEG.event(ind).type);
            end
            EEG = eeg_checksetMG(EEG, 'eventconsistency');
        end
    end
    
    % EEG.times (only for epoched datasets) ---------
    if ~isfield(EEG, 'times') || isempty(EEG.times) || length(EEG.times) ~= EEG.pnts
        EEG.times = linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts);
    end
    
    if ~isfield(EEG, 'history')    EEG.history    = ''; res = com; end
    if ~isfield(EEG, 'splinefile') EEG.splinefile = ''; res = com; end
    if ~isfield(EEG, 'icasplinefile') EEG.icasplinefile = ''; res = com; end
    if ~isfield(EEG, 'saved')      EEG.saved      = 'no'; res = com; end
    if ~isfield(EEG, 'subject')    EEG.subject    = ''; res = com; end
    if ~isfield(EEG, 'condition')  EEG.condition  = ''; res = com; end
    if ~isfield(EEG, 'group')      EEG.group      = ''; res = com; end
    if ~isfield(EEG, 'session')    EEG.session    = []; res = com; end
    if ~isfield(EEG, 'urchanlocs') EEG.urchanlocs = []; res = com; end
    if ~isfield(EEG, 'specdata')   EEG.specdata   = []; res = com; end
    if ~isfield(EEG, 'specicaact') EEG.specicaact = []; res = com; end
    if ~isfield(EEG, 'comments')   EEG.comments   = ''; res = com; end
    if ~isfield(EEG, 'etc'     )   EEG.etc        = []; res = com; end
    if ~isfield(EEG, 'urevent' )   EEG.urevent    = []; res = com; end
    if ~isfield(EEG, 'ref') || isempty(EEG.ref) EEG.ref = 'common'; res = com; end
    
    % create fields if absent -----------------------
    if ~isfield(EEG, 'reject')                    EEG.reject.rejjp = []; res = com; end
    
    listf = { 'rejjp' 'rejkurt' 'rejmanual' 'rejthresh' 'rejconst', 'rejfreq' ...
        'icarejjp' 'icarejkurt' 'icarejmanual' 'icarejthresh' 'icarejconst', 'icarejfreq'};
    for index = 1:length(listf)
        name = listf{index};
        elecfield = [name 'E'];
        if ~isfield(EEG.reject, elecfield),     EEG.reject.(elecfield) = []; res = com; end
        if ~isfield(EEG.reject, name)
            EEG.reject.(name) = [];
            res = com;
        elseif ~isempty(EEG.reject.(name)) && isempty(EEG.reject.(elecfield))
            % check if electrode array is empty with rejection array is not
            nbchan = fastif(strcmp(name, 'ica'), size(EEG.icaweights,1), EEG.nbchan);
            EEG.reject = setfield(EEG.reject, elecfield, zeros(nbchan, length(getfield(EEG.reject, name)))); res = com;
        end
    end
    if ~isfield(EEG.reject, 'rejglobal')        EEG.reject.rejglobal  = []; res = com; end
    if ~isfield(EEG.reject, 'rejglobalE')       EEG.reject.rejglobalE = []; res = com; end
    
    % track version of EEGLAB -----------------------
    tmpvers = eeg_getversion;
    if ~isfield(EEG.etc, 'eeglabvers') || ~isequal(EEG.etc.eeglabvers, tmpvers)
        EEG.etc.eeglabvers = tmpvers;
        EEG = eeg_hist( EEG, ['EEG.etc.eeglabvers = ''' tmpvers '''; % this tracks which version of EEGLAB is being used, you may ignore it'] );
        res = com;
    end
    
    % default colors for rejection ----------------------------
    if ~isfield(EEG.reject, 'rejmanualcol')   EEG.reject.rejmanualcol = [1.0000    1     0.783]; res = com; end
    if ~isfield(EEG.reject, 'rejthreshcol')   EEG.reject.rejthreshcol = [0.8487    1.0000    0.5008]; res = com; end
    if ~isfield(EEG.reject, 'rejconstcol')    EEG.reject.rejconstcol  = [0.6940    1.0000    0.7008]; res = com; end
    if ~isfield(EEG.reject, 'rejjpcol')       EEG.reject.rejjpcol     = [1.0000    0.6991    0.7537]; res = com; end
    if ~isfield(EEG.reject, 'rejkurtcol')     EEG.reject.rejkurtcol   = [0.6880    0.7042    1.0000]; res = com; end
    if ~isfield(EEG.reject, 'rejfreqcol')     EEG.reject.rejfreqcol   = [0.9596    0.7193    1.0000]; res = com; end
    if ~isfield(EEG.reject, 'disprej')        EEG.reject.disprej      = { }; end
    
    if ~isfield(EEG, 'stats')           EEG.stats.jp = []; res = com; end
    if ~isfield(EEG.stats, 'jp')        EEG.stats.jp = []; res = com; end
    if ~isfield(EEG.stats, 'jpE')       EEG.stats.jpE = []; res = com; end
    if ~isfield(EEG.stats, 'icajp')     EEG.stats.icajp = []; res = com; end
    if ~isfield(EEG.stats, 'icajpE')    EEG.stats.icajpE = []; res = com; end
    if ~isfield(EEG.stats, 'kurt')      EEG.stats.kurt = []; res = com; end
    if ~isfield(EEG.stats, 'kurtE')     EEG.stats.kurtE = []; res = com; end
    if ~isfield(EEG.stats, 'icakurt')   EEG.stats.icakurt = []; res = com; end
    if ~isfield(EEG.stats, 'icakurtE')  EEG.stats.icakurtE = []; res = com; end
    
    % component rejection -------------------
    if ~isfield(EEG.stats, 'compenta')        EEG.stats.compenta = []; res = com; end
    if ~isfield(EEG.stats, 'compentr')        EEG.stats.compentr = []; res = com; end
    if ~isfield(EEG.stats, 'compkurta')       EEG.stats.compkurta = []; res = com; end
    if ~isfield(EEG.stats, 'compkurtr')       EEG.stats.compkurtr = []; res = com; end
    if ~isfield(EEG.stats, 'compkurtdist')    EEG.stats.compkurtdist = []; res = com; end
    if ~isfield(EEG.reject, 'threshold')      EEG.reject.threshold = [0.8 0.8 0.8]; res = com; end
    if ~isfield(EEG.reject, 'threshentropy')  EEG.reject.threshentropy = 600; res = com; end
    if ~isfield(EEG.reject, 'threshkurtact')  EEG.reject.threshkurtact = 600; res = com; end
    if ~isfield(EEG.reject, 'threshkurtdist') EEG.reject.threshkurtdist = 600; res = com; end
    if ~isfield(EEG.reject, 'gcompreject')    EEG.reject.gcompreject = []; res = com; end
    if length(EEG.reject.gcompreject) ~= size(EEG.icaweights,1)
        EEG.reject.gcompreject = zeros(1, size(EEG.icaweights,1));
    end
    
    % remove old fields -----------------
    if isfield(EEG, 'averef'), EEG = rmfield(EEG, 'averef'); end
    if isfield(EEG, 'rt'    ), EEG = rmfield(EEG, 'rt');     end
    
    % store in new structure ----------------------
    if isstruct(EEG)
        if ~exist('ALLEEGNEW','var')
            ALLEEGNEW = EEG;
        else
            ALLEEGNEW(inddataset) = EEG;
        end
    end
end

% recorder fields ---------------
fieldorder = { 'setname' ...
    'filename' ...
    'filepath' ...
    'subject' ...
    'group' ...
    'condition' ...
    'session' ...
    'comments' ...
    'nbchan' ...
    'trials' ...
    'pnts' ...
    'srate' ...
    'xmin' ...
    'xmax' ...
    'times' ...
    'data' ...
    'icaact' ...
    'icawinv' ...
    'icasphere' ...
    'icaweights' ...
    'icachansind' ...
    'chanlocs' ...
    'urchanlocs' ...
    'chaninfo' ...
    'ref' ...
    'event' ...
    'urevent' ...
    'eventdescription' ...
    'epoch' ...
    'epochdescription' ...
    'reject' ...
    'stats' ...
    'specdata' ...
    'specicaact' ...
    'splinefile' ...
    'icasplinefile' ...
    'dipfit' ...
    'history' ...
    'saved' ...
    'etc' };

for fcell = fieldnames(EEG)'
    fname = fcell{1};
    if ~any(strcmp(fieldorder,fname))
        fieldorder{end+1} = fname;
    end
end

try
    ALLEEGNEW = orderfields(ALLEEGNEW, fieldorder);
    EEG = ALLEEGNEW;
catch
    disp('Couldn''t order data set fields properly.');
end

if exist('ALLEEGNEW','var')
    EEG = ALLEEGNEW;
end

if ~isa(EEG, 'eegobj') && option_eegobject
    EEG = eegobj(EEG);
end

return;
end
function num = popask( text )
ButtonName=questdlg2( text, ...
    'Confirmation', 'Cancel', 'Yes','Yes');
switch lower(ButtonName),
    case 'cancel', num = 0;
    case 'yes',    num = 1;
end
end
function res = mycellfun(com, vals, classtype);
res = zeros(1, length(vals));
switch com
    case 'isempty',
        for index = 1:length(vals), res(index) = isempty(vals{index}); end
    case 'isclass'
        if strcmp(classtype, 'double')
            for index = 1:length(vals), res(index) = isnumeric(vals{index}); end
        else
            error('unknown cellfun command');
        end
    otherwise error('unknown cellfun command');
end


end

function [EEG, com, b] = pop_eegfiltnew(EEG, varargin)

com = '';

if nargin < 1
    help pop_eegfiltnew;
    return
end
if isempty(EEG(1).data)
    error('Cannot filter empty dataset.');
end

% GUI
if nargin < 2
    
    geometry = {[3, 1], [3, 1], [3, 1], 1, 1, 1, 1 [2 1.5 0.5] [2 1.5 0.5]  };
    geomvert = [1 1 1 2 1 1 1 1 1];
    
    cb_type = 'pop_chansel(get(gcbf, ''userdata''), ''field'', ''type'',   ''handle'', findobj(''parent'', gcbf, ''tag'', ''chantypes''));';
    cb_chan = 'pop_chansel(get(gcbf, ''userdata''), ''field'', ''labels'', ''handle'', findobj(''parent'', gcbf, ''tag'', ''channels''));';
    
    uilist = {{'style', 'text', 'string', 'Lower edge of the frequency pass band (Hz)'} ...
        {'style', 'edit', 'string', ''} ...
        {'style', 'text', 'string', 'Higher edge of the frequency pass band (Hz)'} ...
        {'style', 'edit', 'string', ''} ...
        {'style', 'text', 'string', 'FIR Filter order (Mandatory even. Default is automatic*)'} ...
        {'style', 'edit', 'string', ''} ...
        {'style', 'text', 'string', {'*See help text for a description of the default filter order heuristic.', 'Manual definition is recommended.'}} ...
        {'style', 'checkbox', 'string', 'Notch filter the data instead of pass band', 'value', 0} ...
        {'Style', 'checkbox', 'String', 'Use minimum-phase converted causal filter (non-linear!; beta)', 'Value', 0} ...
        {'style', 'checkbox', 'string', 'Plot frequency response', 'value', 1} ...
        { 'style' 'text'       'string' 'Channel type(s)' } ...
        { 'style' 'edit'       'string' '' 'tag' 'chantypes'}  ...
        { 'style' 'pushbutton' 'string' '...'  'callback' cb_type } ...
        { 'style' 'text'       'string' 'OR channel labels or indices' } ...
        { 'style' 'edit'       'string' '' 'tag' 'channels' }  ...
        { 'style' 'pushbutton' 'string' '...' 'callback' cb_chan }
        };
    
    % channel labels --------------
    if ~isempty(EEG(1).chanlocs)
        tmpchanlocs = EEG(1).chanlocs;
    else
        tmpchanlocs = [];
        for index = 1:EEG(1).nbchan
            tmpchanlocs(index).labels = int2str(index);
            tmpchanlocs(index).type = '';
        end
    end
    
    result = inputgui('geometry', geometry, 'geomvert', geomvert, 'uilist', uilist, 'title', 'Filter the data -- pop_eegfiltnew()', 'helpcom', 'pophelp(''pop_eegfiltnew'')', 'userdata', tmpchanlocs);
    
    if isempty(result), return; end
    options = {};
    if ~isempty(result{1}), options = { options{:} 'locutoff' str2num( result{1}) }; end
    if ~isempty(result{2}), options = { options{:} 'hicutoff' str2num( result{2}) }; end
    if ~isempty(result{3}), options = { options{:} 'filtorder' result{3} }; end
    if result{4}, options = { options{:} 'revfilt' result{4} }; end
    if result{5}, options = { options{:} 'minphase' result{5} }; end
    if result{6}, options = { options{:} 'plotfreqz' result{6} }; end
    if ~isempty(result{7} ), options = { options{:} 'chantype' parsetxt(result{7}) }; end
    if ~isempty(result{8}) && isempty( result{7} )
        [ chaninds, chanlist ] = eeg_decodechan(EEG(1).chanlocs, result{8});
        if isempty(chanlist), chanlist = chaninds; end
        options = { options{:}, 'channels' chanlist };
    end
elseif ~ischar(varargin{1})
    % backward compatibility
    options = {};
    if nargin > 1, options = { options{:} 'locutoff'  varargin{1} }; end
    if nargin > 2, options = { options{:} 'hicutoff'  varargin{2} }; end
    if nargin > 3, options = { options{:} 'filtorder' varargin{3} }; end
    if nargin > 4, options = { options{:} 'revfilt'   varargin{4} }; end
    if nargin > 5, options = { options{:} 'usefft'    varargin{5} }; end
    if nargin > 6, options = { options{:} 'plotfreqz' varargin{6} }; end
    if nargin > 7, options = { options{:} 'minphase'  varargin{7} }; end
    if nargin > 8, options = { options{:} 'usefftfilt' varargin{8} }; end
    
    if nargin < 5 || isempty(revfilt)
        revfilt = 0;
    end
    if nargin < 6
        usefft = [];
    elseif usefft == 1
        error('FFT filtering not supported. Argument is provided for backward compatibility in command line mode only.')
    end
    if nargin < 7 || isempty(plotfreqz)
        plotfreqz = 0;
    end
    if nargin < 8 || isempty(minphase)
        minphase = 0;
    end
    if nargin < 9 || isempty(usefftfilt)
        usefftfilt = 0;
    end
    
else
    options = varargin;
end

% process multiple datasets -------------------------
if length(EEG) > 1
    if nargin < 2
        [ EEG, com ] = eeg_eval( 'pop_eegfiltnew', EEG, 'warning', 'on', 'params', options );
    else
        [ EEG, com ] = eeg_eval( 'pop_eegfiltnew', EEG, 'params', options );
    end
    return;
end

% decode inputs -------------
fieldlist = { 'locutoff'           'real'       []            [];
    'hicutoff'           'real'       []            [];
    'filtorder'          'integer'    []            [];
    'revfilt'            'integer'    [0 1]         0;
    'usefft'             'integer'    [0 1]         0;
    'usefftfilt'         'integer'    [0 1]         0;
    'minphase'           'integer'    [0 1]         0;
    'plotfreqz'          'integer'    [0 1]         0;
    'channels'      {'cell' 'string' 'integer' } []                {};
    'chantype'      {'cell' 'string'} []                {}  };
g = finputcheck( options, fieldlist, 'pop_eegfiltnew');
if ischar(g), error(g); end
if isempty(g.minphase), g.minphase = 0; end
if ~isempty(g.chantype)
    g.channels = eeg_decodechan(EEG.chanlocs, g.chantype, 'type');
elseif ~isempty(g.channels)
    g.channels = eeg_decodechan(EEG.chanlocs, g.channels);
else
    g.channels = [1:EEG.nbchan];
end
if g.usefft
    error('FFT filtering not supported. Argument is provided for backward compatibility in command line mode only.')
end

% Constants
TRANSWIDTHRATIO = 0.25;
fNyquist = EEG.srate / 2;

% Check arguments
if g.locutoff == 0, g.locutoff = []; end
if g.hicutoff == 0, g.hicutoff = []; end
if isempty(g.hicutoff) % Convert highpass to inverted lowpass
    g.hicutoff = g.locutoff;
    g.locutoff = [];
    g.revfilt = ~g.revfilt;
end
edgeArray = sort([g.locutoff g.hicutoff]);

if isempty(edgeArray)
    error('Not enough input arguments.');
end
if any(edgeArray < 0 | edgeArray >= fNyquist)
    error('Cutoff frequency out of range');
end

if ~isempty(g.filtorder) && (g.filtorder < 2 || mod(g.filtorder, 2) ~= 0)
    error('Filter order must be a real, even, positive integer.')
end

% Max stop-band width
maxTBWArray = edgeArray; % Band-/highpass
if g.revfilt == 0 % Band-/lowpass
    maxTBWArray(end) = fNyquist - edgeArray(end);
elseif length(edgeArray) == 2 % Bandstop
    maxTBWArray = diff(edgeArray) / 2;
end
maxDf = min(maxTBWArray);

% Transition band width and filter order
if isempty(g.filtorder)
    
    % Default filter order heuristic
    if g.revfilt == 1 % Highpass and bandstop
        df = min([max([maxDf * TRANSWIDTHRATIO 2]) maxDf]);
    else % Lowpass and bandpass
        df = min([max([edgeArray(1) * TRANSWIDTHRATIO 2]) maxDf]);
    end
    
    g.filtorder = 3.3 / (df / EEG.srate); % Hamming window
    g.filtorder = ceil(g.filtorder / 2) * 2; % Filter order must be even.
    
else
    
    df = 3.3 / g.filtorder * EEG.srate; % Hamming window
    g.filtorderMin = ceil(3.3 ./ ((maxDf * 2) / EEG.srate) / 2) * 2;
    g.filtorderOpt = ceil(3.3 ./ (maxDf / EEG.srate) / 2) * 2;
    if g.filtorder < g.filtorderMin
        error('Filter order too low. Minimum required filter order is %d. For better results a minimum filter order of %d is recommended.', g.filtorderMin, g.filtorderOpt)
    elseif g.filtorder < g.filtorderOpt
        warning('firfilt:filterOrderLow', 'Transition band is wider than maximum stop-band width. For better results a minimum filter order of %d is recommended. Reported might deviate from effective -6dB cutoff frequency.', g.filtorderOpt)
    end
    
end

filterTypeArray = {'lowpass', 'bandpass'; 'highpass', 'bandstop (notch)'};
% fprintf('pop_eegfiltnew() - performing %d point %s filtering.\n',
% g.filtorder + 1, filterTypeArray{g.revfilt + 1, length(edgeArray)})
% fprintf('pop_eegfiltnew() - transition band width: %.4g Hz\n', df)
% fprintf('pop_eegfiltnew() - passband edge(s): %s Hz\n',
% mat2str(edgeArray))

% Passband edge to cutoff (transition band center; -6 dB)
dfArray = {df, [-df, df]; -df, [df, -df]};
cutoffArray = edgeArray + dfArray{g.revfilt + 1, length(edgeArray)} / 2;
% fprintf('pop_eegfiltnew() - cutoff frequency(ies) (-6 dB): %s Hz\n',
% mat2str(cutoffArray))

% Window
winArray = windows('hamming', g.filtorder + 1);

% Filter coefficients
if g.revfilt == 1
    filterTypeArray = {'high', 'stop'};
    b = firws(g.filtorder, cutoffArray / fNyquist, filterTypeArray{length(cutoffArray)}, winArray);
else
    b = firws(g.filtorder, cutoffArray / fNyquist, winArray);
end

if g.minphase
    disp('pop_eegfiltnew() - converting filter to minimum-phase (non-linear!)');
    b = minphaserceps(b);
    causal = 1;
    dir = '(causal)';
else
    causal = 0;
    dir = '(zero-phase, non-causal)';
end

% Plot frequency response
if g.plotfreqz
    try
        freqz(b, 1, 8192, EEG.srate);
    catch
        warning( 'Plotting of frequency response requires signal processing toolbox.' )
    end
end

% Filter
if g.minphase || g.usefftfilt
    disp(['pop_eegfiltnew() - filtering the data ' dir]);
    EEG = firfiltsplit(EEG, b, causal, g.usefftfilt, g.channels);
else
    %     disp(['pop_eegfiltnew() - filtering the data ' dir]);
    EEG = firfilt(EEG, b, [], g.channels);
end

% History string
com = sprintf('EEG = pop_eegfiltnew(EEG, %s);', vararg2str(options));

end
function EEG = firfilt(EEG, b, nFrames, chaninds)

if nargin < 2
    error('Not enough input arguments.');
end
if nargin < 3 || isempty(nFrames)
    nFrames = 1000;
end
if nargin < 4
    chaninds = 1:size(EEG.data,1);
end

% Filter's group delay
if mod(length(b), 2) ~= 1
    error('Filter order is not even.');
end
groupDelay = (length(b) - 1) / 2;

% Find data discontinuities and reshape epoched data
if EEG.trials > 1 % Epoched data
    EEG.data = reshape(EEG.data, [EEG.nbchan EEG.pnts * EEG.trials]);
    dcArray = 1 : EEG.pnts : EEG.pnts * (EEG.trials + 1);
else % Continuous data
    dcArray = [findboundaries(EEG.event) EEG.pnts + 1];
end

% Initialize progress indicator
nSteps = 20;
step = 0;
% fprintf(1, 'firfilt(): |');
strLength = fprintf(1, [repmat(' ', 1, nSteps - step) '|   0%%']);
tic

for iDc = 1:(length(dcArray) - 1)
    
    % Pad beginning of data with DC constant and get initial conditions
    ziDataDur = min(groupDelay, dcArray(iDc + 1) - dcArray(iDc));
    [temp, zi] = filter(b, 1, double([EEG.data(chaninds, ones(1, groupDelay) * dcArray(iDc)) ...
        EEG.data(chaninds, dcArray(iDc):(dcArray(iDc) + ziDataDur - 1))]), [], 2);
    
    blockArray = [(dcArray(iDc) + groupDelay):nFrames:(dcArray(iDc + 1) - 1) dcArray(iDc + 1)];
    for iBlock = 1:(length(blockArray) - 1)
        
        % Filter the data
        [EEG.data(chaninds, (blockArray(iBlock) - groupDelay):(blockArray(iBlock + 1) - groupDelay - 1)), zi] = ...
            filter(b, 1, double(EEG.data(chaninds, blockArray(iBlock):(blockArray(iBlock + 1) - 1))), zi, 2);
        
        % Update progress indicator
        [step, strLength] = mywaitbar((blockArray(iBlock + 1) - groupDelay - 1), size(EEG.data, 2), step, nSteps, strLength);
    end
    
    % Pad end of data with DC constant
    temp = filter(b, 1, double(EEG.data(chaninds, ones(1, groupDelay) * (dcArray(iDc + 1) - 1))), zi, 2);
    EEG.data(chaninds, (dcArray(iDc + 1) - ziDataDur):(dcArray(iDc + 1) - 1)) = ...
        temp(:, (end - ziDataDur + 1):end);
    
    % Update progress indicator
    [step, strLength] = mywaitbar((dcArray(iDc + 1) - 1), size(EEG.data, 2), step, nSteps, strLength);
    
end

% Reshape epoched data
if EEG.trials > 1
    EEG.data = reshape(EEG.data, [EEG.nbchan EEG.pnts EEG.trials]);
end

% Deinitialize progress indicator
fprintf(1, '\n')

end

function [step, strLength] = mywaitbar(compl, total, step, nSteps, strLength)

progStrArray = '/-\|';
tmp = floor(compl / total * nSteps);
if tmp > step
    fprintf(1, [repmat('\b', 1, strLength) '%s'], repmat('=', 1, tmp - step))
    step = tmp;
    ete = ceil(toc / step * (nSteps - step));
    % strLength = fprintf(1, [repmat(' ', 1, nSteps - step) '%s %3d%%, ETE
    % %02d:%02d'], progStrArray(mod(step - 1, 4) + 1), floor(step * 100 /
    % nSteps), floor(ete / 60), mod(ete, 60));
end

end




