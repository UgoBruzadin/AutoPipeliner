




V = var(EEG.icaact(8,:,:));
V = reshape(V,1,size(V,3));
% --- gets the S sum of the variance (i.e. total variance)
S = sum(V,2);
% --- calculates C contributing variance for each trial
C = (S - V)/S;
% --- reshapes it in an array of lenght C
C = reshape(C,1,length(C));
% --- calculates the Z score for that array
Z = zscore(C);

componentData = EEG.icaact(8, :, :);
 %componentData = reshape(componentData,EEG.pnts,EEG.trials);