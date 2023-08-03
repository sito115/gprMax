function data = plt_BScan(isNormalize, component, filename,isGain,isSave)
% main function to display B-scan with additional functions in the menu
% "USER-Options". It assumes that the receivers are placed along the
% x-direction
% INPUT:
% isNormalize   : logical 
% component     : string - [Ex,Ey,Ez]
% filename      : string - absolute path [optional]
% isGain        : logical - apply gain filter [optional]
% isSave        : logical - save automatically, false by default [optional]
%
% OUTPUT:
% data  : structure - containing all relevant information of the .out File


    fs = 30; % FontSize

    %% define pathRoot Folder and check for folder existance
    pathRoot     = 'C:\OneDrive - Delft University of Technology';                       
    
    if exist(pathRoot, 'dir') ~= 7
        pathRoot     = pwd;
        outputFolder = '';
        figureFolder = '';
    else
        outputFolder = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\ProcessedFiles';  % where results are stored
        figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';                                 % to save figueres
    end

    %% if fileName is not given, make user choose it in GUI
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

    %% if isGain is not given, make user choose it in GUI
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
    %% if isSave is not given, set it to false
if nargin < 5
    isSave = false;
end

    %% read fields f
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
    
        if isGain
            field = gpr_gainInvEnv2D(fieldRaw);
        end
               
        %% Plot
        fh1=figure('Name', filenameSelect{iField},'units','normalized','outerposition',[0 0 1 1]);
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
        set(gca,'TickDir','out');

        hold on

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
        uimenu(m,'Text','Add x2 t2 Analysis',...
             'MenuSelectedFcn',{@addx2y2Analysis,offset});

        if isSave || isempty(isSave)
            if ~isGain
                SaveFigure([],[],fullfile(pathRoot, figureFolder),filenameSelect{iField},1,1);
            else
                SaveFigure([],[],fullfile(pathRoot, figureFolder),[filenameSelect{iField} '-Hilbert'],1,1);
            end
        end

    end

end
