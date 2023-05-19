% plot_Bscan.m
clc, clear, close all
%% MAIN
p          = mfilename('fullpath');
script_dir = fileparts(p);
addpath(genpath(script_dir));


%% Plotting Parameters
isNormalize = 1;     % normalize traces

component   = 'Ey';     % which component?
isSave      = false;

% call main function
data = plt_BScan(isNormalize, component, []);

%% Functions
function data = plt_BScan(isNormalize, component, filename)

    isGain1      = 0;    
    isGain2      = 0;
    timewindow   = 0.5e-7;
    nSegments    =  6;

    % check for folder existance
    pathRoot     = 'C:\OneDrive - Delft University of Technology';                              % pathRoot
    
    if exist(pathRoot, 'dir') ~= 7
        pathRoot     = pwd;
        outputFolder = '';
        figureFolder = '';
    else
        outputFolder = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\ProcessedFiles';  % where results are stored
        figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';                                 % to save figueres
    end

    if nargin < 3 || isempty(filename)
        [filenameSelect, pathname, check] = uigetfile([fullfile(pathRoot,outputFolder) '\*.out'],...
                                            'Select gprMax output file to plot B-scan', 'MultiSelect', 'off');
        
        filename                          = fullfile(pathname, filenameSelect);
        assert(check ~= 0, 'No File Selected')
    end
    %% Load b -field

    data = load_output([], filenameSelect,pathname, true);

    %% read fields
    fieldNames = fieldnames(data);
    fn         = fieldNames{1};
    nrx        = data.(fn).Attributes.nrx;
    nsrc       = data.(fn).Attributes.nsrc;
    time       = data.(fn).Axis.time;
    fieldRaw   = data.(fn).Data.fields.(component);
    traces     = 1:size(fieldRaw, 2);
 

    if isNormalize
        field = fieldRaw ./ max(fieldRaw);
        clims = [-1, 1];
        titleString = append('Normalized - ', filenameSelect, ' - ',component);
    else
        field = fieldRaw; 
        clims = [-max(max(abs(field))) max(max(abs(field)))];
        titleString = append(filenameSelect, ' - ', component);
    end

    % Gain1 
    if isGain1
        field = gain(field,timewindow, dt);
    end
    
    % Gain2
    if isGain2
        field = gain2(field,nSegments);
    end
    
    
    %% Plot
    fh1=figure('Name', filename);
    
    im = imagesc(traces, time, field, clims);
    colormap(jet)
    xlabel('Traces');
    xlim([traces(1) traces(end)]);
    ylim([time(1), time(end)])
    ylabel('Time [s]');
    c = colorbar;
    c.Label.String = 'Field strength [V/m]';
    ax = gca;
    ax.FontSize = 16;
    title(titleString, 'Interpreter', 'none')
    
    % for rx_array containing only once source -> plot subtitle

    if nsrc == 1
        scrcPos = data.(fn).Attributes.SrcData.Position;
        scrcPosType = data.(fn).Attributes.SrcData.Type;
        dRx = data.(fn).Attributes.RxData.Position(2,:) - data.(fn).Attributes.RxData.Position(1,:);
        subtit1 = sprintf('(x_{TX},y_{TX},z_{TX}) = (%gm, %gm, %gm) - %s', scrcPos(1),scrcPos(2),scrcPos(3),scrcPosType );
        subtit2 = sprintf('(\\Delta x_{RX},\\Delta y_{RX},\\Delta z_{RX}) = (%gm, %gm, %gm)',dRx(1),dRx(2),dRx(3));
        subtitle({subtit1,subtit2})
    end

    % Options to create a nice looking figure for display and printing
    set(fh1,'Color','white');
    hold on
%     X = 60;   % Paper size
%     Y = 30;   % Paper size
%     xMargin = 0; % Left/right margins from page borders
%     yMargin = 0;  % Bottom/top margins from page borders
%     xSize = X - 2*xMargin;    % Figure size on paper (width & height)
%     ySize = Y - 2*yMargin;    % Figure size on paper (width & height)
%     
%     % Figure size displayed on screen
%     set(fh1, 'Units','centimeters', 'Position', [0 0 xSize ySize])
%     movegui(fh1, 'center')
%     
%     % Figure size printed on paper
%     set(fh1,'PaperUnits', 'centimeters')
%     set(fh1,'PaperSize', [X Y])
%     set(fh1,'PaperPosition', [xMargin yMargin xSize ySize])
%     set(fh1,'PaperOrientation', 'portrait')
    



    %% UI - Menu 
    m = uimenu('Text','USER-Options');
    uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
    uimenu(m,'Text','DifferencePlot',...
         'MenuSelectedFcn',{@dif_plot_BScan, isNormalize, data, component});
    uimenu(m,'Text','Estimate Velocity',...
         'MenuSelectedFcn',{@estimateVelocity, data, fh1});
    uimenu(m,'Text','Delete Velocity Estimations',...
         'MenuSelectedFcn',@deleteLines);
    uimenu(m,'Text','Find Peak Amplitudes',...
         'MenuSelectedFcn',{@findMaxAmplInTimeWindow, data, component});
    uimenu(m,'Text','Display Individual Traces',...
         'MenuSelectedFcn',{@displayTraces, data, component});

    function displayTraces(src, event, data, component)
        plot_TimeFreqDomain(data, component)
    end

