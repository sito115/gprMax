%% Select Path
function [allData,fieldName] = fft_gprMaxOutput(path, fileName, isFFT)

fullfilename  = fullfile(path, fileName);
allComponents = {'Ex', 'Ey', 'Ez'};         % to perform fft

%% Load MetaData
fprintf('%s\n', fileName)
fprintf('\tLoading Metadata...')

header = struct;

header.title      = h5readatt(fullfilename, '/', 'Title');
header.iterations = double(h5readatt(fullfilename,'/', 'Iterations'));
tmp               = h5readatt(fullfilename, '/', 'dx_dy_dz');
header.dx         = tmp(1);
header.dy         = tmp(2);
header.dz         = tmp(3);
header.dt         = h5readatt(fullfilename, '/', 'dt');
header.nsrc       = h5readatt(fullfilename, '/', 'nsrc');
header.nrx        = h5readatt(fullfilename, '/', 'nrx');
header.nx_ny_nz   = h5readatt(fullfilename, '/', 'nx_ny_nz');
header.srcsteps   = h5readatt(fullfilename, '/', 'srcsteps');   
header.rxsteps    = h5readatt(fullfilename, '/', 'rxsteps');   
header.gprMaxVers = h5readatt(fullfilename, '/', 'gprMax');

header.fullfileName = fullfilename;

srcPositions = zeros(header.nsrc, 3);
srcTypes      = strings(header.nsrc,1);   
for iSrc = 1:header.nsrc
    srcPos      = h5readatt(fullfilename, ['/srcs/src',num2str(iSrc)], 'Position');
    srcType     = h5readatt(fullfilename, ['/srcs/src',num2str(iSrc)], 'Type');
    srcPositions(iSrc,:) = srcPos;
    srcTypes(iSrc)       = srcType;
end
header.SrcData = table(srcTypes, srcPositions,...
                    'VariableNames',{ 'Type', 'Position'});
fprintf('Done \n')

%% Load E-Field Time Domain
fprintf('\tLoading E & H field time domain...')
% Time vector for plotting
time = linspace(0, (header.iterations - 1) * header.dt, header.iterations)';

% Initialise structure for field arrays
fields.Ex = zeros(header.iterations, header.nrx);
fields.Ey = zeros(header.iterations, header.nrx);
fields.Ez = zeros(header.iterations, header.nrx);
fields.Hx = zeros(header.iterations, header.nrx);
fields.Hy = zeros(header.iterations, header.nrx);
fields.Hz = zeros(header.iterations, header.nrx);

rxPositions = zeros(header.nrx, 3);
rxNames     = strings(header.nrx,1);    
for iRx=1:header.nrx
    path = strcat('/rxs/rx', num2str(iRx));

    rxPos      = h5readatt(fullfilename, path, 'Position');
    rxName     = h5readatt(fullfilename, path, 'Name');
    rxPositions(iRx,:) = rxPos;
    rxNames(iRx)        = rxName;

    path = strcat(path, '/');
    fields.Ex(:,iRx) = h5read(fullfilename, strcat(path, 'Ex'));
    fields.Ey(:,iRx) = h5read(fullfilename, strcat(path, 'Ey'));
    fields.Ez(:,iRx) = h5read(fullfilename, strcat(path, 'Ez'));
    fields.Hx(:,iRx) = h5read(fullfilename, strcat(path, 'Hx'));
    fields.Hy(:,iRx) = h5read(fullfilename, strcat(path, 'Hy'));
    fields.Hz(:,iRx) = h5read(fullfilename, strcat(path, 'Hz'));
end

header.RxData = table(rxNames, rxPositions,...
                'VariableNames',{ 'Name', 'Position'});

scrPos      = header.SrcData.Position(1,1); % x-coordinates
offset      = header.RxData.Position(:,1) - scrPos; % x-coordinates
header.Offset_x = offset;
fprintf('Done \n')
%% FFT of Components
if isFFT
    % https://de.mathworks.com/help/wavelet/gs/from-fourier-analysis-to-wavelet-analysis.html
    % https://de.mathworks.com/help/matlab/math/fourier-transforms.html
    % fs = 1/header.dt;
    % fAxis = (0:header.iterations-1)*fs/header.iterations;
    
    % NEW
    fprintf('\tPerforming FFT...')
    exp2n = log2(header.iterations); % get exponent for 2^n series
    exp2n = ceil(exp2n + 1); % get next higher exponent
    
    iterationsFFT = 2^exp2n;
    
    df    = 1/(header.dt*iterationsFFT);
    fAxis = linspace(0,iterationsFFT/2,fix(iterationsFFT/2+1))*df;    %making the frequency axis
    
    for component = allComponents
        for iRx = 1:header.nrx
            comp = component{1};
            timeField = [fields.(comp)(:,iRx);zeros(iterationsFFT-header.iterations,1)];
            FFT.(comp)(:,iRx) = fft(timeField, [], 1)*header.dt;
        end
    end
    
    
    fprintf('Done \n')
end
%% Create output structure

fprintf('\tSaving...')

% erase ilegal characters
fieldName = erase(fileName,{'.','-','_',' ','(',')','[',']','+','-'});

allData= struct;
allData.(fieldName).Attributes   = header;
allData.(fieldName).Data.fields  = fields;
if isFFT
    allData.(fieldName).Data.FFT     = FFT;
    allData.(fieldName).Axis.fAxis   = fAxis;
end
allData.(fieldName).Axis.time    = time;
allData.(fieldName).FileName     = fileName;

fprintf('Done \n')
