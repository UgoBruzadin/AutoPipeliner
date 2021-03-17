clc
clear
NumberOfFieldsAndFieldSpace = [2 2 1 .4];

Row1 = { { 'style' 'text' 'string' 'Visual Inspection' 'fontweight' 'bold' } ...
    {} ...
    {  'style' 'text' 'string' '' } ...
    {  'style' 'text' 'string' '' } ...
    {  'style' 'text' 'string' '' } };

InputPathway  = { { 'style' 'text' 'string' 'Input Pathway' } ...
    { 'style' 'edit' 'string' '' } ...
    { 'style' 'text' 'string' '' } ...
    { 'style' 'text' 'string' '' } };

OutputPathway  = { { 'style' 'text' 'string' 'Output Pathway' } ...
    { 'style' 'edit' 'string' '' } ...
    { 'style' 'text' 'string' '' } ...
    { 'style' 'text' 'string' '' } };

OutputName  = { { 'style' 'text' 'string' 'Save Excel with name' } ...
    { 'style' 'edit' 'string' '' } ...
    { 'style' 'text' 'string' '' } ...
    { 'style' 'text' 'string' '' } };

StartingPoint  = { { 'style' 'text' 'string' 'Number of file to start a' } ...
    { 'style' 'edit' 'string' '1' } ...
    { 'style' 'text' 'string' '' } ...
    { 'style' 'text' 'string' '' } };
allGeom = { 1 NumberOfFieldsAndFieldSpace };

Row1 = [ Row1(:)' InputPathway(:)'];
allGeom{end+1} = NumberOfFieldsAndFieldSpace;
Row1 = [ Row1(:)' OutputPathway(:)'];
allGeom{end+1} = NumberOfFieldsAndFieldSpace;
Row1 = [ Row1(:)' OutputName(:)'];
allGeom{end+1} = NumberOfFieldsAndFieldSpace;
Row1 = [ Row1(:)' StartingPoint(:)'];
allGeom{end+1} = NumberOfFieldsAndFieldSpace;
eeglab;
res = inputguiMG(allGeom, Row1);
movegui('center')

if isempty(res)
    return
end

