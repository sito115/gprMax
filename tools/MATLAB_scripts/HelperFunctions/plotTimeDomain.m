function [firstBreak,firstMinimumTime, maxAmplitude] = plotTimeDomain(TempField, component, normalizationTime, lw,...
                                              timePlot, color)

    alpha = 0.7;
    nRx   = TempField.Attributes.nrx;
    firstBreak = zeros(nRx,1);
    firstMinimumTime = zeros(nRx,1);
    maxAmplitude = zeros(nRx,1);

    if size(color,1) ~= nRx
        color = repmat(color(1,:),nRx,1);
    end

    for iRx = 1:nRx

        tempData = TempField.Data.fields.(component)(:,iRx);
        tempAxis = TempField.Axis.time;
    
        fprintf('%s - Trace %d\n',TempField.FileName, iRx)
        
        normalizedTempData = tempData/max(abs([min(tempData), max(tempData)]));
    
%         [firstBreak(iRx),firstMinimumTime(iRx), maxAmplitude(iRx)] = ...
%             find1stBreak(tempData, tempAxis, nonZeroThresh);
    
        if normalizationTime
            tempData = normalizedTempData;
        end
    
        [~, indTd] = max(tempData);
        maxAmlitude = tempAxis(indTd(1));
        fprintf('\tMax Amplitude at %e s\n',maxAmlitude)
    
        lineObj = plot(tempAxis,tempData , 'DisplayName',sprintf('%s - Trace %d',TempField.FileName, iRx),...
                           'LineWidth', lw, 'Parent',timePlot,'Color',[color(iRx,:),alpha]);

        lineObj.UserData            = TempField;
        lineObj.UserData.iRx        = iRx;
        lineObj.UserData.ShowLine   = 1;
        lineObj.UserData.Color      = color(iRx,:);
%         lineObj.UserData.FirstBreak = firstBreak(iRx);
%         lineObj.UserData.firstMinimumTime = firstMinimumTime(iRx);
%         lineObj.UserData.maxAmplitude = maxAmplitude(iRx);

    end
   
end