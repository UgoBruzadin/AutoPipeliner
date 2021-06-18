%clear all
%clc
%this is the simple code where we chose which functions we want run on the
%files of this folder
Filter = {'filter',2, 55}; %works
Nfilter = {'nfilter',59,61}; %works
nfilterAMPS = {'nfilterAMPS'}; %works
ICLREJ = {'iclrej', 1};
ICheart = {'icheart',0.8};
BSS = {'bss'};
HM99 = {'HM99'};
EP2448 = {'epoch','DIN ',[0.400, 2.448]}; %works
EP4096 = {'epoch','DIN ',[-1.000, 3.096]};
ICA = {'ica'};
dipfit = {'dipfit'};
PCA50 = {'ica',50};
F2 = {'epoch','DIN',0.600, 2.648}; %works
F3 = {'epoch',{'DIN',0.800, 2.848}}; %works
H = {'epochRejection',3, 3}; %works
I = {'loreta'}; %needs to be created
refav = {'ref', 'av'}; %needs to be retested
I2 = {'ref', 'cz'}; %needs to be retested
I3 = {'ref', 'le'}; %needs to be retested
J = {'interpolate'}; %needs to be retested
Baseline = {'baseline',[]}; %needs to be retested
FFT = {'fft'};

all = {Filter, Nfilter, nfilterAMPS, ICLREJ, ICheart, BSS, HM99, EP2448, EP4096, Baseline, ICA, dipfit, PCA50, FFT};

[files,path] = uigetfile('*.set',...
    'Select One or More Files', ...
    'MultiSelect', 'on');
%maybe: BSS, 
%example; Batch1 = {E2,F}; Batch2 = {E3,F,G};

batch1 = {EP4096,ICA,ICheart,HM99,BSS,PCA50};
batch2 = {EP2448,ICA,ICheart,HM99,BSS,PCA50};
batch3 = {ICA,ICheart,HM99,BSS,PCA50};
%batch2 = {Nfilter,Filter};
%[batchFolder, OGFolder] = autopipeliner_v2a.batches({batch1,batch2},path);
%cd strcat(path)
[batchFolder, OGFolder] = autopipeliner_v1b.batches({batch1},path);

%[batchFolder, OGFolder] = autopipeliner_v2a.batches({batch2,batch3},path,2,files);


