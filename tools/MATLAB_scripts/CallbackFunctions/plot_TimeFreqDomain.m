function plot_TimeFreqDomain(allData, component, fcut)

% Displays individual traces of one or multiple .out-Files with additonal
% "USER-Options" in the menu.
% INPUT:
% allData       : structure - containing information of loaded .out-Files 
% component     : string - [Ex,Ey,Ez] 
% fcut          : float - cut off frequency to display in MHz


if nargin < 2 || isempty(component)
    component = 'Ey';
end

if nargin < 3 || isempty(fcut)
    fcut = 600;
end


fieldNames = fieldnames(allData);
nField     = numel(fieldNames);

%% PARAMETER
lw            = 1.5;    % line width
fs            = 10;     % font size
%% PLOT
% TIME DOMAIN
f = figure;
% set(f,'Color','white');
t = tiledlayout(1,2, 'Parent',f); %, 'Units', 'normalized','OuterPosition',[0 0.15 1 0.85]);
timePlot = nexttile;
grid on

hold on
set(gca, 'FontSize', fs)


% legend
xlabel('Time (ns)')
ylabel('Field strength [V/m]')
title([component ' - Time Domain'])

lg = legend('Interpreter','none', 'FontSize', 0.5*fs, 'Orientation','Vertical','NumColumns',2);
lg.Layout.Tile = 'south';


% FREQUENCY DOMAIN
freqPlot = nexttile;
grid on
set(gca, 'FontSize', fs)
hold on

xlim([0 fcut])
xlabel('Frequency (MHz)')


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
    plotTimeDomain(TempField, component, lw,timePlot, color);
    plotFreq(TempField, color, component, lw, freqPlot)
    colorCounter = colorCounter + nRx;
end

handle_legend([],[],'hide', fs)

title([component,' - Frequency Domain'])




%% MENU
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pwd)});

uimenu(m, 'Text', 'Add Line', 'MenuSelectedFcn', {@addLine,timePlot, freqPlot, pwd,'', ...
                                                 component, lw} ); 
uimenu(m, 'Text', 'Add Line from .mat', 'MenuSelectedFcn', {@addLine,timePlot, freqPlot, pwd,'', ...
                                                 component, lw,true} ); 
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
uimenu(process, 'Text', 'Select Time Window for FFT', 'MenuSelectedFcn', {@selectTimeWindow,timePlot, fcut, lw, fs, component})
uimenu(process, 'Text', 'Normalize Traces', 'MenuSelectedFcn', {@normalize_traces,timePlot, freqPlot,component,fs, lw,fcut})
uimenu(process, 'Text', 'Show A-Scan', 'MenuSelectedFcn', {@showAScan,timePlot})
uimenu(process, 'Text', 'Overlay with Envelope (Hilbert)', 'MenuSelectedFcn', {@createEnvelopeHilbert,timePlot,lw,fs})



end