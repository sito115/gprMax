function selectTimeWindow(src,event, timePlot, fcut, lw, fs, component, isNormalize)
% Let the user define a time window in a GUI to display a trace and
% perform a FFT in this time window.
%
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs
% timePlot      : axis object of the tile containg data in time domain
% fcut          : float - cut off frequency to display in MHz
% lw            : float - Line Width
% fs            : float - Font Size
% component     : character [Ex,Ey,Ez]
% isNormalize   : logical -optional, false by default

if nargin < 8 || isempty(isNormalize)
    isNormalize = false;
end

alpha = 0.6;

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
start_value = str2double(input{1});
end_value   = str2double(input{2});

% Check if input is valid
if isnan(start_value) || isnan(end_value) || start_value > end_value
    msgbox('Invalid input! Please enter valid numeric values with start value less than or equal to end value.', 'Error');
    return;
end


% start (invisible) figure 
fWindow = figure('Visible','off');
% set(fWindow,'Color','white');
m = uimenu('Text','USER-Options');

t = tiledlayout(1,2, 'Parent',fWindow); 

% TIME DOMAIN plot
timeTile = nexttile;
hold on
set(gca, 'FontSize', fs)
grid on

% legend
xlabel('Time (ns)')
ylabel('Electric Field Strength (V/m)')
timeTile.Title.String = [component ' - Time Domain'];
lg = legend('Interpreter','none', 'FontSize', 0.75*fs, 'Orientation','Vertical','NumColumns',2);
lg.Layout.Tile = 'south';
handle_legend([],[],'hide', fs)
xlim([start_value end_value])
% FREQUENCY DOMAIN plot
freqTile = nexttile;
grid on
set(gca, 'FontSize', fs)
hold on

xlim([0 fcut])
xlabel('Frequency (MHz)')
freqTile.Title.String = [component,' - Frequency Domain'];


% FFT and plot lines
timeLines  = findobj(timePlot, 'Type', 'line');
peakValuesFFT = [];
peakValuesTime = [];
peakNames  = {};
for iLine = 1:numel(timeLines) % numel(timeLines):-1:1
    if ~isfield(timeLines(iLine).UserData,'ShowLine')
        timeLines(iLine).UserData.ShowLine = 0;
    end

    if timeLines(iLine).UserData.ShowLine
        fprintf('%s\n\t Performing FFT...',timeLines(iLine).DisplayName)
        % fft
        dt         = timeLines(iLine).UserData.Attributes.dt;
        % select x and y data
        tempData = timeLines(iLine).YData;
        tempAxis = timeLines(iLine).XData ;
        samples  = numel(tempAxis);

        % find start and end index
        iT0      = find(tempAxis >= start_value, 1,"first");
        if end_value > tempAxis(end)
            iTEnd   = samples;
        else
            iTEnd    = find(tempAxis >= end_value, 1,"first");
        end

        tempDataRaw = tempData(iT0:iTEnd);
        tempAxis    = tempAxis(iT0:iTEnd);

        % Hanning windowing
        tempData = tempDataRaw.*hanning(numel(tempDataRaw))';

        % determine how many windows for zero padding
        exp2n = log2(samples); % get exponent for 2^n series
        exp2n = ceil(exp2n + 2);  % get next higher exponent
        
        iterationsFFT = 2^exp2n;
        
        % f axis
        df    = 1/(dt*iterationsFFT);
        fAxis = linspace(0,iterationsFFT/2,fix(iterationsFFT/2+1))*df;    %making the frequency axis
        
        tempDataFFT  = [tempData';zeros(iterationsFFT-samples,1)];
        fftData      = fft(tempDataFFT, [], 1)*dt;
        fftData      = abs(fftData(:,:));

        peakNames  = [peakNames; timeLines(iLine).DisplayName ];

        maxFFT = max(fftData(1:numel(fAxis)));
        iMaxFFT = find(fftData(1:numel(fAxis)) >= maxFFT, 1, 'first');

        peakValuesFFT = [peakValuesFFT; fAxis(iMaxFFT) , maxFFT  ];

        maxTime = max(tempDataRaw);
        iMaxTime = find(tempDataRaw >= maxTime, 1, 'first');

        maxTimeNeg = max(-tempDataRaw);
        iMaxTimeNeg = find(-tempDataRaw >= maxTimeNeg, 1, 'first');

        peakValuesTime = [peakValuesTime; tempAxis(iMaxTime),maxTime,tempAxis(iMaxTimeNeg),maxTimeNeg];

        fprintf('Done \n')
        color        = timeLines(iLine).UserData.Color;
        legendString = timeLines(iLine).DisplayName;

        if isNormalize
            tempDataRaw = tempDataRaw./max(tempDataRaw);
            fftData = fftData./max(fftData);
        end
        
        timeObj = plot(tempAxis,tempDataRaw , 'DisplayName',legendString,...
                           'LineWidth', lw, 'Parent',timeTile,'Color',[color,alpha]);
        timeObj.UserData.ShowLine = 1;
        timeObj.UserData.Color    = color;
        timeObj.UserData.Attributes.dt       = timeLines(iLine).UserData.Attributes.dt;

        plot(fAxis/1e6, fftData(1:numel(fAxis)),...
            'DisplayName',legendString,'LineWidth', lw, 'Color',[color,alpha], 'Parent', freqTile)
    end
end

tablePeaks = table(peakNames,peakValuesTime,peakValuesFFT,'VariableNames',{'Name', 'PeaksTime','PeaksFFT'});
assignin('base','peakValues',tablePeaks)

fWindow.Visible = 'on';

uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',@SaveFigure);

uimenu(m, 'Text', 'Hide Lines', 'MenuSelectedFcn', {@deleteLine,timeTile, freqTile,'hide'} )
uimenu(m, 'Text', 'Show Lines', 'MenuSelectedFcn', {@deleteLine,timeTile, freqTile,'show'} )
uimenu(m, 'Text', 'Hide Legend', 'MenuSelectedFcn', {@handle_legend,'hide', fs} )
uimenu(m, 'Text', 'Show Legend', 'MenuSelectedFcn', {@handle_legend,'show', fs} )
uimenu(m, 'Text','Pick Times', 'MenuSelectedFcn',@PickTimes); 
uimenu(m, 'Text', 'Normalize Traces', 'MenuSelectedFcn', {@normalize_traces,timeTile, freqTile,component,fs, lw,fcut})
uimenu(m, 'Text', 'Overlap at first break', 'MenuSelectedFcn', {@overlapLines, timeTile, component, lw, fs, fcut} )

changeLabels = uimenu(m, 'Label', 'Change Labels');
uimenu(changeLabels, 'Text', 'Change Legend Names', 'MenuSelectedFcn', @changeLegendNames)
uimenu(changeLabels, 'Text', 'Add Title', 'MenuSelectedFcn', {@addTitle,t, fs})


t.Title.String = sprintf('Time Window from %g ns to %g ns', start_value, end_value);

end