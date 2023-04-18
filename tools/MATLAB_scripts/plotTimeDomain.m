function [firstBreak,firstMinimumTime, maxAmplitude] = plotTimeDomain(TempField, component, normalizationTime, lw,...
                                              nonZeroThresh,timePlot, color)

    alpha = 0.8;
    tempData = TempField.Data.fields.(component);
    tempAxis = TempField.Axis.time;

    fprintf('%s \n',TempField.FileName)
    
    normalizedTempData = tempData/max(abs([min(tempData), max(tempData)]));

    [firstBreak,firstMinimumTime, maxAmplitude] = find1stBreak(tempData, tempAxis, nonZeroThresh);

    if normalizationTime
        tempData = normalizedTempData;
    end

    [~, indTd] = max(tempData);
    maxAmlitude = tempAxis(indTd(1));
    fprintf('\tMax Amplitude at %e s\n',maxAmlitude)

    plot(tempAxis,tempData , 'DisplayName',TempField.FileName,...
                       'LineWidth', lw, 'Parent',timePlot,'Color',[color,alpha]);
   
end