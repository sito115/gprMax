function [firstBreak,firstMinimumTime, maxAmplitude] = find1stBreak(tempData, tempAxis, nonZeroThresh)


    if size(tempData,2) ~= 1
        warning('Wrong dimension')
        firstBreak = NaN;
        return
    end
       
    [~, idx] = max(tempData);
    maxAmplitude = tempAxis(idx);

    [pks,locs] = findpeaks(-tempData, 'MinPeakHeight', 0.1*max(tempData));

    if isempty(pks)
        warning('No peak found')
        firstBreak = NaN;
        firstMinimumTime = NaN;

        return
    else
        firstMinimum = pks(1);
        firstMinimumTime = tempAxis(locs(1));
    end
    
    fprintf('\t\tFirst local minumum found at %e having a value of %e\n', tempAxis(locs(1)), firstMinimum )


    threshold = firstMinimum * nonZeroThresh;
    idx       = find(abs(tempData)>threshold,1);

    fprintf('\t\tNew threshold is %f %% above the first local minimum for absolute values\n', nonZeroThresh*100)

    if isempty(idx)
        firstBreak = NaN;
        warning('\tNo value above threshold\n')
        fprintf('\tFirst break set at %e s\n', firstBreak)
    else
        firstBreak = tempAxis(idx(1));
        fprintf('\tFirst break above threshold %e at %g s\n', threshold, firstBreak)
    end
    



end
