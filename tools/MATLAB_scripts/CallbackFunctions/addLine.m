function allData = addLine(src,event,timePlot, freqPlot, pathRoot,trdSemester,...
                           component, lw,isMat)
% Add new data to current figure selecting an .out file.
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs
% timePlot      : axis object of the tile containg data in time domain
% freqPlot      : axis object of the tile containg data in frequency domain
% pathRoot      : character
% trdSemester   : character , specyfiyng the folder names [if not found it is empty]
% component     : character [Ex,Ey,Ez]
% lw            : float - Line Width
% isMat         : the data is loaded from a .mat File [optional, false by default]
%
% OUTPUT: 
% allData       : strucutre containing information about loaded data

% check if data is given in a mat file
if nargin < 9 || isempty(isMat)
    isMat = false;
end

% check if allData variable exists
W = evalin('base','whos'); 
doesExist = ismember('allData',{W(:).name});

if doesExist
    allData = evalin('base','allData');
else
    allData = [];
end

if ~isMat
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
else
    % load allData
    [file, path] = uigetfile([fullfile(pathRoot,trdSemester,'Results') '\*.mat'], 'Select a .mat file',...
        'MultiSelect','off');
    loadedData = load(fullfile(path, file)); % specify is necessary
    allData     = loadedData.DiffStruct;
    nNewFields = 1;
end

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
    plotTimeDomain(TempField, component, lw, timePlot, color);
    plotFreq(TempField, color, component, lw, freqPlot)
    colorCounter = colorCounter + nRx;
end

assignin('base','allData',allData)

end