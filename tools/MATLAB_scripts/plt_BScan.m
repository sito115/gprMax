function data = plt_BScan(isNormalize, component, filename,isGain)


    fs = 30;
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
                                            'Select gprMax output file to plot B-scan', 'MultiSelect', 'on');
        
        filename                          = fullfile(pathname, filenameSelect);
        assert(check ~= 0, 'No File Selected')
            % Load b -field
    if ~iscell(filenameSelect)
        filenameSelect = cellstr(filenameSelect);
    end

    data = load_output([], filenameSelect,pathname, true);

else
    [pathname,name,ext] = fileparts(filename);
    filenameSelect = cellstr([name,ext]);
    data = load_output([], filenameSelect,pathname, true);
end

if nargin < 4 || isempty(isGain)
    answer = questdlg('Would you like To apply a gain (Hilbert)?', ...
	    'Gain?', ...
	    'Yes','No','Cancel','Yes');
    % Handle response
    switch answer
        case 'Yes'
            isGain = 1;
        case 'No'
            isGain = 0;
        case 'Cancel'
            return
    end

end


    %% read fields
    fieldNames = fieldnames(data);
    for iField = 1:numel(fieldNames)
        fn         = fieldNames{iField};
        nrx        = data.(fn).Attributes.nrx;
        nsrc       = data.(fn).Attributes.nsrc;
        time       = data.(fn).Axis.time;
        fieldRaw   = data.(fn).Data.fields.(component);
        traces     = 1:size(fieldRaw, 2);
        offset     = data.(fn).Attributes.Offset_x;
        dt         = data.(fn).Attributes.dt;
    
        if isNormalize
            field = fieldRaw ./ max(abs(fieldRaw));
            clims = [-1, 1];
            titleString = append('Normalized - ', filenameSelect{iField}, ' - ',component);
        else
            field = fieldRaw; 
            clims = [-max(max(abs(field))) max(max(abs(field)))];
            titleString = append(filenameSelect{iField}, ' - ', component);
        end
    
        % Gain1 
        if isGain
            field = gpr_gainInvEnv2D(fieldRaw);
%             field = field./max(field);
        end
               
        %% Plot
        fh1=figure('Name', filenameSelect{iField});
        time= time*1e9;
        im = imagesc(offset, time, field, clims);
        colormap(jet)
        xlabel('Offset [m]');
        xlim([offset(1) offset(end)]);
        ylim([time(1), time(end)])
        ylabel('Time [ns]');
        c = colorbar;
        if isNormalize
            c.Label.String = 'Normalized field strength [-]';
        else
            c.Label.String = 'Field strength [V/m]';
        end
        ax = gca;
        ax.FontSize = fs;
       
        
        % for rx_array containing only once source -> plot subtitle

        title(titleString, 'Interpreter', 'none')
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
        names2Delete = fieldNames;
        tf = matches(fieldNames,fn);
        names2Delete(tf) = [];
        if isempty(names2Delete)
            data2CallBack = data;
        else
            data2CallBack  = rmfield(data,names2Delete);
        end
    
    
        %% UI - Menu 
        m = uimenu('Text','USER-Options');
        uimenu(m,'Text','Save Figure',...
             'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder),filenameSelect{iField}});
        uimenu(m,'Text','DifferencePlot',...
             'MenuSelectedFcn',{@dif_plot_BScan, isNormalize, data2CallBack, component});
        uimenu(m,'Text','Estimate Velocity',...
             'MenuSelectedFcn',{@estimateVelocity, data2CallBack, fh1});
        uimenu(m,'Text','Delete Velocity Estimations',...
             'MenuSelectedFcn',@deleteLines);
        uimenu(m,'Text','Find Peak Amplitudes',...
             'MenuSelectedFcn',{@findMaxAmplInTimeWindow, data2CallBack, component});
        uimenu(m,'Text','Display Individual Traces (raw)',...
             'MenuSelectedFcn',{@displayTraces, data2CallBack, component,'raw'});
        uimenu(m,'Text','Display Individual Traces (gain)',...
             'MenuSelectedFcn',{@displayTraces, data2CallBack, component,'displayed'});
        uimenu(m,'Text','Load new B-Scan',...
             'MenuSelectedFcn',['data= plt_BScan(1,', '"Ey"' ',[])' ]);


    end
        function displayTraces(src, event, data, component,mode)
            switch mode 
                case 'raw'
                    plot_TimeFreqDomain(data, component)
                case 'displayed'
                    h = findobj(gca().Children,'Type','Image');
                    fields = fieldnames(data);
                    data.(fields{1}).Data.fields.(component) = h.CData;
                    plot_TimeFreqDomain(data, component)
            end
        end
end



%% estimate veloc
function estimateVelocity(src, event, data, fh1)

fn  = fieldnames(data);
atr = data.(fn{1}).Attributes.RxData;
drx = diff(atr.Position);
drx = round(drx,5);
drx = unique(drx, 'rows');
offset = data.(fn{1}).Attributes.Offset_x;

if size(drx,1) > 1
    warning('Multiple different receiver spacings detected') 
end
drx = drx(drx(1,:) > 0) ;

[x_raw,time] = ginput(2);

[~,idx] = min(abs(x_raw'-offset));
x = offset(idx);

t     = time./1e9;
m     = ((t(2) - t(1))/(x(2)-x(1)));
t0    = t(2) - m*x(2);
fprintf('Formula: y = %.4e * x + %.4e\n', m, t0)

f = gcf;
f.UserData.m  = m;
f.UserData.t0 = t0;

v     = 1/m;
eps   = (3e8/v)^2;
currentLine = plot(x,time,'DisplayName', sprintf('%.3f m/ns',v/1e9), 'Parent', gca, 'Tag', 'velocityEst',...
                   'LineWidth',3);
currentLine.UserData.ShowLine = true;
txt = text((x(2)+x(1))/2, (time(2) + time(1))/2,sprintf('%.3f m/ns (\\epsilon_r = %.2f)',v/1e9,eps),...
    'Tag', 'velocityEst','Color','black');
txt.UserData.ShowLine = true;
txt.FontWeight = 'bold';
txt.FontSize = 13;

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
    'SelectionMode','single','ListString',displayNames, 'ListSize', [500, 200]);

if tf
    for i = sel_indx
        name = displayNames(i);
        for k = 1:numel(h)
            if strcmpi(get(h(k),'Type'),'Line')
                if contains(h(k).DisplayName,name)
                    delete(h(k))
                end
            elseif strcmpi(get(h(k),'Type'),'Text')
                if contains(h(k).String,name) 
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

