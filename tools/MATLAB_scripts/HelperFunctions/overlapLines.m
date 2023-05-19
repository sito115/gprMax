%% Overlap Lines
function overlapLines(src, event, timePlot, component, lw, fs, fcut)

% Prompt the user to enter start and end values
prompt = {'Enter threshold for first break picking relative to first minimum peak:'};
titleString = 'Input';
dims = [1 35];
default = {'1e-1'};
nonZeroThresh = inputdlg(prompt, titleString, dims, default);

% Check if the user clicked "Cancel" or closed the dialog
if isempty(nonZeroThresh)
    return;
end
nonZeroThresh = str2double(nonZeroThresh);

timeLines = findobj(timePlot, 'Type', 'line');

figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',@SaveFigure);

uimenu(m, 'Text', 'Select Time Window for FFT', 'MenuSelectedFcn', {@selectTimeWindow,gca, ...
                                                                    fcut, lw, fs, component})
uimenu(m, 'Text', 'Hide Legend', 'MenuSelectedFcn', {@handle_legend,'hide', fs} )
uimenu(m, 'Text', 'Show Legend', 'MenuSelectedFcn', {@handle_legend,'show', fs} )
uimenu(m, 'Text','Pick Times', 'MenuSelectedFcn',@PickTimes); 

set(gca, 'FontSize', fs)



hold on
for iLine = numel(timeLines):-1:1
    if timeLines(iLine).UserData.ShowLine
        tempData = timeLines(iLine).YData;
        color     = timeLines(iLine).UserData.Color;
        tempAxis  = timeLines(iLine).XData;
        name      = timeLines(iLine).DisplayName;

        [firstBreak,firstMinimumTime, maxAmplitude, idxFirstMin] = find1stBreak(tempData', tempAxis', nonZeroThresh);

%         firstBreak = timeLines(iLine).UserData.FirstBreak;
%         maxAmp     = timeLines(iLine).UserData.maxAmplitude; 
        newAxis = tempAxis - firstBreak;
%         newAxis = tempAxis - maxAmp;
    
        line = plot(newAxis,tempData , 'DisplayName', name ,...
               'LineWidth', lw ,'Color',[color, 0.8],'Tag','ShiftedLine');
        line.UserData = timeLines(iLine).UserData;
%         line.Annotation.LegendInformation.IconDisplayStyle = 'off';
        plot(tempAxis,tempData , 'DisplayName', name ,...
               'LineWidth', lw ,'Color',[color, 0.1],'HandleVisibility','off');

        scatter(firstBreak,tempData(idxFirstMin),'filled','o','HandleVisibility','off',...
                'MarkerFaceAlpha',0.5, 'MarkerEdgeColor', color, 'MarkerFaceColor',color)
            
        %     idx = find(abs(tempData)>nonZeroThresh,1);
        %     NewfirstBreak = newAxis(idx(1));
        %     fprintf('\tFirst non-zero value above threshold %.2e = %e s\n', nonZeroThresh, NewfirstBreak)
    end
end

uimenu(m, 'Text', 'Compute Average Wavelet', 'MenuSelectedFcn', @averageWavelet )

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
handle_legend([],[],'hide', fs)

end
%%
function averageWavelet(src,event)

lineObj = findobj(gca,'Tag','ShiftedLine');

% Prompt the user to enter start and end values
prompt = {'Enter start value [ns]:', 'Enter end value [ns]:'};
titleString = 'Input';
dims = [1 35];
default = {'10', '20'};
input = inputdlg(prompt, titleString, dims, default);

% Check if the user clicked "Cancel" or closed the dialog
if isempty(input)
    return;
end

% Convert input to numeric values
start_value = str2double(input{1})*1e-9;
end_value   = str2double(input{2})*1e-9;

% Check if input is valid
if isnan(start_value) || isnan(end_value) || start_value > end_value
    msgbox('Invalid input! Please enter valid numeric values with start value less than or equal to end value.', 'Error');
    return;
end

nLine = numel(lineObj);

Data2Average = [];
for iLine = 1:nLine
    tempData  = lineObj(iLine).YData;
    tempAxis  = lineObj(iLine).XData;

    if end_value > tempAxis(end)
        fprintf('Excluded: Wrong Dimension for %s due to time shift\n', lineObj(iLine).DisplayName)
        continue
    else
        iTEnd    = find(tempAxis >= end_value, 1,"first");
    end

    % find start and end index
    iT0      = find(tempAxis >= start_value, 1,"first");

    tempData2Average = tempData(iT0:iTEnd);
    try
        Data2Average = [Data2Average;tempData2Average];
    catch
        fprintf('Excluded: Wrong Dimension for %s due to time shift\n', lineObj(iLine).DisplayName)
    end

end
    Data2Average = mean(Data2Average);
    Axis         = tempAxis(iT0:iTEnd);

    figure
    plot(Axis,Data2Average)
    title("Average Wavelet")
    subtitle(sprintf('Selected Range from %.2e s to %.2e s', start_value, end_value))

    m = uimenu('Text','USER-Options');
    uimenu(m,'Text','Create Output .mat', 'MenuSelectedFcn',{@createOutput,Data2Average,Axis});

    function createOutput(src, event, Data2Average, Axis)
        assignin('base','AverageWavelet',[Axis',Data2Average'])
    end

end



