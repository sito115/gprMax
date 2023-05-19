function plot_TimeFreqDomain(allData, component, fcut, nonZeroThresh, normalizationTime, normalizationFreq)

if nargin < 2 || isempty(component)
    component = 'Ey';
end

if nargin < 3 || isempty(fcut)
    fcut = 6e8;
end

if nargin < 4 || isempty(nonZeroThresh)
    nonZeroThresh = 1e-1;
end

if nargin < 5 || isempty(normalizationTime)
    normalizationTime = false;
end

if nargin < 6 || isempty(normalizationTime)
    normalizationFreq = false;
end


fieldNames = fieldnames(allData);
nField     = numel(fieldNames);

%% PARAMETER
lw            = 1.5;    % line width
fs            = 18;     % font size
%% PLOT
% TIME DOMAIN
f = figure;
t = tiledlayout(1,2, 'Parent',f); %, 'Units', 'normalized','OuterPosition',[0 0.15 1 0.85]);
timePlot = nexttile;
grid on

hold on
set(gca, 'FontSize', fs)

% legend
xlabel('Time (s)')
title([component ' - Time Domain'])

lg = legend('Interpreter','none', 'FontSize', 0.75*fs, 'Orientation','Vertical','NumColumns',2);
lg.Layout.Tile = 'south';


% FREQUENCY DOMAIN
freqPlot = nexttile;
grid on
set(gca, 'FontSize', fs)
hold on

xlim([0 fcut])
xlabel('Frequency (Hz)')


nTraces = 0;
for iField = fieldNames'
    traces = allData.(iField{1}).Attributes.nrx;
    nTraces = nTraces + traces;
end
colors = distinguishable_colors(nTraces);


colorCounter = 1;
for iField = 1:nField
    TempField = allData.(fieldNames{iField});
    nRx       = TempField.Attributes.nrx;
    color     = colors(colorCounter:colorCounter+nRx-1,:);
    allData.(fieldNames{iField}).Color = color;
    plotTimeDomain(TempField, component, normalizationTime, lw,timePlot, color);
    plotFreq(TempField, color, component, lw, normalizationFreq, freqPlot)
    colorCounter = colorCounter + nRx;
end

handle_legend([],[],'hide', fs)

title([component,' - Frequency Domain'])




%% MENU
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pwd)});

uimenu(m, 'Text', 'Add Line', 'MenuSelectedFcn', ['allData = addLine(timePlot, freqPlot, pathRoot,trdSemester,' ...
                                                 'component, normalizationTime, lw, nonZeroThresh, normalizationFreq, allData);'] ); 

% labels
changeLabels = uimenu(m, 'Label', 'Change Labels');
uimenu(changeLabels, 'Text', 'Change Legend Names', 'MenuSelectedFcn', @changeLegendNames)
uimenu(changeLabels, 'Text', 'Add Title', 'MenuSelectedFcn', {@addTitle,t, fs})

% hide show
hideShow     = uimenu(m, 'Label', 'Hide/Show');
uimenu(hideShow, 'Text', 'Hide Lines', 'MenuSelectedFcn', {@deleteLine,timePlot, freqPlot,'hide'} )
uimenu(hideShow, 'Text', 'Hide Lines with Filter', 'MenuSelectedFcn', {@deleteLine,timePlot, freqPlot,'hide','filter'} )
uimenu(hideShow, 'Text', 'Show Lines', 'MenuSelectedFcn', {@deleteLine,timePlot, freqPlot,'show'} )
uimenu(hideShow, 'Text', 'Show Lines with Filter', 'MenuSelectedFcn', {@deleteLine,timePlot, freqPlot,'show','filter'} )
uimenu(hideShow, 'Text', 'Delete Lines', 'MenuSelectedFcn', {@deleteLine,timePlot, freqPlot,'delete'} )
uimenu(hideShow, 'Text', 'Hide Legend', 'MenuSelectedFcn', {@handle_legend,'hide', fs} )
uimenu(hideShow, 'Text', 'Show Legend', 'MenuSelectedFcn', {@handle_legend,'show', fs} )

% process
process     = uimenu(m, 'Label', 'Process');
uimenu(process, 'Text', 'Overlap at first break', 'MenuSelectedFcn', {@overlapLines, timePlot, component, lw, fs, fcut} )
uimenu(process, 'Text', 'Add Wavelet (Mexican hat)', 'MenuSelectedFcn', 'allData = addWavelet(allData,timePlot, freqPlot, component, nonZeroThresh, lw);' )
uimenu(process, 'Text', 'Select Time Window for FFT', 'MenuSelectedFcn', {@selectTimeWindow,timePlot, fcut, lw, fs, component})




%% changeLegendNames
function changeLegendNames(src, event)

lgObj = findobj(gcf,'Type','Legend');
prompt = lgObj.String;

dlgtitle = 'Change Legend Entry';

answer = inputdlg(prompt',dlgtitle,[1 150],prompt');

set(lgObj,'String',answer)

end
%% Add title

function addTitle(src, event, t, fs)

dlgtitle = 'AddTitle';

if isempty(t.Title.String)
    lgObj = findobj(gcf,'Type','Legend');
    prompt = lgObj.String(1);
else
    prompt = t.Title.String;
end

answer = inputdlg('New title',dlgtitle,[1 150],prompt);

title(t,answer, 'FontSize', 1.3*fs)

end


end