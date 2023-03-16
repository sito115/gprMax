clear, clc, %close all

%% PARAMETER
lw            = 1.5;    % line width
fs            = 18;     % font size
pathRoot      = 'C:\OneDrive - Delft University of Technology'; % specific pathRoot

% Dialog
prompt = {'Component [Ex, Ey, Ez]', 'Cutoff Frequency', 'Threshold first non-zero value',...
          'Normalize Time? [1 or 0]', 'Normalize Frequency? [1 or 0]',sprintf('Use working directory [0] "%s" or specific pathRoot (for Thomas only) [1] "%s"',pwd, pathRoot)};
answer = inputdlg(prompt','Define Parameters',[1 150],{'Ex', '4e8', '1e-7', '0', '0','1'});

component         = answer{1};
fcut              = str2double(answer{2});
nonZeroThresh     = str2double(answer{3});
normalizationTime = str2double(answer{4});
normalizationFreq = str2double(answer{5});
isFolder          = str2double(answer{6});

% Default folders
if isFolder
    trdSemester  = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\thomas\python';
    figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';
else
    pathRoot = pwd;
    trdSemester = '';
    figureFolder ='';
end


filenameArray = {'PlaceAntennas_Dist1.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist2.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist3.5m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist4.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist5.0m_tSim5.00e-08_eps1.00_iA1_iBH0 (2).out',...
                 'PlaceAntennas_Dist7.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out'};

%% Start Skript
allData  = struct;

answer = questdlg(['Start of the program: Which files should be selected? Pre-Selected files' filenameArray], ...
    'Question', ...
    'Manual','Default (only for Thomas)','Cancel','Manual');
% Handle response
switch answer
    case 'Manual'
        isManual = 1;
    case 'Default'
        isManual = 0;
        pathname        = fullfile(pathRoot, trdSemester, 'Results');   
        allData = load_output(allData,filenameArray, pathname);
    case 'Cancel'
        return
end

%% Start Loading Data
isFile = 1;
while isFile == 1
    [filenameArray, pathname, check] = uigetfile([fullfile(pathRoot,trdSemester,'Results') '\*.out'],...
                                'Select gprMax output file to plot B-scan', 'MultiSelect', 'on');
    
    if check == 0   % user pressed cancel
        break
    end

    allData = load_output(allData,filenameArray, pathname);

    answer = questdlg('Would you like to chose more files?', ...
	    'Question', ...
	    'Yes','No','Cancel','No');
    % Handle response
    switch answer
        case 'Yes'
            isFile = 1;
        case 'No'
            isFile = 0;
        case 'Cancel'
            return
    end
end

fieldNames = fieldnames(allData);
nField     = numel(fieldNames);

%% PLOT
% TIME DOMAIN

f = figure;
t = tiledlayout(1,2, 'Parent',f); %, 'Units', 'normalized','OuterPosition',[0 0.15 1 0.85]);
timeLines = struct;
timePlot = nexttile;
grid on

hold on
set(gca, 'FontSize', fs)

% legend
xlabel('Time (s)')
title([component ' - Time Domain'])

% FREQUENCY DOMAIN
freqPlot = nexttile;
grid on
set(gca, 'FontSize', fs)
hold on

xlim([0 fcut])
xlabel('Frequency (Hz)')

colors = distinguishable_colors(nField);

for iField = 1:nField
    TempField = allData.(fieldNames{iField});
    color = colors(iField,:);
    firstBreak  = plotTimeDomain(TempField, component, normalizationTime, lw, nonZeroThresh,timePlot, color);
    plotFreq(TempField, color, component, lw, normalizationFreq, freqPlot)
    allData.(fieldNames{iField}).FirstBreak = firstBreak;
end


lg = legend('Interpreter','none', 'FontSize', fs, 'Orientation','Vertical','NumColumns',2);
lg.Layout.Tile = 'south';
title([component,' - Frequency Domain'])


%% MENU
m = uimenu('Text','USER-Options');


uimenu(m,'Text','Pick Times', 'MenuSelectedFcn',{@PickTimes,t,nField});
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn','SaveFigure(fullfile(pathRoot, figureFolder))');
uimenu(m, 'Text', 'Change Legend Names', 'MenuSelectedFcn', @changeLegendNames)
uimenu(m, 'Text', 'Add Title', 'MenuSelectedFcn', {@addTitle,t, fs})
% uimenu(m, 'Text', 'Change Legend Order', 'MenuSelectedFcn', @changeLegendOrder)
uimenu(m, 'Text', 'Add Line', 'MenuSelectedFcn', ['allData = addLine(timePlot, freqPlot, pathRoot,trdSemester,' ...
                                                 'component, normalizationTime, lw, nonZeroThresh, normalizationFreq, allData);'] );  
uimenu(m, 'Text', 'Delete Lines', 'MenuSelectedFcn', {@deleteLine, timePlot, freqPlot} )

uimenu(m, 'Text', 'Overlap at first break', 'MenuSelectedFcn', 'overlapLines(allData , nonZeroThresh, normalizationTime, timePlot, component, lw, fs, fullfile(pathRoot, figureFolder))' )

%% Pick times
function PickTimes(src,event,t,nLines)
    button = 1;
    counter = numel(get(gca,'Children'))-nLines;
    while button == 1
        counter = counter + 1;
        [x,y, button] = ginput(1);
        if button ~= 1
            break
        end
        fprintf('Point #%d at time at %e \n',counter, x)
        axnum = find(ismember(t.Children,gca));
        plot(x,y,'Parent',t.Children(axnum), 'Color','r', 'Marker','o', 'HandleVisibility','on','MarkerSize',8)
        text(x,y,sprintf('#%d', counter),'VerticalAlignment','top','HorizontalAlignment','left','HandleVisibility','off',...
             'FontSize',15)
    end
end

%% Save figure



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

%% 
function changeLegendOrder(src, event)

dlgtitle = 'Change Legend';


lgObj = findobj(gcf,'Type','Legend');
prompt = lgObj.String;

prevOrder = arrayfun(@num2str,1:numel(prompt),'Uni',0);

answer = inputdlg(prompt',dlgtitle,[1 150],prevOrder');

h = zeros(1, numel(prompt));
for i = 1:numel(prompt)
h(i) = str2double(answer{i});
end


set(gcf, 'Legend', lgObj(h))
uistack(h,'top')

end


%% delete Lines
function deleteLine(src, event, timePlot, freqPlot) 

axesHandlesToChildObjects = findobj(gcf, 'Type', 'Legend');
lines = flipud(axesHandlesToChildObjects.String');


[indx,tf] = listdlg('PromptString','Delete Lines',...
    'SelectionMode','multiple','ListString',lines, 'ListSize', [500, 200]);

timeLines = findobj(timePlot, 'Type', 'line');
freqLines = findobj(freqPlot, 'Type', 'line');

if tf
    for i = indx
        delete(timeLines(indx))
        delete(freqLines(indx))
    end
else
    fprintf('No lines selected')
end

end


