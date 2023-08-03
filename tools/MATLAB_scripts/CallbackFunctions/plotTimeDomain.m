function [firstBreak,firstMinimumTime, maxAmplitude] = plotTimeDomain(TempField, component, lw,...
                                              timePlot, color)
% Plot frequency data in tile.
% INPUT:
% TempField     : structure containing informmation of the field to be displayed
% component     : character [Ex,Ey,Ez]
% lw            : float - Line Width
% timePlot      : axis object of the tile containg data in time domain
% color         : [1x3] double
%
% OUTPUT:
% firstBreak        : first break time
% firstMinimumTime  : time of first minimum
% maxAmplitude      : time of maximum amplitude

    alpha = 0.7;
    nRx   = TempField.Attributes.nrx;
    firstBreak = zeros(nRx,1);
    firstMinimumTime = zeros(nRx,1);
    maxAmplitude = zeros(nRx,1);
    offset = TempField.Attributes.Offset_x;

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
    
        [~, indTd] = max(tempData);
        maxAmlitude = tempAxis(indTd(1));
        fprintf('\tMax Amplitude at %e s\n',maxAmlitude)
    
        lineObj = plot(tempAxis*1e9,tempData , 'DisplayName',sprintf('%s - Trace %d (%.1fm)',TempField.FileName, iRx, offset(iRx)),...
                           'LineWidth', lw, 'Parent',timePlot,'Color',[color(iRx,:),alpha]);

        lineObj.UserData            = TempField;
        lineObj.UserData.iRx        = iRx;
        lineObj.UserData.ShowLine   = 1;
        lineObj.UserData.dt         = TempField.Attributes.dt;
        lineObj.UserData.Color      = color(iRx,:);

    end
   
end