function dif_plot_BScan(src, event, isNormalize, data, component,isGain,pathRoot)

% Callback function to create a difference B-scan. The newly loaded B-scan
% is being substracted by the default old one, from where the callback was
% called. It is important that both B-scans have the same size (same amount
% of receivers and time steps).
% INPUT:
% src, evt      : structures - mandatory inputs source, event for callback handles, see Matlab Docs
% isNormalize   : logical - traceNormalized yes or no
% data          : structure containing information of .out file from where the callback was called
% component     : string - [Ex,Ey,Ez] 
% isGain        : logical - apply gain function [optional]
% pathRoot      : character [optional]

    %% if isGain is not given, make user choose it in GUI
if nargin < 6 || isempty(isGain)
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

if nargin < 7 || isempty(pathRoot)
    pathRoot = pwd;
end


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
        assignin('base','diffData',diffData)
    else
        error('The amount of recievers or time window is not equal')
    end

    time   = data.(fnNew).Axis.time;
    data = rmfield(data,fnNew);
    data.(fnOld).Data.fields.(component) = diffData;    

    assignin('base','DiffStruct',data)

    % Normalize
%     isNormalize = false;
    if isNormalize
        diffData = diffData ./ max(abs(diffData));
        clims = [-1, 1];
        titleString = append(titleString, '- Normalized');
        offset = data.(fnOld).Attributes.Offset_x;
    else
        clims = [-max(max(abs(diffData))) max(max(abs(diffData)))];
    end


    

    % Gain1 
    if isGain
        diffData = gpr_gainInvEnv2D(diffData);
%             field = field./max(field);
    end

    

    f = figure('Name', 'DiffPlot');
     set(f,'Color','white');
     
    
    im = imagesc(offset, time*1e9, diffData, clims);
    set(im, 'AlphaData', ~isnan(diffData))
    set(gca,'color','magenta');
    colormap(jet)
    xlabel('Offset [m]');
    xlim([offset(1) offset(end)]);
    ylabel('Time [ns]');
    c = colorbar;
    c.Label.String = 'Normalized field strength [-]';
    ax = gca;
    ax.FontSize = 30;
    set(gca,'TickDir','out');
    title(titleString, 'Interpreter', 'none')
        hold on

    m = uimenu('Text','USER-Options');
    uimenu(m,'Text','Save Figure','MenuSelectedFcn',{@SaveFigure,[],sprintf('%s-DiffPlot',data.(fnOld).FileName)});
    uimenu(m,'Text','DifferencePlot',...
         'MenuSelectedFcn',{@dif_plot_BScan, isNormalize, diffData, component,pathRoot});
    uimenu(m,'Text','Estimate Velocity',...
         'MenuSelectedFcn',{@estimateVelocity, data, gcf});
    uimenu(m,'Text','Delete Velocity Estimations',...
         'MenuSelectedFcn',@deleteLines);
    uimenu(m,'Text','Find Peak Amplitudes',...
         'MenuSelectedFcn',{@findMaxAmplInTimeWindow, data, component});
    uimenu(m,'Text','Display Individual Traces (raw)',...
         'MenuSelectedFcn',{@displayTraces, data, component,'raw'});
    uimenu(m,'Text','Display Individual Traces (gain)',...
         'MenuSelectedFcn',{@displayTraces, data, component,'displayed'});
    uimenu(m,'Text','Load new B-Scan',...
         'MenuSelectedFcn',['data= plt_BScan(1,', '"Ey"' ',[])' ]);
    uimenu(m,'Text','Add x2 t2 Analysis',...
         'MenuSelectedFcn',{@addx2y2Analysis,offset,ax});

