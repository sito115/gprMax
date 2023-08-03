function showAScan(src,evt,timePlot)
% Show full A-scan of a selected traces which includes Ex,Ey,Ez,Hx,Hy,Hz.
%
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs
% timePlot      : axis object of the tile containg data in time domain



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

for i = sel_indx
    figure('Name', timeLines(i).DisplayName);
    fields = timeLines(i).UserData.Data.fields;
    iRx    = timeLines(i).UserData.iRx;
    time   = timeLines(i).UserData.Axis.time*1e9;
    ax(1) = subplot(3,2,1); plot(time, fields.Ex(:,iRx), 'r', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [V/m]'), title('E_x')
    ax(2) = subplot(3,2,3); plot(time, fields.Ey(:,iRx), 'r', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [V/m]'), title('E_y')
    ax(3) = subplot(3,2,5); plot(time, fields.Ez(:,iRx), 'r', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [V/m]'), title('E_z')
    ax(4) = subplot(3,2,2); plot(time, fields.Hx(:,iRx), 'b', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [A/m]'), title('H_x')
    ax(5) = subplot(3,2,4); plot(time, fields.Hy(:,iRx), 'b', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [A/m]'), title('H_y')
    ax(6) = subplot(3,2,6); plot(time, fields.Hz(:,iRx), 'b', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [A/m]'), title('H_z')
    set(ax,'FontSize', 16, 'xlim', [0 time(end)]);
end


end

