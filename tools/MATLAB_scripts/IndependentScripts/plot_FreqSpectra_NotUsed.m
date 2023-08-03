clear ,close all
% This skript plots a average frequency of all traces that have been stored
% in FreqSpecDataRev.mat


fcut = 600;     % cut-off frequency for x axis
lw = 2;         % linewidth
fs = 20;        % font size
stepSize = 5;   % how many array elements are plotted, e.g. 5 means that every 5th element is plotted
alpha = 0.8;    % transparency

% load data
path      = 'mat-Files\FreqSpecDataRev.mat';
Data      = load(path);
FreqData  = Data.FreqData;


FreqData = sortrows(FreqData);

nGroups = [];
markers = {'--o',':+','-.*'};

[sel_indxALL,tf] = listdlg('PromptString','Select A1',...
    'SelectionMode','multiple','ListString',FreqData.Name, 'ListSize', [500, 200]);
assert(tf == true)

if ~isempty(nGroups )
    colors = distinguishable_colors(ceil(numel(sel_indxALL)/nGroups));
    isGroupColor = true;
else
    colors = distinguishable_colors(numel(sel_indxALL));
     isGroupColor = false;
end




figure
hold on
grid on
counter = 1;
colCounter = 1;
lineSpecCounter = 0;
color = colors(1,:);
xlabel('Frequency (MHz)')


for i = sel_indxALL

    if isGroupColor
        lineSpecCounter = lineSpecCounter + 1;
        colCounter      = colCounter + 1;
        if lineSpecCounter > nGroups
            colCounter = 1;
            lineSpecCounter = 1;
        end
        marker = markers{lineSpecCounter};
        color  = colors(colCounter,:);
    else
        color = colors(counter,:);
        marker = 'o--';
    end


    FreqData.freqSpectrum(i,:) = FreqData.freqSpectrum(i,:)./max(FreqData.freqSpectrum(i,:));
    xData = FreqData.fAxis(i,1:stepSize:end);
    yData =  FreqData.freqSpectrum(i,1:stepSize:end);

    curLine = plot(xData,yData,marker,'DisplayName',FreqData.Name{i},...
        'LineWidth',lw,'Color',[color, alpha]);
    curLine.UserData.ShowLine = 1;
    counter = counter + 1;


end
timePlot = gca;
xlim([0 fcut])
legend('Interpreter','none','Location','southoutside','NumColumns',1)
set(timePlot,'FontSize',0.5*fs)

m = uimenu('Text','USER-Options');
hideShow     = uimenu(m, 'Label', 'Hide/Show');
uimenu(hideShow, 'Text', 'Hide Lines', 'MenuSelectedFcn', {@hideLine,timePlot,'hide'} )
uimenu(hideShow, 'Text', 'Hide Lines with Filter', 'MenuSelectedFcn', {@hideLine,timePlot,'hide','filter'} )
uimenu(hideShow, 'Text', 'Show Lines', 'MenuSelectedFcn', {@hideLine,timePlot,'show'} )
uimenu(hideShow, 'Text', 'Show Lines with Filter', 'MenuSelectedFcn', {@hideLine,timePlot,'show','filter'} )
uimenu(hideShow, 'Text', 'Delete Lines', 'MenuSelectedFcn', {@hideLine,timePlot,'delete'} )
uimenu(m, 'Text', 'Change Legend Names', 'MenuSelectedFcn', @changeLegendNames)
uimenu(m, 'Text', 'Save', 'MenuSelectedFcn', @SaveFigure)
%%


function hideLine(src, event, timePlot, mode1, mode2) 

if nargin < 5 || isempty(mode2)
    mode2 = 'select';
end

timeLines = findobj(timePlot, 'Type', 'line');


showTF = zeros(numel(timeLines),1);
lines  = strings(numel(timeLines),1);
for iLine = 1:numel(timeLines)
    lines(iLine) = timeLines(iLine).DisplayName;
    if isempty(timeLines(iLine).UserData) || timeLines(iLine).UserData.ShowLine
        showTF(iLine) = 1;
    end
end

switch mode1
    case 'hide'
    assert(any(showTF), 'No Lines to hide') 
    switch mode2
        case 'select'
   
            [sel_indx,tf] = select(lines(showTF==1));
        
            indx = find(showTF);
            indx = indx(sel_indx);
        case 'filter'
            answer = filter();
            idx    = contains(lines,answer,'IgnoreCase',true);
            indx   = find(idx);
            tf     = true;


    end

    if tf
        for ix = indx'
            timeLines(ix).Visible = 'off';
            timeLines(ix).Annotation.LegendInformation.IconDisplayStyle = 'off';
            timeLines(ix).UserData.ShowLine = 0;
        end
    else
        fprintf('No lines selected')
    end

    case 'show'

    assert(any(~showTF), 'No Lines to hide')

    switch mode2
        case 'select'
            [sel_indx,tf] = select(lines(showTF==0));
        
            indx = find(~showTF);
            indx = indx(sel_indx);
        case 'filter'
            answer = filter();
            idx    = contains(lines,answer,'IgnoreCase',true);
            indx   = find(idx);
            tf     = true;
    end

    if tf
        for ix = indx'
            timeLines(ix).Visible = 'on';
            timeLines(ix).Annotation.LegendInformation.IconDisplayStyle= 'on';
            timeLines(ix).UserData.ShowLine = 1;
        end
    else
        fprintf('No lines selected')
    end

    case 'delete'
        [sel_indx,tf] = select(lines);

        if tf
            for i = sel_indx
                delete(timeLines(i))
            end
        end
end


end

%%
function [sel_indx,tf] = select(list)
            [sel_indx,tf] = listdlg('PromptString','Delete Lines',...
        'Selectionmode','multiple','ListString',list, 'ListSize', [500, 200]);

end
%%
function answer = filter()
    prompt = {'Filter all lines that do contain:'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'Trace'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
end