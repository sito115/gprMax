function allData = addLine(timePlot, freqPlot, pathRoot,trdSemester,...
                           component, normalizationTime, lw, nonZeroThresh, normalizationFreq, allData)

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
nFields = numel(fieldNames);

colors = distinguishable_colors(nFields);

for iField = nFields-nNewFields:nFields
    color = colors(iField, :);
    TempField  = allData.(fieldNames{iField});
    firstBreak = plotTimeDomain(TempField, component, normalizationTime, lw, nonZeroThresh,timePlot, color);
    plotFreq(TempField, color, component, lw, normalizationFreq, freqPlot)
    allData.(fieldNames{iField}).FirstBreak = firstBreak;
end

end