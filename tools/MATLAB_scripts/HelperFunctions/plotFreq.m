function plotFreq(TempField, color, component, lw, normalizationFreq, freqPlot)

    
    tempAxis    = TempField.Axis.fAxis;
    displayName = TempField.FileName;
    alpha       = 0.8;
    nRx         = TempField.Attributes.nrx;

    if size(color,1) ~= nRx
        color = repmat(color(1,:),nRx,1);
    end

    for iRx = 1:nRx
        tempData    = TempField.Data.FFT.(component)(:,iRx);

        tempData = abs(tempData(:,:));
        if normalizationFreq 
            tempData = tempData/max(tempData);
        end
        
        lineObj = plot(tempAxis, tempData(1:numel(tempAxis)),...
            'DisplayName',displayName,'LineWidth', lw, 'Color',[color(iRx,:),alpha], 'Parent', freqPlot);
    
        lineObj.UserData     = TempField;
        lineObj.UserData.iRx = iRx;
        lineObj.UserData.ShowLine = 1;
        lineObj.Color   = color(iRx,:);


        [~, indFd] = max(tempData);
        fcenter = tempAxis(indFd(1));
    
    %     xline(fcenter, 'HandleVisibility','off',....
    %         'LabelVerticalAlignment','bottom',...
    %         'LabelHorizontalAlignment','center', 'LineStyle','-.', 'Color', color,...
    %         'LineWidth',lw)
    
        fprintf('\tDominant Frequency at %e Hz\n', fcenter)

    end

end