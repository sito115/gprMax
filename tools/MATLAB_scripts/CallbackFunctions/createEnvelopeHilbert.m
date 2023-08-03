function createEnvelopeHilbert(src,evt,timePlot,lw,fs)
% Make the user choose traces in a GUI and then displays the trace together
% with their Hilbert envelopes in a new window.
%
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs
% timePlot      : axis object containing traces in time domain
% lw            : double - line width
% fs            : double - font size

% extract lines from axis object
timeLines = findobj(timePlot, 'Type', 'line');

showTF = zeros(numel(timeLines),1);
lines  = strings(numel(timeLines),1);
for iLine = 1:numel(timeLines)
    lines(iLine) = timeLines(iLine).DisplayName;
    if isempty(timeLines(iLine).UserData) || timeLines(iLine).UserData.ShowLine
        showTF(iLine) = 1;
    end
end

[sel_indx,tf] = listdlg('PromptString','Delete Lines',...
                'Selectionmode','multiple','ListString',lines(showTF==1), 'ListSize', [500, 200]);

if ~tf
    return
end

figure
hold on
for i = sel_indx
    color = timeLines(i).Color;
    time = timeLines(i).XData;
    fieldData = timeLines(i).YData';
    [~,fieldDataHilbert] = gpr_gainInvEnv2D(fieldData);
    plot(time,fieldDataHilbert,'Color','black','LineStyle','-','LineWidth',1.5*lw,'HandleVisibility','on')
    plot(time,fieldData,'Color',color,'LineWidth',lw,'LineStyle',':','DisplayName',timeLines(i).DisplayName)
end
legend('Interpreter','none')
xlabel('Time (ns)')
ylabel('Field strength [V/m]')
grid on
set(gca,'FontSize',fs)


m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pwd)});


% labels
changeLabels = uimenu(m, 'Label', 'Change Labels');
uimenu(changeLabels, 'Text', 'Change Legend Names', 'MenuSelectedFcn', @changeLegendNames)

% hide show
hideShow     = uimenu(m, 'Label', 'Hide/Show');
uimenu(hideShow, 'Text', 'Hide Legend', 'MenuSelectedFcn', {@handle_legend,'hide', fs} )
uimenu(hideShow, 'Text', 'Show Legend', 'MenuSelectedFcn', {@handle_legend,'show', fs} )