end

%% LOCAL FUNCTIONS

%% Difference Plot
function dif_plot_BScan(src, event, isNormalize, data, component)

    [filenameSelect, pathname, check] = uigetfile([pwd '\*.out'],...
                                            'Select gprMax output file to plot B-scan', 'MultiSelect', 'off');

    data = load_output(data, filenameSelect,pathname, false);
    fieldNames = fieldnames(data);
    fnOld = fieldNames{1};
    fnNew = fieldNames{2};

    fieldOld = data.(fnOld).Data.fields.(component);
    fieldNew = data.(fnNew).Data.fields.(component);

    titleString = sprintf('Difference Plot\n %s \n - \n %s', data.(fnNew).FileName, data.(fnOld).FileName);
    if size(fieldOld) == size(fieldNew)
        diffData = fieldNew - fieldOld;
    end

    % Normalize
%     isNormalize = false;
    if isNormalize
        diffData = diffData ./ max(diffData);
        clims = [-1, 1];
        titleString = append(titleString, '- Normalized');
    else
        clims = [-max(max(abs(diffData))) max(max(abs(diffData)))];
    end

    traces = 0:size(diffData, 2);
    time   = data.(fnNew).Axis.time;

    f = figure('Name', 'DiffPlot');
     set(f,'Color','white');
    
    im = imagesc(traces, time, diffData, clims);
    set(im, 'AlphaData', ~isnan(diffData))
    set(gca,'color','magenta');
    colormap(jet)
    xlabel('Traces');
    xlim([traces(1) traces(end)]);
    ylabel('Time [s]');
    c = colorbar;
    c.Label.String = 'Field strength [V/m]';
    ax = gca;
    ax.FontSize = 16;
    title(titleString, 'Interpreter', 'none')



end

%% estimate veloc
function estimateVelocity(src, event, data, fh1)

fn  = fieldnames(data);
atr = data.(fn{1}).Attributes.RxData;
drx = diff(atr.Position);
drx = round(drx,5);
drx = unique(drx, 'rows');

if size(drx,1) > 1
    warning('Multiple different receiver spacings detected') 
end
drx = drx(drx(1,:) > 0) ;

[x,t] = ginput(2);

% x     = round(x);
m     = ((t(2) - t(1))/(x(2)-x(1)));
t0    = t(2) - m*x(2);
fprintf('Formula: y = %.4e * x + %.4e\n', m, t0)

f = gcf;
f.UserData.m  = m;
f.UserData.t0 = t0;


v     = drx/m;

currentLine = plot(x,t,'DisplayName', sprintf('%e m/s',v), 'Parent', gca, 'Tag', 'velocityEst',...
                   'LineWidth',3);
currentLine.UserData.ShowLine = true;
txt = text((x(2)+x(1))/2, (t(2) + t(1))/2,sprintf('%e m/s',v),'Tag', 'velocityEst');
txt.UserData.ShowLine = true;

end

%% find maximum aplitude
function findMaxAmplInTimeWindow(scr, event, data, component)

%% Load Data
fn  = fieldnames(data);
dt  = data.(fn{1}).Attributes.dt;
nrx = data.(fn{1}).Attributes.nrx;
fileName = data.(fn{1}).FileName;

parent_f = gcf;

if ~isempty(parent_f.UserData)
    mDefault =  num2str(parent_f.UserData.m);
    t0Default = num2str(parent_f.UserData.t0);
else
 mDefault = '1.56e-9';
 t0Default = '9e-9';
end

%% Input Dialog
% Prompt the user to enter start and end values
prompt = {sprintf('Enter line equation to search to closest local maximum for in Bscan : y = m*x + t \n (given from "Estimate Velocity"\n m:'),...
            't:',...
            'Buffer on each side [ns]: ', 'Mode [first, max]: '};
