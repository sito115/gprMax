clear, close all
addpath(genpath(pwd))
% Data = load('C:\OneDrive - Delft University of Technology\4. Semester - Thesis\AmplitudesData.mat');
Data = load("C:\OneDrive - Delft University of Technology\4. Semester - Thesis\AllPeaks.mat");
Data = Data.AllPeaks;
fn = fieldnames(Data);

fs = 10;
lw = 2.5;
markers = {'--',':','-.'};
alpha = 0.7;

mode = 'AirVsGround';
switch mode 
    case 'AirVsGround'
    waveName = {'Airwave','Groundwave'};
    case 'Airwave'
    waveName = {mode};
    case 'Groundwave'
    waveName = {mode};    
end


%% HOMO 
Homogeneous5 = Data.Homogeneous5        ;
A0_air       = Homogeneous5.Airwave.PeaksTime(:,2);
A0_ground    = Homogeneous5.Groundwave.PeaksTime(:,2);
%% VDK
% VDK5 = Data.VDK5;
% VDK10 = Data.VDK10;
% 
% figure
% hold on
% plot(VDK5.Airwave, 'LineWidth',lw,'DisplayName','v.d.K 5cm - Airwave')
% plot(VDK10.Airwave,':', 'LineWidth',lw,'DisplayName','v.d.K 10cm - Airwave')
% plot(VDK5.Groundwave, 'LineWidth',lw,'DisplayName','v.d.K 5cm - Groundwave')
% plot(VDK10.Groundwave,':', 'LineWidth',lw,'DisplayName','v.d.K 10cm - Groundwave')
% xlim([1 numel(VDK5.Airwave)])
% xlabel('Trace', 'FontSize',fs)
% ylabel('Amplitude', 'FontSize',fs)
% l = legend('Interpreter','none','FontSize',fs);
% l.Location = "southoutside";
% grid on

%%
[sel_indxALL,tf] = listdlg('PromptString','Select A1',...
    'SelectionMode','multiple','ListString',fn, 'ListSize', [500, 200]);
assert(tf == true)
%% Time Peaks vs Offset

colors = distinguishable_colors(numel(sel_indxALL));

for name = waveName
    figure
    for iter = 1:numel(sel_indxALL)
        i = sel_indxALL(iter);

        if isfield(Data.(fn{i}),(name))
            A1 = Data.(fn{i}).(name{1}).PeaksTime(:,2);
        else
            fprintf('No data for %s in %s\n',name{1}, Data.(fn{i}).FileName)
            A1 = nan*zeros(1,Data.(fn{i}).Attributes.nrx);
        end

        dispName = Data.(fn{i}).(name{1}).Name{1};

        lineSpec = markers{randi([1 3])};
        
        lh = plot(A1,lineSpec, 'LineWidth', lw,'DisplayName',sprintf('%s - %s',fn{i},dispName),'Color',colors(iter,:));
        lh.Color = [lh.Color alpha];
        hold on
        title(name, 'Interpreter','none','FontSize',fs)
	    xlim([1 numel(A1)])
        xlabel('Trace', 'FontSize',fs)
        ylabel('Amplitude', 'FontSize',fs)
    
    end
    l = legend('Interpreter','none','FontSize',fs);
    l.Location = "southoutside";
end

%% Time Peaks vs Time

for name = waveName
    figure
    for iter = 1:numel(sel_indxALL)
        i = sel_indxALL(iter);
        
        if isfield(Data.(fn{i}),(name))
            A1 = Data.(fn{i}).(name{1}).PeaksTime(:,2);
        else
            fprintf('No data for %s in %s\n',name{1}, Data.(fn{i}).FileName)
            A1 = nan*zeros(1,Data.(fn{i}).Attributes.nrx);
        end

        dispName = Data.(fn{i}).(name{1}).Name{1};

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
    l = legend('Interpreter','none','FontSize',fs);
    l.Location = "southoutside";
end

%% FFT Peaks vs Offset
for name = waveName
    figure
    for i = sel_indxALL
        
        if isfield(Data.(fn{i}),(name))
            A1 = Data.(fn{i}).(name{1}).PeaksFFT(:,1);
        else
            fprintf('No data for %s in %s\n',name{1}, Data.(fn{i}).FileName)
            A1 = nan*zeros(1,Data.(fn{i}).Attributes.nrx);
        end

        dispName = Data.(fn{i}).(name{1}).Name{1};

        lineSpec = markers{randi([1 3])};
        
        lh = plot(A1,lineSpec, 'LineWidth', lw,'DisplayName',sprintf('%s - %s',fn{i},dispName));
        lh.Color = [lh.Color alpha];
        hold on
        title([name '- FFT'], 'Interpreter','none','FontSize',fs)
	    xlim([1 numel(A1)])
        xlabel('Trace', 'FontSize',fs)
        ylabel('Center Frequency', 'FontSize',fs)
    
    end
    l = legend('Interpreter','none','FontSize',fs);
    l.Location = "southoutside";
