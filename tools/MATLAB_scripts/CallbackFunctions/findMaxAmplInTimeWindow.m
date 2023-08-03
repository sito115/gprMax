function findMaxAmplInTimeWindow(scr, event, data, component)
% Define a line where to pick the maximum amplitude in a B-scan (detailed description in chapter 5.1.2).
% The user can set two points in the B-scan where a velocity line is drawn
% and specify a time buffer zone. A time window along this zone is
% extracted where the amplitudes are picked either as global maximum or
% first amplitude.
%
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs
% data          : structure - containing information about loaded out-file
% component     : char 'Ex','Ey','Ez'
%



fs = 20;
%% Load Data
fn       = fieldnames(data);
dt       = data.(fn{1}).Attributes.dt;
nrx      = data.(fn{1}).Attributes.nrx;
fileName = data.(fn{1}).FileName;
offset   = data.(fn{1}).Attributes.Offset_x;

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


plotData = fieldData./max(fieldData);

%% Find Peaks
peaks = zeros(nrx,1);

for iRx = 1:nrx
    tStart  = m*offset(iRx) + t0;
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


v = 1/m;
perm      = (299792458/v).^2;

fprintf('v = %e m/s\n',v)
fprintf('rel Permittitty = %f \n',perm)
assignin('base','v',v)
assignin('base','perm',perm)

mu0       = 4*pi*1e-7;
eps       = perm*8.88542e-12;  

%% Plot
f = figure;
set(f,'Color','white');

time = tAxis*1e9;
% h1.Visible = 'off';
imagesc(offset, time, plotData, [-1, 1])
h1 = gca;
h1.FontSize = fs;
title(fileName, 'Interpreter','none')
subtitle(sprintf('v = %e m/s', v))
xlabel('Offset [m]');
ylabel('Time [ns]');
xlim([offset(1) offset(end)]);
ylim([time(1), time(end)])


h2 = axes(f);
im2 = imagesc(h2,offset, time, selectedWindow, [0, 1]);
h2.FontSize = fs;
title(fileName, 'Interpreter','none')
subtitle(sprintf('v = %e m/s', v))
xlabel('Offset [m]');
ylabel('Time [ns]');
xlim([offset(1) offset(end)]);
ylim([time(1), time(end)])

im2.AlphaData = 0.2;

linkaxes([h1 h2], 'xy');



colormap(h1,'jet')
colormap(h2,'gray')
set(h2,'color','none') %,'visible','off');
hold on

points = cell(nrx,1);
for iPoint = 1:nrx
    points{iPoint} = drawpoint('Position',[offset(iPoint),double(peakTime(iPoint))*1e9],...
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
uimenu(men,'Text','Save Figure',...
     'MenuSelectedFcn',@SaveFigure);
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
            idxTime = find(tAxis*1e9 >= pos(2),1,'first');
            amplitudes(i) = curPoint.UserData.Trace(idxTime);
        end

        figure
        plot(offset, amplitudes,'-o','LineWidth',3)
        xlabel('Offset (m)');
        ylabel('Picked Amplitude');
        grid on
        title(fileName, 'Interpreter','none')
        xlim([offset(1) offset(end)])
        subtitle(sprintf('v = %e m/s', v))
        set(gca,'FontSize',30)
        
        assignin('base','peaksAll',amplitudes)

        opt = uimenu('Text','USER-Options');
        uimenu(opt,'Text','Save Figure',...
             'MenuSelectedFcn',@SaveFigure);
    end


    function selectTimeWindow(src, event,f,points)

        existingobj = findobj(gca,'Tag','TimeWindow2Analyze');
        if ~isempty(existingobj)
            delete(existingobj)
            f.UserData.Window2Analyze = [];
        end

        fprintf('Select start and endpoint of time window to analyze conducitvity\n')
        [x_raw,~] = ginput(2);
        [~,idx] = min(abs(x_raw'-offset));
        x = offset(idx);
        
        trace1 = idx(1);
        trace2 = idx(2);

        offset1 = x(1);
        offset2 = x(2);

        xl = xline([offset1,offset2],'-',{'Start','End'},'Tag','TimeWindow2Analyze','Parent',gca);
        fprintf('Selected Traces\n')
        fprintf('\tStart Offset: %.2fm (Trace %d)\n',offset1,trace1)
        fprintf('\tEnd Offset: %.2fm (Trace %d)\n',offset2,trace2)
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
            idxTime = find(tAxis >= pos(2)/1e9,1,'first');
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
