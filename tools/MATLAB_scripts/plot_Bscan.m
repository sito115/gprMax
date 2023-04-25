% plot_Bscan.m

clear, clc%, close all

%% Plotting Parameters
isNormalize = true;     % normalize traces
isGain1      = 0;    
isGain2      = 0;
component   = 'Ey';     % which component?
isSave      = false;
timewindow  = 0.5e-7;
nSegments   =  6;
%% Define Files

data = plt_BScan(isNormalize, component, []);

% pathRoot     = '  ';      % pathRoot
% outputFolder = '  ';      % where results are stored
% figureFolder = '  ';      % to save figueres

function data = plt_BScan(isNormalize, component, filename)

pathRoot     = 'C:\OneDrive - Delft University of Technology';                              % pathRoot
outputFolder = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\ProcessedFiles';  % where results are stored
figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';                                 % to save figueres


    if nargin < 3 || isempty(filename)
        [filenameSelect, pathname, check] = uigetfile([fullfile(pathRoot,outputFolder) '\*.out'],...
                                            'Select gprMax output file to plot B-scan', 'MultiSelect', 'off');
        
        filename                          = fullfile(pathname, filenameSelect);
        assert(check ~= 0, 'No File Selected')
    end
    %% Load b -field

    data = load_output([], filenameSelect,pathname, false);

    %% read fields
    fieldNames = fieldnames(data);
    fn         = fieldNames{1};
    nrx        = data.(fn).Attributes.nrx;
    nsrc       = data.(fn).Attributes.nsrc;
    time       = data.(fn).Axis.time;
    fieldRaw   = data.(fn).Data.fields.(component);
    traces     = 0:size(fieldRaw, 2);
 

    if isNormalize
        field = fieldRaw ./ max(fieldRaw);
        clims = [-1, 1];
        titleString = append('Normalized - ', filenameSelect, ' - ',component);
    else
        field = fieldRaw; 
        clims = [-max(max(abs(field))) max(max(abs(field)))];
        titleString = append(filenameSelect, ' - ', component);
    end

    %% Gain1 
    % if isGain1
    %     field = gain(field,timewindow, dt);
    % end
    % 
    %% Gain2
    % if isGain2
    %     field = gain2(field,nSegments);
    % end
    
    
    %% Plot
    fh1=figure('Name', filename);
    
    im = imagesc(traces, time, field, clims);
    colormap(jet)
    xlabel('Traces');
    xlim([traces(1) traces(end)]);
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
        dRx = data.(fn).Attributes.RxData.Position(2) - data.(fn).Attributes.RxData.Position(1);
        subtit1 = sprintf('(x_{TX},y_{TX},z_{TX}) = (%gm, %gm, %gm) - %s', scrcPos(1),scrcPos(2),scrcPos(3),scrcPosType );
        subtit2 = sprintf('(\\Delta x_{RX},\\Delta y_{RX},\\Delta z_{RX}) = (%gm, %gm, %gm)',dRx(1),dRx(2),dRx(3));
        subtitle({subtit1,subtit2})
    end

    % Options to create a nice looking figure for display and printing
    set(fh1,'Color','white');
    X = 60;   % Paper size
    Y = 30;   % Paper size
    xMargin = 0; % Left/right margins from page borders
    yMargin = 0;  % Bottom/top margins from page borders
    xSize = X - 2*xMargin;    % Figure size on paper (width & height)
    ySize = Y - 2*yMargin;    % Figure size on paper (width & height)
    
    % Figure size displayed on screen
    set(fh1, 'Units','centimeters', 'Position', [0 0 xSize ySize])
    movegui(fh1, 'center')
    
    % Figure size printed on paper
    set(fh1,'PaperUnits', 'centimeters')
    set(fh1,'PaperSize', [X Y])
    set(fh1,'PaperPosition', [xMargin yMargin xSize ySize])
    set(fh1,'PaperOrientation', 'portrait')
    



    %% UI - Menu
    m = uimenu('Text','USER-Options');
    uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
    uimenu(m,'Text','DifferencePlot',...
         'MenuSelectedFcn',{@dif_plot_BScan, isNormalize, data, component});
end


%%%%%%%%%%%%%%%%%%% SUB-FUNCTIONS
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
    if isNormalize
        diffData = diffData ./ max(diffData);
        clims = [-1, 1];
        titleString = append(titleString, '- Normalized');
    else
        clims = [-max(max(abs(field))) max(max(abs(field)))];
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

%% amplitud versus offset


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