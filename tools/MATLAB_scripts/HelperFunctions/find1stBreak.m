function [firstBreak,firstMinimumTime, maxAmplitude, idx] = find1stBreak(tempData, tempAxis, nonZeroThresh)


    if size(tempData,2) ~= 1
        warning('Wrong dimension')
        firstBreak = NaN;
        return
    end
       
    [~, idxMax] = max(tempData);
    maxAmplitude = tempAxis(idxMax);

    zeroCrossings = find( tempData(2:end).*tempData(1:end-1)<0 );
    if isempty(zeroCrossings)
        zeroCrossings = NaN;
    end
    idx1stZeroCross = zeroCrossings(find(zeroCrossings<idxMax,1,'last'));
    idx2ndZeroCross = zeroCrossings(find(zeroCrossings>idxMax,1,'first'));

    if isempty(idx1stZeroCross)
        fprintf('\tFirst Maximum is too high!')
        firstBreak = NaN;
        firstMinimumTime = NaN;
        idx = NaN;
        return
    end

    timeWindowPeakFlip = flip(tempData(1:idx1stZeroCross));
    [pks,locs] = findpeaks(-timeWindowPeakFlip, 'MinPeakHeight', 0.1*max(abs(timeWindowPeakFlip) ));

%     [pks,locs] = findpeaks(-tempData, 'MinPeakHeight', 0.2*max(tempData) );

    if any(pks > max(tempData)) % discard negative peaks greater than the maximum
        idx = find(pks > max(tempData));
        pks(idx) = [];
        locs(idx) = [];
    end

    if isempty(pks)
        warning('No peak found')
        firstBreak = NaN;
        firstMinimumTime = NaN;

        return
    else
        FirstMinIdx = idx1stZeroCross - locs(1);
        firstMinimumTime = tempAxis(FirstMinIdx);
        
        firstMinimum = pks(1);
%         firstMinimumTime = tempAxis(locs(1));
    end
    
    fprintf('\t\tFirst local minumum found at %e having a value of %e\n', tempAxis(locs(1)), firstMinimum )


    threshold = abs(firstMinimum * nonZeroThresh);

    idxRaw      = find(-timeWindowPeakFlip(locs(1):end) <= threshold,1,'first');
    idx         = FirstMinIdx - idxRaw;

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