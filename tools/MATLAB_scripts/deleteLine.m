function allData = deleteLine(allData, timePlot, freqPlot) 

axesHandlesToChildObjects = findobj(gcf, 'Type', 'Legend');
lines = flipud(axesHandlesToChildObjects.String');


[indx,tf] = listdlg('PromptString','Delete Lines',...
    'SelectionMode','multiple','ListString',lines, 'ListSize', [500, 200]);

timeLines = findobj(timePlot, 'Type', 'line');
freqLines = findobj(freqPlot, 'Type', 'line');

fieldNames = flip(fieldnames(allData));

if tf
    delete(timeLines(indx))
    delete(freqLines(indx))
    allData = rmfield(allData, fieldNames(indx));
else
    fprintf('No lines selected')
end

end
