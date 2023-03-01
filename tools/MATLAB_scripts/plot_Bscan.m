% plot_Bscan.m

clear, clc, close all

%% Plotting Parameters
isNormalize = true;     % normalize traces
component   = 'Ey';     % which component?

%% Define Files
pathRoot     = 'C:\OneDrive - Delft University of Technology';                              % pathRoot
outputFolder = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\thomas\python';  % where results are stored
figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';                                 % to save figueres

% pathRoot     = '  ';      % pathRoot
% outputFolder = '  ';      % where results are stored
% figureFolder = '  ';      % to save figueres

[filenameSelect, pathname, check] = uigetfile([fullfile(pathRoot,outputFolder) '\*.out'],...
                                    'Select gprMax output file to plot B-scan', 'MultiSelect', 'on');

filename                          = fullfile(pathname, filenameSelect);

%% Check Parameters
assert(ismember(component, {'Ex', 'Ey', 'Ez'}) || isempty(component), 'Unknown field component');
assert(check ~= 0, 'No File Selected')

%% Open file and read fields
iterations = double(h5readatt(filename, '/', 'Iterations'));
dt         = h5readatt(filename, '/', 'dt');
nrx        = h5readatt(filename, '/', 'nrx');
time       = linspace(0, (iterations - 1) * dt, iterations)';

if isempty(component)
    prompt     = 'Which field do you want to view? Ex, Ey, or Ez: ';
    component  = input(prompt,'s');
end

%% Check if rx-array or merge and extract output
if nrx == 1
    isMerge    = true;
    fieldpath  = strcat('/rxs/rx1/', component);
    fieldRaw   = h5read(filename, fieldpath)';
elseif nrx > 1
    isMerge  = false;
    fieldRaw = zeros(iterations, nrx);
    position = zeros(nrx, 3);
    for iArray = 1:nrx
        fieldpath          = strcat(['/rxs/rx' num2str(iArray) '/'], component);
        fieldRaw(:,iArray) = h5read(filename, fieldpath)';
        position(iArray,:) = h5readatt(filename, ['/rxs/rx' num2str(iArray) '/'], 'Position')';
    end
else
    error('No Field loaded')
end

traces     = 0:size(fieldRaw, 2);

%% Normalize
if isNormalize
    field = fieldRaw ./ max(fieldRaw);
    clims = [-1, 1];
    titleString = append('Normalised - ', filenameSelect, ' - ',component);
else
    field = fieldRaw; 
    clims = [-max(max(abs(field))) max(max(abs(field)))];
    titleString = append(filenameSelect, ' - ', component);
end


%% Plot
fh1=figure('Name', filename);

im = imagesc(traces, time, field, clims);
xlabel('Traces');
xlim([traces(1) traces(end)]);
ylabel('Time [s]');
c = colorbar;
c.Label.String = 'Field strength [V/m]';
ax = gca;
ax.FontSize = 16;
title(titleString, 'Interpreter', 'none')

% for rx_array containing only once source -> plot subtitle
if isMerge == false
    nsrc = h5readatt(filename, '/', 'nsrc');
    if nsrc == 1
        scrcPos = h5readatt(filename, '/srcs/src1', 'Position');
        subtit1 = sprintf('(x_{TX},y_{TX},z_{TX}) = (%.2em, %.1em, %.1em)', scrcPos(1),scrcPos(2),scrcPos(3) );
        dRx     =  position(2,:) - position(1,:);
        subtit2 = sprintf('(\\Delta x_{RX},\\Delta y_{RX},\\Delta z_{RX} = (%.1em, %.1em, %.1em)',dRx(1),dRx(2),dRx(3));
        subtitle({subtit1,subtit2})
    
    end
end
    
% Options to create a nice looking figure for display and printing
set(fh1,'Color','white','Menubar','none');
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

%% Save
isSave = input('Save Figure? [1 0]\n');
if isSave 
    saveas(fh1, fullfile(pathRoot, figureFolder, [filenameSelect, '.pdf']))
end