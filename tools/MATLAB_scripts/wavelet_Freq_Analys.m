%% Select Path
clear
%% File give or GUI?
isFile       = 0;
%%

pathRoot     = 'C:\OneDrive - Delft University of Technology';
trdSemester  = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\thomas\python';
figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';

if isFile
    pathname = fullfile(pathRoot,trdSemester);
    filenameSelect = 'PlaceAntennasDist5.0m_tSim2.24e-07eps20.00iA1.out';
    check = true;
else
    [filenameSelect, pathname, check] = uigetfile([fullfile(pathRoot,trdSemester) '\*.out'],...
                                        'Select gprMax output file to plot B-scan', 'MultiSelect', 'on');
    
end
fullfilename                          = fullfile(pathname, filenameSelect);

lw           = 1.5;
fcut         = 9.5e8;
isSave       = false;
isTimeWindow = false;
isPickt0     = false;

normalization = 'lin';  % 'db' or 'lin'


t0   = [];
tEnd = [];

allComponents = {'Ex', 'Ey', 'Ez'};
%% Check
assert(check ~= 0, 'No File Selected')
fprintf('Loaded... %s\n', filenameSelect)
%% Load Data
header.title = h5readatt(fullfilename, '/', 'Title');
header.iterations = double(h5readatt(fullfilename,'/', 'Iterations'));
tmp = h5readatt(fullfilename, '/', 'dx_dy_dz');
header.dx = tmp(1);
header.dy = tmp(2);
header.dz = tmp(3);
header.dt = h5readatt(fullfilename, '/', 'dt');
header.nsrc = h5readatt(fullfilename, '/', 'nsrc');
header.nrx = h5readatt(fullfilename, '/', 'nrx');
header.nx_ny_nz = h5readatt(fullfilename, '/', 'nx_ny_nz');
header.fullfileName = fullfilename;

srcTemp      = h5readatt(fullfilename, '/srcs/src1', 'Position');
header.sx = srcTemp(1);
header.sy = srcTemp(2);
header.sz = srcTemp(3);

% Time vector for plotting
time = linspace(0, (header.iterations - 1) * header.dt, header.iterations)';

% Initialise structure for field arrays
fields.Ex = zeros(header.iterations, header.nrx);
fields.Ey = zeros(header.iterations, header.nrx);
fields.Ez = zeros(header.iterations, header.nrx);
fields.Hx = zeros(header.iterations, header.nrx);
fields.Hy = zeros(header.iterations, header.nrx);
fields.Hz = zeros(header.iterations, header.nrx);

for n=1:header.nrx
    path = strcat('/rxs/rx', num2str(n));
    tmp = h5readatt(fullfilename, path, 'Position');
    header.rx(n) = tmp(1);
    header.ry(n) = tmp(2);
    header.rz(n) = tmp(3);
    path = strcat(path, '/');
    fields.Ex(:,n) = h5read(fullfilename, strcat(path, 'Ex'));
    fields.Ey(:,n) = h5read(fullfilename, strcat(path, 'Ey'));
    fields.Ez(:,n) = h5read(fullfilename, strcat(path, 'Ez'));
    fields.Hx(:,n) = h5read(fullfilename, strcat(path, 'Hx'));
    fields.Hy(:,n) = h5read(fullfilename, strcat(path, 'Hy'));
    fields.Hz(:,n) = h5read(fullfilename, strcat(path, 'Hz'));
end

%% FFT of Components
% https://de.mathworks.com/help/wavelet/gs/from-fourier-analysis-to-wavelet-analysis.html
% https://de.mathworks.com/help/matlab/math/fourier-transforms.html
% fs = 1/header.dt;
% fAxis = (0:header.iterations-1)*fs/header.iterations;

df    = 1/(header.dt*header.iterations);
fAxis = linspace(0,header.iterations/2,fix(header.iterations/2+1))*df;    %making the frequency axis

for component = allComponents
    for iRx = 1:header.nrx
        comp = component{1};
        FFT.(comp)(:,iRx) = fft(fields.(comp)(:,iRx), [], 1)*header.dt;
    end
end

if isempty(fcut)
    fcut = fAxis(end);
end

%% Plot
for iRx = 1:header.nrx
    fig = figure;
    t = tiledlayout(1,2);
    for component = allComponents(1)
        comp = component{1};
        nexttile
        plot(time, fields.(comp)(:,iRx),'LineWidth',lw)
        title(sprintf('%s - Time Domain', comp))
        xlabel('Time (s)')
        hold on
    
        nexttile
        fftData = FFT.(comp)(:,iRx);
        FFT.([comp, 'Norm'])(:,iRx) = DataNorm(abs(fftData(:,:)), normalization);
        stem(fAxis,FFT.([comp, 'Norm'])(1:numel(fAxis),iRx) ,'LineWidth',lw, 'Color', 'b', 'LineStyle','-.')
        hold on
        stem(fAxis,FFT.([comp, 'Norm'])(1:numel(fAxis),iRx) ,'LineWidth',0.5*lw, 'Color', 'b')
        title(sprintf('%s - Frequency Domain', comp))
        xlabel('Frequency (Hz)')
        xlim([0 fcut])
    end
end


