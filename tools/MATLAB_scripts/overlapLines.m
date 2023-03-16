%% Overlap Lines
function overlapLines(allData , nonZeroThresh, normalizationTime, timePlot, component, lw, fs, path)


lgObj   = findobj(gcf,'Type','Legend');
legendString  = lgObj.String;

fieldNames = fieldnames(allData);
nFields = numel(fieldNames);
colors = distinguishable_colors(nFields);

figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn','SaveFigure(fullfile(pathRoot, figureFolder))');

set(gca, 'FontSize', fs)
hold on
for iField = 1:nFields
    TempField = allData.(fieldNames{iField});
    tempData = TempField.Data.fields.(component);
    tempAxis = TempField.Axis.time;
    firstBreak = TempField.FirstBreak;
    newAxis = tempAxis - firstBreak;
    color = colors(iField,:);

    if normalizationTime 
        tempData = tempData/max(abs([min(tempData), max(tempData)]));
    end

    plot(newAxis,tempData , 'DisplayName', legendString{iField} ,...
           'LineWidth', lw ,'Color',[color, 0.8]);
    plot(tempAxis,tempData , 'DisplayName', legendString{iField} ,...
           'LineWidth', lw ,'Color',[color, 0.1],'HandleVisibility','off');
    scatter(firstBreak,0,'filled','o','HandleVisibility','off',...
            'MarkerFaceAlpha',0.5, 'MarkerEdgeColor', color, 'MarkerFaceColor',color )
    
%     idx = find(abs(tempData)>nonZeroThresh,1);
%     NewfirstBreak = newAxis(idx(1));
%     fprintf('\tFirst non-zero value above threshold %.2e = %e s\n', nonZeroThresh, NewfirstBreak)
end

if normalizationTime
    prompt = sprintf('First break pick at normalized trace when > %.2e s', nonZeroThresh);
else
    prompt = sprintf('First break pick at trace when > %.2e s', nonZeroThresh);
end

xline(0,'--','DisplayName','Alligned First Breaks')

scatter(NaN,NaN,'filled','o','Color','red','DisplayName','Picked First Breaks',...
            'MarkerFaceAlpha',0.4)

limits = get(gca,'XLim');
xticks = get(gca,'xtick');
xlim([(-xticks(2)+xticks(1)) limits(2)]);
xlabel('Time (s)')
grid on

ylabel('')
title(sprintf('%s - Time Domain',component))
subtitle(prompt)

legend('Interpreter','none', 'FontSize', fs, 'Orientation','Vertical','NumColumns',2, 'Location','southoutside');

