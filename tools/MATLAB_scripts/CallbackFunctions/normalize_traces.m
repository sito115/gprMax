function normalize_traces(src,event,timePlot,freqPlot,component,fs,lw,fcut)
% Normalize traces in time and frequency domain in a new window.
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs
% timePlot      : axis object of the tile containg data in time domain
% freqPlot      : axis object of the tile containg data in frequency domain
% component     : character [Ex,Ey,Ez]
% fs            : float - Font Size
% lw            : float - Line Width
% fcut          : float - cut off frequency to display in MHz

alpha = 0.7;

timeLines  = findobj(timePlot, 'Type', 'line');
freqLines  = findobj(freqPlot, 'Type', 'line');

fWindow = figure('Visible','off');
set(fWindow,'Color','white');
m = uimenu('Text','USER-Options');

t = tiledlayout(1,2, 'Parent',fWindow); 

% TIME DOMAIN plot
timeTile = nexttile;

hold on
set(gca, 'FontSize', fs)
grid on

% legend
xlabel('Time (ns)')
timeTile.Title.String = [component ' - Time Domain'];
lg = legend('Interpreter','none', 'FontSize', 0.75*fs, 'Orientation','Vertical','NumColumns',2);
lg.Layout.Tile = 'south';
handle_legend([],[],'hide', fs)

% FREQUENCY DOMAIN plot
freqTile = nexttile;
grid on
set(gca, 'FontSize', fs)
hold on

xlim([0 fcut])
xlabel('Frequency (MHz)')
freqTile.Title.String = [component,' - Frequency Domain'];

%% Plot
for iLine = numel(timeLines):-1:1
    if timeLines(iLine).UserData.ShowLine 
        tempAxis   = timeLines(iLine).XData;
        tempDataRaw = timeLines(iLine).YData;
        tempDataRaw = tempDataRaw/max(abs(tempDataRaw));
        color        = timeLines(iLine).UserData.Color;
        legendString = timeLines(iLine).DisplayName;
    
        line = plot(tempAxis,tempDataRaw , 'DisplayName',legendString,...
                               'LineWidth', lw, 'Parent',timeTile,'Color',[color,alpha]);
        line.UserData.ShowLine = 1;
        line.UserData.Color = color;
        line.UserData.Attributes.dt = timeLines(iLine).UserData.Attributes.dt;
        fAxis   = freqLines(iLine).XData;
        fftData = freqLines(iLine).YData;
        fftData = fftData/max(abs(fftData));
    
            plot(fAxis, fftData,...
                'DisplayName',legendString,'LineWidth', lw, 'Color',[color,alpha], 'Parent', freqTile)
    end
end

% labels
changeLabels = uimenu(m, 'Label', 'Change Labels');
uimenu(changeLabels, 'Text', 'Change Legend Names', 'MenuSelectedFcn', @changeLegendNames)
uimenu(changeLabels, 'Text', 'Add Title', 'MenuSelectedFcn', {@addTitle,t, fs})

% hide show
hideShow     = uimenu(m, 'Label', 'Hide/Show');
uimenu(hideShow, 'Text', 'Hide Lines', 'MenuSelectedFcn', {@deleteLine,timeTile, freqTile,'hide'} )
uimenu(hideShow, 'Text', 'Hide Lines with Filter', 'MenuSelectedFcn', {@deleteLine,timeTile, freqTile,'hide','filter'} )
uimenu(hideShow, 'Text', 'Show Lines', 'MenuSelectedFcn', {@deleteLine,timeTile, freqTile,'show'} )
uimenu(hideShow, 'Text', 'Show Lines with Filter', 'MenuSelectedFcn', {@deleteLine,timeTile, freqTile,'show','filter'} )
uimenu(hideShow, 'Text', 'Delete Lines', 'MenuSelectedFcn', {@deleteLine,timeTile, freqTile,'delete'} )
uimenu(hideShow, 'Text', 'Hide Legend', 'MenuSelectedFcn', {@handle_legend,'hide', fs} )
uimenu(hideShow, 'Text', 'Show Legend', 'MenuSelectedFcn', {@handle_legend,'show', fs} )

% process
process     = uimenu(m, 'Label', 'Process');
uimenu(process, 'Text', 'Overlap at first break', 'MenuSelectedFcn', {@overlapLines, timeTile, component, lw, fs, fcut} )
uimenu(process, 'Text', 'Select Time Window for FFT', 'MenuSelectedFcn', {@selectTimeWindow,timeTile, fcut, lw, fs, component,'normalize'})
uimenu(process, 'Text', 'Overlay with Envelope (Hilbert)', 'MenuSelectedFcn', {@createEnvelopeHilbert,timeTile,lw,fs})

fWindow.Visible = 'on';