end

%% FFT Peaks vs Frequency
for name = waveName
    figure
    for i = sel_indxALL
        
        if isfield(Data.(fn{i}),(name))
            A1 = Data.(fn{i}).(name{1}).PeaksFFT(:,2);
        else
            fprintf('No data for %s in %s\n',name{1}, Data.(fn{i}).FileName)
            A1 = nan*zeros(1,Data.(fn{i}).Attributes.nrx);
        end

        dispName = Data.(fn{i}).(name{1}).Name{1};

        lineSpec = markers{randi([1 3])};
        
        lh = plot(Data.(fn{i}).(name{1}).PeaksFFT(:,1),A1,lineSpec, 'LineWidth', lw,'DisplayName',sprintf('%s - %s',fn{i},dispName));
        lh.Color = [lh.Color alpha];
        hold on
        title([name '-FFT'], 'Interpreter','none','FontSize',fs)
% 	    xlim([1 numel(A1)])
        xlabel('Frequency', 'FontSize',fs)
        ylabel('Amplitude', 'FontSize',fs)
    
    end
    l = legend('Interpreter','none','FontSize',fs);
    l.Location = "southoutside";
end


%%
figure
for iter = 1:numel(sel_indxALL)
    sel_indx = sel_indxALL(iter);

    if isfield(Data.(fn{sel_indx}),'Airwave') && isfield(Data.(fn{sel_indx}),'Groundwave')
        A1_air    = Data.(fn{sel_indx}).Airwave.PeaksTime(:,2);
        A1_ground = Data.(fn{sel_indx}).Groundwave.PeaksTime(:,2);
    else
        fprintf('No data for %s in %s\n',name{1}, Data.(fn{i}).FileName)
        A1_air      = nan* ones(1,Data.(fn{i}).Attributes.nrx);
        A1_ground   = nan* ones(1,Data.(fn{i}).Attributes.nrx);
    end


    dispName = Data.(fn{i}).(name{1}).Name{1};

    lineSpec = markers{randi([1 3])};

    lh = plot(A1_air./A1_ground,lineSpec,'LineWidth', lw,...
        'DisplayName',sprintf('%s - %s',fn{sel_indx},dispName),'Color',colors(iter,:));
    lh.Color = [lh.Color alpha];
    hold on
end
title('Airwave / Groundwave')
xlim([1 numel(A1)])
xlabel('Trace', 'FontSize',fs)
l = legend('Interpreter','none','FontSize',fs);
l.Location = "southoutside";

%%
% figure
% 
% for sel_indx = sel_indxALL
%     for name = waveName
%         if isfield(Data.(fn{sel_indx}),name{1})
%             A1 = Data.(fn{sel_indx}).(name{1}).PeaksTime(:,2);
%         else
%             fprintf('No data for %s in %s\n',name{1}, Data.(fn{i}).FileName)
%             A1 = nan*ones(1,Data.(fn{i}).Attributes.nrx);
%         end
%     A0 = Homogeneous5.(name{1}).PeaksTime(:,2);
% 
%     dispName = Data.(fn{i}).(name{1}).Name{1};
% 
%     lineSpec = markers{randi([1 3])};
% 
%     lh = plot(A0./A1,lineSpec,'LineWidth', lw,'DisplayName',sprintf('%s - %s - %s',fn{sel_indx},name{1},dispName));
%     lh.Color = [lh.Color alpha];
%     hold on
%     end
% end
% title('Rel. Amplitudes', 'Interpreter', 'none', 'FontSize', fs)
% xlim([1 numel(A1)])
% xlabel('Trace', 'FontSize',fs)
% ylabel('Rel. Amplitude to homogeneous case (5)', 'FontSize',fs)
% l = legend('Interpreter','none','FontSize',fs);
% l.Location = "southoutside";

% zeros(1,9)
h = findobj(gca,'Type','Line');
stringTitle = get(gca,'title');
disp(stringTitle.String)
for i = 1:numel(h)
    fprintf('\t%s\n', h(i).DisplayName)
    fprintf('\t\t Mean: %f\n', mean(h(i).YData(15:25))/1e6)
end


