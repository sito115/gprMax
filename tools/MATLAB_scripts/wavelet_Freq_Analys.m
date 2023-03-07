%% Select Path

function allData = fft_gprMaxOutput(path, fileNameSelect)

clear
%% File give or GUI?
isFile       = 0;
%%

pathRoot     = 'C:\OneDrive - Delft University of Technology';
trdSemester  = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\thomas\python';
figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';

fullfilename = fullfile(path, fileNameSelect);

allComponents = {'Ex', 'Ey', 'Ez'};
%% Check
assert(check ~= 0, 'No File Selected')

%% Load MetaData
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


fprintf('Loaded... %s\n', filenameSelect)

%% Load E-Field Time Domain

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



%% Create output structure

isSaveStruc = input('Save Results to Structure? [y n]\n','s');

if strcmp(isSaveStruc, 'y')

    newName = erase(filenameSelect,{'.','-','_'});
    
    allData= struct;
    allData.(newName).Attributes   = header;
    allData.(newName).Data.fields  = fields;
    allData.(newName).Data.FFT     = FFT;
    allData.(newName).Axis.time    = time;
    allData.(newName).Axis.fAxis    = fAxis;
    allData.(newName).Label.DomFreq = fAxis(indFd(1));
    allData.(newName).Label.MaxAmp  = time(indTd(1));

    %% Save

%     data = load(fullfile(pathRoot, '3. Semester - Studienunterlagen\ResearchModule\AllResults.mat'));
%     Results = data.Results;
% 
%     if ~ismember(newName, fieldnames(Results))
%        
%         Results.(newName) = allData.(newName);
% 
%         save (fullfile(pathRoot, '3. Semester - Studienunterlagen\ResearchModule\AllResults.mat'),'Results', '-v7.3')
%         fprintf('Succesfully save file.\n')
%     else
%         fprintf('The field %s already exists in Results\n', newName)
%         answer = input('Really save?\n','s');
%         if strcmp(answer, 'y')
%             Results.(newName) = allData.(newName);
%     
%             save (fullfile(pathRoot, '3. Semester - Studienunterlagen\ResearchModule\AllResults.mat'),'Results', '-v7.3')
%             fprintf('Succesfully save file.\n')
%         end
%     end
% 
% end

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



