clear , close all

% This skript lets you load picked amplitudes that have been stored in a
% .mat file. Eventually, Tab. 5.3 and 5.4 of the thesis have been computed
% with this function by taking an average between a selected range of
% traces as indicated in the thesis.


%% parameters
fs = 25;  %font size
lw = 2.5; %line width
markers = {'o--','o:','o-.'}; %markers for points in plot
alpha = 0.7; % transparency
legendFactor = 0.6; % scale font size of legend


% load .mat file
Data = load('mat-Files\AllPeaks.mat');

% load paths of corresponding .out files
outputFolder = 'gprMax_InOutVti-Files';
files = dir([outputFolder '\**\*.out']);
files = struct2table(files);

Data = Data.AllPeaks;
fn = fieldnames(Data);

waveName = {'Airwave','Groundwave'}; % plot both air and ground waves


%% HOMO 
Homogeneous5 = Data.Homogeneous5        ;
A0_air       = Homogeneous5.Airwave.PeaksTime(:,2);
A0_ground    = Homogeneous5.Groundwave.PeaksTime(:,2);

%%
[sel_indxALL,tf] = listdlg('PromptString','Select A1',...
    'SelectionMode','multiple','ListString',fn, 'ListSize', [500, 200]);
assert(tf == true)

for i = sel_indxALL
    name = Data.(fn{i}).Airwave.Name{1};
    name = split(name);
    name = name{1};
    idx  = find(strcmpi(name,files.name));
    idx  = idx(1);
    allData = load_output([], files.name{idx},files.folder{idx}, false);
    fieldNames = fieldnames(allData);
    Data.(fn{i}).Offset = allData.(fieldNames{1}).Attributes.Offset_x;
end

%% Time Peaks vs Offset

colors = distinguishable_colors(numel(sel_indxALL));

for name = waveName
    figure
    for iter = 1:numel(sel_indxALL)
        i = sel_indxALL(iter);

        if isfield(Data.(fn{i}),(name))
            if strcmp(name,'Groundwave')
                A1 = Data.(fn{i}).(name{1}).PeaksTime(:,2);
            else
                A1 = Data.(fn{i}).(name{1}).PeaksTime(:,4);
            end
            dispName = Data.(fn{i}).(name{1}).Name{1};
        else
            fprintf('No data for %s in %s\n',name{1}, fn{i})
            A1 = nan;
            dispName = sprintf('NAN-%s',(fn{i}));
        end

        lineSpec = markers{randi([1 3])};
        
        lh = plot(Data.(fn{i}).Offset,A1,lineSpec, 'LineWidth', lw,'DisplayName',sprintf('%s - %s',fn{i},dispName),'Color',colors(iter,:));
        lh.Color = [lh.Color alpha];
        hold on
        title(name, 'Interpreter','none','FontSize',fs)
        xlabel('Offset (m)', 'FontSize',fs)
        ylabel('Amplitude', 'FontSize',fs)
        set(gca,'FontSize',fs)
    end
    l = legend('Interpreter','none','FontSize',legendFactor*fs);
    l.Location = "southoutside";
end

%% Time Peaks vs Time

for name = waveName
    figure
    for iter = 1:numel(sel_indxALL)
        i = sel_indxALL(iter);
        
        if isfield(Data.(fn{i}),(name))
            A1 = Data.(fn{i}).(name{1}).PeaksTime(:,2);
            dispName = Data.(fn{i}).(name{1}).Name{1};
        else
            fprintf('No data for %s in %s\n',name{1}, fn{i})
            A1 = nan;
            dispName = sprintf('NAN-%s',(fn{i}));
            continue
        end



        lineSpec = markers{randi([1 3])};
        
        lh = plot(Data.(fn{i}).(name{1}).PeaksTime(:,1),A1,lineSpec, 'LineWidth', lw,...
            'DisplayName',sprintf('%s - %s',fn{i},dispName),'Color',colors(iter,:));
        lh.Color = [lh.Color alpha];
        hold on
        title(name, 'Interpreter','none','FontSize',fs)
% 	    xlim([1 numel(A1)])
        xlabel('Time [s]', 'FontSize',fs)
        ylabel('Amplitude', 'FontSize',fs)
    
    end
    l = legend('Interpreter','none','FontSize',legendFactor*fs);
    l.Location = "southoutside";
end
set(gca,'FontSize',fs)
%% FFT Peaks vs Offset
for name = waveName
    figure
    for i = sel_indxALL
        
        if isfield(Data.(fn{i}),(name))
            A1 = Data.(fn{i}).(name{1}).PeaksFFT(:,1);
            dispName = Data.(fn{i}).(name{1}).Name{1};
        else
            fprintf('No data for %s in %s\n',name{1},fn{i})
            A1 = nan;
            dispName = sprintf('NAN-%s',(fn{i}));
        end



        lineSpec = markers{randi([1 3])};
        
        lh = plot(Data.(fn{i}).Offset,A1,lineSpec, 'LineWidth', lw,'DisplayName',sprintf('%s - %s',fn{i},dispName));
        lh.Color = [lh.Color alpha];
        hold on
        title([name '- FFT'], 'Interpreter','none','FontSize',fs)
        xlabel('Offset (m)', 'FontSize',fs)
        ylabel('Center Frequency', 'FontSize',fs)
    
    end
    l = legend('Interpreter','none','FontSize',legendFactor*fs);
    l.Location = "southoutside";
end
set(gca,'FontSize',fs)


%%
figure
for iter = 1:numel(sel_indxALL)
    sel_indx = sel_indxALL(iter);

    if isfield(Data.(fn{sel_indx}),'Airwave') && isfield(Data.(fn{sel_indx}),'Groundwave')
        A1_air    = Data.(fn{sel_indx}).Airwave.PeaksTime(:,4);
        A1_ground = Data.(fn{sel_indx}).Groundwave.PeaksTime(:,2);
        dispName = Data.(fn{sel_indx}).(name{1}).Name{1};
    else
        fprintf('No data for %s in %s\n',name{1}, fn{i})
        A1_air      = nan;
        A1_ground   = nan;
        dispName = sprintf('NAN-%s',(fn{i}));
    end

    lineSpec = markers{randi([1 3])};

    lh = plot(Data.(fn{sel_indx}).Offset,A1_air./A1_ground,lineSpec,'LineWidth', lw,...
        'DisplayName',sprintf('%s - %s',fn{sel_indx},dispName),'Color',colors(iter,:));
    lh.Color = [lh.Color alpha];
    hold on
end
title('Airwave / Groundwave')
xlabel('Offset (m)', 'FontSize',fs)
l = legend('Interpreter','none','FontSize',legendFactor*fs);
l.Location = "southoutside";
set(gca,'FontSize',fs)


h = findobj(gca,'Type','Line');
stringTitle = get(gca,'title');
disp(stringTitle.String)
for i = 1:numel(h)
    fprintf('\t%s\n', h(i).DisplayName)
    fprintf('\t\t Mean: %f\n', mean(h(i).YData(19:29)))
end




% h = findobj(gca,'Type','Line');
% stringTitle = get(gca,'title');
% disp(stringTitle.String)
% for i = numel(h):-1:1
% %     fprintf('%s\n',h(i).DisplayName)
%     [maxA,idx] = max(h(i).YData);
% %     h(i).YData = h(i).YData./maxA;
%     fprintf('\t%f\n', maxA) %h(i).XData(idx))
% % fprintf('\t\t%f\n', )
% % fprintf('\t\t max: %f\n',maxA)
% end