List1Path = string(res(1,1));
List2Path = string(res(1,2));
OutName = string(res(1,3));
StartA1File = str2double(res(1,4));
cd (List1Path);
fileINPUT = pwd;
mkdir HandCheckedAlready
MoveAfterFinished = strcat(fileINPUT,'\','HandCheckedAlready');
file1 = dir('*.set');
cd (List2Path);
fileOUTPUT = pwd;
ExcelSheet = [];
ListIndex = 1;
for i=StartA1File:length(file1)
    EEG = pop_loadset(file1(i).name, fileINPUT,  'all','all','all','all','auto');
    %     assignin('base','EEGMG',EEG)
    clear BadCompGUI
    clear BadChanGUI
    clear BandFFTGUI
    clear ViewComps
    %%%%%% Comp and Chan List - Start
    clear h
    h.f = figure('Name','Bad Channel Selection','units','pixels','position',[450,450,450,450],'toolbar','none','menu','none');
    MaxColumns = ceil(EEG.nbchan/4); % NumberofColumns = 4
    for Ci = 1 : EEG.nbchan
        if Ci <= MaxColumns
            Adjectment1yaxis = 400 - (20*Ci);
            ChanNum = strcat('Chan',32,num2str(Ci));
            h.c(Ci) = uicontrol('style','checkbox','units','pixels','position',[10,Adjectment1yaxis,100,15],'string',ChanNum);
        end
        if Ci > MaxColumns && Ci <= MaxColumns*2
            Adjectment1yaxis = 400 - (20*(Ci-MaxColumns));
            ChanNum = strcat('Chan',32,num2str(Ci));
            h.c(Ci) = uicontrol('style','checkbox','units','pixels','position',[100,Adjectment1yaxis,100,15],'string',ChanNum);
        end
        if Ci > MaxColumns*2 && Ci <= MaxColumns*3
            Adjectment1yaxis = 400 - (20*(Ci-MaxColumns*2));
            ChanNum = strcat('Chan',32,num2str(Ci));
            h.c(Ci) = uicontrol('style','checkbox','units','pixels','position',[190,Adjectment1yaxis,100,15],'string',ChanNum);
        end
        if Ci > MaxColumns*3 && Ci <= MaxColumns*4
            Adjectment1yaxis = 400 - (20*(Ci-MaxColumns*3));
            ChanNum = strcat('Chan',32,num2str(Ci));
            h.c(Ci) = uicontrol('style','checkbox','units','pixels','position',[280,Adjectment1yaxis,100,15],'string',ChanNum);
        end
    end
    h.p = uicontrol('style','pushbutton','units','pixels','position',[40,5,200,20],'string','Confirm and Close');
    set(h.p, 'callback', @(src, event)BadChan_p_call(src, event, h));
    sgtitle('Bad Channel Selection');
    movegui('northwest')
    %BadComp
    clear g
    g.f = figure('Name','Bad Comp Selection','units','pixels','position',[450,450,450,450],'toolbar','none','menu','none');
    MaxColumns = ceil(size(EEG.icaweights,1)/4); % NumberofColumns = 4
    for Ci = 1 : size(EEG.icaweights,1)
        if Ci <= MaxColumns
            Adjectment1yaxis = 400 - (20*Ci);
            CganNum = strcat('Comp',32,num2str(Ci));
            g.c(Ci) = uicontrol('style','checkbox','units','pixels','position',[10,Adjectment1yaxis,100,15],'string',CganNum);
        end
        if Ci > MaxColumns && Ci <= MaxColumns*2
            Adjectment1yaxis = 400 - (20*(Ci-MaxColumns));
            CganNum = strcat('Comp',32,num2str(Ci));
            g.c(Ci) = uicontrol('style','checkbox','units','pixels','position',[100,Adjectment1yaxis,100,15],'string',CganNum);
        end
        if Ci > MaxColumns*2 && Ci <= MaxColumns*3
            Adjectment1yaxis = 400 - (20*(Ci-MaxColumns*2));
            CganNum = strcat('Comp',32,num2str(Ci));
            g.c(Ci) = uicontrol('style','checkbox','units','pixels','position',[190,Adjectment1yaxis,100,15],'string',CganNum);
        end
        if Ci > MaxColumns*3 && Ci <= MaxColumns*4
            Adjectment1yaxis = 400 - (20*(Ci-MaxColumns*3));
            CganNum = strcat('Comp',32,num2str(Ci));
            g.c(Ci) = uicontrol('style','checkbox','units','pixels','position',[280,Adjectment1yaxis,100,15],'string',CganNum);
        end
    end
    g.p = uicontrol('style','pushbutton','units','pixels','position',[10,5,200,20],'string','Confirm and Close');
    g.p1 = uicontrol('style','pushbutton','units','pixels','position',[230,5,200,20],'string','View Selected Comps');
    g.pEEG = EEG;
    set(g.p, 'callback', @(src, event)BadComp_p_call(src, event, g));
    set(g.p1, 'callback', @(src, event)BadComp_p_call(src, event, g));
    sgtitle('Bad Comp Selection');
    movegui('southwest')
    %%%%%% Comp and Chan List - End
    clear f
    f.f = figure('Name','Bad FFT Band Selection','units','pixels','position',[250,450,250,150],'toolbar','none','menu','none');
    f.c(1) = uicontrol('style','checkbox','units','pixels','position',[10,105,175,15],'string','Delta brainwaves (1-3 Hz)');
    f.c(2) = uicontrol('style','checkbox','units','pixels','position',[10,90,175,15],'string','Theta brainwaves (4-7 Hz)');
    f.c(3) = uicontrol('style','checkbox','units','pixels','position',[10,75,300,15],'string','Alpha brainwaves (8-12 Hz)');
    f.c(4) = uicontrol('style','checkbox','units','pixels','position',[10,60,300,15],'string','Beta brainwaves (13–38 Hz)');
    f.c(5) = uicontrol('style','checkbox','units','pixels','position',[10,45,300,15],'string','Gamma brainwaves (39–42 Hz)');
    f.c(6) = uicontrol('style','checkbox','units','pixels','position',[10,30,300,15],'string','Plus ultra brainwaves (43+ Hz)');
    f.p = uicontrol('style','pushbutton','units','pixels','position',[40,5,200,20],'string','Confirm and Close');
    set(f.p, 'callback', @(src, event)BandFFT_p_call(src, event, f));
    sgtitle('Bad FFT Band Selection');
    try
        axes('Position',[.7 .57 .2 .2])
        gifplayer('Alpha.gif',.1)
        title('Your Brain')
    catch
        %         DeletefristPlot = get(gcf,'children');
        %         delete(DeletefristPlot(1))
    end
    movegui('west')
    
    EEG = eeg_checkset( EEG );
    
    clear ZZ
    ZZ.f = figure('Name','Screen Shot Desktop','units','pixels','position',[250,450,250,150],'toolbar','none','menu','none');
    ZZ.c(1) = uicontrol('style','checkbox','units','pixels','position',[10,105,175,15],'string','Screen Shot Desktop');
    ZZ.n(1) = uicontrol('style','checkbox','units','pixels','position',[100,205,175,15],'string',file1(i).name);
    ZZ.pw(1) = uicontrol('style','checkbox','units','pixels','position',[100,305,175,15],'string',fileOUTPUT);
    ZZ.p = uicontrol('style','pushbutton','units','pixels','position',[40,5,200,20],'string','Take Picture');
    set(ZZ.p, 'callback', @(src, event)ScreenShot_p_call(src, event, ZZ));
    movegui('east')
    
    %     clear ff
    %     ff.f = figure('Name','Open Comp Maps','units','pixels','position',[250,450,250,150],'toolbar','none','menu','none');
    %     ff.c(1) = uicontrol('style','checkbox','units','pixels','position',[10,105,175,15],'string','Open Comp Maps');
    %     ff.p = uicontrol('style','pushbutton','units','pixels','position',[40,5,200,20],'string','Confirm and Close');
    %     set(ff.p, 'callback', @(src, event)viewprops_p_call(src, event, ff));
    %     movegui('east')
    figure; pop_spectopo(EEG, 1, [0  4094], 'EEG' , 'freq', [0.5 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 18 20 22 26 30], 'freqrange',[0 55],'winsize',2048,'electrodes','off');
    movegui('north')
    %     EEG = pop_iclabel(EEG, 'default');
    %     pop_viewprops( EEG, 0, [1:size(EEG.icaweights,1)], {'freqrange', [2 80]}, {}, 1, 'ICLabel' );
    %     movegui('south')
    pop_eegplotMG( EEG, 1, 1, 0);
    movegui('north')
    pop_eegplotMG( EEG, 0, 1, 0);
    movegui('south')
    %List Problem GUI
    Row1 = { { 'style' 'text' 'string' 'Visual Inspection' 'fontweight' 'bold' } ...
        {} ...
        {  'style' 'text' 'string' '' } ...
        {  'style' 'text' 'string' '' } ...
        {  'style' 'text' 'string' '' } };
    
    ProblemsBadEpoch  = { { 'style' 'text' 'string' 'Data: Bad Epoches' } ...
        { 'style' 'edit' 'string' 'Mark In scroll' } ...
        { 'style' 'text' 'string' '' } ...
        { 'style' 'text' 'string' '' } };
    
    ProblemsBadPCAScroll  = { { 'style' 'text' 'string' 'Comp: Bad Epoches' } ...
        { 'style' 'edit' 'string' 'Mark In scroll' } ...
        { 'style' 'text' 'string' '' } ...
        { 'style' 'text' 'string' '' } };
    
    ProblemsBadChannel  = { { 'style' 'text' 'string' 'Bad Channel' } ...
        { 'style' 'edit' 'string' 'Mark In Boxes' } ...
        { 'style' 'text' 'string' '' } ...
        { 'style' 'text' 'string' '' } };
    
    ProblemsBadPCA  = { { 'style' 'text' 'string' 'Bad PCA' } ...
        { 'style' 'edit' 'string' 'Mark In Boxes' } ...
        { 'style' 'text' 'string' '' } ...
        { 'style' 'text' 'string' '' } };
    
    ProblemsBadFFT  = { { 'style' 'text' 'string' 'Bad FFT' } ...
        { 'style' 'edit' 'string' 'Mark In Boxes' } ...
        { 'style' 'text' 'string' '' } ...
        { 'style' 'text' 'string' '' } };
    
    ExitLoop  = { { 'style' 'text' 'string' 'Exist Loop and save excel' } ...
        { 'style' 'edit' 'string' 'N' } ...
        { 'style' 'text' 'string' '' } ...
        { 'style' 'text' 'string' '' } };
    
    allGeom = { 1 NumberOfFieldsAndFieldSpace };
    
    Row1 = [ Row1(:)' ProblemsBadEpoch(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Row1 = [ Row1(:)' ProblemsBadPCAScroll(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Row1 = [ Row1(:)' ProblemsBadChannel(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Row1 = [ Row1(:)' ProblemsBadPCA(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Row1 = [ Row1(:)' ProblemsBadFFT(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Row1 = [ Row1(:)' ExitLoop(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    res = inputguiMG(allGeom, Row1);
    
    if isempty(res)
        return
    end
    
    if exist('BadChanGUI') == 0
        BadChanGUI = '';
    end
    if exist('BadCompGUI') == 0
        BadCompGUI = '';
    end
    if exist('BandFFTGUI') == 0
        BandFFTGUI = 'None'
    end
    if isempty(EEG.reject.rejmanual) == 0
        [Datarow,Datacol] = find(EEG.reject.rejmanual);
        DataMarktoCell = 1;
        if size(Datacol,2)> 0
            for j=1:size(Datacol,2)
                if DataMarktoCell == 1
                    AllEpochesData = string(Datacol(1,j));
                    AllEpochesData =  strcat(AllEpochesData);
                    DataMarktoCell = 0;
                else
                    CurrentData = string(Datacol(1,j));
                    AllEpochesData =  strcat(AllEpochesData,',',CurrentData);
                end
            end
        end
        res(1,1) = {AllEpochesData};
    else
        res(1,1) = {'None'};
    end
    
    if isempty(EEG.reject.icarejmanual) == 0
        [Comprow,Compcol] = find(EEG.reject.icarejmanual);
        DataMarktoCell = 1;
        if size(Compcol,2)> 0
            for j=1:size(Compcol,2)
                if DataMarktoCell == 1
                    AllEpochesData = string(Compcol(1,j));
                    AllEpochesData =  strcat(AllEpochesData);
                    DataMarktoCell = 0;
                else
                    CurrentData = string(Compcol(1,j));
                    AllEpochesData =  strcat(AllEpochesData,',',CurrentData);
                end
            end
        end
        res(1,2) = {AllEpochesData};
    else
        res(1,2) = {'None'};
    end
    
    if isempty(BadChanGUI) == 0
        DataMarktoCell = 1;
        if size(BadChanGUI,2)> 0
            for j=1:size(BadChanGUI,2)
                if DataMarktoCell == 1
                    AllChanData = string(BadChanGUI(1,j));
                    AllChanData =  strcat(AllChanData);
                    DataMarktoCell = 0;
                else
                    CurrentData = string(BadChanGUI(1,j));
                    AllChanData =  strcat(AllChanData,',',CurrentData);
                end
            end
        end
        res(1,3) = {AllChanData};
    else
        res(1,3) = {'None'};
    end
    
    if isempty(BadCompGUI) == 0
        DataMarktoCell = 1;
        if size(BadCompGUI,2)> 0
            for j=1:size(BadCompGUI,2)
                if DataMarktoCell == 1
                    AllCompData = string(BadCompGUI(1,j));
                    AllCompData =  strcat(AllCompData);
                    DataMarktoCell = 0;
                else
                    CurrentData = string(BadCompGUI(1,j));
                    AllCompData =  strcat(AllCompData,',',CurrentData);
                end
            end
        end
        res(1,4) = {AllCompData};
    else
        res(1,4) = {'None'};
    end
    res(1,5) = {BandFFTGUI};
    
    close(gcf);
    close(gcf);
    close(gcf);
    close(gcf);
    close(gcf);
    close(gcf);
    close(gcf);
    if ListIndex == 1
        ForExcelSheet = [file1(i).name res(1,:)];
        ListIndex = 0;
    else
        CurrentForExcelSheet =[file1(i).name res(1,:)];
        ForExcelSheet = [ForExcelSheet; CurrentForExcelSheet];
    end
    
    tf0 = strcmp('Y',res(1,6));
    tf1 = strcmp('Yes',res(1,6));
    tf2 = strcmp('y',res(1,6));
    tf3 = strcmp('yes',res(1,6));
    Ysum = tf0+tf1+tf2+tf3;
    if Ysum > 0
        break
    end
    
        cd(fileINPUT);
        movefile(file1(i).name, MoveAfterFinished)
        movefile(strcat(file1(i).name(1:end-4),'.fdt'), MoveAfterFinished);
        cd (fileOUTPUT);
end
cd (fileOUTPUT);
ExcelSheetTitles0 = [];
ExcelSheetTitles0{1,1} = 'File Name';
ExcelSheetTitles0{1,2} = 'Data: Bad Epoch';
ExcelSheetTitles0{1,3} = 'Comp: Bad Epoch';
ExcelSheetTitles0{1,4} = 'Bad Channel';
ExcelSheetTitles0{1,5} = 'Bad PCA';
ExcelSheetTitles0{1,6} = 'Bad FFT';
ExcelSheetTitles0{1,7} = 'Exit loop';

ExcelSheet = [ExcelSheetTitles0 ;ForExcelSheet];
t = datestr(now, 'mm_dd_yyyy-HHMM');
t = string(t);
Report_Name = strcat(OutName,'_', t(1,1), '.xlsx');
xlswrite(Report_Name,ExcelSheet);





%%%Button Scripting % For fun later
% if confirm ~= 0
%     ButtonName=questdlg2('Are you sure, you want to reject the labeled trials ?', ...
%         'Reject pre-labelled epochs -- pop_rejepoch()', 'NO', 'YES', 'YES');
%     switch ButtonName,
%         case 'NO',
%             disp('Operation cancelled');
%             return;
%         case 'YES',
%             disp('Compute new dataset');
%     end % switch
%
% end



%%%%%%%%%DO NOT TOUCH ANYTHING BELOW THIS LINE%%%%%%%%%%%%%%
function ScreenShot_p_call(~, ~, ZZ)
t = datestr(now, 'mm_dd_yyyy_HHMM');
t = string(t);
set(0,'units','pixels')
results = get(0,'ScreenSize');
CD0 = pwd;
cd(ZZ.pw.String);
try
    ScreenName = convertStringsToChars(strcat(ZZ.n.String(1:end-4),'_',t(1,1),'.bmp'));
catch
    ScreenName = convertStringsToChars(strcat(ZZ.n.String,'_NameTooLong_',t(1,1),'.bmp'));
end
screencapture(0,  [0,30,results(1,3),results(1,4)],ScreenName)
% V = imread(ScreenName);
% figure;
% image(V);
%
% [imagedata imagemap] = imread(ScreenName);
% imshow(imagedata, imagemap);
cd(CD0);
end

function OutputComp = BadComp_p_call(~, ~, g)
vals = get(g.c,'Value');
OutputComp = find([vals{:}]);
% if isempty(OutputComp)
%     OutputComp = 'none';
% else
%end
if g.p1.Value == 1
    g.pEEG = pop_iclabel(g.pEEG, 'default');
    pop_viewprops( g.pEEG, 0, [OutputComp], {'freqrange', [2 80]}, {}, 0, 'ICLabel' );
else
    assignin('base','BadCompGUI',OutputComp)
    close(gcf)
end
end
% Pushbutton callback For Chan
function OutputChan = BadChan_p_call(~, ~, h)
vals = get(h.c,'Value');
OutputChan = find([vals{:}]);
% if isempty(OutputChan)
%     OutputChan = 'none';
% end
assignin('base','BadChanGUI',OutputChan)
close(gcf)
end
function OutputChan = viewprops_p_call(~, ~, ff)
EEGMG = pop_iclabel(EEGMG, 'default');
pop_viewprops( EEGMG, 0, [1:size(EEGMG.icaweights,1)], {'freqrange', [2 80]}, {}, 1, 'ICLabel' );
movegui('south')
close(gcf)
end

% Pushbutton callback For FFT
function OutputBandFFT = BandFFT_p_call(~, ~, f)
vals = get(f.c,'Value');
OutputBandFFT = find([vals{:}]);
% if isempty(OutputBandFFT)
%     OutputBandFFT = 'none';
% end
if ismember(1,OutputBandFFT)== 1
    D = 'Delta,';
else
    D = '';
end
if ismember(2,OutputBandFFT)== 1
    T = 'Theta,';
else
    T = '';
end
if ismember(3,OutputBandFFT)== 1
    A = 'Alpha,';
else
    A = '';
end
if ismember(4,OutputBandFFT)== 1
    B = 'Beta,';
else
    B = '';
end
if ismember(5,OutputBandFFT)== 1
    G = 'Gamma,';
else
    G = '';
end
if ismember(6,OutputBandFFT)== 1
    P = 'Plus Ultra,';
else
    P = '';
end
CatNameOutput = strcat(D,T,A,B,G,P);

if isempty(CatNameOutput)== 1
    CatNameOutput = {'None'};
end
assignin('base','BandFFTGUI',CatNameOutput)
close(gcf)
end
function [result, userdat, strhalt, resstruct, instruct] = inputguiMG(varargin)

if nargin < 2
    help inputgui;
    return;
end

% decoding input and backward compatibility
% -----------------------------------------
if ischar(varargin{1})
    options = varargin;
else
    options = { 'geometry' 'uilist' 'helpcom' 'title' 'userdata' 'mode' 'geomvert' };
    options = { options{1:length(varargin)}; varargin{:} };
    options = options(:)';
end

% checking inputs
% ---------------
g = finputcheck(options, { 'geom'     'cell'                []      {}; ...
    'geometry' {'cell','integer'}    []      []; ...
    'uilist'   'cell'                []      {}; ...
    'helpcom'  { 'string','cell' }   { [] [] }      ''; ...
    'title'    'string'              []      ''; ...
    'eval'     'string'              []      ''; ...
    'helpbut'  'string'              []      'Help'; ...
    'skipline' 'string'              { 'on' 'off' } 'on'; ...
    'addbuttons' 'string'            { 'on' 'off' } 'on'; ...
    'userdata' ''                    []      []; ...
    'getresult' 'real'               []      []; ...
    'minwidth'  'real'               []      200; ...
    'screenpos' ''                   []      []; ...
    'mode'     ''                    []      'normal'; ...
    'geomvert' 'real'                []       [] ...
    }, 'inputgui');
if ischar(g), error(g); end

if isempty(g.getresult)
    if ischar(g.mode)
        fig = figure('visible', 'off');
        set(fig, 'name', g.title);
        set(fig, 'userdata', g.userdata);
        if ~iscell( g.geometry )
            oldgeom = g.geometry;
            g.geometry = {};
            for row = 1:length(oldgeom)
                g.geometry = { g.geometry{:} ones(1, oldgeom(row)) };
            end
        end
        
        % skip a line
        if strcmpi(g.skipline, 'on')
            g.geometry = { g.geometry{:} [1] };
            if ~isempty(g.geom)
                for ind = 1:length(g.geom)
                    g.geom{ind}{2} = g.geom{ind}{2}+1; % add one row
                end
                g.geom = { g.geom{:} {1 g.geom{1}{2} [0 g.geom{1}{2}-2] [1 1] } };
            end
            g.uilist   = { g.uilist{:}, {} };
        end
        
        % add buttons
        if strcmpi(g.addbuttons, 'on')
            g.geometry = { g.geometry{:} [1 1 1 1] };
            if ~isempty(g.geom)
                for ind = 1:length(g.geom)
                    g.geom{ind}{2} = g.geom{ind}{2}+1; % add one row
                end
                g.geom = { g.geom{:} ...
                    {4 g.geom{1}{2} [0 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [1 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [2 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [3 g.geom{1}{2}-1] [1 1] } };
            end
            if ~isempty(g.helpcom)
                if ~iscell(g.helpcom)
                    g.uilist = { g.uilist{:}, { 'width' 80 'align' 'left' 'Style', 'pushbutton', 'string', g.helpbut, 'tag', 'help', 'callback', g.helpcom } {} };
                else
                    g.uilist = { g.uilist{:}, { 'width' 80 'align' 'left' 'Style', 'pushbutton', 'string', 'Help gui', 'callback', g.helpcom{1} } };
                    g.uilist = { g.uilist{:}, { 'width' 80 'align' 'left' 'Style', 'pushbutton', 'string', 'More help', 'callback', g.helpcom{2} } };
                end
            else
                g.uilist = { g.uilist{:}, {} {} };
            end
            g.uilist = { g.uilist{:}, { 'width' 80 'align' 'right' 'Style', 'pushbutton', 'string', 'Cancel', 'tag' 'cancel' 'callback', 'close gcbf' } };
            g.uilist = { g.uilist{:}, { 'width' 80 'align' 'right' 'stickto' 'on' 'Style', 'pushbutton', 'tag', 'ok', 'string', 'OK', 'callback', 'set(gcbo, ''userdata'', ''retuninginputui'');' } };
        end
        
        % add the three buttons (CANCEL HELP OK) at the bottom of the GUI
        % ---------------------------------------------------------------
        if ~isempty(g.geom)
            [tmp, tmp2, allobj] = supergui( 'fig', fig, 'minwidth', g.minwidth, 'geom', g.geom, 'uilist', g.uilist, 'screenpos', g.screenpos );
        elseif isempty(g.geomvert)
            [tmp, tmp2, allobj] = supergui( 'fig', fig, 'minwidth', g.minwidth, 'geomhoriz', g.geometry, 'uilist', g.uilist, 'screenpos', g.screenpos );
        else
            if strcmpi(g.skipline, 'on'),  g.geomvert = [g.geomvert(:)' 1]; end
            if strcmpi(g.addbuttons, 'on'),g.geomvert = [g.geomvert(:)' 1]; end
            [tmp, tmp2, allobj] = supergui( 'fig', fig, 'minwidth', g.minwidth, 'geomhoriz', g.geometry, 'uilist', g.uilist, 'screenpos', g.screenpos, 'geomvert', g.geomvert(:)' );
        end
    else
        fig = g.mode;
        set(findobj('parent', fig, 'tag', 'ok'), 'userdata', []);
        allobj = findobj('parent',fig);
        allobj = allobj(end:-1:1);
    end
    
    % evaluate command before waiting?
    % --------------------------------
    if ~isempty(g.eval), eval(g.eval); end
    instruct = outstruct(allobj); % Getting default values in the GUI.
    
    % create figure and wait for return
    % ---------------------------------
    if ischar(g.mode) && (strcmpi(g.mode, 'plot') || strcmpi(g.mode, 'return') )
        if strcmpi(g.mode, 'plot')
            return; % only plot and returns
        end
    else
        waitfor( findobj('parent', fig, 'tag', 'ok'), 'userdata');
    end
else
    fig = g.getresult;
    allobj = findobj('parent',fig);
    allobj = allobj(end:-1:1);
end

result    = {};
userdat   = [];
strhalt   = '';
resstruct = [];

if ~(ishandle(fig)), return; end % Check if figure still exist

% output parameters
% -----------------
strhalt = get(findobj('parent', fig, 'tag', 'ok'), 'userdata');
[resstruct,result] = outstruct(allobj); % Output parameters
userdat = get(fig, 'userdata');

if isempty(g.getresult) && ischar(g.mode) && ( strcmp(g.mode, 'normal') || strcmp(g.mode, 'return') )
    close(fig);
end
drawnow; % for windows

    function [resstructout, resultout] = outstruct(allobj)
        counter   = 1;
        resultout    = {};
        resstructout = [];
        
        for index=1:length(allobj)
            if isnumeric(allobj), currentobj = allobj(index);
            else                  currentobj = allobj{index};
            end
            if isnumeric(currentobj) || ~isprop(currentobj,'GetPropertySpecification') % To allow new object handles
                try
                    objstyle = get(currentobj, 'style');
                    switch lower( objstyle )
                        case { 'listbox', 'checkbox', 'radiobutton' 'popupmenu' 'radio' }
                            resultout{counter} = get( currentobj, 'value');
                            if ~isempty(get(currentobj, 'tag')),
                                try
                                    resstructout = setfield(resstructout, get(currentobj, 'tag'), resultout{counter});
                                catch
                                    fprintf('Warning: tag "%" may not be use as field in output structure', get(currentobj, 'tag'));
                                end
                            end
                            counter = counter+1;
                        case 'edit'
                            resultout{counter} = get( currentobj, 'string');
                            if ~isempty(get(currentobj, 'tag')),
                                try
                                    resstructout = setfield(resstructout, get(currentobj, 'tag'), resultout{counter});
                                catch
                                    fprintf('Warning: tag "%" may not be use as field in output structure', get(currentobj, 'tag'));
                                end
                            end
                            counter = counter+1;
                    end
                catch, end
            else
                ps              = currentobj.GetPropertySpecification;
                resultout{counter} = arg_tovals(ps,false);
                count = 1;
                while isfield(resstructout, ['propgrid' int2str(count)])
                    count = count + 1;
                end
                resstructout = setfield(resstructout, ['propgrid' int2str(count)], arg_tovals(ps,false));
            end
        end
    end
end



%Data and Comp Scroll
% pop_eegplotMG() - Visually inspect EEG data using a scrolling display.
%                 Perform rejection or marking for rejection of visually
%                 (and/or previously) selected data portions (i.e., stretches
%                 of continuous data or whole data epochs).
% Usage:
%   >> pop_eegplotMG( EEG ) % Scroll EEG channel data. Allow marking for rejection via
%                         % button 'Update Marks' but perform no actual data rejection.
%                         % Do not show or use marks from previous visual inspections
%                         % or from semi-auotmatic rejection.
%   >> pop_eegplotMG( EEG, icacomp, superpose, reject );
%
% Graphic interface:
%   "Add to previously marked rejections" - [edit box] Either YES or NO.
%                    Command line equivalent: 'superpose'.
%   "Reject marked trials" - [edit box] Either YES or NO. Command line
%                    equivalent 'reject'.
% Inputs:
%   EEG        - input EEG dataset
%   icacomp    - type of rejection 0 = independent components;
%                                  1 = data channels. {Default: 1 = data channels}
%   superpose  - 0 = Show new marks only: Do not color the background of data portions
%                    previously marked for rejection by visual inspection. Mark new data
%                    portions for rejection by first coloring them (by dragging the left
%                    mouse button), finally pressing the 'Update Marks' or 'Reject'
%                    buttons (see 'reject' below). Previous markings from visual inspection
%                    will be lost.
%                1 = Show data portions previously marked by visual inspection plus
%                    data portions selected in this window for rejection (by dragging
%                    the left mouse button in this window). These are differentiated
%                    using a lighter and darker hue, respectively). Pressing the
%                    'Update Marks' or 'Reject' buttons (see 'reject' below)
%                    will then mark or reject all the colored data portions.
%                {Default: 0, show and act on new marks only}
%   reject     - 0 = Mark for rejection. Mark data portions by dragging the left mouse
%                    button on the data windows (producing a background coloring indicating
%                    the extent of the marked data portion).  Then press the screen button
%                    'Update Marks' to store the data portions marked for rejection
%                    (stretches of continuous data or whole data epochs). No 'Reject' button
%                    is present, so data marked for rejection cannot be actually rejected
%                    from this eegplot() window.
%                1 = Reject marked trials. After inspecting/selecting data portions for
%                    rejection, press button 'Reject' to reject (remove) them from the EEG
%                    dataset (i.e., those portions plottted on a colored background.
%                    {default: 1, mark for rejection only}
%
%  topcommand   -  Input deprecated.  Kept for compatibility with other function calls
% Outputs:
%   Modifications are applied to the current EEG dataset at the end of the
%   eegplot() call, when the user presses the 'Update Marks' or 'Reject' button.
%   NOTE: The modifications made are not saved into EEGLAB history. As of v4.2,
%   events contained in rejected data portions are remembered in the EEG.urevent
%   structure (see EEGLAB tutorial).
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: eeglab(), eegplot(), pop_rejepoch()

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This file is part of EEGLAB, see http://www.eeglab.org
% for the documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.

% 01-25-02 reformated help & license -ad
% 03-07-02 added srate argument to eegplot call -ad
% 03-27-02 added event latency recalculation for continuous data -ad

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
    
    % which set to save
    % -----------------
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
    %    	command = ['if isempty(EEG.event) EEG.event = [eegplot2event(TMPREJ, -1)];' ...
    %         'else EEG.event = [EEG.event(find(EEG.event(:,1) ~= -1),:); eegplot2event(TMPREJ, -1, [], [0.8 1 0.8])];' ...
    %         'end;'];
    %else, command = ['if isempty(EEG.event) EEG.event = [eegplot2event(TMPREJ, -1)];' ...
    %         'else EEG.event = [EEG.event(find(EEG.event(:,1) ~= -2),:); eegplot2event(TMPREJ, -1, [], [0.8 1 0.8])];' ...
    %         'end;'];
    %end
    %if reject
    %   command = ...
    %   [  command ...
    %      '[EEG.data EEG.xmax] = eegrej(EEG.data, EEG.event(find(EEG.event(:,1) < 0),3:end), EEG.xmax-EEG.xmin);' ...
    %      'EEG.xmax = EEG.xmax+EEG.xmin;' ...
    %   	'EEG.event = EEG.event(find(EEG.event(:,1) >= 0),:);' ...
    %      'EEG.icaact = [];' ...
    %      'EEG = eeg_checkset(EEG);' ];
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


function [outvar1] = eegplotMG(data, varargin); % p1,p2,p3,p4,p5,p6,p7,p8,p9)

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
%MAXEVENTSTRING = 10;
%DEFAULT_AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
% dimensions of main EEG axes
ORIGINAL_POSITION = [50 50 800 500];
matVers = version;
matVers = str2double(matVers(1:3));

if nargin < 1
    help eegplot
    return
end

% %%%%%%%%%%%%%%%%%%%%%%%%
% Setup inputs
% %%%%%%%%%%%%%%%%%%%%%%%%

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
        %        % Check  consistency of freqlimits
        %        % Check  consistency of freqs
        
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
    
    % push button: create/remove window
    % ---------------------------------
    defdowncom   = 'eegplot(''defdowncom'',   gcbf);'; % push button: create/remove window
    defmotioncom = 'eegplot(''defmotioncom'', gcbf);'; % motion button: move windows or display current position
    defupcom     = 'eegplot(''defupcom'',     gcbf);';
    defctrldowncom = 'eegplot(''topoplot'',   gcbf);'; % CTRL press and motion -> do nothing by default
    defctrlmotioncom = ''; % CTRL press and motion -> do nothing by default
    defctrlupcom = ''; % CTRL press and up -> do nothing by default
    
    try, g.srate; 		    catch, g.srate		= 256; 	end
    try, g.spacing; 			catch, g.spacing	= 0; 	end
    try, g.eloc_file; 		catch, g.eloc_file	= 0; 	end; % 0 mean numbered
    %try, g.winlength; 		catch, g.winlength	= 5; 	end; % Number of seconds of EEG displayed
    g.winlength	= 2;
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
    %try, g.dispchans; 		catch, g.dispchans  = size(data,1); end
    if size(data,1) > 30
        g.dispchans = 30;
    else
        g.dispchans = size(data,1);
    end
    
    g.dispchans  = 30;
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
    
    % g.data=data; % never used and slows down display dramatically - Ozgur 2010
    
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
    
    % max event string;  JavierLC
    % ---------------------------------
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
    
    % set defaults
    % ------------
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
    % %%%%%%%%%%%%%%%%%%%%%%%%
    % Prepare figure and axes
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
    
    % Background axis
    % ---------------
    ax0 = axes('tag','backeeg','parent',figh,...
        'Position',DEFAULT_AXES_POSITION,...
        'Box','off','xgrid','off', 'xaxislocation', 'top', 'Units', 'Normalized');
    
    % Drawing axis
    % ---------------
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
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up uicontrols
    % %%%%%%%%%%%%%%%%%%%%%%%%%
    
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
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up uimenus
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
    %'checked', 'off', 'Callback', ...
    %['g = get(gcbf, ''userdata'');' ...
    % 'g.setelectrode = ~g.setelectrode;' ...
    % 'set(gcbf, ''userdata'', g); ' ...
    % 'if ~g.setelectrode setgcbo, ''checked'', ''on''); ...
    % else set(gcbo, ''checked'', ''off''); end;'...
    % ' clear g;'] )
    
    % trials boundaries
    %uimenu('Parent',m(11),'Label','Trial boundaries', 'checked', fastif( g.trialstag(1) == -1, 'off', 'on'), 'Callback', ...
    %['hh = findobj(''tag'',''displaywin'',''parent'', findobj(''tag'',''displaymenu'',''parent'', gcbf ));' ...
    % 'hhdat = get(hh, ''userdata'');' ...
    % 'set(hh, ''userdata'', { hhdat{1},  hhdat{2}, hhdat{3}, ~hhdat{4}} ); ' ...
    %'if ~hhdat{4} set(gcbo, ''checked'', ''on''); else set(gcbo, ''checked'', ''off''); end;' ...
    %' clear hh hhdat;'] )
    
    % plot durations
    % --------------
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
        % Temporary fix to avoid warning when setting a callback and the  mode is active
        % This is failing for us http://undocumentedmatlab.com/blog/enabling-user-callbacks-during-zoom-pan
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
    
    
    % %%%%%%%%%%%%%%%%%
    % Set up autoselect
    % NOTE: commandselect{2} option has been moved to a
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
    %  set(figh, 'windowbuttondownfcn', commandpush);
    %  set(figh, 'windowbuttonmotionfcn', commandmove);
    %  set(figh, 'windowbuttonupfcn', commandrelease);
    %  set(figh, 'interruptible', 'off');
    %  set(figh, 'busyaction', 'cancel');
    
    % prepare event array if any
    % --------------------------
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
        
        % latency and duration of events
        % ------------------------------
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
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot EEG Data
    % %%%%%%%%%%%%%%%%%%%%%%%%%%
    axes(ax1)
    hold on
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Spacing I
    % %%%%%%%%%%%%%%%%%%%%%%%%%%
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
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End Main Function
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
            
            % Update edit box
            % ---------------
            g.time = max(0,min(g.time,ceil((g.frames-1)/multiplier)-g.winlength));
            if g.trialstag(1) == -1
                set(EPosition,'string',num2str(g.time));
            else
                set(EPosition,'string',num2str(g.time+1));
            end
            set(figh, 'userdata', g);
            
            lowlim = round(g.time*multiplier+1);
            highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
            
            % Plot data and update axes
            % -------------------------
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
            % plot data
            % ---------
            axes(ax1)
            hold on
            
            % plot channels whose "badchan" field is set to 1.
            % Bad channels are plotted first so that they appear behind the good
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
            
            % plot good channels on top of bad channels (if g.eloc_file(i).badchan = 0... or there is no bad channel information)
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
            
            % draw selected channels
            % ------------------------
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
            %              set(ax1, 'XTickLabel', num2str((g.freqs(1):DEFAULT_GRID_SPACING:g.freqs(end))'));
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
            
            % draw rejection windows
            % ----------------------
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
            
            % plot tags
            % ---------
            %if trialtag(1) ~= -1 & displaystatus % put tags at arbitrary places
            % 	for tmptag = trialtag
            %		if tmptag >= lowlim & tmptag <= highlim
            %			plot([tmptag-lowlim tmptag-lowlim], [0 1], 'b--');
            %		end;
            %	end
            %end
            
            % draw events if any
            % ------------------
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
                
                % find event to plot
                % ------------------
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
                    
                    % draw latency line
                    % -----------------
                    tmplat = g.eventlatencies(event2plot(index))-lowlim-1;
                    tmph   = plot([ tmplat tmplat ], ylims, 'color', g.eventcolors{ event2plot(index) }, ...
                        'linestyle', g.eventstyle { event2plot(index) }, ...
                        'linewidth', g.eventwidths( event2plot(index) ) );
                    
                    % schtefan: add Event types text above event latency line
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
                    
                    % draw duration is not 0
                    % ----------------------
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
                
                % plot trial limits
                % -----------------
                tmptag = [lowlim:highlim];
                tmpind = find(mod(tmptag-1, g.trialstag) == 0);
                for index = tmpind
                    plot([tmptag(index)-lowlim tmptag(index)-lowlim], [0 1], 'b--');
                end
                alltag = tmptag(tmpind);
                
                % compute Xticks
                % --------------
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
                
                % tag zero below is an offset used to be sure that 0 is included
                % in the absicia of the data epochs
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
                
                % find corresponding epochs
                % -------------------------
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
            
            % update edit box
            % ---------------
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
            % get dialog box
            % -------------------------------------
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
            
            % deal with abscissa
            % ------------------
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
            
            % deal with ordinate
            % ------------------
            g.elecoffset = tmpylim(1)/g.spacing;
            g.dispchans  = round(1000*(tmpylim(2)-tmpylim(1))/g.spacing)/1000;
            
            set(fig,'UserData', g);
            eegplot('updateslider', fig);
            eegplot('drawp', 0);
            eegplot('scaleeye', [], fig);
            
            % reactivate zoom if 3 arguments
            % ------------------------------
            if exist('p2', 'var') == 1
                if matVers < 8.4
                    set(gcbf, 'windowbuttondownfcn', [ 'zoom(gcbf,''down''); eegplot(''zoom'', gcbf, 1);' ]);
                else
                    % This is failing for us: http://undocumentedmatlab.com/blog/enabling-user-callbacks-during-zoom-pan
                    %               hManager = uigetmodemanager(gcbf);
                    %               [hManager.WindowListenerHandles.Enabled] = deal(false);
                    
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
            
            
            % motion button: move windows or display current position (channel, g.time and activation)
            % ----------------------------------------------------------------------------------------
            % case moved as subfunction
            % add topoplot
            % ------------
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
            
            % release button: check window consistency, add to trial boundaries
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
% function not supported under Mac
% --------------------------------
function [reshist, allbin] = myhistc(vals, intervals);

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



function [EEG, com] = pop_rejepoch( EEG, tmprej, confirm);

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
% screencapture - get a screen-capture of a figure frame, component handle, or screen area rectangle
%
% ScreenCapture gets a screen-capture of any Matlab GUI handle (including desktop,
% figure, axes, image or uicontrol), or a specified area rectangle located relative to
% the specified handle. Screen area capture is possible by specifying the root (desktop)
% handle (=0). The output can be either to an image file or to a Matlab matrix (useful
% for displaying via imshow() or for further processing) or to the system clipboard.
% This utility also enables adding a toolbar button for easy interactive screen-capture.
%
% Syntax:
%    imageData = screencapture(handle, position, target, 'PropName',PropValue, ...)
%
% Input Parameters:
%    handle   - optional handle to be used for screen-capture origin.
%                 If empty/unsupplied then current figure (gcf) will be used.
%    position - optional position array in pixels: [x,y,width,height].
%                 If empty/unsupplied then the handle's position vector will be used.
%                 If both handle and position are empty/unsupplied then the position
%                   will be retrieved via interactive mouse-selection.
%                 If handle is an image, then position is in data (not pixel) units, so the
%                   captured region remains the same after figure/axes resize (like imcrop)
%    target   - optional filename for storing the screen-capture, or the
%               'clipboard'/'printer' strings.
%                 If empty/unsupplied then no output to file will be done.
%                 The file format will be determined from the extension (JPG/PNG/...).
%                 Supported formats are those supported by the imwrite function.
%    'PropName',PropValue -
%               optional list of property pairs (e.g., 'target','myImage.png','pos',[10,20,30,40],'handle',gca)
%               PropNames may be abbreviated and are case-insensitive.
%               PropNames may also be given in whichever order.
%               Supported PropNames are:
%                 - 'handle'    (default: gcf handle)
%                 - 'position'  (default: gcf position array)
%                 - 'target'    (default: '')
%                 - 'toolbar'   (figure handle; default: gcf)
%                      this adds a screen-capture button to the figure's toolbar
%                      If this parameter is specified, then no screen-capture
%                        will take place and the returned imageData will be [].
%
% Output parameters:
%    imageData - image data in a format acceptable by the imshow function
%                  If neither target nor imageData were specified, the user will be
%                    asked to interactively specify the output file.
%
% Examples:
%    imageData = screencapture;  % interactively select screen-capture rectangle
%    imageData = screencapture(hListbox);  % capture image of a uicontrol
%    imageData = screencapture(0,  [20,30,40,50]);  % capture a small desktop region
%    imageData = screencapture(gcf,[20,30,40,50]);  % capture a small figure region
%    imageData = screencapture(gca,[10,20,30,40]);  % capture a small axes region
%      imshow(imageData);  % display the captured image in a matlab figure
%      imwrite(imageData,'myImage.png');  % save the captured image to file
%    img = imread('cameraman.tif');
%      hImg = imshow(img);
%      screencapture(hImg,[60,35,140,80]);  % capture a region of an image
%    screencapture(gcf,[],'myFigure.jpg');  % capture the entire figure into file
%    screencapture(gcf,[],'clipboard');     % capture the entire figure into clipboard
%    screencapture(gcf,[],'printer');       % print the entire figure
%    screencapture('handle',gcf,'target','myFigure.jpg'); % same as previous, save to file
%    screencapture('handle',gcf,'target','clipboard');    % same as previous, copy to clipboard
%    screencapture('handle',gcf,'target','printer');      % same as previous, send to printer
%    screencapture('toolbar',gcf);  % adds a screen-capture button to gcf's toolbar
%    screencapture('toolbar',[],'target','sc.bmp'); % same with default output filename
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
%    1.17 2016-05-16: Fix annoying warning about JavaFrame property becoming obsolete someday (yes, we know...)
%    1.16 2016-04-19: Fix for deployed application suggested by Dwight Bartholomew
%    1.10 2014-11-25: Added the 'print' target
%    1.9  2014-11-25: Fix for saving GIF files
%    1.8  2014-11-16: Fixes for R2014b
%    1.7  2014-04-28: Fixed bug when capturing interactive selection
%    1.6  2014-04-22: Only enable image formats when saving to an unspecified file via uiputfile
%    1.5  2013-04-18: Fixed bug in capture of non-square image; fixes for Win64
%    1.4  2013-01-27: Fixed capture of Desktop (root); enabled rbbox anywhere on desktop (not necesarily in a Matlab figure); enabled output to clipboard (based on Jiro Doke's imclipboard utility); edge-case fixes; added Java compatibility check
%    1.3  2012-07-23: Capture current object (uicontrol/axes/figure) if w=h=0 (e.g., by clicking a single point); extra input args sanity checks; fix for docked windows and image axes; include axes labels & ticks by default when capturing axes; use data-units position vector when capturing images; many edge-case fixes
%    1.2  2011-01-16: another performance boost (thanks to Jan Simon); some compatibility fixes for Matlab 6.5 (untested)
%    1.1  2009-06-03: Handle missing output format; performance boost (thanks to Urs); fix minor root-handle bug; added toolbar button option
%    1.0  2009-06-02: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks File Exchange</a>
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.
% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.17 $  $Date: 2016/05/16 17:59:36 $
% Ensure that java awt is enabled...
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
    
    % If neither output formats was specified (neither target nor output data)
elseif isempty(paramsStruct.target) & ~isempty(imgData)  %#ok ML6
    % Ask the user to specify a file
    %error('YMA:screencapture:noOutput','No output specified for ScreenCapture: specify the output filename and/or output data');
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

% Process optional arguments
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
        % Disregard empty propNames (may be due to users mis-interpretting the syntax help)
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
            %paramsStruct.(lower(supportedArgs{idx(1)})) = paramValue;  % incompatible with ML6
            paramsStruct = setfield(paramsStruct, lower(supportedArgs{idx(1)}), paramValue);  %#ok ML6
            % If 'toolbar' param specified, then it cannot be left empty - use gcf
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
% Convert position from handle-relative to desktop Java-based pixels
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
        % Handle was supplied but position was not, so use the handle's position
        paramsStruct.position = getPixelPos(paramsStruct.handle);
        paramsStruct.position(1:2) = 0;
        wasPositionGiven = 0;  % no false available in ML6
        
    elseif ~isnumeric(paramsStruct.position) | (length(paramsStruct.position) ~= 4)  %#ok ML6
        % Both handle & position were supplied - ensure a valid pixel position vector
        error('YMA:screencapture:invalidPosition','Invalid position vector passed to ScreenCapture: \nMust be a [x,y,w,h] numeric pixel array');
    end
    
    % Capture current object (uicontrol/axes/figure) if w=h=0 (single-click in interactive mode)
    if paramsStruct.position(3)<=0 | paramsStruct.position(4)<=0  %#ok ML6
        %TODO - find a way to single-click another Matlab figure (the following does not work)
        %paramsStruct.position = getPixelPos(ancestor(hittest,'figure'));
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
                %actualImgSize = min(parentPos(3:4));
                %dX = (parentPos(3) - actualImgSize) / 2;
                %dY = (parentPos(4) - actualImgSize) / 2;
                %parentPos(3:4) = actualImgSize;
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
                % In images, use data units rather than pixel units
                % Reverse the YDir
                ymax = max(get(hParent,'YData'));
                paramsStruct.position(2) = ymax - paramsStruct.position(2) - paramsStruct.position(4);
                % Note: it would be best to use hgconvertunits, but:
                % ^^^^  (1) it fails on Matlab 6, and (2) it doesn't accept Data units
                %paramsStruct.position = hgconvertunits(hFig, paramsStruct.position, 'Data', 'pixel', hParent);  % fails!
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
        % Compensate 4px figure boundaries = difference betweeen OuterPosition and Position
        deltaX = -1;
        deltaY = 1;
    end
    %disp(paramsStruct.position)  % for debugging
    
    % Now get the pixel position relative to the monitor
    figurePos = getPixelPos(hParent);
    desktopPos = figurePos + parentPos;
    % Now convert to Java-based pixels based on screen size
    % Note: multiple monitors are automatically handled correctly, since all
    % ^^^^  Java positions are relative to the main monitor's top-left corner
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
    % Maybe root/desktop handle (root does not have a 'Position' prop so getPixelPos croaks
    if isequal(double(hParent),0)  % =root/desktop handle;  handles case of hParent=[]
        javaX = paramsStruct.position(1) - 1;
        javaY = screenSize(4) - paramsStruct.position(2) - paramsStruct.position(4) - 1;
        paramsStruct.position = [javaX, javaY, paramsStruct.position(3:4)];
    end
end
end  % convertPos
% Interactively get the requested capture rectangle
function [positionRect, jFrameUsed, msgStr] = getInteractivePosition(hFig)
msgStr = '';
try
    % First try the invisible-figure approach, in order to
    % enable rbbox outside any existing figure boundaries
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
%hFig = getCurrentFig;
%p1 = get(hFig,'CurrentPoint');
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
% Get current figure (even if its handle is hidden)
function hFig = getCurrentFig
oldState = get(0,'showHiddenHandles');
set(0,'showHiddenHandles','on');
hFig = get(0,'CurrentFigure');
set(0,'showHiddenHandles',oldState);
end  % getCurrentFig
% Get ancestor figure - used for old Matlab versions that don't have a built-in ancestor()
function hObj = ancestor(hObj,type)
if ~isempty(hObj) & ishandle(hObj)  %#ok for Matlab 6 compatibility
    try
        hObj = get(hObj,'Ancestor');
    catch
        % never mind...
    end
    try
        %if ~isa(handle(hObj),type)  % this is best but always returns 0 in Matlab 6!
        %if ~isprop(hObj,'type') | ~strcmpi(get(hObj,'type'),type)  % no isprop() in ML6!
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
% Get position of an HG object in specified units
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
% Get pixel position of an HG object - for Matlab 6 compatibility
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
        % add the axes labels/ticks if relevant (plus a tiny margin to fix 2px label/title inconsistencies)
        if isAxes(hObj) & ~isImage(originalObj)  %#ok ML6
            tightInsets = getPos(hObj,'TightInset','pixel');
            pos = pos + tightInsets.*[-1,-1,1,1] + [-1,1,1+tightInsets(1:2)];
        end
    end
catch
    try
        % Matlab 6 did not have getpixelposition nor hgconvertunits so use the old way...
        pos = getPos(hObj,'Position','pixels');
    catch
        % Maybe the handle does not have a 'Position' prop (e.g., text/line/plot) - use its parent
        pos = getPixelPos(get(hObj,'parent'),varargin{:});
    end
end
% Handle the case of missing/invalid/empty HG handle
if isempty(pos)
    pos = [0,0,0,0];
end
end  % getPixelPos
% Adds a ScreenCapture toolbar button
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
% Java-get the actual screen-capture image data
function imgData = getScreenCaptureImageData(positionRect)
if isempty(positionRect) | all(positionRect==0) | positionRect(3)<=0 | positionRect(4)<=0  %#ok ML6
    imgData = [];
else
    % Use java.awt.Robot to take a screen-capture of the specified screen area
    rect = java.awt.Rectangle(positionRect(1), positionRect(2), positionRect(3), positionRect(4));
    robot = java.awt.Robot;
    jImage = robot.createScreenCapture(rect);
    % Convert the resulting Java image to a Matlab image
    % Adapted for a much-improved performance from:
    % http://www.mathworks.com/support/solutions/data/1-2WPAYR.html
    h = jImage.getHeight;
    w = jImage.getWidth;
    %imgData = zeros([h,w,3],'uint8');
    %pixelsData = uint8(jImage.getData.getPixels(0,0,w,h,[]));
    %for i = 1 : h
    %    base = (i-1)*w*3+1;
    %    imgData(i,1:w,:) = deal(reshape(pixelsData(base:(base+3*w-1)),3,w)');
    %end
    % Performance further improved based on feedback from Urs Schwartz:
    %pixelsData = reshape(typecast(jImage.getData.getDataStorage,'uint32'),w,h).';
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
% Return the figure to its pre-undocked state (when relevant)
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
% Copy screen-capture to the system clipboard
% Adapted from http://www.mathworks.com/matlabcentral/fileexchange/28708-imclipboard/content/imclipboard.m
function imclipboard(imgData)
% Import necessary Java classes
import java.awt.Toolkit.*
import java.awt.image.BufferedImage
import java.awt.datatransfer.DataFlavor
% Add the necessary Java class (ImageSelection) to the Java classpath
if ~exist('ImageSelection', 'class')
    % Obtain the directory of the executable (or of the M-file if not deployed)
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
% Is the provided handle a figure?
function flag = isFigure(hObj)
flag = isa(handle(hObj),'figure') | isa(hObj,'matlab.ui.Figure');
end  %isFigure
% Is the provided handle an axes?
function flag = isAxes(hObj)
flag = isa(handle(hObj),'axes') | isa(hObj,'matlab.graphics.axis.Axes');
end  %isFigure
% Is the provided handle an image?
function flag = isImage(hObj)
flag = isa(handle(hObj),'image') | isa(hObj,'matlab.graphics.primitive.Image');
end  %isFigure
%%%%%%%%%%%%%%%%%%%%%%%%%% TODO %%%%%%%%%%%%%%%%%%%%%%%%%
% find a way in interactive-mode to single-click another Matlab figure for screen-capture