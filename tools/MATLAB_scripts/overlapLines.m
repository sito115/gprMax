%% Overlap Lines
function overlapLines(src, event , nonZeroThresh, timePlot, component, lw, fs, fcut)

timeLines = findobj(timePlot, 'Type', 'line');


figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',@SaveFigure);

uimenu(m, 'Text', 'Select Time Window for FFT', 'MenuSelectedFcn', {@selectTimeWindow,gca, ...
                                                                    fcut, lw, fs, component})
uimenu(m, 'Text', 'Hide Legend', 'MenuSelectedFcn', {@handle_legend,'hide', fs} )
uimenu(m, 'Text', 'Show Legend', 'MenuSelectedFcn', {@handle_legend,'show', fs} )


set(gca, 'FontSize', fs)
hold on
for iLine = 1:numel(timeLines)
    if timeLines(iLine).UserData.ShowLine
        tempData = timeLines(iLine).YData;
        color     = timeLines(iLine).UserData.Color;
        tempAxis  = timeLines(iLine).XData;
        name      = timeLines(iLine).DisplayName;

        firstBreak = timeLines(iLine).UserData.FirstBreak;
        newAxis = tempAxis - firstBreak;
    
        line = plot(newAxis,tempData , 'DisplayName', name ,...
               'LineWidth', lw ,'Color',[color, 0.8]);
        line.UserData = timeLines(iLine).UserData;
        plot(tempAxis,tempData , 'DisplayName', name ,...
               'LineWidth', lw ,'Color',[color, 0.1],'HandleVisibility','off');
        scatter(firstBreak,0,'filled','o','HandleVisibility','off',...
                'MarkerFaceAlpha',0.5, 'MarkerEdgeColor', color, 'MarkerFaceColor',color)
            
        %     idx = find(abs(tempData)>nonZeroThresh,1);
        %     NewfirstBreak = newAxis(idx(1));
        %     fprintf('\tFirst non-zero value above threshold %.2e = %e s\n', nonZeroThresh, NewfirstBreak)
    end
end


prompt = sprintf('First break pick at trace when > %g %% above first minimum', 100*nonZeroThresh);


xLine = xline(0,'--','DisplayName','Alligned First Breaks','LineWidth',1.5*lw);
xLine.UserData.ShowLine = 0;

sc = scatter(NaN,NaN,'filled','o','Color','red','DisplayName','Picked First Breaks',...
            'MarkerFaceAlpha',0.4);
sc.UserData.ShowLine = 0;

% limits = get(gca,'XLim');
% xticks = get(gca,'xtick');
xlabel('Time (s)')
grid on

ylabel('')
title(sprintf('%s - Time Domain',component))
subtitle(prompt)

legend('Interpreter','none', 'FontSize', fs, 'Orientation','Vertical','NumColumns',2, 'Location','southoutside');

