function allData = addLine(timePlot, freqPlot, pathRoot,trdSemester,...
                           component, normalizationTime, lw, normalizationFreq, allData)

[filenameArray, pathname, check] = uigetfile([fullfile(pathRoot,trdSemester,'Results') '\*.out'],...
                            'Select gprMax output file to plot B-scan', 'MultiSelect', 'on');

if check == 0   % user pressed cancel
    return
end

if iscell(filenameArray)
    nNewFields = numel(filenameArray);
else
    nNewFields = 1;
end

allData    = load_output(allData,filenameArray, pathname);
fieldNames = fieldnames(allData);
nFields    = numel(fieldNames);

timeLines = findobj(timePlot, 'Type', 'line');
nColorsOld = numel(timeLines);

nColorsNew = 0;
for iField = nFields-nNewFields+1:nFields
    fieldname =  fieldNames{iField};
    traces = allData.(fieldname).Attributes.nrx;
    nColorsNew = nColorsNew + traces;
end

colors = distinguishable_colors(nColorsOld + nColorsNew);

colorCounter = nColorsOld + 1;
for iField = nFields-nNewFields+1:nFields
    TempField  = allData.(fieldNames{iField});
    nRx       = TempField.Attributes.nrx;
    color     = colors(colorCounter:colorCounter+nRx-1,:);
    allData.(fieldNames{iField}).Color = color;
    plotTimeDomain(TempField, component, normalizationTime, lw, timePlot, color);
    plotFreq(TempField, color, component, lw, normalizationFreq, freqPlot)
    colorCounter = colorCounter + nRx;
end

end