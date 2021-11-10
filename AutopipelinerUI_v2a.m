%clear all
%clc
%this is the simple code where we chose which functions we want run on the
%files of this folder
Filter = {'filter',2, 55}; %works
HighPass = {'filterhigh',18}; %works
LowPass = {'filterlow',22}; %works

Nfilter = {'nfilter',59,61}; %works
nfilterAMPS = {'nfilterAMPS'}; %works
ICREJ = {'icrej',0.9};
ICREJ2 = {'icrej',0.8};
ICheart = {'icheart',0.50};
BSS = {'bss'};
HM99 = {'HM99'};
EP2448 = {'epoch','DIN ',[0.400, 2.448]}; %works
EP4096 = {'epoch','DIN ',[-1.000, 3.096]};
ICA = {'ica'};
dipfit = {'dipfit'};
PCA35 = {'ica',35};
PCA42 = {'ica',42};
PCA20 = {'ica',20};
PCA50 = {'ica',50};
F2 = {'epoch','DIN',0.600, 2.648}; %works
F3 = {'epoch',{'DIN',0.800, 2.848}}; %works
EPREJ = {'epochrej',6, 6}; %works
I = {'loreta'}; %needs to be created
refav = {'ref', 'av'}; %needs to be retested
I2 = {'ref', 'cz'}; %needs to be retested
I3 = {'ref', 'le'}; %needs to be retested
J = {'interpolate'}; %needs to be retested
Baseline = {'baseline',[]}; %needs to be retested
FFT = {'fft'};
test = {'test',[]};

all = {HighPass, LowPass, Filter, Nfilter, nfilterAMPS, ICREJ, PCA42, PCA20, PCA40, ICheart, BSS, HM99, EP2448, EP4096, Baseline, ICA, dipfit, PCA35, PCA50, FFT};

[files,path] = uigetfile('*.set',...
    'Select One or More Files', ...
    'MultiSelect', 'on');

testbatch = {test, test, test,test};
%[batchFolder, OGFolder] = autopipeliner_v3b.newBatches({testbatch,testbatch},path,files);
%[batchFolder, OGFolder] = autopipeliner_v3b.newBatches({testbatch,testbatch},batchFolder,files);

%example; Batch1 = {E2,F}; Batch2 = {E3,F,G};
 
 batch1 = {BSS,PCA50,ICheart,PCA42,ICREJ2,HM99};
 batch2 = {LowPass,EP4096,BSS,PCA35,ICREJ2,EPREJ,FFT};
 batch3 = {HighPass,EP4096,BSS,PCA20,ICREJ2,EPREJ,FFT};
 
%  tic
 [path, OGFolder] = autopipeliner_v3c.newBatches({batch1},path,files);
 [path, OGFolder] = autopipeliner_v3c.newBatches({batch2,batch3},path,files);
% 
% runtime = toc



