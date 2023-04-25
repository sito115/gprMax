function deleteLine(src, event, timePlot, freqPlot, mode) 

timeLines = findobj(timePlot, 'Type', 'line');
freqLines = findobj(freqPlot, 'Type', 'line');

showTF = zeros(numel(timeLines),1);
lines  = strings(numel(timeLines),1);
for iLine = 1:numel(timeLines)
    lines(iLine) = timeLines(iLine).DisplayName;
    if isempty(timeLines(iLine).UserData) || timeLines(iLine).UserData.ShowLine
        showTF(iLine) = 1;
    end
end

switch mode
    case 'hide'
    
    assert(any(showTF), 'No Lines to hide')    
    
    [sel_indx,tf] = listdlg('PromptString','Delete Lines',...
        'SelectionMode','multiple','ListString',lines(showTF==1), 'ListSize', [500, 200]);

    indx = find(showTF);
    indx = indx(sel_indx);

    if tf
        for ix = indx'
            timeLines(ix).Visible = 'off';
            timeLines(ix).Annotation.LegendInformation.IconDisplayStyle = 'off';
            timeLines(ix).UserData.ShowLine = 0;
            freqLines(ix).Visible = 'off';
            freqLines(ix).Annotation.LegendInformation.IconDisplayStyle = 'off';
            freqLines(ix).UserData.ShowLine = 0;
        end
    else
        fprintf('No lines selected')
    end

    case 'show'

    assert(any(~showTF), 'No Lines to hide')


    [sel_indx,tf] = listdlg('PromptString','Delete Lines',...
        'SelectionMode','multiple','ListString',lines(showTF==0), 'ListSize', [500, 200]);

    indx = find(~showTF);
    indx = indx(sel_indx);

    if tf
        for ix = indx'
            timeLines(ix).Visible = 'on';
            timeLines(ix).Annotation.LegendInformation.IconDisplayStyle= 'on';
            timeLines(ix).UserData.ShowLine = 1;
            freqLines(ix).Visible = 'on';
            freqLines(ix).Annotation.LegendInformation.IconDisplayStyle= 'on';
            freqLines(ix).UserData.ShowLine = 1;
        end
    else
        fprintf('No lines selected')
    end

    case 'delete'
            [sel_indx,tf] = listdlg('PromptString','Delete Lines',...
        'SelectionMode','multiple','ListString',lines, 'ListSize', [500, 200]);

        if tf
            for i = sel_indx
                delete(timeLines(i))
                delete(freqLines(i))
            end
        end
end


end
