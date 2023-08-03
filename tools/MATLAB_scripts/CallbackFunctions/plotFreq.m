function plotFreq(TempField, color, component, lw, freqPlot)
% Plot frequency data in tile.
% INPUT:
% TempField     : structure containing informmation of the field to be displayed
% color         : [1x3] double
% freqPlot      : axis object of the tile containg data in frequency domain
% component     : character [Ex,Ey,Ez]
% lw            : float - Line Width
% fcut          : float - cut off frequency to display in MHz
    
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
        
        lineObj = plot(tempAxis/1e6, tempData(1:numel(tempAxis)),...
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