titleString = 'Amplitude';
dims = [1 35];
default = {mDefault,t0Default, '10', 'first'};
input = inputdlg(prompt, titleString, dims, default);

% Check if the user clicked "Cancel" or closed the dialog
if isempty(input)
    return;
end

% Convert input to numeric values
m       = str2double(input{1});
t0      = str2double(input{2});
buffer  = str2double(input{3})*1e-9;
mode    = input{4};

fprintf('m = %e\n',m)
fprintf('y0 = %e\n',t0)

parent_f.UserData.m  = m;
parent_f.UserData.t0 = t0;

%% Pre-Process Data

nBuffer = round(buffer / dt);

fieldData      = data.(fn{1}).Data.fields.(component);
selectedWindow = zeros(size(fieldData));
valuesInWindow = zeros(size(fieldData));
peakTime    = zeros(nrx,1);
peakTimeIdx = zeros(nrx,1);
tAxis     = data.(fn{1}).Axis.time;


%% Find Peaks
peaks = zeros(nrx,1);

for iRx = 1:nrx
    tStart  = m*double(iRx) + t0;
    iTStart = find(tAxis>=tStart,1,'first');

    it0 = iTStart - nBuffer;
    if it0 < 1
        it0 = 1;
    elseif isempty(it0)
        it0 = numel(tAxis) - buffer;
    end

    itEnd           = iTStart + nBuffer;
    if isempty(itEnd) || itEnd > numel(tAxis)
        itEnd =  numel(tAxis); 
    end

    traceData       = fieldData(it0:itEnd,iRx);
    timeData        = tAxis(it0:itEnd);

        

    selectedWindow(it0:itEnd, iRx) = 1;
    valuesInWindow(it0:itEnd, iRx) = traceData;

    traceDataNorm   = traceData ./ max(traceData);

    try
        [pks,locs] = findpeaks(traceDataNorm, 'MinPeakProminence',0.1);
    catch
        fprintf('Error in "findpeaks" for Trace %d\n', iRx)
        pks = [];
    end

    if isempty(pks)
        fprintf('No peaks found at trace %d\n', iRx)
        peaks(iRx)    = -1;
        peakTime(iRx) = 0;
        continue
    end

    switch mode
        case 'first'
            iPeak = locs(1);
        case 'max'
            [~, iMaxPeak] = max(pks);
            iPeak = locs(iMaxPeak);
        otherwise
            fprintf('wrong mode %s\n',mode)
            return
    end

    peakTime(iRx) = timeData(iPeak);
    peaks(iRx)    = traceData(iPeak);
    peakTimeIdx(iRx) = iPeak;

end

assignin('base','valuesInWindow',valuesInWindow)
assignin('base','timeData',timeData)

atr = data.(fn{1}).Attributes.RxData;
drx = diff(atr.Position);
drx = round(drx,5);
drx = unique(drx, 'rows');

if size(drx,1) > 1
    warning('Multiple different receiver spacings detected') 
end



scrPos      = data.(fn{1}).Attributes.SrcData.Position(1,1); % x-coordinates
dx0         = data.(fn{1}).Attributes.RxData.Position(1,1) - scrPos;
offset      = data.(fn{1}).Attributes.RxData.Position(:,1) - scrPos; % x-coordinates

assignin('base','offset',offset)

drx = drx(drx(1,:) > 0) ;
v = drx/m;
perm      = (299792458/v).^2;

fprintf('v = %e m/s\n',v)
fprintf('rel Permittitty = %f \n',perm)
assignin('base','v',v)
assignin('base','perm',perm)

mu0       = 4*pi*1e-7;
eps       = perm*8.88542e-12;  

%% Plot
f = figure;



% h1.Visible = 'off';
imagesc(1:nrx, tAxis, fieldData./max(fieldData), [-1, 1])
h1 = gca;

title(fileName, 'Interpreter','none')
subtitle(sprintf('v = %e m/s', v))
xlabel('Traces');
xlim([1 nrx]);
ylim([tAxis(1), tAxis(end)])
ylabel('Time [s]');

h2 = axes(f);
im2 = imagesc(h2,1:nrx, tAxis, selectedWindow, [0, 1]);
im2.AlphaData = 0.2;

h2.XTickLabel = {};
h2.YTickLabel = {};
h2.XTick = [];
h2.YTick = [];
h2.Visible = 'off';

linkaxes([h1 h2], 'xy');



colormap(h1,'jet')
colormap(h2,'gray')
set(h2,'color','none','visible','off');

