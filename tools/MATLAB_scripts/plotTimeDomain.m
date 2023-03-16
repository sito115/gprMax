function firstBreak = plotTimeDomain(TempField, component, normalizationTime, lw,...
                                              nonZeroThresh,timePlot, color)

    tempData = TempField.Data.fields.(component);
    tempAxis = TempField.Axis.time;

    fprintf('%s \n',TempField.FileName)

    if normalizationTime 
        tempData = tempData/max(abs([min(tempData), max(tempData)]));
    end

    idx = find(abs(tempData)>nonZeroThresh,1);
    firstBreak = tempAxis(idx(1));
    fprintf('\tFirst non-zero value above threshold %.2e = %e s\n', nonZeroThresh, firstBreak)
    
%     scatter(firstBreak,0,50,'filled','MarkerFaceAlpha',0.5,...
%             'HandleVisibility','off','Parent',timePlot,'MarkerEdgeColor',color, 'MarkerFaceColor',color)

    [~, indTd] = max(tempData);
    maxAmlitude = tempAxis(indTd(1));
    fprintf('\tMax Amplitude at %e s\n',maxAmlitude)

    plot(tempAxis,tempData , 'DisplayName',TempField.FileName,...
                       'LineWidth', lw, 'Parent',timePlot,'Color',color);
   
end