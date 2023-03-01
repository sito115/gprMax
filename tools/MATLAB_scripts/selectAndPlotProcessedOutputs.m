clear, clc, close all
%% LOAD
pathRoot     = 'C:\OneDrive - Delft University of Technology';
trdSemester  = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\thomas\python';
figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';

data = load(fullfile(pathRoot, '3. Semester - Studienunterlagen\ResearchModule\AllResults.mat'));
Results = data.Results;
names = fieldnames(Results);

%% PARAMETER
fcut          = 5e8;
lw            = 1.5;
fs            = 15;
isPickt0      = true;
nonZeroThresh = 1e-7;

% Select files
[indx,tf] = listdlg('PromptString',{'Select files.',...
    'Will be loaded and plotted for TD and FD.',''},...
    'SelectionMode','multiple','ListString',names, 'ListSize',[400 300]);
assert(tf ~= 0, 'No file was selected.')



%% PLOT
% TIME DOMAIN
fC = zeros(numel(indx),1);

t = tiledlayout(1,2);
timeLines = struct;
nexttile
grid on
set(gca, 'FontSize', fs)
hold on
counter = 0;
fprintf('#### Time Domain ####\n\n')
for iSelec = indx
    counter = counter + 1;
    nameSel = names{iSelec};
    [~,nameDisp,ext] = fileparts(Results.(nameSel).Attributes.fullfileName);
    tempData = Results.(nameSel).Data.fields;
    tempAxis = Results.(nameSel).Axis;

    fprintf('\t %s \n',nameDisp)
    exValuesNormalized = tempData.Ex/max(abs([min(tempData.Ex), max(tempData.Ex)]));
    idx = find(abs(exValuesNormalized)>nonZeroThresh,1);
    fprintf('First non-zero value above threshold %.2e = %e s\n', nonZeroThresh, tempAxis.time(idx(1)))

    curLine = plot(tempAxis.time,exValuesNormalized , 'DisplayName',names{iSelec},'LineWidth', lw);
    timeLines.(nameSel) = curLine;
    xlabel('Time (s)')

end
% legend
title('Ex - Time Domain')

% FREQUENCY DOMAIN
fprintf('\n#### Frequency Domain ####\n\n')
nexttile
grid on
set(gca, 'FontSize', fs)
hold on
counter = 0;

for iSelec = indx
    counter = counter +1;
    nameSel = names{iSelec};
    [~,nameDisp,ext] = fileparts(Results.(nameSel).Attributes.fullfileName);
    tempData = Results.(nameSel).Data.FFT;
    tempAxis = Results.(nameSel).Axis;
    
    currentLine = plot(tempAxis.fAxis, tempData.ExNorm(1:numel(tempAxis.fAxis)), 'DisplayName',[nameDisp,ext],...
            'LineWidth', lw);

    color = get(currentLine, 'Color');
    fcTemp = Results.(nameSel).Label.DomFreq;
    maxAmp = Results.(nameSel).Label.MaxAmp;

    fprintf('\t %s \n',nameDisp)
    fprintf('F_c = %e Hz\n', fcTemp)
    fprintf('A_max = %e s\n', maxAmp)

    fC(counter) = fcTemp;
    xline(fcTemp, 'HandleVisibility','off',....
        'LabelVerticalAlignment','bottom',...
        'LabelHorizontalAlignment','center', 'LineStyle','-.', 'Color',color,...
        'LineWidth',lw)
    xlim([0 fcut])
    xlabel('Frequency (Hz)')
end
l = legend('Interpreter','none', 'FontSize', fs);
title('Ex - Frequency Domain')


%% MENU
m = uimenu('Text','USER-Options');
mitem = uimenu(m,'Text','Pick Times');
mitem.MenuSelectedFcn = {@PickTimes,t,numel(indx)};


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



