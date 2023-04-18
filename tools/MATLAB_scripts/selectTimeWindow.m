%% select time window
function selectTimeWindow(src,event, timePlot, fcut, lw, fs, component)

alpha = 0.7;

% Prompt the user to enter start and end values
prompt = {'Enter start value [ns]:', 'Enter end value [ns]:'};
title = 'Input';
dims = [1 35];
default = {'10', '20'};
input = inputdlg(prompt, title, dims, default);

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



fWindow = figure('Visible','off');
m = uimenu('Text','USER-Options');

t = tiledlayout(1,2, 'Parent',fWindow); 

% Time
timeTile = nexttile;
hold on
set(gca, 'FontSize', fs)
grid on

% legend
xlabel('Time (s)')
timeTile.Title.String = [component ' - Time Domain'];
lg = legend('Interpreter','none', 'FontSize', fs, 'Orientation','Vertical','NumColumns',2);
lg.Layout.Tile = 'south';


% FREQUENCY DOMAIN
freqTile = nexttile;
grid on
set(gca, 'FontSize', fs)
hold on

xlim([0 fcut])
xlabel('Frequency (Hz)')
freqTile.Title.String = [component,' - Frequency Domain'];


% Plot
timeLines = findobj(timePlot, 'Type', 'line');
for iLine = 1:numel(timeLines)
    if timeLines(iLine).UserData.ShowLine
        tempData = timeLines(iLine).YData;

        tempAxis = timeLines(iLine).XData;
        iT0      = find(tempAxis >= start_value, 1,"first");
        iTEnd    = find(tempAxis >= end_value, 1,"first");

        tempData = tempData(iT0:iTEnd);
        tempAxis = tempAxis(iT0:iTEnd);

        dt         = timeLines(iLine).UserData.Attributes.dt;
        iterations = numel(tempAxis);

        fprintf('\tPerforming FFT...')
        exp2n = log2(iterations); % get exponent for 2^n series
        exp2n = ceil(exp2n + 2);  % get next higher exponent
        
        iterationsFFT = 2^exp2n;
        
        df    = 1/(dt*iterationsFFT);
        fAxis = linspace(0,iterationsFFT/2,fix(iterationsFFT/2+1))*df;    %making the frequency axis
        
        tempDataFFT  = [tempData';zeros(iterationsFFT-iterations,1)];
        fftData   = fft(tempDataFFT, [], 1)*dt;
        fftData   = abs(fftData(:,:));

        fprintf('Done \n')
        color = timeLines(iLine).UserData.Color;
        legendString = timeLines(iLine).DisplayName;

        plot(tempAxis,tempData , 'DisplayName',legendString,...
                           'LineWidth', lw, 'Parent',timeTile,'Color',[color,alpha])

        plot(fAxis, fftData(1:numel(fAxis)),...
            'DisplayName',legendString,'LineWidth', lw, 'Color',[color,alpha], 'Parent', freqTile)
    end
end

fWindow.Visible = 'on';

uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn','SaveFigure(fullfile(pathRoot, figureFolder))');

uimenu(m, 'Text', 'Hide Lines', 'MenuSelectedFcn', {@deleteLine,timeTile, freqTile,'hide'} )
uimenu(m, 'Text', 'Show Lines', 'MenuSelectedFcn', {@deleteLine,timeTile, freqTile,'show'} )

t.Title.String = sprintf('Time Window from %g ns to %g ns', start_value*1e9, end_value*1e9);

end