dcm = datacursormode;
dcm.Enable = 'on';
dcm.UpdateFcn = @displayCoordinates;

if isSave
    exportgraphics(gca, fullfile(figureFolder, [filenameSelect, num2str(iRx) ,'.pdf'] ),...
                   'ContentType','vector',...
                   'BackgroundColor','none')  

end


[~, indTd] = max(fields.Ex);
fprintf('Figure 1: Max Amplitude at %e s\n', time(indTd(1)))
[~, indFd] = max(FFT.ExNorm);
fprintf('Figure 1: Dominant Frequency at %e Hz\n', fAxis(indFd(1)))



if isPickt0
    fprintf('Pick time zero position:\n')
    isCorrect = false;
    while isCorrect == false
        [x,y] = ginput(1);
        fprintf('First arrival time at %e s\n', x)
        s = input('Is picking OK? [y,n]\n','s');
        if strcmp(s,'y')
            isCorrect = true;
            break
        end
    end
    axnum = find(ismember(t.Children,gca));
    plot(x,y,'Parent',t.Children(axnum), 'Color','r', 'Marker','o')
end

%% Create output structure

isSaveStruc = input('Save Results to Structure? [y n]\n','s');

if strcmp(isSaveStruc, 'y')

    newName = erase(filenameSelect,{'.','-','_'});
    
    
    NewRes= struct;
    NewRes.(newName).Attributes   = header;
    NewRes.(newName).Data.fields  = fields;
    NewRes.(newName).Data.FFT     = FFT;
    NewRes.(newName).Axis.time    = time;
    NewRes.(newName).Axis.fAxis    = fAxis;
    NewRes.(newName).Label.DomFreq = fAxis(indFd(1));
    NewRes.(newName).Label.MaxAmp  = time(indTd(1));

    %% Save

    data = load(fullfile(pathRoot, '3. Semester - Studienunterlagen\ResearchModule\AllResults.mat'));
    Results = data.Results;

    if ~ismember(newName, fieldnames(Results))
       
        Results.(newName) = NewRes.(newName);

        save (fullfile(pathRoot, '3. Semester - Studienunterlagen\ResearchModule\AllResults.mat'),'Results', '-v7.3')
        fprintf('Succesfully save file.\n')
    else
        fprintf('The field %s already exists in Results\n', newName)
        answer = input('Really save?\n','s');
        if strcmp(answer, 'y')
            Results.(newName) = NewRes.(newName);
    
            save (fullfile(pathRoot, '3. Semester - Studienunterlagen\ResearchModule\AllResults.mat'),'Results', '-v7.3')
            fprintf('Succesfully save file.\n')
        end
    end

end
% %% Select Time Window
% if isTimeWindow
% 
%     if isempty(t0) 
%         t0 = input('Start of time window to analyze:\n');
%     end
%     
%     if isempty(tEnd)
%         tEnd = input('End of time window to analyze:\n');
%     end
%     
%     % Plot Lines 
%     for iT = 2
%         xline(t0, 'Parent',t.Children(iT), 'Color','r','Label','t0')
%         xline(tEnd, 'Parent', t.Children(iT), 'Color','r','Label','tEnd')
%     end
%     
%     iT0 = find(time >= t0, 1,"first");
%     iTEnd = find(time >= tEnd, 1,"first");
    
%     %% New FFT for time window
%     
%     timeWindNew = time(iT0:iTEnd);
%     
%     df    = 1/(header.dt*numel(timeWindNew));
%     
%     fAxisTW = linspace(0,numel(timeWindNew)/2,fix(numel(timeWindNew)/2)+1)*df;    %making the frequency axis
%     
%     for component = allComponents
%         comp = component{1};
%         FFTTimeWindow.(comp) = fft(fields.(comp)(iT0:iTEnd,1), [], 1)*header.dt;
%     end
%     
%     figTW = figure;
%     t1 = tiledlayout(3,2);
%     title(t1,sprintf('time window: %.2es - %.2es',t0, tEnd))
%     iRx = 1;
%     
%     for component = allComponents
%         comp = component{1};
%         nexttile
%         plot(timeWindNew, fields.(comp)(iT0:iTEnd, iRx),'LineWidth',lw)
%         title(sprintf('%s - Time Domain', comp))
%         xlabel('Time (s)')
%     
%         nexttile
%         fftData = FFTTimeWindow.(comp)(:,iRx);
%         stem(fAxisTW,DataNorm(abs(fftData(1:numel(fAxisTW),iRx)), normalization) ,'LineWidth',lw, 'LineStyle','-.', 'Color','b')
%         hold on
%         plot(fAxisTW,DataNorm(abs(fftData(1:numel(fAxisTW),iRx)), normalization),'LineWidth',0.5*lw, 'Color','b')
%         title(sprintf('%s - Frequency Domain', comp))
%         xlabel('Frequency (Hz)')
%         xlim([0 fcut])
%     end

% end
%% DCM
% dcm = datacursormode;
% dcm.Enable = 'on';
% dcm.UpdateFcn = @displayCoordinates;


% Local Function
% function txt = displayCoordinates(~,info)
%     x = info.Position(1);
%     y = info.Position(2);
%     txt = sprintf('%.3e, %.3e',x,y);
% end



