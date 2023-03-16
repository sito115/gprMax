function plotFreq(TempField, color, component, lw, normalizationFreq, freqPlot)

    tempData    = TempField.Data.FFT.(component);
    tempAxis    = TempField.Axis.fAxis;
    displayName = TempField.FileName;

    tempData = abs(tempData(:,:));
    if normalizationFreq 
        tempData = tempData/max(tempData);
    end
    
    plot(tempAxis, tempData(1:numel(tempAxis)),...
        'DisplayName',displayName,'LineWidth', lw, 'Color',color, 'Parent', freqPlot);

    [~, indFd] = max(tempData);
    fcenter = tempAxis(indFd(1));

%     xline(fcenter, 'HandleVisibility','off',....
%         'LabelVerticalAlignment','bottom',...
%         'LabelHorizontalAlignment','center', 'LineStyle','-.', 'Color', color,...
%         'LineWidth',lw)

    fprintf('\tDominant Frequency at %e Hz\n', fcenter)

end