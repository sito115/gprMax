clear, clc, close all

%% PARAMETER
lw            = 1.5;    % line width
fs            = 15;     % font size

% Dialog
prompt = {'Component [Ex, Ey, Ez]', 'Cutoff Frequency', 'Threshold first non-zero value',...
          'Normalize Time? [1 or 0]', 'Normalize Frequency? [1 or 0]'};
answer = inputdlg(prompt','Define Parameters',[1 150],{'Ex', '5e8', '1e-7', '1', '0'});

component         = answer{1};
fcut              = str2double(answer{2});
nonZeroThresh     = str2double(answer{3});
normalizationTime = str2double(answer{4});
normalizationFreq = str2double(answer{5});

% Default folders
pathRoot     = 'C:\OneDrive - Delft University of Technology';
trdSemester  = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\thomas\python';
figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';


% filenameArray = {'PlaceAntennas_Dist2.0m_tSim2.00e-08_eps1.00_iA1_iBH0.out',  ...
%                  'PlaceAntennas_Dist3.0m_tSim3.00e-08_eps1.00_iA1_iBH0.out',  ...
%                  'PlaceAntennas_Dist3.5m_tSim2.92e-08_eps1.00_iA1_iBH0.out',  ...
%                  'PlaceAntennas_Dist4.0m_tSim4.00e-08_eps1.00_iA1_iBH0.out',  ...
%                  'PlaceAntennas_Dist5.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out',  ...
%                  'PlaceAntennas_Dist7.0m_tSim7.00e-08_eps1.00_iA1_iBH0.out'  };
% 
filenameArray = {'PlaceAntennas_Dist1.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist2.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist3.5m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist4.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist5.0m_tSim5.00e-08_eps1.00_iA1_iBH0 (2).out',...
                 'PlaceAntennas_Dist7.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out'};

pathname        = fullfile(pathRoot, trdSemester, 'Results');

%% Start Skript
allData  = struct;

answer = questdlg(['Start of the program: Which files should be selected? Pre-Selected files' filenameArray], ...
    'Question', ...
    'Manual','Default','Cancel','Manual');
% Handle response
switch answer
    case 'Manual'
        isManual = 1;
    case 'Default'
        isManual = 0;
        allData = load_output(allData,filenameArray, pathname);
    case 'Cancel'
        return
end

%% Start Loading Data
isFile = 1;
while isFile == 1
    [filenameArray, pathname, check] = uigetfile([fullfile(pathRoot,trdSemester) '\*.out'],...
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
nexttile
grid on
set(gca, 'FontSize', fs)
hold on

fprintf('#### Time Domain ####\n\n')
colors = zeros(nField,3);
for iField = 1:nField
    TempField = allData.(fieldNames{iField});

    tempData = TempField.Data.fields.(component);
    tempAxis = TempField.Axis.time;

    fprintf('%s \n',TempField.FileName)

    if normalizationTime 
        tempData = tempData/max(abs([min(tempData), max(tempData)]));
    end

    idx = find(abs(tempData)>nonZeroThresh,1);
    fprintf('\tFirst non-zero value above threshold %.2e = %e s\n', nonZeroThresh, tempAxis(idx(1)))
    
    [~, indTd] = max(tempData);
    fprintf('\tMax Amplitude at %e s\n', tempAxis(indTd(1)))

    currentLine = plot(tempAxis,tempData , 'DisplayName',TempField.FileName,'LineWidth', lw);
    colors(iField,:) = get(currentLine, 'Color');

    xlabel('Time (s)')
end
% legend
title([component ' - Time Domain'])

% FREQUENCY DOMAIN
fprintf('\n#### Frequency Domain ####\n\n')
nexttile
grid on
set(gca, 'FontSize', fs)
hold on


for iField = 1:nField
    TempField = allData.(fieldNames{iField});

    tempData    = TempField.Data.FFT.(component);
    tempAxis    = TempField.Axis.fAxis;
    displayName = TempField.FileName;

    tempData = abs(tempData(:,:));
    if normalizationFreq 
        tempData = tempData/max(tempData);
    end
    
    fprintf('%s \n',TempField.FileName)

    plot(tempAxis, tempData(1:numel(tempAxis)),...
        'DisplayName',displayName,'LineWidth', lw, 'Color',colors(iField,:));

    [~, indFd] = max(tempData);
    fcenter = tempAxis(indFd(1));

    xline(fcenter, 'HandleVisibility','off',....
        'LabelVerticalAlignment','bottom',...
        'LabelHorizontalAlignment','center', 'LineStyle','-.', 'Color',colors(iField,:),...
        'LineWidth',lw)
    xlim([0 fcut])
    xlabel('Frequency (Hz)')

    fprintf('\tDominant Frequency at %e Hz\n', fcenter)
end

lg = legend('Interpreter','none', 'FontSize', fs, 'Orientation','Horizontal','NumColumns',2);
lg.Layout.Tile = 'south';
title([component,' - Frequency Domain'])


%% MENU
m = uimenu('Text','USER-Options');


uimenu(m,'Text','Pick Times', 'MenuSelectedFcn',{@PickTimes,t,nField});
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure, fullfile(pathRoot, figureFolder)});
uimenu(m, 'Text', 'Change Legend Names', 'MenuSelectedFcn', @changeLegendNames)



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
        fprintf('Point #%d at time at %e s\n',counter, x)
        axnum = find(ismember(t.Children,gca));
        plot(x,y,'Parent',t.Children(axnum), 'Color','r', 'Marker','o', 'HandleVisibility','on','MarkerSize',8)
        text(x,y,sprintf('#%d', counter),'VerticalAlignment','top','HorizontalAlignment','left','HandleVisibility','off',...
             'FontSize',15)
    end
end

%% Save figure
function SaveFigure(src, event, path)

filterUI = {'*.pdf';'*.jpg';'*.fig';'*.*'};

[file,Selpath] = uiputfile(filterUI,'defname', fullfile(path,'MyFigure')); 


% set(gcf,'Units','inches');
% screenposition = get(gcf,'Position');
% set(gcf,...
%     'PaperPosition',[0 0 screenposition(3:4)],...
%     'PaperSize',[screenposition(3:4)]);
% print -dpdf -painters epsFig
% 

fprintf('Saving %s...', file)

exportgraphics(gcf, fullfile(Selpath, file  ),...
               'ContentType','vector',...
               'BackgroundColor','none')  

fprintf('Done\n')

end


%% changeLegendNames
function changeLegendNames(src, event)

lgObj = findobj('Type','Legend');
prompt = lgObj.String;

dlgtitle = 'Change Legend Entry';

answer = inputdlg(prompt',dlgtitle,[1 150],prompt');

set(lgObj,'String',answer)

end