hold on

points = cell(nrx,1);
for iPoint = 1:nrx
    points{iPoint} = drawpoint('Position',[double(iPoint),double(peakTime(iPoint))],...
                            'Deletable', true, 'Label', sprintf('%d',iPoint));
    points{iPoint}.UserData.Trace   = fieldData(:,iPoint);
    addlistener(points{iPoint},'ROIClicked',@movePoint);
    bringToFront(points{iPoint})
end


% pointsVector = arrayfun(@(x,y) [x y], double((1:nrx)'), double(peakTime), 'UniformOutput', false);
% lineRoi = drawpolyline('Position',cell2mat(pointsVector));
% bringToFront(lineRoi)
% % addlistener(lineRoi, 'MovingROI', @allevents);
% addlistener(lineRoi,'ROIClicked',@movePoint);

%% Menu
men = uimenu('Text','USER-Options');
uimenu(men,'Text','Get picked Amplitudes',...
     'MenuSelectedFcn',{@getAmplitudes,points});
uimenu(men,'Text','Select time window to analyze',...
     'MenuSelectedFcn',{@selectTimeWindow,f});
uimenu(men,'Text','Get conductivity',...
     'MenuSelectedFcn',{@getConductivity,f,points});
uimenu(men,'Text','Display Traces in Window',...
     'MenuSelectedFcn',{@process_Traces,data, component, valuesInWindow});
%% Callbacks
    function movePoint(s, evtData)
       [x,y, button] = ginput(1);
       if button ~= 1
           disp('Action Canceled')
           return
       else
           s.Position = [round(x) y];
       end
    end

    function getAmplitudes(src, event, points)

        amplitudes = zeros(nrx,1);
        for i = 1:nrx
            curPoint = points{i};
            pos = curPoint.Position;
            idxTime = find(tAxis >= pos(2),1,'first');
            amplitudes(i) = curPoint.UserData.Trace(idxTime);
        end

        figure
        plot(1:nrx, amplitudes)
        xlabel('Traces');
        ylabel('Max Amplitude');
        title(fileName, 'Interpreter','none')
        subtitle(sprintf('v = %e m/s', v))
        
        assignin('base','peaksAll',amplitudes)
    end


    function selectTimeWindow(src, event,f,points)

        existingobj = findobj(gca,'Tag','TimeWindow2Analyze');
        if ~isempty(existingobj)
            delete(existingobj)
            f.UserData.Window2Analyze = [];
        end

        fprintf('Select start and endpoint of time window to analyze conducitvity\n')
        traces = ginput(2);
        trace1 = round(traces(1));
        trace2 = round(traces(2));

        xl = xline([trace1,trace2],'-',{'Start','End'},'Tag','TimeWindow2Analyze','Parent',gca);
        fprintf('Selected Traces\n')
        fprintf('\tStart Trace: %d\n',trace1)
        fprintf('\tEnd Trace: %d\n',trace2)
        f.UserData.Window2Analyze = [trace1, trace2];

    end

    function getConductivity(src,event,f,points)
       
        if ~isfield(f.UserData,'Window2Analyze')
            fprintf('No Start and End of traces selected, Please do this in "Select Time Window to Analyze"\n')
            return
        end

        traces = f.UserData.Window2Analyze;
        selTraces = traces(1):traces(2);
        amplitudes = zeros(numel(selTraces),1);
        for i = 1:numel(selTraces)
            iTrace = selTraces(i);
            curPoint = points{iTrace};
            pos = curPoint.Position;
            idxTime = find(tAxis >= pos(2),1,'first');
            amplitudes(i) = curPoint.UserData.Trace(idxTime);
        end

        % get conductivity
%         cond_pre  = 0;
        x0        = 1e-2;
        xm        = 1e-3;

        figure
        options = optimset('TolX',1e-5);%,'PlotFcns',@optimplotfval);

%         [sigma1_estimation,fval,exitflag,output]=fminbnd(@(x)procconstraint_sigma1_estimation(x, ...
%                                                         amplitudes,max(amplitudes),offset(selTraces),mu0,eps),...
%                                                         xm,x0,options);

        [x,fval,exitflag,output] =fminsearch(@(x)procconstraint_sigma1_estimation(x, ...
                                                amplitudes,max(amplitudes),offset(selTraces),mu0,eps, gca),...
                                                [mean([x0 xm]), amplitudes(1)],options);

        sigma1_estimation = x(1);
        A0_estimation = x(2);
        assignin('base', 'FminOut', output)
        title(sprintf('Fminsearch result - %s', fileName),'Interpreter','none')
        subtitle(sprintf('Electrical Conductivity Esimation: %f\nIterations: %d\nTrace %d - Trace %d\nMSE = %e',...
                        sigma1_estimation, output.iterations, selTraces(1),selTraces(end), fval))
        legend

        fprintf('Estimated sigma = %f S/m\n',sigma1_estimation)
        fprintf('Estimated A0 = %f \n',A0_estimation)
        fprintf('function value %f\n',fval)
        fprintf('exit flag %f\n',exitflag)
        xlabel('Offset (m)')
        ylabel('Picked Amplitude')
        disp(output)
    end
    

    function process_Traces(src,event, data, component, valuesInWindow)
         fiedNames = fieldnames(data);
         data.(fiedNames{1}).Data.fields.(component) = valuesInWindow;
         data.(fiedNames{1}).Data.FFT.(component) = zeros(size(data.(fiedNames{1}).Data.FFT.(component)));
         plot_TimeFreqDomain(data, component)
    end
end

%% delete Veloc lines
function deleteLines(src,event)
h     = findobj(gca,'Tag','velocityEst');
lines = findobj(h, 'Type','Line');
displayNames = strings(numel(lines),1);
for i = 1:numel(lines)
    displayNames(i) = lines(i).DisplayName;
end

[sel_indx,tf] = listdlg('PromptString','Delete velocity estimations',...
    'SelectionMode','multiple','ListString',displayNames, 'ListSize', [500, 200]);

if tf
    for i = sel_indx
        name = displayNames(i);
        for k = 1:numel(h)
            if strcmpi(get(h(k),'Type'),'Line')
                if strcmpi(name, h(k).DisplayName)
                    delete(h(k))
                end
            elseif strcmpi(get(h(k),'Type'),'Text')
                if strcmpi(name, h(k).String) 
                    delete(h(k))
                end
            end
        end
    end
end

end


%% gain
% https://link.springer.com/referenceworkentry/10.1007/978-3-030-26050-7_47-1
function result = gain(traces,windowlength, dt)
n = ceil(windowlength / dt);
if mod(n,2) == 0
    n = n + 1;
end
m = (n-1)/2;

gain = ones(size(traces));

% 1. De-mean value
for iTrace = 1:size(traces,2)
    currentTrace = traces(:,iTrace);
    for iValue = m+1:size(traces,1)-m
        index_low  = iValue-m;
        index_up   = iValue+m;
        tracesInTw    = currentTrace(index_low:index_up);
        traces_mean   = mean(tracesInTw);
        crit1 = tracesInTw > traces_mean;
        crit2 = tracesInTw < traces_mean;
        if traces_mean > 0
            traces_demean = (tracesInTw -traces_mean).*crit1 + tracesInTw.*(~crit1);
        else
            traces_demean = (tracesInTw +traces_mean).*crit2 + tracesInTw.*(~crit2);
        end

        if mean(traces_demean) > 1e-1
            fprintf('Mean of "demeaned" center point %d of trace %d is %f\n',iValue, iTrace, mean(traces_demean))
        end

        energy = 1/numel(tracesInTw)*sum(traces_demean.^2);
        gain(iValue, iTrace) = 1/energy;
         
%         agc(iValue,iTrace) = currentTrace(iValue) / gain_energy;
    end
end

result = traces .* gain;

end


%% fgain2
function result = gain2(traces,nSegments)

result = zeros(size(traces));
nSamples     = size(traces,1);
nSubSamples = floor(nSamples/nSegments);
index       = 1:nSubSamples:nSamples;
index(end)  = nSamples;

rms_a_stuetz = zeros(nSegments,size(traces,2));
rms_a        = zeros(size(traces));
midpoints    = zeros(nSegments,1);
for iTrace = 1:size(traces,2)
    currentTrace = traces(:,iTrace);
    for iSample = 1:numel(index)-1
        currentSubTrace = currentTrace(index(iSample):index(iSample+1));
        midpoints(iSample) = floor(mean(index(iSample)+index(iSample+1)));
        local_mean      = mean(currentSubTrace);
        rms_a_stuetz(iSample, iTrace)           = sqrt(1/numel(currentSubTrace)*sum((currentSubTrace-local_mean).^2));
    end
    rms_a(:,iTrace) = spline(midpoints, rms_a_stuetz(:,iTrace),1:nSamples);
    const = mean(rms_a(:,iTrace));
    result(:,iTrace) = const./rms_a(:,iTrace).*traces(:,iTrace);
end

end

